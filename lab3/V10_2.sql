USE AdventureWorks2012;

/*
	выполните код, созданный во втором задании второй лабораторной работы. 
	Добавьте в таблицу dbo.Employee поле SumSubTotal MONEY. 
	Также создайте в таблице вычисляемое поле LeaveHours, 
	вычисляющее сумму часов отпуска и больничных в полях VacationHours и SickLeaveHours
*/

ALTER TABLE dbo.Employee
ADD
	SumSubTotal MONEY,
	LeaveHours AS (VacationHours + SickLeaveHours);
GO

/*
	создайте временную таблицу #Employee, с первичным ключом по полю ID. 
	Временная таблица должна включать все поля таблицы dbo.Employee за исключением поля LeaveHours
*/

CREATE TABLE #Employee
(
	BusinessEntityID INT NOT NULL,   
	NationalIDNumber NVARCHAR(15) NOT NULL,   
	LoginID NVARCHAR(256) NOT NULL,   
	JobTitle NVARCHAR(50) NOT NULL,   
	BirthDate DATE NOT NULL,   
	MaritalStatus NVARCHAR(1) NULL,   
	Gender NCHAR(1) NOT NULL,   
	HireDate DATE NOT NULL,   
	VacationHours SMALLINT NOT NULL,   
	SickLeaveHours SMALLINT NOT NULL,   
	ModifiedDate DATETIME NOT NULL,   
	ID BIGINT NOT NULL PRIMARY KEY,   
	SumSubTotal MONEY NULL);
GO

/*
	заполните временную таблицу данными из dbo.Employee. 
	Посчитайте общую сумму без учета налогов и стоимости доставки (SubTotal), 
	на которую сотрудник (EmployeeID) оформил заказов в таблице Purchasing.PurchaseOrderHeader 
	и заполните этими значениями поле SumSubTotal. Подсчет суммы осуществите в Common Table Expression (CTE)
*/

WITH SumSubTotal_CTE(EmployeeID, SumSubTotal) AS(
	SELECT EmployeeID, SUM(SubTotal) 
	FROM Purchasing.PurchaseOrderHeader
	GROUP BY EmployeeID
)
INSERT INTO #Employee(
	BusinessEntityID,
	NationalIDNumber,
	LoginID,
	JobTitle,
	BirthDate,
	MaritalStatus,
	Gender,
	HireDate,
	VacationHours,
	SickLeaveHours,
	ModifiedDate,
    ID,
	SumSubTotal
)
SELECT
	e.BusinessEntityID,
	e.NationalIDNumber,
	e.LoginID,
	e.JobTitle,
	e.BirthDate,
	e.MaritalStatus,
	e.Gender,
	e.HireDate,
	e.VacationHours,
	e.SickLeaveHours,
	e.ModifiedDate,
	e.ID,
	cte.SumSubTotal
FROM 
	dbo.Employee e
LEFT JOIN SumSubTotal_CTE AS cte ON e.BusinessEntityID = cte.EmployeeID;

/*
	удалите из таблицы dbo.Employee строки, где LeaveHours > 160
*/

DELETE FROM dbo.Employee WHERE LeaveHours > 160;
GO

/*
	напишите Merge выражение, использующее dbo.Employee как target, 
	а временную таблицу как source. Для связи target и source используйте ID. 
	Обновите поле SumSubTotal, если запись присутствует в source и target. 
	Если строка присутствует во временной таблице, но не существует в target, 
	добавьте строку в dbo.Employee. Если в dbo.Employee присутствует такая строка, 
	которой не существует во временной таблице, удалите строку из dbo.Employee
*/

SET IDENTITY_INSERT dbo.Employee ON;
GO

MERGE
    dbo.Employee AS trg
	USING #Employee AS src
	ON (trg.ID = src.ID)
WHEN MATCHED THEN
    UPDATE 
	SET trg.SumSubTotal  = src.SumSubTotal
WHEN NOT MATCHED BY TARGET THEN
	INSERT(
		BusinessEntityID,
		NationalIDNumber,
		LoginID,
		JobTitle,
		BirthDate,
		MaritalStatus,
		Gender,
		HireDate,
		VacationHours,
		SickLeaveHours,
		ModifiedDate,
		ID,
		SumSubTotal	)
	VALUES(
		BusinessEntityID,
		NationalIDNumber,
		LoginID,
		JobTitle,
		BirthDate,
		MaritalStatus,
		Gender,
		HireDate,
		VacationHours,
		SickLeaveHours,
		ModifiedDate,
		ID,
		SumSubTotal	)
WHEN NOT MATCHED BY SOURCE THEN 
	DELETE;

SET IDENTITY_INSERT dbo.Employee OFF;
GO