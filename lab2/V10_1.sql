USE AdventureWorks2012;
GO

/*
	Вывести на экран почасовую ставку каждого сотрудника, округленную до целого числа.
*/

SELECT Employee.BusinessEntityID, JobTitle, ROUND(Rate, 0) AS RoundRate
FROM HumanResources.Employee
INNER JOIN HumanResources.EmployeePayHistory 
ON Employee.BusinessEntityID = EmployeePayHistory.BusinessEntityID;
GO

/*
	Вывести на экран порядковый номер изменения почасовой ставки для каждого сотрудника по дате изменения ставки.
*/

SELECT 
	Employee.BusinessEntityID, 
	JobTitle, 
	Rate, 
	ROW_NUMBER() OVER(PARTITION BY Employee.BusinessEntityID ORDER BY RateChangeDate ASC) AS ChangeNumber
FROM HumanResources.Employee
INNER JOIN HumanResources.EmployeePayHistory 
ON Employee.BusinessEntityID = EmployeePayHistory.BusinessEntityID;
GO

/*
	Вывести на экран информацию об отделах и работающих в них сотрудниках, отсортированную по полю JobTitle, 
	а затем по полю HireDate в порядке убывания (если JobTitle сотрудника содержит одно слово) 
	или по полю BirthDate в порядке убывания (если JobTitle сотрудника содержит несколько слов).
*/

SELECT Name, JobTitle, HireDate, BirthDate
FROM HumanResources.Department 
INNER JOIN HumanResources.EmployeeDepartmentHistory 
	ON Department.DepartmentID = EmployeeDepartmentHistory.DepartmentID
INNER JOIN HumanResources.Employee 
	ON EmployeeDepartmentHistory.BusinessEntityID = Employee.BusinessEntityID
ORDER BY JobTitle ASC, 
	CASE CHARINDEX(' ', LTRIM(RTRIM(JobTitle)))
		WHEN 0 THEN HireDate
		ELSE BirthDate END DESC; 
GO