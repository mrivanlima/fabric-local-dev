# Start from official Apache Spark image
# This includes Java, Scala, and Apache Spark pre-configured
FROM apache/spark:3.5.0

# Switch to root to install packages
USER root

# Install Python and development tools
# We need these for PySpark and data science libraries
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create working directories
RUN mkdir -p /opt/notebooks /opt/data /opt/scripts && \
    chmod -R 777 /opt/notebooks /opt/data /opt/scripts

# Copy Python requirements and install dependencies
COPY ./requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

# Install SQL Server ODBC driver for PySpark SQL Server connectivity
# This allows PySpark to read/write to SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 unixodbc-dev && \
    echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc

# Download SQL Server JDBC driver for Spark
# Spark uses JDBC to connect to databases
RUN curl -L https://go.microsoft.com/fwlink/?linkid=2223050 -o /opt/spark/jars/mssql-jdbc-12.4.2.jre11.jar

# Set Python environment
ENV PYTHONPATH=/opt/spark/python:/opt/spark/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH
ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=python3

# Working directory for notebooks
WORKDIR /opt/notebooks

# Default command - will be overridden by docker-compose for different services
CMD ["/opt/spark/bin/spark-class", "org.apache.spark.deploy.master.Master"]
