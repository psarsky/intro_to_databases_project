EXEC dbo.AddStudy 22, 'Web development 101', 'This course will teach you the basics of web development.', 1000
EXEC dbo.AddSubjectAndAssign 23, 'HTML, CSS, JavaScript - the basics',
     'This module includes the basics of HTML, CSS and JavaScript.', 11, 1
EXEC dbo.AddSubjectAndAssign 24, 'Microservices with ExpressJS', 'This module includes the basics of ExpressJS.', 11, 2
EXEC dbo.AddSubjectAndAssign 25, 'Basics of React.js',
     'This module instrduces React.js - probably the most popular front-end framework.', 11, 3
EXEC dbo.AddStudyMeeting 11, 'Meeting 1', '20260201 00:00:00', '20260203 00:00:00', 500, 30
EXEC dbo.AddClassAndAssign 11, 101, NULL, 27, NULL, NULL, 'Class 1', 'Intro', '20251005 10:00:00', '01:30:00',
     'synchronous', NULL, 'videolink1', 'meetinglink1'
EXEC dbo.AddClassAndAssign 11, 101, NULL, 27, NULL, NULL, 'Class 2', 'aaaaq', '20251012 10:00:00', '01:30:00',
     'synchronous', NULL, 'videolink2', 'meetinglink2'
EXEC dbo.AddClassAndAssign 11, 101, NULL, 27, NULL, NULL, 'Class 3', 'bbbbbbb', '20251019 10:00:00', '01:30:00',
     'synchronous', NULL, 'videolink3', 'meetinglink3'
EXEC dbo.AddClassAndAssign 11, 101, NULL, 27, NULL, NULL, 'Class 4', NULL, '20251026 10:00:00', '01:30:00',
     'asynchronous', NULL, 'videolink4', NULL
EXEC dbo.AddClassAndAssign 11, 101, NULL, 27, NULL, NULL, 'Class 5', 'eeeeee', '20251103 10:00:00', '01:30:00',
     'asynchronous', NULL, 'videolink5', NULL
INSERT INTO Reservations(RoomID, StartTime, EndTime)
VALUES (15, '20251110 10:00:00', '20251110 11:30:00')
EXEC dbo.AddClassAndAssign 11, 101, 101, 27, NULL, NULL, 'Class 6', 'oiiaioiiiiai', '20251110 10:00:00', '01:30:00',
     'stationary', 244, NULL, NULL
EXEC dbo.AddClassAndAssign 11, 102, NULL, 28, NULL, NULL, 'Class 1', 'Intro', '20260305 10:00:00', '01:30:00',
     'synchronous', NULL, 'videolink6', 'meetinglink4'
EXEC dbo.AddClassAndAssign 11, 103, NULL, 29, NULL, NULL, 'Class 1', 'Intro', '20261005 10:00:00', '01:30:00',
     'synchronous', NULL, 'videolink7', 'meetinglink5'
EXEC dbo.AddInternship 11, 30, 'Front end development internship', '20260505 00:00:00'

SELECT *
FROM dbo.STUDY_TIMETABLE
WHERE StudiesName = 'Web development 101'


-- RESET

DELETE
FROM Internships
WHERE InternshipID > 10
DELETE
FROM StationaryClasses
WHERE ClassID > 1000
DELETE
FROM OnlineSynchronousClasses
WHERE ClassID > 1000
DELETE
FROM OnlineAsynchronousClasses
WHERE ClassID > 1000
DELETE
FROM Classes
WHERE ClassID > 1000
DELETE
FROM StudyMeetings
WHERE MeetingID > 100
DELETE
FROM SubjectDetails
WHERE SubjectID > 100
DELETE
FROM Subjects
WHERE SubjectID > 100
DELETE
FROM StudentLists
WHERE StudyID > 10
DELETE
FROM Studies
WHERE StudyID > 10

DBCC CHECKIDENT ('Internships', RESEED, 10);
DBCC CHECKIDENT ('Classes', RESEED, 1000);
DBCC CHECKIDENT ('StudyMeetings', RESEED, 100);
DBCC CHECKIDENT ('Subjects', RESEED, 100);
DBCC CHECKIDENT ('Studies', RESEED, 10);
