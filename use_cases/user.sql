EXEC AddUser
     128,
     'Karol',
     'Wojtyla',
     'karolek2137@gmail.com',
     'eeeeeeee',
     '+48692137420',
     'ul. kremuwkowa 6',
     '92137'


-- RESET

DELETE
FROM Users
WHERE UserID > 200
DBCC CHECKIDENT ('Users', RESEED, 200);
