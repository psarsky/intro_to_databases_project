-- PEOPLE

-- Table: CountriesCities
CREATE TABLE CountriesCities
(
    CCID    int          NOT NULL IDENTITY,
    City    nvarchar(50) NOT NULL,
    Country nvarchar(50) NOT NULL,
    CONSTRAINT unique_combinations UNIQUE (City, Country),
    CONSTRAINT CountriesCities_pk PRIMARY KEY (CCID)
);

-- Table: Users
CREATE TABLE Users
(
    UserID       int          NOT NULL IDENTITY,
    Email        nvarchar(64) NOT NULL CHECK (Email LIKE '_%@__%.__%'),
    Password     nvarchar(64) NOT NULL,
    FirstName    nvarchar(30) NOT NULL,
    LastName     nvarchar(30) NOT NULL,
    Address      nvarchar(64) NOT NULL,
    PostalCode   nvarchar(10) NOT NULL,
    City         nvarchar(50) NOT NULL,
    Region       nvarchar(50) NOT NULL,
    Country      nvarchar(50) NOT NULL,
    RegisterDate datetime     NOT NULL CHECK (RegisterDate >= '01-01-1900'),
    Phone        nvarchar(15) NULL,
    CONSTRAINT Users_unique_email UNIQUE (Email),
    CONSTRAINT Users_phone_check CHECK (Phone IS NULL OR ISNUMERIC(Phone) = 1 OR
                                        LEFT(Phone, 1) = '+' AND ISNUMERIC(SUBSTRING(Phone, 2, LEN(Phone))) = 1),
    CONSTRAINT Users_pk PRIMARY KEY (UserID)
);

-- Table: Employees
CREATE TABLE Employees
(
    EmployeeID int          NOT NULL IDENTITY,
    PositionID int          NOT NULL,
    Email      nvarchar(64) NOT NULL CHECK (Email LIKE '_%@__%.__%'),
    Password   nvarchar(64) NOT NULL,
    FirstName  nvarchar(30) NOT NULL,
    LastName   nvarchar(30) NOT NULL,
    HireDate   datetime     NOT NULL CHECK (HireDate >= '01-01-1900'),
    Phone      nvarchar(15) NOT NULL,
    CONSTRAINT Employees_unique_email UNIQUE (Email),
    CONSTRAINT Employees_unique_phone UNIQUE (Phone),
    CONSTRAINT Employees_phone_check CHECK (Phone IS NULL OR
                                            ISNUMERIC(Phone) = 1 OR
                                            LEFT(Phone, 1) = '+' AND
                                            ISNUMERIC(SUBSTRING(Phone, 2, LEN(Phone))) = 1),
    CONSTRAINT Employees_pk PRIMARY KEY (EmployeeID)
);

-- Table: Positions
CREATE TABLE Positions
(
    PositionID int          NOT NULL IDENTITY,
    Name       nvarchar(20) NOT NULL,
    CONSTRAINT Positions_unique_position_names UNIQUE (Name),
    CONSTRAINT Positions_pk PRIMARY KEY (PositionID)
);

-- Table: Languages
CREATE TABLE Languages
(
    LanguageID   int          NOT NULL IDENTITY,
    LanguageName nvarchar(15) NOT NULL,
    CONSTRAINT Languages_unique_language_name UNIQUE (LanguageName),
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
    Date         datetime      NOT NULL CHECK (Date >= '01-01-1900'),
    Duration     time          NOT NULL DEFAULT '01:30:00' CHECK (Duration > '00:00:00'),
    MeetingLink  nvarchar(100) NOT NULL,
    VideoLink    nvarchar(100) NOT NULL,
    Price        money         NULL CHECK (Price IS NULL OR Price >= 0),
    CONSTRAINT Webinars_unique_video_link UNIQUE (VideoLink),
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
    Price         money         NOT NULL CHECK (Price >= 0),
    BeginDate     datetime      NOT NULL CHECK (BeginDate >= '01-01-1900'),
    EndDate       datetime      NOT NULL CHECK (EndDate >= '01-01-1900'),
    CONSTRAINT course_date_check CHECK (EndDate > BeginDate),
    CONSTRAINT Courses_pk PRIMARY KEY (CourseID)
);

-- Table: CourseModules
CREATE TABLE CourseModules
(
    ModuleID    int           NOT NULL IDENTITY,
    CourseID    int           NOT NULL,
    Title       nvarchar(100) NOT NULL,
    Description nvarchar(max) NULL,
    ModuleType  nvarchar(12)  NOT NULL CHECK (ModuleType IN ('stationary', 'synchronous', 'asynchronous', 'hybrid')),
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
    Date         datetime      NOT NULL CHECK (Date >= '01-01-1900'),
    Duration     time          NOT NULL DEFAULT '01:30:00' CHECK (Duration > '00:00:00'),
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
    CONSTRAINT OnlineAsynchronousCourseMeetings_unique_video_link UNIQUE (VideoLink),
    CONSTRAINT OnlineAsynchronousCourseMeetings_pk PRIMARY KEY (MeetingID)
);

-- Table: OnlineSynchronousCourseMeetings
CREATE TABLE OnlineSynchronousCourseMeetings
(
    MeetingID   int           NOT NULL,
    MeetingLink nvarchar(100) NOT NULL,
    VideoLink   nvarchar(100) NOT NULL,
    CONSTRAINT OnlineSynchronousCourseMeetings_unique_video_link UNIQUE (VideoLink),
    CONSTRAINT OnlineSynchronousCourseMeetings_pk PRIMARY KEY (MeetingID)
);

-- Table: StationaryCourseMeetings
CREATE TABLE StationaryCourseMeetings
(
    MeetingID     int NOT NULL,
    ReservationID int NOT NULL,
    Limit         int NOT NULL DEFAULT 30 CHECK (Limit >= 0),
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
    TuitionFee    money         NOT NULL CHECK (TuitionFee >= 0),
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
    Grade   real NOT NULL CHECK (Grade BETWEEN 2.0 AND 5.0),
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
    SemesterNo int NOT NULL CHECK (SemesterNo BETWEEN 1 AND 7),
    CONSTRAINT SubjectDetails_pk PRIMARY KEY (StudyID, SubjectID)
);

-- Table: SubjectGrades
CREATE TABLE SubjectGrades
(
    StudyID   int  NOT NULL,
    UserID    int  NOT NULL,
    SubjectID int  NOT NULL,
    Grade     real NOT NULL CHECK (Grade IN (2.0, 3.0, 3.5, 4.0, 4.5, 5.0)),
    CONSTRAINT SubjectGrades_pk PRIMARY KEY (SubjectID, UserID, StudyID)
);

-- Table: Internships
CREATE TABLE Internships
(
    InternshipID int      NOT NULL IDENTITY,
    StudyID      int      NOT NULL,
    TeacherID    int      NOT NULL,
    StartDate    datetime NOT NULL CHECK (StartDate >= '01-01-1900'),
    CONSTRAINT Internships_pk PRIMARY KEY (InternshipID)
);

-- Table: InternshipAttendance
CREATE TABLE InternshipAttendance
(
    InternshipID int NOT NULL,
    UserID       int NOT NULL,
    StudyID      int NOT NULL,
    Attended     bit NOT NULL DEFAULT 0,
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
    Date         datetime      NOT NULL CHECK (Date >= '01-01-1900'),
    Duration     time          NOT NULL DEFAULT '01:30:00' CHECK (Duration > '00:00:00'),
    CONSTRAINT Classes_pk PRIMARY KEY (ClassID)
);

-- Table: ClassAttendance
CREATE TABLE ClassAttendance
(
    ClassID  int NOT NULL,
    UserID   int NOT NULL,
    Attended bit NOT NULL DEFAULT 0,
    CONSTRAINT MeetingDetails_pk PRIMARY KEY (ClassID, UserID)
);

-- Table: StudyMeetings
CREATE TABLE StudyMeetings
(
    MeetingID int           NOT NULL IDENTITY,
    StudyID   int           NOT NULL,
    Title     nvarchar(100) NOT NULL,
    BeginDate datetime      NOT NULL CHECK (BeginDate >= '01-01-1900'),
    EndDate   datetime      NOT NULL CHECK (EndDate >= '01-01-1900'),
    Price     money         NOT NULL CHECK (Price >= 0),
    Limit     int           NOT NULL CHECK (Limit >= 0),
    CONSTRAINT meeting_date_check CHECK (EndDate > BeginDate),
    CONSTRAINT StudyMeetings_pk PRIMARY KEY (MeetingID)
);

-- Table: StationaryClasses
CREATE TABLE StationaryClasses
(
    ClassID       int NOT NULL,
    ReservationID int NOT NULL,
    CONSTRAINT StationaryClasses_pk PRIMARY KEY (ClassID)
);

-- Table: OnlineAsynchronousClasses
CREATE TABLE OnlineAsynchronousClasses
(
    ClassID   int           NOT NULL,
    VideoLink nvarchar(100) NOT NULL,
    CONSTRAINT OnlineAsynchronousClasses_unique_video_link UNIQUE (VideoLink),
    CONSTRAINT OnlineAsynchronousClasses_pk PRIMARY KEY (ClassID)
);

-- Table: OnlineSynchronousClasses
CREATE TABLE OnlineSynchronousClasses
(
    ClassID     int           NOT NULL,
    MeetingLink nvarchar(100) NOT NULL,
    VideoLink   nvarchar(100) NOT NULL,
    CONSTRAINT OnlineSynchronousClasses_unique_video_link UNIQUE (VideoLink),
    CONSTRAINT OnlineSynchronousClasses_pk PRIMARY KEY (ClassID)
);



-- ROOMS

-- Table: Rooms
CREATE TABLE Rooms
(
    RoomID     int           NOT NULL IDENTITY,
    RoomNumber int           NOT NULL,
    Location   nvarchar(max) NOT NULL,
    Limit      int           NOT NULL DEFAULT 30 CHECK (Limit >= 0),
    CONSTRAINT unique_room_number UNIQUE (RoomNumber),
    CONSTRAINT Rooms_pk PRIMARY KEY (RoomID)
);

-- Table: Reservations
CREATE TABLE Reservations
(
    ReservationID int      NOT NULL IDENTITY,
    RoomID        int      NOT NULL,
    StartTime     datetime NOT NULL CHECK (StartTime >= '01-01-1900'),
    EndTime       datetime NOT NULL CHECK (EndTime >= '01-01-1900'),
    CONSTRAINT reservation_time_check CHECK (EndTime > StartTime),
    CONSTRAINT Reservations_pk PRIMARY KEY (ReservationID)
);



-- ORDERS

-- Table: Orders
CREATE TABLE Orders
(
    OrderID    int           NOT NULL IDENTITY,
    UserID     int           NOT NULL,
    OrderDate  datetime      NOT NULL DEFAULT GETDATE() CHECK (OrderDate <= GETDATE()),
    PaymentURL nvarchar(200) NOT NULL,
    CONSTRAINT Orders_unique_payment_url UNIQUE (PaymentURL),
    CONSTRAINT Orders_pk PRIMARY KEY (OrderID)
);

-- Table: WebinarOrders
CREATE TABLE WebinarOrders
(
    OrderID     int      NOT NULL,
    WebinarID   int      NOT NULL,
    Price       money    NOT NULL CHECK (Price >= 0),
    PaymentDate datetime NULL CHECK (PaymentDate IS NULL OR
                                     (PaymentDate >= '01-01-1900' AND
                                      PaymentDate <= GETDATE())),
    CONSTRAINT WebinarOrders_pk PRIMARY KEY (WebinarID, OrderID)
);

-- Table: CourseOrders
CREATE TABLE CourseOrders
(
    OrderID              int      NOT NULL,
    CourseID             int      NOT NULL,
    PaymentInAdvance     money    NOT NULL CHECK (PaymentInAdvance >= 0),
    FullPrice            money    NOT NULL,
    PaymentDateInAdvance datetime NULL CHECK (PaymentDateInAdvance IS NULL OR
                                              (PaymentDateInAdvance >= '01-01-1900' AND
                                               PaymentDateInAdvance <= GETDATE())),
    PaymentDateFull      datetime NULL CHECK (PaymentDateFull IS NULL OR
                                              (PaymentDateFull >= '01-01-1900' AND
                                               PaymentDateFull <= GETDATE())),
    CONSTRAINT payment_date_check CHECK (PaymentDateInAdvance IS NULL OR
                                         PaymentDateFull IS NULL OR
                                         PaymentDateInAdvance < PaymentDateFull),
    CONSTRAINT full_price_check CHECK (FullPrice > PaymentInAdvance),
    CONSTRAINT CourseOrders_pk PRIMARY KEY (OrderID, CourseID)
);

-- Table: StudyOrders
CREATE TABLE StudyOrders
(
    OrderID     int      NOT NULL,
    StudyID     int      NOT NULL,
    Price       money    NOT NULL CHECK (Price >= 0),
    PaymentDate datetime NULL CHECK (PaymentDate IS NULL OR
                                     (PaymentDate >= '01-01-1900' AND
                                      PaymentDate <= GETDATE())),
    CONSTRAINT StudyOrders_pk PRIMARY KEY (OrderID, StudyID)
);

-- Table: StudyMeetingOrders
CREATE TABLE StudyMeetingOrders
(
    OrderID     int      NOT NULL,
    MeetingID   int      NOT NULL,
    Price       money    NOT NULL CHECK (Price >= 0),
    PaymentDate datetime NULL CHECK (PaymentDate IS NULL OR
                                     (PaymentDate >= '01-01-1900' AND
                                      PaymentDate <= GETDATE())),
    CONSTRAINT StudyMeetingOrders_pk PRIMARY KEY (OrderID, MeetingID)
);
