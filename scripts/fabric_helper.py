"""
Fabric Local Dev - Database Helper

Common database operations for PySpark and SQL Server.
Use this in your notebooks or scripts.
"""

import os
from pyspark.sql import SparkSession
from typing import Optional


class FabricHelper:
    """Helper class for common Fabric development tasks"""
    
    def __init__(self, use_secondary_db: bool = False):
        """
        Initialize with environment variables from docker-compose.yml
        
        Args:
            use_secondary_db: If True, connect to secondary SQL Server instance
        """
        if use_secondary_db:
            self.sql_host = os.getenv('SQL_SERVER2_HOST', 'sqlserver2')
            self.sql_port = os.getenv('SQL_SERVER2_PORT', '1433')
            self.sql_user = os.getenv('SQL_SERVER2_USER', 'sa')
            self.sql_password = os.getenv('SQL_SERVER2_PASSWORD', 'YourStrong@Passw0rd')
            self.database = 'FabricDev2'
            self.instance_name = "Secondary"
        else:
            self.sql_host = os.getenv('SQL_SERVER_HOST', 'sqlserver')
            self.sql_port = os.getenv('SQL_SERVER_PORT', '1433')
            self.sql_user = os.getenv('SQL_SERVER_USER', 'sa')
            self.sql_password = os.getenv('SQL_SERVER_PASSWORD', 'YourStrong@Passw0rd')
            self.database = 'FabricDev'
            self.instance_name = "Primary"
        
        # JDBC connection string
        self.jdbc_url = (
            f"jdbc:sqlserver://{self.sql_host}:{self.sql_port};"
            f"databaseName={self.database};"
            f"encrypt=false;trustServerCertificate=true"
        )
        
        # Connection properties
        self.connection_properties = {
            "user": self.sql_user,
            "password": self.sql_password,
            "driver": "com.microsoft.sqlserver.jdbc.SQLServerDriver"
        }
        
    def create_spark_session(self, app_name: str = "FabricLocalDev") -> SparkSession:
        """
        Create a Spark session with SQL Server connectivity
        
        Args:
            app_name: Name for your Spark application
            
        Returns:
            SparkSession configured for SQL Server
        """
        spark = SparkSession.builder \
            .appName(app_name) \
            .master("spark://spark-master:7077") \
            .config("spark.sql.adaptive.enabled", "true") \
            .config("spark.sql.adaptive.coalescePartitions.enabled", "true") \
            .config("spark.executor.memory", "1g") \
            .config("spark.driver.memory", "1g") \
            .getOrCreate()
        
        print(f"✅ Spark session created: {app_name}")
        print(f"   Version: {spark.version}")
        print(f"   Master: {spark.sparkContext.master}")
        
        return spark
    
    def read_sql_table(self, spark: SparkSession, table_name: str):
        """
        Read a table from SQL Server
        
        Args:
            spark: SparkSession instance
            table_name: Table name (e.g., 'dbo.Sales')
            
        Returns:
            Spark DataFrame
        """
        print(f"📖 Reading table: {table_name} from {self.instance_name} SQL Server")
        
        df = spark.read.jdbc(
            url=self.jdbc_url,
            table=table_name,
            properties=self.connection_properties
        )
        
        print(f"✅ Loaded {df.count()} rows")
        return df
    
    def write_sql_table(self, df, table_name: str, mode: str = "overwrite"):
        """
        Write DataFrame to SQL Server
        
        Args:
            df: Spark DataFrame to write
            table_name: Target table name (e.g., 'dbo.Results')
            mode: Write mode - 'overwrite', 'append', 'ignore', 'error'
        """
        print(f"✍️ Writing to table: {table_name} on {self.instance_name} SQL Server (mode: {mode})")
        
        df.write.jdbc(
            url=self.jdbc_url,
            table=table_name,
            mode=mode,
            properties=self.connection_properties
        )
        
        print(f"✅ Data written successfully")
    
    def copy_between_servers(self, spark: SparkSession, source_table: str, target_table: str):
        """
        Copy data from primary to secondary SQL Server (or vice versa)
        
        Args:
            spark: SparkSession instance
            source_table: Source table name
            target_table: Target table name
        """
        # Read from current instance
        df = self.read_sql_table(spark, source_table)
        
        # Switch to other instance
        other_instance = FabricHelper(use_secondary_db=not self.instance_name == "Secondary")
        
        # Write to other instance
        other_instance.write_sql_table(df, target_table, mode="overwrite")
        
        print(f"✅ Copied {df.count()} rows from {self.instance_name} to {other_instance.instance_name}")
    
    def execute_sql(self, spark: SparkSession, query: str):
        """
        Execute a SQL query against SQL Server
        
        Args:
            spark: SparkSession instance
            query: SQL query string
            
        Returns:
            Spark DataFrame with results
        """
        print(f"🔍 Executing SQL query")
        
        df = spark.read.jdbc(
            url=self.jdbc_url,
            table=f"({query}) AS query",
            properties=self.connection_properties
        )
        
        print(f"✅ Query executed, {df.count()} rows returned")
        return df
    
    def read_csv(self, spark: SparkSession, file_path: str, header: bool = True, infer_schema: bool = True):
        """
        Read CSV file from data folder
        
        Args:
            spark: SparkSession instance
            file_path: Path to CSV file (e.g., '/opt/data/file.csv')
            header: Whether first row is header
            infer_schema: Whether to infer data types
            
        Returns:
            Spark DataFrame
        """
        print(f"📖 Reading CSV: {file_path}")
        
        df = spark.read \
            .option("header", header) \
            .option("inferSchema", infer_schema) \
            .csv(file_path)
        
        print(f"✅ Loaded {df.count()} rows")
        return df
    
    def read_parquet(self, spark: SparkSession, file_path: str):
        """
        Read Parquet file
        
        Args:
            spark: SparkSession instance
            file_path: Path to Parquet file
            
        Returns:
            Spark DataFrame
        """
        print(f"📖 Reading Parquet: {file_path}")
        
        df = spark.read.parquet(file_path)
        
        print(f"✅ Loaded {df.count()} rows")
        return df
    
    def display_summary(self, df, sample_rows: int = 5):
        """
        Display DataFrame summary information
        
        Args:
            df: Spark DataFrame
            sample_rows: Number of sample rows to show
        """
        print("\n" + "="*60)
        print("DataFrame Summary")
        print("="*60)
        
        print(f"\n📊 Row count: {df.count()}")
        
        print(f"\n📋 Schema:")
        df.printSchema()
        
        print(f"\n👀 Sample data ({sample_rows} rows):")
        df.show(sample_rows, truncate=False)
        
        print(f"\n📈 Statistics:")
        df.describe().show()


# Quick functions for notebooks
def get_spark() -> SparkSession:
    """Quick function to get a Spark session"""
    helper = FabricHelper()
    return helper.create_spa (Primary SQL Server)
helper = FabricHelper()
spark = helper.create_spark_session("MyApp")
df = helper.read_sql_table(spark, "dbo.Sales")
helper.display_summary(df)

# Method 2: Use helper class (Secondary SQL Server)
helper2 = FabricHelper(use_secondary_db=True)
df2 = helper2.read_sql_table(spark, "dbo.Sales")

# Method 3: Copy data between servers
helper.copy_between_servers(spark, "dbo.Sales", "dbo.SalesBackup")

# Method 4: Use quick functions (defaults to primary)
    return helper.read_sql_table(spark, table_name)


def write_table(df, table_name: str, mode: str = "overwrite"):
    """Quick function to write to SQL table"""
    helper = FabricHelper()
    helper.write_sql_table(df, table_name, mode)


# Example usage in notebook:
"""
from scripts.fabric_helper import FabricHelper, get_spark, read_table, write_table

# Method 1: Use helper class
helper = FabricHelper()
spark = helper.create_spark_session("MyApp")
df = helper.read_sql_table(spark, "dbo.Sales")
helper.display_summary(df)

# Method 2: Use quick functions
spark = get_spark()
df = read_table("dbo.Sales")
write_table(df, "dbo.Results")
"""
