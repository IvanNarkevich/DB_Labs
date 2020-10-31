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

