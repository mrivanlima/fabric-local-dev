# Production Volumes to OneSchema Transformation

## Overview
This Power Query (M language) script transforms Pilzen Production Volume data from Excel into the OneSchema template format. The script is **production-ready** and includes robust logic to handle:

- **Dynamic month detection** - Automatically detects and validates monthly date columns (Jan 2025 - Mar 2026)
- **Chronological validation** - Filters out typo columns (e.g., "Juli 05") and quarterly aggregations
- **Program fill-down** - Handles merged cells in Excel by filling down the Program column
- **Grand total handling** - Separately processes "Total complete vehicle" row (line 68) and merges it with part-level data
- **Null safety** - Uses defensive checks to prevent errors on empty or malformed data

## Files
- **`production-volumes-oneschema-v2.pq`** - Local development version (uses local file path: `C:\Development\fabric-local-dev\data\...`)
- **`production-volumes-oneschema-v2-fabric.pq`** - Microsoft Fabric version (SharePoint connection placeholder - requires configuration before deployment)

---

## 🎯 Acceptance Criteria

✅ **AC1: Dataflow connects to Production Volume Data**
- Loads Excel file: `C:\Development\fabric-local-dev\data\Actuals-March-2026.xlsx`
- Sheet: "Production Volumes"
- Skips title rows (first 3 rows) and promotes headers

✅ **AC2: Data transformed to OneSchema template**
- All columns mapped correctly
- Dates parsed as DATE type
- Volumes converted to numbers
- Unpivoted from wide (months as columns) to long (one row per part per month)

✅ **AC3: Required fields populated**
- **Period Start**: First day of each month
- **Period End**: Last day of each month
- **Product/Line Name**: Filled down from Program column (PO416, VW275, XFK, PPE/PPC, Caddy5)
- **Volume Produced**: Monthly production values
- **ReportDate**: Set to null (per requirements)
- **Product/Line ID**: Set to null (per requirements)

✅ **AC4: Grand total included**
- "Total complete vehicle" row (Excel line 68) included with:
  - Product/Line Name = "Total complete vehicle"
  - Part Id = null
  - Part Description = null
  - Volume Produced = monthly totals

✅ **AC5: Data quality filters**
- Excludes program subtotals (rows without Part Number)
- Excludes quarterly aggregations (Q1-2025, Q2-2025, etc.)
- Excludes typo columns (Juli 05, etc.)
- Only includes months in correct chronological order (Jan 2025 → Mar 2026)

---

## 📊 Output Schema

| Column Name | Source | Type | Required | Notes |
|-------------|--------|------|----------|-------|
| ReportDate | null | DATE | No | Per requirements, always null |
| Period Start | Calculated from month column | DATE | Yes | First day of month |
| Period End | Calculated from month column | DATE | Yes | Last day of month |
| Product/Line Name | Program column (filled down) | TEXT | Yes | PO416, VW275, XFK, etc. OR "Total complete vehicle" |
| Product/Line ID | null | TEXT | No | Per requirements, always null |
| Volume Forecast | null | NUMBER | No | Future enhancement |
| Volume Produced | Monthly volume value | NUMBER | Yes | Actual production volumes |
| Part Id | Part Number column | TEXT | No | null for "Total complete vehicle" row |
| Part Description | Description column | TEXT | No | null for "Total complete vehicle" row |

---

## 🔄 Transformation Logic (15 Steps)

### **STEP 1: Load Excel File**
- Connects to local Excel file using `Excel.Workbook()`
- Selects "Production Volumes" sheet
- Loads raw data with headers in multiple rows

### **STEP 2: Skip Title Rows and Promote Headers**
- Skips first 3 rows (title, ACT/Q3FC labels, blank row)
- Promotes row 4 as column headers
- Adds `SourceRowNumber` to track original Excel row position (used to identify first "Total complete vehicle" row)

### **STEP 3: Fill Down Program Column**
- Uses `Table.FillDown()` to populate Program in all rows
- Handles merged cells in Excel where Program only appears in first row of each section

### **STEP 4: Detect Valid Monthly Date Columns Dynamically**
- **Dynamic detection**: Scans all columns and parses as dates
- **Validation**: Only keeps dates >= January 1, 2025
- **Chronological check**: Sorts months and validates they follow expected sequence (Jan → Feb → Mar, etc.)
- **Filters out**:
  - Quarterly columns (Q1-2025, Q2-2025, etc.)
  - Typo columns (Juli 05, etc.)
  - Out-of-order months
- **Result**: List of valid month column names (e.g., "Januar 25", "Februar 25", ..., "März 26")

### **STEP 5: Find First "Total complete vehicle" Row**
- Searches all row values for exact text "total complete vehicle" (case-insensitive)
- Identifies Excel line 68 (first occurrence)
- Separates this row for special processing
- Removes ALL "Total complete vehicle" rows from part-level data

### **STEP 6: Filter Part-Level Data**
- Removes rows where:
  - Program is null or empty
  - Part Number is null or empty (excludes subtotals)
  - Description is null or empty

### **STEP 7: Unpivot Monthly Columns (Part-Level)**
- Transforms from wide format (months as columns) to long format
- Each part now has one row per month
- Creates two new columns:
  - `PeriodDate` = month column name (e.g., "Januar 25")
  - `Volume` = production volume value

### **STEP 8: Parse Dates (Part-Level)**
- Converts month column names to actual dates
- "Januar 25" → 2025-01-01
- "März 26" → 2026-03-01

### **STEP 9: Add Period Start, Period End, ReportDate (Part-Level)**
- **Period Start**: `Date.StartOfMonth()` - first day of month
- **Period End**: `Date.EndOfMonth()` - last day of month
- **ReportDate**: Set to null (per requirements)

### **STEP 10: Clean Volume Data (Part-Level)**
- Converts Volume column to number type
- Handles nulls and text values with `try...otherwise`
- Keeps rows with valid volumes (including zeros)
- Removes rows where Volume = null

### **STEP 11: Map to OneSchema Schema (Part-Level)**
- Renames columns:
  - Program → Product/Line Name
  - Part Number → Part Id
  - Description → Part Description
  - Volume → Volume Produced
- Removes unnecessary columns (SAP number, PeriodDate, SourceRowNumber)
- Adds OneSchema columns:
  - Product/Line ID = null
  - Volume Forecast = null

### **STEP 12: Process "Total complete vehicle" Row**
- IF first total vehicle row exists:
  - Unpivots monthly columns (same as part-level data)
  - Parses dates and adds Period Start/End/ReportDate
  - Cleans volume data
  - Sets Product/Line Name = "Total complete vehicle"
  - Sets Part Id = null
  - Sets Part Description = null
  - Sets Product/Line ID = null
  - Sets Volume Forecast = null
- ELSE: Returns empty table with correct schema

### **STEP 13: Combine Part-Level and Total Vehicle Data**
- Uses `Table.Combine()` to merge both datasets
- Result: All part rows + "Total complete vehicle" monthly rows

### **STEP 14: Select and Order Final Columns**
- Ensures columns appear in correct OneSchema order:
  1. ReportDate
  2. Period Start
  3. Period End
  4. Product/Line Name
  5. Product/Line ID
  6. Volume Forecast
  7. Volume Produced
  8. Part Id
  9. Part Description

### **STEP 15: Set Final Column Types and Sort**
- Sets correct data types for all columns
- Sorts by:
  1. Period Start (ascending)
  2. Product/Line Name (ascending)
  3. Part Id (ascending)

---

## 🚀 Usage

### **Local Development (Power BI Desktop)**

1. Open **Power BI Desktop**
2. **Home** → **Get Data** → **Blank Query**
3. Open **Advanced Editor**
4. Copy entire contents of `production-volumes-oneschema-v2.pq`
5. Paste into Advanced Editor
6. Click **Done**
7. Preview data to verify transformation
8. **Expected result**: 728 rows (713 part-level + 15 "Total complete vehicle")

### **Testing Checklist**
✅ Verify "Total complete vehicle" appears in Product/Line Name column (15 rows)  
✅ Verify Part Id is null for "Total complete vehicle" rows  
✅ Verify Part Description is null for "Total complete vehicle" rows  
✅ Verify all months from Jan 2025 to Mar 2026 are included (15 months)  
✅ Verify no quarterly columns (Q1-2025, Q2-2025) appear  
✅ Verify no subtotal rows (rows without Part Number) appear  
✅ Verify Juli 2025 is included (not excluded due to Q3FC label)  
✅ Verify "Juli 05" typo column is excluded  

### **Deploy to Microsoft Fabric with SharePoint**

**Prerequisites:**
- Excel file uploaded to SharePoint document library
- Permissions to access SharePoint site
- Microsoft Fabric workspace with Dataflow Gen2 capability

**Steps:**

1. Open **Microsoft Fabric** workspace
2. Create new **Dataflow Gen2**
3. **Get Data** → **Blank Query**
4. Open **Advanced Editor**
5. Copy entire contents of **`production-volumes-oneschema-v2-fabric.pq`**
6. Paste into Advanced Editor
7. **Configure SharePoint connection** (lines 5-25):
   
   Replace the placeholder connection with your SharePoint details:
   
   ```m
   SharePointSource = SharePoint.Files(
       "https://yourorg.sharepoint.com/sites/yoursite", 
       [ApiVersion = 15]
   ),
   
   FilteredFile = Table.SelectRows(
       SharePointSource, 
       each Text.Contains([Name], "Actuals-March-2026.xlsx")
   ),
   
   FileContent = FilteredFile{0}[Content],
   
   Source = Excel.Workbook(FileContent, null, true),
   ```
   
   **Replace:**
   - `yourorg.sharepoint.com/sites/yoursite` → Your actual SharePoint site URL
   - `Actuals-March-2026.xlsx` → Your Excel file name (can keep as-is if using same file)

8. **Delete the placeholder line** (line 38):
   ```m
   Source = #table({"Item", "Kind", "Data"}, ...),
   ```
   
9. Click **Done**
10. **Authenticate** to SharePoint when prompted
11. **Preview data** to verify transformation (should see 728 rows)
12. Configure **destination** (Lakehouse table or SQL database)
13. **Publish** dataflow
14. Schedule **refresh** (e.g., daily, weekly)

---

## 📋 Sample Output

### Part-Level Data (First 5 Rows)
| ReportDate | Period Start | Period End | Product/Line Name | Product/Line ID | Volume Forecast | Volume Produced | Part Id | Part Description |
|------------|--------------|------------|-------------------|-----------------|-----------------|-----------------|---------|------------------|
| null | 2025-01-01 | 2025-01-31 | PO416 | null | null | 2448 | 95B885501A | ASW BACKREST LH |
| null | 2025-02-01 | 2025-02-28 | PO416 | null | null | 2826 | 95B885501A | ASW BACKREST LH |
| null | 2025-03-01 | 2025-03-31 | PO416 | null | null | 4149 | 95B885501A | ASW BACKREST LH |
| null | 2025-04-01 | 2025-04-30 | PO416 | null | null | 4419 | 95B885501A | ASW BACKREST LH |
| null | 2025-05-01 | 2025-05-31 | PO416 | null | null | 3816 | 95B885501A | ASW BACKREST LH |

### Total Complete Vehicle Data (First 5 Rows)
| ReportDate | Period Start | Period End | Product/Line Name | Product/Line ID | Volume Forecast | Volume Produced | Part Id | Part Description |
|------------|--------------|------------|-------------------|-----------------|-----------------|-----------------|---------|------------------|
| null | 2025-01-01 | 2025-01-31 | Total complete vehicle | null | null | 35458 | null | null |
| null | 2025-02-01 | 2025-02-28 | Total complete vehicle | null | null | 38282 | null | null |
| null | 2025-03-01 | 2025-03-31 | Total complete vehicle | null | null | 45931 | null | null |
| null | 2025-04-01 | 2025-04-30 | Total complete vehicle | null | null | 53302 | null | null |
| null | 2025-05-01 | 2025-05-31 | Total complete vehicle | null | null | 41875 | null | null |

---

## 🔍 Key Design Decisions

### 1. **Dynamic Month Detection vs. Hardcoded List**
**Decision**: Dynamic detection using date parsing and chronological validation

**Why**: 
- Robust against typos (e.g., "Juli 05")
- Automatically adapts to new months added to Excel
- Filters out quarterly aggregations without hardcoding column names

**Implementation**:
```m
IsValidDateColumn = (columnName as text) as logical =>
    let
        ParsedDate = try Date.From(DateTime.From(columnName)) otherwise null,
        IsValid = ParsedDate <> null and ParsedDate >= #date(2025, 1, 1)
    in
        IsValid
```

### 2. **Program Fill-Down**
**Decision**: Use `Table.FillDown()` on Program column

**Why**: 
- Excel uses merged cells for Program (only appears in first row of each section)
- Fill-down ensures every part row has a Product/Line Name

**Implementation**:
```m
FilledDownProgram = Table.FillDown(AddedSourceRowNumber, {"Program"})
```

### 3. **"Total complete vehicle" Handling**
**Decision**: Separate processing and combine with `Table.Combine()`

**Why**: 
- Total row has different structure (no Part Number or Description)
- OneSchema requires Part Id = null (not "Total complete vehicle")
- Safer to process separately than apply complex conditional logic

**Implementation**:
- Find first occurrence using `SourceRowNumber`
- Remove all total rows from part-level data
- Process total row separately
- Combine at the end

### 4. **Filtering Subtotals**
**Decision**: Filter out rows where Part Number is null or empty

**Why**: 
- Subtotals don't have Part Numbers
- Simpler and more reliable than text matching on Program or Description

**Implementation**:
```m
CleanedData = Table.SelectRows(
    FilteredData, 
    each [#"Part Number"] <> null and Text.Trim(Text.From([#"Part Number"])) <> ""
)
```

### 5. **Chronological Validation**
**Decision**: Sort detected months and compare against expected sequence

**Why**: 
- Catches out-of-order months (typos like "Juli 05")
- Ensures only valid timeline months are included (Jan 2025 → Mar 2026)

**Implementation**:
```m
MonthMetadataWithExpected = Table.AddColumn(
    MonthMetadataWithIndex,
    "ExpectedMonthStartDate",
    each Date.AddMonths(#date(2025, 1, 1), [MonthIndex])
)
ValidMonthMetadata = Table.SelectRows(
    MonthMetadataWithExpected,
    each [MonthStartDate] = [ExpectedMonthStartDate]
)
```

---

## ⚠️ Troubleshooting

### **Issue: "Column not found" error**
**Cause**: Excel file structure changed (columns renamed, moved, or deleted)

**Solution**: 
- Verify Excel file matches expected structure:
  - Column A: Program
  - Column B: Part Number
  - Column C: SAP number
  - Column D: Description
  - Columns E+: Monthly date columns
- Check that row 4 contains headers (rows 1-3 are skipped)

### **Issue: "Total complete vehicle" not appearing in output**
**Cause**: Script couldn't find row with exact text "total complete vehicle"

**Solution**: 
- Verify Excel line 68 contains "Total complete vehicle" in Part Number column
- Check for typos, extra spaces, or different capitalization
- Script uses case-insensitive search, but text must match exactly

### **Issue: Juli 2025 missing from output**
**Cause**: Column header couldn't be parsed as date or failed chronological validation

**Solution**: 
- Check column header format (should be "Juli 25" or parseable as 2025-07-01)
- Verify Juli 2025 is in correct chronological position (after Juni 25, before August 25)
- Check for duplicate Juli columns (script keeps first occurrence)

### **Issue: Quarterly columns (Q1-2025, Q2-2025) appearing in output**
**Cause**: Quarter column names are being parsed as dates

**Solution**: 
- Verify chronological validation is working
- Quarterly columns should fail `ExpectedMonthStartDate` check
- Check Excel file for unexpected date formats

### **Issue: Subtotal rows appearing in output**
**Cause**: Subtotal rows have Part Numbers

**Solution**: 
- Verify Part Number column is truly empty for subtotals
- Check for hidden characters or spaces
- Add additional filter logic if needed:
  ```m
  each not Text.Contains(Text.Lower([Description]), "total")
  ```

### **Issue: Dates not parsing correctly**
**Cause**: Regional settings or date format mismatch

**Solution**: 
- Use `DateTime.From()` wrapper: `Date.From(DateTime.From(columnName))`
- Check Power BI regional settings: File → Options → Regional Settings
- Verify Excel date format is recognized (should be datetime type)

### **Issue: Null or zero volumes**
**Cause**: Source cells contain formulas with errors or text values

**Solution**: 
- Script uses `try...otherwise null` to handle conversion errors
- Null volumes are filtered out
- Check Excel formulas for #N/A, #DIV/0!, etc.

---

## 🔧 Maintenance & Updates

### **Adding New Months**
1. Add new month columns to Excel file
2. Ensure columns follow naming pattern (e.g., "April 26", "Mai 26")
3. Script will automatically detect and include new months (no code changes needed)

### **Changing Source File Path**
Update line 6 in the script:
```m
Source = Excel.Workbook(
    File.Contents("C:\\Development\\fabric-local-dev\\data\\Actuals-March-2026.xlsx"), 
    null, 
    true
)
```

### **Adding Volume Forecast Column**
Currently `Volume Forecast` is set to null. To populate:
1. Parse row 2 (Actual, Q3FC, BP26 labels)
2. Route values based on label:
   - "Actual" → Volume Produced
   - "Q3FC", "BP26" → Volume Forecast

### **Supporting Multiple Sheets**
If Excel has multiple month sheets:
```m
AllSheets = List.Select(Source[Name], each Text.StartsWith(_, "Production"))
CombinedData = Table.Combine(List.Transform(AllSheets, each ProcessSheet(_)))
```

---

## 📚 Power Query M Language Reference

### **Key Functions Used**
- `Excel.Workbook()` - Load Excel file
- `Table.Skip()` - Skip header rows
- `Table.PromoteHeaders()` - Promote first row to headers
- `Table.FillDown()` - Fill down merged cells
- `Table.SelectRows()` - Filter rows by condition
- `Table.Unpivot()` - Transform wide to long format
- `Date.From()` / `DateTime.From()` - Parse dates
- `Date.StartOfMonth()` / `Date.EndOfMonth()` - Calculate period boundaries
- `Table.TransformColumns()` - Change data types
- `Table.RenameColumns()` - Rename columns
- `Table.AddColumn()` - Add calculated columns
- `Table.Combine()` - Merge multiple tables
- `Table.Sort()` - Sort by multiple columns
- `try...otherwise` - Error handling

---

## 📞 Contact & Support
For questions or issues, contact **Data & Analytics Team**

**Related Files**:
- Source Excel: `data/Actuals-March-2026.xlsx`
- Power Query Script (Local): `queries/transforms/production-volumes-oneschema-v2.pq`
- Power Query Script (Fabric/SharePoint): `queries/transforms/production-volumes-oneschema-v2-fabric.pq`
- Expected Output: `data/Pilzen_Production_Volume_Cleaned_OneSchema_v3.xlsx`
