# Scripts Directory

Python helper scripts and utilities for the Fabric development environment.

## 📦 Available Scripts

### fabric_helper.py
**Purpose:** Common operations for PySpark and SQL Server

**Classes:**
- `FabricHelper` - Main helper class with database operations

**Quick Functions:**
- `get_spark()` - Get Spark session
- `read_table(table_name)` - Read from primary SQL Server
- `write_table(df, table_name)` - Write to primary SQL Server

**Usage in Notebooks:**
```python
from scripts.fabric_helper import FabricHelper

# Connect to primary SQL Server
helper = FabricHelper()
spark = helper.create_spark_session()
df = helper.read_sql_table(spark, "dbo.Sales")

# Connect to secondary SQL Server
helper2 = FabricHelper(use_secondary_db=True)
df2 = helper2.read_sql_table(spark, "dbo.Sales")

# Copy data between servers
helper.copy_between_servers(spark, "dbo.Sales", "dbo.SalesBackup")
```

---

## 🔧 Creating New Scripts

### Template for New Helper Script:

```python
"""
Module: my_helper.py
Purpose: Description of what this script does
"""

import os
from pyspark.sql import SparkSession

def my_function(param1, param2):
    """
    Function description
    
    Args:
        param1: Description
        param2: Description
        
    Returns:
        Description of return value
    """
    # Your code here
    pass

# Example usage
if __name__ == "__main__":
    print("Testing my_helper.py")
    result = my_function("test", 123)
    print(f"Result: {result}")
```

---

## 📝 Script Best Practices

### 1. Documentation
- Docstrings for modules, classes, and functions
- Type hints for parameters
- Example usage in docstrings

### 2. Error Handling
```python
def safe_function():
    try:
        # Your code
        pass
    except Exception as e:
        print(f"Error: {e}")
        raise
```

### 3. Logging
```python
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

logger.info("Operation started")
logger.error("Something went wrong")
```

### 4. Testing
```python
if __name__ == "__main__":
    # Test code here
    print("Running tests...")
```

---

## 🎯 Common Patterns

### Pattern 1: SQL Connection Helper
```python
def get_sql_connection(host='sqlserver', database='FabricDev'):
    """Get SQL Server connection"""
    import pymssql
    return pymssql.connect(
        server=host,
        user='sa',
        password='YourStrong@Passw0rd',
        database=database
    )
```

### Pattern 2: DataFrame Validator
```python
def validate_dataframe(df, required_columns):
    """Validate DataFrame has required columns"""
    missing = set(required_columns) - set(df.columns)
    if missing:
        raise ValueError(f"Missing columns: {missing}")
    return True
```

### Pattern 3: Data Quality Checker
```python
def check_nulls(df, column):
    """Check for null values in column"""
    null_count = df.filter(df[column].isNull()).count()
    total_count = df.count()
    null_pct = (null_count / total_count) * 100
    return {
        'column': column,
        'null_count': null_count,
        'null_percentage': null_pct
    }
```

---

## 📚 Useful Utilities to Add

### 1. Data Profiler
```python
def profile_dataframe(df):
    """Generate data profile report"""
    return {
        'row_count': df.count(),
        'column_count': len(df.columns),
        'columns': df.columns,
        'dtypes': df.dtypes,
        'null_counts': {col: df.filter(df[col].isNull()).count() 
                       for col in df.columns}
    }
```

### 2. Connection Tester
```python
def test_connections():
    """Test all connection endpoints"""
    results = {}
    
    # Test Spark
    try:
        spark = SparkSession.builder.master("spark://spark-master:7077").getOrCreate()
        results['spark'] = 'OK'
    except Exception as e:
        results['spark'] = f'Failed: {e}'
    
    # Test SQL Server
    try:
        import pymssql
        conn = pymssql.connect(server='sqlserver', user='sa', 
                              password='YourStrong@Passw0rd')
        results['sqlserver'] = 'OK'
        conn.close()
    except Exception as e:
        results['sqlserver'] = f'Failed: {e}'
    
    return results
```

### 3. Performance Monitor
```python
import time

def time_operation(func):
    """Decorator to time function execution"""
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        duration = time.time() - start
        print(f"{func.__name__} took {duration:.2f} seconds")
        return result
    return wrapper

@time_operation
def my_slow_function():
    # Your code
    pass
```

---

## 🧪 Testing Scripts

### Run Script Tests:
```bash
# In VS Code terminal (inside container)
cd /opt/scripts
python3 fabric_helper.py
```

### Import in Python:
```python
import sys
sys.path.append('/opt/scripts')

from fabric_helper import FabricHelper
```

---

## 📖 Adding to Requirements

If your script needs new packages:

1. Edit `requirements.txt` in project root
2. Add package: `new-package==version`
3. Rebuild container:
   ```bash
   docker-compose build
   docker-compose up -d
   ```

---

## ✅ Script Checklist

- [ ] Clear purpose and documentation
- [ ] Error handling
- [ ] Type hints
- [ ] Example usage
- [ ] Test code in `if __name__ == "__main__"`
- [ ] Updated this README if new script

---

**Keep your scripts organized and well-documented! 🐍**
