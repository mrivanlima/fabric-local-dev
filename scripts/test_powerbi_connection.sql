-- Test Connection to Docker SQL Server
-- This script verifies that Power BI Desktop can connect to the Docker SQL Server instances

-- Test 1: Check SQL Server version
SELECT 
    @@VERSION AS SQLServerVersion,
    @@SERVERNAME AS ServerName,
    DB_NAME() AS CurrentDatabase,
    GETDATE() AS CurrentDateTime;

-- Test 2: Verify FabricDev database exists
SELECT name AS DatabaseName
FROM sys.databases
WHERE name = 'FabricDev';

-- Test 3: Check if Sales table exists and has data
SELECT 
    COUNT(*) AS TotalRows,
    MIN(SaleDate) AS EarliestSale,
    MAX(SaleDate) AS LatestSale,
    SUM(TotalAmount) AS TotalSalesAmount
FROM dbo.Sales;

-- Test 4: Show sample data from Sales table
SELECT TOP 5 
    SaleID,
    SaleDate,
    ProductName,
    Quantity,
    UnitPrice,
    TotalAmount,
    Region,
    SalesRep
FROM dbo.Sales
ORDER BY SaleDate DESC;

-- Test 5: Verify table schema
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' 
  AND TABLE_NAME = 'Sales'
ORDER BY ORDINAL_POSITION;

-- Expected Results:
-- Test 1: Should show SQL Server 2025 version
-- Test 2: Should return 'FabricDev' database name
-- Test 3: Should show 10 rows (sample data)
-- Test 4: Should display 5 recent sales records
-- Test 5: Should show all columns of Sales table

-- If all tests pass, Power BI Desktop can successfully connect!
