# 🚀 Fabric Local Development - Setup Progress

**Project:** Fabric Local Development Environment  
**Location:** `C:\Development\fabric-local-dev`  
**Workspace:** `fabric-local-dev.code-workspace`  
**Status:** ⏳ Ready to Start  
**Last Updated:** April 22, 2026

> 💡 **Tip:** Open the workspace file (`fabric-local-dev.code-workspace`) for the best experience!

---

## 📋 Setup Checklist

### ✅ Phase 1: Prerequisites (Complete Before Starting)

- [ ] **Docker Desktop** installed and running
  - Minimum 8GB RAM allocated
  - Minimum 4 CPU cores allocated
  - WSL 2 enabled (Windows)
  - Check: `docker --version`

- [ ] **Visual Studio Code** installed
  - Version 1.85 or later recommended
  - Check: `code --version`

- [ ] **VS Code Extensions** (local machine)
  - Dev Containers (`ms-vscode-remote.remote-containers`)
  - Docker (`ms-azuretools.vscode-docker`)
  - Install: Extensions panel (Ctrl+Shift+X) → Search for extensions

- [ ] **Network Requirements**
  - Ports available: 1433, 1434, 8080, 8888
  - Internet connection for downloading images (~3GB)

---

## 🏗️ Phase 2: Initial Setup (One-Time)

### Step 1: Verify Project Files ✅ COMPLETE
All project files have been created:
- ✅ docker-compose.yml
- ✅ .devcontainer/devcontainer.json
- ✅ Dockerfile (Spark)
- ✅ requirements.txt
- ✅ SQL initialization scripts
- ✅ Sample notebooks
- ✅ Helper scripts
- ✅ Documentation

**Status:** Files are in place, ready to build.

---

### Step 2: Build and Start Containers (10-15 minutes first time)

**Command to run:**
```powershell
cd C:\Development\fabric-local-dev
.\start.ps1
```

**Or manually:**
```powershell
docker-compose build
docker-compose up -d
```

**What happens:**
- Downloads SQL Server 2025 image (~1.5GB per instance = 3GB total)
- Downloads Bitnami Spark image (~1GB)
- Builds custom Spark image with PySpark
- Installs Python packages
- Starts 5 containers

**Expected containers after start:**
```
fabric-sqlserver    - SQL Server 2025 Primary (port 1433)
fabric-sqlserver2   - SQL Server 2025 Secondary (port 1434)
fabric-spark-master - Spark Master (port 8080)
fabric-spark-worker - Spark Worker
fabric-jupyter      - Jupyter Lab (port 8888)
```

**Verify with:**
```powershell
docker ps
```

**Troubleshooting:**
- If build fails: `docker-compose build --no-cache`
- If ports conflict: Edit docker-compose.yml port mappings
- Check logs: `docker-compose logs -f`

---

### Step 3: Open Project in VS Code

**Recommended Method (Best):**
```powershell
# Open the workspace file directly
code C:\Development\fabric-local-dev\fabric-local-dev.code-workspace
```

**Or double-click:**
- Navigate to `C:\Development\fabric-local-dev\`
- Double-click `fabric-local-dev.code-workspace`

**Or open folder:**
```powershell
code C:\Development\fabric-local-dev
```

**Why use the workspace file?**
- ✅ Organized folder views
- ✅ Enhanced settings
- ✅ Quick navigation
- ✅ Professional structure
- See [WORKSPACE.md](WORKSPACE.md) for details

**Result:** VS Code opens with organized project structure

---

### Step 4: Reopen in Dev Container (3-5 minutes)

**In VS Code:**
1. Press `Ctrl+Shift+P` (Command Palette)
2. Type: `Dev Containers: Reopen in Container`
3. Press Enter
4. Wait for connection and extension installation

**What happens:**
- VS Code connects to Jupyter container
- Installs VS Code Server in container
- Installs all extensions (Python, Jupyter, SQL, etc.)
- Mounts your workspace files

**You'll know it's ready when:**
- Bottom left corner shows: `Dev Container: Fabric Local Development`
- Terminal opens inside container
- No error messages

**Troubleshooting:**
- If connection fails: `Dev Containers: Rebuild Container`
- Check container is running: `docker ps`
- View logs: `docker logs fabric-jupyter`

---

### Step 5: Verify Environment

**In VS Code terminal (Ctrl+`):**
```bash
# Check Python
python3 --version
# Should show: Python 3.11.x

# Check PySpark
python3 -c "import pyspark; print(f'PySpark {pyspark.__version__}')"
# Should show: PySpark 3.5.0

# Check location
pwd
# Should show: /opt/notebooks
```

**Access web interfaces:**
- Jupyter Lab: http://localhost:8888
- Spark UI: http://localhost:8080

**Test SQL Server connections:**
```bash
# Primary SQL Server
docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT @@VERSION"

# Secondary SQL Server
docker exec fabric-sqlserver2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT @@VERSION"
```

---

## 🎓 Phase 3: Run Sample Notebooks

### Notebook 1: Getting Started

**File:** `notebooks/01-getting-started.ipynb`

**Steps:**
1. Open notebook in VS Code
2. Click "Select Kernel" → Choose "Python 3"
3. Click "Run All" or use `Ctrl+Alt+Shift+Enter`

**What it does:**
- ✅ Connects to Spark cluster
- ✅ Reads data from primary SQL Server
- ✅ Performs PySpark transformations
- ✅ Writes results back to SQL Server
- ✅ Creates visualizations

**Expected result:** All cells run successfully with output

---

### Notebook 2: Dual SQL Server

**File:** `notebooks/02-dual-sql-server.ipynb`

**Prerequisites:**
Create database on secondary instance first:
```powershell
docker exec fabric-sqlserver2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "CREATE DATABASE FabricDev2"
```

**Steps:**
1. Open notebook in VS Code
2. Select Python 3 kernel
3. Run cells step-by-step or all at once

**What it does:**
- ✅ Connects to both SQL Server instances
- ✅ Reads data from primary
- ✅ Transforms with metadata
- ✅ Writes to secondary
- ✅ Compares data between instances

---

## � Phase 4: Power Query Setup (Optional)

This phase is **optional** - skip if you only want PySpark development.

**What is this?** Enable Power Query (M language) development alongside PySpark using a hybrid approach: Power BI Desktop for execution + VS Code for editing.

### Prerequisites

- [ ] **Power BI Desktop** installed (Windows only)
  - Download: https://aka.ms/pbidesktopstore
  - Free application from Microsoft
  - Version: Latest stable release recommended

- [ ] **Docker containers running**
  - Verify: `docker ps` shows all 5 containers

- [ ] **Power Query extensions** (auto-installed in Dev Container)
  - PowerQuery SDK (`powerquery.vscode-powerquery-sdk`)
  - Power Query M Language (`powerquery.vscode-powerquery`)

---

### Step 1: Install Power BI Desktop

**Download and install:**
1. Visit https://aka.ms/pbidesktopstore
2. Click "Get" to download from Microsoft Store
3. Or download direct installer from Microsoft
4. Install with default settings
5. Launch Power BI Desktop to verify

**Verify installation:**
```powershell
# Check if Power BI Desktop is installed
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Power BI Desktop*"}
```

---

### Step 2: Test Connection to Docker SQL Server

**In Power BI Desktop:**
1. Click **"Get Data"** → **"SQL Server"**
2. Server: `localhost,1433`
3. Database: `FabricDev` (or leave blank)
4. Click **"OK"**

**Authentication:**
1. Switch to **"Database"** tab
2. User name: `sa`
3. Password: `YourStrong@Passw0rd`
4. Click **"Connect"**

**If certificate error:**
1. Click **"Advanced Options"** or connection string options
2. Add: `TrustServerCertificate=True;Encrypt=False`
3. Retry connection

**Success indicator:**
- Navigator window shows tables
- You can see `dbo.Sales` table
- Click to preview data

**Troubleshooting:**
```powershell
# Test SQL Server is accessible
docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -Q "SELECT @@VERSION, DB_NAME()"

# Check if containers are running
docker ps

# View SQL Server logs
docker logs fabric-sqlserver
```

---

### Step 3: Verify VS Code Power Query Extensions

**In VS Code (Dev Container):**
1. Press `Ctrl+Shift+X` (Extensions)
2. Search for "powerquery"
3. Verify these are installed:
   - ✅ PowerQuery SDK
   - ✅ Power Query M Language

**Test extension:**
1. Navigate to `queries/examples/` folder
2. Open `example-basic-query.pq`
3. Verify syntax highlighting works (M code is colorized)
4. Type `Table.` and check if IntelliSense shows function list
5. Right-click → **Format Document** (should format code)

**If extensions not installed:**
```
Ctrl+Shift+P → "Dev Containers: Rebuild Container"
```

---

### Step 4: Run Sample Power Query

**In Power BI Desktop:**
1. **Home → Get Data → Blank Query**
2. Power Query Editor opens
3. **Home → Advanced Editor**
4. **Copy this M code:**

```m
let
    Source = Sql.Database(
        "localhost,1433",
        "FabricDev",
        [TrustServerCertificate=true, Encrypt=false]
    ),
    dbo_Sales = Source{[Schema="dbo",Item="Sales"]}[Data],
    FilteredRows = Table.SelectRows(dbo_Sales, each [Region] = "North America")
in
    FilteredRows
```

5. **Paste code** in Advanced Editor
6. Click **"Done"**
7. Query should execute and show filtered sales data

**Expected result:** Table with sales records from North America region

---

### Step 5: Export Query to VS Code

**In Power BI:**
1. In Advanced Editor, select all code (Ctrl+A)
2. Copy (Ctrl+C)

**In VS Code:**
1. Navigate to `queries/examples/`
2. Create new file: `my-first-query.pq`
3. Paste M code (Ctrl+V)
4. Format: Right-click → **Format Document**
5. Add comment:
   ```m
   // My first Power Query - filters North America sales
   ```
6. Save (Ctrl+S)

**Commit to Git:**
```powershell
git add queries/examples/my-first-query.pq
git commit -m "Add my first Power Query example"
```

---

### Step 6: Review Documentation

- [ ] Read [docs/POWERQUERY-WORKFLOW.md](docs/POWERQUERY-WORKFLOW.md) - Complete workflow guide
- [ ] Read [queries/README.md](queries/README.md) - M code examples and patterns
- [ ] Read [powerbi/README.md](powerbi/README.md) - Connection setup and troubleshooting
- [ ] Review sample .pq files in `queries/` folder structure

---

### Power Query Setup Complete! ✅

**You can now:**
- ✅ Develop Power Query transformations in Power BI Desktop
- ✅ Connect Power BI to Docker SQL Server (localhost,1433)
- ✅ Export M code to VS Code for version control
- ✅ Edit .pq files with syntax highlighting and IntelliSense
- ✅ Share M code with your team via Git
- ✅ Use both Power Query and PySpark in the same project

**Next steps:**
1. Try creating a query in Power BI from `dbo.Sales` table
2. Export to VS Code and save in `queries/transforms/`
3. Explore the example files in `queries/examples/`
4. Read the workflow guide for best practices

---

## 🛠️ Phase 5: Daily Usage
 (recommended):**
```powershell
cd C:\Development\fabric-local-dev
.\start.ps1
# Then double-click: fabric-local-dev.code-workspace
```

**Manual start:**
```powershell
docker-compose start
code fabric-local-dev.code-workspace
# Then: Ctrl+Shift+P → "Dev Containers: Reopen in Container"
```

**Alternative - open folder directly
```

**Manual start:**
```powershell
docker-compose start
code .
# Then: Ctrl+Shift+P → "Dev Containers: Reopen in Container"
```

---

### Stopping Your Dev Environment

**Stop containers (keeps data):**
```powershell
docker-compose stop
```

**Full shutdown:**
```powershell
docker-compose down
```

**Complete reset (deletes all data):**
```powershell
docker-compose down -v
```

---

### Creating New Notebooks

**In VS Code:**
1. Navigate to `notebooks/` folder
2. Right-click → New File
3. Name it: `my-notebook.ipynb`
4. Select Python 3 kernel
5. Start coding!

**Or via terminal:**
```bash
cd /opt/notebooks
touch my-new-notebook.ipynb
```

---

## 📊 Phase 6: Working with Data

### SQL Server Connections

**Primary Instance:**
- Host: `localhost,1433` (from local) or `sqlserver` (from container)
- Username: `sa`
- Password: `YourStrong@Passw0rd`
- Database: `FabricDev`

**Secondary Instance:**
- Host: `localhost,1434` (from local) or `sqlserver2` (from container)
- Username: `sa`
- Password: `YourStrong@Passw0rd`
- Database: `FabricDev2`

### Connect from External Tools

**Azure Data Studio / SSMS:**
1. Server: `localhost,1433` or `localhost,1434`
2. Authentication: SQL Server Authentication
3. Login: `sa`
4. Password: `YourStrong@Passw0rd`

**VS Code SQL Extension:**
Use built-in mssql extension (already installed in container)

---

### Adding Your Own Data

**CSV files:**
```python
# Place file in data/ folder, then:
df = spark.read.option("header", "true").csv("/opt/data/your-file.csv")
```

**From SQL Server:**
```python
from scripts.fabric_helper import FabricHelper
helper = FabricHelper()
df = helper.read_sql_table(spark, "dbo.YourTable")
```

---

## 🛠️ Common Tasks

### View Container Status
```powershell
docker ps
```

### View Logs
```powershell
docker logs fabric-jupyter
docker logs fabric-sqlserver
docker logs fabric-spark-master
```

### Restart a Service
```powershell
docker-compose restart jupyter
docker-compose restart sqlserver
```

### Add Python Package
1. Edit `requirements.txt`
2. Rebuild: `docker-compose build`
3. Restart: `docker-compose up -d`

### Scale Spark Workers
```powershell
docker-compose up -d --scale spark-worker=3
```

---

## ⚠️ Troubleshooting

### Containers won't start
```powershell
# Check Docker is running
docker info

# View detailed logs
docker-compose logs

# Clean rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### VS Code won't connect to container
```powershell
# Rebuild container
# Ctrl+Shift+P → "Dev Containers: Rebuild Container"

# Or manually
docker-compose restart jupyter
```

### SQL Server not responding
```powershell
# Wait 30 seconds after start (SQL Server takes time to initialize)
# Check health
docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT 1"

# View logs
docker logs fabric-sqlserver
```

### Port conflicts
Edit `docker-compose.yml` and change port mappings:
```yaml
ports:
  - "1435:1433"  # Changed from 1433:1433
```

### Out of memory
Increase Docker Desktop memory allocation:
- Docker Desktop → Settings → Resources → Memory (recommend 8GB minimum)

---

## 📚 Reference

### Quick Links
- Jupyter Lab: http://localhost:8888
- Spark UI: http://localhost:8080
- Project README: [README.md](README.md)
- Setup Commands: [SETUP-COMMANDS.md](SETUP-COMMANDS.md)

### Key Files
- `docker-compose.yml` - Container orchestration
- `.devcontainer/devcontainer.json` - VS Code config
- `requirements.txt` - Python packages
- `notebooks/` - Your Jupyter notebooks
- `data/` - Data files
- `scripts/fabric_helper.py` - Helper functions

### Architecture
```
VS Code (Local) → Dev Container (Jupyter) → Spark Cluster → SQL Server (2 instances)
```

---

## ✅ Current Status Tracking

### Session: [DATE]

**Setup Status:**
- [ ] Docker Desktop running
- [ ] Containers built
- [ ] Containers started (all 5 running)
- [ ] VS Code connected to container
- [ ] Sample notebook 1 tested
- [ ] Sample notebook 2 tested
- [ ] Secondary database created

**Working On:**
- 

**Issues:**
- 

**Notes:**
- 

---

## 🎯 Next Steps

After completing setup:
1. ✅ Run both sample notebooks
2. ✅ Create your first custom notebook
3. ✅ Import your own data
4. ✅ Connect external SQL tool
5. ✅ **Publish to GitHub** (see GITHUB-SETUP.md)
6. ✅ Commit your work to Git

---

## 📤 Publishing to GitHub

### Quick Method (Recommended):
```powershell
.\publish-to-github.ps1
```

This automated script will:
- Initialize Git repository
- Configure Git settings
- Create initial commit
- Help you create GitHub repository
- Push to GitHub

### Manual Method:
See [GITHUB-SETUP.md](GITHUB-SETUP.md) for step-by-step instructions.

**Your GitHub Profile:** https://github.com/mrivanlima

---

## 💡 Tips for Success

1. **Always start containers before opening VS Code**
2. **Use `.\start.ps1` for guided startup**
3. **Keep Spark UI open** (http://localhost:8080) when running jobs
4. **Commit notebooks regularly** - containers are disposable, your code isn't
5. **Check logs** if something doesn't work
6. **Use the helper script** in notebooks for easier SQL Server access

---

## 📞 Need Help?

- Review [README.md](README.md) for comprehensive documentation
- Check [SETUP-COMMANDS.md](SETUP-COMMANDS.md) for all commands
- View container logs: `docker-compose logs -f`
- Check Docker resources in Docker Desktop

---

**Remember:** This is a DEVELOPMENT environment. Never use production data or credentials!

---

**Happy Coding! 🚀**
