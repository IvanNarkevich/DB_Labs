USE AdventureWorks2012;
GO

/*
	Вывести значения полей [FirstName], [LastName] из таблицы [Person].[Person]
	и полей [ModifiedDate] и [BusinessEntityID] из таблицы [Person].[Password] в виде xml, 
	сохраненного в переменную. Вывести только первые 100 записи из таблицы.
*/

DECLARE @XMLPerson XML = (
	SELECT TOP 100 
	p.FirstName, 
	p.LastName, 
	pass.ModifiedDate AS 'Password/Date',
	pass.BusinessEntityID AS 'Password/ID'
	FROM Person.Person p
	JOIN Person.Password pass ON p.BusinessEntityID = pass.BusinessEntityID
	FOR XML PATH('Person'), ROOT('Persons')
)

SELECT @XMLPerson;
GO

/*
	Создать хранимую процедуру, возвращающую таблицу, состоящую из 1 колонки и заполняет её xml, 
	содержащимся в тегах Password. Вызвать эту процедуру для заполненной на первом шаге переменной.
*/

CREATE PROCEDURE Person.GetXMLPassword ( @XMLPerson XML)
AS
BEGIN
	SELECT p.query('.') AS [sql]
	FROM @XMLPerson.nodes('/Persons/Person/Password') AS T(p)
RETURN
END;
GO

/*
	Вывод
*/

DECLARE @XMLPerson XML = (
	SELECT TOP 100 
	p.FirstName, 
	p.LastName, 
	pass.ModifiedDate AS 'Password/Date',
	pass.BusinessEntityID AS 'Password/ID'
	FROM Person.Person p
	JOIN Person.Password pass ON p.BusinessEntityID = pass.BusinessEntityID
	FOR XML PATH('Person'), ROOT('Persons')
)

EXECUTE Person.GetXMLPassword @XMLPerson;
GO