# Power Query Development Workflow

**Hybrid Approach:** Power BI Desktop + VS Code + Docker SQL Server

This guide explains the recommended workflow for developing Power Query (M language) code in this environment.

---

## 🎯 Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   Development Workflow                       │
└─────────────────────────────────────────────────────────────┘

   Power BI Desktop              VS Code             Docker SQL Server
   ┌──────────────┐             ┌─────────┐         ┌──────────────┐
   │              │   Export    │         │         │              │
   │  Develop &   │────────────>│  Edit & │         │  FabricDev   │
   │  Test Query  │   M Code    │ Version │         │  (1433)      │
   │              │             │ Control │         │              │
   │              │   Import    │         │         │  FabricDev2  │
   │  Execute &   │<────────────│  Share  │         │  (1434)      │
   │  Visualize   │   M Code    │ w/Team  │         │              │
   └──────┬───────┘             └─────────┘         └───────▲──────┘
          │                                                  │
          │          Connect via localhost,1433             │
          └─────────────────────────────────────────────────┘
```

---

## 📋 Prerequisites

### Required Software
1. ✅ **Docker Desktop** - Running with fabric containers
2. ✅ **VS Code** - With workspace open
3. ✅ **Power BI Desktop** - Free download from Microsoft
4. ✅ **Power Query Extensions** - Installed in VS Code

### Verify Setup
```powershell
# Check Docker containers running
docker ps

# Expected: fabric-sqlserver, fabric-sqlserver2, fabric-jupyter, fabric-spark-*

# Test SQL Server connection
docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -Q "SELECT 1"
```

---

## 🔄 Development Cycle

### Phase 1: Develop in Power BI Desktop

**Step 1: Connect to Docker SQL Server**
1. Open Power BI Desktop
2. **Get Data → SQL Server**
3. Server: `localhost,1433`
4. Database: `FabricDev`
5. Authentication: Database (sa / YourStrong@Passw0rd)
6. Click **Connect**

**Step 2: Build Query with GUI**
1. In Navigator, select table (e.g., `dbo.Sales`)
2. Click **"Transform Data"** to open Power Query Editor
3. Use ribbon buttons to transform:
   - Filter rows
   - Remove columns
   - Change data types
   - Add custom columns
   - Group and aggregate
4. Click **"Close & Apply"** when done

**Step 3: View M Code**
1. In Power Query Editor, select your query
2. **Home → Advanced Editor**
3. See the M code that Power BI generated
4. Review and understand each step

---

### Phase 2: Export to VS Code

**Step 1: Copy M Code**
1. In Advanced Editor, select all code (Ctrl+A)
2. Copy to clipboard (Ctrl+C)

**Step 2: Create .pq File in VS Code**
1. Open VS Code with fabric-local-dev workspace
2. Navigate to appropriate folder in `queries/`:
   - `sources/` for connection queries
   - `transforms/` for data transformations
   - `functions/` for reusable functions
   - `examples/` for sample queries
3. Create new file: `your-query-name.pq`
4. Paste M code (Ctrl+V)
5. Save file (Ctrl+S)

**Step 3: Format and Clean Up**
1. Right-click in editor → **Format Document**
2. Add comments to explain complex logic:
   ```m
   // Filter sales from last 30 days
   FilteredRows = Table.SelectRows(Source, each ...)
   ```
3. Remove any unnecessary steps
4. Ensure consistent naming

---

### Phase 3: Version Control

**Step 1: Commit to Git**
```powershell
git add queries/transforms/your-query-name.pq
git commit -m "Add sales transformation query"
```

**Step 2: Push and Share**
```powershell
git push origin main
```

**Step 3: Team Collaboration**
- Team members can pull your `.pq` files
- Review M code in pull requests
- Comment on transformations
- Suggest improvements

---

### Phase 4: Edit and Refine in VS Code

**Benefits of Editing in VS Code:**
- ✅ Syntax highlighting (colorized M code)
- ✅ IntelliSense (auto-complete functions)
- ✅ Format document (clean code structure)
- ✅ Git integration (track changes, diff view)
- ✅ Find and replace across files
- ✅ Multiple cursors and advanced editing

**Editing Workflow:**
1. Open `.pq` file in VS Code
2. Make changes with IntelliSense support
3. Type `Table.` to see available functions
4. Use Ctrl+Space for auto-complete
5. Format with Shift+Alt+F
6. Save changes

---

### Phase 5: Import Back to Power BI

**Step 1: Copy from VS Code**
1. Open `.pq` file in VS Code
2. Select all (Ctrl+A)
3. Copy (Ctrl+C)

**Step 2: Create New Query in Power BI**
1. Open Power BI Desktop
2. **Home → Get Data → Blank Query**
3. Power Query Editor opens with empty query
4. **Home → Advanced Editor**
5. Delete existing code
6. Paste your M code from VS Code
7. Click **"Done"**

**Step 3: Test Execution**
1. Query will execute against your data
2. View results in preview pane
3. Check each step for correctness
4. Click steps to see intermediate results
5. Verify row counts and data types

**Step 4: Handle Errors**
If query fails:
- Read error message carefully
- Common issues:
  - Table/column names don't match
  - Wrong data types
  - Missing connection credentials
  - Server not accessible
- Fix in Power BI or go back to VS Code

---

## 🎓 Common Scenarios

### Scenario 1: Create New Transformation Query

**Workflow:**
```
1. Power BI Desktop
   ↓ Get Data → SQL Server → localhost,1433 → FabricDev
   ↓ Select dbo.Sales → Transform Data
   ↓ Build transformation step-by-step
   ↓ Test each step with preview
   ↓ Advanced Editor → Copy M code

2. VS Code
   ↓ Create queries/transforms/new-transform.pq
   ↓ Paste M code → Format → Add comments
   ↓ git add → git commit → git push

3. Team Review
   ↓ Pull request created
   ↓ Code review comments
   ↓ Updates in VS Code → git commit → git push

4. Finalize
   ↓ Merge pull request
   ↓ Team pulls latest code
   ↓ Import to their Power BI Desktop files
```

---

### Scenario 2: Reuse Existing Query

**Workflow:**
```
1. VS Code
   ↓ Open queries/transforms/existing-query.pq
   ↓ Review M code and comments
   ↓ Copy code (Ctrl+A, Ctrl+C)

2. Power BI Desktop
   ↓ Get Data → Blank Query
   ↓ Advanced Editor → Paste code → Done
   ↓ Verify execution and results
   ↓ Rename query to descriptive name

3. Customize (Optional)
   ↓ Modify parameters or logic in Power BI
   ↓ Test changes
   ↓ If significant changes, export back to VS Code
```

---

### Scenario 3: Create Parameterized Connection

**Workflow:**
```
1. VS Code
   ↓ Create queries/parameters/local-params.pq (already exists)
   ↓ Define parameters for server, database, credentials

2. VS Code
   ↓ Create queries/sources/parameterized-connection.pq
   ↓ Reference parameter query
   ↓ Use parameters in connection string

3. Power BI Desktop
   ↓ Import parameter query first
   ↓ Then import connection query
   ↓ Connection will use parameter values
   ↓ Easy to switch environments (local/dev/prod)
```

**Example:**
```m
// queries/sources/parameterized-connection.pq
let
    Params = local-params,  // Reference parameter query
    Source = Sql.Database(
        Params[PrimaryServer],
        Params[PrimaryDatabase],
        Params[ConnectionOptions]
    )
in
    Source
```

---

### Scenario 4: Build Reusable Function

**Workflow:**
```
1. VS Code
   ↓ Create queries/functions/fn-custom-function.pqm
   ↓ Define function with parameters and logic
   ↓ Add documentation metadata
   ↓ Save and commit

2. Power BI Desktop
   ↓ Import function as Blank Query
   ↓ Paste function M code
   ↓ Rename query to match function name
   ↓ Mark as function (Power BI auto-detects)

3. Use Function
   ↓ In another query, invoke function:
   ↓ = fn-custom-function(argument1, argument2)
```

**Example:**
```m
// queries/functions/fn-calculate-tax.pqm
let
    CalculateTax = (amount as number, rate as number) as number =>
        amount * rate,
    
    FunctionType = type function (
        amount as number,
        rate as number
    ) as number
in
    Value.ReplaceType(CalculateTax, FunctionType)
```

---

## 🆚 Power Query vs PySpark: When to Use Each

### Use Power Query When:
✅ You prefer GUI-based development  
✅ Building simple to moderate transformations  
✅ Working with business users who know Power BI  
✅ Creating reports and dashboards in Power BI  
✅ Need quick data exploration and prototyping  
✅ Data fits in memory (Import mode)  
✅ Deploying to Power BI Service or Fabric Dataflows  

### Use PySpark When:
✅ Processing large datasets (>1GB)  
✅ Need distributed computing power  
✅ Complex transformations with custom logic  
✅ Machine learning or advanced analytics  
✅ Batch processing and scheduling  
✅ Integration with data lakes or big data systems  
✅ Deploying to Fabric Notebooks or Data Pipelines  

### Hybrid Approach:
🔄 Use **Power Query** for data extraction and initial cleaning  
🔄 Use **PySpark** for heavy transformations and processing  
🔄 Use **Power BI** for visualization and reporting  

---

## 📊 Side-by-Side Examples

### Example 1: Filter and Select Columns

**Power Query (M):**
```m
let
    Source = Sql.Database("localhost,1433", "FabricDev"),
    dbo_Sales = Source{[Schema="dbo",Item="Sales"]}[Data],
    FilteredRows = Table.SelectRows(dbo_Sales, each [TotalAmount] > 100),
    SelectedColumns = Table.SelectColumns(FilteredRows, {"ProductName", "TotalAmount", "Region"})
in
    SelectedColumns
```

**PySpark (Python):**
```python
from scripts.fabric_helper import FabricHelper

helper = FabricHelper()
spark = helper.create_spark_session()
df = helper.read_sql_table(spark, "dbo.Sales")

result = df.filter(df.TotalAmount > 100) \
    .select("ProductName", "TotalAmount", "Region")
```

---

### Example 2: Group and Aggregate

**Power Query (M):**
```m
let
    Source = Sql.Database("localhost,1433", "FabricDev"),
    dbo_Sales = Source{[Schema="dbo",Item="Sales"]}[Data],
    GroupedRows = Table.Group(dbo_Sales, {"Region"}, {
        {"TotalSales", each List.Sum([TotalAmount]), type number},
        {"OrderCount", each Table.RowCount(_), Int64.Type}
    })
in
    GroupedRows
```

**PySpark (Python):**
```python
from pyspark.sql.functions import sum, count

result = df.groupBy("Region") \
    .agg(
        sum("TotalAmount").alias("TotalSales"),
        count("*").alias("OrderCount")
    )
```

---

### Example 3: Add Calculated Column

**Power Query (M):**
```m
let
    Source = Sql.Database("localhost,1433", "FabricDev"),
    dbo_Sales = Source{[Schema="dbo",Item="Sales"]}[Data],
    AddedColumn = Table.AddColumn(dbo_Sales, "Tax", each [TotalAmount] * 0.08, type number)
in
    AddedColumn
```

**PySpark (Python):**
```python
from pyspark.sql.functions import col

result = df.withColumn("Tax", col("TotalAmount") * 0.08)
```

---

## 🔧 Tips and Best Practices

### 1. Start Simple, Build Complexity
- Begin with basic query in Power BI GUI
- Test each transformation step
- Gradually add complexity
- Export to VS Code when satisfied

### 2. Use Descriptive Step Names
In Power Query Editor, rename steps to describe what they do:
- ❌ `Changed Type`, `Filtered Rows1`, `Added Custom`
- ✅ `ConvertDatesToDateTime`, `FilterRecentSales`, `CalculateTaxAmount`

### 3. Add Comments in M Code
```m
// Connect to primary SQL Server
let Source = Sql.Database("localhost,1433", "FabricDev"),
    
    // Load sales table
    dbo_Sales = Source{[Schema="dbo",Item="Sales"]}[Data],
    
    // Keep only sales from last quarter
    FilteredRows = Table.SelectRows(dbo_Sales, each ...)
in
    FilteredRows
```

### 4. Test with Small Data First
- Limit rows during development: `Table.FirstN(Source, 100)`
- Test logic with sample data
- Remove limit when deploying to production

### 5. Use Parameters for Flexibility
- Server names
- Database names
- Date ranges
- Thresholds
- Environment-specific settings

### 6. Version Control Everything
```powershell
# Commit frequently
git add queries/
git commit -m "Add sales analysis transformation"
git push

# Use branches for experiments
git checkout -b experiment/new-approach
# Make changes
git commit -am "Test new aggregation method"
# If successful, merge to main
```

### 7. Document in README Files
- Explain purpose of each query
- Document dependencies between queries
- Note any assumptions or requirements
- Include usage examples

---

## 🚨 Common Pitfalls and Solutions

### Pitfall 1: Hardcoded Connection Strings

**Problem:**
```m
Source = Sql.Database("localhost,1433", "FabricDev")
```
Hard to switch between environments.

**Solution:**
Use parameters:
```m
let
    Params = local-params,
    Source = Sql.Database(Params[PrimaryServer], Params[PrimaryDatabase])
in
    Source
```

---

### Pitfall 2: Not Handling Nulls

**Problem:**
```m
AddedColumn = Table.AddColumn(Source, "Total", each [Qty] * [Price])
```
Fails if Qty or Price is null.

**Solution:**
```m
AddedColumn = Table.AddColumn(Source, "Total", 
    each if [Qty] = null or [Price] = null 
         then null 
         else [Qty] * [Price])
```

---

### Pitfall 3: Performance Issues with Large Datasets

**Problem:**
Loading entire table into Power BI can be slow.

**Solution:**
- Use DirectQuery mode instead of Import
- Filter data at source with SQL query:
  ```m
  Source = Sql.Database("localhost,1433", "FabricDev", [
      Query = "SELECT * FROM dbo.Sales WHERE SaleDate >= '2024-01-01'"
  ])
  ```
- Or use PySpark for large data processing

---

### Pitfall 4: Forgetting to Commit Changes

**Problem:**
Made changes in VS Code but forgot to commit.

**Solution:**
Set up Git workflow:
```powershell
# Before making changes
git pull

# After making changes
git status  # See what changed
git add queries/
git commit -m "Descriptive message"
git push
```

---

## 📚 Additional Resources

### M Language Documentation
- [Power Query M Formula Language](https://learn.microsoft.com/en-us/powerquery-m/)
- [M Function Reference](https://learn.microsoft.com/en-us/powerquery-m/power-query-m-function-reference)
- [M Type System](https://learn.microsoft.com/en-us/powerquery-m/m-spec-types)

### Power BI Documentation
- [Power Query in Power BI](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-query-overview)
- [Power BI Best Practices](https://learn.microsoft.com/en-us/power-bi/guidance/)
- [DirectQuery vs Import](https://learn.microsoft.com/en-us/power-bi/connect-data/desktop-directquery-about)

### Git and Version Control
- [Git Basics](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Git Best Practices](https://www.git-tower.com/learn/git/ebook/en/command-line/appendix/best-practices)

### Project Documentation
- [queries/README.md](../queries/README.md) - M code organization and examples
- [powerbi/README.md](../powerbi/README.md) - Power BI Desktop setup and usage
- [EXTENSIONS.md](../EXTENSIONS.md) - VS Code extension information

---

## 💬 Getting Help

### Questions About:

**M Language Syntax**
- Check [M Language Reference](https://learn.microsoft.com/en-us/powerquery-m/)
- Use IntelliSense in VS Code (Ctrl+Space)
- Review example queries in `queries/examples/`

**Power BI Desktop Connection**
- See [powerbi/README.md](../powerbi/README.md) troubleshooting section
- Test connection with SQL script
- Check Docker container logs

**VS Code Extensions**
- See [EXTENSIONS.md](../EXTENSIONS.md)
- Verify extension installed: Ctrl+Shift+X
- Reload window: Ctrl+Shift+P → "Reload Window"

**Docker SQL Server**
- Check container status: `docker ps`
- View logs: `docker logs fabric-sqlserver`
- Test connection: See powerbi/README.md

**Git and Version Control**
- Check Git status: `git status`
- View commit history: `git log`
- Compare changes: `git diff`

---

## ✅ Workflow Checklist

Use this checklist for each new query you develop:

- [ ] **Connect** - Power BI Desktop connects to Docker SQL Server
- [ ] **Develop** - Build query step-by-step in Power Query Editor
- [ ] **Test** - Verify each step with preview data
- [ ] **Export** - Copy M code from Advanced Editor
- [ ] **Save** - Create `.pq` file in appropriate `queries/` subfolder
- [ ] **Format** - Format document in VS Code (Shift+Alt+F)
- [ ] **Comment** - Add explanatory comments for complex logic
- [ ] **Commit** - `git add` → `git commit` with clear message
- [ ] **Push** - `git push` to share with team
- [ ] **Review** - Create pull request if needed
- [ ] **Document** - Update README if query is significant

---

## 🎯 Next Steps

1. **Practice the workflow** - Start with simple query from examples
2. **Build your own query** - Connect to Docker SQL Server and transform Sales data
3. **Share with team** - Commit your first `.pq` file
4. **Explore advanced features** - Try parameters, functions, and complex transformations
5. **Compare with PySpark** - Build same query in both M and Python

**Happy Querying! 🚀**
