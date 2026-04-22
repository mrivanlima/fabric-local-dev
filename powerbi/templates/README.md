# Power BI Templates

Template files (`.pbit`) that can be shared across the team.

## 📋 Available Templates

*(Template files will be added here as they are created)*

---

## 🎯 Creating a New Template

1. Build your report in Power BI Desktop
2. Use **parameters** for connection strings
3. Test thoroughly with Docker SQL Server
4. **File → Export → Power BI template**
5. Save here with descriptive name
6. Commit to Git

---

## 📝 Template Naming Convention

Use descriptive names that indicate the report purpose:

**Good names:**
- `sales-analysis-template.pbit`
- `customer-dashboard-template.pbit`
- `fabric-starter-template.pbit`

**Avoid:**
- `template1.pbit`
- `report.pbit`
- `untitled.pbit`

---

## 🔧 Using Parameters in Templates

When creating templates, use parameters for environment-specific values:

**Example parameters:**
- `ServerName` - SQL Server instance (e.g., "localhost,1433")
- `DatabaseName` - Database name (e.g., "FabricDev")
- `Environment` - "Local", "Dev", "Prod"

This makes templates reusable across different environments.
