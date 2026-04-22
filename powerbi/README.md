# Power BI Desktop Files

This directory contains Power BI Desktop files for local development.

## 📁 Folder Structure

```
powerbi/
├── README.md              # This file
├── dev/                   # Development .pbix files (not committed)
├── templates/             # .pbit template files (committed)
└── .gitignore             # Excludes large .pbix files
```

---

## 🚀 Getting Started

### Prerequisites
1. **Power BI Desktop** installed (free Windows application)
   - Download: https://aka.ms/pbidesktopstore
   - Minimum version: Latest stable release
   
2. **Docker containers running**
   - Run: `docker-compose up -d` or `.\start.ps1`
   - Verify: `docker ps` shows all containers running

3. **SQL Server accessible**
   - Test: See connection testing section below

---

## 🔗 Connecting Power BI Desktop to Docker SQL Server

### Step 1: Open Power BI Desktop
1. Launch Power BI Desktop
2. Click **"Get Data"** or **"Home → Get Data"**
3. Search for and select **"SQL Server"**
4. Click **"Connect"**

### Step 2: Enter Connection Details

**Primary SQL Server (Port 1433):**
```
Server: localhost,1433
Database: FabricDev
```

**Secondary SQL Server (Port 1434):**
```
Server: localhost,1434
Database: FabricDev2
```

**Important Notes:**
- Use **comma** (`,`), not colon (`:`): `localhost,1433` ✅ `localhost:1433` ❌
- You can leave Database blank to browse all databases
- Data Connectivity mode: Choose **"Import"** for better performance in local dev

### Step 3: Authentication

1. Switch to **"Database"** tab
2. Enter credentials:
   - **User name:** `sa`
   - **Password:** `YourStrong@Passw0rd`
3. Click **"Connect"**

### Step 4: Handle Certificate Warning (if prompted)

If you see a certificate security warning:
1. Click **"Advanced Options"**
2. Add to connection string:
   ```
   TrustServerCertificate=True;Encrypt=False
   ```
3. Or click "Trust Server Certificate" if option available

### Step 5: Select Tables

1. Navigator window will show available tables
2. Check boxes for tables you want (e.g., `dbo.Sales`)
3. Click **"Transform Data"** to open Power Query Editor
4. Or click **"Load"** to import directly

---

## 📝 Working with Power Query Editor

### Opening Advanced Editor
1. In Power Query Editor, select a query
2. Click **"Home → Advanced Editor"**
3. See the M code for that query
4. Copy code to save to `.pq` file in VS Code

### Creating New Query
1. **"Home → New Source → Blank Query"**
2. **"Home → Advanced Editor"**
3. Paste M code from `.pq` file
4. Click **"Done"**
5. Test query with your data

### Exporting Query to VS Code
```
Power Query Editor → Select Query → Advanced Editor → Copy M Code
→ VS Code → Create .pq file in queries/ folder → Paste → Save
```

### Importing Query from VS Code
```
VS Code → Open .pq file → Copy M code
→ Power BI → New Blank Query → Advanced Editor → Paste → Done
```

---

## 🎯 Recommended Workflow

### Development Cycle
```
1. Power BI Desktop
   ↓ Develop query with GUI
   ↓ Test with Docker SQL Server
   ↓ Verify results
   
2. Export to VS Code
   ↓ Copy M code from Advanced Editor
   ↓ Save as .pq file in queries/
   ↓ Commit to Git
   
3. Refine in VS Code
   ↓ Edit with syntax highlighting
   ↓ Format code
   ↓ Review with team
   
4. Import back to Power BI
   ↓ Paste updated M code
   ↓ Test execution
   ↓ Verify results
```

### File Organization
- **Development files** (`.pbix`) → Save in `powerbi/dev/` folder
- **Template files** (`.pbit`) → Save in `powerbi/templates/` folder
- **M code** (`.pq`) → Save in `queries/` folder structure

**Why separate?**
- `.pbix` files are large binaries (not great for Git)
- `.pbit` templates are smaller and useful for sharing
- `.pq` files are text and work well with version control

---

## 🔧 Connection Testing

### Test 1: Verify Docker Containers Running
```powershell
docker ps
```
**Expected:** See `fabric-sqlserver` and `fabric-sqlserver2` in the list

### Test 2: Test SQL Server Connection
```powershell
# Primary SQL Server
docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -Q "SELECT @@VERSION, DB_NAME()"

# Secondary SQL Server
docker exec fabric-sqlserver2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -Q "SELECT @@VERSION, DB_NAME()"
```
**Expected:** See SQL Server version and database name

### Test 3: Check Sample Data
```powershell
docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d FabricDev -Q "SELECT COUNT(*) as RowCount FROM dbo.Sales"
```
**Expected:** See row count (should be 10 sample rows)

### Test 4: Power BI Desktop Connection
1. Open Power BI Desktop
2. Get Data → SQL Server
3. Server: `localhost,1433`
4. Database: `FabricDev`
5. Authenticate with sa credentials
6. If successful, you'll see table list including `dbo.Sales`

---

## ⚠️ Troubleshooting

### Problem: "Can't connect to server"

**Possible causes:**
1. Docker containers not running
   - **Solution:** Run `docker-compose up -d` or `.\start.ps1`

2. Wrong server format
   - **Solution:** Use `localhost,1433` (comma, not colon)

3. Firewall blocking connection
   - **Solution:** Check Windows Firewall settings for ports 1433, 1434

4. SQL Server not ready yet
   - **Solution:** Wait 30 seconds after starting containers, then retry

### Problem: "Login failed for user 'sa'"

**Possible causes:**
1. Wrong password
   - **Solution:** Verify password is exactly `YourStrong@Passw0rd`

2. SQL Server authentication not enabled
   - **Solution:** This should be default in Docker image, but verify container logs

**Check logs:**
```powershell
docker logs fabric-sqlserver
```

### Problem: "Certificate chain not trusted"

**Solution 1:** Add connection options
```
TrustServerCertificate=True;Encrypt=False
```

**Solution 2:** Use Advanced Options in Power BI connection dialog and paste above

### Problem: "Database 'FabricDev' does not exist"

**Possible cause:** SQL Server initialization script didn't run

**Solution:**
```powershell
# Check if database exists
docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -Q "SELECT name FROM sys.databases"

# If FabricDev missing, recreate containers
docker-compose down
docker-compose up -d
```

### Problem: Power BI Desktop won't open .pbit files

**Solution:**
1. Ensure Power BI Desktop is installed
2. Right-click `.pbit` file → Open With → Power BI Desktop
3. Or open Power BI Desktop first, then File → Open → select `.pbit` file

---

## 📚 Best Practices

### 1. Use Import Mode for Local Development
- Faster query performance
- Can work offline
- Better for testing transformations

### 2. Create Parameterized Connections
- Makes switching between Local/Production easier
- Store parameters in M parameter files
- Reference parameters in connections

### 3. Save Templates, Not Data Files
- `.pbit` files don't contain data (smaller, shareable)
- `.pbix` files contain data (larger, local only)
- Use `.pbit` for team sharing

### 4. Version Control M Code, Not PBIX
- Save M queries as `.pq` files in Git
- Document query logic in README files
- Use branches for experimental queries

### 5. Test Incrementally
- Build query step-by-step in Power Query Editor
- Click each step to see intermediate results
- Add descriptive step names

---

## 🎓 Learning Resources

### Power BI Desktop
- [Power BI Desktop Documentation](https://learn.microsoft.com/en-us/power-bi/fundamentals/)
- [Power Query in Power BI](https://learn.microsoft.com/en-us/power-bi/transform-model/desktop-query-overview)
- [Power BI Video Training](https://learn.microsoft.com/en-us/power-bi/fundamentals/desktop-videos)

### Power Query M Language
- [M Language Reference](https://learn.microsoft.com/en-us/powerquery-m/)
- [M Function Reference](https://learn.microsoft.com/en-us/powerquery-m/power-query-m-function-reference)
- [Power Query Formula Language](https://learn.microsoft.com/en-us/powerquery-m/power-query-m-language-specification)

### SQL Server Connections
- [SQL Server in Power BI](https://learn.microsoft.com/en-us/power-bi/connect-data/desktop-connect-to-data)
- [DirectQuery vs Import](https://learn.microsoft.com/en-us/power-bi/connect-data/desktop-directquery-about)

---

## 🔐 Security Notes

### For Local Development ONLY
- Passwords here are for Docker containers
- **DO NOT** use these credentials in production
- **DO NOT** commit `.pbix` files with production connection strings

### Before Deploying to Production
1. Replace connection strings with production values
2. Use secure credential storage (Azure Key Vault, etc.)
3. Remove hardcoded passwords
4. Use service accounts, not SA account
5. Enable encryption and certificate validation

---

## 📞 Need Help?

1. Check [POWERQUERY-WORKFLOW.md](../docs/POWERQUERY-WORKFLOW.md) for detailed workflow
2. See [queries/README.md](../queries/README.md) for M code examples
3. Review [EXTENSIONS.md](../EXTENSIONS.md) for VS Code Power Query extension info
4. Check Docker container logs: `docker logs fabric-sqlserver`
