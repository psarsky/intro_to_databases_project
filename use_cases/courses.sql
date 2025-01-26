EXEC dbo.AddCourse 21, 'Web development 101', 'This course will teach you the basics of web development.', 1000,
     '20250501 00:00:00', '20250503 00:00:00'
EXEC dbo.AddCourseModule 16, 'HTML, CSS, JavaScript - the basics',
     'This module includes the basics of HTML, CSS and JavaScript.', 'stationary'
EXEC dbo.AddCourseModule 16, 'Microservices with ExpressJS', 'This module includes the basics of ExpressJS.',
     'asynchronous'
EXEC dbo.AddCourseModule 16, 'Basics of React',
     'This module instrduces React - probably the most popular front-end framework.', 'hybrid'
EXEC dbo.AddMeetingAndAssign 31, 25, NULL, NULL, 'Meeting 1 - HTML', NULL, '20250501 8:00:00', '01:00:00',
     'stationary', 181, NULL, NULL
EXEC dbo.AddMeetingAndAssign 31, 25, NULL, NULL, 'Meeting 2 - CSS', NULL, '20250501 9:30:00', '01:00:00',
     'stationary', 182, NULL, NULL
EXEC dbo.AddMeetingAndAssign 31, 25, NULL, NULL, 'Meeting 3 - JavaScript', NULL, '20250501 11:00:00', '01:00:00',
     'stationary', 183, NULL, NULL
EXEC dbo.AddMeetingAndAssign 32, 26, NULL, NULL, 'Microservices with ExpressJS', NULL, NULL, '01:30:00',
     'asynchronous', NULL, 'https://meetings.com/ejfwoeifwoiedovidbfidn', NULL
EXEC dbo.AddMeetingAndAssign 33, 27, 1, 61, 'React - meeting 1', NULL, '20250502 8:00:00', '01:00:00', 'stationary',
     184, NULL, NULL
EXEC dbo.AddMeetingAndAssign 33, 27, 1, 61, 'React - meeting 2', NULL, '20250502 9:30:00', '01:00:00', 'stationary',
     185, NULL, NULL
EXEC dbo.AddMeetingAndAssign 33, 27, 1, 61, 'React - meeting 3', NULL, NULL, '01:30:00', 'asynchronous', NULL,
     'https://meetings.com/ifsjggbgrtufidn', NULL

SELECT *
FROM dbo.COURSE_TIMETABLE
WHERE CourseName = 'Web development 101'


-- RESET

DELETE
FROM StationaryCourseMeetings
WHERE MeetingID > 120
DELETE
FROM OnlineSynchronousCourseMeetings
WHERE MeetingID > 120
DELETE
FROM OnlineAsynchronousCourseMeetings
WHERE MeetingID > 120
DELETE
FROM CourseMeetings
WHERE MeetingID > 120
DELETE
FROM CourseModules
WHERE ModuleID > 30
DELETE
FROM Courses
WHERE CourseID > 15

DBCC CHECKIDENT ('CourseMeetings', RESEED, 120);
DBCC CHECKIDENT ('CourseModules', RESEED, 30);
DBCC CHECKIDENT ('Courses', RESEED, 15);
