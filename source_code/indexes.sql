--PEOPLE

CREATE INDEX Employees_PositionID ON Employees (PositionID);
CREATE INDEX Users_CityID ON Users (CityID);
CREATE INDEX Cities_CountryID ON Cities (CountryID);
CREATE INDEX TranslatorLanguages_TranslatorID ON TranslatorLanguages (TranslatorID);
CREATE INDEX TranslatorLanguages_LanguageID ON TranslatorLanguages (LanguageID);


-- WEBINARS

CREATE INDEX Webinars_TeacherID ON Webinars (TeacherID);
CREATE INDEX Webinars_TranslatorID ON Webinars (TranslatorID);
CREATE INDEX Webinars_LanguageID ON Webinars (LanguageID);
CREATE INDEX Webinars_Date ON Webinars (Date);
CREATE INDEX Webinars_Price ON Webinars (Price);


-- COURSES

CREATE INDEX Courses_CoordinatorID ON Courses (CoordinatorID);
CREATE INDEX Courses_Price ON Courses (Price);

CREATE INDEX CourseModules_CourseID ON CourseModules (CourseID);
CREATE INDEX CourseModules_ModuleType ON CourseModules (ModuleType);

CREATE INDEX CourseMeetings_ModuleID ON CourseMeetings (ModuleID);
CREATE INDEX CourseMeetings_TeacherID ON CourseMeetings (TeacherID);
CREATE INDEX CourseMeetings_LanguageID ON CourseMeetings (LanguageID);
CREATE INDEX CourseMeetings_TranslatorID ON CourseMeetings (TranslatorID);
CREATE INDEX CourseMeetings_Date ON CourseMeetings (Date);


-- STUDIES

CREATE INDEX Study_CoordinatorID ON Studies (CoordinatorID);
CREATE INDEX Study_Price ON Studies (TuitionFee);

CREATE INDEX Subjects_CoordinatorID ON Subjects (CoordinatorID);

CREATE INDEX SubjectDetails_StudyID ON SubjectDetails (StudyID);
CREATE INDEX SubjectDetails_SubjectID ON SubjectDetails (SubjectID);

CREATE INDEX StudentLists_StudyID ON StudentLists (StudyID);
CREATE INDEX StudentLists_UserID ON StudentLists (UserID);

CREATE INDEX StudyGrades_StudyID ON StudyGrades (StudyID);
CREATE INDEX StudyGrades_UserID ON StudyGrades (UserID);
CREATE INDEX StudyGrades_Grade ON StudyGrades (Grade);

CREATE INDEX SubjectGrades_StudyID ON SubjectGrades (StudyID);
CREATE INDEX SubjectGrades_UserID ON SubjectGrades (UserID);
CREATE INDEX SubjectGrades_SubjectID ON SubjectGrades (SubjectID);
CREATE INDEX SubjectGrades_Grade ON SubjectGrades (Grade);

CREATE INDEX Internships_StudyID ON Internships (StudyID);
CREATE INDEX Internships_TeacherID ON Internships (TeacherID);
CREATE INDEX Internships_StartDate ON Internships (StartDate);

CREATE INDEX InternshipAttendance_InternshipID ON InternshipAttendance (InternshipID);
CREATE INDEX InternshipAttendance_UserID ON InternshipAttendance (UserID);
CREATE INDEX InternshipAttendance_StudyID ON InternshipAttendance (StudyID);


-- MEETINGS

CREATE INDEX StudyMeetings_StudyID ON StudyMeetings (StudyID);
CREATE INDEX StudyMeetings_Price ON StudyMeetings (Price);
CREATE INDEX StudyMeetings_BeginDate ON StudyMeetings (BeginDate);
CREATE INDEX StudyMeetings_EndDate ON StudyMeetings (EndDate);

CREATE INDEX Classes_StudyID ON Classes (StudyID);
CREATE INDEX Classes_SubjectID ON Classes (SubjectID);
CREATE INDEX Classes_MeetingID ON Classes (MeetingID);
CREATE INDEX Classes_TeacherID ON Classes (TeacherID);
CREATE INDEX Classes_LanguageID ON Classes (LanguageID);
CREATE INDEX Classes_TranslatorID ON Classes (TranslatorID);
CREATE INDEX Classes_Date ON Classes (Date);

CREATE INDEX ClassAttendance_ClassID ON ClassAttendance (ClassID);
CREATE INDEX ClassAttendance_UserID ON ClassAttendance (UserID);


-- ORDERS

CREATE INDEX Orders_UserID ON Orders (UserID);

CREATE INDEX WebinarOrders_OrderID ON WebinarOrders (OrderID);
CREATE INDEX WebinarOrders_WebinarID ON WebinarOrders (WebinarID);
CREATE INDEX WebinarOrders_PaymentDate ON WebinarOrders (PaymentDate);

CREATE INDEX CourseOrders_OrderID ON CourseOrders (OrderID);
CREATE INDEX CourseOrders_CourseID ON CourseOrders (CourseID);
CREATE INDEX CourseOrders_PaymentDateInAdvance ON CourseOrders (PaymentDateInAdvance);
CREATE INDEX CourseOrders_PaymentDateFull ON CourseOrders (PaymentDateFull);

CREATE INDEX StudyOrders_OrderID ON StudyOrders (OrderID);
CREATE INDEX StudyOrders_StudyID ON StudyOrders (StudyID);
CREATE INDEX StudyOrders_PaymentDate ON StudyOrders (PaymentDate);

CREATE INDEX StudyMeetingOrders_OrderID ON StudyMeetingOrders (OrderID);
CREATE INDEX StudyMeetingOrders_MeetingID ON StudyMeetingOrders (MeetingID);
CREATE INDEX StudyMeetingOrders_PaymentDate ON StudyMeetingOrders (PaymentDate);


-- ROOMS

CREATE INDEX Reservations_RoomID ON Reservations (RoomID);
