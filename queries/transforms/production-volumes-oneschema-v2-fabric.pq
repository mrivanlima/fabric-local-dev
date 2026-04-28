/**************************************************************************************
QUERY NAME:
    Pilzen Production Volume - OneSchema Transform

PURPOSE:
    Transform the original Pilzen Production Volume Excel file into the final
    OneSchema import format.

SOURCE:
    SharePoint file:
    https://digerati.sharepoint.com/sites/BusinessOps

SOURCE FOLDER:
    Shared Documents/Customer Data Information/Plzen/Production Scheduling/2026/

SOURCE FILE:
    Actuals March 2026.xlsx

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
**************************************************************************************/

let
    // ============================================================================
    // STEP 1: Load Excel File from SharePoint
    // Purpose:
    //     Connect to SharePoint instead of using a local file path.
    // ============================================================================

    SharePointSource = SharePoint.Files(
        "https://digerati.sharepoint.com/sites/BusinessOps",
        [ApiVersion = 15]
    ),

    // Filter to the exact SharePoint folder.
    FilteredToExactPlzenFolder = Table.SelectRows(
        SharePointSource,
        each [Folder Path] =
            "https://digerati.sharepoint.com/sites/BusinessOps/Shared Documents/Customer Data Information/Plzen/Production Scheduling/2026/"
    ),

    // Filter to the exact workbook name.
    FilteredToActualsWorkbook = Table.SelectRows(
        FilteredToExactPlzenFolder,
        each [Name] = "Actuals March 2026.xlsx"
    ),

    // Return a clear error if the file is not found.
    FileContent =
        if Table.RowCount(FilteredToActualsWorkbook) = 0 then
            error "Source workbook was not found in the expected SharePoint folder."
        else
            FilteredToActualsWorkbook{0}[Content],

    // Load the Excel workbook from the SharePoint binary content.
    Source = Excel.Workbook(
        FileContent,
        null,
        true
    ),

    // ============================================================================
    // STEP 2: Select Source Sheet
    // ============================================================================
    ProductionVolumesSheet = Source{[Item="Production Volumes",Kind="Sheet"]}[Data],

    // ============================================================================
    // STEP 3: Skip Title Rows and Promote Headers
    // ============================================================================
    SkippedRows = Table.Skip(ProductionVolumesSheet, 3),

    PromotedHeaders = Table.PromoteHeaders(
        SkippedRows,
        [PromoteAllScalars=true]
    ),

    // ============================================================================
    // STEP 4: Add Source Row Number
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
    // ============================================================================
    FilledDownProgram = Table.FillDown(
        AddedSourceRowNumber,
        {"Program"}
    ),

    // ============================================================================
    // STEP 6: Get Column Names and Define Identifier Columns
    // ============================================================================
    AllColumns = Table.ColumnNames(FilledDownProgram),

    IdentifierColumns = {
        "Program",
        "Part Number",
        "SAP number",
        "Description",
        "SourceRowNumber"
    },

    // ============================================================================
    // STEP 7: Detect Valid Date Columns
    // ============================================================================
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

    // ============================================================================
    // STEP 8: Build Month Metadata
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

    MonthMetadataSorted =
        Table.Sort(
            MonthMetadataRaw,
            {{"MonthStartDate", Order.Ascending}}
        ),

    // ============================================================================
    // STEP 9: Enforce Expected Monthly Sequence
    // ============================================================================
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

    ValidMonthMetadata =
        Table.SelectRows(
            MonthMetadataWithExpected,
            each [MonthStartDate] = [ExpectedMonthStartDate]
        ),

    ValidDateColumns =
        ValidMonthMetadata[MonthColumnName],

    // ============================================================================
    // STEP 10: Keep Only Needed Source Columns
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
    // STEP 11: Detect "Total complete vehicle"
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

    FilteredData = Table.SelectRows(
        SelectedValidColumns,
        each not ContainsTotalVehicleInRow(_)
    ),

    // ============================================================================
    // STEP 12: Keep Valid Part Detail Rows
    // ============================================================================
    CleanedData = Table.SelectRows(
        FilteredData,
        each
            [Program] <> null and Text.Trim(Text.From([Program])) <> "" and
            [#"Part Number"] <> null and Text.Trim(Text.From([#"Part Number"])) <> "" and
            [Description] <> null and Text.Trim(Text.From([Description])) <> ""
    ),

    // ============================================================================
    // STEP 13: Unpivot Monthly Columns
    // ============================================================================
    UnpivotedData = Table.Unpivot(
        CleanedData,
        ValidDateColumns,
        "PeriodDate",
        "Volume"
    ),

    // ============================================================================
    // STEP 14: Parse Period Date
    // ============================================================================
    ParsedDates = Table.TransformColumns(
        UnpivotedData,
        {{"PeriodDate", each Date.From(DateTime.From(_)), type date}}
    ),

    // ============================================================================
    // STEP 15: Add Date Fields
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
    // STEP 18: Process First Total Complete Vehicle Row
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
    // STEP 19: Combine Final Rows
    // ============================================================================
    CombinedData = Table.Combine(
        {
            AddedVolumeForecast,
            TotalVehicleUnpivoted
        }
    ),

    // ============================================================================
    // STEP 20: Select Final Columns
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
    // STEP 21: Set Final Types
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