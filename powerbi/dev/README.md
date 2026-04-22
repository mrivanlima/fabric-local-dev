# Power BI Development Files

## 📁 Folders

### `dev/`
Personal development `.pbix` files. These contain data and are not committed to Git.

**Usage:**
- Create your Power BI reports here
- Test queries against Docker SQL Server
- Experiment with visualizations

**Not Committed:** Files in this folder are excluded from Git (see `.gitignore`)

### `templates/`
Power BI Template files (`.pbit`) that can be shared with the team.

**Usage:**
- Save template versions of your reports
- Share with team members
- Templates don't contain data (smaller file size)

**Committed:** These files ARE committed to Git for team sharing

---

## 💡 Creating a Template from PBIX

1. Open your `.pbix` file in Power BI Desktop
2. **File → Export → Power BI template**
3. Add description and save to `templates/` folder
4. Commit the `.pbit` file to Git

---

## 🔄 Using a Template

1. Double-click `.pbit` file (or File → Open in Power BI Desktop)
2. Enter any required parameters
3. Power BI will recreate the report structure
4. Refresh to load data from Docker SQL Server
5. Save as `.pbix` in `dev/` folder for local work

---

## ⚠️ Important Notes

- `.pbix` files can be very large (100MB+) - keep out of Git
- `.pbit` templates are much smaller (few MB) - good for Git
- Connection strings in templates should use parameters
- Always test templates after checking out from Git
