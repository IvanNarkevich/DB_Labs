USE AdventureWorks2012;
GO

/*
	Создайте представление VIEW, отображающее данные из таблиц Sales.SalesReason и Sales.SalesOrderHeaderSalesReason, 
	а также CustomerID из таблицы Sales.SalesOrderHeader. Создайте уникальный кластерный индекс в представлении по полям SalesReasonID, SalesOrderID.
*/

CREATE VIEW Sales.vSalesOrderReason
WITH SCHEMABINDING AS
SELECT 
    SOHSR.SalesOrderID, 
	SOHSR.SalesReasonID, 
	SR.Name, 
	SR.ReasonType, 
	SOH.CustomerID
FROM Sales.SalesOrderHeaderSalesReason AS SOHSR
INNER JOIN Sales.SalesReason AS SR
    ON (SR.SalesReasonID = SOHSR.SalesReasonID)
INNER JOIN Sales.SalesOrderHeader AS SOH
    ON (SOH.SalesOrderID = SOHSR.SalesOrderID);
GO

CREATE UNIQUE CLUSTERED INDEX UCIndex_vSalesOrderReason
	ON Sales.vSalesOrderReason (SalesReasonID, SalesOrderID);
GO

/*
	Создайте один INSTEAD OF триггер для представления на три операции INSERT, UPDATE, DELETE. 
	Триггер должен выполнять соответствующие операции в таблицах Sales.SalesReason и Sales.SalesOrderHeaderSalesReason 
	для указанного CustomerID. Обновление не должно происходить в таблице Sales.SalesOrderHeaderSalesReason. 
	Удаление из таблицы Sales.SalesReason производите только в том случае, если удаляемые строки больше не ссылаются на Sales.SalesOrderHeaderSalesReason.
*/

CREATE TRIGGER TRG_vSalesOrderReason
ON Sales.vSalesOrderReason
INSTEAD OF UPDATE, INSERT, DELETE
AS
BEGIN
	IF EXISTS(SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
	BEGIN
		UPDATE Sales.SalesReason
		SET
		Name = I.Name,
		ReasonType = I.ReasonType,
		ModifiedDate = GETDATE()
		FROM Sales.SalesReason AS SR
		INNER JOIN inserted AS I
			ON I.SalesReasonId = SR.SalesReasonId    
	END

	ELSE IF EXISTS(SELECT * FROM inserted)
	BEGIN
		IF NOT EXISTS(
			SELECT * FROM Sales.SalesReason AS SR
			JOIN inserted ON inserted.SalesReasonID = SR.SalesReasonID
			WHERE SR.SalesReasonID = inserted.SalesReasonID)
		BEGIN
			INSERT INTO Sales.SalesReason (Name, ReasonType, ModifiedDate)
			SELECT Name, ReasonType, GETDATE()
			FROM inserted
		END
		ELSE
		BEGIN
			UPDATE Sales.SalesReason
			SET
			Name = I.Name,
			ReasonType = I.ReasonType,
			ModifiedDate = GETDATE()
			FROM inserted AS I
			WHERE Sales.SalesReason.SalesReasonId = I.SalesReasonId
		END
		INSERT INTO Sales.SalesOrderHeaderSalesReason (SalesOrderId, SalesReasonID, ModifiedDate)
		SELECT I.SalesOrderID, I.SalesReasonID, GETDATE()
		FROM inserted AS I
	END

	ELSE IF EXISTS (SELECT * FROM deleted)
	BEGIN
		DELETE FROM Sales.SalesOrderHeaderSalesReason
		WHERE SalesOrderID IN (SELECT SalesOrderID FROM deleted)
			AND SalesReasonID IN (SELECT SalesReasonId FROM deleted)

		DELETE FROM Sales.SalesReason 
		WHERE SalesReasonId = (SELECT SalesReasonId FROM deleted)
			AND SalesReasonId NOT IN (SELECT SalesReasonId FROM Sales.SalesOrderHeaderSalesReason)
	END;
END;
GO

/*
	Вставьте новую строку в представление, указав новые данные SalesReason для существующего CustomerID (например для 11000). 
	Триггер должен добавить новые строки в таблицы Sales.SalesReason и Sales.SalesOrderHeaderSalesReason. 
	Обновите вставленные строки через представление. Удалите строки.
*/

INSERT INTO Sales.vSalesOrderReason (
	SalesOrderID, 
	SalesReasonID, 
	Name, 
	ReasonType, 
	CustomerID)
VALUES (
	57418, 
	6, 
	'New name', 
	'New Type', 
	11000);


UPDATE Sales.vSalesOrderReason 
SET Name = 'Review', 
	ReasonType = 'Other'
WHERE SalesOrderID = 57418
    AND SalesReasonID = 6
	AND CustomerID = 11000

DELETE FROM Sales.vSalesOrderReason 
WHERE SalesOrderID = 57418
    AND SalesReasonID = 6
	AND CustomerID = 11000
