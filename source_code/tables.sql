-- PEOPLE

-- Table: Users
CREATE TABLE Users
(
    UserID       int          NOT NULL IDENTITY,
    FirstName    nvarchar(30) NOT NULL,
    LastName     nvarchar(30) NOT NULL,
    Address      nvarchar(30) NOT NULL,
    PostalCode   nvarchar(6)  NOT NULL,
    City         nvarchar(50) NOT NULL,
    Country      nvarchar(20) NOT NULL,
    RegisterDate datetime     NOT NULL,
    Email        nvarchar(50) NOT NULL,
    Phone        nvarchar(15) NULL,
    CONSTRAINT Users_pk PRIMARY KEY (UserID)
);

-- Table: Employees
CREATE TABLE Employees
(
    EmployeeID int          NOT NULL IDENTITY,
    PositionID int          NOT NULL,
    FirstName  nvarchar(30) NOT NULL,
    LastName   nvarchar(30) NOT NULL,
    HireDate   datetime     NOT NULL,
    Email      nvarchar(50) NOT NULL,
    Phone      nvarchar(15) NOT NULL,
    CONSTRAINT Employees_pk PRIMARY KEY (EmployeeID)
);

-- Table: Positions
CREATE TABLE Positions
(
    PositionID int          NOT NULL IDENTITY,
    Name       nvarchar(20) NOT NULL,
    CONSTRAINT Positions_pk PRIMARY KEY (PositionID)
);

-- Table: Languages
CREATE TABLE Languages
(
    LanguageID   int          NOT NULL IDENTITY,
    LanguageName nvarchar(15) NOT NULL,
    CONSTRAINT Languages_pk PRIMARY KEY (LanguageID)
);

-- Table: TranslatorLanguages
CREATE TABLE TranslatorLanguages
(
    TranslatorID int NOT NULL,
    LanguageID   int NOT NULL,
    CONSTRAINT TranslatorLanguages_pk PRIMARY KEY (TranslatorID, LanguageID)
);



-- WEBINARS

-- Table: Webinars
CREATE TABLE Webinars
(
    WebinarID    int           NOT NULL IDENTITY,
    TeacherID    int           NOT NULL,
    LanguageID   int           NULL,
    TranslatorID int           NULL,
    Title        nvarchar(100) NOT NULL,
    Description  nvarchar(max) NULL,
    Date         datetime      NOT NULL,
    Duration     time          NOT NULL,
    MeetingLink  nvarchar(100) NOT NULL,
    VideoLink    nvarchar(100) NOT NULL,
    Price        money         NULL,
    CONSTRAINT Webinars_pk PRIMARY KEY (WebinarID)
);



-- COURSES

-- Table: Courses
CREATE TABLE Courses
(
    CourseID      int           NOT NULL IDENTITY,
    CoordinatorID int           NOT NULL,
    Title         nvarchar(100) NOT NULL,
    Description   nvarchar(max) NULL,
    Price         money         NOT NULL,
    CONSTRAINT Courses_pk PRIMARY KEY (CourseID)
);

-- Table: CourseModules
CREATE TABLE CourseModules
(
    ModuleID    int           NOT NULL IDENTITY,
    CourseID    int           NOT NULL,
    Title       nvarchar(100) NOT NULL,
    Description nvarchar(max) NULL,
    ModuleType  nvarchar(12)  NOT NULL,
    CONSTRAINT CourseModules_pk PRIMARY KEY (ModuleID)
);

-- Table: CourseMeetings
CREATE TABLE CourseMeetings
(
    MeetingID    int           NOT NULL IDENTITY,
    ModuleID     int           NOT NULL,
    TeacherID    int           NOT NULL,
    LanguageID   int           NULL,
    TranslatorID int           NULL,
    Title        nvarchar(100) NOT NULL,
    Description  nvarchar(max) NOT NULL,
    Date         datetime      NOT NULL,
    Duration     time          NOT NULL,
    CONSTRAINT CourseMeetings_pk PRIMARY KEY (MeetingID)
);

-- Table: CourseMeetingAttendance
CREATE TABLE CourseMeetingAttendance
(
    MeetingID int NOT NULL,
    UserID    int NOT NULL,
    Attended  bit NOT NULL DEFAULT 0,
    CONSTRAINT CourseMeetingAttendance_pk PRIMARY KEY (UserID, MeetingID)
);

-- Table: OnlineAsynchronousCourseMeetings
CREATE TABLE OnlineAsynchronousCourseMeetings
(
    MeetingID int           NOT NULL,
    VideoLink nvarchar(100) NOT NULL,
    CONSTRAINT OnlineAsynchronousCourseMeetings_pk PRIMARY KEY (MeetingID)
);

-- Table: OnlineSynchronousCourseMeetings
CREATE TABLE OnlineSynchronousCourseMeetings
(
    MeetingID   int           NOT NULL,
    MeetingLink nvarchar(100) NOT NULL,
    VideoLink   nvarchar(100) NOT NULL,
    CONSTRAINT OnlineSynchronousCourseMeetings_pk PRIMARY KEY (MeetingID)
);

-- Table: StationaryCourseMeetings
CREATE TABLE StationaryCourseMeetings
(
    MeetingID     int NOT NULL,
    ReservationID int NOT NULL,
    Limit         int NOT NULL,
    CONSTRAINT StationaryCourseMeetings_pk PRIMARY KEY (MeetingID)
);



-- STUDIES

-- Table: Studies
CREATE TABLE Studies
(
    StudyID       int           NOT NULL IDENTITY,
    CoordinatorID int           NOT NULL,
    Title         nvarchar(100) NOT NULL,
    Description   nvarchar(max) NULL,
    TuitionFee    money         NOT NULL,
    CONSTRAINT Studies_pk PRIMARY KEY (StudyID)
);

-- Table: StudentLists
CREATE TABLE StudentLists
(
    StudyID int NOT NULL,
    UserID  int NOT NULL,
    CONSTRAINT StudentLists_pk PRIMARY KEY (StudyID, UserID)
);

-- Table: StudyGrades
CREATE TABLE StudyGrades
(
    StudyID int  NOT NULL,
    UserID  int  NOT NULL,
    Grade   real NOT NULL,
    CONSTRAINT StudyGrades_pk PRIMARY KEY (StudyID, UserID)
);

-- Table: Subjects
CREATE TABLE Subjects
(
    SubjectID     int           NOT NULL IDENTITY,
    CoordinatorID int           NOT NULL,
    Title         nvarchar(100) NOT NULL,
    Description   nvarchar(max) NULL,
    CONSTRAINT Subjects_pk PRIMARY KEY (SubjectID)
);

-- Table: SubjectDetails
CREATE TABLE SubjectDetails
(
    StudyID    int NOT NULL,
    SubjectID  int NOT NULL,
    SemesterNo int NOT NULL,
    CONSTRAINT SubjectDetails_pk PRIMARY KEY (StudyID, SubjectID)
);

-- Table: SubjectGrades
CREATE TABLE SubjectGrades
(
    StudyID   int  NOT NULL,
    UserID    int  NOT NULL,
    SubjectID int  NOT NULL,
    Grade     real NOT NULL,
    CONSTRAINT SubjectGrades_pk PRIMARY KEY (SubjectID, UserID, StudyID)
);

-- Table: Internships
CREATE TABLE Internships
(
    InternshipID int      NOT NULL IDENTITY,
    StudyID      int      NOT NULL,
    TeacherID    int      NOT NULL,
    StartDate    datetime NOT NULL,
    EndDate      datetime NOT NULL,
    CONSTRAINT Internships_pk PRIMARY KEY (InternshipID)
);

-- Table: InternshipAttendance
CREATE TABLE InternshipAttendance
(
    InternshipID int NOT NULL,
    UserID       int NOT NULL,
    StudyID      int NOT NULL,
    Attended     bit NOT NULL,
    CONSTRAINT InternshipAttendance_pk PRIMARY KEY (InternshipID, UserID)
);



-- MEETINGS

-- Table: Classes
CREATE TABLE Classes
(
    ClassID      int           NOT NULL IDENTITY,
    StudyID      int           NOT NULL,
    SubjectID    int           NOT NULL,
    MeetingID    int           NULL,
    TeacherID    int           NOT NULL,
    LanguageID   int           NULL,
    TranslatorID int           NULL,
    Title        nvarchar(100) NOT NULL,
    Description  nvarchar(max) NULL,
    Date         datetime      NOT NULL,
    Duration     time          NOT NULL,
    Price        money         NOT NULL,
    CONSTRAINT Classes_pk PRIMARY KEY (ClassID)
);

-- Table: ClassAttendance
CREATE TABLE ClassAttendance
(
    ClassID  int NOT NULL,
    UserID   int NOT NULL,
    Attended bit NOT NULL,
    CONSTRAINT MeetingDetails_pk PRIMARY KEY (ClassID, UserID)
);

-- Table: StudyMeetings
CREATE TABLE StudyMeetings
(
    MeetingID int      NOT NULL IDENTITY,
    BeginDate datetime NOT NULL,
    EndDate   datetime NOT NULL,
    Price     money    NOT NULL,
    Limit     int      NOT NULL,
    CONSTRAINT StudyMeetings_pk PRIMARY KEY (MeetingID)
);

-- Table: StationaryClasses
CREATE TABLE StationaryClasses
(
    ClassID       int NOT NULL,
    MeetingID     int NOT NULL,
    ReservationID int NOT NULL,
    CONSTRAINT StationaryClasses_pk PRIMARY KEY (ClassID)
);

-- Table: OnlineAsynchronousClasses
CREATE TABLE OnlineAsynchronousClasses
(
    ClassID   int           NOT NULL,
    VideoLink nvarchar(100) NOT NULL,
    CONSTRAINT OnlineAsynchronousClasses_pk PRIMARY KEY (ClassID)
);

-- Table: OnlineSynchronousClasses
CREATE TABLE OnlineSynchronousClasses
(
    ClassID     int           NOT NULL,
    MeetingLink nvarchar(100) NOT NULL,
    VideoLink   nvarchar(100) NOT NULL,
    CONSTRAINT OnlineSynchronousClasses_pk PRIMARY KEY (ClassID)
);



-- ROOMS

-- Table: Rooms
CREATE TABLE Rooms
(
    RoomID     int           NOT NULL IDENTITY,
    RoomNumber int           NOT NULL,
    Location   nvarchar(max) NOT NULL,
    Limit      int           NOT NULL,
    CONSTRAINT Rooms_pk PRIMARY KEY (RoomID)
);

-- Table: Reservations
CREATE TABLE Reservations
(
    ReservationID int      NOT NULL IDENTITY,
    RoomID        int      NOT NULL,
    StartTime     datetime NOT NULL,
    EndTime       datetime NOT NULL,
    CONSTRAINT Reservations_pk PRIMARY KEY (ReservationID)
);



-- ORDERS

-- Table: Orders
CREATE TABLE Orders
(
    OrderID    int           NOT NULL IDENTITY,
    UserID     int           NOT NULL,
    OrderDate  datetime      NOT NULL,
    PaymentURL nvarchar(max) NOT NULL,
    CONSTRAINT Orders_pk PRIMARY KEY (OrderID)
);

-- Table: WebinarOrders
CREATE TABLE WebinarOrders
(
    WebinarID   int      NOT NULL,
    OrderID     int      NOT NULL,
    Price       money    NOT NULL,
    PaymentDate datetime NULL,
    CONSTRAINT WebinarOrders_pk PRIMARY KEY (WebinarID)
);

-- Table: CourseOrders
CREATE TABLE CourseOrders
(
    OrderID              int      NOT NULL,
    CourseID             int      NOT NULL,
    PaymentInAdvance     money    NOT NULL,
    FullPrice            money    NOT NULL,
    PaymentDateInAdvance datetime NULL,
    PaymentDateFull      datetime NULL,
    CONSTRAINT CourseOrders_pk PRIMARY KEY (OrderID, CourseID)
);

-- Table: StudyOrders
CREATE TABLE StudyOrders
(
    OrderID     int      NOT NULL,
    StudyID     int      NOT NULL,
    Price       money    NOT NULL,
    PaymentDate datetime NULL,
    CONSTRAINT StudyOrders_pk PRIMARY KEY (OrderID, StudyID)
);

-- Table: StudyMeetingOrders
CREATE TABLE StudyMeetingOrders
(
    OrderID     int      NOT NULL,
    MeetingID   int      NOT NULL,
    Price       money    NOT NULL,
    PaymentDate datetime NULL,
    CONSTRAINT StudyMeetingOrders_pk PRIMARY KEY (OrderID, MeetingID)
);
