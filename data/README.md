# Data Directory

This folder contains your data files for development and testing.

## Usage

Place your data files here to access them from notebooks and scripts.

**Paths in notebooks/scripts:**
- CSV files: `/opt/data/your-file.csv`
- Parquet files: `/opt/data/your-file.parquet`
- Excel files: `/opt/data/your-file.xlsx`

## Sample Files

- `sample-products.csv` - Sample product data for testing

## File Formats Supported

- **CSV** - Comma-separated values
- **Parquet** - Columnar storage (efficient, recommended)
- **JSON** - JSON records
- **Excel** - `.xlsx` files
- **Avro** - Data serialization format

## Reading Data Examples

### CSV
```python
df = spark.read.option("header", "true").csv("/opt/data/file.csv")
```

### Parquet
```python
df = spark.read.parquet("/opt/data/file.parquet")
```

### JSON
```python
df = spark.read.json("/opt/data/file.json")
```

### Excel
```python
import pandas as pd
pdf = pd.read_excel("/opt/data/file.xlsx")
df = spark.createDataFrame(pdf)
```

## Writing Data Examples

### CSV
```python
df.coalesce(1).write.mode("overwrite").option("header", "true").csv("/opt/data/output.csv")
```

### Parquet
```python
df.write.mode("overwrite").parquet("/opt/data/output.parquet")
```

## Notes

- Large data files are excluded from Git (see `.gitignore`)
- Sample files (sample-*.csv) are tracked in Git
- Parquet format is recommended for large datasets (faster, compressed)
- This folder is mounted to all containers (Jupyter, Spark)
