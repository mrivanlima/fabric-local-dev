# Quick GitHub Setup Commands

# COPY AND PASTE THESE COMMANDS ONE SECTION AT A TIME

# ============================================
# STEP 1: Navigate to Project
# ============================================
cd C:\Development\fabric-local-dev

# ============================================
# STEP 2: Initialize Git Repository
# ============================================
git init

# ============================================
# STEP 3: Configure Git (Update with your info)
# ============================================
git config user.name "Ivan Lima"
git config user.email "your-email@example.com"
git config init.defaultBranch main

# ============================================
# STEP 4: Stage All Files
# ============================================
git add .

# ============================================
# STEP 5: Initial Commit
# ============================================
git commit -m "Initial commit: Fabric Local Development Environment

- Complete Docker Compose setup with SQL Server 2025 and Spark cluster
- VS Code Dev Container configuration
- Sample Jupyter notebooks
- Python helper scripts
- Comprehensive documentation
- Pre-configured workspace"

# ============================================
# STEP 6: Create GitHub Repository
# ============================================
# Go to: https://github.com/new
# - Name: fabric-local-dev
# - Description: Local Microsoft Fabric development environment
# - Public or Private
# - DO NOT initialize with README
# - Click "Create repository"

# ============================================
# STEP 7: Connect to GitHub and Push
# ============================================
git remote add origin https://github.com/mrivanlima/fabric-local-dev.git
git branch -M main
git push -u origin main

# ============================================
# VERIFY
# ============================================
# Open: https://github.com/mrivanlima/fabric-local-dev

# ============================================
# DONE! 🎉
# ============================================
