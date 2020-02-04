Create table Department
(DepartmentID Integer not null,
DepartmentName Varchar(100) not null,
constraint Department_PK primary key (DepartmentID));

Create table Region
(RegionID Integer not null,
RegionName Varchar(100) not null,
constraint Region_PK primary key (RegionID));


Create table Employee
(EmployeeID Integer not null,
EmployeeFirstName Varchar(200) not null,
EmployeeLastName Varchar(200),
DepartmentID Integer not null,
EmployeeAddress Varchar (200),
Gender Char(20),
EmployeeBirthDate Date,
Salary Real,
RegionID Integer not null,
constraint Employee_PK primary key (EmployeeID),
constraint Employee_FK1 foreign key (DepartmentID) references Department(DepartmentID),
constraint Employee_FK2 foreign key (RegionID) references Region(RegionID));

Create table Product
(ProductID Integer not null,
ProductName Varchar(200) not null,
Cost Real,
WholeSalePrice Real,
MSRP Real,
constraint Product_PK primary key (ProductID));

Create table Customer
(CustomerID Integer not null,
CustomerFirstName Varchar(200) not null,
CustomerLastName Varchar(200),
CustomerAddress Varchar (200),
CustomerAge Integer,
CustomerExperience Integer,
constraint Customer_PK primary key (CustomerID));

Create table SalesOrder
(OrderID Integer not null,
PODate Date ,
ProductID Integer not null,
CustomerID Integer not null,
CustomerPO Integer,
EmployeeID Integer not null,
Quantity Integer,
UnitPrice Real,
constraint SalesOrder_PK primary key (OrderID),
constraint SalesOrder_FK1 foreign key (ProductID) references Product(ProductID),
constraint SalesOrder_FK2 foreign key (CustomerID) references Customer(CustomerID),
constraint SalesOrder_FK3 foreign key (EmployeeID) references Employee(EmployeeID));

BULK
INSERT Department
FROM 'C:\Users\Abhisha Burande\Documents\CSU MSBA Sem 1\610- Database Management\project 3\Department.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

BULK
INSERT Region
FROM 'C:\Users\Abhisha Burande\Documents\CSU MSBA Sem 1\610- Database Management\project 3\Region.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

BULK
INSERT Employee
FROM 'C:\Users\Abhisha Burande\Documents\CSU MSBA Sem 1\610- Database Management\project 3\Employee.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

BULK
INSERT Product
FROM 'C:\Users\Abhisha Burande\Documents\CSU MSBA Sem 1\610- Database Management\project 3\Product.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

BULK
INSERT Customer
FROM 'C:\Users\Abhisha Burande\Documents\CSU MSBA Sem 1\610- Database Management\project 3\Customer.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO

BULK
INSERT SalesOrder
FROM 'C:\Users\Abhisha Burande\Documents\CSU MSBA Sem 1\610- Database Management\project 3\SalesOrder.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)
GO


-- Question 1
SELECT Region.RegionName, SUM(SalesOrder.Quantity* SalesOrder.UnitPrice) AS 'Total Sales' 
FROM  Region, SalesOrder, Employee, Product
WHERE Region.RegionID = Employee.RegionID
AND Product.ProductID = SalesOrder.ProductID
AND SalesOrder.EmployeeID = Employee.EmployeeID
AND Product.ProductName IN ('Extreme Mountain Bike', 'Extreme Plus Mountain Bike','Extreme Ultra Mountain Bike')
GROUP BY Region.RegionName;

-- Question 2:
SELECT Product.ProductID, Product.ProductName, Product.Cost
FROM Product
WHERE ProductID NOT IN
(
	SELECT ProductID FROM SalesOrder, Customer 
	WHERE Customer.CustomerID = SalesOrder.CustomerID 
	AND Customer.CustomerFirstName = 'Dan'
	AND Customer.CustomerLastName ='Connor'
);


-- Question 3:
SELECT Customer.CustomerID, Customer.CustomerFirstName, Customer.CustomerLastName, Customer.CustomerAge , (SELECT AVG(Customer.CustomerAge) from Customer) AS 'AvgAge'
FROM Customer
WHERE Customer.CustomerAge > (SELECT AVG(Customer.CustomerAge) FROM Customer)
AND Customer.CustomerID IN 
(SELECT CustomerID
FROM SalesOrder
GROUP BY CustomerID
HAVING COUNT(CustomerID) > 1000);


-- Question 4: 
select 
max([Q1 Sales]) as [Max Sales Q1], 
max([Q2 Sales]) as [Max Sales Q2], 
max([Q3 Sales]) as [Max Sales Q3], 
max([Q4 Sales]) as [Max Sales Q4]
from (
select 
sum (case when DATEPART(QUARTER, PODate) = 1 then Quantity* UnitPrice end) AS [Q1 Sales],
sum (case when DATEPART(QUARTER, PODate) = 2 then Quantity* UnitPrice end) AS [Q2 Sales],
sum (case when DATEPART(QUARTER, PODate) = 3 then Quantity* UnitPrice end) AS [Q3 Sales],
sum (case when DATEPART(QUARTER, PODate) = 4 then Quantity* UnitPrice end) AS [Q4 Sales], CustomerID
from SalesOrder
group by CustomerID
) as X

-- Question 5:
SELECT Product.ProductName, SUM(SalesOrder.Quantity*(SalesOrder.UnitPrice-Product.Cost)) AS [Over Avg Profit]
FROM Product INNER JOIN SalesOrder ON Product.ProductID = SalesOrder.ProductID
GROUP BY Product.ProductName
HAVING SUM(SalesOrder.Quantity*(SalesOrder.UnitPrice-Product.Cost)) > (
		SELECT AVG(X.Profit)
		FROM (
			SELECT Product.ProductName, SUM(SalesOrder.Quantity*(SalesOrder.UnitPrice-Product.Cost)) AS Profit
			FROM Product INNER JOIN SalesOrder ON Product.ProductID = SalesOrder.ProductID
			GROUP BY Product.ProductName
		) AS X
	)