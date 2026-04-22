// Connection to Secondary SQL Server (localhost:1434)
// Database: FabricDev2

let
    // Connection parameters
    Server = "localhost,1434",
    Database = "FabricDev2",
    
    // Connect to SQL Server
    Source = Sql.Database(
        Server, 
        Database, 
        [
            TrustServerCertificate = true,
            Encrypt = false
        ]
    ),
    
    // Return the database connection
    Result = Source
in
    Result
