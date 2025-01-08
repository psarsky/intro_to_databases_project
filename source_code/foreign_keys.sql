-- Reference: ClassAttendance_Classes (table: ClassAttendance)
ALTER TABLE ClassAttendance
    ADD CONSTRAINT ClassAttendance_Classes
        FOREIGN KEY (ClassID)
            REFERENCES Classes (ClassID);

-- Reference: ClassAttendance_Users (table: ClassAttendance)
ALTER TABLE ClassAttendance
    ADD CONSTRAINT ClassAttendance_Users
        FOREIGN KEY (UserID)
            REFERENCES Users (UserID);

-- Reference: Classes_Employees (table: Classes)
ALTER TABLE Classes
    ADD CONSTRAINT Classes_Employees
        FOREIGN KEY (TeacherID)
            REFERENCES Employees (EmployeeID);

-- Reference: Classes_OnlineAsynchronousClasses (table: OnlineAsynchronousClasses)
ALTER TABLE OnlineAsynchronousClasses
    ADD CONSTRAINT Classes_OnlineAsynchronousClasses
        FOREIGN KEY (ClassID)
            REFERENCES Classes (ClassID);

-- Reference: Classes_OnlineSynchronousClasses (table: OnlineSynchronousClasses)
ALTER TABLE OnlineSynchronousClasses
    ADD CONSTRAINT Classes_OnlineSynchronousClasses
        FOREIGN KEY (ClassID)
            REFERENCES Classes (ClassID);

-- Reference: Classes_StationaryClasses (table: StationaryClasses)
ALTER TABLE StationaryClasses
    ADD CONSTRAINT Classes_StationaryClasses
        FOREIGN KEY (ClassID)
            REFERENCES Classes (ClassID);

-- Reference: Classes_StudyMeetings (table: Classes)
ALTER TABLE Classes
    ADD CONSTRAINT Classes_StudyMeetings
        FOREIGN KEY (MeetingID)
            REFERENCES StudyMeetings (MeetingID);

-- Reference: Classes_SubjectDetails (table: Classes)
ALTER TABLE Classes
    ADD CONSTRAINT Classes_SubjectDetails
        FOREIGN KEY (StudyID, SubjectID)
            REFERENCES SubjectDetails (StudyID, SubjectID);

-- Reference: CourseMeetingAttendance_CourseMeetings (table: CourseMeetingAttendance)
ALTER TABLE CourseMeetingAttendance
    ADD CONSTRAINT CourseMeetingAttendance_CourseMeetings
        FOREIGN KEY (MeetingID)
            REFERENCES CourseMeetings (MeetingID);

-- Reference: CourseMeetingAttendance_Users (table: CourseMeetingAttendance)
ALTER TABLE CourseMeetingAttendance
    ADD CONSTRAINT CourseMeetingAttendance_Users
        FOREIGN KEY (UserID)
            REFERENCES Users (UserID);

-- Reference: CourseMeetings_CourseModules (table: CourseMeetings)
ALTER TABLE CourseMeetings
    ADD CONSTRAINT CourseMeetings_CourseModules
        FOREIGN KEY (ModuleID)
            REFERENCES CourseModules (ModuleID);

-- Reference: CourseMeetings_Employees (table: CourseMeetings)
ALTER TABLE CourseMeetings
    ADD CONSTRAINT CourseMeetings_Employees
        FOREIGN KEY (TeacherID)
            REFERENCES Employees (EmployeeID);

-- Reference: CourseMeetings_TranslatorLanguages (table: CourseMeetings)
ALTER TABLE CourseMeetings
    ADD CONSTRAINT CourseMeetings_TranslatorLanguages
        FOREIGN KEY (TranslatorID, LanguageID)
            REFERENCES TranslatorLanguages (TranslatorID, LanguageID);

-- Reference: CourseModules_Courses (table: CourseModules)
ALTER TABLE CourseModules
    ADD CONSTRAINT CourseModules_Courses
        FOREIGN KEY (CourseID)
            REFERENCES Courses (CourseID);

-- Reference: CourseOrders_Courses (table: CourseOrders)
ALTER TABLE CourseOrders
    ADD CONSTRAINT CourseOrders_Courses
        FOREIGN KEY (CourseID)
            REFERENCES Courses (CourseID);

-- Reference: CourseOrders_Orders (table: CourseOrders)
ALTER TABLE CourseOrders
    ADD CONSTRAINT CourseOrders_Orders
        FOREIGN KEY (OrderID)
            REFERENCES Orders (OrderID);

-- Reference: Courses_Employees (table: Courses)
ALTER TABLE Courses
    ADD CONSTRAINT Courses_Employees
        FOREIGN KEY (CoordinatorID)
            REFERENCES Employees (EmployeeID);

-- Reference: Employees_Positions (table: Employees)
ALTER TABLE Employees
    ADD CONSTRAINT Employees_Positions
        FOREIGN KEY (PositionID)
            REFERENCES Positions (PositionID);

-- Reference: InternshipAttendance_StudentLists (table: InternshipAttendance)
ALTER TABLE InternshipAttendance
    ADD CONSTRAINT InternshipAttendance_StudentLists
        FOREIGN KEY (StudyID, UserID)
            REFERENCES StudentLists (StudyID, UserID);

-- Reference: InternshipDetails_Internships (table: InternshipAttendance)
ALTER TABLE InternshipAttendance
    ADD CONSTRAINT InternshipDetails_Internships
        FOREIGN KEY (InternshipID)
            REFERENCES Internships (InternshipID);

-- Reference: Internships_Employees (table: Internships)
ALTER TABLE Internships
    ADD CONSTRAINT Internships_Employees
        FOREIGN KEY (TeacherID)
            REFERENCES Employees (EmployeeID);

-- Reference: Internships_Studies (table: Internships)
ALTER TABLE Internships
    ADD CONSTRAINT Internships_Studies
        FOREIGN KEY (StudyID)
            REFERENCES Studies (StudyID);

-- Reference: Meetings_TranslatorLanguages (table: Classes)
ALTER TABLE Classes
    ADD CONSTRAINT Meetings_TranslatorLanguages
        FOREIGN KEY (TranslatorID, LanguageID)
            REFERENCES TranslatorLanguages (TranslatorID, LanguageID);

-- Reference: OnlineAsynchronousCourseMeetings_CourseMeetings (table: OnlineAsynchronousCourseMeetings)
ALTER TABLE OnlineAsynchronousCourseMeetings
    ADD CONSTRAINT OnlineAsynchronousCourseMeetings_CourseMeetings
        FOREIGN KEY (MeetingID)
            REFERENCES CourseMeetings (MeetingID);

-- Reference: OnlineSynchronousCourseMeetings_CourseMeetings (table: OnlineSynchronousCourseMeetings)
ALTER TABLE OnlineSynchronousCourseMeetings
    ADD CONSTRAINT OnlineSynchronousCourseMeetings_CourseMeetings
        FOREIGN KEY (MeetingID)
            REFERENCES CourseMeetings (MeetingID);

-- Reference: Orders_Users (table: Orders)
ALTER TABLE Orders
    ADD CONSTRAINT Orders_Users
        FOREIGN KEY (UserID)
            REFERENCES Users (UserID);

-- Reference: Reservations_Rooms (table: Reservations)
ALTER TABLE Reservations
    ADD CONSTRAINT Reservations_Rooms
        FOREIGN KEY (RoomID)
            REFERENCES Rooms (RoomID);

-- Reference: StationaryClasses_Reservations (table: StationaryClasses)
ALTER TABLE StationaryClasses
    ADD CONSTRAINT StationaryClasses_Reservations
        FOREIGN KEY (ReservationID)
            REFERENCES Reservations (ReservationID);

-- Reference: StationaryCourseMeetings_CourseMeetings (table: StationaryCourseMeetings)
ALTER TABLE StationaryCourseMeetings
    ADD CONSTRAINT StationaryCourseMeetings_CourseMeetings
        FOREIGN KEY (MeetingID)
            REFERENCES CourseMeetings (MeetingID);

-- Reference: StationaryCourseMeetings_Reservations (table: StationaryCourseMeetings)
ALTER TABLE StationaryCourseMeetings
    ADD CONSTRAINT StationaryCourseMeetings_Reservations
        FOREIGN KEY (ReservationID)
            REFERENCES Reservations (ReservationID);

-- Reference: StudentLists_Studies (table: StudentLists)
ALTER TABLE StudentLists
    ADD CONSTRAINT StudentLists_Studies
        FOREIGN KEY (StudyID)
            REFERENCES Studies (StudyID);

-- Reference: StudentLists_StudyGrades (table: StudyGrades)
ALTER TABLE StudyGrades
    ADD CONSTRAINT StudentLists_StudyGrades
        FOREIGN KEY (StudyID, UserID)
            REFERENCES StudentLists (StudyID, UserID);

-- Reference: StudentLists_Users (table: StudentLists)
ALTER TABLE StudentLists
    ADD CONSTRAINT StudentLists_Users
        FOREIGN KEY (UserID)
            REFERENCES Users (UserID);

-- Reference: Studies_Employees (table: Studies)
ALTER TABLE Studies
    ADD CONSTRAINT Studies_Employees
        FOREIGN KEY (CoordinatorID)
            REFERENCES Employees (EmployeeID);

-- Reference: StudyMeetingOrders_Orders (table: StudyMeetingOrders)
ALTER TABLE StudyMeetingOrders
    ADD CONSTRAINT StudyMeetingOrders_Orders
        FOREIGN KEY (OrderID)
            REFERENCES Orders (OrderID);

-- Reference: StudyMeetingOrders_StudyMeetings (table: StudyMeetingOrders)
ALTER TABLE StudyMeetingOrders
    ADD CONSTRAINT StudyMeetingOrders_StudyMeetings
        FOREIGN KEY (MeetingID)
            REFERENCES StudyMeetings (MeetingID);

-- Reference: StudyMeetings_Studies (table: StudyMeetings)
ALTER TABLE StudyMeetings
    ADD CONSTRAINT StudyMeetings_Studies
        FOREIGN KEY (StudyID)
            REFERENCES Studies (StudyID);

-- Reference: StudyOrders_Orders (table: StudyOrders)
ALTER TABLE StudyOrders
    ADD CONSTRAINT StudyOrders_Orders
        FOREIGN KEY (OrderID)
            REFERENCES Orders (OrderID);

-- Reference: StudyOrders_Studies (table: StudyOrders)
ALTER TABLE StudyOrders
    ADD CONSTRAINT StudyOrders_Studies
        FOREIGN KEY (StudyID)
            REFERENCES Studies (StudyID);

-- Reference: SubjectDetails_Studies (table: SubjectDetails)
ALTER TABLE SubjectDetails
    ADD CONSTRAINT SubjectDetails_Studies
        FOREIGN KEY (StudyID)
            REFERENCES Studies (StudyID);

-- Reference: SubjectDetails_Subjects (table: SubjectDetails)
ALTER TABLE SubjectDetails
    ADD CONSTRAINT SubjectDetails_Subjects
        FOREIGN KEY (SubjectID)
            REFERENCES Subjects (SubjectID);

-- Reference: SubjectGrades_StudentLists (table: SubjectGrades)
ALTER TABLE SubjectGrades
    ADD CONSTRAINT SubjectGrades_StudentLists
        FOREIGN KEY (StudyID, UserID)
            REFERENCES StudentLists (StudyID, UserID);

-- Reference: SubjectGrades_Subjects (table: SubjectGrades)
ALTER TABLE SubjectGrades
    ADD CONSTRAINT SubjectGrades_Subjects
        FOREIGN KEY (SubjectID)
            REFERENCES Subjects (SubjectID);

-- Reference: Subjects_Employees (table: Subjects)
ALTER TABLE Subjects
    ADD CONSTRAINT Subjects_Employees
        FOREIGN KEY (CoordinatorID)
            REFERENCES Employees (EmployeeID);

-- Reference: TranslatorLanguages_Employees (table: TranslatorLanguages)
ALTER TABLE TranslatorLanguages
    ADD CONSTRAINT TranslatorLanguages_Employees
        FOREIGN KEY (TranslatorID)
            REFERENCES Employees (EmployeeID);

-- Reference: TranslatorLanguages_Languages (table: TranslatorLanguages)
ALTER TABLE TranslatorLanguages
    ADD CONSTRAINT TranslatorLanguages_Languages
        FOREIGN KEY (LanguageID)
            REFERENCES Languages (LanguageID);

-- Reference: Users_CountriesCities (table: Users)
ALTER TABLE Users ADD CONSTRAINT Users_CountriesCities
    FOREIGN KEY (City,Country)
        REFERENCES CountriesCities (City,Country);

-- Reference: WebinarOrders_Orders (table: WebinarOrders)
ALTER TABLE WebinarOrders
    ADD CONSTRAINT WebinarOrders_Orders
        FOREIGN KEY (OrderID)
            REFERENCES Orders (OrderID);

-- Reference: WebinarOrders_Webinars (table: WebinarOrders)
ALTER TABLE WebinarOrders
    ADD CONSTRAINT WebinarOrders_Webinars
        FOREIGN KEY (WebinarID)
            REFERENCES Webinars (WebinarID);

-- Reference: Webinars_Employees (table: Webinars)
ALTER TABLE Webinars
    ADD CONSTRAINT Webinars_Employees
        FOREIGN KEY (TeacherID)
            REFERENCES Employees (EmployeeID);

-- Reference: Webinars_TranslatorLanguages (table: Webinars)
ALTER TABLE Webinars
    ADD CONSTRAINT Webinars_TranslatorLanguages
        FOREIGN KEY (TranslatorID, LanguageID)
            REFERENCES TranslatorLanguages (TranslatorID, LanguageID);