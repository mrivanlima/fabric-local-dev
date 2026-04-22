# Fabric Local Development Environment - Setup Log

This file documents all commands and steps taken to set up this development environment.

**Date:** April 22, 2026  
**Purpose:** Create a local Microsoft Fabric-like development environment using Docker

---

## Step 1: Create Project Structure

```powershell
# Create main project directory
mkdir C:\Development\fabric-local-dev

# Navigate to project directory
cd C:\Development\fabric-local-dev
```

**What this does:** Creates the root folder for our entire project. All configuration files, notebooks, and scripts will live here.

**SQL Server Version:** SQL Server 2025 Developer Edition (latest) - 2 instances for testing data movement scenarios

---

## Step 2: Create Folder Structure

```powershell
# Create all subdirectories
mkdir .devcontainer
mkdir docker\spark
mkdir docker\sql
mkdir notebooks
mkdir data
mkdir scripts
```

**Folder purposes:**
- `.devcontainer/` - VS Code Dev Container configuration (tells VS Code how to connect to containers)
- `docker/spark/` - Custom PySpark container configuration
- `docker/sql/` - SQL Server initialization scripts
- `notebooks/` - Your Jupyter notebooks for data processing
- `data/` - Sample data files and datasets
- `scripts/` - Python utility scripts

---

## Step 3: Build and Start Containers

```powershell
# Navigate to project directory
cd C:\Development\fabric-local-dev

# Build all Docker images (first time takes 5-10 minutes)
docker-compose build

# Start all containers in background
docker-compose up -d

# Check if all containers are running
docker ps
```

**What this does:**5 image
- Starts 5 containers: Jupyter, Spark Master, Spark Worker, SQL Server (Primary), SQL Server (Secondary)
- Initializes primary SQL Server with sample database
- Creates network for container communication

**Expected output:** You should see 5 running containers:
- `fabric-jupyter`
- `fabric-spark-master`
- `fabric-spark-worker`
- `fabric-sqlserver` (Primary - port 1433)
- `fabric-sqlserver2` (Secondary - port 1434)er`
- `fabric-spark-worker`
- `fabric-sqlserver`

---

## Step 4: Open in VS Code Dev Container

```powershell
# Make sure you're in the project directory
cd C:\Development\fabric-local-dev

# Open VS Code
code .
```

**Then in VS Code:**
1. Press `Ctrl+Shift+P` (Command Palette)
2. Type: "Dev Containers: Reopen in Container"
3. Select it and press Enter
4. Wait for container connection (30-60 seconds)

**What this does:**
- VS Code connects to the Jupyter container
- Installs VS Code server inside container
- Installs all recommended extensions (Python, Jupyter, SQL Server)
- Maps your local files to container
- Gives you full IDE capabilities inside the container

---

## Step 5: Verify Setup

```bash
# Run these commands in VS Code terminal (Ctrl+`)

# Check Python version
python3 --version

# Check PySpark
python3 -c "import pyspark; print(f'PySpark {pyspark.__version__}')"

# Check SQL Server connection
docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT @@VERSION"

# List running Spark applications
curl http://localhost:8080
```

**What to expect:**
- Python 3.11+
- PySpark 3.5.0
- SQL Server 2025 version info
- Spark Master UI HTML response

---

## Step 6: Access Interfaces

Open these URLs in your browser:

```powershell
# Open Jupyter Lab
start http://localhost:8888

# Open Spark Master UI
start http://localhost:8080
```

**What you'll see:**
- **Jupyter Lab** - File browser with `notebooks/` folder
- **Spark UI** - Master status, workers, running applications

---

## Step 7: Run Sample Notebook

In VS Code:
1. Open: `notebooks/01-getting-started.ipynb`
2. Select Kernel: Click "Select Kernel" → "Python 3"
3. Run All: Click "Run All" button or `Ctrl+Alt+Shift+Enter`

**What happens:**
- Connects to Spark cluster
- Reads data from SQL Server
- Performs transformations
- Writes results back to SQL Server
- Creates visualizations

---

## Step 8: Connect to SQL Server (Optional)

**Using Azure Data Studio or SSMS:**

**Primary SQL Server:**
```
Server: localhost,1433
Authentication: SQL Server Authentication
Username: sa
Password: YourStrong@Passw0rd
Database: FabricDev
```

**Secondary SQL Server:**
```
Server: localhost,1434
Authentication: SQL Server Authentication
Username: sa
Password: YourStrong@Passw0rd
Database: (Create FabricDev2 manually or use master)
```

**Using VS Code SQL Server Extension:**
1. Click SQL Server icon in sidebar
2. Add Connection
3. Enter connection details above

**Query sample data:**
```sql
-- Primary instance
USE FabricDev;
SELECT * FROM dbo.Sales;
SELECT * FROM dbo.SalesSummary;

-- Secondary instance (connect to localhost,1434)
CREATE DATABASE FabricDev2;
USE FabricDev2;
-- Create tables as needed
```

---

## Common Commands Reference

### Docker Management

```powershell
# View all containers (running and stopped)
docker ps -a

# View logs for specific container
docker logs fabric-jupyter
docker logs fabric-sqlserver
docker logs fabric-spark-master

# Follow logs in real-time
docker logs -f fabric-jupyter

# Restart a specific service
docker-compose restart jupyter
docker-compose restart sqlserver

# Stop all containers
docker-compose stop

# Start all containers
docker-compose start

# Stop and remove containers (keeps data)
docker-compose down

# Remove everything including data volumes
docker-compose down -v

# Rebuild after changing configuration
docker-compose up --build

# View Docker resource usage
docker stats
```

### VS Code Dev Container

```powershell
# Reopen in container (from VS Code Command Palette)
# Ctrl+Shift+P → "Dev Containers: Reopen in Container"

# Reopen locally (exit container)
# Ctrl+Shift+P → "Dev Containers: Reopen Folder Locally"

# Rebuild container without cache
# Ctrl+Shift+P → "Dev Containers: Rebuild Container"

# Rebuild and reopen
# Ctrl+Shift+P → "Dev Containers: Rebuild and Reopen in Container"
```

### Inside Container (VS Code Terminal)

```bash
# Check where you are
pwd
# Should show: /opt/notebooks

# List files in notebooks directory
ls -la /opt/notebooks

# Check installed Python packages
pip list

# Install additional package
pip install your-package-name

# Check Spark configuration
spark-submit --version

# Test SQL Server connection
python3 -c "import pymssql; print('SQL Server driver installed')"

# Create new notebook
touch /opt/notebooks/my-notebook.ipynb
```

### Jupyter Lab (Terminal within Jupyter)

```bash
# Access at http://localhost:8888
# Click "+" → "Terminal"

# List data files
ls -la /opt/data

# View CSV file
head /opt/data/sample-products.csv

# Check Spark cluster
curl spark-master:8080
```

---

## Maintenance Commands

### Update Python Packages

```powershell
# 1. Edit requirements.txt (add your packages)
# 2. Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Clear All Data and Start Fresh

```powershell
# WARNING: This deletes ALL data!
docker-compose down -v
docker-compose up --build
```

### Backup SQL Server Database

```powershell
# Create backup
docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "BACKUP DATABASE FabricDev TO DISK = '/var/opt/mssql/backup/FabricDev.bak'"

# Copy backup to local machine
docker cp fabric-sqlserver:/var/opt/mssql/backup/FabricDev.bak ./FabricDev.bak
```

### Export Notebook as Python Script

```python
# In Jupyter Lab, or using command:
jupyter nbconvert --to script /opt/notebooks/01-getting-started.ipynb
```

---

## Troubleshooting Commands

### Check Container Health

```powershell
# See which containers are running
docker-compose ps

# Check specific container health
docker inspect fabric-sqlserver --format='{{.State.Health.Status}}'

# View last 100 log lines
docker logs --tail 100 fabric-sqlserver
```

### Network Issues

```powershell
# Check if containers can communicate
docker exec fabric-jupyter ping -c 3 sqlserver
docker exec fabric-jupyter ping -c 3 spark-master

# List Docker networks
docker network ls

# Inspect fabric network
docker network inspect fabric-local-dev_fabric-network
```

### Resourcprimary SQL Server is ready
docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT 1"

# Check if secondary SQL Server is ready
docker exec fabric-sqlserver2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT 1"

# View SQL Server error log (primary)
docker exec fabric-sqlserver cat /var/opt/mssql/log/errorlog

# View SQL Server error log (secondary)
docker exec fabric-sqlserver2 cat /var/opt/mssql/log/errorlog

# List databases (primary)
docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT name FROM sys.databases"

# List databases (secondary)
docker exec fabric-sqlserver2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT name FROM sys.databases"

# Create database on secondary instance
docker exec fabric-sqlserver2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "CREATE DATABASE FabricDev2

# Clean up unused images/containers
docker system prune
```

### SQL Server Specific

```powershell
# Check if SQL Server is ready
docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT 1"

# View SQL Server error log
docker exec fabric-sqlserver cat /var/opt/mssql/log/errorlog

# List databases
docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT name FROM sys.databases"
```

---

## Performance Optimization

### Scale Spark Workers

```powershell
# Add more workers for parallel processing
docker-compose up -d --scale spark-worker=3

# Check all workers are connected
# Visit http://localhost:8080
```

### Allocate More Memory

Edit `docker-compose.yml`:
```yaml
spark-worker:
  environment:
    - SPARK_WORKER_MEMORY=4G  # Increase from 2G
    - SPARK_WORKER_CORES=4    # Increase from 2
```

Then restart:
```powershell
docker-compose down
docker-compose up -d
```

---

## Git Integration

### Initialize Repository

```powershell
cd C:\Development\fabric-local-dev

# Initialize Git repo
git init

# Add all files
git add .

# Commit
git commit -m "Initial setup: Fabric local dev environment"

# Add remote (if using GitHub/Azure DevOps)
git remote add origin https://github.com/yourusername/fabric-local-dev.git
git push -u origin main
```

### Useful .gitignore

Already included in project. Key exclusions:
- `.env` files (passwords)
- `__pycache__/` (Python cache)
- `.ipynb_checkpoints/` (Jupyter checkpoints)
- Docker volumes
- Local data files

---

## Next Steps After Setup

1. ✅ Run the sample notebook `01-getting-started.ipynb`
2. ✅ Connect to SQL Server and explore the sample data
3. ✅ Create your own notebook
4. ✅ Add your own data to `data/` folder
5. ✅ Modify SQL initialization script for your schema
6. ✅ Commit your work to Git

---

## Summary: Complete Setup in One Go

```powershell
# Full setup commands (copy-paste friendly)
cd C:\Development\fabric-local-dev
docker-compose build
docker-compose up -d
code .
# Then: Ctrl+Shift+P → "Dev Containers: Reopen in Container"
```

**Wait for:** Container connection + extension installation (2-3 minutes)

**Then:** Open `notebooks/01-getting-started.ipynb` and run it!

---

**Setup completed successfully! 🎉**

All files created, containers ready, VS Code configured.
Your local Microsoft Fabric development environment is ready to use!
