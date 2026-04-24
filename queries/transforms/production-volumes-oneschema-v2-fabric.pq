let
    // ============================================================================
    // STEP 1: Load Excel File from SharePoint
    // ============================================================================
    // TODO: Configure SharePoint connection before deploying to Microsoft Fabric
    //
    // INSTRUCTIONS:
    // 1. Replace the placeholder connection below with your SharePoint details
    // 2. Update the SharePoint site URL to your organization's site
    // 3. Update the file name filter to match your Excel file
    // 4. Ensure the file is uploaded to SharePoint document library
    //
    // EXAMPLE SharePoint connection pattern:
    //
    //   SharePointSource = SharePoint.Files(
    //       "https://yourorg.sharepoint.com/sites/yoursite", 
    //       [ApiVersion = 15]
    //   ),
    //   
    //   FilteredFile = Table.SelectRows(
    //       SharePointSource, 
    //       each Text.Contains([Name], "Actuals-March-2026.xlsx")
    //   ),
    //   
    //   FileContent = FilteredFile{0}[Content],
    //   
    //   Source = Excel.Workbook(FileContent, null, true),
    //
    // Once configured, replace the placeholder Source line below.
    
    // PLACEHOLDER: Replace this line after configuring SharePoint connection above
    Source = #table(
        {"Item", "Kind", "Data"}, 
        {{"Production Volumes", "Sheet", #table({}, {})}}
    ),
    
    ProductionVolumesSheet = Source{[Item="Production Volumes",Kind="Sheet"]}[Data],
    
    // ============================================================================
    // STEP 2: Skip Title Rows and Promote Headers
    // ============================================================================
    SkippedRows = Table.Skip(ProductionVolumesSheet, 3),
    
    PromotedHeaders = Table.PromoteHeaders(
        SkippedRows, 
        [PromoteAllScalars=true]
    ),

    // Add row number so we can keep first Total complete vehicle dynamically
    AddedSourceRowNumber = Table.AddIndexColumn(
        PromotedHeaders,
        "SourceRowNumber",
        1,
        1,
        Int64.Type
    ),
    
    // ============================================================================
    // STEP 3: Fill Down Program Column
    // ============================================================================
    FilledDownProgram = Table.FillDown(
        AddedSourceRowNumber, 
        {"Program"}
    ),
    
    // ============================================================================
    // STEP 4: Detect Valid Monthly Date Columns Dynamically
    // ============================================================================
    AllColumns = Table.ColumnNames(FilledDownProgram),

    IdentifierColumns = {
        "Program", 
        "Part Number", 
        "SAP number", 
        "Description",
        "SourceRowNumber"
    },

    IsValidDateColumn = (columnName as text) as logical =>
        let
            ParsedDate = try Date.From(DateTime.From(columnName)) otherwise null,
            IsValid = ParsedDate <> null and ParsedDate >= #date(2025, 1, 1)
        in
            IsValid,

    ValidDateColumnsRaw = List.Select(
        AllColumns, 
        each IsValidDateColumn(_)
    ),

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

    // Sort months chronologically
    MonthMetadataSorted =
        Table.Sort(
            MonthMetadataRaw,
            {{"MonthStartDate", Order.Ascending}}
        ),

    // Add expected previous month to validate chronological sequence
    MonthMetadataWithIndex =
        Table.AddIndexColumn(
            MonthMetadataSorted,
            "MonthIndex",
            0,
            1,
            Int64.Type
        ),

    MonthMetadataWithExpected =
        Table.AddColumn(
            MonthMetadataWithIndex,
            "ExpectedMonthStartDate",
            each Date.AddMonths(#date(2025, 1, 1), [MonthIndex]),
            type date
        ),

    // Keep only months that follow expected Jan 2025, Feb 2025, Mar 2025, etc.
    ValidMonthMetadata =
        Table.SelectRows(
            MonthMetadataWithExpected,
            each [MonthStartDate] = [ExpectedMonthStartDate]
        ),

    ValidDateColumns =
        ValidMonthMetadata[MonthColumnName],

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
    // STEP 5: Find First "Total complete vehicle" Row Dynamically
    // ============================================================================
    ContainsTotalVehicleInRow = (rowRecord as record) as logical =>
        let
            RowValues = Record.FieldValues(rowRecord),
            CleanValues = List.Transform(
                RowValues,
                each Text.Lower(Text.Trim(Text.From(_)))
            ),
            Result = List.Contains(CleanValues, "total complete vehicle")
        in
            Result,

    TotalVehicleRows = Table.SelectRows(
        SelectedValidColumns,
        each ContainsTotalVehicleInRow(_)
    ),

    FirstTotalVehicleRow =
        Table.FirstN(
            Table.Sort(
                TotalVehicleRows,
                {{"SourceRowNumber", Order.Ascending}}
            ),
            1
        ),

    // Remove all Total complete vehicle rows from part-level data
    FilteredData = Table.SelectRows(
        SelectedValidColumns,
        each not ContainsTotalVehicleInRow(_)
    ),

    // Keep only valid part rows
    CleanedData = Table.SelectRows(
        FilteredData, 
        each 
            [Program] <> null and Text.Trim(Text.From([Program])) <> "" and
            [#"Part Number"] <> null and Text.Trim(Text.From([#"Part Number"])) <> "" and
            [Description] <> null and Text.Trim(Text.From([Description])) <> ""
    ),
    
    // ============================================================================
    // STEP 6: Unpivot Monthly Columns for Part-Level Data
    // ============================================================================
    UnpivotedData = Table.Unpivot(
        CleanedData, 
        ValidDateColumns, 
        "PeriodDate", 
        "Volume"
    ),
    
    // ============================================================================
    // STEP 7: Parse Dates
    // ============================================================================
    ParsedDates = Table.TransformColumns(
        UnpivotedData,
        {{"PeriodDate", each Date.From(DateTime.From(_)), type date}}
    ),
    
    // ============================================================================
    // STEP 8: Add Period Start, Period End, and ReportDate
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
    // STEP 9: Clean Volume Data
    // ============================================================================
    CleanedVolume = Table.TransformColumns(
        AddedReportDate,
        {{"Volume", each try Number.From(_) otherwise null, type nullable number}}
    ),
    
    // Keep zero volumes if they exist; only remove null volumes
    FilteredVolumes = Table.SelectRows(
        CleanedVolume, 
        each [Volume] <> null
    ),
    
    // ============================================================================
    // STEP 10: Map Part-Level Data to OneSchema
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
    
    RemovedExtraColumns = Table.RemoveColumns(
        RenamedColumns, 
        {"SAP number", "PeriodDate", "SourceRowNumber"},
        MissingField.Ignore
    ),
    
    AddedProductLineID = Table.AddColumn(
        RemovedExtraColumns,
        "Product/Line ID",
        each null,
        type nullable text
    ),
    
    AddedVolumeForecast = Table.AddColumn(
        AddedProductLineID, 
        "Volume Forecast", 
        each null, 
        type nullable number
    ),
    
    // ============================================================================
    // STEP 11: Process First Total Complete Vehicle Row
    // ============================================================================
    TotalVehicleUnpivoted = 
        if Table.RowCount(FirstTotalVehicleRow) > 0 then
            let
                Unpivoted = Table.Unpivot(
                    FirstTotalVehicleRow,
                    ValidDateColumns,
                    "PeriodDate",
                    "Volume"
                ),

                ParsedTotalDates = Table.TransformColumns(
                    Unpivoted,
                    {{"PeriodDate", each Date.From(DateTime.From(_)), type date}}
                ),

                AddedTotalPeriodStart = Table.AddColumn(
                    ParsedTotalDates,
                    "Period Start",
                    each Date.StartOfMonth([PeriodDate]),
                    type date
                ),

                AddedTotalPeriodEnd = Table.AddColumn(
                    AddedTotalPeriodStart,
                    "Period End",
                    each Date.EndOfMonth([PeriodDate]),
                    type date
                ),

                AddedTotalReportDate = Table.AddColumn(
                    AddedTotalPeriodEnd,
                    "ReportDate",
                    each null,
                    type nullable date
                ),

                CleanedTotalVolume = Table.TransformColumns(
                    AddedTotalReportDate,
                    {{"Volume", each try Number.From(_) otherwise null, type nullable number}}
                ),

                FilteredTotalVolume = Table.SelectRows(
                    CleanedTotalVolume,
                    each [Volume] <> null
                ),

                RenamedTotalVolume = Table.RenameColumns(
                    FilteredTotalVolume,
                    {{"Volume", "Volume Produced"}},
                    MissingField.Ignore
                ),

                AddedProductLineName = Table.AddColumn(
                    RenamedTotalVolume,
                    "Product/Line Name",
                    each "Total complete vehicle",
                    type text
                ),

                AddedPartId = Table.AddColumn(
                    AddedProductLineName,
                    "Part Id",
                    each null,
                    type nullable text
                ),

                AddedPartDescription = Table.AddColumn(
                    AddedPartId,
                    "Part Description",
                    each null,
                    type nullable text
                ),

                RemovedTotalExtraColumns = Table.RemoveColumns(
                    AddedPartDescription,
                    {"Program", "Part Number", "SAP number", "Description", "PeriodDate", "SourceRowNumber"},
                    MissingField.Ignore
                ),

                AddedTotalProductLineID = Table.AddColumn(
                    RemovedTotalExtraColumns,
                    "Product/Line ID",
                    each null,
                    type nullable text
                ),

                AddedTotalVolumeForecast = Table.AddColumn(
                    AddedTotalProductLineID,
                    "Volume Forecast",
                    each null,
                    type nullable number
                )
            in
                AddedTotalVolumeForecast
        else
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
    // STEP 12: Combine Part-Level and Total Vehicle Data
    // ============================================================================
    CombinedData = Table.Combine(
        {
            AddedVolumeForecast, 
            TotalVehicleUnpivoted
        }
    ),
    
    // ============================================================================
    // STEP 13: Select and Order Final Columns
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
    // STEP 14: Set Final Column Types
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
    // STEP 15: Sort Final Output
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
