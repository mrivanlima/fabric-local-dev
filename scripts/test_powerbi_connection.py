#!/usr/bin/env python3
"""
Power BI Connection Test Script

This script tests the connection from Python to Docker SQL Server instances.
Use this to verify that the containers are accessible and ready for Power BI Desktop.
"""

import os
import sys
import subprocess

def print_header(text):
    """Print a formatted header"""
    print(f"\n{'='*60}")
    print(f" {text}")
    print(f"{'='*60}\n")

def print_success(text):
    """Print success message"""
    print(f"✅ {text}")

def print_error(text):
    """Print error message"""
    print(f"❌ {text}")

def print_info(text):
    """Print info message"""
    print(f"ℹ️  {text}")

def test_docker_containers():
    """Test if Docker containers are running"""
    print_header("Test 1: Docker Containers")
    
    try:
        result = subprocess.run(
            ["docker", "ps", "--format", "{{.Names}}"],
            capture_output=True,
            text=True,
            check=True
        )
        
        containers = result.stdout.strip().split('\n')
        
        required_containers = [
            'fabric-sqlserver',
            'fabric-sqlserver2',
            'fabric-jupyter',
            'fabric-spark-master',
            'fabric-spark-worker'
        ]
        
        all_running = True
        for container in required_containers:
            if container in containers:
                print_success(f"{container} is running")
            else:
                print_error(f"{container} is NOT running")
                all_running = False
        
        return all_running
        
    except subprocess.CalledProcessError as e:
        print_error(f"Failed to check Docker containers: {e}")
        return False
    except FileNotFoundError:
        print_error("Docker is not installed or not in PATH")
        return False

def test_sql_connection(server_name, port, description):
    """Test SQL Server connection"""
    print_header(f"Test: {description}")
    
    try:
        # Try to execute a simple SQL query
        cmd = [
            "docker", "exec", server_name,
            "/opt/mssql-tools/bin/sqlcmd",
            "-S", "localhost",
            "-U", "sa",
            "-P", "YourStrong@Passw0rd",
            "-Q", "SELECT @@VERSION, DB_NAME()",
            "-h", "-1"  # Remove headers for cleaner output
        ]
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True,
            timeout=10
        )
        
        if result.returncode == 0:
            print_success(f"{description} is accessible")
            print_info(f"Connection string for Power BI: localhost,{port}")
            print_info(f"Database: {'FabricDev' if port == '1433' else 'FabricDev2 (create if needed)'}")
            return True
        else:
            print_error(f"{description} connection failed")
            print(result.stderr)
            return False
            
    except subprocess.TimeoutExpired:
        print_error(f"{description} connection timed out")
        return False
    except subprocess.CalledProcessError as e:
        print_error(f"{description} connection failed: {e}")
        print(e.stderr)
        return False

def test_sample_data(server_name):
    """Test if sample data exists"""
    print_header("Test: Sample Data")
    
    try:
        cmd = [
            "docker", "exec", server_name,
            "/opt/mssql-tools/bin/sqlcmd",
            "-S", "localhost",
            "-U", "sa",
            "-P", "YourStrong@Passw0rd",
            "-d", "FabricDev",
            "-Q", "SELECT COUNT(*) as RowCount FROM dbo.Sales",
            "-h", "-1"
        ]
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True,
            timeout=10
        )
        
        if result.returncode == 0:
            row_count = result.stdout.strip()
            if row_count and row_count.isdigit():
                print_success(f"Sample data exists: {row_count} rows in dbo.Sales")
                return True
            else:
                print_error("Sample data not found or invalid response")
                return False
        else:
            print_error("Failed to check sample data")
            return False
            
    except Exception as e:
        print_error(f"Failed to check sample data: {e}")
        return False

def test_ports():
    """Test if required ports are available"""
    print_header("Test: Port Availability")
    
    try:
        import socket
        
        ports_to_test = [
            (1433, "SQL Server Primary"),
            (1434, "SQL Server Secondary"),
            (8888, "Jupyter Lab"),
            (8080, "Spark UI")
        ]
        
        all_available = True
        for port, description in ports_to_test:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(2)
                result = sock.connect_ex(('localhost', port))
                sock.close()
                
                if result == 0:
                    print_success(f"Port {port} ({description}) is open")
                else:
                    print_error(f"Port {port} ({description}) is not accessible")
                    all_available = False
            except Exception as e:
                print_error(f"Failed to test port {port}: {e}")
                all_available = False
        
        return all_available
        
    except ImportError:
        print_error("Socket module not available")
        return False

def print_connection_info():
    """Print connection information for Power BI Desktop"""
    print_header("Power BI Desktop Connection Info")
    
    print("Primary SQL Server:")
    print("  Server: localhost,1433")
    print("  Database: FabricDev")
    print("  Username: sa")
    print("  Password: YourStrong@Passw0rd")
    print("  Connection Options: TrustServerCertificate=True;Encrypt=False")
    print()
    
    print("Secondary SQL Server:")
    print("  Server: localhost,1434")
    print("  Database: FabricDev2")
    print("  Username: sa")
    print("  Password: YourStrong@Passw0rd")
    print("  Connection Options: TrustServerCertificate=True;Encrypt=False")
    print()
    
    print("To connect from Power BI Desktop:")
    print("  1. Get Data → SQL Server")
    print("  2. Enter server: localhost,1433")
    print("  3. Select Database authentication")
    print("  4. Enter username and password")
    print("  5. Click Connect")

def main():
    """Run all tests"""
    print("\n" + "="*60)
    print(" Power BI Connection Test Suite")
    print(" Testing Docker SQL Server connectivity")
    print("="*60)
    
    tests_passed = 0
    tests_total = 0
    
    # Test 1: Docker containers
    tests_total += 1
    if test_docker_containers():
        tests_passed += 1
    
    # Test 2: Port availability
    tests_total += 1
    if test_ports():
        tests_passed += 1
    
    # Test 3: Primary SQL Server
    tests_total += 1
    if test_sql_connection('fabric-sqlserver', '1433', 'Primary SQL Server (1433)'):
        tests_passed += 1
    
    # Test 4: Secondary SQL Server
    tests_total += 1
    if test_sql_connection('fabric-sqlserver2', '1434', 'Secondary SQL Server (1434)'):
        tests_passed += 1
    
    # Test 5: Sample data
    tests_total += 1
    if test_sample_data('fabric-sqlserver'):
        tests_passed += 1
    
    # Print summary
    print_header("Test Summary")
    print(f"Tests passed: {tests_passed}/{tests_total}")
    
    if tests_passed == tests_total:
        print_success("All tests passed! Power BI Desktop should be able to connect.")
        print_connection_info()
        return 0
    else:
        print_error(f"{tests_total - tests_passed} test(s) failed. Check the errors above.")
        print()
        print("Common issues:")
        print("  - Docker containers not running: Run 'docker-compose up -d'")
        print("  - Ports in use: Change ports in docker-compose.yml")
        print("  - SQL Server not ready: Wait 30 seconds and retry")
        return 1

if __name__ == "__main__":
    sys.exit(main())
