USE AdventureWorks2012;
GO

/*
	Создайте scalar-valued функцию, которая будет принимать в качестве входного параметра id 
	для типа телефонного номера (Person.PhoneNumberType.PhoneNumberTypeID) и 
	возвращать количество телефонов указанного типа (Person.PersonPhone)
*/	

CREATE FUNCTION Person.GetPhoneCountByType(@PhoneNumberTypeID INT)  
RETURNS INT AS 
BEGIN
	DECLARE @Count INT
	SELECT @Count = COUNT(DISTINCT PhoneNumber)
	FROM Person.PersonPhone
	WHERE PhoneNumberTypeID = @PhoneNumberTypeID

	RETURN @Count;
END;
GO

PRINT Person.GetPhoneCountByType(1);
GO

SELECT COUNT(DISTINCT PhoneNumber)
FROM Person.PersonPhone
WHERE PhoneNumberTypeID = 1;
GO

/*
	Создайте inline table-valued функцию, которая будет принимать в качестве входного параметра id 
	для типа телефонного номера (Person.PhoneNumberType.PhoneNumberTypeID), 
	а возвращать список сотрудников из Person.Person (сотрудники обозначены как PersonType = ‘EM’), 
	телефонный номер которых принадлежит к указанному типу
*/

CREATE FUNCTION Person.GetPersonsListByPhoneNumberType(@PhoneNumberTypeID INT)
RETURNS TABLE AS
RETURN (
	SELECT p.BusinessEntityID, p.FirstName, p.MiddleName, p.LastName
	FROM Person.Person p
	JOIN Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID
	WHERE pp.PhoneNumberTypeID = @PhoneNumberTypeID AND p.PersonType = 'EM'
);
GO

SELECT *
	FROM Person.GetPersonsListByPhoneNumberType(1);
GO
/*
	Вызовите функцию для каждого типа телефонного номера, применив оператор CROSS APPLY. 
*/

SELECT pnt.PhoneNumberTypeID, f.BusinessEntityID, f.FirstName, f.MiddleName, f.LastName
FROM Person.PhoneNumberType pnt
CROSS APPLY Person.GetPersonsListByPhoneNumberType(pnt.PhoneNumberTypeID) f
ORDER BY pnt.PhoneNumberTypeID;
GO

/*
	Вызовите функцию для каждого типа телефонного номера, применив оператор OUTER APPLY
*/

SELECT pnt.PhoneNumberTypeID, f.BusinessEntityID, f.FirstName, f.MiddleName, f.LastName
FROM Person.PhoneNumberType pnt
OUTER APPLY Person.GetPersonsListByPhoneNumberType(pnt.PhoneNumberTypeID) f
ORDER BY pnt.PhoneNumberTypeID;
GO

/*
	Измените созданную inline table-valued функцию, сделав ее multistatement table-valued 
	(предварительно сохранив для проверки код создания inline table-valued функции)
*/

CREATE FUNCTION Person.GetPersonsListByPhoneNumberTypeNew(@PhoneNumberTypeID INT)
RETURNS @persons TABLE(
	BusinessEntityID INT,
	FirstName NVARCHAR(200),
	MiddleName NVARCHAR(200),
	LastName NVARCHAR(200)
) 
AS
BEGIN
	INSERT INTO @persons (BusinessEntityID, FirstName, MiddleName, LastName)
	SELECT p.BusinessEntityID, p.FirstName, p.MiddleName, p.LastName
	FROM Person.Person p
	JOIN Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID
	WHERE pp.PhoneNumberTypeID = @PhoneNumberTypeID AND P.PersonType = 'EM';
	RETURN;
END;
GO

SELECT  * FROM  Person.GetPersonsListByPhoneNumberTypeNew(1);
GO

