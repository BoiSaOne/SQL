# SQL
### Задача 2
```
SELECT YEAR(Sales.OrderDate) AS Year, MONTH(Sales.OrderDate) AS Month, SUM(Sales.TotalDue) AS Sum FROM Sales.SalesOrderHeader AS Sales
WHERE Sales.Status = 5
GROUP BY YEAR(Sales.OrderDate), MONTH(Sales.OrderDate)
ORDER BY Year, Month, Sum;
```
### Задача 3
```
SELECT TOP 10 City.City AS Город, COUNT(Person.CustomerID) AS Приоритет FROM (SELECT DISTINCT City FROM Person.Address
WHERE NOT City IN (SELECT DISTINCT City FROM Sales.vStoreWithAddresses)) City
LEFT JOIN (SELECT DISTINCT Customer.CustomerID, Address.City FROM Person.Person
INNER JOIN Sales.Customer ON Customer.PersonID = Person.BusinessEntityID
INNER JOIN Person.BusinessEntity ON BusinessEntity.BusinessEntityID = Person.BusinessEntityID
INNER JOIN Person.BusinessEntityAddress ON BusinessEntityAddress.BusinessEntityID = BusinessEntity.BusinessEntityID
INNER JOIN Person.Address ON Address.AddressID = BusinessEntityAddress.AddressID) Person 
ON Person.City = City.City
GROUP BY City.City
ORDER BY COUNT(Person.CustomerID) DESC
```
### Задача 4
```
SELECT Person.LastName AS 'Фамилия покупателя', Person.FirstName AS 'Имя покупателя', Product.Name 'Название продукта', SUM(SalesOrderDetail.OrderQty) 'Количество купленных экземпляров' FROM Person.Person
INNER JOIN Sales.Customer ON Customer.PersonID = Person.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader ON SalesOrderHeader.CustomerID = Customer.CustomerID
INNER JOIN Sales.SalesOrderDetail ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
LEFT JOIN Production.Product ON Product.ProductID = SalesOrderDetail.ProductID
GROUP BY Person.LastName, Person.FirstName, Product.Name
HAVING SUM(SalesOrderDetail.OrderQty) > 15
ORDER BY SUM(SalesOrderDetail.OrderQty) DESC, CONCAT(Person.LastName, ' ', Person.FirstName)
```
### Задача 5
```
SELECT SalesOrderHeader.OrderDate AS 'Дата заказа', Person.LastName AS 'Фамилия покупателя', Person.FirstName AS 'Имя покупателя', STRING_AGG (CONVERT(NVARCHAR(max), CONCAT(Product.Name, N' Количество: ', SalesOrderDetail.OrderQty, N' шт.')), CHAR(13)) AS 'Содержимое заказа' FROM 
(SELECT SalesOrderHeader.CustomerID, SalesOrderHeader.OrderDate, MIN(SalesOrderHeader.SalesOrderID) AS SalesOrderID FROM 
(SELECT CustomerID, MIN(OrderDate) AS MinOrderDate FROM Sales.SalesOrderHeader
GROUP BY CustomerID) AS MinOrderDateCustomer 
INNER JOIN Sales.SalesOrderHeader ON SalesOrderHeader.CustomerID = MinOrderDateCustomer.CustomerID 
AND SalesOrderHeader.OrderDate = MinOrderDateCustomer.MinOrderDate
GROUP BY SalesOrderHeader.CustomerID, SalesOrderHeader.OrderDate) SalesOrderHeader
INNER JOIN Sales.Customer ON Customer.CustomerID = SalesOrderHeader.CustomerID
INNER JOIN Person.Person ON Person.BusinessEntityID = Customer.PersonID
INNER JOIN Sales.SalesOrderDetail ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
LEFT JOIN Production.Product ON Product.ProductID = SalesOrderDetail.ProductID
GROUP BY SalesOrderHeader.OrderDate, Person.LastName, Person.FirstName
ORDER BY SalesOrderHeader.OrderDate DESC
```
### Задача 6
```
;WITH Recursives AS (SELECT BusinessEntityID, OrganizationLevel, BirthDate, HireDate, FIO, BirthDate AS BirthDateDirector, HireDate AS HireDateDirector, FIO AS FIODirector FROM 
(SELECT Employee.BusinessEntityID, OrganizationLevel, BirthDate, HireDate, CONCAT(Person.FirstName, ' ', LEFT(Person.LastName, 1), '.', LEFT(Person.MiddleName, 1), '.') AS FIO FROM HumanResources.Employee
INNER JOIN Person.Person ON Person.BusinessEntityID = Employee.BusinessEntityID) AS Employee
WHERE OrganizationLevel IS NULL
UNION ALL
SELECT T.BusinessEntityID, T.OrganizationLevel, T.BirthDate, T.HireDate, T.FIO, R.BirthDate, R.HireDate, R.FIO FROM (SELECT Employee.BusinessEntityID, OrganizationLevel, BirthDate, HireDate, CONCAT(Person.FirstName, ' ', LEFT(Person.LastName, 1), '.', LEFT(Person.MiddleName, 1), '.') AS FIO FROM HumanResources.Employee
INNER JOIN Person.Person ON Person.BusinessEntityID = Employee.BusinessEntityID) AS T 
INNER JOIN Recursives AS R ON T.OrganizationLevel = R.BusinessEntityID)
SELECT FIODirector AS 'Имя руководителя', HireDateDirector AS 'Дата приема руководителя на работу', BirthDateDirector AS 'Дата рождения руководителя',
FIO AS 'Имя сотрудника', HireDate AS 'Дата приема сотрудника на работу', BirthDate AS 'Дата рождения сотрудника' FROM Recursives
WHERE HireDateDirector > HireDate AND BirthDateDirector > BirthDate
ORDER BY OrganizationLevel, FIODirector, FIO
GO
```
### Задача 7
```
CREATE PROCEDURE SingleMen (
	@startDate AS date,
	@endDate AS date,
	@count AS int OUTPUT
)
AS
SELECT @count = COUNT(*) FROM HumanResources.Employee
WHERE Gender = 'M' AND MaritalStatus = 'S' AND @startDate <= BirthDate AND BirthDate <= @endDate
GO

--Пример
DECLARE @startDate date, @endDate date, @count int
SET @startDate = DATEFROMPARTS(1983, 1, 1) 
SET @endDate = DATEFROMPARTS(1984, 8, 16)
EXEC SingleMen @startDate, @endDate, @count OUTPUT
PRINT N'Количество найденных записей: ' + CONVERT(VARCHAR, @count)

DROP PROCEDURE SingleMen
```