# Notebooks Directory

This directory contains Jupyter notebooks for data processing and analysis.

## 📚 Available Notebooks

### 1. Getting Started (01-getting-started.ipynb)
**Purpose:** Introduction to the environment  
**Topics:**
- Connecting to Spark cluster
- Reading from SQL Server
- Basic PySpark transformations
- Writing results back
- Data visualization

**Run this first!**

### 2. Dual SQL Server (02-dual-sql-server.ipynb)
**Purpose:** Working with both SQL Server instances  
**Topics:**
- Connecting to primary and secondary instances
- Data migration between servers
- Data comparison and validation
- ETL workflows

**Prerequisites:** Create FabricDev2 database on secondary instance

---

## 🎯 Notebook Best Practices

### Structure Your Notebooks

```python
# 1. Imports and Setup
from pyspark.sql import SparkSession
from scripts.fabric_helper import FabricHelper

# 2. Initialize Spark
spark = SparkSession.builder.appName("MyApp").getOrCreate()

# 3. Load Data
df = helper.read_sql_table(spark, "dbo.MyTable")

# 4. Transform Data
df_transformed = df.filter(...).groupBy(...)

# 5. Save Results
helper.write_sql_table(df_transformed, "dbo.Results")

# 6. Cleanup
# spark.stop()  # Usually not needed in notebooks
```

### Naming Conventions

Use numbered prefixes for ordering:
- `01-getting-started.ipynb`
- `02-dual-sql-server.ipynb`
- `03-your-analysis.ipynb`

### Cell Organization

**Markdown cells for:**
- Section headers
- Explanations
- Documentation
- Results interpretation

**Code cells for:**
- One logical operation per cell
- Keep cells small and focused
- Add comments for complex logic

---

## 🚀 Creating New Notebooks

### From VS Code:
1. Right-click `notebooks/` folder
2. New File
3. Name it: `03-your-notebook.ipynb`
4. Select Python 3 kernel

### From Jupyter Lab:
1. Open http://localhost:8888
2. Click "+" (New Launcher)
3. Click "Notebook" under Python 3
4. File → Rename

### From Terminal:
```bash
cd /opt/notebooks
touch 03-my-analysis.ipynb
```

---

## 📦 Common Imports

```python
# PySpark
from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col, sum, avg, count, max, min,
    round, lit, current_timestamp,
    when, concat, split
)

# Helper functions
from scripts.fabric_helper import (
    FabricHelper,
    get_spark,
    read_table,
    write_table
)

# Data manipulation
import pandas as pd
import numpy as np

# Visualization
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.express as px

# Utilities
from datetime import datetime
import os
```

---

## 🔧 Using Helper Functions

### Quick Functions
```python
# Easiest way - uses defaults
spark = get_spark()
df = read_table("dbo.Sales")
write_table(df, "dbo.Results")
```

### Helper Class (More Control)
```python
# Primary SQL Server
helper = FabricHelper()
df = helper.read_sql_table(spark, "dbo.Sales")
helper.display_summary(df)

# Secondary SQL Server
helper2 = FabricHelper(use_secondary_db=True)
df2 = helper2.read_sql_table(spark, "dbo.Sales")

# Copy between servers
helper.copy_between_servers(spark, "dbo.Sales", "dbo.SalesCopy")
```

---

## 💡 Tips & Tricks

### 1. Cell Magic Commands
```python
%%time
# Measure cell execution time
df.count()
```

### 2. Display DataFrames
```python
# Show with more rows/columns
df.show(20, truncate=False)

# Convert to Pandas for better display
df.limit(10).toPandas()

# Use display() for rich output
display(df.limit(10))
```

### 3. SQL in Notebooks
```python
# Register as temp view
df.createOrReplaceTempView("sales_view")

# Run SQL
result = spark.sql("""
    SELECT Region, SUM(TotalAmount) as Revenue
    FROM sales_view
    GROUP BY Region
""")
```

### 4. Debugging
```python
# Print schema
df.printSchema()

# Sample data
df.show(5)

# Execution plan
df.explain()

# Count rows
print(f"Rows: {df.count()}")
```

### 5. Performance
```python
# Cache frequently accessed DataFrames
df.cache()

# Reduce partitions for small data
df.coalesce(1)

# Monitor in Spark UI
# http://localhost:8080
```

---

## 📊 Visualization Examples

### Matplotlib
```python
import matplotlib.pyplot as plt

pdf = df.toPandas()
plt.figure(figsize=(10, 6))
plt.bar(pdf['Region'], pdf['TotalSales'])
plt.title('Sales by Region')
plt.xlabel('Region')
plt.ylabel('Sales ($)')
plt.xticks(rotation=45)
plt.show()
```

### Plotly (Interactive)
```python
import plotly.express as px

pdf = df.toPandas()
fig = px.bar(pdf, x='Region', y='TotalSales', 
             title='Sales by Region',
             color='TotalSales')
fig.show()
```

---

## 🐛 Troubleshooting

### Kernel Won't Start
1. `Ctrl+Shift+P` → "Jupyter: Select Kernel"
2. Choose "Python 3"
3. If still issues: Restart VS Code in container

### Import Errors
```python
# Add scripts to path
import sys
sys.path.append('/opt/scripts')
```

### Spark Connection Issues
```python
# Check Spark Master
spark.sparkContext.master
# Should show: spark://spark-master:7077

# Restart Spark session
spark.stop()
spark = SparkSession.builder.master("spark://spark-master:7077").getOrCreate()
```

### SQL Server Connection Issues
```python
# Test connection
import pymssql
conn = pymssql.connect(server='sqlserver', user='sa', 
                       password='YourStrong@Passw0rd', 
                       database='FabricDev')
conn.close()
print("Connected!")
```

---

## 📚 Learning Resources

- **PySpark DataFrame Guide:** https://spark.apache.org/docs/latest/api/python/reference/pyspark.sql.html
- **PySpark SQL Functions:** https://spark.apache.org/docs/latest/api/python/reference/pyspark.sql/functions.html
- **Jupyter Notebook Docs:** https://jupyter-notebook.readthedocs.io/

---

## ✅ Checklist for New Notebooks

- [ ] Meaningful name with number prefix
- [ ] Markdown cell at top explaining purpose
- [ ] Imports in first code cell
- [ ] Section headers (markdown cells)
- [ ] Comments in code cells
- [ ] Cell outputs cleared before committing
- [ ] Run "Restart & Run All" to verify
- [ ] Save and commit to Git

---

**Happy notebook development! 📓✨**
