--STUDIES

GO

CREATE PROCEDURE AddStudy @CoordinatorID int,
                          @Name nvarchar(100),
                          @Description nvarchar(max),
                          @TuitionFee money
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Employees e
                            INNER JOIN Positions p
                                       ON e.PositionID = p.PositionID
                   WHERE EmployeeID = @CoordinatorID
                     AND p.Name = 'Teacher')
        THROW 50000, 'No teacher found for given ID.', 0;
    IF @TuitionFee < 0
        THROW 50001, 'Tuitions fee must be a positive number.', 0;
    INSERT INTO Studies(CoordinatorID, Name, Description, TuitionFee)
    VALUES (@CoordinatorID, @Name, @Description, @TuitionFee)
END

GO

CREATE PROCEDURE AddSubject @CoordinatorID int,
                            @Name nvarchar(100),
                            @Description nvarchar(max)
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Employees e
                            INNER JOIN Positions p
                                       ON e.PositionID = p.PositionID
                   WHERE EmployeeID = @CoordinatorID
                     AND p.Name = 'Teacher')
        THROW 50000, 'No teacher found for given ID.', 1;

    INSERT INTO Subjects(CoordinatorID, Name, Description)
    VALUES (@CoordinatorID, @Name, @Description)
END

GO

CREATE PROCEDURE AssignSubjectToStudies @StudyID int,
                                        @SubjectID int,
                                        @SemesterNo int
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Studies s
                   WHERE s.StudyID = @StudyID)
        THROW 50002, 'No studies found for given ID.', 2;
    IF EXISTS (SELECT 1
               FROM SubjectDetails sd
                        INNER JOIN Subjects s
                                   ON sd.SubjectID = s.SubjectID
               WHERE sd.StudyID = @StudyID
                 AND s.Name = (SELECT s1.Name
                               FROM Subjects s1
                               WHERE s1.SubjectID = @SubjectID))
        THROW 50003, 'Provided study program already has a subject with this name.', 2;
    IF @SemesterNo NOT BETWEEN 1 AND 7
        THROW 50003, 'Provide a correct semester number.', 2;

    INSERT INTO SubjectDetails(StudyID, SubjectID, SemesterNo)
    VALUES (@StudyID, @SubjectID, @SemesterNo)
END

GO

CREATE PROCEDURE AddSubjectAndAssign @CoordinatorID int,
                                     @Name nvarchar(100),
                                     @Description nvarchar(max),
                                     @StudyID int,
                                     @SemesterNo int
AS
BEGIN
    DECLARE @SubjectID int
    EXEC AddSubject @CoordinatorID, @Name, @Description
    SET @SubjectID = (SELECT TOP 1 s.SubjectID
                      FROM Subjects s
                      ORDER BY s.SubjectID DESC)
    EXEC AssignSubjectToStudies @StudyID, @SubjectID, @SemesterNo
END

GO

CREATE PROCEDURE AddInternship @StudyID int,
                               @TeacherID int,
                               @Name nvarchar(100),
                               @StartDate datetime
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Studies s
                   WHERE s.StudyID = @StudyID)
        THROW 50002, 'No studies found for given ID.', 4;
    IF NOT EXISTS (SELECT 1
                   FROM Employees e
                            INNER JOIN Positions p
                                       ON e.PositionID = p.PositionID
                   WHERE EmployeeID = @TeacherID
                     AND p.Name = 'Teacher')
        THROW 50000, 'No teacher found for given ID.', 4;

    INSERT INTO Internships(StudyID, TeacherID, Name, StartDate)
    VALUES (@StudyID, @TeacherID, @Name, @StartDate)
END

GO

CREATE PROCEDURE ChangeInternshipDates @InternshipID int,
                                       @StartDate datetime
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Internships i
                   WHERE i.InternshipID = @InternshipID)
        THROW 50006, 'No internship found for given ID.', 5;

    UPDATE Internships
    SET StartDate = @StartDate
    WHERE InternshipID = @InternshipID
END

GO

CREATE PROCEDURE AddStudyGrade @UserID int,
                               @StudyID int
AS
BEGIN
    DECLARE @Result real

    IF NOT EXISTS (SELECT 1
                   FROM Users AS u
                   WHERE u.UserID = @UserID)
        THROW 50023, 'No user found for given ID.', 29;
    IF NOT EXISTS (SELECT 1
                   FROM Studies s
                   WHERE s.StudyID = @StudyID)
        THROW 50002, 'No studies found for given ID.', 29;
    IF NOT EXISTS (SELECT 1
                   FROM Studies s
                            INNER JOIN StudentLists sl
                                       ON s.StudyID = sl.StudyID
                   WHERE sl.UserID = @UserID)
        THROW 50026, 'The given student is not a member of the given studies.', 29;

    SET @Result = (SELECT AVG(sg.Grade)
                   FROM SubjectGrades sg
                   WHERE sg.UserID = @UserID
                     AND sg.StudyID = @StudyID)

    INSERT INTO StudyGrades (StudyID, UserID, Grade)
    VALUES (@StudyID, @UserID, @Result)
END

GO


--MEETINGS

CREATE PROCEDURE AddStudyMeeting @StudyID int,
                                 @Name nvarchar(100),
                                 @BeginDate datetime,
                                 @EndDate datetime,
                                 @Price money,
                                 @Limit int
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Studies s
                   WHERE s.StudyID = @StudyID)
        THROW 50002, 'No studies found for given ID.', 6;
    IF @Price IS NULL
        SET @Price = 100
    IF @BeginDate > @EndDate
        THROW 50004, 'Provide correct dates.', 6;

    INSERT INTO StudyMeetings(StudyID, Name, BeginDate, EndDate, Price, Limit)
    VALUES (@StudyID, @Name, @BeginDate, @EndDate, @Price, @Limit)
END

GO

CREATE PROCEDURE ChangeStudyMeetingDates @MeetingID int,
                                         @BeginDate datetime,
                                         @EndDate datetime
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM StudyMeetings sm
                   WHERE sm.MeetingID = @MeetingID)
        THROW 50005, 'No study meeting found for given ID.', 7;
    IF @BeginDate > @EndDate
        THROW 50004, 'Provide correct dates.', 7;

    UPDATE StudyMeetings
    SET BeginDate = @BeginDate,
        EndDate   = @EndDate
    WHERE MeetingID = @MeetingID
END

GO

CREATE PROCEDURE AddClass @StudyID int,
                          @SubjectID int,
                          @MeetingID int,
                          @TeacherID int,
                          @LanguageID int,
                          @TranslatorID int,
                          @Name nvarchar(100),
                          @Description nvarchar(max),
                          @Date datetime,
                          @Duration time,
                          @Type nvarchar(12)
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM SubjectDetails sd
                   WHERE sd.StudyID = @StudyID
                     AND sd.SubjectID = @SubjectID)
        THROW 50011, 'The given subject is not assigned to the given studies.', 8;
    IF @Type = 'stationary'
        AND (@MeetingID IS NULL
            OR NOT EXISTS (SELECT 1
                           FROM StudyMeetings sm
                           WHERE sm.MeetingID = @MeetingID))
        THROW 50012, 'Invalid study meeting ID for stationary class.', 8;
    ELSE
        IF @MeetingID IS NOT NULL
            THROW 500013, 'Cannot assign an online class to a study meeting.', 8;
    IF NOT EXISTS (SELECT 1
                   FROM Employees e
                            INNER JOIN Positions p
                                       ON e.PositionID = p.PositionID
                   WHERE EmployeeID = @TeacherID
                     AND p.Name = 'Teacher')
        THROW 50000, 'No teacher found for given ID.', 8;
    IF dbo.CheckTranslatorLanguage(@TranslatorID, @LanguageID) = CAST(0 AS bit)
        THROW 50008, 'Invalid translator-language pair.', 8;

    INSERT INTO Classes(StudyID, SubjectID, MeetingID, TeacherID, LanguageID, TranslatorID, Name, Description, Date,
                        Duration)
    VALUES (@StudyID, @SubjectID, @MeetingID, @TeacherID, @LanguageID, @TranslatorID, @Name, @Description, @Date,
            @Duration)
END

GO

CREATE PROCEDURE AssignStationaryClass @ClassID int,
                                       @ReservationID int
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Classes c
                   WHERE c.ClassID = @ClassID)
        THROW 50010, 'No class found for given ID.', 9;
    IF NOT EXISTS (SELECT 1
                   FROM Reservations r
                   WHERE r.ReservationID = @ReservationID)
        THROW 50013, 'No reservation found for given ID.', 9;

    INSERT INTO StationaryClasses(ClassID, ReservationID)
    VALUES (@ClassID, @ReservationID)
END

GO

CREATE PROCEDURE AssignAsynchronousClass @ClassID int,
                                         @VideoLink nvarchar(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Classes c
                   WHERE c.ClassID = @ClassID)
        THROW 50010, 'No class found for given ID.', 10;

    INSERT INTO OnlineAsynchronousClasses(ClassID, VideoLink)
    VALUES (@ClassID, @VideoLink)
END

GO

CREATE PROCEDURE AssignSynchronousClass @ClassID int,
                                        @VideoLink nvarchar(100),
                                        @MeetingLink nvarchar(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Classes c
                   WHERE c.ClassID = @ClassID)
        THROW 50010, 'No class found for given ID.', 11;

    INSERT INTO OnlineSynchronousClasses(ClassID, VideoLink, MeetingLink)
    VALUES (@ClassID, @VideoLink, @MeetingLink)
END

GO

CREATE PROCEDURE AddClassAndAssign @StudyID int,
                                   @SubjectID int,
                                   @MeetingID int,
                                   @TeacherID int,
                                   @LanguageID int,
                                   @TranslatorID int,
                                   @Name nvarchar(100),
                                   @Description nvarchar(max),
                                   @Date datetime,
                                   @Duration time,
                                   @Type nvarchar(12),
                                   @ReservationID int,
                                   @VideoLink nvarchar(100),
                                   @MeetingLink nvarchar(100)
AS
BEGIN
    DECLARE @ClassID int
    IF @Type = 'stationary'
        BEGIN
            IF @ReservationID IS NULL
                THROW 50014, 'Provide reservation ID for a stationary class.', 12;
            IF @VideoLink IS NOT NULL
                THROW 50015, 'Cannot assign a video link to this class.', 12;
            IF @MeetingLink IS NOT NULL
                THROW 50016, 'Cannot assign a meeting link to this class.', 12;
        END
    IF @Type = 'asynchronous'
        BEGIN
            IF @ReservationID IS NOT NULL
                THROW 50017, 'Cannot assign a reservation ID to this class.', 12;
            IF @VideoLink IS NULL
                THROW 50018, 'Provide a video link.', 12;
            IF @MeetingLink IS NOT NULL
                THROW 50016, 'Cannot assign a meeting link to this class.', 12;
        END
    IF @Type = 'synchronous'
        BEGIN
            IF @ReservationID IS NOT NULL
                THROW 50017, 'Cannot assign a reservation ID to this class.', 12;
            IF @VideoLink IS NULL
                THROW 50018, 'Provide a video link.', 12;
            IF @MeetingLink IS NULL
                THROW 50019, 'Provide a meeting link.', 12;
        END
    EXEC AddClass
         @StudyID,
         @SubjectID,
         @MeetingID,
         @TeacherID,
         @LanguageID,
         @TranslatorID,
         @Name,
         @Description,
         @Date,
         @Duration,
         @Type
    SET @ClassID = (SELECT TOP 1 c.ClassID
                    FROM Classes c
                    ORDER BY c.ClassID DESC)
    IF @Type = 'stationary'
        EXEC AssignStationaryClass @ClassID, @ReservationID
    IF @Type = 'asynchronous'
        EXEC AssignAsynchronousClass @ClassID, @VideoLink
    IF @Type = 'synchronous'
        EXEC AssignSynchronousClass @ClassID, @VideoLink, @MeetingLink
END


--TRANSLATORS

GO

CREATE PROCEDURE AssignTranslatorToWebinar @WebinarID int,
                                           @LanguageID int,
                                           @TranslatorID int
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Webinars w
                   WHERE w.WebinarID = @WebinarID)
        THROW 50007, 'No webinar found for given ID.', 13;
    IF dbo.CheckTranslatorLanguage(@TranslatorID, @LanguageID) = CAST(0 AS bit)
        THROW 50008, 'Invalid translator-language pair.', 13;

    UPDATE Webinars
    SET TranslatorID = @TranslatorID,
        LanguageID   = @LanguageID
    WHERE WebinarID = @WebinarID
END

GO

CREATE PROCEDURE AssignTranslatorToCourseMeeting @MeetingID int,
                                                 @LanguageID int,
                                                 @TranslatorID int
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM CourseMeetings cm
                   WHERE cm.MeetingID = @MeetingID)
        THROW 50009, 'No course meeting found for given ID.', 14;
    IF dbo.CheckTranslatorLanguage(@TranslatorID, @LanguageID) = CAST(0 AS bit)
        THROW 50008, 'Invalid translator-language pair.', 14;

    UPDATE CourseMeetings
    SET TranslatorID = @TranslatorID,
        LanguageID   = @LanguageID
    WHERE MeetingID = @MeetingID
END

GO

CREATE PROCEDURE AssignTranslatorToClass @ClassID int,
                                         @LanguageID int,
                                         @TranslatorID int
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Classes c
                   WHERE c.ClassID = @ClassID)
        THROW 50010, 'No class found for given ID.', 15;
    IF dbo.CheckTranslatorLanguage(@TranslatorID, @LanguageID) = CAST(0 AS bit)
        THROW 50008, 'Invalid translator-language pair.', 15;

    UPDATE Classes
    SET TranslatorID = @TranslatorID,
        LanguageID   = @LanguageID
    WHERE ClassID = @ClassID
END

GO


--WEBINARS

CREATE PROCEDURE AddWebinar @TeacherID int,
                            @LanguageID int,
                            @TranslatorID int,
                            @Name nvarchar(100),
                            @Description nvarchar(max),
                            @Date datetime,
                            @Duration time,
                            @MeetingLink nvarchar(100),
                            @VideoLink nvarchar(100),
                            @Price money
AS
BEGIN

    IF NOT EXISTS (SELECT 1
                   FROM Employees e
                            INNER JOIN Positions p ON e.PositionID = p.PositionID
                   WHERE EmployeeID = @TeacherID
                     AND p.Name = 'Teacher')
        THROW 50000, 'No teacher found for given ID.', 16;

    IF dbo.CheckTranslatorLanguage(@TranslatorID, @LanguageID) = CAST(0 AS bit)
        THROW 50008, 'Invalid translator-language pair.', 16;


    INSERT INTO Webinars (TeacherID, LanguageID, TranslatorID, Name, Description, Date, Duration, MeetingLink,
                          VideoLink, Price)
    VALUES (@TeacherID, @LanguageID, @TranslatorID, @Name, @Description, @Date, @Duration, @MeetingLink, @VideoLink,
            @Price);
END;

GO

CREATE PROCEDURE UpdateWebinarDate @WebinarID int,
                                   @NewDate datetime,
                                   @NewDuration time
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Webinars w
                   WHERE w.WebinarID = @WebinarID)
        THROW 50007, 'No webinar found for given ID.', 17;

    UPDATE Webinars
    SET Date     = @NewDate,
        Duration = @NewDuration
    WHERE WebinarID = @WebinarID;
END;

GO


--COURSES

CREATE PROCEDURE AddCourse @CoordinatorID int,
                           @Name varchar(100),
                           @Description nvarchar(max),
                           @Price money,
                           @BeginDate datetime,
                           @EndDate datetime
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Employees e
                            INNER JOIN Positions p ON e.PositionID = p.PositionID
                   WHERE EmployeeID = @CoordinatorID
                     AND p.Name = 'Teacher')
        THROW 50000, 'No teacher found for given ID.', 18;

    INSERT INTO Courses (CoordinatorID, Name, Description, Price, BeginDate, EndDate)
    VALUES (@CoordinatorID, @Name, @Description, @Price, @BeginDate, @EndDate);
END;

GO

CREATE PROCEDURE AddCourseModule @CourseID int,
                                 @Name nvarchar(100),
                                 @Description nvarchar(max),
                                 @ModuleType nvarchar(12)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1
                   FROM Courses
                   WHERE CourseID = @CourseID)
        THROW 50020, 'No course found for given ID.', 19;

    INSERT INTO CourseModules (CourseID, Name, Description, ModuleType)
    VALUES (@CourseID, @Name, @Description, @ModuleType);
END;

GO

CREATE PROCEDURE AddCourseMeeting @ModuleID int,
                                  @TeacherID int,
                                  @LanguageID int,
                                  @TranslatorID int,
                                  @Name nvarchar(100),
                                  @Description nvarchar(100),
                                  @Date datetime,
                                  @Duration time
AS
BEGIN

    IF @Duration IS NULL
        SET @Duration = '01:30:00'

    IF dbo.CheckTranslatorLanguage(@TranslatorID, @LanguageID) = CAST(0 AS bit)
        THROW 50008, 'Invalid translator-language pair.', 20;

    INSERT INTO CourseMeetings(ModuleID, TeacherID, LanguageID, TranslatorID, Name, Description, Date, Duration)
    VALUES (@ModuleID, @TeacherID, @LanguageID, @TranslatorID, @Name, @Description, @Date, @Duration)
END;

GO

CREATE PROCEDURE UpdateCourseMeetingDate @MeetingID int,
                                         @NewDate datetime,
                                         @NewDuration time
AS
BEGIN
    IF @NewDuration IS NULL
        SET @NewDuration = '01:30:00'
    IF NOT EXISTS (SELECT 1
                   FROM CourseMeetings cm
                   WHERE cm.MeetingID = @MeetingID)
        THROW 50009, 'No course meeting found for given ID.', 21;

    UPDATE CourseMeetings
    SET Date     = @NewDate,
        Duration = @NewDuration
    WHERE MeetingID = @MeetingID;
END;

GO

CREATE PROCEDURE AssignStationaryCourseMeeting @MeetingID int,
                                               @ReservationID int
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM CourseMeetings c
                   WHERE c.MeetingID = @MeetingID)
        THROW 50010, 'No meeting found for given ID.', 31;
    IF NOT EXISTS (SELECT 1
                   FROM Reservations r
                   WHERE r.ReservationID = @ReservationID)
        THROW 50013, 'No reservation found for given ID.', 9;

    INSERT INTO StationaryCourseMeetings(MeetingID, ReservationID)
    VALUES (@MeetingID, @ReservationID)
END

GO

CREATE PROCEDURE AssignAsynchronousCourseMeeting @MeetingID int,
                                                 @VideoLink nvarchar(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM CourseMeetings c
                   WHERE c.MeetingID = @MeetingID)
        THROW 50010, 'No meeting found for given ID.', 10;

    INSERT INTO OnlineAsynchronousCourseMeetings(MeetingID, VideoLink)
    VALUES (@MeetingID, @VideoLink)
END

GO

CREATE PROCEDURE AssignSynchronousCourseMeeting @MeetingID int,
                                                @VideoLink nvarchar(100),
                                                @MeetingLink nvarchar(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM CourseMeetings c
                   WHERE c.MeetingID = @MeetingID)
        THROW 50010, 'No meeting found for given ID.', 11;

    INSERT INTO OnlineSynchronousCourseMeetings(MeetingID, VideoLink, MeetingLink)
    VALUES (@MeetingID, @VideoLink, @MeetingLink)
END

GO

CREATE PROCEDURE AddMeetingAndAssign @ModuleID int,
                                     @TeacherID int,
                                     @LanguageID int,
                                     @TranslatorID int,
                                     @Name nvarchar(100),
                                     @Description nvarchar(max),
                                     @Date datetime,
                                     @Duration time,
                                     @Type nvarchar(12),
                                     @ReservationID int,
                                     @VideoLink nvarchar(100),
                                     @MeetingLink nvarchar(100)
AS
BEGIN
    DECLARE @MeetingID int
    IF @Type = 'stationary'
        BEGIN
            IF @ReservationID IS NULL
                THROW 50014, 'Provide reservation ID for a stationary Meeting.', 12;
            IF @VideoLink IS NOT NULL
                THROW 50015, 'Cannot assign a video link to this Meeting.', 12;
            IF @MeetingLink IS NOT NULL
                THROW 50016, 'Cannot assign a meeting link to this Meeting.', 12;
        END
    IF @Type = 'asynchronous'
        BEGIN
            IF @ReservationID IS NOT NULL
                THROW 50017, 'Cannot assign a reservation ID to this Meeting.', 12;
            IF @VideoLink IS NULL
                THROW 50018, 'Provide a video link.', 12;
            IF @MeetingLink IS NOT NULL
                THROW 50016, 'Cannot assign a meeting link to this Meeting.', 12;
        END
    IF @Type = 'synchronous'
        BEGIN
            IF @ReservationID IS NOT NULL
                THROW 50017, 'Cannot assign a reservation ID to this Meeting.', 12;
            IF @VideoLink IS NULL
                THROW 50018, 'Provide a video link.', 12;
            IF @MeetingLink IS NULL
                THROW 50019, 'Provide a meeting link.', 12;
        END
    EXEC AddCourseMeeting
         @ModuleID,
         @TeacherID,
         @LanguageID,
         @TranslatorID,
         @Name,
         @Description,
         @Date,
         @Duration
    SET @MeetingID = (SELECT TOP 1 c.MeetingID
                      FROM CourseMeetings c
                      ORDER BY c.MeetingID DESC)
    IF @Type = 'stationary'
        EXEC AssignStationaryCourseMeeting @MeetingID, @ReservationID
    IF @Type = 'asynchronous'
        EXEC AssignAsynchronousCourseMeeting @MeetingID, @VideoLink
    IF @Type = 'synchronous'
        EXEC AssignSynchronousCourseMeeting @MeetingID, @VideoLink, @MeetingLink
END

GO

-- PEOPLE

CREATE PROCEDURE AddEmployee @p_FirstName NVARCHAR(30),
                             @p_LastName NVARCHAR(30),
                             @p_PositionName NVARCHAR(20),
                             @p_Email NVARCHAR(64),
                             @p_Password NVARCHAR(64),
                             @p_Phone NVARCHAR(15)
AS
BEGIN

    DECLARE @v_PositionID INT;
    SELECT @v_PositionID = PositionID
    FROM Positions
    WHERE name = @p_PositionName;

    IF @v_PositionID IS NULL
        THROW 50021, 'No position with given name', 22;

    INSERT INTO Employees (PositionID, Email, Password, FirstName, LastName, HireDate, Phone)
    VALUES (@v_PositionID, @p_Email, @p_Password, @p_FirstName, @p_LastName, GETDATE(), @p_Phone);
END;

GO

CREATE PROCEDURE ModifyEmployee @p_EmployeeID INT,
                                @p_PositionName NVARCHAR(20),
                                @p_Phone NVARCHAR(15)
AS
BEGIN

    IF NOT EXISTS (SELECT 1
                   FROM Employees AS e
                   WHERE e.EmployeeID = @p_EmployeeID)
        THROW 50027, 'No employee found for given ID.', 30;

    DECLARE @v_PositionID INT;
    SELECT @v_PositionID = PositionID
    FROM Positions
    WHERE name = @p_PositionName;

    UPDATE Employees

    SET PositionID=@v_PositionID,
        Phone     = @p_Phone

    WHERE EmployeeID = @p_EmployeeID
END;

GO

CREATE PROCEDURE AddUser @p_CityID INT,
                         @p_FirstName NVARCHAR(30),
                         @p_LastName NVARCHAR(30),
                         @p_Email NVARCHAR(64),
                         @p_Password NVARCHAR(64),
                         @p_Phone NVARCHAR(15),
                         @p_Address NVARCHAR(64),
                         @p_PostalCode NVARCHAR(6)
AS
BEGIN
    INSERT INTO Users (CityID, Email, Password, FirstName, LastName, Address, PostalCode, RegisterDate, Phone)
    VALUES (@p_CityID, @p_Email, @p_Password, @p_FirstName, @p_LastName, @p_Address, @p_PostalCode, GETDATE(),
            @p_Phone);
END;

GO


CREATE PROCEDURE ModifyUser @p_UserID INT,
                            @p_Phone NVARCHAR(15)
AS
BEGIN

    IF NOT EXISTS (SELECT 1
                   FROM Users AS u
                   WHERE u.UserID = @p_UserID)
        THROW 50023, 'No user found for given ID.', 24;

    UPDATE Users
    SET Phone = @p_Phone
    WHERE UserID = @p_UserID
END;

GO


-- ORDERS

CREATE PROCEDURE AddOrder @p_UserID INT,
                          @p_OrderDate DATETIME,
                          @p_PaymentURL NVARCHAR(200)
AS
BEGIN

    IF NOT EXISTS (SELECT 1
                   FROM Users AS u
                   WHERE u.UserID = @p_UserID)
        THROW 50023, 'No user found for given ID.', 25;

    INSERT INTO Orders (UserID, OrderDate, PaymentURL)
    VALUES (@p_UserID, @p_OrderDate, @p_PaymentURL)

END;

GO

CREATE PROCEDURE ModifyOrder @p_OrderID INT,
                             @p_UserID INT,
                             @p_PaymentURL NVARCHAR(200)
AS
BEGIN

    IF NOT EXISTS (SELECT 1
                   FROM Orders AS o
                   WHERE o.OrderID = @p_OrderID)
        THROW 50024, 'No order found for given ID.', 26;

    IF NOT EXISTS (SELECT 1
                   FROM Users AS u
                   WHERE u.UserID = @p_UserID)
        THROW 50023, 'No user found for given ID.', 26;

    UPDATE Orders
    SET PaymentURL = @p_PaymentURL
    WHERE OrderID = @p_OrderID;
END;

GO

CREATE PROCEDURE AddOrderDetails @p_OrderID INT,
                                 @p_DetailType NVARCHAR(50),
                                 @p_EntityID INT,
                                 @p_Price MONEY = NULL,
                                 @p_PaymentDate DATETIME = NULL,
                                 @p_PaymentInAdvance MONEY = NULL,
                                 @p_FullPrice MONEY = NULL,
                                 @p_PaymentDateInAdvance DATETIME = NULL,
                                 @p_PaymentDateFull DATETIME = NULL
AS
BEGIN
    IF @p_DetailType = 'Webinar'
        BEGIN

            IF NOT EXISTS (SELECT 1
                           FROM Orders AS o
                           WHERE o.OrderID = @p_OrderID)
                THROW 50024, 'No order found for given ID.', 27;

            INSERT INTO WebinarOrders (OrderID, WebinarID, Price, PaymentDate)
            VALUES (@p_OrderID, @p_EntityID, @p_Price, @p_PaymentDate);
        END
    ELSE
        IF @p_DetailType = 'Course'
            BEGIN

                IF NOT EXISTS (SELECT 1
                               FROM Orders AS o
                               WHERE o.OrderID = @p_OrderID)
                    THROW 50024, 'No order found for given ID.', 27;

                INSERT INTO CourseOrders (OrderID, CourseID, PaymentInAdvance, FullPrice, PaymentDateInAdvance,
                                          PaymentDateFull)
                VALUES (@p_OrderID, @p_EntityID, @p_PaymentInAdvance, @p_FullPrice, @p_PaymentDateInAdvance,
                        @p_PaymentDateFull);
            END
        ELSE
            IF @p_DetailType = 'Study'
                BEGIN

                    IF NOT EXISTS (SELECT 1
                                   FROM Orders AS o
                                   WHERE o.OrderID = @p_OrderID)
                        THROW 50024, 'No order found for given ID.', 27;

                    INSERT INTO StudyOrders (OrderID, StudyID, Price, PaymentDate)
                    VALUES (@p_OrderID, @p_EntityID, @p_Price, @p_PaymentDate);
                END
            ELSE
                IF @p_DetailType = 'StudyMeeting'
                    BEGIN

                        IF NOT EXISTS (SELECT 1
                                       FROM Orders AS o
                                       WHERE o.OrderID = @p_OrderID)
                            THROW 50024, 'No order found for given ID.', 27;

                        INSERT INTO StudyMeetingOrders (OrderID, MeetingID, Price, PaymentDate)
                        VALUES (@p_OrderID, @p_EntityID, @p_Price, @p_PaymentDate);
                    END
                ELSE
                    THROW 50025, 'Invalid module name.', 27;
END;

GO

CREATE PROCEDURE ModifyOrderDetails @p_OrderID INT,
                                    @p_DetailType NVARCHAR(50),
                                    @p_EntityID INT,
                                    @p_Price MONEY = NULL,
                                    @p_PaymentDate DATETIME = NULL,
                                    @p_PaymentInAdvance MONEY = NULL,
                                    @p_FullPrice MONEY = NULL,
                                    @p_PaymentDateInAdvance DATETIME = NULL,
                                    @p_PaymentDateFull DATETIME = NULL
AS
BEGIN
    IF @p_DetailType = 'Webinar'
        BEGIN

            IF NOT EXISTS (SELECT 1
                           FROM WebinarOrders AS wo
                           WHERE wo.OrderID = @p_OrderID
                             AND wo.WebinarID = @p_EntityID)
                THROW 50024, 'No order found for given ID.', 28;

            UPDATE WebinarOrders
            SET Price       = @p_Price,
                PaymentDate = @p_PaymentDate
            WHERE OrderID = @p_OrderID
              AND WebinarID = @p_EntityID;
        END
    ELSE
        IF @p_DetailType = 'Course'
            BEGIN

                IF NOT EXISTS (SELECT 1
                               FROM CourseOrders AS co
                               WHERE co.OrderID = @p_OrderID
                                 AND co.CourseID = @p_EntityID)
                    THROW 50024, 'No order found for given ID.', 28;

                UPDATE CourseOrders
                SET PaymentInAdvance     =@p_PaymentInAdvance,
                    FullPrice            = @p_FullPrice,
                    PaymentDateInAdvance = @p_PaymentDateInAdvance,
                    PaymentDateFull      = @p_PaymentDateFull
                WHERE OrderID = @p_OrderID
                  AND CourseID = @p_EntityID

            END
        ELSE
            IF @p_DetailType = 'Study'
                BEGIN

                    IF NOT EXISTS (SELECT 1
                                   FROM StudyOrders AS so
                                   WHERE so.OrderID = @p_OrderID
                                     AND so.StudyID = @p_EntityID)
                        THROW 50024, 'No order found for given ID.', 28;

                    UPDATE StudyOrders
                    SET Price       = @p_Price,
                        PaymentDate = @p_PaymentDate
                    WHERE OrderID = @p_OrderID
                      AND StudyID = @p_EntityID;

                END
            ELSE
                IF @p_DetailType = 'StudyMeeting'
                    BEGIN

                        IF NOT EXISTS (SELECT 1
                                       FROM StudyMeetingOrders AS smo
                                       WHERE smo.OrderID = @p_OrderID
                                         AND smo.MeetingID = @p_EntityID)
                            THROW 50024, 'No order found for given ID.', 28;

                        UPDATE StudyMeetingOrders
                        SET Price       = @p_Price,
                            PaymentDate = @p_PaymentDate
                        WHERE OrderID = @p_OrderID
                          AND MeetingID = @p_EntityID;

                    END
                ELSE
                    THROW 50025, 'Invalid module name.', 28;
END;

GO

CREATE PROCEDURE RegisterForOneStudyMeeting @OrderID INT,
                                            @MeetingID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM StudyMeetingOrders WHERE MeetingID = @MeetingID AND OrderID = @OrderID)
        BEGIN
            INSERT INTO StudyMeetingOrders (OrderID, MeetingID, Price, PaymentDate)
            VALUES (@OrderID, @MeetingID, (SELECT Price * 1.2 FROM StudyMeetings WHERE MeetingID = @MeetingID), NULL);
        END
END;
