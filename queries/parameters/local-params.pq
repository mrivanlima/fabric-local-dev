// Local Development Parameters
// Use these parameters for connecting to Docker SQL Server instances

let
    // Primary SQL Server Configuration
    PrimaryServer = "localhost,1433",
    PrimaryDatabase = "FabricDev",
    
    // Secondary SQL Server Configuration
    SecondaryServer = "localhost,1434",
    SecondaryDatabase = "FabricDev2",
    
    // Authentication (Docker default SA account)
    Username = "sa",
    Password = "YourStrong@Passw0rd",
    
    // Connection Options (required for Docker self-signed certificates)
    ConnectionOptions = [
        TrustServerCertificate = true,
        Encrypt = false
    ],
    
    // Environment identifier
    Environment = "Local",
    
    // Return record with all parameters
    Parameters = [
        PrimaryServer = PrimaryServer,
        PrimaryDatabase = PrimaryDatabase,
        SecondaryServer = SecondaryServer,
        SecondaryDatabase = SecondaryDatabase,
        Username = Username,
        Password = Password,
        ConnectionOptions = ConnectionOptions,
        Environment = Environment
    ]
in
    Parameters
