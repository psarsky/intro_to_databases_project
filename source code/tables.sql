-- PEOPLE

-- Users
CREATE TABLE dbo.Users
(
    UserID       int IDENTITY
        CONSTRAINT Users_pk
            PRIMARY KEY,
    FirstName    nvarchar(30) NOT NULL,
    LastName     nvarchar(30) NOT NULL,
    Address      nvarchar(30) NOT NULL,
    PostalCode   nvarchar(6)  NOT NULL,
    City         nvarchar(50) NOT NULL,
    Country      nvarchar(20) NOT NULL,
    RegisterDate datetime     NOT NULL
        CONSTRAINT registerdate_check
            CHECK ([RegisterDate] <= GETDATE()),
    Email        nvarchar(50) NOT NULL
        CONSTRAINT email_check_users
            CHECK ([Email] LIKE '%_@%_.%__'),
    Phone        nvarchar(15)
)
go

-- Employees
CREATE TABLE dbo.Employees
(
    EmployeeID int IDENTITY
        CONSTRAINT Employees_pk
            PRIMARY KEY,
    PositionID int          NOT NULL
        CONSTRAINT Employees_Positions_PositionID_fk
            REFERENCES dbo.Positions,
    FirstName  nvarchar(30) NOT NULL,
    LastName   nvarchar(30) NOT NULL,
    HireDate   datetime     NOT NULL
        CONSTRAINT hiredate_check
            CHECK ([HireDate] <= GETDATE()),
    Email      nvarchar(50) NOT NULL
        CONSTRAINT email_check
            CHECK ([Email] LIKE '%_@%_.%__'),
    Phone      nvarchar(15) NOT NULL
)
go

-- Positions
CREATE TABLE dbo.Positions
(
    PositionID int IDENTITY
        CONSTRAINT Positions_pk
            PRIMARY KEY,
    Name       nvarchar(20) NOT NULL
)
go

-- TranslatorLanguages
CREATE TABLE dbo.TranslatorLanguages
(
    TranslatorID int NOT NULL
        CONSTRAINT TranslatorLanguages_Employees_EmployeeID_fk
            REFERENCES dbo.Employees,
    LanguageID   int NOT NULL
        CONSTRAINT TranslatorLanguages_Languages_LanguageID_fk
            REFERENCES dbo.Languages,
    CONSTRAINT TranslatorLanguages_pk
        PRIMARY KEY (TranslatorID, LanguageID)
)
go

-- Languages
CREATE TABLE dbo.Languages
(
    LanguageID   int IDENTITY
        CONSTRAINT Languages_pk
            PRIMARY KEY,
    LanguageName nvarchar(15) NOT NULL
)
go

-- WEBINARS

-- Webinars
CREATE TABLE dbo.Webinars
(
    WebinarID      int IDENTITY
        CONSTRAINT Webinars_pk
            PRIMARY KEY,
    TeacherID      int           NOT NULL
        CONSTRAINT Webinar_Employees_Teacher_fk
            REFERENCES dbo.Employees,
    LanguageID     int           NOT NULL
        CONSTRAINT Webinars_Languages_LanguageID_fk
            REFERENCES dbo.Languages,
    TranslatorID   int
        CONSTRAINT Webinar_Employees_Translator_fk
            REFERENCES dbo.Employees,
    Title          nvarchar(100) NOT NULL,
    Description    nvarchar(max),
    Duration       time          NOT NULL,
    Date           datetime      NOT NULL,
    AvailableUntil datetime      NOT NULL,
    MeetingLink    nvarchar(100) NOT NULL,
    VideoLink      nvarchar(100) NOT NULL,
    Price          money
        CONSTRAINT price_check_webinars
            CHECK ([Price] >= 0 OR [Price] IS NULL)
)
go

-- WebinarAccess
CREATE TABLE dbo.WebinarAccess
(
    WebinarID int NOT NULL
        CONSTRAINT WebinarAccess_Webinar_WebinarID_fk
            REFERENCES dbo.Webinars,
    UserID    int NOT NULL
        CONSTRAINT WebinarAccess_Users_UserID_fk
            REFERENCES dbo.Users,
    CONSTRAINT WebinarAccess_pk
        PRIMARY KEY (WebinarID, UserID)
)
go

-- COURSES

-- Courses
CREATE TABLE dbo.Courses
(
    CourseID      int IDENTITY
        CONSTRAINT Courses_pk
            PRIMARY KEY,
    CoordinatorID int           NOT NULL
        CONSTRAINT Courses_Employees_EmployeeID_fk
            REFERENCES dbo.Employees,
    Title         nvarchar(100) NOT NULL,
    Description   nvarchar(max),
    Price         money         NOT NULL
        CONSTRAINT price_check
            CHECK ([Price] >= 0)
)
go

-- CourseAccess
CREATE TABLE dbo.CourseAccess
(
    CourseID int NOT NULL
        CONSTRAINT CourseAccess_Course_CourseID_fk
            REFERENCES dbo.Courses,
    UserID   int NOT NULL
        CONSTRAINT CourseAccess_Users_UserID_fk
            REFERENCES dbo.Users,
    CONSTRAINT CourseAccess_pk
        PRIMARY KEY (UserID, CourseID)
)
go

-- CourseModules
CREATE TABLE dbo.CourseModules
(
    ModuleID     int IDENTITY
        CONSTRAINT CourseModules_pk
            PRIMARY KEY,
    CourseID     int           NOT NULL
        CONSTRAINT CourseModules_Course_CourseID_fk
            REFERENCES dbo.Courses,
    TeacherID    int           NOT NULL
        CONSTRAINT CourseModule_Employees_Teacher_fk
            REFERENCES dbo.Employees,
    LanguageID   int           NOT NULL
        CONSTRAINT CourseModules_Languages_LanguageID_fk
            REFERENCES dbo.Languages,
    TranslatorID int
        CONSTRAINT CourseModule_Employees_Translator_fk
            REFERENCES dbo.Employees,
    Title        nvarchar(100) NOT NULL,
    Description  nvarchar(max),
    Date         datetime      NOT NULL,
    Duration     time          NOT NULL
)
go

-- CourseModuleAttendance
CREATE TABLE dbo.CourseModuleAttendance
(
    ModuleID int           NOT NULL
        CONSTRAINT CourseModuleAttendance_CourseModules_ModuleID_fk
            REFERENCES dbo.CourseModules,
    UserID   int           NOT NULL
        CONSTRAINT CourseModuleAttendance_Users_UserID_fk
            REFERENCES dbo.Users,
    Attended bit DEFAULT 0 NOT NULL,
    CONSTRAINT CourseModuleAttendance_pk
        PRIMARY KEY (ModuleID, UserID)
)
go

-- StationaryModules
CREATE TABLE dbo.StationaryModules
(
    ModuleID int           NOT NULL
        CONSTRAINT StationaryCourseModules_pk
            PRIMARY KEY
        CONSTRAINT StationaryCourseModules_CourseModule_ModuleID_fk
            REFERENCES dbo.CourseModules,
    Location nvarchar(100) NOT NULL,
    Limit    int           NOT NULL
)
go

-- OnlineSynchronousModules
CREATE TABLE dbo.OnlineSynchronousModules
(
    ModuleID    int           NOT NULL
        CONSTRAINT OnlineSynchronousModule_pk
            PRIMARY KEY
        CONSTRAINT OnlineSynchronousModule_CourseModules_ModuleID_fk
            REFERENCES dbo.CourseModules,
    MeetingLink nvarchar(100) NOT NULL,
    VideoLink   nvarchar(100) NOT NULL
)
go

-- OnlineAsynchronousModules
CREATE TABLE dbo.OnlineAsynchronousModules
(
    ModuleID  int           NOT NULL
        CONSTRAINT OnlineAsynchronousModule_pk
            PRIMARY KEY
        CONSTRAINT OnlineAsynchronousModule_CourseModules_ModuleID_fk
            REFERENCES dbo.CourseModules,
    VideoLink nvarchar(100) NOT NULL
)
go

-- STUDIES

-- Studies
CREATE TABLE dbo.Studies
(
    StudyID       int IDENTITY
        CONSTRAINT Studies_pk
            PRIMARY KEY,
    CoordinatorID int           NOT NULL
        CONSTRAINT Studies_Employees_EmployeeID_fk
            REFERENCES dbo.Employees,
    Title         nvarchar(100) NOT NULL,
    Description   nvarchar(max),
    TuitionFee    money         NOT NULL
        CONSTRAINT tuitionfee_check
            CHECK ([TuitionFee] >= 0)
)
go

-- StudiesDetails
CREATE TABLE dbo.StudiesDetails
(
    StudyID int NOT NULL
        CONSTRAINT StudiesDetails_Studies_StudyID_fk
            REFERENCES dbo.Studies,
    UserID  int NOT NULL
        CONSTRAINT StudiesDetails_Users_UserID_fk
            REFERENCES dbo.Users,
    Grade   real
        CONSTRAINT grade_check
            CHECK ([Grade] >= 2.0 AND [Grade] <= 5.0),
    CONSTRAINT StudiesDetails_pk
        PRIMARY KEY (StudyID, UserID)
)
go

-- Subjects
CREATE TABLE dbo.Subjects
(
    SubjectID     int IDENTITY
        CONSTRAINT Subjects_pk
            PRIMARY KEY,
    StudyID       int           NOT NULL
        CONSTRAINT Subjects_Studies_StudyID_fk
            REFERENCES dbo.Studies,
    CoordinatorID int           NOT NULL
        CONSTRAINT Subjects_Employees_EmployeeID_fk
            REFERENCES dbo.Employees,
    Title         nvarchar(100) NOT NULL,
    Description   nvarchar(max)
)
go

-- SubjectsDetails
CREATE TABLE dbo.SubjectsDetails
(
    SubjectID int NOT NULL
        CONSTRAINT SubjectsDetails_Subjects_SubjectID_fk
            REFERENCES dbo.Subjects,
    UserID    int NOT NULL
        CONSTRAINT SubjectsDetails_Users_UserID_fk
            REFERENCES dbo.Users,
    Grade     real
        CONSTRAINT grade_check_subject
            CHECK ([Grade] = 5.0 OR [Grade] = 4.5 OR [Grade] = 4.0 OR [Grade] = 3.5 OR [Grade] = 3.0 OR [Grade] = 2.0),
    CONSTRAINT SubjectsDetails_pk
        PRIMARY KEY (SubjectID, UserID)
)
go

-- Internships
CREATE TABLE dbo.Internships
(
    InternshipID int IDENTITY
        CONSTRAINT Internships_pk
            PRIMARY KEY,
    StudyID      int      NOT NULL
        CONSTRAINT Internships_Studies_StudyID_fk
            REFERENCES dbo.Studies,
    TeacherID    int      NOT NULL
        CONSTRAINT Internships_Employees_EmployeeID_fk
            REFERENCES dbo.Employees,
    StartDate    datetime NOT NULL,
    EndDate      datetime NOT NULL
)
go

-- InternshipsDetails
CREATE TABLE dbo.InternshipsDetails
(
    InternshipID int NOT NULL
        CONSTRAINT InternshipDetails_Internships_InternshipID_fk
            REFERENCES dbo.Internships,
    UserID       int NOT NULL
        CONSTRAINT InternshipDetails_Users_UserID_fk
            REFERENCES dbo.Users,
    Attended     bit NOT NULL,
    CONSTRAINT InternshipDetails_pk
        PRIMARY KEY (InternshipID, UserID)
)
go

-- Meetings
CREATE TABLE dbo.Meetings
(
    MeetingID    int IDENTITY
        CONSTRAINT Meetings_pk
            PRIMARY KEY,
    SubjectID    int           NOT NULL
        CONSTRAINT Meetings_Subjects_SubjectID_fk
            REFERENCES dbo.Subjects,
    TeacherID    int           NOT NULL
        CONSTRAINT Meetings_Employees_EmployeeID_fk
            REFERENCES dbo.Employees,
    LanguageID   int           NOT NULL
        CONSTRAINT Meetings_Languages_LanguageID_fk
            REFERENCES dbo.Languages,
    TranslatorID int           NOT NULL
        CONSTRAINT Meetings_Employees_EmployeeID_fk_2
            REFERENCES dbo.Employees,
    Title        nvarchar(100) NOT NULL,
    Description  nvarchar(max),
    Date         datetime      NOT NULL,
    Duration     time          NOT NULL,
    Price        money         NOT NULL
        CONSTRAINT price_check_meeting
            CHECK ([Price] >= 0)
)
go

-- MeetingsDetails
CREATE TABLE dbo.MeetingsDetails
(
    MeetingID int NOT NULL
        CONSTRAINT MeetingDetails_Meetings_MeetingID_fk
            REFERENCES dbo.Meetings,
    UserID    int NOT NULL
        CONSTRAINT MeetingDetails_Users_UserID_fk
            REFERENCES dbo.Users,
    Attended  bit NOT NULL,
    CONSTRAINT MeetingDetails_pk
        PRIMARY KEY (MeetingID, UserID)
)
go

-- StationaryMeetings
CREATE TABLE dbo.StationaryMeetings
(
    MeetingID int           NOT NULL
        CONSTRAINT StationaryMeeting_pk
            PRIMARY KEY
        CONSTRAINT StationaryMeeting_Meetings_MeetingID_fk
            REFERENCES dbo.Meetings,
    Location  nvarchar(100) NOT NULL,
    Limit     int           NOT NULL
)
go

-- OnlineSynchronousMeetings
CREATE TABLE dbo.OnlineSynchronousMeetings
(
    MeetingID   int           NOT NULL
        CONSTRAINT OnlineSynchronousMeeting_pk
            PRIMARY KEY
        CONSTRAINT OnlineSynchronousMeeting_Meetings_MeetingID_fk
            REFERENCES dbo.Meetings,
    MeetingLink nvarchar(100) NOT NULL,
    VideoLink   nvarchar(100) NOT NULL
)
go

-- OnlineAsynchronousMeetings
CREATE TABLE dbo.OnlineAsynchronousMeetings
(
    MeetingID int           NOT NULL
        CONSTRAINT OnlineAsynchronousMeeting_pk
            PRIMARY KEY
        CONSTRAINT OnlineAsynchronousMeeting_Meetings_MeetingID_fk
            REFERENCES dbo.Meetings,
    VideoLink nvarchar(100) NOT NULL
)
go

-- ORDERS

-- Orders
CREATE TABLE dbo.Orders
(
    OrderID     int IDENTITY
        CONSTRAINT Orders_pk
            PRIMARY KEY,
    UserID      int      NOT NULL
        CONSTRAINT Orders_Users_UserID_fk
            REFERENCES dbo.Users,
    OrderDate   datetime NOT NULL,
    PaymentDate datetime NOT NULL,
    CONSTRAINT paymentdate_check
        CHECK ([PaymentDate] >= [OrderDate])
)
go

-- WebinarOrders
CREATE TABLE dbo.WebinarOrders
(
    OrderID   int   NOT NULL
        CONSTRAINT WebinarOrders_Orders_OrderID_fk
            REFERENCES dbo.Orders,
    WebinarID int   NOT NULL
        CONSTRAINT WebinarOrders_Webinars_WebinarID_fk
            REFERENCES dbo.Webinars,
    Price     money NOT NULL
        CONSTRAINT price_check_webinarorders
            CHECK ([Price] >= 0),
    CONSTRAINT WebinarOrders_pk
        PRIMARY KEY (OrderID, WebinarID)
)
go

-- CourseOrders
CREATE TABLE dbo.CourseOrders
(
    OrderID  int   NOT NULL
        CONSTRAINT CourseOrders_Orders_OrderID_fk
            REFERENCES dbo.Orders,
    CourseID int   NOT NULL
        CONSTRAINT CourseOrders_Courses_CourseID_fk
            REFERENCES dbo.Courses,
    Price    money NOT NULL
        CONSTRAINT price_check_courseorders
            CHECK ([Price] >= 0),
    CONSTRAINT CourseOrders_pk
        PRIMARY KEY (OrderID, CourseID)
)
go

-- StudyOrders
CREATE TABLE dbo.StudyOrders
(
    OrderID int   NOT NULL
        CONSTRAINT StudyOrders_Orders_OrderID_fk
            REFERENCES dbo.Orders,
    StudyID int   NOT NULL
        CONSTRAINT StudyOrders_Studies_StudyID_fk
            REFERENCES dbo.Studies,
    Price   money NOT NULL
        CONSTRAINT price_check_studyorders
            CHECK ([Price] >= 0),
    CONSTRAINT StudyOrders_pk
        PRIMARY KEY (OrderID, StudyID)
)
go

-- StudyMeetingOrders
CREATE TABLE dbo.StudyMeetingOrders
(
    OrderID   int   NOT NULL
        CONSTRAINT StudyMeetingOrders_Orders_OrderID_fk
            REFERENCES dbo.Orders,
    MeetingID int   NOT NULL
        CONSTRAINT StudyMeetingOrders_Meetings_MeetingID_fk
            REFERENCES dbo.Meetings,
    Price     money NOT NULL
        CONSTRAINT price_check_studymeetingorders
            CHECK ([Price] >= 0),
    CONSTRAINT StudyMeetingOrders_pk
        PRIMARY KEY (OrderID, MeetingID)
)
go
