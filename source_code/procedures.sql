--STUDIES

GO

CREATE PROCEDURE AddStudy @CoordinatorID int,
                          @Title nvarchar(100),
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
    INSERT INTO Studies(CoordinatorID, Title, Description, TuitionFee)
    VALUES (@CoordinatorID, @Title, @Description, @TuitionFee)
END

GO

CREATE PROCEDURE AddSubject @CoordinatorID int,
                            @Title nvarchar(100),
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

    INSERT INTO Subjects(CoordinatorID, Title, Description)
    VALUES (@CoordinatorID, @Title, @Description)
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
                 AND s.Title = (SELECT s1.Title
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
                                     @Title nvarchar(100),
                                     @Description nvarchar(max),
                                     @StudyID int,
                                     @SemesterNo int
AS
BEGIN
    DECLARE @SubjectID int
    EXEC AddSubject @CoordinatorID, @Title, @Description
    SET @SubjectID = (SELECT TOP 1 s.SubjectID
                      FROM Subjects s
                      ORDER BY s.SubjectID DESC)
    EXEC AssignSubjectToStudies @StudyID, @SubjectID, @SemesterNo
END

GO

CREATE PROCEDURE AddInternship @StudyID int,
                               @TeacherID int,
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

    INSERT INTO Internships(StudyID, TeacherID, StartDate)
    VALUES (@StudyID, @TeacherID, @StartDate)
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
                                 @Title nvarchar(100),
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

    INSERT INTO StudyMeetings(StudyID, Title, BeginDate, EndDate, Price, Limit)
    VALUES (@StudyID, @Title, @BeginDate, @EndDate, @Price, @Limit)
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
                          @Title nvarchar(100),
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

    INSERT INTO Classes(StudyID, SubjectID, MeetingID, TeacherID, LanguageID, TranslatorID, Title, Description, Date,
                        Duration)
    VALUES (@StudyID, @SubjectID, @MeetingID, @TeacherID, @LanguageID, @TranslatorID, @Title, @Description, @Date,
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
                                   @Title nvarchar(100),
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
         @Title,
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
                            @Title nvarchar(100),
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


    INSERT INTO Webinars (TeacherID, LanguageID, TranslatorID, Title, Description, Date, Duration, MeetingLink,
                          VideoLink, Price)
    VALUES (@TeacherID, @LanguageID, @TranslatorID, @Title, @Description, @Date, @Duration, @MeetingLink, @VideoLink,
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
                           @Title varchar(100),
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

    INSERT INTO Courses (CoordinatorID, Title, Description, Price, BeginDate, EndDate)
    VALUES (@CoordinatorID, @Title, @Description, @Price, @BeginDate, @EndDate);
END;

GO

CREATE PROCEDURE AddCourseModule @CourseID int,
                                 @Title nvarchar(100),
                                 @Description nvarchar(max),
                                 @ModuleType nvarchar(12)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1
                   FROM Courses
                   WHERE CourseID = @CourseID)
        THROW 50020, 'No course found for given ID.', 19;

    INSERT INTO CourseModules (CourseID, Title, Description, ModuleType)
    VALUES (@CourseID, @Title, @Description, @ModuleType);
END;

GO

CREATE PROCEDURE AddCourseMeeting @ModuleID int,
                                  @TeacherID int,
                                  @LanguageID int,
                                  @TranslatorID int,
                                  @Title nvarchar(100),
                                  @Description nvarchar(100),
                                  @Date datetime,
                                  @Duration time
AS
BEGIN

    IF @Duration IS NULL
        SET @Duration = '01:30:00'

    IF dbo.CheckTranslatorLanguage(@TranslatorID, @LanguageID) = CAST(0 AS bit)
        THROW 50008, 'Invalid translator-language pair.', 20;

    INSERT INTO CourseMeetings(ModuleID, TeacherID, LanguageID, TranslatorID, Title, Description, Date, Duration)
    VALUES (@ModuleID, @TeacherID, @LanguageID, @TranslatorID, @Title, @Description, @Date, @Duration)
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


-- ORDERS

CREATE PROCEDURE AddOrder @p_UserID INT,
                          @p_OrderDate DATETIME = GETDATE(),
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
