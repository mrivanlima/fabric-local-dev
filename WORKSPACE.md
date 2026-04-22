# 📁 VS Code Workspace Guide

This project uses a VS Code workspace for better organization and productivity.

---

## 🎯 What is a Workspace?

A workspace in VS Code is a configuration that defines:
- Multiple folder views (even from the same root)
- Workspace-specific settings
- Task definitions
- Launch configurations for debugging
- Recommended extensions

---

## 🚀 How to Use This Workspace

### Method 1: Double-click the Workspace File (Easiest)

```
📁 C:\Development\fabric-local-dev\
   └── fabric-local-dev.code-workspace  ← Double-click this!
```

This will:
- ✅ Open VS Code automatically
- ✅ Load the entire project structure
- ✅ Apply all settings
- ✅ Show organized folder tree

### Method 2: Open from VS Code

1. Open VS Code
2. File → Open Workspace from File
3. Navigate to `C:\Development\fabric-local-dev\`
4. Select `fabric-local-dev.code-workspace`

### Method 3: Command Line

```powershell
code C:\Development\fabric-local-dev\fabric-local-dev.code-workspace
```

---

## 📂 Workspace Structure

When you open the workspace, you'll see organized folders in the Explorer:

```
🏠 Fabric Local Dev (Root)       ← All files
📓 Notebooks                     ← Quick access to notebooks
🐍 Scripts & Helpers             ← Python utility scripts
📊 Data Files                    ← Your data files
🐳 Docker Configuration          ← Docker setup files
📚 Documentation                 ← All docs in one place
```

**Benefits:**
- Quick navigation between related files
- Each folder is independently collapsible
- Easy to focus on specific areas
- Professional organization

---

## ⚙️ Workspace Settings

The workspace includes pre-configured settings:

### Python Configuration
- Black formatter (auto-format on save)
- 88-character line limit
- Auto-organize imports
- Scripts folder in Python path

### Jupyter Configuration
- Notebooks folder as root
- Execute selection enabled
- Kernel auto-detection

### Editor Configuration
- Auto-save after 1 second
- Format on save
- Hide clutter files (pycache, checkpoints)
- Rulers at 88 and 120 characters

### File Associations
- `.ipynb` → Jupyter Notebook
- `docker-compose*.yml` → YAML
- `Dockerfile*` → Dockerfile
- `requirements*.txt` → Pip Requirements

---

## 🎮 Workspace Features

### 1. Multi-Folder View

Even though we have one root folder, the workspace creates logical views:

**Example:** Working on a notebook but need to reference a helper script?
- **Left sidebar:** `📓 Notebooks` folder expanded
- **Right sidebar:** `🐍 Scripts & Helpers` folder visible
- No need to navigate up/down the tree!

### 2. Integrated Tasks

Press `Ctrl+Shift+P` → "Tasks: Run Task":
- 🚀 Start All Containers
- ⏹️ Stop All Containers
- 📊 View Container Status
- 📝 View Logs
- 🌐 Open Jupyter Lab
- And more...

### 3. Debug Configurations

Press `F5` to debug:
- **Python: Current File** - Debug any Python script
- **Python: Debug Notebook** - Debug notebook code

### 4. Extension Recommendations

Workspace automatically suggests required extensions when opened.

---

## 🔧 Customizing the Workspace

### Add Your Own Folder Views

Edit `fabric-local-dev.code-workspace`:

```json
{
  "folders": [
    {
      "name": "🎨 My Custom View",
      "path": "path/to/folder"
    }
  ]
}
```

### Add Workspace Settings

```json
{
  "settings": {
    "your.setting.here": "value"
  }
}
```

### Add Custom Tasks

See `.vscode/tasks.json` for examples.

---

## 📋 Workspace vs Folder

| Feature | Opening Folder | Opening Workspace |
|---------|---------------|-------------------|
| File access | ✅ All files | ✅ All files |
| Settings | ✅ Basic | ✅ Enhanced |
| Multi-root | ❌ No | ✅ Yes |
| Folder views | ❌ Single tree | ✅ Multiple views |
| Tasks | ✅ Yes | ✅ Enhanced |
| Debug configs | ✅ Basic | ✅ Full featured |

**Recommendation:** Use the workspace file for the best experience!

---

## 🎓 Workspace Workflow

### Opening the Project

**Best practice:**
1. Double-click `fabric-local-dev.code-workspace`
2. VS Code opens with organized structure
3. Press `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"
4. Start working!

### Daily Workflow

1. **Start containers:**
   - `Ctrl+Shift+P` → Tasks → "🚀 Start All Containers"
   - Or run `.\start.ps1`

2. **Reopen in container:**
   - `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

3. **Navigate:**
   - Use folder views in sidebar
   - Quick Open: `Ctrl+P` → type filename

4. **Work:**
   - Open notebooks from `📓 Notebooks` view
   - Access helpers from `🐍 Scripts & Helpers` view
   - View logs with Tasks menu

5. **Stop:**
   - `Ctrl+Shift+P` → Tasks → "⏹️ Stop All Containers"

---

## 💡 Pro Tips

### Tip 1: Save Workspace State
When you close VS Code, it remembers:
- Open files
- Editor layout
- Terminal state
- Sidebar position

### Tip 2: Multiple Windows
Open the same workspace in multiple windows:
- File → New Window
- File → Open Workspace from File
- Select same workspace file

Each window is independent!

### Tip 3: Workspace Tasks
Add frequently-used commands as tasks:
- Edit `.vscode/tasks.json`
- `Ctrl+Shift+P` → "Tasks: Run Task"

### Tip 4: Folder Icons
The emoji in folder names (📓 🐍 📊) make navigation visual and fun!

### Tip 5: Search Scope
Right-click any folder view → "Find in Folder"
Searches only that folder!

---

## 🔒 What Gets Saved

### Saved in Workspace File:
- Folder definitions
- Workspace settings
- Extension recommendations
- Debug configurations
- Task definitions

### Saved in VS Code Settings:
- Window position
- Recently opened files
- Editor layout
- Terminal history

### NOT Saved:
- Container state (managed by Docker)
- Notebook output (saved in .ipynb files)
- Data files (managed separately)

---

## 📦 Sharing the Workspace

To share with your team:

1. **Include in Git:**
   ```bash
   git add fabric-local-dev.code-workspace
   git commit -m "Add workspace configuration"
   ```

2. **Team members:**
   - Clone repo
   - Double-click workspace file
   - Same experience for everyone!

3. **Benefits:**
   - Consistent settings
   - Same folder structure
   - Same extensions
   - Same tasks

---

## 🛠️ Troubleshooting

### Workspace won't open?
- Make sure VS Code is updated
- Try: File → Close Workspace → Reopen

### Settings not applying?
- Workspace settings override user settings
- Check: File → Preferences → Settings → Workspace tab

### Folders not showing?
- Check paths in workspace file are correct
- Relative paths are relative to workspace file location

### Extensions not installing?
- Check: Extensions panel → Filter by "Recommended"
- Click "Install All" if prompted

---

## 📚 Additional Resources

- [VS Code Workspaces Documentation](https://code.visualstudio.com/docs/editor/workspaces)
- [Multi-root Workspaces](https://code.visualstudio.com/docs/editor/multi-root-workspaces)
- [Workspace Settings](https://code.visualstudio.com/docs/getstarted/settings#_workspace-settings)

---

## ✅ Quick Reference

| Action | Command |
|--------|---------|
| Open workspace | Double-click `.code-workspace` file |
| Switch to folder view | File → Close Workspace |
| Add folder to workspace | File → Add Folder to Workspace |
| Edit workspace settings | File → Preferences → Settings (Workspace) |
| Save workspace as | File → Save Workspace As |

---

**Enjoy your organized workspace! 🎉**
