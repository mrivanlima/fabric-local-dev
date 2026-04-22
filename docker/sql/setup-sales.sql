USE FabricDev;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE TABLE dbo.Sales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    SaleDate DATETIME NOT NULL DEFAULT GETDATE(),
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    ProductName NVARCHAR(100) NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalAmount AS (Quantity * UnitPrice) PERSISTED,
    Region NVARCHAR(50) NOT NULL,
    SalesRep NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
);
GO

INSERT INTO dbo.Sales (SaleDate, CustomerID, ProductID, ProductName, Quantity, UnitPrice, Region, SalesRep)
VALUES 
    ('2024-01-15', 1001, 501, 'Laptop Pro 15', 2, 1299.99, 'North America', 'John Smith'),
    ('2024-01-16', 1002, 502, 'Wireless Mouse', 5, 29.99, 'Europe', 'Sarah Johnson'),
    ('2024-01-17', 1003, 503, 'USB-C Cable', 10, 12.99, 'Asia', 'Mike Chen'),
    ('2024-01-18', 1001, 504, 'Monitor 27"', 1, 399.99, 'North America', 'John Smith'),
    ('2024-01-19', 1004, 501, 'Laptop Pro 15', 1, 1299.99, 'Europe', 'Sarah Johnson'),
    ('2024-01-20', 1005, 505, 'Keyboard Mechanical', 3, 89.99, 'Asia', 'Mike Chen'),
    ('2024-01-21', 1002, 502, 'Wireless Mouse', 8, 29.99, 'North America', 'John Smith'),
    ('2024-01-22', 1006, 506, 'Webcam HD', 2, 79.99, 'Europe', 'Sarah Johnson'),
    ('2024-01-23', 1003, 507, 'Headset Pro', 4, 149.99, 'Asia', 'Mike Chen'),
    ('2024-01-24', 1007, 501, 'Laptop Pro 15', 3, 1299.99, 'North America', 'John Smith');
GO

SELECT COUNT(*) as TotalRows FROM dbo.Sales;
GO
