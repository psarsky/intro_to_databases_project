EXEC AddWebinar
     35,
     NULL,
     NULL,
     'How to overcome sleep deprivation',
     'just go to sleep lul',
     '20250304 12:00:00',
     '3:00:00',
     'https://meetingsite.com/eeeeeeeeeeeheheheehehehehehehehhe',
     'https://videosite.com/eeeeeeeeeeeheheheehehehehehehehhe',
     150

SELECT *
FROM dbo.WEBINAR_TIMETABLE
WHERE Name = 'How to overcome sleep deprivation'


-- RESET

DELETE
FROM Webinars
WHERE WebinarID > 400
DBCC CHECKIDENT ('Webinars', RESEED, 400);