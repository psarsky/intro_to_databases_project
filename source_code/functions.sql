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

GO

CREATE FUNCTION GetMaxCourseCapacity(@CourseID int)
    RETURNS int
AS
BEGIN
    DECLARE @MaxCapacity int;

    SELECT @MaxCapacity = MIN(scm.Limit)
    FROM StationaryCourseMeetings scm
             INNER JOIN CourseMeetings cm
                        ON scm.MeetingID = cm.MeetingID
             INNER JOIN CourseModules cmod
                        ON cm.ModuleID = cmod.ModuleID
    WHERE cmod.CourseID = @CourseID;

    RETURN @MaxCapacity;
END;

GO

CREATE FUNCTION GetMaxStudyCapacity(@StudyID int)
    RETURNS int
AS
BEGIN
    DECLARE @MaxCapacity int;

    SELECT @MaxCapacity = MIN(sm.Limit)
    FROM StudyMeetings sm
             INNER JOIN Studies s
                        ON s.StudyID = sm.StudyID
    WHERE s.StudyID = @StudyID;

    RETURN @MaxCapacity;
END;

GO

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
    WHERE UserID IN (SELECT u.UserID
                     FROM Users AS u
                              JOIN StudentLists AS sl
                                   ON u.UserID = sl.UserID
                     WHERE sl.StudyID = @StudyID);

    RETURN @MaximumCapacity - @CurrentCapacity
END;

GO

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
    SELECT @OccupiedSeats = COUNT(cma.UserID)
    FROM CourseModules cm
             INNER JOIN CourseMeetings m
                        ON cm.ModuleID = m.ModuleID
             LEFT JOIN CourseMeetingAttendance cma
                       ON m.MeetingID = cma.MeetingID
                           AND cma.Attended = 1
    WHERE cm.CourseID = @CourseID;
    RETURN @MaximumCapacity - @OccupiedSeats;
END;

GO

CREATE FUNCTION CheckTranslatorLanguage(@TranslatorID int, @LanguageID int)
    RETURNS bit AS
BEGIN
    IF @TranslatorID IS NOT NULL
        AND NOT EXISTS (SELECT *
                        FROM TranslatorLanguages
                        WHERE TranslatorID = @TranslatorID)
        BEGIN
            RETURN CAST(0 AS bit)
        END

    IF @LanguageID IS NOT NULL
        AND NOT EXISTS (SELECT *
                        FROM TranslatorLanguages
                        WHERE LanguageID = @LanguageID)
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

    IF @TranslatorID IS NOT NULL AND @LanguageID IS NOT NULL AND
       NOT EXISTS (SELECT *
                   FROM TranslatorLanguages
                   WHERE TranslatorID = @TranslatorID
                     AND LanguageID = @LanguageID)
        BEGIN
            RETURN CAST(0 AS bit)
        END

    RETURN CAST(1 AS bit)
END

GO

CREATE FUNCTION GenerateStudentSchedule(@UserID INT)
    RETURNS TABLE
        AS
        RETURN(SELECT c.Name     AS MeetingName,
                      c.Date     AS Start,
                      c.Duration AS Duration,
                      sub.Name   AS SubjectName,
                      s.Name     AS StudiesName
               FROM Classes AS c
                        JOIN Subjects AS sub
                             ON sub.SubjectID = c.SubjectID
                        JOIN SubjectDetails sd
                             ON sd.SubjectID = sub.SubjectID
                        JOIN Studies s
                             ON sd.StudyID = s.StudyID
                        JOIN StudentLists sl
                             ON sl.StudyID = s.StudyID
               WHERE sl.UserID = @UserID
               UNION
               SELECT cm.Name     AS MeetingName,
                      cm.Date     AS Start,
                      cm.Duration AS Duration,
                      c.Name      AS SubjectName,
                      NULL        AS StudiesName
               FROM CourseMeetings AS cm
                        JOIN CourseModules AS cmod
                             ON cm.ModuleID = cmod.ModuleID
                        JOIN Courses AS c
                             ON cmod.CourseID = c.CourseID
                        JOIN CourseOrders AS co
                             ON c.CourseID = co.CourseID
                        JOIN Orders AS o
                             ON co.OrderID = o.OrderID
               WHERE o.UserID = @UserID
               UNION
               SELECT w.Name     AS MeetingName,
                      w.Date     AS Start,
                      w.Duration AS Duration,
                      NULL       AS SubjectName,
                      NULL       AS StudiesName
               FROM Webinars AS w
                        JOIN WebinarOrders AS wo
                             ON w.WebinarID = wo.WebinarID
                        JOIN Orders AS o
                             ON wo.OrderID = o.OrderID
               WHERE o.UserID = @UserID);

GO

CREATE FUNCTION GenerateCourseSchedule(@CourseID INT)
    RETURNS TABLE
        AS
        RETURN(SELECT cm.Name, cm.Date, cm.Duration, c.Name AS CourseName, cmod.Name AS ModuleName
               FROM CourseMeetings AS cm
                        JOIN CourseModules AS cmod
                             ON cm.ModuleID = cmod.ModuleID
                        JOIN Courses AS c
                             ON cmod.CourseID = c.CourseID
               WHERE c.CourseID = @CourseID);

GO

CREATE FUNCTION GenerateStudySchedule(@StudyID INT)
    RETURNS TABLE
        AS
        RETURN(SELECT c.Name, c.Date, c.Duration, s.Name AS StudyName, sub.Name AS SubjectName
               FROM Classes AS c
                        JOIN Subjects AS sub
                             ON c.SubjectID = sub.SubjectID
                        JOIN Studies AS s
                             ON c.StudyID = s.StudyID
               WHERE s.StudyID = @StudyID);

GO

CREATE FUNCTION StudyClassesGenerateAttendanceList(@ClassID INT)
    RETURNS TABLE
        AS
        RETURN(SELECT u.FirstName, u.LastName, ca.Attended
               FROM Classes AS c
                        JOIN ClassAttendance AS ca
                             ON c.ClassID = ca.ClassID
                        JOIN Users AS u
                             ON ca.UserID = u.UserID
               WHERE c.ClassID = @ClassID);

GO

CREATE FUNCTION CourseMeetingGenerateAttendanceList(@MeetingID INT)
    RETURNS TABLE
        AS
        RETURN(SELECT u.FirstName, u.LastName, cma.Attended
               FROM CourseMeetings AS cm
                        JOIN CourseMeetingAttendance AS cma
                             ON cm.MeetingID = cma.MeetingID
                        JOIN Users AS u ON cma.UserID = u.UserID
               WHERE cm.MeetingID = @MeetingID);

GO

CREATE FUNCTION GenerateStudySyllabus(@StudyID int)
    RETURNS TABLE
        AS
        RETURN(SELECT s.Name        AS SubjectName,
                      s.Description AS SubjectDescription,
                      sd.SemesterNo AS Semester
               FROM SubjectDetails sd
                        INNER JOIN Subjects s
                                   ON sd.SubjectID = s.SubjectID
               WHERE sd.StudyID = @StudyID);

GO

CREATE FUNCTION GenerateDiploma(@UserID int, @StudyID int)
    RETURNS TABLE
        AS
        Return(SELECT s.Name AS SubjectName,
                      sg.Grade
               FROM Users u
                        INNER JOIN SubjectGrades sg
                                   ON u.UserID = sg.UserID
                        INNER JOIN Subjects s
                                   ON s.SubjectID = sg.SubjectID
               WHERE u.UserID = @UserID
                 AND sg.StudyID = @StudyID);

GO

CREATE FUNCTION UserPassedCourse(@UserID int, @CourseID int)
    RETURNS bit
AS
BEGIN
    DECLARE @Result bit = 0
    DECLARE @MeetingCount int
    DECLARE @MeetingsAttended int

    SET @MeetingCount = (SELECT COUNT(*)
                         FROM dbo.GenerateCourseSchedule(@CourseID))
    SET @MeetingsAttended = (SELECT COUNT(*)
                             FROM CourseMeetingAttendance cma
                                      INNER JOIN CourseMeetings cm
                                                 ON cma.MeetingID = cm.MeetingID
                                      INNER JOIN CourseModules cmod
                                                 ON cm.ModuleID = cmod.ModuleID
                                      INNER JOIN Courses c
                                                 ON cmod.CourseID = c.CourseID
                             WHERE c.CourseID = @CourseID
                               AND cma.UserID = @UserID
                               AND cma.Attended = 1)

    IF @MeetingsAttended / @MeetingCount > 0.8
        SET @Result = 1

    RETURN @Result
END

GO

CREATE FUNCTION CheckWebinarAccess(@UserID int, @WebinarID int)
    RETURNS bit
AS
BEGIN
    DECLARE @Result bit = 0

    IF (SELECT DATEDIFF(DAYOFYEAR, w.Date, GETDATE())
        FROM Webinars w
        WHERE w.WebinarID = @WebinarID) BETWEEN 0 AND 30
        AND @UserID IN (SELECT o.UserID
                        FROM Webinars w
                                 INNER JOIN WebinarOrders wo
                                            ON w.WebinarID = wo.WebinarID
                                 INNER JOIN Orders o
                                            ON wo.OrderID = o.OrderID
                        WHERE w.WebinarID = @WebinarID
                          AND o.UserID = @UserID
                          AND wo.PaymentDate IS NOT NULL)
        SET @Result = 1

    RETURN @Result
END

GO

CREATE FUNCTION GenerateOrderInfo(@OrderID int)
    RETURNS TABLE
        AS
        RETURN(SELECT o.OrderID      AS OrderID,
                      o.UserID       AS UserID,
                      'Webinar'      AS ProductType,
                      wo.WebinarID   AS ProductID,
                      wo.Price       AS Price,
                      o.OrderDate    AS OrderDate,
                      wo.PaymentDate AS PaymentDate
               FROM Orders o
                        INNER JOIN WebinarOrders wo
                                   ON o.OrderID = wo.OrderID
               WHERE o.OrderID = @OrderID
               UNION
               SELECT o.OrderID          AS OrderID,
                      o.UserID           AS UserID,
                      'Course'           AS ProductType,
                      co.CourseID        AS ProductID,
                      co.FullPrice       AS Price,
                      o.OrderDate        AS OrderDate,
                      co.PaymentDateFull AS PaymentDate
               FROM Orders o
                        INNER JOIN CourseOrders co
                                   ON o.OrderID = co.OrderID
               WHERE o.OrderID = @OrderID
               UNION
               SELECT o.OrderID       AS OrderID,
                      o.UserID        AS UserID,
                      'Study meeting' AS ProductType,
                      smo.MeetingID   AS ProductID,
                      smo.Price       AS Price,
                      o.OrderDate     AS OrderDate,
                      smo.PaymentDate AS PaymentDate
               FROM Orders o
                        INNER JOIN StudyMeetingOrders smo
                                   ON o.OrderID = smo.OrderID
               WHERE o.OrderID = @OrderID
               UNION
               SELECT o.OrderID      AS OrderID,
                      o.UserID       AS UserID,
                      'Studies'      AS ProductType,
                      so.StudyID     AS ProductID,
                      so.Price       AS Price,
                      o.OrderDate    AS OrderDate,
                      so.PaymentDate AS PaymentDate
               FROM Orders o
                        INNER JOIN StudyOrders so
                                   ON o.OrderID = so.OrderID
               WHERE o.OrderID = @OrderID);
GO

CREATE FUNCTION GetStudyMeetingPrice(@MeetingID int)
    RETURNS money
AS
BEGIN
    DECLARE @Price money = 0
    IF EXISTS (SELECT *
               FROM StudyMeetings
               WHERE MeetingID = @MeetingID)
        BEGIN
            SET @Price = ( SELECT Price 
							FROM StudyMeetings
							WHERE MeetingID=@MeetingID)
        END
    RETURN @Price
END

