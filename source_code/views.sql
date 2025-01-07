-- View: WEBINARS_FINANCIAL_REPORT
CREATE VIEW WEBINARS_FINANCIAL_REPORT
AS
SELECT w.WebinarID                        AS ID,
       w.Title                            AS Name,
       (SELECT ISNULL(SUM(wo.Price), 0)
        FROM WebinarOrders wo
        WHERE wo.WebinarID = w.WebinarID
          AND wo.PaymentDate IS NOT NULL) AS TotalIncome
FROM Webinars w
GO;

-- View: COURSES_FINANCIAL_REPORT
CREATE VIEW COURSES_FINANCIAL_REPORT
AS
SELECT c.CourseID                                  AS ID,
       c.Title                                     AS Name,
       (SELECT SUM(co.FullPrice)
        FROM CourseOrders co
        WHERE co.CourseID = c.CourseID
          AND co.PaymentDateFull IS NOT NULL) +
       (SELECT SUM(co.PaymentInAdvance)
        FROM CourseOrders AS co
        WHERE co.CourseID = c.CourseID
          AND co.PaymentDateFull IS NULL
          AND co.PaymentDateInAdvance IS NOT NULL) AS TotalIncome
FROM Courses c
GO;

-- View: STUDIES_FINANCIAL_REPORT
CREATE VIEW STUDIES_FINANCIAL_REPORT
AS
SELECT s.StudyID                           AS ID,
       s.Title                             AS Name,
       (SELECT SUM(so.Price)
        FROM StudyOrders so
        WHERE so.StudyID = s.StudyID
          AND so.PaymentDate IS NOT NULL) +
       (SELECT SUM(smo.Price)
        FROM StudyMeetingOrders smo
                 INNER JOIN StudyMeetings sm ON smo.MeetingID = sm.MeetingID
        WHERE sm.StudyID = s.StudyID
          AND smo.PaymentDate IS NOT NULL) AS TotalIncome
FROM Studies s
GO;

-- View: FINANCIAL_REPORT
CREATE VIEW FINANCIAL_REPORT
AS
SELECT *, 'Webinar' AS Type
FROM WEBINARS_FINANCIAL_REPORT
UNION
SELECT *, 'Course' AS Type
FROM COURSES_FINANCIAL_REPORT
UNION
SELECT *, 'Study' AS Type
FROM STUDIES_FINANCIAL_REPORT
GO;

-- View: FUTURE_WEBINARS_REPORT
CREATE VIEW FUTURE_WEBINARS_REPORT
AS
SELECT w.WebinarID AS ID,
       w.Title     AS Name,
       COUNT(*)    AS Participants
FROM Webinars w
         INNER JOIN WebinarOrders wo
                    ON w.WebinarID = wo.WebinarID
WHERE w.Date > GETDATE()
  AND wo.PaymentDate IS NOT NULL
GROUP BY w.WebinarID, w.Title
GO;

-- View: FUTURE_COURSE_MEETINGS_REPORT
CREATE VIEW FUTURE_COURSE_MEETINGS_REPORT
AS
SELECT cm.MeetingID AS ID,
       cm.Title     AS Name,
       COUNT(*)     AS Participants
FROM CourseMeetings cm
         INNER JOIN CourseModules cmod
                    ON cm.ModuleID = cmod.ModuleID
         INNER JOIN Courses c
                    ON cmod.CourseID = c.CourseID
         INNER JOIN CourseOrders co
                    ON c.CourseID = co.CourseID
WHERE cm.Date > GETDATE()
  AND (co.PaymentDateFull IS NOT NULL OR co.PaymentDateInAdvance IS NOT NULL)
GROUP BY cm.MeetingID, cm.Title
GO;

-- View: FUTURE_STUDY_MEETINGS_REPORT
CREATE VIEW FUTURE_STUDY_MEETINGS_REPORT
AS
SELECT sm.MeetingID AS ID,
       sm.Title     AS Name,
       COUNT(*)     AS Participants
FROM StudyMeetings sm
         INNER JOIN StudyMeetingOrders smo
                    ON sm.MeetingID = smo.MeetingID
WHERE sm.BeginDate > GETDATE()
  AND smo.PaymentDate IS NOT NULL
GROUP BY sm.MeetingID, sm.Title
GO;

-- View: FUTURE_EVENTS_REPORT
CREATE VIEW FUTURE_EVENTS_REPORT
AS
SELECT *, 'Webinar' AS Type
FROM FUTURE_WEBINARS_REPORT
UNION
SELECT *, 'Course meeting' AS Type
FROM FUTURE_COURSE_MEETINGS_REPORT
UNION
SELECT *, 'Study meeting' AS Type
FROM FUTURE_STUDY_MEETINGS_REPORT
GO;

-- View: CLASS_ATTENDANCE_REPORT
CREATE VIEW CLASS_ATTENDANCE_REPORT AS
SELECT ClassID                                                     AS ID,
       COUNT(CASE WHEN Attended = 1 THEN 1 END)                    AS PresentCount,
       COUNT(CASE WHEN Attended = 0 THEN 1 END)                    AS AbsentCount,
       COUNT(*)                                                    AS TotalParticipants,
       COUNT(CASE WHEN Attended = 1 THEN 1 END) * 100.0 / COUNT(*) AS AttendancePercentage
FROM ClassAttendance
GROUP BY ClassID
GO;

-- View: COURSE_MEETING_ATTENDANCE_REPORT
CREATE VIEW COURSE_MEETING_ATTENDANCE_REPORT AS
SELECT MeetingID                                                   AS ID,
       COUNT(CASE WHEN Attended = 1 THEN 1 END)                    AS PresentCount,
       COUNT(CASE WHEN Attended = 0 THEN 1 END)                    AS AbsentCount,
       COUNT(*)                                                    AS TotalParticipants,
       COUNT(CASE WHEN Attended = 1 THEN 1 END) * 100.0 / COUNT(*) AS AttendancePercentage
FROM CourseMeetingAttendance
GROUP BY MeetingID
GO;

-- View: INTERNSHIP_ATTENDANCE_REPORT
CREATE VIEW INTERNSHIP_ATTENDANCE_REPORT AS
SELECT InternshipID                                                AS ID,
       COUNT(CASE WHEN Attended = 1 THEN 1 END)                    AS PresentCount,
       COUNT(CASE WHEN Attended = 0 THEN 1 END)                    AS AbsentCount,
       COUNT(*)                                                    AS TotalParticipants,
       COUNT(CASE WHEN Attended = 1 THEN 1 END) * 100.0 / COUNT(*) AS AttendancePercentage
FROM InternshipAttendance
GROUP BY InternshipID
GO;

-- View: ATTENDANCE_REPORT
CREATE VIEW ATTENDANCE_REPORT AS
SELECT *, 'Internship' AS Type
FROM INTERNSHIP_ATTENDANCE_REPORT
UNION
SELECT *, 'Course meeting' AS Type
FROM COURSE_MEETING_ATTENDANCE_REPORT
UNION
SELECT *, 'Classes' AS Type
FROM CLASS_ATTENDANCE_REPORT
GO;

--View: HarmonogramOfWebinars
CREATE VIEW HarmonogramOfWebinars AS
SELECT Date, Duration, Title
FROM Webinars
ORDER BY Date
GO;

--View: HarmonogramOfCourses
CREATE VIEW HarmonogramOfCourses AS
SELECT cm.Date, cm.Duration, cm.Title AS MeetingTitle, cmod.Title AS ModuleTitle, c.Title AS CourseTile
FROM CourseMeetings AS cm
JOIN CourseModules AS cmod ON cm.ModuleID = cmod.ModuleID
JOIN Courses AS c ON cmod.CourseID = c.CourseID
ORDER BY cm.Date
GO;

--View: HarmonogramOfStudies
CREATE VIEW HarmonogramOfStudies AS
SELECT c.Date, c.Duration, sub.Title AS SubjectTitle, s.Title AS StudiesTitle
FROM Classes AS c
JOIN Subjects AS sub ON c.SubjectID = sub.SubjectID
JOIN Studies AS s On c.StudyID = s.StudyID
ORDER BY c.Date
GO;

--View: HarmonogramOfAll
CREATE VIEW HarmonografOfAll AS
SELECT Date AS Date, Duration AS Duration, Title AS Title, NULL AS SuperiorTitle
FROM Webinars
UNION
SELECT cm.Date AS Date, cm.Duration AS Duration, cm.Title AS Title, c.Title AS SuperiorTile
FROM CourseMeetings AS cm
JOIN CourseModules AS cmod ON cm.ModuleID = cmod.ModuleID
JOIN Courses AS c ON cmod.CourseID = c.CourseID
UNION
SELECT c.Date AS Date, c.Duration AS Duration, sub.Title AS Title, s.Title AS SuperiorTitle
FROM Classes AS c
JOIN Subjects AS sub ON c.SubjectID = sub.SubjectID
JOIN Studies AS s On c.StudyID = s.StudyID
ORDER BY Date
GO;