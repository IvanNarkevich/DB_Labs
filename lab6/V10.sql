USE AdventureWorks2012;
GO

/*
	Создайте хранимую процедуру, которая будет возвращать сводную таблицу (оператор PIVOT), 
	отображающую данные об итоговой сумме продаж за каждый год (Sales.SalesOrderHeader.OrderDate) 
	по определенному региону (Sales.SalesTerritory.CountryRegionCode). 
	Список регионов передайте в процедуру через входной параметр.

	Таким образом, вызов процедуры будет выглядеть следующим образом:

	EXECUTE dbo.SalesByRegions ‘[AU],[CA],[DE],[FR],[GB],[US]’
*/

CREATE PROCEDURE dbo.SalesByRegions (@Regions NVARCHAR(500)) AS
BEGIN
	DECLARE @SQL NVARCHAR(1000);
	SET @SQL = 	'SELECT OrderYear, ' + @Regions + '
		FROM
		(
			SELECT YEAR(sho.OrderDate) as OrderYear, TotalDue, CountryRegionCode
			FROM Sales.SalesOrderHeader sho
			JOIN Sales.SalesTerritory st ON sho.TerritoryID = st.TerritoryID
		) AS p1 
		PIVOT
		(
			SUM(TotalDue)
			FOR CountryRegionCode IN (' + @Regions + ')
		) AS p2;';
	EXECUTE (@SQL);
	RETURN;
END;
GO

EXECUTE dbo.SalesByRegions '[AU],[CA],[DE],[FR],[GB],[US]';
GO