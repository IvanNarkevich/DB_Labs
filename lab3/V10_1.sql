USE AdventureWorks2012;

/*
	добавьте в таблицу dbo.Employee поле Name типа nvarchar размерностью 60 символов;
*/

ALTER TABLE dbo.Employee ADD Name NVARCHAR(60);
GO

/*
	объявите табличную переменную с такой же структурой как dbo.Employee
	и заполните ее данными из dbo.Employee. Поле Name заполните данными таблицы Person.Person,
	из полей Title и FirstName. Если Title содержит null значение, замените его на ‘M.’;
*/

DECLARE @Employee TABLE
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
	ID BIGINT PRIMARY KEY NOT NULL,   
	Name NVARCHAR(60) NULL);
INSERT INTO @Employee(
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
	Name
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
	CONCAT( (CASE WHEN p.Title IS NULL THEN 'M.' ELSE p.Title END ), p.FirstName)
FROM dbo.Employee as e
	INNER JOIN Person.Person as p ON p.BusinessEntityID = e.BusinessEntityID;

/*
	обновите поле Name в dbo.Employee данными из табличной переменной;
*/

UPDATE dbo.Employee
SET dbo.Employee.Name = eVar.Name
FROM dbo.Employee AS e
INNER JOIN @Employee eVar ON  e.BusinessEntityID = eVar.BusinessEntityID;

/*
	удалите из dbo.Employee сотрудников, которые хотя бы раз меняли отдел (таблица HumanResources.EmployeeDepartmentHistory);	
*/

DELETE FROM dbo.Employee
WHERE EXISTS
(
    SELECT DISTINCT BusinessEntityID
    FROM HumanResources.EmployeeDepartmentHistory AS edh
    WHERE edh.BusinessEntityID = dbo.Employee.BusinessEntityID and edh.EndDate IS NOT NULL
); 

/*
	удалите поле Name из таблицы, удалите все созданные ограничения и значения по умолчанию.
	Имена значений по умолчанию найдите самостоятельно, приведите код, которым пользовались для поиска;
*/

ALTER TABLE dbo.Employee
	DROP COLUMN Name;
GO

/*SELECT * FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
	WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Employee';

SELECT *, OBJECT_NAME(parent_column_id) FROM AdventureWorks2012.sys.default_constraints
	WHERE SCHEMA_NAME(schema_id) = 'dbo' and OBJECT_NAME(parent_object_id) = 'Employee';*/

ALTER TABLE dbo.Employee
DROP CONSTRAINT birth_date_check;
GO

ALTER TABLE dbo.Employee
DROP CONSTRAINT default_hire_date;
GO

/*
	удалите таблицу dbo.Employee.
*/

DROP TABLE dbo.Employee;
GO