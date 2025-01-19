CREATE TRIGGER dbo.trg_AddStudentToStudentList
    ON dbo.StudyOrders
    AFTER INSERT
    AS
BEGIN
    IF EXISTS (SELECT UserID
               FROM INSERTED i
                        INNER JOIN StudyOrders so
                                   ON i.OrderID = so.OrderID
                        INNER JOIN Orders o
                                   ON o.OrderID = so.OrderID
               WHERE UserID IN (SELECT DISTINCT UserID
                                FROM INSERTED i
                                         INNER JOIN StudentLists sl
                                                    ON i.StudyID = sl.UserID))
        THROW 50050, 'User with given ID is already assigned to the given studies', 20
    ELSE
        BEGIN
            DECLARE @StudentID int;
            SELECT @StudentID = o.UserID
            FROM INSERTED i
                     INNER JOIN StudyOrders so
                                ON i.OrderID = so.OrderID
                     INNER JOIN Orders o
                                ON o.OrderID = so.OrderID;

            INSERT INTO StudentLists(StudyID, UserID)
            SELECT i.StudyID, @StudentID
            FROM inserted i;
        END
END;