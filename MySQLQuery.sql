use AdventureWorks2017;
GO

--������ 2
SELECT YEAR(Sales.OrderDate) AS Year, MONTH(Sales.OrderDate) AS Month, SUM(Sales.TotalDue) AS Sum FROM Sales.SalesOrderHeader AS Sales
WHERE Sales.Status = 5
GROUP BY YEAR(Sales.OrderDate), MONTH(Sales.OrderDate)
ORDER BY Year, Month, Sum;

--������ 3
SELECT TOP 10 City.City AS �����, COUNT(Person.CustomerID) AS ��������� FROM (SELECT DISTINCT City FROM Person.Address
WHERE NOT City IN (SELECT DISTINCT City FROM Sales.vStoreWithAddresses)) City
LEFT JOIN (SELECT DISTINCT Customer.CustomerID, Address.City FROM Person.Person
INNER JOIN Sales.Customer ON Customer.PersonID = Person.BusinessEntityID
INNER JOIN Person.BusinessEntity ON BusinessEntity.BusinessEntityID = Person.BusinessEntityID
INNER JOIN Person.BusinessEntityAddress ON BusinessEntityAddress.BusinessEntityID = BusinessEntity.BusinessEntityID
INNER JOIN Person.Address ON Address.AddressID = BusinessEntityAddress.AddressID) Person 
ON Person.City = City.City
GROUP BY City.City
ORDER BY COUNT(Person.CustomerID) DESC

--������ 4
SELECT Person.LastName AS '������� ����������', Person.FirstName AS '��� ����������', Product.Name '�������� ��������', SUM(SalesOrderDetail.OrderQty) '���������� ��������� �����������' FROM Person.Person
INNER JOIN Sales.Customer ON Customer.PersonID = Person.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader ON SalesOrderHeader.CustomerID = Customer.CustomerID
INNER JOIN Sales.SalesOrderDetail ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
LEFT JOIN Production.Product ON Product.ProductID = SalesOrderDetail.ProductID
GROUP BY Person.LastName, Person.FirstName, Product.Name
HAVING SUM(SalesOrderDetail.OrderQty) > 15
ORDER BY SUM(SalesOrderDetail.OrderQty) DESC, CONCAT(Person.LastName, ' ', Person.FirstName)

--������ 5
SELECT SalesOrderHeader.OrderDate AS '���� ������', Person.LastName AS '������� ����������', Person.FirstName AS '��� ����������', STRING_AGG (CONVERT(NVARCHAR(max), CONCAT(Product.Name, N' ����������: ', SalesOrderDetail.OrderQty, N' ��.')), CHAR(13)) AS '���������� ������' FROM 
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

--������ 6
SELECT FIODirector AS '��� ������������', HireDateDirector AS '���� ������ ������������ �� ������', BirthDateDirector AS '���� �������� ������������',
FIO AS '��� ����������', HireDate AS '���� ������ ���������� �� ������', BirthDate AS '���� �������� ����������'
FROM (SELECT emp.OrganizationLevel, emp.BusinessEntityID AS EmployeeID, emp.HireDate AS HireDate,  emp.BirthDate AS BirthDate, CONCAT(Person.LastName, ' ', Person.FirstName, '.', Person.MiddleName) AS FIO,
  (SELECT  man.BusinessEntityID FROM HumanResources.Employee man 
	    WHERE emp.OrganizationNode.GetAncestor(1) = man.OrganizationNode OR 
		    (emp.OrganizationNode.GetAncestor(1) = 0x AND man.OrganizationNode IS NULL)) AS ManagerID,
  (SELECT  man.HireDate FROM HumanResources.Employee man 
	    WHERE emp.OrganizationNode.GetAncestor(1) = man.OrganizationNode OR 
		    (emp.OrganizationNode.GetAncestor(1) = 0x AND man.OrganizationNode IS NULL)) AS HireDateDirector,
  (SELECT  man.BirthDate FROM HumanResources.Employee man 
	    WHERE emp.OrganizationNode.GetAncestor(1) = man.OrganizationNode OR 
		    (emp.OrganizationNode.GetAncestor(1) = 0x AND man.OrganizationNode IS NULL)) AS BirthDateDirector,
  (SELECT  CONCAT(Person.LastName, ' ', Person.FirstName, '.', Person.MiddleName) FROM HumanResources.Employee man 
		INNER JOIN Person.Person ON Person.BusinessEntityID = man.BusinessEntityID
	    WHERE emp.OrganizationNode.GetAncestor(1) = man.OrganizationNode OR 
		    (emp.OrganizationNode.GetAncestor(1) = 0x AND man.OrganizationNode IS NULL)) AS FIODirector
FROM HumanResources.Employee emp
INNER JOIN Person.Person ON Person.BusinessEntityID = emp.BusinessEntityID) TAB
WHERE HireDateDirector > HireDate AND BirthDateDirector > BirthDate
ORDER BY OrganizationLevel, FIODirector, FIO

--������ 7
CREATE PROCEDURE SingleMen (
	@startDate AS date,
	@endDate AS date,
	@count AS int OUTPUT
)
AS
SELECT * FROM HumanResources.Employee
WHERE Gender = 'M' AND MaritalStatus = 'S' AND @startDate <= BirthDate AND BirthDate <= @endDate
SET @count = @@ROWCOUNT
GO

--������
DECLARE @startDate date, @endDate date, @count int
SET @startDate = DATEFROMPARTS(1983, 1, 1) 
SET @endDate = DATEFROMPARTS(1984, 8, 16)
EXEC SingleMen @startDate, @endDate, @count OUTPUT
SELECT @count AS Count

DROP PROCEDURE SingleMen