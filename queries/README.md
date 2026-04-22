# Power Query Files

This directory contains Power Query (M language) files for data transformations.

## 📁 Folder Structure

```
queries/
├── README.md              # This file
├── parameters/            # Environment-specific parameters
├── sources/               # Data source connections
├── transforms/            # Data transformation logic
├── functions/             # Reusable M functions
└── examples/              # Sample queries
```

---

## 🔗 Connecting to Docker SQL Server

### Primary SQL Server (Port 1433)
```
Server: localhost,1433
Database: FabricDev
Username: sa
Password: YourStrong@Passw0rd
```

### Secondary SQL Server (Port 1434)
```
Server: localhost,1434
Database: FabricDev2
Username: sa
Password: YourStrong@Passw0rd
```

### Connection String Format (M Language)
```m
Sql.Database("localhost,1433", "FabricDev", [
    TrustServerCertificate=true,
    Encrypt=false
])
```

---

## 🚀 Usage Workflow

### 1. **Develop in Power BI Desktop**
- Open Power BI Desktop
- Get Data → SQL Server
- Connect to `localhost,1433`
- Build query using Power Query Editor
- Test query with sample data

### 2. **Export to VS Code**
- In Power Query Editor, open Advanced Editor
- Copy M code
- Create new `.pq` file in appropriate folder
- Paste and save

### 3. **Edit in VS Code**
- Syntax highlighting and IntelliSense available
- Format code: Right-click → Format Document
- Version control with Git
- Share with team

### 4. **Import Back to Power BI**
- Copy M code from `.pq` file
- In Power BI: Home → New Source → Blank Query
- Open Advanced Editor
- Paste M code
- Click Done

---

## 📂 File Organization

### `parameters/`
Environment-specific settings like server names, database names, and connection options.

**Example:** `local-params.pq`, `prod-params.pq`

### `sources/`
Connection queries to data sources (SQL Server, CSV files, etc.).

**Example:** `sql-primary.pq`, `sql-secondary.pq`, `csv-products.pq`

### `transforms/`
Data transformation logic (cleaning, filtering, aggregating, merging).

**Example:** `clean-sales.pq`, `aggregate-daily.pq`, `merge-customers.pq`

### `functions/`
Reusable M functions that can be called from multiple queries.

**Example:** `fn-format-currency.pqm`, `fn-clean-text.pqm`

### `examples/`
Sample queries demonstrating common patterns and best practices.

**Example:** `example-basic-query.pq`, `example-parameters.pq`

---

## 💡 Best Practices

### 1. **Use Parameters**
Create parameter files for environment-specific settings:
```m
// parameters/local-params.pq
let
    ServerName = "localhost,1433",
    DatabaseName = "FabricDev",
    TrustCertificate = true
in
    [Server = ServerName, Database = DatabaseName, Trust = TrustCertificate]
```

### 2. **Modularize Queries**
Break complex queries into smaller, reusable pieces:
- Source connections in `sources/`
- Transformations in `transforms/`
- Reusable logic in `functions/`

### 3. **Document Your Code**
Use M comments to explain complex logic:
```m
// Filter sales records from the last 30 days
let
    Source = ...,
    FilteredRows = Table.SelectRows(Source, each [SaleDate] >= Date.AddDays(DateTime.LocalNow(), -30))
in
    FilteredRows
```

### 4. **Test Incrementally**
- Test each transformation step in Power BI Editor
- Click on each step to see intermediate results
- Verify data types and row counts

### 5. **Version Control**
- Commit `.pq` and `.pqm` files to Git
- Use meaningful commit messages
- Create branches for experimental queries

---

## 🔍 Common M Language Patterns

### Filter Rows
```m
Table.SelectRows(Source, each [Amount] > 100)
```

### Add Custom Column
```m
Table.AddColumn(Source, "FullName", each [FirstName] & " " & [LastName])
```

### Group and Aggregate
```m
Table.Group(Source, {"Region"}, {
    {"TotalSales", each List.Sum([Amount]), type number}
})
```

### Join Tables
```m
Table.NestedJoin(
    Sales, {"CustomerID"},
    Customers, {"ID"},
    "CustomerInfo",
    JoinKind.Inner
)
```

### Change Data Types
```m
Table.TransformColumnTypes(Source, {
    {"SaleDate", type datetime},
    {"Amount", type number},
    {"ProductName", type text}
})
```

---

## 📚 Resources

- [Power Query M Language Reference](https://learn.microsoft.com/en-us/powerquery-m/)
- [Power Query M Function Reference](https://learn.microsoft.com/en-us/powerquery-m/power-query-m-function-reference)
- [Power BI Desktop Documentation](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-query-overview)
- [Hybrid Workflow Guide](../docs/POWERQUERY-WORKFLOW.md)

---

## ⚠️ Important Notes

### Limitations
- **No Direct Execution**: VS Code extensions provide editing only, not execution
- **Require Power BI Desktop**: To test queries, you must use Power BI Desktop or Fabric
- **TLS Certificates**: Docker SQL Server uses self-signed certificates - use `TrustServerCertificate=true`

### Security
- **Local Development Only**: Connection strings here are for local Docker containers
- **Change Passwords**: Update passwords before deploying to production
- **Don't Commit Secrets**: Use parameters for sensitive values

---

## 🆘 Troubleshooting

### Can't Connect from Power BI Desktop
1. Verify Docker containers are running: `docker ps`
2. Test SQL Server: `docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -Q "SELECT 1"`
3. Use comma, not colon: `localhost,1433` (not `localhost:1433`)
4. Add connection options: `TrustServerCertificate=true`, `Encrypt=false`

### Syntax Highlighting Not Working
1. Verify Power Query extension installed: `Ctrl+Shift+X` → Search "powerquery"
2. Check file extension: Must be `.pq`, `.pqm`, or `.m`
3. Reload VS Code: `Ctrl+Shift+P` → "Reload Window"

### IntelliSense Not Working
1. Verify PowerQuery SDK extension installed
2. Open file with correct extension (`.pq`)
3. Wait a few seconds for language server to start
4. Type `Table.` to test - should show function list

---

## 📝 File Naming Conventions

- **Sources**: `sql-*.pq`, `csv-*.pq`, `api-*.pq`
- **Transforms**: `clean-*.pq`, `merge-*.pq`, `aggregate-*.pq`
- **Functions**: `fn-*.pqm` (use `.pqm` for function modules)
- **Parameters**: `*-params.pq`
- **Examples**: `example-*.pq`

Use lowercase with hyphens for consistency.
