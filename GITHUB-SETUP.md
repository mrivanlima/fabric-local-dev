# GitHub Setup Guide

This guide walks you through publishing this project to your GitHub profile.

**Your GitHub Profile:** https://github.com/mrivanlima

---

## 🚀 Quick Setup (Copy-Paste Ready)

### Step 1: Initialize Git Repository

```powershell
# Navigate to project directory
cd C:\Development\fabric-local-dev

# Initialize Git repository
git init

# Check Git status
git status
```

---

### Step 2: Configure Git (If Not Already Done)

```powershell
# Set your name (replace with your name)
git config user.name "Ivan Lima"

# Set your email (use your GitHub email)
git config user.email "your-email@example.com"

# Optional: Set default branch to main
git config init.defaultBranch main
```

---

### Step 3: Stage All Files

```powershell
# Add all files to staging
git add .

# Check what will be committed
git status
```

**Expected output:** All project files staged for commit.

---

### Step 4: Make Initial Commit

```powershell
# Create initial commit
git commit -m "Initial commit: Fabric Local Development Environment

- Complete Docker Compose setup with SQL Server 2025 (2 instances) and Spark cluster
- VS Code Dev Container configuration for seamless development
- Sample Jupyter notebooks demonstrating PySpark and SQL Server integration
- Python helper scripts for common operations
- Comprehensive documentation (PROGRESS.md, WORKSPACE.md, EXTENSIONS.md)
- Quick-start PowerShell script
- Pre-configured VS Code workspace with organized folder views
- 16 built-in tasks for container management and monitoring"
```

---

### Step 5: Create GitHub Repository

**You have 2 options:**

#### Option A: GitHub Website (Easier)

1. Go to: https://github.com/new
2. Repository name: `fabric-local-dev`
3. Description: `Local Microsoft Fabric development environment using Docker, PySpark, and SQL Server 2025`
4. Select: **Public** (or Private if you prefer)
5. **DO NOT** check "Initialize with README" (we already have one)
6. **DO NOT** add .gitignore or license
7. Click: **"Create repository"**

#### Option B: GitHub CLI (Faster)

If you have GitHub CLI installed (`gh`):

```powershell
# Login to GitHub (if not already)
gh auth login

# Create repository
gh repo create fabric-local-dev --public --description "Local Microsoft Fabric development environment using Docker, PySpark, and SQL Server 2025" --source=. --remote=origin --push
```

**If using Option B, you're done! Skip to Step 7 (Verify).**

---

### Step 6: Connect Local Repo to GitHub (If using Option A)

After creating the repository on GitHub, run these commands:

```powershell
# Add GitHub as remote (replace mrivanlima with your username if different)
git remote add origin https://github.com/mrivanlima/fabric-local-dev.git

# Verify remote was added
git remote -v

# Push to GitHub (first push)
git branch -M main
git push -u origin main
```

**If you're prompted for credentials:**
- Username: `mrivanlima`
- Password: Use a **Personal Access Token** (not your GitHub password)
  - Create token at: https://github.com/settings/tokens
  - Scopes needed: `repo`

---

### Step 7: Verify on GitHub

1. Open: https://github.com/mrivanlima/fabric-local-dev
2. You should see:
   - All project files
   - README.md displayed on main page
   - Proper folder structure

---

## 📝 Recommended: Add GitHub-Specific Files

### Add Topics/Tags to Repository

On GitHub repository page:
1. Click ⚙️ (Settings) or the "About" gear icon
2. Add topics:
   - `microsoft-fabric`
   - `pyspark`
   - `sql-server`
   - `docker`
   - `jupyter-notebook`
   - `data-engineering`
   - `vscode-devcontainer`
   - `docker-compose`

### Add Repository Description

"Local development environment mimicking Microsoft Fabric architecture with Docker, PySpark, SQL Server 2025, and Jupyter notebooks"

---

## 🔒 Security Considerations

### ⚠️ Important: Check Passwords

Your project uses default passwords in `docker-compose.yml`:
```yaml
SA_PASSWORD: "YourStrong@Passw0rd"
```

**For public repositories:**
1. ✅ **OK as-is** - These are clearly development/example passwords
2. ✅ Document in README that these are for local dev only
3. ✅ Users should change in production

**For private repositories:**
- Current setup is fine for local development

---

## 📋 Daily Git Workflow

### Making Changes and Pushing

```powershell
# Check status
git status

# Add specific files
git add notebooks/my-new-notebook.ipynb
git add scripts/my-script.py

# Or add all changed files
git add .

# Commit with descriptive message
git commit -m "Add new notebook for data analysis"

# Push to GitHub
git push
```

### Pull Latest Changes

```powershell
# Fetch and merge changes from GitHub
git pull
```

### Create New Branch (For Features)

```powershell
# Create and switch to new branch
git checkout -b feature/new-analysis

# Make changes and commit
git add .
git commit -m "Add new analysis workflow"

# Push branch to GitHub
git push -u origin feature/new-analysis
```

---

## 🎯 .gitignore Explanation

The following files/folders are **NOT** pushed to GitHub (already configured):

**Ignored:**
- `__pycache__/` - Python cache
- `.ipynb_checkpoints/` - Jupyter checkpoints
- `data/` - Data files (except samples)
- `.env` - Environment variables
- Docker volumes
- Build artifacts

**Included:**
- All source code
- Documentation
- Configuration files
- Sample data
- Requirements

---

## 🌟 Make Your Repo Stand Out

### 1. Add a GitHub Banner

Create a banner image showing your architecture diagram:
- Size: 1280x640 pixels
- Save as: `docs/banner.png`
- Reference in README:
  ```markdown
  ![Fabric Local Dev](docs/banner.png)
  ```

### 2. Add Badges to README

Add at the top of README.md:

```markdown
# Fabric Local Development Environment

[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](https://www.docker.com/)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2025-red)](https://www.microsoft.com/sql-server)
[![PySpark](https://img.shields.io/badge/PySpark-3.5.0-orange)](https://spark.apache.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
```

### 3. Add a License

If you want others to use your project:

```powershell
# Add MIT License
curl https://raw.githubusercontent.com/licenses/license-templates/master/templates/mit.txt -o LICENSE

# Edit LICENSE file and add your name and year
```

### 4. Add GitHub Actions (CI/CD)

Create `.github/workflows/docker-build.yml` for automated testing.

---

## 🐛 Troubleshooting

### Git Not Installed?

Download and install: https://git-scm.com/download/win

### Authentication Failed?

Use Personal Access Token instead of password:
1. Go to: https://github.com/settings/tokens
2. Generate new token (classic)
3. Select scopes: `repo`
4. Copy token
5. Use token as password when pushing

### Or use GitHub Desktop:

Download: https://desktop.github.com/

### Large Files Warning?

If you see warnings about large files:
```powershell
# See file sizes
git ls-files -z | xargs -0 du -h | sort -h

# Remove large files from tracking
git rm --cached path/to/large/file
```

---

## 📱 Connect with GitHub Desktop (Alternative)

If you prefer GUI:

1. Download GitHub Desktop: https://desktop.github.com/
2. File → Add Local Repository
3. Select: `C:\Development\fabric-local-dev`
4. Publish repository
5. Done!

---

## ✅ Verification Checklist

After pushing, verify on GitHub:

- [ ] Repository created: https://github.com/mrivanlima/fabric-local-dev
- [ ] README.md displays correctly
- [ ] All folders visible
- [ ] Topics/tags added
- [ ] Description added
- [ ] .gitignore working (no pycache, checkpoints, etc.)
- [ ] Clone to test: `git clone https://github.com/mrivanlima/fabric-local-dev.git`

---

## 🎉 You're All Set!

Your repository URL:
**https://github.com/mrivanlima/fabric-local-dev**

Share it, star it, fork it! 🌟

---

## 📚 Additional Resources

- **GitHub Guides:** https://guides.github.com/
- **Git Documentation:** https://git-scm.com/doc
- **GitHub CLI:** https://cli.github.com/
- **Personal Access Tokens:** https://github.com/settings/tokens

---

**Happy coding and sharing! 🚀**
