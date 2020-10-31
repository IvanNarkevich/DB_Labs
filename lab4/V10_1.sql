USE AdventureWorks2012;

/*
	Создайте таблицу Sales.SalesReasonHst, которая будет хранить информацию об изменениях в таблице Sales.SalesReason.
	Обязательные поля, которые должны присутствовать в таблице: 
	ID — первичный ключ IDENTITY(1,1); 
	Action — совершенное действие (insert, update или delete); 
	ModifiedDate — дата и время, когда была совершена операция; 
	SourceID — первичный ключ исходной таблицы; 
	UserName — имя пользователя, совершившего операцию. 
	Создайте другие поля, если считаете их нужными.
*/

CREATE TABLE Sales.SalesReasonHst (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Action NVARCHAR(20) NOT NULL,
    ModifiedDate DATETIME NOT NULL,
    SourceID INT NOT NULL,
    UserName NVARCHAR(120) NOT NULL
);
GO

/*
	 Создайте три AFTER триггера для трех операций INSERT, UPDATE, DELETE для таблицы Sales.SalesReason. 
	 Каждый триггер должен заполнять таблицу Sales.SalesReasonHst с указанием типа операции в поле Action.
*/

CREATE TRIGGER TRG_SalesReason_AfterInsert
ON Sales.SalesReason
AFTER INSERT AS
BEGIN
    INSERT INTO Sales.SalesReasonHst (
	        Action,
			ModifiedDate,
			SourceID,
			UserName)
    SELECT 
			'INSERT', 
			CURRENT_TIMESTAMP, 
			SalesReasonID, 
			CURRENT_USER
    FROM inserted;
END
GO

CREATE TRIGGER TRG_SalesReason_AfterUpdate
ON Sales.SalesReason
AFTER UPDATE AS
BEGIN
    INSERT INTO Sales.SalesReasonHst (
	        Action,
			ModifiedDate,
			SourceID,
			UserName)
    SELECT
            'UPDATE', 
			CURRENT_TIMESTAMP, 
			SalesReasonID, 
			CURRENT_USER
	FROM inserted;
END
GO

CREATE TRIGGER TRG_SalesReason_AfterDelete
ON Sales.SalesReason
AFTER DELETE AS
BEGIN
    INSERT INTO Sales.SalesReasonHst (
            Action,
			ModifiedDate,
			SourceID,
			UserName)
    SELECT 
    	    'DELETE', 
			CURRENT_TIMESTAMP, 
			SalesReasonID, 
			CURRENT_USER
	FROM deleted;
END
GO

/*
	 Создайте представление VIEW, отображающее все поля таблицы Sales.SalesReason. 
	 Сделайте невозможным просмотр исходного кода представления.
*/

CREATE VIEW Sales.vSalesReason 
WITH ENCRYPTION AS
	SELECT * 
	FROM Sales.SalesReason;
GO

/*
	Вставьте новую строку в Sales.SalesReason через представление. Обновите вставленную строку. 
	Удалите вставленную строку. Убедитесь, что все три операции отображены в Sales.SalesReasonHst.
*/

INSERT INTO Sales.vSalesReason (
	Name, 
	ReasonType, 
	ModifiedDate)
VALUES (
	'MyName', 
	'Other', 
	CURRENT_TIMESTAMP);
GO

UPDATE Sales.vSalesReason 
SET Name = 'Name'
WHERE Name = 'MyName';
GO

DELETE FROM Sales.vSalesReason
WHERE Name = 'Name';
GO

SELECT *
FROM Sales.SalesReasonHst;
