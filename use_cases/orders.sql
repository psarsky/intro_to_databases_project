EXEC AddOrderWithDetails 201, '20240201 10:00:00', 'https://payment.example.com/order101', 'Webinar', 401, 50
EXEC AddOrderDetails 74, 'Course', 16, NULL, NULL, 100, 1000, '20240202 10:00:00', NULL
EXEC AddOrderDetails 74, 'Study', 11, 1000, '20240202 10:00:00', NULL, NULL, NULL, NULL
EXEC AddOrderDetails 74, 'StudyMeeting', 101, 500, NULL, NULL, NULL, NULL, NULL
EXEC ModifyOrder 74, 201, 'https://payment.example.com/updated_order201'
EXEC ModifyOrderDetails 74, 'Course', 16, NULL, NULL, 100, 1000, '20240202 10:00:00', '20240205 10:00:00'
EXEC ModifyOrderDetails 74, 'Webinar', 401, 50, '20240205 10:00:00', NULL, NULL, NULL, NULL
EXEC ModifyOrderDetails 74, 'StudyMeeting', 101, 500, '20240205 10:00:00', NULL, NULL, NULL, NULL

SELECT * FROM dbo.GenerateOrderInfo(74)
SELECT dbo.GetOrderValue(74)


-- RESET

DELETE FROM WebinarOrders WHERE OrderID > 73;
DELETE FROM CourseOrders WHERE OrderID > 73;
DELETE FROM StudyOrders WHERE OrderID > 73;
DELETE FROM StudyMeetingOrders WHERE OrderID > 73;
DELETE FROM Orders WHERE OrderID > 73;

DBCC CHECKIDENT ('Orders', RESEED, 73);