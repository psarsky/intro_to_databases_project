EXEC dbo.AddCourse 21, 'Web development 101', 'This course will teach you the basics of web development.', 1000,
     '01-05-2025 00:00:00', '03-05-2025 00:00:00'
EXEC dbo.AddCourseModule 16, 'HTML, CSS, JavaScript - the basics',
     'This module includes the basics of HTML, CSS and JavaScript.', 'stationary'
EXEC dbo.AddCourseModule 16, 'Microservices with ExpressJS', 'This module includes the basics of ExpressJS.',
     'asynchronous'
EXEC dbo.AddCourseModule 16, 'Basics of React',
     'This module instrduces React - probably the most popular front-end framework.', 'hybrid'
EXEC dbo.AddMeetingAndAssign 31, 25, NULL, NULL, 'Meeting 1 - HTML', NULL, '01-05-2025 8:00:00', '01:00:00',
     'stationary', 181, NULL, NULL
EXEC dbo.AddMeetingAndAssign 31, 25, NULL, NULL, 'Meeting 2 - CSS', NULL, '01-05-2025 9:30:00', '01:00:00',
     'stationary', 182, NULL, NULL
EXEC dbo.AddMeetingAndAssign 31, 25, NULL, NULL, 'Meeting 3 - JavaScript', NULL, '01-05-2025 11:00:00', '01:00:00',
     'stationary', 183, NULL, NULL
EXEC dbo.AddMeetingAndAssign 32, 26, NULL, NULL, 'Microservices with ExpressJS', NULL, '01-01-1950', '01:30:00',
     'asynchronous', NULL, 'https://meetings.com/ejfwoeifwoiedovidbfidn', NULL
EXEC dbo.AddMeetingAndAssign 33, 27, 1, 61, 'React - meeting 1', NULL, '02-05-2025 8:00:00', '01:00:00', 'stationary',
     184, NULL, NULL
EXEC dbo.AddMeetingAndAssign 33, 27, 1, 61, 'React - meeting 2', NULL, '02-05-2025 9:30:00', '01:00:00', 'stationary',
     185, NULL, NULL
EXEC dbo.AddMeetingAndAssign 33, 27, 1, 61, 'React - meeting 3', NULL, '01-01-1950', '01:30:00', 'asynchronous', NULL,
     'https://meetings.com/ifsjggbgrtufidn', NULL

SELECT *
FROM dbo.COURSE_TIMETABLE
WHERE CourseName = 'Web development 101'