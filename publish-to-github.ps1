# GitHub Publishing Script
# Automates the process of publishing to GitHub

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GitHub Repository Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to project directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "📁 Project directory: $scriptPath" -ForegroundColor Cyan
Write-Host ""

# Check if Git is installed
Write-Host "🔍 Checking Git installation..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "✅ Git installed: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git is not installed!" -ForegroundColor Red
    Write-Host "Please install Git from: https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check if already a Git repository
if (Test-Path ".git") {
    Write-Host "✅ Git repository already initialized" -ForegroundColor Green
    $reinit = Read-Host "Do you want to reinitialize? (y/N)"
    if ($reinit -eq 'y' -or $reinit -eq 'Y') {
        Remove-Item -Recurse -Force .git
        git init
        Write-Host "✅ Git repository reinitialized" -ForegroundColor Green
    }
} else {
    Write-Host "📦 Initializing Git repository..." -ForegroundColor Yellow
    git init
    git config init.defaultBranch main
    Write-Host "✅ Git repository initialized" -ForegroundColor Green
}

Write-Host ""

# Configure Git user
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Git Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$currentName = git config user.name
$currentEmail = git config user.email

if ($currentName) {
    Write-Host "Current Git name: $currentName" -ForegroundColor Gray
    $changeName = Read-Host "Change name? (y/N)"
    if ($changeName -eq 'y' -or $changeName -eq 'Y') {
        $userName = Read-Host "Enter your name"
        git config user.name "$userName"
    }
} else {
    Write-Host "No Git name configured" -ForegroundColor Yellow
    $userName = Read-Host "Enter your name (e.g., Ivan Lima)"
    git config user.name "$userName"
}

if ($currentEmail) {
    Write-Host "Current Git email: $currentEmail" -ForegroundColor Gray
    $changeEmail = Read-Host "Change email? (y/N)"
    if ($changeEmail -eq 'y' -or $changeEmail -eq 'Y') {
        $userEmail = Read-Host "Enter your email"
        git config user.email "$userEmail"
    }
} else {
    Write-Host "No Git email configured" -ForegroundColor Yellow
    $userEmail = Read-Host "Enter your email"
    git config user.email "$userEmail"
}

Write-Host ""
Write-Host "✅ Git configured" -ForegroundColor Green
Write-Host ""

# Stage files
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Staging Files" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📦 Adding files to Git..." -ForegroundColor Yellow
git add .

$status = git status --short
if ($status) {
    Write-Host "✅ Files staged:" -ForegroundColor Green
    git status --short
} else {
    Write-Host "⚠️  No changes to commit" -ForegroundColor Yellow
}

Write-Host ""

# Commit
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Creating Initial Commit" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$hasCommits = git log --oneline 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "📝 Creating initial commit..." -ForegroundColor Yellow
    git commit -m "Initial commit: Fabric Local Development Environment

- Complete Docker Compose setup with SQL Server 2025 (2 instances) and Spark cluster
- VS Code Dev Container configuration for seamless development
- Sample Jupyter notebooks demonstrating PySpark and SQL Server integration
- Python helper scripts for common operations
- Comprehensive documentation (PROGRESS.md, WORKSPACE.md, EXTENSIONS.md)
- Quick-start PowerShell script
- Pre-configured VS Code workspace with organized folder views
- 16 built-in tasks for container management and monitoring
- MIT License
- GitHub-ready with badges and proper .gitignore"
    Write-Host "✅ Initial commit created" -ForegroundColor Green
} else {
    Write-Host "✅ Repository already has commits" -ForegroundColor Green
    $makeCommit = Read-Host "Create new commit? (y/N)"
    if ($makeCommit -eq 'y' -or $makeCommit -eq 'Y') {
        $commitMsg = Read-Host "Enter commit message"
        git commit -m "$commitMsg"
        Write-Host "✅ Commit created" -ForegroundColor Green
    }
}

Write-Host ""

# GitHub setup
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GitHub Repository Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🌐 Repository URL: https://github.com/mrivanlima/fabric-local-dev" -ForegroundColor Cyan
Write-Host ""

# Check if remote exists
$remotes = git remote
if ($remotes -contains "origin") {
    Write-Host "✅ Remote 'origin' already configured" -ForegroundColor Green
    $originUrl = git remote get-url origin
    Write-Host "   URL: $originUrl" -ForegroundColor Gray
    Write-Host ""
    $changeRemote = Read-Host "Change remote URL? (y/N)"
    if ($changeRemote -eq 'y' -or $changeRemote -eq 'Y') {
        $newUrl = Read-Host "Enter GitHub repository URL"
        git remote set-url origin $newUrl
        Write-Host "✅ Remote URL updated" -ForegroundColor Green
    }
} else {
    Write-Host "⚠️  No remote configured" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To create the GitHub repository:" -ForegroundColor White
    Write-Host "1. Go to: https://github.com/new" -ForegroundColor Yellow
    Write-Host "2. Repository name: fabric-local-dev" -ForegroundColor Yellow
    Write-Host "3. DO NOT initialize with README" -ForegroundColor Yellow
    Write-Host "4. Click 'Create repository'" -ForegroundColor Yellow
    Write-Host ""
    
    $created = Read-Host "Have you created the repository on GitHub? (y/N)"
    
    if ($created -eq 'y' -or $created -eq 'Y') {
        $username = Read-Host "Enter your GitHub username (default: mrivanlima)"
        if (-not $username) {
            $username = "mrivanlima"
        }
        
        $repoName = Read-Host "Enter repository name (default: fabric-local-dev)"
        if (-not $repoName) {
            $repoName = "fabric-local-dev"
        }
        
        $repoUrl = "https://github.com/$username/$repoName.git"
        
        Write-Host ""
        Write-Host "📦 Adding remote..." -ForegroundColor Yellow
        git remote add origin $repoUrl
        Write-Host "✅ Remote added: $repoUrl" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "⏸️  Please create the repository on GitHub first" -ForegroundColor Yellow
        Write-Host "Then run this script again" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Or manually add remote:" -ForegroundColor White
        Write-Host "git remote add origin https://github.com/mrivanlima/fabric-local-dev.git" -ForegroundColor Cyan
        exit 0
    }
}

Write-Host ""

# Push to GitHub
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Push to GitHub" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$push = Read-Host "Push to GitHub now? (Y/n)"

if ($push -ne 'n' -and $push -ne 'N') {
    Write-Host ""
    Write-Host "📤 Pushing to GitHub..." -ForegroundColor Yellow
    Write-Host ""
    
    git branch -M main
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "  ✅ SUCCESS!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎉 Your repository is now on GitHub!" -ForegroundColor Green
        Write-Host ""
        
        $originUrl = git remote get-url origin
        $webUrl = $originUrl -replace '\.git$', '' -replace 'https://github.com/', 'https://github.com/'
        
        Write-Host "🌐 View your repository:" -ForegroundColor White
        Write-Host "   $webUrl" -ForegroundColor Cyan
        Write-Host ""
        
        $openBrowser = Read-Host "Open in browser? (Y/n)"
        if ($openBrowser -ne 'n' -and $openBrowser -ne 'N') {
            Start-Process $webUrl
        }
        
        Write-Host ""
        Write-Host "📋 Next steps:" -ForegroundColor White
        Write-Host "1. Add repository description on GitHub" -ForegroundColor Yellow
        Write-Host "2. Add topics: microsoft-fabric, pyspark, sql-server, docker" -ForegroundColor Yellow
        Write-Host "3. Share with the community! ⭐" -ForegroundColor Yellow
        
    } else {
        Write-Host ""
        Write-Host "❌ Push failed!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Common issues:" -ForegroundColor Yellow
        Write-Host "- Authentication failed: Use Personal Access Token" -ForegroundColor White
        Write-Host "  Create one at: https://github.com/settings/tokens" -ForegroundColor Cyan
        Write-Host "- Repository doesn't exist: Create it first" -ForegroundColor White
        Write-Host "- Wrong remote URL: Check git remote -v" -ForegroundColor White
    }
} else {
    Write-Host ""
    Write-Host "⏸️  Push cancelled" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To push later, run:" -ForegroundColor White
    Write-Host "git push -u origin main" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Done! 🚀" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
