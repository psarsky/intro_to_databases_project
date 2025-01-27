CREATE TRIGGER dbo.trg_AddStudentToStudentList
    ON dbo.StudyOrders
    AFTER INSERT
    AS
BEGIN
    IF EXISTS (SELECT UserID
               FROM INSERTED i
                        INNER JOIN StudyOrders so
                                   ON i.OrderID = so.OrderID
                        INNER JOIN Orders o
                                   ON o.OrderID = so.OrderID
               WHERE UserID IN (SELECT DISTINCT UserID
                                FROM INSERTED i
                                         INNER JOIN StudentLists sl
                                                    ON i.StudyID = sl.UserID))
        THROW 50050, 'User with given ID is already assigned to the given studies', 20
    IF NOT EXISTS (SELECT i.PaymentDate
               FROM INSERTED i)
        THROW 50051, 'User did not pay for studies', 20
    ELSE
        BEGIN
            DECLARE @StudentID int;
            SELECT @StudentID = o.UserID
            FROM INSERTED i
                     INNER JOIN StudyOrders so
                                ON i.OrderID = so.OrderID
                     INNER JOIN Orders o
                                ON o.OrderID = so.OrderID;

            INSERT INTO StudentLists(StudyID, UserID)
            SELECT i.StudyID, @StudentID
            FROM inserted i;
        END
END;
GO

CREATE TRIGGER dbo.trg_CheckStudyMeetingLimitBeforeInsert
    ON StudyMeetingOrders
    FOR INSERT
    AS
BEGIN
    DECLARE @meeting_limit INT;
    DECLARE @current_orders INT;
    DECLARE @meetingid INT;

    SELECT @meetingid = meetingid FROM inserted;

    SELECT @meeting_limit = limit
    FROM studymeetings
    WHERE meetingid = @meetingid;

    SELECT @current_orders = COUNT(*)
    FROM studymeetingorders
    WHERE meetingid = @meetingid;

    IF @current_orders >= @meeting_limit
        BEGIN
            RAISERROR ('Place limit exceeded', 16, 1);
            ROLLBACK TRANSACTION;
        END
END;
GO

CREATE TRIGGER dbo.trg_CheckCourseLimitBeforeInsert
    ON CourseOrders
    FOR INSERT
    AS
BEGIN
    DECLARE @course_limit INT;
    DECLARE @current_orders INT;
    DECLARE @meetingid INT;

    SELECT @meetingid = courseid FROM inserted;

    SELECT @course_limit = limit
    FROM CourseMeetings cm
             INNER JOIN StationaryCourseMeetings scm
                 ON cm.MeetingID = scm.MeetingID
    WHERE cm.meetingid = @meetingid;

    SELECT @current_orders = COUNT(*)
    FROM studymeetingorders
    WHERE meetingid = @meetingid;

    IF @current_orders >= @course_limit
        BEGIN
            RAISERROR ('Place limit exceeded', 16, 1);
            ROLLBACK TRANSACTION;
        END
END;
GO
