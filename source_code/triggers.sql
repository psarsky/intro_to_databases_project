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

CREATE TRIGGER check_order_limit_before_insert
ON studymeetingorders
FOR INSERT
AS
BEGIN
    DECLARE @meeting_limit INT;
    DECLARE @current_orders INT;
    DECLARE @meetingid INT;
    
    SELECT @meetingid = meetingid FROM inserted;
    
    SELECT @meeting_limit = limit
    FROM study_meetings
    WHERE meetingid = @meetingid;
    
    SELECT @current_orders = COUNT(*)
    FROM studymeetingorders
    WHERE meetingid = @meetingid;
    
    IF @current_orders >= @meeting_limit
    BEGIN
        RAISERROR('Limit zamówieñ dla tego spotkania zosta³ przekroczony', 16, 1);
        ROLLBACK TRANSACTION; 
    END
END;
GO

CREATE TRIGGER trg_AllowToSignUpOnCourseMeeting
    ON CourseOrders
    INSTEAD OF INSERT
    AS
	BEGIN
		IF EXISTS (SELECT OrderID FROM Orders WHERE OrderID = (SELECT OrderID FROM inserted))
			BEGIN
				IF ((SELECT TOP 1 scm.Limit-(SELECT COUNT(*)
											FROM CourseOrders as co
											WHERE cm.CourseID = co.CourseID)
						FROM StationaryCourseMeetings as scm
						JOIN CourseMeetings as cmeet on cmeet.MeetingID=scm.MeetingID
						JOIN CourseModules as cm on cm.ModuleID = cmeet.ModuleID
						WHERE cm.CourseID=5
						ORDER BY 1)>0)
					BEGIN
						DECLARE @OrderID int
						SET @OrderID = (SELECT OrderID FROM inserted)
						DECLARE @DetailType nvarchar(50)
						SET @DetailType = 'Course'
						DECLARE @CourseID int
						SET @CourseID = (SELECT CourseID FROM inserted)
						DECLARE @PaymentInAdvance money
						SET @PaymentInAdvance = (SELECT PaymentInAdvance FROM inserted)
						DECLARE @FullPrice money
						SET @FullPrice = (SELECT FullPrice FROM inserted)
						DECLARE @PaymentDateInAdvance datetime
						SET @PaymentDateInAdvance = (SELECT PaymentDateInAdvance FROM inserted)
						DECLARE @PaymentDateFull datetime
						SET @PaymentDateFull = (SELECT PaymentDateFull FROM inserted)

						EXEC AddOrderDetails @OrderID, @DetailType, @CourseID, NULL, NULL, @PaymentInAdvance, @FullPrice, @PaymentDateInAdvance, @PaymentDateFull 
					END
				ELSE
					THROW 50031, 'Course is full. You can`t sign up to it.', 40
			END
		ELSE
			THROW 50020, 'No course found for given ID.', 40;
	END;