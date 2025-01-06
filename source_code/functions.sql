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
END
