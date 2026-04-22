// Example: Basic SQL Server Query
// Demonstrates connecting to Docker SQL Server and loading a table

let
    // Step 1: Connect to SQL Server
    // Use comma separator for port: "localhost,1433"
    Source = Sql.Database(
        "localhost,1433",           // Server and port
        "FabricDev",                // Database name
        [
            TrustServerCertificate = true,  // Required for Docker self-signed cert
            Encrypt = false                  // Disable encryption for local dev
        ]
    ),
    
    // Step 2: Navigate to specific table
    // Syntax: Source{[Schema="schemaname", Item="tablename"]}[Data]
    dbo_Sales = Source{[Schema="dbo", Item="Sales"]}[Data],
    
    // Step 3: Preview first 10 rows (optional)
    FirstRows = Table.FirstN(dbo_Sales, 10),
    
    // Step 4: Apply simple transformation - filter by region
    FilteredRows = Table.SelectRows(FirstRows, each [Region] = "North America"),
    
    // Step 5: Select specific columns
    SelectedColumns = Table.SelectColumns(FilteredRows, {
        "SaleID", 
        "SaleDate", 
        "ProductName", 
        "Quantity", 
        "TotalAmount", 
        "Region"
    }),
    
    // Step 6: Sort by TotalAmount descending
    SortedRows = Table.Sort(SelectedColumns, {{"TotalAmount", Order.Descending}}),
    
    // Return final result
    Result = SortedRows
in
    Result
