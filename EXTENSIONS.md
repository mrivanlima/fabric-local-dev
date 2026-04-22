# VS Code Extensions Guide

This document lists all VS Code extensions configured for the Fabric Local Development environment.

## 📦 Installed Extensions (Auto-installed in Dev Container)

### Python Development
| Extension | ID | Purpose |
|-----------|----|------------|
| Python | `ms-python.python` | Core Python language support, debugging, testing |
| Pylance | `ms-python.vscode-pylance` | Fast IntelliSense, type checking, auto-completion |
| Jupyter | `ms-toolsai.jupyter` | Jupyter notebook support in VS Code |
| Jupyter Cell Tags | `ms-toolsai.vscode-jupyter-cell-tags` | Organize and tag notebook cells |

**Why these?** Essential for PySpark development and interactive notebooks.

---

### Database & SQL
| Extension | ID | Purpose |
|-----------|----|------------|
| SQL Server (mssql) | `ms-mssql.mssql` | Connect to SQL Server, run queries, view results |

**Why this?** Direct SQL Server connectivity from VS Code - query both instances (1433, 1434).

**Usage:**
- Click SQL Server icon in sidebar
- Add connection: `localhost,1433` and `localhost,1434`
- Run queries directly from `.sql` files

---

### Power Query / M Language
| Extension | ID | Purpose |
|-----------|----|------------|
| PowerQuery SDK | `powerquery.vscode-powerquery-sdk` | Official M language support with IntelliSense, formatting, and evaluation |
| Power Query | `powerquery.vscode-powerquery` | M language syntax highlighting and code snippets |

**Why these?** Enable Power Query (M language) development in VS Code alongside PySpark.

**What you can do:**
- Write and edit `.pq` and `.pqm` files with syntax highlighting
- Get IntelliSense for M language functions
- Format M code automatically
- Develop queries for use in Power BI Desktop or Microsoft Fabric

**Important Note:** These extensions provide **editing support only**. To execute Power Query code, you need:
- **Power BI Desktop** (Windows) - Recommended for local execution
- **Microsoft Fabric** - Cloud execution
- **Excel** - Limited M query support

**Workflow:**
1. Develop queries in Power BI Desktop connected to Docker SQL Server (`localhost,1433`)
2. Copy M code from Advanced Editor to VS Code `.pq` files for version control
3. Edit and refine in VS Code with syntax highlighting
4. Copy back to Power BI Desktop to test and execute

See [`docs/POWERQUERY-WORKFLOW.md`](docs/POWERQUERY-WORKFLOW.md) for detailed workflow guide.

**File Types:**
- `.pq` - Power Query files (queries/tables)
- `.pqm` - Power Query Module files (reusable functions)
- `.m` - Generic M language files

---

### Data Tools
| Extension | ID | Purpose |
|-----------|----|------------|
| Data Wrangler | `ms-toolsai.datawrangler` | View and explore DataFrames and CSV files |
| Rainbow CSV | `mechatroner.rainbow-csv` | Colorize CSV columns for easy reading |

**Why these?** Better data exploration and CSV file viewing.

---

### Code Quality
| Extension | ID | Purpose |
|-----------|----|------------|
| Black Formatter | `ms-python.black-formatter` | Python code auto-formatting (PEP 8 style) |
| Pylint | `ms-python.pylint` | Python code linting and error detection |

**Why these?** Keep your code clean and consistent. Auto-format on save enabled.

---

### Docker & DevOps
| Extension | ID | Purpose |
|-----------|----|------------|
| Docker | `ms-azuretools.vscode-docker` | Manage containers, view logs, inspect images |
| YAML | `redhat.vscode-yaml` | YAML syntax highlighting and validation |

**Why these?** 
- Manage Docker containers without leaving VS Code
- Edit docker-compose.yml with validation and auto-complete

---

### Documentation & Productivity
| Extension | ID | Purpose |
|-----------|----|------------|
| GitLens | `eamodio.gitlens` | Enhanced Git integration, blame, history |
| Prettier | `esbenp.prettier-vscode` | Format JSON, YAML, Markdown |
| Markdown All in One | `yzhang.markdown-all-in-one` | Markdown preview, TOC, shortcuts |
| Markdown Mermaid | `bierner.markdown-mermaid` | Render Mermaid diagrams in Markdown |

**Why these?** Better documentation, Git workflow, and file formatting.

---

## 🚀 Extension Features You'll Use

### 1. Python IntelliSense (Pylance)
- **Auto-completion** as you type
- **Parameter hints** for functions
- **Import suggestions**
- **Type checking**

### 2. Jupyter Notebooks
- **Run cells** with Shift+Enter
- **Variable explorer** - see all variables
- **Kernel selection** - choose Python environment
- **Output inline** - graphs, tables, text

### 3. SQL Server Extension
- **Query execution** - Ctrl+Shift+E
- **Results view** - table format
- **Connection management** - save connections
- **Object explorer** - browse databases/tables

### 4. Docker Extension
- **Container list** - see all running containers
- **Logs viewer** - real-time container logs
- **Shell access** - open terminal in container
- **Image management** - build, pull, remove

### 5. Git Integration (GitLens)
- **Inline blame** - see who changed each line
- **Commit history** - per file or project
- **File comparison** - diff view
- **Branch management**

### 6. Power Query Extension
- **Syntax highlighting** - M language syntax colored
- **IntelliSense** - Auto-complete M functions
- **Formatting** - Right-click → Format Document
- **Code snippets** - Type common patterns

**Example M Code:**
```m
// Sample Power Query - connect to Docker SQL Server
let
    Source = Sql.Database("localhost,1433", "FabricDev"),
    dbo_Sales = Source{[Schema="dbo",Item="Sales"]}[Data],
    FilteredRows = Table.SelectRows(dbo_Sales, each [TotalAmount] > 100)
in
    FilteredRows
```

---

## ⚙️ Pre-configured Settings

These settings are automatically applied in the Dev Container:

### Python Settings
```json
"python.defaultInterpreterPath": "/usr/bin/python3"
"python.linting.enabled": true
"python.formatting.provider": "black"
```

### Editor Settings
```json
"editor.formatOnSave": true  // Auto-format when you save
"files.autoSave": "afterDelay"  // Auto-save after 1 second
```

### Jupyter Settings
```json
"jupyter.notebookFileRoot": "/opt/notebooks"
```

### Power Query Settings
```json
"[powerquery]": {
  "editor.defaultFormatter": "powerquery.vscode-powerquery-sdk",
  "editor.formatOnSave": true,
  "editor.tabSize": 2
}
```

---
4. **Power Query SDK** (`powerquery.vscode-powerquery-sdk`) - For editing .pq files on local machine

**How to install:**
1. Press `Ctrl+Shift+X`
2. Search for extension name
3. Click "Install"

**Note:** Power Query extensions work both locally and in container. Install locally if you edit `.pq` files before opening workspace.
### Recommended Local Extensions:
1. **Dev Containers** (`ms-vscode-remote.remote-containers`) - **REQUIRED**
2. **Docker** (`ms-azuretools.vscode-docker`) - **RECOMMENDED**
3. **PowerShell** (`ms-vscode.powershell`) - For editing .ps1 scripts locally

**How to install:**
1. Press `Ctrl+Shift+X`
2. Search for extension name
3. Click "Install"

---

## 📝 Keyboard Shortcuts

### Jupyter Notebooks
| Shortcut | Action |
|----------|--------|
| `Shift+Enter` | Run current cell and move to next |
| `Ctrl+Enter` | Run current cell |
| `Alt+Enter` | Run current cell and insert below |
| `Ctrl+Shift+P` → "Jupyter: Select Kernel" | Choose Python environment |

### Python Development
| Shortcut | Action |
|----------|--------|
| `F5` | Start debugging |
| `Shift+Alt+F` | Format document (Black) |
| `Ctrl+Space` | Trigger IntelliSense |
| `F12` | Go to definition |

### SQL Server
| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+E` | Execute query |
| `Ctrl+Shift+C` | New connection |

### General
| Shortcut | Action |
|----------|--------|
| `` Ctrl+` `` | Toggle terminal |
| `Ctrl+Shift+P` | Command Palette |
| `Ctrl+P` | Quick file open |
| `Ctrl+Shift+F` | Search in files |

---

## 🎯 Extension Usage Tips

### 1. SQL Server Extension
```sql
-- Create a .sql file and write queries
-- Connect: Ctrl+Shift+P → "MS SQL: Connect"
-- Execute: Ctrl+Shift+E

USE FabricDev;
SELECT * FROM dbo.Sales;
```

### 2. Docker Extension
- **View logs:** Right-click container → "View Logs"
- **Open shell:** Right-click container → "Attach Shell"
- **Restart:** Right-click container → "Restart"

### 3. Data Wrangler
- **Open:** Right-click CSV file → "Open in Data Wrangler"
- **Filter, sort, transform** data visually
- **Export** transformations as Python code

### 4. Jupyter Variables
- **View variables:** Click "Variables" button in notebook toolbar
- See all DataFrames, values, types
- Click to inspect or visualize

---

## 🔄 Extension Updates

Extensions update automatically in the Dev Container. To force update:
1. `Ctrl+Shift+P`
2. Type: "Dev Containers: Rebuild Container"
3. This reinstalls all extensions

---

## ❓ Troubleshooting Extensions

### Extension not working?
```
Ctrl+Shift+P → "Developer: Reload Window"
```

### Python extension issues?
```
Ctrl+Shift+P → "Python: Select Interpreter"
Choose: /usr/bin/python3
```

### Jupyter kernel not found?
```
Ctrl+Shift+P → "Jupyter: Select Kernel"
Choose: Python 3.11.x
```

---

## 📚 Extension Documentation

- **Python:** https://code.visualstudio.com/docs/python/python-tutorial
- **Jupyter:** https://code.visualstudio.com/docs/datascience/jupyter-notebooks
- **SQL Server:** https://learn.microsoft.com/en-us/sql/tools/visual-studio-code/mssql-extensions
- **Docker:** https://code.visualstudio.com/docs/containers/overview

---

## ✅ Verification

After opening in Dev Container, verify all extensions are installed:

1. Open Extensions panel: `Ctrl+Shift+X`
2. Filter by "Installed"
3. You should see all extensions listed above
4. If any are missing: `Ctrl+Shift+P` → "Dev Containers: Rebuild Container"

---

**All extensions are configured and ready to use! 🎉**
