USE AdventureWorks2012;
GO

/*
	Вывести на экран количество сотрудников, позиция которых в организации соответствует 3-ему уровню (OrganizationLevel).
*/

SELECT COUNT(OrganizationLevel) as EmpCount
FROM HumanResources.Employee
WHERE OrganizationLevel = 3;
GO

/*
	Вывести на экран список неповторяющихся названий групп отделов из таблицы Department.
*/

SELECT DISTINCT Groupname
FROM HumanResources.Department;
GO

/*
	Вывести на экран список неповторяющихся должностей в порядке A-Z. 
	Вывести только первые 10 названий. Добавить столбец, в котором вывести последнее слово из поля [JobTitle].
*/ 

SELECT DISTINCT TOP 10 JobTitle, 
	RIGHT(RTRIM(JobTitle), CHARINDEX(' ', REVERSE(RTRIM(JobTitle)) + ' ') - 1) AS LastWord
FROM HumanResources.Employee
ORDER BY JobTitle ASC;
GO
