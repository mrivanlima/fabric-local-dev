/**************************************************************************************
QUERY NAME:
    Pilzen Production Volume - OneSchema Transform

PURPOSE:
    Transform the original Pilzen Production Volume Excel file into the final
    OneSchema import format.

SOURCE FILE:
    C:\Development\fabric-local-dev\data\Actuals-March-2026.xlsx

SOURCE SHEET:
    Production Volumes

FINAL OUTPUT COLUMNS:
    1. ReportDate
    2. Period Start
    3. Period End
    4. Product/Line Name
    5. Product/Line ID
    6. Volume Forecast
    7. Volume Produced
    8. Part Id
    9. Part Description

BUSINESS RULES:
    - ReportDate is blank for now.
    - Period Start is the first day of the production month.
    - Period End is the last day of the production month.
    - Product/Line Name maps from Program.
    - Product/Line ID is blank for now.
    - Volume Forecast is blank for now.
    - Volume Produced maps from the monthly production values.
    - Part Id maps from Part Number.
    - Part Description maps from Description.
    - "Total complete vehicle" must be included as its own Product/Line Name.
    - Only the first "Total complete vehicle" row should be included.
    - Duplicate/later "Total complete vehicle" rows should be ignored.
    - ACT / Q3FC / BP labels are ignored because they are not reliable.
    - Month columns are detected dynamically from valid date-style headers.
    - Bad typo month/date columns are removed by enforcing the expected monthly sequence.
    - Zero volumes are kept. Only null volume values are removed.

HIGH-LEVEL STEPS:
    1. Load the Excel workbook.
    2. Select the Production Volumes sheet.
    3. Skip the title rows and promote the real header row.
    4. Add a source row number for traceability and ordering.
    5. Fill down Program values so detail rows inherit their Program.
    6. Detect valid month columns dynamically from date-style column headers.
    7. Build month metadata and enforce expected chronological order from Jan 2025 forward.
    8. Keep identifier columns plus validated month columns only.
    9. Dynamically find the first "Total complete vehicle" row across the whole row.
    10. Remove all "Total complete vehicle" rows from normal part-level processing.
    11. Keep valid part detail rows.
    12. Unpivot monthly columns into one row per part per month.
    13. Convert the month column into Period Start and Period End.
    14. Clean volume values and keep zero volumes.
    15. Rename/map part-level columns to OneSchema.
    16. Separately transform the first "Total complete vehicle" row.
    17. Append part-level rows and Total complete vehicle rows.
    18. Select, type, and sort the final OneSchema output.
**************************************************************************************/

let
    // ============================================================================
    // STEP 1: Load Excel File
    // Purpose:
    //     Connect to the original Excel workbook from the local development path.
    // ============================================================================
    Source = Excel.Workbook(
        File.Contents("C:\Development\fabric-local-dev\data\Actuals-March-2026.xlsx"), 
        null, 
        true
    ),
    
    // ============================================================================
    // STEP 2: Select Source Sheet
    // Purpose:
    //     Select the "Production Volumes" sheet that contains the raw production data.
    // ============================================================================
    ProductionVolumesSheet = Source{[Item="Production Volumes",Kind="Sheet"]}[Data],
    
    // ============================================================================
    // STEP 3: Skip Title Rows and Promote Headers
    // Purpose:
    //     The Excel file has title/helper rows before the usable header row.
    //     Skipping 3 rows makes the next row become the real header row.
    // ============================================================================
    SkippedRows = Table.Skip(
        ProductionVolumesSheet, 
        3
    ),
    
    // Promote the first remaining row to headers.
    // This gives us columns like Program, Part Number, Description, and month dates.
    PromotedHeaders = Table.PromoteHeaders(
        SkippedRows, 
        [PromoteAllScalars=true]
    ),

    // ============================================================================
    // STEP 4: Add Source Row Number
    // Purpose:
    //     Preserve the original row order after promoting headers.
    //     This is especially important when keeping only the first
    //     "Total complete vehicle" row.
    // ============================================================================
    AddedSourceRowNumber = Table.AddIndexColumn(
        PromotedHeaders,
        "SourceRowNumber",
        1,
        1,
        Int64.Type
    ),
    
    // ============================================================================
    // STEP 5: Fill Down Program
    // Purpose:
    //     In the source file, Program behaves like a group header.
    //     Detail rows underneath may have blank Program values.
    //     Fill down makes every detail row inherit the correct Program.
    // ============================================================================
    FilledDownProgram = Table.FillDown(
        AddedSourceRowNumber, 
        {"Program"}
    ),
    
    // ============================================================================
    // STEP 6: Get Column Names and Define Identifier Columns
    // Purpose:
    //     Separate fixed identifier columns from dynamic month columns.
    // ============================================================================
    AllColumns = Table.ColumnNames(
        FilledDownProgram
    ),

    // These columns identify the row and should not be unpivoted as production months.
    IdentifierColumns = {
        "Program", 
        "Part Number", 
        "SAP number", 
        "Description",
        "SourceRowNumber"
    },

    // ============================================================================
    // STEP 7: Define Valid Date Column Function
    // Purpose:
    //     Identify month columns dynamically.
    //     A valid month column is a column name that can be parsed as a date
    //     and is on or after Jan 1, 2025.
    // ============================================================================
    IsValidDateColumn = (columnName as text) as logical =>
        let
            ParsedDate = try Date.From(DateTime.From(columnName)) otherwise null,
            IsValid = ParsedDate <> null and ParsedDate >= #date(2025, 1, 1)
        in
            IsValid,

    // Apply the date-column detection function to all columns.
    ValidDateColumnsRaw = List.Select(
        AllColumns, 
        each IsValidDateColumn(_)
    ),

    // ============================================================================
    // STEP 8: Build Month Metadata
    // Purpose:
    //     Create a small lookup table with:
    //         - original month column name
    //         - parsed month start date
    //     This lets us validate and sort months correctly.
    // ============================================================================
    MonthMetadataRaw =
        Table.FromRecords(
            List.Transform(
                ValidDateColumnsRaw,
                each [
                    MonthColumnName = _,
                    MonthStartDate = Date.StartOfMonth(Date.From(DateTime.From(_)))
                ]
            )
        ),

    // Sort parsed month columns in chronological order.
    MonthMetadataSorted =
        Table.Sort(
            MonthMetadataRaw,
            {{"MonthStartDate", Order.Ascending}}
        ),

    // ============================================================================
    // STEP 9: Enforce Expected Monthly Sequence
    // Purpose:
    //     Remove bad typo/out-of-sequence date columns.
    //     The expected sequence starts at Jan 2025:
    //         Jan 2025, Feb 2025, Mar 2025, ...
    // ============================================================================
    MonthMetadataWithIndex =
        Table.AddIndexColumn(
            MonthMetadataSorted,
            "MonthIndex",
            0,
            1,
            Int64.Type
        ),

    // Calculate what each month should be based on its sequence position.
    MonthMetadataWithExpected =
        Table.AddColumn(
            MonthMetadataWithIndex,
            "ExpectedMonthStartDate",
            each Date.AddMonths(#date(2025, 1, 1), [MonthIndex]),
            type date
        ),

    // Keep only columns where the actual parsed month matches the expected month.
    ValidMonthMetadata =
        Table.SelectRows(
            MonthMetadataWithExpected,
            each [MonthStartDate] = [ExpectedMonthStartDate]
        ),

    // Extract the final validated month column names.
    ValidDateColumns =
        ValidMonthMetadata[MonthColumnName],

    // ============================================================================
    // STEP 10: Keep Only Needed Source Columns
    // Purpose:
    //     Keep identifier columns and validated month columns.
    //     This removes unreliable ACT/Q3FC/BP/helper columns.
    // ============================================================================
    ColumnsToKeep = List.Combine(
        {
            IdentifierColumns, 
            ValidDateColumns
        }
    ),

    SelectedValidColumns = Table.SelectColumns(
        FilledDownProgram, 
        ColumnsToKeep,
        MissingField.Ignore
    ),
    
    // ============================================================================
    // STEP 11: Define Function to Detect "Total complete vehicle"
    // Purpose:
    //     Search the entire row instead of only one column.
    //     This makes the logic more robust if the text moves to another column.
    // ============================================================================
    ContainsTotalVehicleInRow = (rowRecord as record) as logical =>
        let
            RowValues = Record.FieldValues(rowRecord),
            CleanValues = List.Transform(
                RowValues,
                each Text.Lower(Text.Trim(Text.From(_)))
            ),
            Result = List.Contains(
                CleanValues, 
                "total complete vehicle"
            )
        in
            Result,

    // Find all source rows containing "Total complete vehicle".
    TotalVehicleRows = Table.SelectRows(
        SelectedValidColumns,
        each ContainsTotalVehicleInRow(_)
    ),

    // Keep only the first Total complete vehicle row by source order.
    FirstTotalVehicleRow =
        Table.FirstN(
            Table.Sort(
                TotalVehicleRows,
                {{"SourceRowNumber", Order.Ascending}}
            ),
            1
        ),

    // Remove all Total complete vehicle rows from regular part-level processing.
    FilteredData = Table.SelectRows(
        SelectedValidColumns,
        each not ContainsTotalVehicleInRow(_)
    ),

    // ============================================================================
    // STEP 12: Keep Valid Part Detail Rows
    // Purpose:
    //     A valid part row must have:
    //         - Program
    //         - Part Number
    //         - Description
    // ============================================================================
    CleanedData = Table.SelectRows(
        FilteredData, 
        each 
            [Program] <> null and Text.Trim(Text.From([Program])) <> "" and
            [#"Part Number"] <> null and Text.Trim(Text.From([#"Part Number"])) <> "" and
            [Description] <> null and Text.Trim(Text.From([Description])) <> ""
    ),
    
    // ============================================================================
    // STEP 13: Unpivot Monthly Columns for Part-Level Data
    // Purpose:
    //     Convert wide month columns into rows:
    //         one row per Program / Part / Month.
    // ============================================================================
    UnpivotedData = Table.Unpivot(
        CleanedData, 
        ValidDateColumns, 
        "PeriodDate", 
        "Volume"
    ),
    
    // ============================================================================
    // STEP 14: Parse Period Date
    // Purpose:
    //     Convert the unpivoted month column name into an actual date.
    // ============================================================================
    ParsedDates = Table.TransformColumns(
        UnpivotedData,
        {{"PeriodDate", each Date.From(DateTime.From(_)), type date}}
    ),
    
    // ============================================================================
    // STEP 15: Add Period Start, Period End, and ReportDate
    // Purpose:
    //     Create OneSchema-required date fields.
    // ============================================================================
    AddedPeriodStart = Table.AddColumn(
        ParsedDates, 
        "Period Start", 
        each Date.StartOfMonth([PeriodDate]), 
        type date
    ),
    
    AddedPeriodEnd = Table.AddColumn(
        AddedPeriodStart, 
        "Period End", 
        each Date.EndOfMonth([PeriodDate]), 
        type date
    ),
    
    AddedReportDate = Table.AddColumn(
        AddedPeriodEnd, 
        "ReportDate", 
        each null, 
        type nullable date
    ),
    
    // ============================================================================
    // STEP 16: Clean Volume Data
    // Purpose:
    //     Convert monthly values to numbers.
    //     Keep zero values because zero can be a valid production result.
    //     Only null/unreadable values are removed.
    // ============================================================================
    CleanedVolume = Table.TransformColumns(
        AddedReportDate,
        {{"Volume", each try Number.From(_) otherwise null, type nullable number}}
    ),
    
    FilteredVolumes = Table.SelectRows(
        CleanedVolume, 
        each [Volume] <> null
    ),
    
    // ============================================================================
    // STEP 17: Map Part-Level Data to OneSchema
    // Purpose:
    //     Rename source fields to the required OneSchema field names.
    // ============================================================================
    RenamedColumns = Table.RenameColumns(
        FilteredVolumes,
        {
            {"Program", "Product/Line Name"},
            {"Part Number", "Part Id"},
            {"Description", "Part Description"},
            {"Volume", "Volume Produced"}
        },
        MissingField.Ignore
    ),
    
    // Remove fields that are not part of the OneSchema template.
    RemovedExtraColumns = Table.RemoveColumns(
        RenamedColumns, 
        {"SAP number", "PeriodDate", "SourceRowNumber"},
        MissingField.Ignore
    ),
    
    // Add blank Product/Line ID per current requirements.
    AddedProductLineID = Table.AddColumn(
        RemovedExtraColumns,
        "Product/Line ID",
        each null,
        type nullable text
    ),
    
    // Add blank Volume Forecast per current requirements.
    AddedVolumeForecast = Table.AddColumn(
        AddedProductLineID, 
        "Volume Forecast", 
        each null, 
        type nullable number
    ),
    
    // ============================================================================
    // STEP 18: Process First Total Complete Vehicle Row
    // Purpose:
    //     Transform the first Total complete vehicle row separately because it is not
    //     a normal part-level row. It has volume only, and Product/Line Name should
    //     be "Total complete vehicle".
    // ============================================================================
    TotalVehicleUnpivoted = 
        if Table.RowCount(FirstTotalVehicleRow) > 0 then
            let
                // Unpivot only validated month columns.
                Unpivoted = Table.Unpivot(
                    FirstTotalVehicleRow,
                    ValidDateColumns,
                    "PeriodDate",
                    "Volume"
                ),

                // Convert unpivoted month column name to date.
                ParsedTotalDates = Table.TransformColumns(
                    Unpivoted,
                    {{"PeriodDate", each Date.From(DateTime.From(_)), type date}}
                ),

                // Add Period Start.
                AddedTotalPeriodStart = Table.AddColumn(
                    ParsedTotalDates,
                    "Period Start",
                    each Date.StartOfMonth([PeriodDate]),
                    type date
                ),

                // Add Period End.
                AddedTotalPeriodEnd = Table.AddColumn(
                    AddedTotalPeriodStart,
                    "Period End",
                    each Date.EndOfMonth([PeriodDate]),
                    type date
                ),

                // Add blank ReportDate.
                AddedTotalReportDate = Table.AddColumn(
                    AddedTotalPeriodEnd,
                    "ReportDate",
                    each null,
                    type nullable date
                ),

                // Convert Total complete vehicle volume to number.
                CleanedTotalVolume = Table.TransformColumns(
                    AddedTotalReportDate,
                    {{"Volume", each try Number.From(_) otherwise null, type nullable number}}
                ),

                // Keep zero volumes; remove only null values.
                FilteredTotalVolume = Table.SelectRows(
                    CleanedTotalVolume,
                    each [Volume] <> null
                ),

                // Rename Volume to Volume Produced.
                RenamedTotalVolume = Table.RenameColumns(
                    FilteredTotalVolume,
                    {{"Volume", "Volume Produced"}},
                    MissingField.Ignore
                ),

                // Force Product/Line Name to the required business value.
                AddedProductLineName = Table.AddColumn(
                    RenamedTotalVolume,
                    "Product/Line Name",
                    each "Total complete vehicle",
                    type text
                ),

                // Total complete vehicle does not have Part Id.
                AddedPartId = Table.AddColumn(
                    AddedProductLineName,
                    "Part Id",
                    each null,
                    type nullable text
                ),

                // Total complete vehicle does not have Part Description.
                AddedPartDescription = Table.AddColumn(
                    AddedPartId,
                    "Part Description",
                    each null,
                    type nullable text
                ),

                // Remove source/helper columns not needed in final output.
                RemovedTotalExtraColumns = Table.RemoveColumns(
                    AddedPartDescription,
                    {"Program", "Part Number", "SAP number", "Description", "PeriodDate", "SourceRowNumber"},
                    MissingField.Ignore
                ),

                // Add blank Product/Line ID.
                AddedTotalProductLineID = Table.AddColumn(
                    RemovedTotalExtraColumns,
                    "Product/Line ID",
                    each null,
                    type nullable text
                ),

                // Add blank Volume Forecast.
                AddedTotalVolumeForecast = Table.AddColumn(
                    AddedTotalProductLineID,
                    "Volume Forecast",
                    each null,
                    type nullable number
                )
            in
                AddedTotalVolumeForecast
        else
            // If no Total complete vehicle row exists, return an empty table
            // with the expected final schema.
            #table(
                {
                    "ReportDate",
                    "Period Start",
                    "Period End",
                    "Product/Line Name",
                    "Product/Line ID",
                    "Volume Forecast",
                    "Volume Produced",
                    "Part Id",
                    "Part Description"
                },
                {}
            ),
    
    // ============================================================================
    // STEP 19: Combine Part-Level Rows and Total Complete Vehicle Rows
    // Purpose:
    //     Append both result sets into one final OneSchema-shaped table.
    // ============================================================================
    CombinedData = Table.Combine(
        {
            AddedVolumeForecast, 
            TotalVehicleUnpivoted
        }
    ),
    
    // ============================================================================
    // STEP 20: Select and Order Final Columns
    // Purpose:
    //     Keep only OneSchema template fields in the required order.
    // ============================================================================
    FinalColumns = Table.SelectColumns(
        CombinedData,
        {
            "ReportDate",
            "Period Start",
            "Period End",
            "Product/Line Name",
            "Product/Line ID",
            "Volume Forecast",
            "Volume Produced",
            "Part Id",
            "Part Description"
        },
        MissingField.UseNull
    ),
    
    // ============================================================================
    // STEP 21: Set Final Column Types
    // Purpose:
    //     Ensure columns have the correct data types before import.
    // ============================================================================
    TypedColumns = Table.TransformColumnTypes(
        FinalColumns,
        {
            {"ReportDate", type date},
            {"Period Start", type date},
            {"Period End", type date},
            {"Product/Line Name", type text},
            {"Product/Line ID", type text},
            {"Volume Forecast", type number},
            {"Volume Produced", type number},
            {"Part Id", type text},
            {"Part Description", type text}
        }
    ),
    
    // ============================================================================
    // STEP 22: Sort Final Output
    // Purpose:
    //     Sort the output for easier validation.
    // ============================================================================
    SortedRows = Table.Sort(
        TypedColumns,
        {
            {"Period Start", Order.Ascending},
            {"Product/Line Name", Order.Ascending},
            {"Part Id", Order.Ascending}
        }
    )

in
    SortedRows