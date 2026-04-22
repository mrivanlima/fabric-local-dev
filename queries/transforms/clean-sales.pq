// Transform: Clean and prepare Sales data
// Source: dbo.Sales table from Primary SQL Server

let
    // Load Sales table from primary SQL Server
    Source = Sql.Database(
        "localhost,1433", 
        "FabricDev",
        [TrustServerCertificate = true, Encrypt = false]
    ),
    dbo_Sales = Source{[Schema="dbo",Item="Sales"]}[Data],
    
    // Remove any rows with null ProductName
    RemovedNulls = Table.SelectRows(dbo_Sales, each [ProductName] <> null),
    
    // Filter for sales > $100
    FilteredAmount = Table.SelectRows(RemovedNulls, each [TotalAmount] > 100),
    
    // Add Year and Month columns
    AddedYear = Table.AddColumn(FilteredAmount, "Year", each Date.Year([SaleDate]), Int64.Type),
    AddedMonth = Table.AddColumn(AddedYear, "Month", each Date.Month([SaleDate]), Int64.Type),
    AddedMonthName = Table.AddColumn(AddedMonth, "MonthName", each Date.MonthName([SaleDate]), type text),
    
    // Add Quarter column
    AddedQuarter = Table.AddColumn(AddedMonthName, "Quarter", each "Q" & Text.From(Date.QuarterOfYear([SaleDate])), type text),
    
    // Ensure correct data types
    TypedColumns = Table.TransformColumnTypes(AddedQuarter, {
        {"SaleID", Int64.Type},
        {"SaleDate", type datetime},
        {"CustomerID", Int64.Type},
        {"ProductID", Int64.Type},
        {"ProductName", type text},
        {"Quantity", Int64.Type},
        {"UnitPrice", type number},
        {"TotalAmount", type number},
        {"Region", type text},
        {"SalesRep", type text}
    }),
    
    // Sort by SaleDate descending
    SortedRows = Table.Sort(TypedColumns, {{"SaleDate", Order.Descending}}),
    
    // Return cleaned data
    Result = SortedRows
in
    Result
