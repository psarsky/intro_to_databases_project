--1 Administrator
create role admin
grant all privileges on u_psarski.dbo to admin


--2 Director
create role director
grant all privileges on u_psarski.dbo to director


--3 Teacher
create role teacher
grant execute on AddWebinar to teacher
grant execute on UpdateWebinarDate to teacher
grant execute on AssignTranslatorToWebinar to teacher
grant select on WEBINAR_TIMETABLE to teacher
grant select on COURSE_TIMETABLE to teacher
grant select on STUDY_TIMETABLE to teacher
grant select on ALL_EVENTS_TIMETABLE to teacher
grant select on CLASS_ATTENDANCE_REPORT to teacher
grant select on COURSE_MEETING_ATTENDANCE_REPORT to teacher
grant select on INTERNSHIP_ATTENDANCE_REPORT to teacher
grant select on ATTENDANCE_REPORT to teacher
grant execute on GenerateCourseSchedule to teacher
grant execute on GenerateStudySchedule to teacher
grant execute on StudyClassesGenerateAttendanceList to teacher
grant execute on CourseMeetingGenerateAttendanceList to teacher
grant execute on UpdateWebinarDate to teacher
grant execute on AssignTranslatorToWebinar to teacher
grant select on FUTURE_WEBINARS_REPORT to teacher
grant select on FUTURE_COURSE_MEETINGS_REPORT to teacher
grant select on FUTURE_STUDY_MEETINGS_REPORT to teacher
grant select on FUTURE_EVENTS_REPORT to teacher


--4 Course coordinator
create role course_coordinator
grant execute on AddCourse to course_coordinator
grant execute on AddCourseModule to course_coordinator
grant execute on AddCourseMeeting to course_coordinator
grant execute on UpdateCourseMeetingDate to course_coordinator
grant execute on AssignStationaryCourseMeeting to course_coordinator
grant execute on AssignAsynchronousCourseMeeting to course_coordinator
grant execute on AssignSynchronousCourseMeeting to course_coordinator
grant execute on AddMeetingAndAssign to course_coordinator
grant execute on AssignTranslatorToCourseMeeting to course_coordinator
grant select on COURSE_TIMETABLE to course_coordinator
grant execute on GenerateCourseSchedule to course_coordinator
grant execute on CourseMeetingGenerateAttendanceList to course_coordinator
grant select on FUTURE_COURSE_MEETINGS_REPORT to course_coordinator


--5 Subject coordinator
create role subject_coordinator
grant execute on AddStudyMeeting to subject_coordinator
grant execute on ChangeStudyMeetingDates to subject_coordinator
grant execute on AssignStationaryClass to subject_coordinator
grant execute on AssignAsynchronousClass to subject_coordinator
grant execute on AssignSynchronousClass to subject_coordinator
grant execute on AddClassAndAssign to subject_coordinator
grant execute on AssignTranslatorToClass to subject_coordinator
grant execute on StudyClassesGenerateAttendanceList to subject_coordinator
grant execute on CourseMeetingGenerateAttendanceList to subject_coordinator
grant select on CLASS_ATTENDANCE_REPORT to subject_coordinator
grant select on FUTURE_STUDY_MEETINGS_REPORT to subject_coordinator


--6 Study coordinator
create role study_coordinator
grant subject_coordinator to study_coordinator
grant execute on AddStudy to study_coordinator
grant execute on AddSubject to study_coordinator
grant execute on AssignSubjectToStudies to study_coordinator
grant execute on AddSubjectAndAssign to study_coordinator
grant execute on AddInternship to study_coordinator
grant execute on ChangeInternshipDates to study_coordinator
grant execute on AddStudyGrade to study_coordinator
grant select on STUDY_TIMETABLE to study_coordinator
grant select on INTERNSHIP_ATTENDANCE_REPORT to study_coordinator
grant execute on GenerateStudySchedule to study_coordinator
grant select on STUDENTS_REGISTERED_FOR_COLLIDING_FUTURE_EVENTS_LIST to study_coordinator


--7 User/Student
create role student
grant execute on RegisterForOneStudyMeeting to student
grant execute on AddOrderWithDetails to student
grant execute on GenerateStudentSchedule to student
grant execute on GenerateOrderInfo to student
grant select on STUDENTS_REGISTERED_FOR_COLLIDING_FUTURE_EVENTS_LIST to student
grant select on ATTENDANCE_REPORT to student
grant select on FUTURE_EVENTS_REPORT to student


--8 Translator
create role translator
grant select on WEBINAR_TIMETABLE to translator
grant select on COURSE_TIMETABLE to translator
grant select on STUDY_TIMETABLE to translator
grant select on ALL_EVENTS_TIMETABLE to translator


--9 Accountant
create role accountant
grant select on FUTURE_WEBINARS_REPORT to accountant
grant select on FUTURE_COURSE_MEETINGS_REPORT to accountant
grant select on FUTURE_STUDY_MEETINGS_REPORT to accountant
grant select on FUTURE_EVENTS_REPORT to accountant
grant select on WEBINARS_FINANCIAL_REPORT to accountant
grant select on COURSES_FINANCIAL_REPORT to accountant
grant select on STUDIES_FINANCIAL_REPORT to accountant
grant select on FINANCIAL_REPORT to accountant
grant select on LIST_OF_DEBTORS to accountant


