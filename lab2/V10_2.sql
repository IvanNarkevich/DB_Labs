USE AdventureWorks2012;
GO

/*
	создайте таблицу dbo.Employee с такой же структурой как HumanResources.Employee, 
	кроме полей OrganizationLevel, SalariedFlag, CurrentFlag, 
	а также кроме полей с типом hierarchyid, uniqueidentifier, не включая индексы, ограничения и триггеры;
*/

CREATE TABLE dbo.Employee(
	BusinessEntityID	INT NOT NULL,
	NationalIDNumber	NVARCHAR(15) NOT NULL,
	LoginID	NVARCHAR(256) NOT NULL,
	JobTitle	NVARCHAR(50) NOT NULL,
	BirthDate	DATE NOT NULL,
	MaritalStatus	NCHAR(1) NOT NULL,
	Gender	NCHAR(1) NOT NULL,
	HireDate	DATE NOT NULL,
	VacationHours	SMALLINT NOT NULL,
	SickLeaveHours	SMALLINT NOT NULL,
	ModifiedDate	DATETIME NOT NULL
);
GO

/*
	используя инструкцию ALTER TABLE, добавьте в таблицу dbo.Employee новое поле ID, 
	которое является первичным ключом типа bigint и имеет свойство identity. 
	Начальное значение для поля identity задайте 0 и приращение задайте 2;
*/

ALTER TABLE dbo.Employee
	ADD ID BIGINT PRIMARY KEY IDENTITY (0, 2);
GO

/*
	используя инструкцию ALTER TABLE, создайте для таблицы dbo.Employee ограничение для поля BirthDate, 
	запрещающее заполнение поля датами ранее 1900 года и позже текущей даты;
*/

ALTER TABLE dbo.Employee
	ADD CONSTRAINT birth_date_check 
	CHECK (BirthDate >= CONVERT(DATE,'1900-01-01', 23) and BirthDate <= CONVERT(DATE, GETDATE()));	
GO

/*
	используя инструкцию ALTER TABLE, создайте для таблицы dbo.Employee 
	ограничение DEFAULT для поля HireDate, задайте значение по умолчанию текущую дату;
*/

ALTER TABLE dbo.Employee
	ADD CONSTRAINT default_hire_date DEFAULT CONVERT(DATE, GETDATE()) FOR HireDate;
GO

/*
	заполните новую таблицу данными из HumanResources.Employee только для тех сотрудников, 
	у которых EmailPromotion = 0 в таблице Person.Person. Поле HireDate заполните значениями по умолчанию;
*/

INSERT INTO dbo.Employee (	
	BusinessEntityID,
	NationalIDNumber,
	LoginID,
	JobTitle,
	BirthDate,
	MaritalStatus,
	Gender,
	VacationHours,
	SickLeaveHours,
	ModifiedDate)
(SELECT 
	Employee.BusinessEntityID,
	Employee.NationalIDNumber,
	Employee.LoginID,
	Employee.JobTitle,
	Employee.BirthDate,
	Employee.MaritalStatus,
	Employee.Gender,
	Employee.VacationHours,
	Employee.SickLeaveHours,
	Employee.ModifiedDate 
FROM HumanResources.Employee  
INNER JOIN Person.Person  on Employee.BusinessEntityID = Person.BusinessEntityID  
WHERE Person.EmailPromotion = 0);
GO

/*
	измените тип поля MaritalStatus на NVARCHAR(1) и разрешите добавление null значений для него.
*/

ALTER TABLE dbo.Employee
	ALTER COLUMN MaritalStatus NVARCHAR(1) NULL;
GO