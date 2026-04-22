# Fabric Local Development - Quick Start Script
# Run this script to start your development environment

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fabric Local Development Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "🔍 Checking Docker..." -ForegroundColor Yellow
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

# Navigate to project directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host ""
Write-Host "📁 Project directory: $scriptPath" -ForegroundColor Cyan

# Check if containers are already running
Write-Host ""
Write-Host "🔍 Checking container status..." -ForegroundColor Yellow
$runningContainers = docker ps --filter "name=fabric-" --format "{{.Names}}"

if ($runningContainers) {
    Write-Host "✅ Containers are already running:" -ForegroundColor Green
    docker ps --filter "name=fabric-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    Write-Host ""
    $restart = Read-Host "Do you want to restart them? (y/N)"
    
    if ($restart -eq 'y' -or $restart -eq 'Y') {
        Write-Host ""
        Write-Host "🔄 Restarting containers..." -ForegroundColor Yellow
        docker-compose restart
        Write-Host "✅ Containers restarted" -ForegroundColor Green
    }
} else {
    Write-Host "⚠️  Containers are not running" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🚀 Starting containers..." -ForegroundColor Yellow
    Write-Host "   (First time may take 5-10 minutes to download images)" -ForegroundColor Gray
    Write-Host ""
    
    docker-compose up -d --build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Containers started successfully!" -ForegroundColor Green
        
        # Wait for services to be ready
        Write-Host ""
        Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        
        # Check SQL Server health
        Write-Host "   Checking Primary SQL Server..." -ForegroundColor Gray
        $retries = 0
        $maxRetries = 30
        while ($retries -lt $maxRetries) {
            try {
                docker exec fabric-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT 1" 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "   ✅ Primary SQL Server ready" -ForegroundColor Green
                    break
                }
            } catch {}
            $retries++
            Start-Sleep -Seconds 2
        }
        
        if ($retries -eq $maxRetries) {
            Write-Host "   ⚠️  Primary SQL Server may still be starting..." -ForegroundColor Yellow
        }
        
        # Check Secondary SQL Server health
        Write-Host "   Checking Secondary SQL Server..." -ForegroundColor Gray
        $retries = 0
        while ($retries -lt $maxRetries) {
            try {
                docker exec fabric-sqlserver2 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT 1" 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "   ✅ Secondary SQL Server ready" -ForegroundColor Green
                    break
                }
            } catch {}
            $retries++
            Start-Sleep -Seconds 2
        }
        
        if ($retries -eq $maxRetries) {
            Write-Host "   ⚠️  Secondary SQL Server may still be starting..." -ForegroundColor Yellow
        }
        
    } else {
        Write-Host ""
        Write-Host "❌ Failed to start containers!" -ForegroundColor Red
        Write-Host "Check the error messages above." -ForegroundColor Red
        exit 1
    }
}

# Display status 1:  " -NoNewline -ForegroundColor White
Write-Host "localhost:1433 (sa/YourStrong@Passw0rd)" -ForegroundColor Cyan
Write-Host "🗄️  SQL Server 2:  " -NoNewline -ForegroundColor White
Write-Host "localhost:1434
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Environment Status" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

docker ps --filter "name=fabric-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Display access URLs
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Access URLs" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 Jupyter Lab:    " -NoNewline -ForegroundColor White
Write-Host "http://localhost:8888" -ForegroundColor Cyan
Write-Host "🌐 Spark UI:       " -NoNewline -ForegroundColor White
Write-Host "http://localhost:8080" -ForegroundColor Cyan
Write-Host "🗄️  SQL Server:    " -NoNewline -ForegroundColor White
Write-Host "localhost:1433 (sa/YourStrong@Passw0rd)" -ForegroundColor Cyan

# Display next steps
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Next Steps" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open in VS Code:  " -NoNewline
Write-Host "code ." -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Reopen in Container:" -ForegroundColor White
Write-Host "   Press " -NoNewline
Write-Host "Ctrl+Shift+P" -ForegroundColor Yellow -NoNewline
Write-Host " → " -NoNewline
Write-Host "Dev Containers: Reopen in Container" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. Open sample notebook:" -ForegroundColor White
Write-Host "   " -NoNewline
Write-Host "notebooks/01-getting-started.ipynb" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Select Python kernel and run!" -ForegroundColor White
Write-Host ""

# Ask if user wants to open in VS Code
$openVSCode = Read-Host "Open in VS Code now? (Y/n)"

if ($openVSCode -ne 'n' -and $openVSCode -ne 'N') {
    Write-Host ""
    Write-Host "🚀 Opening VS Code..." -ForegroundColor Yellow
    code .
    Write-Host ""
    Write-Host "✅ Remember to 'Reopen in Container' from Command Palette!" -ForegroundColor Green
}

# Ask if user wants to open Jupyter Lab
Write-Host ""
$openJupyter = Read-Host "Open Jupyter Lab in browser? (y/N)"

if ($openJupyter -eq 'y' -or $openJupyter -eq 'Y') {
    Write-Host ""
    Write-Host "🌐 Opening Jupyter Lab..." -ForegroundColor Yellow
    Start-Process "http://localhost:8888"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Useful Commands" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Stop all:       " -NoNewline
Write-Host "docker-compose stop" -ForegroundColor Yellow
Write-Host "Start all:      " -NoNewline
Write-Host "docker-compose start" -ForegroundColor Yellow
Write-Host "View logs:      " -NoNewline
Write-Host "docker-compose logs -f" -ForegroundColor Yellow
Write-Host "Restart service:" -NoNewline
Write-Host " docker-compose restart jupyter" -ForegroundColor Yellow
Write-Host ""
Write-Host "Happy coding! 🎉" -ForegroundColor Green
Write-Host ""
