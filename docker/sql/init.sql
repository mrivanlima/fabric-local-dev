-- SQL Server Initialization Script
-- This runs automatically when SQL Server container starts
-- Creates a sample database and table with test data

-- Wait for SQL Server to be fully ready
WAITFOR DELAY '00:00:10';
GO

-- Create a sample database for Fabric development
CREATE DATABASE FabricDev;
GO

USE FabricDev;
GO

-- Create schema for organizing tables
CREATE SCHEMA dbo;
GO

-- Create a sample Sales table (mimics common Fabric scenario)
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

-- Insert sample data
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

-- Create a destination table for transformed data
CREATE TABLE dbo.SalesSummary (
    Region NVARCHAR(50) PRIMARY KEY,
    TotalSales DECIMAL(18,2),
    TotalOrders INT,
    AvgOrderValue DECIMAL(18,2),
    LastUpdated DATETIME DEFAULT GETDATE()
);
GO

-- Create a view for reporting
CREATE VIEW dbo.vw_SalesByProduct AS
SELECT 
    ProductName,
    COUNT(*) AS OrderCount,
    SUM(Quantity) AS TotalQuantity,
    SUM(TotalAmount) AS TotalRevenue,
    AVG(UnitPrice) AS AvgUnitPrice
FROM dbo.Sales
GROUP BY ProductName;
GO

-- Create indexes for performance
CREATE NONCLUSTERED INDEX IX_Sales_SaleDate ON dbo.Sales(SaleDate);
CREATE NONCLUSTERED INDEX IX_Sales_Region ON dbo.Sales(Region);
CREATE NONCLUSTERED INDEX IX_Sales_CustomerID ON dbo.Sales(CustomerID);
GO

-- Display success message
PRINT 'Database FabricDev created successfully!';
PRINT 'Sample tables created: dbo.Sales, dbo.SalesSummary';
PRINT 'Sample view created: dbo.vw_SalesByProduct';
PRINT 'Ready for PySpark development!';
GO
