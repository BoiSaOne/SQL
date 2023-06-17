# SQL

```
-- Задача 1
CREATE INDEX IX_WebLog_SessionStart_ServerID ON Marketing.WebLog (SessionStart DESC, ServerID DESC) INCLUDE (SessionID, UserName);

DECLARE @StartTime datetime2 = '2010-08-30 16:27';

SELECT TOP(5000) wl.SessionID, wl.ServerID, wl.UserName 
FROM Marketing.WebLog AS wl
WHERE wl.SessionStart >= @StartTime
ORDER BY wl.SessionStart, wl.ServerID;
GO

-- Задача 2
CREATE INDEX IX_PostalCode_StateCode_PostalCode ON Marketing.PostalCode (StateCode, PostalCode) INCLUDE (Country);

SELECT PostalCode, Country
FROM Marketing.PostalCode 
WHERE StateCode = 'KY'
ORDER BY StateCode, PostalCode;
GO

-- Задача 3
CREATE INDEX IX_Prospect ON Marketing.Prospect (LastName) INCLUDE (FirstName);
CREATE INDEX IX_Salesperson ON Marketing.Salesperson (LastName);

DECLARE @Counter INT = 0;
WHILE @Counter < 350
BEGIN
  SELECT p.LastName, p.FirstName 
  FROM Marketing.Prospect AS p
  INNER JOIN Marketing.Salesperson AS sp
  ON p.LastName = sp.LastName
  ORDER BY p.LastName, p.FirstName;
  
  SELECT * 
  FROM Marketing.Prospect AS p
  WHERE p.LastName = 'Smith';
  SET @Counter += 1;
END;


-- Задача 4
CREATE INDEX IX_Subcategory_CategoryID ON Marketing.Subcategory (CategoryID) INCLUDE (SubcategoryName);
CREATE INDEX IX_Product_ProductID ON Marketing.Product (ProductID) INCLUDE (ProductModelID, SubcategoryID)
CREATE INDEX IX_ProductModel_ProductModelID ON Marketing.ProductModel (ProductModelID) INCLUDE (ProductModel)

SELECT
	c.CategoryName,
	sc.SubcategoryName,
	pm.ProductModel,
	COUNT(p.ProductID) AS ModelCount
FROM Marketing.ProductModel pm
	JOIN Marketing.Product p
		ON p.ProductModelID = pm.ProductModelID
	JOIN Marketing.Subcategory sc
		ON sc.SubcategoryID = p.SubcategoryID
	JOIN Marketing.Category c
		ON c.CategoryID = sc.CategoryID
GROUP BY c.CategoryName,
	sc.SubcategoryName,
	pm.ProductModel
HAVING COUNT(p.ProductID) > 1
```
