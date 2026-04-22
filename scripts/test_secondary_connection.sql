-- Test Connection to Secondary SQL Server (localhost:1434)
-- This script verifies connectivity to the second SQL Server instance

-- Test 1: Check SQL Server version and instance
SELECT 
    @@VERSION AS SQLServerVersion,
    @@SERVERNAME AS ServerName,
    GETDATE() AS CurrentDateTime;

-- Test 2: List all databases
SELECT 
    name AS DatabaseName,
    database_id AS DatabaseID,
    create_date AS CreatedDate
FROM sys.databases
ORDER BY name;

-- Test 3: Check if FabricDev2 database exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'FabricDev2')
BEGIN
    PRINT 'FabricDev2 database exists';
    
    USE FabricDev2;
    
    -- List tables in FabricDev2
    SELECT 
        TABLE_SCHEMA,
        TABLE_NAME,
        TABLE_TYPE
    FROM INFORMATION_SCHEMA.TABLES
    ORDER BY TABLE_SCHEMA, TABLE_NAME;
END
ELSE
BEGIN
    PRINT 'FabricDev2 database does not exist yet';
    PRINT 'Create it with: CREATE DATABASE FabricDev2';
END

-- Expected Results:
-- Test 1: Should show SQL Server 2025 version
-- Test 2: Should list all databases (at least master, tempdb, model, msdb)
-- Test 3: 
--   - If FabricDev2 exists: Shows tables in that database
--   - If not exists: Shows message to create database

-- Note: FabricDev2 is not created by default
-- You can create it with: docker exec fabric-sqlserver2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -Q "CREATE DATABASE FabricDev2"
