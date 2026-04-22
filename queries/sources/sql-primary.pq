// Connection to Primary SQL Server (localhost:1433)
// Database: FabricDev

let
    // Connection parameters
    Server = "localhost,1433",
    Database = "FabricDev",
    
    // Connect to SQL Server
    Source = Sql.Database(
        Server, 
        Database, 
        [
            TrustServerCertificate = true,
            Encrypt = false
        ]
    ),
    
    // Optional: List available schemas
    // Uncomment to see all schemas in the database
    // Navigation = Source{[Name = Database]}[Data]
    
    // Return the database connection
    Result = Source
in
    Result
