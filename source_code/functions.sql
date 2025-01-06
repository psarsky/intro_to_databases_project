GO

CREATE FUNCTION GetOrderValue(@OrderID int)
    RETURNS money
AS
BEGIN
    DECLARE @StudiesSum money = 0
    DECLARE @StudyMeetingsSum money = 0
    DECLARE @CoursesSum money = 0
    DECLARE @WebinarsSum money = 0
    IF EXISTS (SELECT 1
               FROM Orders
               WHERE OrderID = @OrderID)
        BEGIN
            SET @StudiesSum = (SELECT ISNULL(SUM(so.Price), 0)
                               FROM StudyOrders AS so
                               WHERE so.OrderID = @OrderID)

            SET @StudyMeetingsSum = (SELECT ISNULL(SUM(smo.Price), 0)
                                     FROM StudyMeetingOrders smo
                                     WHERE smo.OrderID = @OrderID)

            SET @CoursesSum = (SELECT ISNULL(SUM(co.FullPrice), 0)
                               FROM CourseOrders AS co
                               WHERE co.OrderID = @OrderID)

            SET @WebinarsSum = (SELECT ISNULL(SUM(wo.Price), 0)
                                FROM WebinarOrders AS wo
                                WHERE wo.OrderID = @OrderID)
        END
    RETURN @StudiesSum + @CoursesSum + @WebinarsSum + @StudyMeetingsSum
END

GO

CREATE FUNCTION CheckInternshipAttendance(@StudentID int)
    RETURNS bit
AS
BEGIN
    DECLARE @Result bit = 0
    IF EXISTS (SELECT 1 FROM StudentLists WHERE UserID = @StudentID)
        BEGIN
            -- Check if any internships assigned to the student have ended
            IF EXISTS (SELECT 1
                       FROM Internships i
                                INNER JOIN StudentLists sl
                                           ON i.StudyID = sl.StudyID
                       WHERE sl.UserID = @StudentID
                         AND i.StartDate <= GETDATE() - 14)
                BEGIN
                    -- Check if the student attended all assigned internships that have ended
                    IF NOT EXISTS (SELECT 1
                                   FROM InternshipAttendance ia
                                            INNER JOIN Internships i
                                                       ON ia.InternshipID = i.InternshipID
                                   WHERE i.StartDate <= GETDATE() - 14
                                     AND ia.UserID = @StudentID
                                     AND ia.Attended = 0)
                        SET @Result = 1
                END
        END
    RETURN @Result
END

GO

CREATE FUNCTION CheckCoursePaymentDeadline(@UserID int, @CourseID int)
    RETURNS bit
BEGIN
    DECLARE @Result bit = 0
    DECLARE @PaymentDate datetime
    DECLARE @Deadline datetime

    SET @PaymentDate = (SELECT co.PaymentDateFull
                        FROM CourseOrders co
                                 INNER JOIN Orders o
                                            ON co.OrderID = o.OrderID
                        WHERE o.UserID = @UserID
                          AND co.CourseID = @CourseID)

    SET @Deadline = (SELECT c.BeginDate - 3
                     FROM Courses c
                     WHERE c.CourseID = @CourseID)

    IF @PaymentDate IS NOT NULL AND @PaymentDate < @Deadline
        SET @Result = 1

    RETURN @Result
END

GO

CREATE FUNCTION CheckStudyMeetingPaymentDeadline(@UserID int, @MeetingID int)
    RETURNS bit
BEGIN
    DECLARE @Result bit = 0
    DECLARE @PaymentDate datetime
    DECLARE @Deadline datetime

    SET @PaymentDate = (SELECT smo.PaymentDate
                        FROM StudyMeetingOrders smo
                                 INNER JOIN Orders o
                                            ON smo.OrderID = o.OrderID
                        WHERE o.UserID = @UserID
                          AND smo.MeetingID = @MeetingID)

    SET @Deadline = (SELECT sm.BeginDate - 3
                     FROM StudyMeetings sm
                     WHERE sm.MeetingID = @MeetingID)

    IF @PaymentDate IS NOT NULL AND @PaymentDate < @Deadline
        SET @Result = 1

    RETURN @Result
END;

CREATE FUNCTION GetMaxCourseCapacity(@CourseID int)
RETURNS int
AS
BEGIN
    DECLARE @MaxCapacity int;

    SELECT @MaxCapacity = MIN(scm.Limit)
    FROM StationaryCourseMeetings scm
    INNER JOIN CourseMeetings cm ON scm.MeetingID = cm.MeetingID
    INNER JOIN CourseModules cmod ON cm.ModuleID = cmod.ModuleID
    WHERE cmod.CourseID = @CourseID;

    RETURN @MaxCapacity;
END;


CREATE FUNCTION GetMaxStudyCapacity(@StudyID int)
RETURNS int
AS
BEGIN
    DECLARE @MaxCapacity int;

    SELECT @MaxCapacity = MIN(sm.Limit)
    FROM StudyMeetings sm
    INNER JOIN Studies s ON s.StudyID = sm.StudyID
    WHERE s.StudyID = @StudyID;

    RETURN @MaxCapacity;
END;


CREATE FUNCTION HowManyStudyVacancies(@StudyID int)
RETURNS int
AS
BEGIN
    DECLARE @MaximumCapacity int;
    SELECT @MaximumCapacity = dbo.GetMaxStudyCapacity(@StudyID);

    IF @MaximumCapacity IS NULL
    BEGIN
        RETURN @MaximumCapacity
    END

    DECLARE @CurrentCapacity int;
    SELECT @CurrentCapacity = COUNT(*)
        FROM Users
        WHERE UserID IN (
            SELECT u.UserID
            FROM Users AS u
            JOIN StudentLists AS sl
            ON u.UserID = sl.UserID
            WHERE sl.StudyID = @StudyID);

    RETURN @MaximumCapacity - @CurrentCapacity
END;

CREATE FUNCTION HowManyCourseVacancies(@CourseID int)
RETURNS int
AS
BEGIN
    DECLARE @MaximumCapacity int;
    SELECT @MaximumCapacity = dbo.GetMaxCourseCapacity(@CourseID);
    IF @MaximumCapacity IS NULL
    BEGIN
        RETURN NULL;
    END
    DECLARE @OccupiedSeats int;
    SELECT
        @OccupiedSeats = COUNT(cma.UserID)
    FROM CourseModules cm
    INNER JOIN CourseMeetings m ON cm.ModuleID = m.ModuleID
    LEFT JOIN CourseMeetingAttendance cma ON m.MeetingID = cma.MeetingID AND cma.Attended = 1
    WHERE cm.CourseID = @CourseID;
    RETURN @MaximumCapacity - @OccupiedSeats;
END;


CREATE FUNCTION CheckTranslatorLanguage
(@TranslatorID int null, @LanguageID int null)
RETURNS bit AS
BEGIN
    IF @TranslatorID IS NOT NULL AND NOT EXISTS (SELECT * FROM TranslatorLanguages WHERE TranslatorID = @TranslatorID)
    BEGIN
        RETURN CAST(0 AS bit)
    END

    IF @LanguageID IS NOT NULL AND NOT EXISTS (SELECT * FROM TranslatorLanguages WHERE LanguageID = @LanguageID)
    BEGIN
        RETURN CAST(0 AS bit)
    END

    IF @TranslatorID IS NULL AND @LanguageID IS NOT NULL
    BEGIN
        RETURN CAST(0 AS bit)
    END

    IF @TranslatorID IS NOT NULL AND @LanguageID IS NULL
    BEGIN
        RETURN CAST(0 AS bit)
    END

    IF @TranslatorID IS NOT NULL AND @LanguageID IS NOT NULL AND NOT EXISTS (SELECT * FROM TranslatorLanguages WHERE TranslatorID = @TranslatorID AND LanguageID = @LanguageID)
    BEGIN
        RETURN CAST(0 AS bit)
    END

    RETURN CAST(1 AS bit)
END

