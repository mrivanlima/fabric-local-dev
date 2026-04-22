// Example: Aggregation Query
// Demonstrates grouping and calculating summaries

let
    // Connect to SQL Server and load Sales table
    Source = Sql.Database(
        "localhost,1433", 
        "FabricDev",
        [TrustServerCertificate = true, Encrypt = false]
    ),
    dbo_Sales = Source{[Schema="dbo",Item="Sales"]}[Data],
    
    // Group by Region and calculate aggregates
    GroupedRows = Table.Group(
        dbo_Sales, 
        {"Region"},                              // Group by columns
        {
            {"TotalSales", each List.Sum([TotalAmount]), type number},
            {"OrderCount", each Table.RowCount(_), Int64.Type},
            {"AvgOrderValue", each List.Average([TotalAmount]), type number},
            {"MaxOrderValue", each List.Max([TotalAmount]), type number},
            {"TotalQuantity", each List.Sum([Quantity]), Int64.Type}
        }
    ),
    
    // Add calculated column for orders per region percentage
    TotalOrders = List.Sum(GroupedRows[OrderCount]),
    AddedPercentage = Table.AddColumn(
        GroupedRows, 
        "OrderPercentage", 
        each [OrderCount] / TotalOrders * 100, 
        type number
    ),
    
    // Round calculated values
    RoundedValues = Table.TransformColumns(AddedPercentage, {
        {"TotalSales", each Number.Round(_, 2), type number},
        {"AvgOrderValue", each Number.Round(_, 2), type number},
        {"OrderPercentage", each Number.Round(_, 1), type number}
    }),
    
    // Sort by TotalSales descending
    SortedRows = Table.Sort(RoundedValues, {{"TotalSales", Order.Descending}}),
    
    // Return aggregated data
    Result = SortedRows
in
    Result
