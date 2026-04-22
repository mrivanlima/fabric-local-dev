# Fabric Local Development Environment

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2025-CC2927?logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/sql-server)
[![Apache Spark](https://img.shields.io/badge/Apache%20Spark-3.5.0-E25A1C?logo=apache-spark&logoColor=white)](https://spark.apache.org/)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-F37626?logo=jupyter&logoColor=white)](https://jupyter.org/)
[![VS Code](https://img.shields.io/badge/VS%20Code-Dev%20Container-007ACC?logo=visual-studio-code&logoColor=white)](https://code.visualstudio.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A complete local development environment that mimics Microsoft Fabric's architecture using Docker. Develop and test **PySpark data pipelines**, **Power Query transformations**, **notebooks**, and **SQL transformations** locally before deploying to Fabric.

> **⚡ Quick Start:** Open `fabric-local-dev.code-workspace` → Press `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

## 🏗️ Architecture

This setup mirrors Microsoft Fabric's core components:

```
┌─────────────────────────────────────────────────────────┐
│                    VS Code (Local)                       │
│              Connected to Jupyter Container              │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                Docker Environment                        │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Jupyter    │  │ Spark Master │  │ Spark Worker │ │
│  │   Notebook   │◄─┤   (Cluster)  │◄─┤  (Executor)  │ │
│  └──────┬───────┘  └──────────────┘  └──────────────┘ │
│         │                                               │
│         │          ┌──────────────┐                     │
│         └─────────►│ SQL Server   │                     │
│                    │ Developer Ed │                     │
│                    └──────────────┘                     │
└──────────────────────────────────────────────────────────┘
```

**Components:**
- **SQL Server 2025 Developer Edition (2 instances)** - Data source/target for testing data movement
- **Apache Spark Cluster** - Data transformation engine (Fabric's processing layer)
- **Jupyter Lab** - Interactive notebook development
- **VS Code Dev Container** - Seamless IDE integration
- **Power Query (M Language)** - Hybrid development with Power BI Desktop + VS Code

---

## 📋 Prerequisites

Before starting, ensure you have:

1. **Docker Desktop** installed and running
   - [Download for Windows](https://www.docker.com/products/docker-desktop/)
   - Minimum: 8GB RAM, 4 CPU cores allocated to Docker

2. **Visual Studio Code** with extensions:
   - [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
   - [Docker extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)

3. **Windows Subsystem for Linux 2 (WSL 2)** - Required for Docker Desktop
   - Usually installed with Docker Desktop

📝 **First time setup?** Follow the detailed step-by-step guide in [PROGRESS.md](PROGRESS.md)

---

## 🚀 Quick Start

### Step 1: Open Project in VS Code

**Recommended - Open Workspace:**
```powershell
cd C:\Development\fabric-local-dev
code fabric-local-dev.code-workspace
```

**Or double-click** the `fabric-local-dev.code-workspace` file.

**Why workspace?** Better organization with multiple folder views. See [WORKSPACE.md](WORKSPACE.md) for details.

**Alternative - Open Folder:**
```powershell
cd C:\Development\fabric-local-dev
code .
```

### Step 2: Start Dev Container

1. **Open Command Palette**: Press `Ctrl+Shift+P` (or `F1`)
2. **Select**: `Dev Containers: Reopen in Container`
3. **Wait**: First build takes 5-10 minutes (downloads images, installs packages)
4. **Ready**: When you see "Development environment ready!" in terminal

**What happens during build:**
- Downloads SQL Server 2022 image (~1.5GB)
- Downloads Bitnami Spark image (~1GB)
- Installs Python packages (PySpark, Jupyter, Pandas, etc.)
- Initializes SQL Server database with sample data
- Configures Spark cluster (master + worker)

### Step 3: Verify Everything is Running

Open a new terminal in VS Code (`Ctrl+Shift+\``) and run:

```bash
# Check all containers are running
docker ps

# You should see 5 containers:
# - fabric-jupyter (Jupyter Lab)
# - fabric-spark-master (Spark Master)
# - fabric-spark-worker (Spark Worker)
# - fabric-sqlserver (SQL Server - Primary)
# - fabric-sqlserver2 (SQL Server - Secondary)
```

### Step 4: Access Interfaces

Open these URLs in your browser:

- **Jupyter Lab**: http://localhost:8888 (No password required)
- **Spark UI** (Primary)**: `localhost:1433` (Connect from SQL tools)
- **SQL Server (Secondary)**: `localhost:14348080 (Monitor jobs and executors)
- **SQL Server**: `localhost:1433` (Connect from SQL tools)

---

## 📖 How to Use

### Running the Sample Notebook

1. In VS Code, navigate to `notebooks/` folder
2. Open `01-getting-started.ipynb`
3. Click **"Select Kernel"** → Choose **"Python 3"**
4. Click **"Run All"** or run cells individually with `Shift+Enter`

**What the notebook does:**
- Connects to SQL Server
- Reads sample sales data
- Performs PySpark transformations
- Writes results back to SQL Server
- Shows visualizations

### Connecting to SQL Server


**Primary SQL Server:**
```python
jdbc_url = "jdbc:sqlserver://sqlserver:1433;databaseName=FabricDev"
properties = {
    "user": "sa",
    "password": "YourStrong@Passw0rd",
    "driver": "com.microsoft.sqlserver.jdbc.SQLServerDriver"
}
df = spark.read.jdbc(url=jdbc_url, table="dbo.Sales", properties=properties)
```

**Secondary SQL Server:**
```python
jdbc_url = "jdbc:sqlserver://sqlserver2:1433;databaseName=FabricDev2"
properties = {
    "user": "sa",
    "password": "YourStrong@Passw0rd",
    "driver": "com.microsoft.sqlserver.jdbc.SQLServerDriver"
}
df = spark.read.jdbc(url=jdbc_url, table="dbo.Sales", properties=properties)
```

**Or use the helper class:**
```python
from scripts.fabric_helper import FabricHelper

# Connect to primary
helper = FabricHelper()
df = helper.read_sql_table(spark, "dbo.Sales")

# Connect to secondary
helper2 = FabricHelper(use_secondary_db=True)
df2 = helper2.read_sql_table(spark, "dbo.Sales")

# Copy data between servers
helper.copy_between_servers(spark, "dbo.Sales", "dbo.SalesBackup")
```

**From SQL Client (Azure Data Studio, SSMS, DBeaver):**

**Primary Instance:**
- **Server**: `localhost,1433`
- **Username**: `sa`
- **Password**: `YourStrong@Passw0rd`
- **Database**: `FabricDev`

**Secondary Instance:**
- **Server**: `localhost,1434`
- **Username**: `sa`
- **Password**: `YourStrong@Passw0rd`
- **Database**: `FabricDev2` (you'll need to create this)@Passw0rd`
- **Database**: `FabricDev`

### Creating New Notebooks

```bash
# In VS Code terminal (inside container)
cd /opt/notebooks

# Create new notebook
touch my-new-notebook.ipynb

# Or use Jupyter Lab UI at http://localhost:8888
```

### Working with Your Own Data

**CSV Files:**
```python
# Place CSV in data/ folder, then in notebook:
df = spark.read.option("header", "true").csv("/opt/data/your-file.csv")
```

**Parquet Files:**
```python
df = spark.read.parquet("/opt/data/your-file.parquet")
```

**SQL Server Tables:**
```python
df = spark.read.jdbc(url=jdbc_url, table="your_schema.your_table", properties=properties)
```

---

## 🔍 Power Query Development

This environment supports **Power Query (M language)** development alongside PySpark using a **hybrid approach**:

```
Power BI Desktop (Execution) + VS Code (Editing) + Docker SQL Server (Data Source)
```

### Quick Start with Power Query

1. **Install Power BI Desktop** (free from Microsoft)
   - Download: https://aka.ms/pbidesktopstore

2. **Connect Power BI Desktop to Docker SQL Server**
   - Get Data → SQL Server
   - Server: `localhost,1433`
   - Database: `FabricDev`
   - Authentication: sa / YourStrong@Passw0rd

3. **Develop Queries in Power BI**
   - Build transformations using Power Query Editor
   - Test with sample data
   - Open Advanced Editor to see M code

4. **Export to VS Code for Version Control**
   - Copy M code from Power BI Advanced Editor
   - Create `.pq` file in `queries/` folder
   - Edit with syntax highlighting and IntelliSense
   - Commit to Git for team sharing

5. **Import Back to Power BI**
   - Copy M code from `.pq` file in VS Code
   - Paste into Power BI Blank Query → Advanced Editor
   - Execute and verify results

### Power Query Features

✅ **M Language Syntax Highlighting** - VS Code extensions provide IntelliSense  
✅ **Connection to Docker SQL Server** - Power BI Desktop connects to `localhost,1433` and `localhost,1434`  
✅ **Sample .pq Files** - Pre-configured connections and transformation examples  
✅ **Version Control** - Store M code as text files in Git  
✅ **Reusable Functions** - Create `.pqm` function modules  
✅ **Parameterized Connections** - Easy environment switching  

### Learn More

- **Workflow Guide**: [docs/POWERQUERY-WORKFLOW.md](docs/POWERQUERY-WORKFLOW.md) - Complete hybrid development workflow
- **M Code Examples**: [queries/README.md](queries/README.md) - Sample queries and patterns
- **Power BI Setup**: [powerbi/README.md](powerbi/README.md) - Connection instructions and troubleshooting
- **VS Code Extensions**: [EXTENSIONS.md](EXTENSIONS.md) - Power Query SDK extension info

### When to Use Power Query vs PySpark

**Use Power Query** for:
- GUI-based development
- Business user-friendly transformations
- Power BI report development
- Quick data exploration
- Simple to moderate transformations

**Use PySpark** for:
- Large dataset processing (>1GB)
- Complex transformations and custom logic
- Machine learning and analytics
- Distributed computing needs
- Batch processing and automation

Both tools work great with this Docker environment! 🚀

---

## 🛠️ Common Tasks

### View Spark Logs

```bash
# From VS Code terminal
docker logs fabric-spark-master
docker logs fabric-spark-worker
```

### Restart Services

```bash
# Restart all containers
docker-compose restart

# Restart specific service
docker-compose restart jupyter
docker-compose restart sqlserver
```

### Stop Environment

```bash
# Stop all containers
docker-compose stop

# Stop and remove containers (keeps data volumes)
docker-compose down

# Stop and remove everything including data
docker-compose down -v
```

### Add Python Packages

1. Edit `requirements.txt`
2. Rebuild containers:
   ```bash
   docker-compose build
   docker-compose up -d
   ```

### Scale Spark1434, 8080, or 8888 are taken:

```yaml
# Edit docker-compose.yml, change ports:
ports:
  - "1435:1433"  # Changed from 1433:1433 or 1434

---

## 📁 Project Structure

```
fabric-local-dev/
├── .devcontainer/
│   └── devcontainer.json          # VS Code container configuration
├── .vscode/
│   ├── settings.json              # Workspace settings
│   ├── tasks.json                 # Quick tasks
│   └── extensions.json            # Recommended extensions
├── docker/
│   ├── spark/
│   │   └── Dockerfile             # Custom Spark image with PySpark
│   └── sql/
│       └── init.sql               # SQL Server initialization script
├── notebooks/
│   ├── 01-getting-started.ipynb   # Sample notebook - basics
│   ├── 02-dual-sql-server.ipynb   # Sample notebook - dual instances
│   └── README.md                  # Notebook guide
├── data/
│   ├── sample-products.csv        # Sample data file
│   └── README.md                  # Data folder guide
├── scripts/
│   ├── fabric_helper.py           # Python utility functions
│   └── README.md                  # Scripts guide
├── docs/
│   └── README.md                  # Documentation index
├── docker-compose.yml              # Container orchestration
├── requirements.txt                # Python dependencies
├── fabric-local-dev.code-workspace # VS Code workspace (USE THIS!)
├── start.ps1                       # Quick-start PowerShell script
├── README.md                       # This file
├── PROGRESS.md                     # Step-by-step setup checklist
├── WORKSPACE.md                    # Workspace organization guide
├── EXTENSIONS.md                   # VS Code extensions guide
└── SETUP-COMMANDS.md               # Complete command reference
```

---

## 🔍 Troubleshooting

### Port Already in Use

If ports 1433, 8080, or 8888 are taken:

```yaml
# Edit docker-compose.yml, change ports:
ports:
  - "1434:1433"  # Changed from 1433:1433
```

### SQL Server Won't Start

```bash
# Check logs
docker logs fabric-sqlserver

# Common fix: Increase Docker memory
# Docker Desktop → Settings → Resources → Memory (min 4GB)
```

### Spark Jobs Failing

```bash
# Check Spark UI at http://localhost:8080
# Look at "Executors" and "Environment" tabs

# Check worker logs
docker logs fabric-spark-worker
```

### Jupyter Kernel Not Found

1. In VS Code, Command Palette: `Python: Select Interpreter`
2. Choose `/usr/bin/python3`
3. Restart Jupyter kernel

### Container Build Fails

```bash
# Clean build (removes cached layers)
docker-compose build --no-cache

# If still failing, remove everything and rebuild
docker-compose down -v
docker-compose up --build
```

---

## 🎯 Best Practices

### Development Workflow

1. **Write code in notebooks** - Interactive development
2. **Test with sample data** - Use small datasets first
3. **Refactor to Python scripts** - Move production code to `scripts/`
4. **Version control** - Commit notebooks and scripts to Git
5. **Deploy to Fabric** - Copy tested code to Fabric notebooks

### Performance Tips

- **Use `df.cache()`** for DataFrames you access multiple times
- **Use `coalesce()`** to reduce partition count for small datasets
- **Monitor Spark UI** to identify bottlenecks
- **Use Parquet format** for intermediate data (faster than CSV)

### Security Notes

⚠️ **This is a DEVELOPMENT environment only!**

- Default passwords are used (change for shared environments)
- No encryption configured
- No authentication on Jupyter (anyone can access)
- **NEVER use this setup for production data!**

For production:
- Change all passwords in `docker-compose.yml`
- Enable Jupyter authentication
- Use secure networks
- Enable SQL Server encryption

---

## 🚀 Next Steps

### Learn More

- **PySpark Documentation**: https://spark.apache.org/docs/latest/api/python/
- **Microsoft Fabric Docs**: https://learn.microsoft.com/en-us/fabric/
- **Jupyter Notebook Tips**: https://jupyter.org/

### Extend This Setup

- Add **Azure Storage** connection for cloud data
- Configure **Delta Lake** for ACID transactions
- Add **Apache Kafka** for streaming data
- Integrate **Power BI** for visualization
- Add **MLflow** for machine learning tracking

### Deploy to Fabric

When ready to move to production:
1. Copy your notebook code to Fabric
2. Update connection strings to Fabric resources
3. Use Fabric's managed Spark pools
4. Connect to Fabric's SQL analytics endpoint

---

## 📞 Support

- **Setup issues**: Check [PROGRESS.md](PROGRESS.md) for step-by-step checklist
- **Cproject is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Component Licenses:**
- Apache Spark: Apache License 2.0
- SQL Server Developer Edition: Free for dev/test (Microsoft EULA)
- Python packages: Various open-source licenses

## 👤 Author

**Ivan Lima**
- GitHub: [@mrivanlima](https://github.com/mrivanlima)

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/mrivanlima/fabric-local-dev/issues).

## ⭐ Show Your Support

Give a ⭐️ if this project helped you!

## 🙏 Acknowledgments

- Microsoft Fabric team for inspiration
- Apache Spark community
- Docker and VS Code Dev Containers team
---

## 📝 License

This is a development environment template. Use and modify as needed.

**Component Licenses:**
- Apache Spark: Apache License 2.0
- SQL Server Developer Edition: Free for dev/test (Microsoft EULA)
- Python packages: Various open-source licenses

---

## ✅ Quick Reference Card

| Component | URL/Connection | Credentials |
|-----------|---------------|-------------|
| Jupyter Lab | http://localhost:8888 | No password |
| Spark UI | http://localhost:8080 | No auth |
| SQL Server (Primary) | localhost:1433 | sa / YourStrong@Passw0rd |
| SQL Server (Secondary) | localhost:1434 | sa / YourStrong@Passw0rd |
| Database (Primary) | FabricDev | - |
| Database (Secondary) | FabricDev2 | Create manually |

**Key Commands:**
```bash
# Start everything
docker-compose up -d

# Stop everything
docker-compose stop

# View logs
docker-compose logs -f

# Restart a service
docker-compose restart jupyter

# Rebuild after changes
docker-compose up --build
```

---

**Happy Coding! 🎉**
