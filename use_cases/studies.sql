EXEC dbo.AddStudy 22, 'Web development 101', 'This course will teach you the basics of web development.', 1000
EXEC dbo.AddSubjectAndAssign 23, 'HTML, CSS, JavaScript - the basics',
     'This module includes the basics of HTML, CSS and JavaScript.', 11, 1
EXEC dbo.AddSubjectAndAssign 24, 'Microservices with ExpressJS', 'This module includes the basics of ExpressJS.', 11, 2
EXEC dbo.AddSubjectAndAssign 25, 'Basics of React',
     'This module instrduces React - probably the most popular front-end framework.', 11, 3
EXEC dbo.AddStudyMeeting 11, 'Meeting 1', '01-02-2026 00:00:00', '03-02-2026 00:00:00', 500, 30
EXEC dbo.AddClassAndAssign 11, 101, NULL, 27, NULL, NULL, 'Class 1', 'Intro', '05-10-2025 10:00:00', '01:30:00',
     'synchronous', NULL, 'videolink1', 'meetinglink1'
EXEC dbo.AddClassAndAssign 11, 101, NULL, 27, NULL, NULL, 'Class 2', 'aaaaq', '12-10-2025 10:00:00', '01:30:00',
     'synchronous', NULL, 'videolink2', 'meetinglink2'
EXEC dbo.AddClassAndAssign 11, 101, NULL, 27, NULL, NULL, 'Class 3', 'bbbbbbb', '19-10-2025 10:00:00', '01:30:00',
     'synchronous', NULL, 'videolink3', 'meetinglink3'
EXEC dbo.AddClassAndAssign 11, 101, NULL, 27, NULL, NULL, 'Class 4', NULL, '26-10-2025 10:00:00', '01:30:00',
     'synchronous', NULL, 'videolink4', NULL
EXEC dbo.AddClassAndAssign 11, 101, NULL, 27, NULL, NULL, 'Class 5', 'eeeeee', '03-11-2025 10:00:00', '01:30:00',
     'asynchronous', NULL, 'videolink5', NULL
EXEC dbo.AddClassAndAssign 11, 101, NULL, 27, NULL, NULL, 'Class 6', 'oiiaioiiiiai', '10-11-2025 10:00:00', '01:30:00',
     'stationary', 244, NULL, NULL
EXEC dbo.AddClassAndAssign 11, 102, NULL, 28, NULL, NULL, 'Class 1', 'Intro', '05-03-2026 10:00:00', '01:30:00',
     'synchronous', NULL, 'videolink6', 'meetinglink4'
EXEC dbo.AddClassAndAssign 11, 103, NULL, 29, NULL, NULL, 'Class 1', 'Intro', '05-10-2026 10:00:00', '01:30:00',
     'synchronous', NULL, 'videolink7', 'meetinglink5'

SELECT *
FROM dbo.STUDY_TIMETABLE
WHERE StudiesName = 'Web development 101'