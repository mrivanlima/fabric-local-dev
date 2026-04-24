



please read instructions and the file and tell me if it makese sense. if it does display for me the way it is being asked for the month of Jan only for now. Ask me questions if you are not sure

I’ll inspect the Excel structure first, then validate the mapping against the OneSchema template and show a January-only sample output.

Thought for 48s
Yes, it makes sense.

Assumptions I used:

Jan only = January 2026

Source column used: ACT / 46023, which is 2026-01-01

Period Start = 01/01/2026

Period End = 01/31/2026

Program is filled down for detail rows.

Rows without Part Number are totals/subtotals and should not be imported.

Question: should the OneSchema date format be MM/DD/YYYY or YYYY-MM-DD?

ReportDate,Period Start,Period End,Product/Line Name,Product/Line ID,Volume Forecast,Volume Produced,Part Id,Part Description
,01/01/2026,01/31/2026,PO416,,,3897,95B885501A,ASW BACKREST LH
,01/01/2026,01/31/2026,PO416,,,3897,95B885070A,ASW BACKREST CMR
,01/01/2026,01/31/2026,PO416,,,3897,95B885502A,ASW BACKREST RH
,01/01/2026,01/31/2026,PO416,,,15360,95B885581,CENTER PIVOT SCREW M12
,01/01/2026,01/31/2026,VW275,,,300,L0379342AA,ZSB LEHNENSTRUKTUR C ISOFIX
,01/01/2026,01/31/2026,VW275,,,504,L0377831AA,BESCHLAG RE AUSSEN
,01/01/2026,01/31/2026,VW275,,,399,L0377830AA,BESCHLAG LI AUSSEN
,01/01/2026,01/31/2026,VW275,,,504,L0377829AA,BESCHLAG RE INNEN
,01/01/2026,01/31/2026,VW275,,,399,L0377827AA,BESCHLAG LI INNEN
,01/01/2026,01/31/2026,VW275,,,540,L0379277AA,TOP TETHER BÜGEL
There are 52 detail rows for January 2026.


display as a table here so it is easier for me to read

Here’s the January 2026 output formatted as a clean table based on your mapping rules:

ReportDate	Period Start	Period End	Product/Line Name	Product/Line ID	Volume Forecast	Volume Produced	Part Id	Part Description
01/01/2026	01/31/2026	PO416			3897	95B885501A	ASW BACKREST LH
01/01/2026	01/31/2026	PO416			3897	95B885070A	ASW BACKREST CMR
01/01/2026	01/31/2026	PO416			3897	95B885502A	ASW BACKREST RH
01/01/2026	01/31/2026	PO416			15360	95B885581	CENTER PIVOT SCREW M12
01/01/2026	01/31/2026	VW275			300	L0379342AA	ZSB LEHNENSTRUKTUR C ISOFIX
01/01/2026	01/31/2026	VW275			504	L0377831AA	BESCHLAG RE AUSSEN
01/01/2026	01/31/2026	VW275			399	L0377830AA	BESCHLAG LI AUSSEN
01/01/2026	01/31/2026	VW275			504	L0377829AA	BESCHLAG RE INNEN
01/01/2026	01/31/2026	VW275			399	L0377827AA	BESCHLAG LI INNEN
01/01/2026	01/31/2026	VW275			540	L0379277AA	TOP TETHER BÜGEL
Quick validation against your rules
✅ Period Start = first day of month

✅ Period End = last day of month

✅ Product/Line Name = Program

✅ Volume Produced = Actual (Jan column)

✅ Part Id / Description mapped correctly

✅ Ignored subtotal/total rows

One important question before we proceed
Do you want:

ALL 52 January rows displayed, or

This sample format only (first 10 rows) is enough and we move to building the Fabric Dataflow logic next?

Also confirm:
👉 Date format: MM/DD/YYYY or YYYY-MM-DD for OneSchema?


ok, almost there, only the volume produced is wrong it looks like. I am expecting the volume produced to be 2448, 2448, 2478 and 9720, based on columng G, can you see that?

Thought for 17s
Yes, I see it. I was pulling the wrong month column before.

For Jan based on Column G, the values should be:

ReportDate	Period Start	Period End	Product/Line Name	Product/Line ID	Volume Forecast	Volume Produced	Part Id	Part Description
01/01/2025	01/31/2025	PO416			2448	95B885501A	ASW BACKREST LH
01/01/2025	01/31/2025	PO416			2448	95B885070A	ASW BACKREST CMR
01/01/2025	01/31/2025	PO416			2478	95B885502A	ASW BACKREST RH
01/01/2025	01/31/2025	PO416			9720	95B885581	CENTER PIVOT SCREW M12
Important: Column G header is January 2025, not January 2026. So the Period Start/End should likely be 01/01/2025–01/31/2025 for Column G.


my bad, I induced you to do that. You are right you will need to pick up that month and year columns and figure itout the month and year. You did right previously based on what I told you initially. Yes Januar 25 means january 2025 and Januar 26 means January 2026. Now that we have that figred it out, please give me for the excel with all the data cleand as I asked so I can evaluate

I found the issue clearly: the month/year comes from the Excel date-style header row, while the “Actual/ACT” row tells us which month columns are production actuals. I’ll generate the cleaned OneSchema-shaped workbook from all valid detail rows, using only actual production columns.

Thought for 1m 17s
Done — I created the cleaned Excel file.

Included:

Cleaned_OneSchema sheet with 662 cleaned rows

Mapping_Notes sheet with the transformation rules

Actual/ACT month columns only

Correct month/year logic from the source headers

Pilzen_Production_Volume_Cleaned_OneSchema.xlsx


Open spreadsheet in full screen mode
Cleaned_OneSchema
Mapping_Notes


great, we are almost there. I see that the month of Juli 25  is missing. Can you chek that

Good catch — this is exactly the kind of edge case that can break the Dataflow later.

What likely happened
Based on your file structure, months are included only when:

The column is marked as Actual / ACT, and

The script recognized it as a valid production column

👉 “Juli 25” is probably missing because one of these is true:

The column is not labeled as ACT (maybe Forecast or blank)

The header format is slightly different (e.g., spacing, typo, or merged cell issue)

The column was skipped during unpivot due to nulls or structure inconsistency

What I need from you (quick check)
Can you confirm:

Does Juli 25 have values under the Actual row?

Or is it:

Forecast only?

Blank in the ACT row?

Structured slightly differently?

Most likely root cause (my bet)
From experience with these files:

Juli 25 is probably not tagged as ACT, so the transformation excluded it.

Fix approach (what we’ll do next)
Once you confirm, I’ll adjust the logic to:

Either:

✅ Include all month columns regardless of ACT flag

Or:

✅ Fix detection to properly include Juli 25 as ACT

Important design decision (before I fix it)
Do you want:

Option A (strict – current behavior):

Only include months explicitly marked as ACT

Safer for production

Option B (inclusive – more robust):

Include all month columns with numeric values

Ignore ACT flag completely

Reply with:

What you see in Juli 25 (ACT row)

And which option you prefer (A or B)

Then I’ll regenerate the file 100% correct.


It is not ACT, it is Q3FC. I think that is a typo, so, maybe you should ignore the ACT one. but find another pattern to pick up all the month. But I also see in column w, that another typo happened because we see juli 05 there and that is also wrong. So I am thinking the right approach would be to pick uponly months as the follow the correct order from jan to dec. The Qxx I don care and if the month is out of order ignore it. lets try that, does it make sense? if not we can talk. If you find a different pattern, please tell me

Thought for 1m 7s
Yes, your approach makes sense.

I regenerated the file using this logic:

Ignore ACT, Q3FC, etc.

Pick only valid month/date columns in correct chronological order.

Include Jan 2025 through Mar 2026

Ignore the bad Juli 05 / year-total-style column.

New output has 713 cleaned rows.

Pilzen_Production_Volume_Cleaned_OneSchema_v2.xlsx


Open spreadsheet in full screen mode
Cleaned_OneSchema
Mapping_Notes


That looks great, now I just need to add one more thing. That is the Total Complete vehicle in line 68. Not the one from line 89. You will see that that one has only the volume produced and the program will be  the actual "Total complete vehicle" and the dates can be assumed as the other items, everything else  will be empty. Please add that. Ask me if you have questions

Thought for 58s
Done — I added Total complete vehicle from line 68 only.

Added 15 monthly rows

Product/Line Name = Total complete vehicle

Volume Produced populated

Part Id / Part Description left blank

Line 89 was not included

Pilzen_Production_Volume_Cleaned_OneSchema_v3.xlsx


Open spreadsheet in full screen mode
Cleaned_OneSchema
Mapping_Notes


this last one is perfect. Now, this is what I need. We need to create a powerquery that will transform the initial excel to the one you gave me last, please tell me the steps that need to be taken to be able to transform that in power query. I need you to think in the best way to do that and the steps should tell one by one what is is doing any why. I am only looking for text steps for now

Thought for 4s
Power Query transformation plan
Goal
Transform the original Excel file into the same structure as the final cleaned file:

Output Field
ReportDate
Period Start
Period End
Product/Line Name
Product/Line ID
Volume Forecast
Volume Produced
Part Id
Part Description
Step-by-step Power Query logic
1. Connect to the original Excel file
Load the source Excel sheet that contains the production volume data.

Why:
This is the raw file that will be transformed into the OneSchema format.

2. Keep the raw structure first
Do not promote headers immediately.

Why:
The Excel file has meaningful information in the top rows, including the month headers. Promoting headers too early could lose or misalign those values.

3. Identify the month columns
Detect the columns that represent months, such as:

Januar 25

Februar 25

März 25

April 25

…

März 26

Why:
These columns need to become rows in the final output.

4. Ignore ACT / Q3FC / forecast labels
Do not use the ACT, Q3FC, or similar row labels to decide which columns to keep.

Why:
The July 2025 issue showed that those labels are not reliable. The safer pattern is to use valid month sequence logic.

5. Validate the month sequence
Keep only month columns that follow the expected chronological order:

Jan 2025 → Feb 2025 → Mar 2025 → ... → Mar 2026
Ignore bad or out-of-order month columns such as:

Juli 05
Why:
This avoids including typo columns or totals that look like months but are not part of the valid timeline.

6. Convert month headers into real dates
For each valid month column:

Januar 25 becomes 01/01/2025

Juli 25 becomes 07/01/2025

März 26 becomes 03/01/2026

Why:
OneSchema requires date fields, not German month text.

7. Create Period Start
Use the first day of the detected month.

Example:

Juli 25 → 07/01/2025
Why:
This maps to the OneSchema period_start field.

8. Create Period End
Calculate the last day of the same month.

Example:

Juli 25 → 07/31/2025
Why:
This maps to the OneSchema period_end field.

9. Fill down Program
Use the Program value and fill it down to the related part rows.

Example:

PO416
VW275
Why:
In the source file, the program appears as a group header, but the output needs it on every detail row.

10. Filter detail part rows
Keep rows where the source row has a valid:

Part Number

Description

Why:
These are the actual production detail rows.

11. Unpivot the month columns
Turn the valid month columns into rows.

Example source layout:

Part Number	Description	Januar 25	Februar 25
95B885501A	ASW BACKREST LH	2448	2448
Becomes:

Part Number	Description	Month	Volume Produced
95B885501A	ASW BACKREST LH	Januar 25	2448
95B885501A	ASW BACKREST LH	Februar 25	2448
Why:
OneSchema expects one row per product/line/part/month.

12. Map columns to OneSchema format
Create the final output columns:

OneSchema Field	Source / Logic
ReportDate	Blank
Period Start	First day of month
Period End	Last day of month
Product/Line Name	Program
Product/Line ID	Blank
Volume Forecast	Blank
Volume Produced	Monthly value
Part Id	Part Number
Part Description	Description
13. Add Total complete vehicle rows
Create a separate query or branch for source line 68 only.

For each valid month:

Field	Logic
Product/Line Name	Total complete vehicle
Volume Produced	Value from line 68
Period Start	Same month logic
Period End	Same month logic
Everything else	Blank
Why:
This row is not a part-level detail row, but it must still be imported as a production volume line.

14. Exclude Total complete vehicle from line 89
Do not include the second Total complete vehicle row.

Why:
Only line 68 is valid for this output.

15. Append detail rows and vehicle total rows
Append:

Part-level production rows
+
Total complete vehicle rows from line 68
Why:
The final output needs both normal detail production rows and the total complete vehicle rows.

16. Remove blank or invalid volume rows
Remove rows where Volume Produced is blank or null.

Why:
The import should only include actual production values.

17. Set final data types
Set the output data types:

Field	Type
ReportDate	Date or Text blank
Period Start	Date
Period End	Date
Product/Line Name	Text
Product/Line ID	Text blank
Volume Forecast	Number or blank
Volume Produced	Number
Part Id	Text
Part Description	Text
18. Reorder columns to match OneSchema
Final order should be:

ReportDate
Period Start
Period End
Product/Line Name
Product/Line ID
Volume Forecast
Volume Produced
Part Id
Part Description
Why:
This keeps the output aligned with the OneSchema template.


my other question is, can we find out all these data dinamically? for example, in this scenario, Total complete vehicle is in line 68, but it could be in different lines depending on how many Program and part numbers we have 

Yes — we should make it dynamic. Relying on “line 68” is too fragile.

Better dynamic pattern
1. Identify Program group rows dynamically
A Program row is likely a row where:

Program has a value

Part Number is blank

Description is blank or not a real part description

Then Power Query fills Program down to the part rows.

2. Identify part detail rows dynamically
A part row is likely a row where:

Part Number is not blank

Description is not blank

Monthly values exist

These become the normal OneSchema rows.

3. Identify “Total complete vehicle” dynamically
Instead of row number, search for the text:

Total complete vehicle
Then keep the first occurrence only.

That handles the case where it moves from line 68 to another line.

4. Exclude duplicate Total complete vehicle rows
If the source has more than one match:

Total complete vehicle
Power Query should:

Sort by original row order

Keep the first one

Ignore the rest

5. Identify valid month columns dynamically
Do not depend on fixed column letters like G, H, etc.

Instead:

Read the month header row

Convert German month names + year into dates

Keep only columns that form a valid chronological sequence

Ignore bad/out-of-order columns like Juli 05

Recommended dynamic rules
Source Pattern	Dynamic Rule
Program rows	Detect where Program exists and Part Number is blank
Part rows	Detect where Part Number + Description exist
Month columns	Detect valid German month + year sequence
Bad month typo	Ignore if outside expected sequence
Total complete vehicle	Find by text, keep first occurrence
ACT/Q3FC	Ignore completely
Answer
Yes, we can make the Power Query dynamic enough so it does not care what line “Total complete vehicle” is on. It should find the first valid occurrence by text and transform it separately.


this is the source I will be using in power query:
Source = Excel.Workbook(
        File.Contents("C:\\Development\\fabric-local-dev\\data\\Actuals-March-2026.xlsx"), 
        null, 
        true
    ),
Please give me the power query script with a good header explaining what we are doing and make sure to put comments everywhere in the code so it helps me and you understand it later

Thought for 16s
Below is a Power Query M script using your source exactly as provided.

/**************************************************************************************
Purpose:
    Transform the original Pilzen Production Volume Excel file into the OneSchema import
    format for production volume data.

What this query does:
    1. Reads the "Production Volumes" sheet from the Excel file.
    2. Detects valid monthly columns dynamically using the actual Excel date headers.
    3. Ignores ACT / Q3FC / BP / quarter labels because those labels are not reliable.
    4. Keeps only valid month columns in chronological order.
    5. Excludes invalid/out-of-order date columns such as the bad "Juli 05" column.
    6. Fills down Program values so each part row has a Product/Line Name.
    7. Converts part-level monthly volumes into OneSchema format.
    8. Dynamically finds the first "Total complete vehicle" row and adds it separately.
    9. Ignores duplicate/later "Total complete vehicle" rows.
    10. Outputs the final OneSchema-ready columns.

Important:
    - This script does NOT depend on fixed Excel line numbers.
    - This script does NOT depend on ACT / Q3FC labels.
    - The first valid "Total complete vehicle" row is included dynamically.
**************************************************************************************/

let
    // ==================================================================================
    // 1. Connect to the Excel workbook
    // ==================================================================================
    Source = Excel.Workbook(
        File.Contents("C:\Development\fabric-local-dev\data\Actuals-March-2026.xlsx"), 
        null, 
        true
    ),

    // ==================================================================================
    // 2. Select the source sheet
    // ==================================================================================
    ProductionVolumesSheet =
        Source{[Item = "Production Volumes", Kind = "Sheet"]}[Data],

    // ==================================================================================
    // 3. Add an original row number so we can preserve source order
    // ==================================================================================
    AddSourceRowNumber =
        Table.AddIndexColumn(
            ProductionVolumesSheet,
            "SourceRowNumber",
            1,
            1,
            Int64.Type
        ),

    // ==================================================================================
    // 4. Get the header row that contains Program, Part Number, Description, and months
    //    In this file, that is source row 5.
    // ==================================================================================
    HeaderRow =
        AddSourceRowNumber{4},

    // ==================================================================================
    // 5. Get all column names from the raw imported Excel table
    // ==================================================================================
    RawColumnNames =
        Table.ColumnNames(AddSourceRowNumber),

    // ==================================================================================
    // 6. Identify valid month columns dynamically
    //    A valid month column is a column where the header row value is an actual date.
    //    This captures Jan 2025, Feb 2025, etc.
    // ==================================================================================
    MonthColumnCandidates =
        List.Select(
            RawColumnNames,
            each
                let
                    HeaderValue = Record.Field(HeaderRow, _)
                in
                    Value.Is(HeaderValue, type date)
                    or Value.Is(HeaderValue, type datetime)
        ),

    // ==================================================================================
    // 7. Create a small month metadata table
    //    This lets us sort month columns by the real date from the header row.
    // ==================================================================================
    MonthMetadataRaw =
        Table.FromRecords(
            List.Transform(
                MonthColumnCandidates,
                each
                    [
                        MonthColumnName = _,
                        MonthStartDate = Date.From(Record.Field(HeaderRow, _))
                    ]
            )
        ),

    // ==================================================================================
    // 8. Remove bad year/date typo columns
    //    Example: the source contains a bad 1905 date that should not be imported.
    //    We only keep realistic production months from 2025 onward.
    // ==================================================================================
    MonthMetadataFiltered =
        Table.SelectRows(
            MonthMetadataRaw,
            each [MonthStartDate] >= #date(2025, 1, 1)
        ),

    // ==================================================================================
    // 9. Sort month columns chronologically
    // ==================================================================================
    MonthMetadataSorted =
        Table.Sort(
            MonthMetadataFiltered,
            {{"MonthStartDate", Order.Ascending}}
        ),

    // ==================================================================================
    // 10. Keep only the month columns that follow the expected chronological order
    //     This avoids bad/out-of-order month columns.
    // ==================================================================================
    ValidMonthColumnNames =
        MonthMetadataSorted[MonthColumnName],

    // ==================================================================================
    // 11. Remove the top rows before the real data starts
    //     Source row 5 is the header row, so real data starts after that.
    // ==================================================================================
    DataRowsOnly =
        Table.SelectRows(
            AddSourceRowNumber,
            each [SourceRowNumber] > 5
        ),

    // ==================================================================================
    // 12. Rename the known descriptive columns
    //     Column2 = Program
    //     Column3 = Part Number
    //     Column6 = Description
    // ==================================================================================
    RenameBaseColumns =
        Table.RenameColumns(
            DataRowsOnly,
            {
                {"Column2", "Program"},
                {"Column3", "Part Number"},
                {"Column6", "Description"}
            },
            MissingField.Ignore
        ),

    // ==================================================================================
    // 13. Fill down Program
    //     Program appears once at the group level, then blank on detail rows.
    // ==================================================================================
    FillDownProgram =
        Table.FillDown(
            RenameBaseColumns,
            {"Program"}
        ),

    // ==================================================================================
    // 14. Keep only part detail rows
    //     A part detail row must have a Part Number and Description.
    // ==================================================================================
    PartDetailRows =
        Table.SelectRows(
            FillDownProgram,
            each
                [Part Number] <> null
                and Text.Trim(Text.From([Part Number])) <> ""
                and [Description] <> null
                and Text.Trim(Text.From([Description])) <> ""
        ),

    // ==================================================================================
    // 15. Keep only the columns needed for part-level unpivot
    // ==================================================================================
    PartRowsSelectedColumns =
        Table.SelectColumns(
            PartDetailRows,
            List.Combine(
                {
                    {"Program", "Part Number", "Description"},
                    ValidMonthColumnNames
                }
            ),
            MissingField.Ignore
        ),

    // ==================================================================================
    // 16. Unpivot the valid month columns
    //     This converts one row per part with many month columns into:
    //     one row per part per month.
    // ==================================================================================
    PartRowsUnpivoted =
        Table.Unpivot(
            PartRowsSelectedColumns,
            ValidMonthColumnNames,
            "MonthColumnName",
            "Volume Produced"
        ),

    // ==================================================================================
    // 17. Join back to month metadata so each month column gets its real Period Start date
    // ==================================================================================
    PartRowsWithMonthDate =
        Table.NestedJoin(
            PartRowsUnpivoted,
            {"MonthColumnName"},
            MonthMetadataSorted,
            {"MonthColumnName"},
            "MonthInfo",
            JoinKind.LeftOuter
        ),

    // ==================================================================================
    // 18. Expand the month date
    // ==================================================================================
    PartRowsExpandMonthDate =
        Table.ExpandTableColumn(
            PartRowsWithMonthDate,
            "MonthInfo",
            {"MonthStartDate"},
            {"Period Start"}
        ),

    // ==================================================================================
    // 19. Add Period End as the last day of the same month
    // ==================================================================================
    PartRowsAddPeriodEnd =
        Table.AddColumn(
            PartRowsExpandMonthDate,
            "Period End",
            each Date.EndOfMonth([Period Start]),
            type date
        ),

    // ==================================================================================
    // 20. Add blank OneSchema fields for part-level rows
    // ==================================================================================
    PartRowsAddReportDate =
        Table.AddColumn(
            PartRowsAddPeriodEnd,
            "ReportDate",
            each null,
            type nullable date
        ),

    PartRowsAddProductLineId =
        Table.AddColumn(
            PartRowsAddReportDate,
            "Product/Line ID",
            each null,
            type nullable text
        ),

    PartRowsAddVolumeForecast =
        Table.AddColumn(
            PartRowsAddProductLineId,
            "Volume Forecast",
            each null,
            type nullable number
        ),

    // ==================================================================================
    // 21. Rename part-level fields to OneSchema names
    // ==================================================================================
    PartRowsRenameFinalFields =
        Table.RenameColumns(
            PartRowsAddVolumeForecast,
            {
                {"Program", "Product/Line Name"},
                {"Part Number", "Part Id"},
                {"Description", "Part Description"}
            },
            MissingField.Ignore
        ),

    // ==================================================================================
    // 22. Select final part-level output columns
    // ==================================================================================
    PartRowsFinal =
        Table.SelectColumns(
            PartRowsRenameFinalFields,
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
            }
        ),

    // ==================================================================================
    // 23. Dynamically find Total complete vehicle rows
    //     We search across the row values instead of depending on a fixed line number.
    // ==================================================================================
    TotalCompleteVehicleRows =
        Table.SelectRows(
            AddSourceRowNumber,
            each
                List.Contains(
                    List.Transform(
                        Record.FieldValues(_),
                        each Text.Lower(Text.Trim(Text.From(_)))
                    ),
                    "total complete vehicle"
                )
        ),

    // ==================================================================================
    // 24. Keep only the first Total complete vehicle row
    //     This avoids including the duplicate/later one.
    // ==================================================================================
    FirstTotalCompleteVehicleRow =
        Table.FirstN(
            Table.Sort(
                TotalCompleteVehicleRows,
                {{"SourceRowNumber", Order.Ascending}}
            ),
            1
        ),

    // ==================================================================================
    // 25. Keep only the valid month columns from that Total complete vehicle row
    // ==================================================================================
    TotalVehicleSelectedColumns =
        Table.SelectColumns(
            FirstTotalCompleteVehicleRow,
            ValidMonthColumnNames,
            MissingField.Ignore
        ),

    // ==================================================================================
    // 26. Unpivot Total complete vehicle monthly values
    // ==================================================================================
    TotalVehicleUnpivoted =
        Table.Unpivot(
            TotalVehicleSelectedColumns,
            ValidMonthColumnNames,
            "MonthColumnName",
            "Volume Produced"
        ),

    // ==================================================================================
    // 27. Join Total complete vehicle rows back to month metadata
    // ==================================================================================
    TotalVehicleWithMonthDate =
        Table.NestedJoin(
            TotalVehicleUnpivoted,
            {"MonthColumnName"},
            MonthMetadataSorted,
            {"MonthColumnName"},
            "MonthInfo",
            JoinKind.LeftOuter
        ),

    // ==================================================================================
    // 28. Expand Period Start for Total complete vehicle
    // ==================================================================================
    TotalVehicleExpandMonthDate =
        Table.ExpandTableColumn(
            TotalVehicleWithMonthDate,
            "MonthInfo",
            {"MonthStartDate"},
            {"Period Start"}
        ),

    // ==================================================================================
    // 29. Add Period End for Total complete vehicle
    // ==================================================================================
    TotalVehicleAddPeriodEnd =
        Table.AddColumn(
            TotalVehicleExpandMonthDate,
            "Period End",
            each Date.EndOfMonth([Period Start]),
            type date
        ),

    // ==================================================================================
    // 30. Add OneSchema fields for Total complete vehicle
    // ==================================================================================
    TotalVehicleAddReportDate =
        Table.AddColumn(
            TotalVehicleAddPeriodEnd,
            "ReportDate",
            each null,
            type nullable date
        ),

    TotalVehicleAddProductLineName =
        Table.AddColumn(
            TotalVehicleAddReportDate,
            "Product/Line Name",
            each "Total complete vehicle",
            type text
        ),

    TotalVehicleAddProductLineId =
        Table.AddColumn(
            TotalVehicleAddProductLineName,
            "Product/Line ID",
            each null,
            type nullable text
        ),

    TotalVehicleAddVolumeForecast =
        Table.AddColumn(
            TotalVehicleAddProductLineId,
            "Volume Forecast",
            each null,
            type nullable number
        ),

    TotalVehicleAddPartId =
        Table.AddColumn(
            TotalVehicleAddVolumeForecast,
            "Part Id",
            each null,
            type nullable text
        ),

    TotalVehicleAddPartDescription =
        Table.AddColumn(
            TotalVehicleAddPartId,
            "Part Description",
            each null,
            type nullable text
        ),

    // ==================================================================================
    // 31. Select final Total complete vehicle output columns
    // ==================================================================================
    TotalVehicleFinal =
        Table.SelectColumns(
            TotalVehicleAddPartDescription,
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
            }
        ),

    // ==================================================================================
    // 32. Append part-level rows and Total complete vehicle rows
    // ==================================================================================
    CombinedFinalRows =
        Table.Combine(
            {
                PartRowsFinal,
                TotalVehicleFinal
            }
        ),

    // ==================================================================================
    // 33. Remove rows where Volume Produced is blank
    // ==================================================================================
    RemoveBlankVolumes =
        Table.SelectRows(
            CombinedFinalRows,
            each [Volume Produced] <> null
        ),

    // ==================================================================================
    // 34. Set final data types
    // ==================================================================================
    FinalTyped =
        Table.TransformColumnTypes(
            RemoveBlankVolumes,
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

    // ==================================================================================
    // 35. Final column order for OneSchema
    // ==================================================================================
    FinalOutput =
        Table.ReorderColumns(
            FinalTyped,
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
            }
        )

in
    FinalOutput
This version is dynamic for:

month columns,

product/program fill-down,

part rows,

and first Total complete vehicle row.



Thought for 9s
Yes — that error is coming from a Table.Sort() step.

Most likely fix: replace the Table.Sort() syntax with this safer Power Query format.

Replace this step
MonthMetadataSorted =
    Table.Sort(
        MonthMetadataFiltered,
        {{"MonthStartDate", Order.Ascending}}
    ),
With this
MonthMetadataSorted =
    Table.Sort(
        MonthMetadataFiltered,
        {"MonthStartDate"}
    ),
Also replace this one:

FirstTotalCompleteVehicleRow =
    Table.FirstN(
        Table.Sort(
            TotalCompleteVehicleRows,
            {{"SourceRowNumber", Order.Ascending}}
        ),
        1
    ),
With this
FirstTotalCompleteVehicleRow =
    Table.FirstN(
        Table.Sort(
            TotalCompleteVehicleRows,
            {"SourceRowNumber"}
        ),
        1
    ),
Power Query sometimes accepts both formats, but depending on the environment, the simpler sort list is safer.

After that, refresh again.


give me whole script again

Thought for a few seconds
Here is the full script again with the safer Table.Sort() format.

/**************************************************************************************
Purpose:
    Transform the original Pilzen Production Volume Excel file into the OneSchema import
    format for production volume data.

What this query does:
    1. Reads the "Production Volumes" sheet from the Excel file.
    2. Detects valid monthly columns dynamically using the Excel date headers.
    3. Ignores ACT / Q3FC / BP / quarter labels because those labels are not reliable.
    4. Keeps only realistic month columns from 2025 onward.
    5. Excludes invalid typo columns such as the bad "Juli 05" column.
    6. Fills down Program values so each part row has a Product/Line Name.
    7. Converts part-level monthly volumes into OneSchema format.
    8. Dynamically finds the first "Total complete vehicle" row and adds it separately.
    9. Ignores duplicate/later "Total complete vehicle" rows.
    10. Outputs the final OneSchema-ready columns.

Important:
    - This script does NOT depend on fixed Excel row numbers for detail rows.
    - This script does NOT depend on ACT / Q3FC labels.
    - The first valid "Total complete vehicle" row is included dynamically.
**************************************************************************************/

let
    Source = Excel.Workbook(
        File.Contents("C:\Development\fabric-local-dev\data\Actuals-March-2026.xlsx"), 
        null, 
        true
    ),

    ProductionVolumesSheet =
        Source{[Item = "Production Volumes", Kind = "Sheet"]}[Data],

    AddSourceRowNumber =
        Table.AddIndexColumn(
            ProductionVolumesSheet,
            "SourceRowNumber",
            1,
            1,
            Int64.Type
        ),

    HeaderRow =
        AddSourceRowNumber{4},

    RawColumnNames =
        Table.ColumnNames(AddSourceRowNumber),

    MonthColumnCandidates =
        List.Select(
            RawColumnNames,
            each
                let
                    HeaderValue = Record.Field(HeaderRow, _)
                in
                    Value.Is(HeaderValue, type date)
                    or Value.Is(HeaderValue, type datetime)
        ),

    MonthMetadataRaw =
        Table.FromRecords(
            List.Transform(
                MonthColumnCandidates,
                each
                    [
                        MonthColumnName = _,
                        MonthStartDate = Date.From(Record.Field(HeaderRow, _))
                    ]
            )
        ),

    MonthMetadataFiltered =
        Table.SelectRows(
            MonthMetadataRaw,
            each [MonthStartDate] >= #date(2025, 1, 1)
        ),

    MonthMetadataSorted =
        Table.Sort(
            MonthMetadataFiltered,
            {"MonthStartDate"}
        ),

    ValidMonthColumnNames =
        MonthMetadataSorted[MonthColumnName],

    DataRowsOnly =
        Table.SelectRows(
            AddSourceRowNumber,
            each [SourceRowNumber] > 5
        ),

    RenameBaseColumns =
        Table.RenameColumns(
            DataRowsOnly,
            {
                {"Column2", "Program"},
                {"Column3", "Part Number"},
                {"Column6", "Description"}
            },
            MissingField.Ignore
        ),

    FillDownProgram =
        Table.FillDown(
            RenameBaseColumns,
            {"Program"}
        ),

    PartDetailRows =
        Table.SelectRows(
            FillDownProgram,
            each
                [Part Number] <> null
                and Text.Trim(Text.From([Part Number])) <> ""
                and [Description] <> null
                and Text.Trim(Text.From([Description])) <> ""
        ),

    PartRowsSelectedColumns =
        Table.SelectColumns(
            PartDetailRows,
            List.Combine(
                {
                    {"Program", "Part Number", "Description"},
                    ValidMonthColumnNames
                }
            ),
            MissingField.Ignore
        ),

    PartRowsUnpivoted =
        Table.Unpivot(
            PartRowsSelectedColumns,
            ValidMonthColumnNames,
            "MonthColumnName",
            "Volume Produced"
        ),

    PartRowsWithMonthDate =
        Table.NestedJoin(
            PartRowsUnpivoted,
            {"MonthColumnName"},
            MonthMetadataSorted,
            {"MonthColumnName"},
            "MonthInfo",
            JoinKind.LeftOuter
        ),

    PartRowsExpandMonthDate =
        Table.ExpandTableColumn(
            PartRowsWithMonthDate,
            "MonthInfo",
            {"MonthStartDate"},
            {"Period Start"}
        ),

    PartRowsAddPeriodEnd =
        Table.AddColumn(
            PartRowsExpandMonthDate,
            "Period End",
            each Date.EndOfMonth([Period Start]),
            type date
        ),

    PartRowsAddReportDate =
        Table.AddColumn(
            PartRowsAddPeriodEnd,
            "ReportDate",
            each null,
            type nullable date
        ),

    PartRowsAddProductLineId =
        Table.AddColumn(
            PartRowsAddReportDate,
            "Product/Line ID",
            each null,
            type nullable text
        ),

    PartRowsAddVolumeForecast =
        Table.AddColumn(
            PartRowsAddProductLineId,
            "Volume Forecast",
            each null,
            type nullable number
        ),

    PartRowsRenameFinalFields =
        Table.RenameColumns(
            PartRowsAddVolumeForecast,
            {
                {"Program", "Product/Line Name"},
                {"Part Number", "Part Id"},
                {"Description", "Part Description"}
            },
            MissingField.Ignore
        ),

    PartRowsFinal =
        Table.SelectColumns(
            PartRowsRenameFinalFields,
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
            }
        ),

    TotalCompleteVehicleRows =
        Table.SelectRows(
            AddSourceRowNumber,
            each
                List.Contains(
                    List.Transform(
                        Record.FieldValues(_),
                        each Text.Lower(Text.Trim(Text.From(_)))
                    ),
                    "total complete vehicle"
                )
        ),

    FirstTotalCompleteVehicleRow =
        Table.FirstN(
            Table.Sort(
                TotalCompleteVehicleRows,
                {"SourceRowNumber"}
            ),
            1
        ),

    TotalVehicleSelectedColumns =
        Table.SelectColumns(
            FirstTotalCompleteVehicleRow,
            ValidMonthColumnNames,
            MissingField.Ignore
        ),

    TotalVehicleUnpivoted =
        Table.Unpivot(
            TotalVehicleSelectedColumns,
            ValidMonthColumnNames,
            "MonthColumnName",
            "Volume Produced"
        ),

    TotalVehicleWithMonthDate =
        Table.NestedJoin(
            TotalVehicleUnpivoted,
            {"MonthColumnName"},
            MonthMetadataSorted,
            {"MonthColumnName"},
            "MonthInfo",
            JoinKind.LeftOuter
        ),

    TotalVehicleExpandMonthDate =
        Table.ExpandTableColumn(
            TotalVehicleWithMonthDate,
            "MonthInfo",
            {"MonthStartDate"},
            {"Period Start"}
        ),

    TotalVehicleAddPeriodEnd =
        Table.AddColumn(
            TotalVehicleExpandMonthDate,
            "Period End",
            each Date.EndOfMonth([Period Start]),
            type date
        ),

    TotalVehicleAddReportDate =
        Table.AddColumn(
            TotalVehicleAddPeriodEnd,
            "ReportDate",
            each null,
            type nullable date
        ),

    TotalVehicleAddProductLineName =
        Table.AddColumn(
            TotalVehicleAddReportDate,
            "Product/Line Name",
            each "Total complete vehicle",
            type text
        ),

    TotalVehicleAddProductLineId =
        Table.AddColumn(
            TotalVehicleAddProductLineName,
            "Product/Line ID",
            each null,
            type nullable text
        ),

    TotalVehicleAddVolumeForecast =
        Table.AddColumn(
            TotalVehicleAddProductLineId,
            "Volume Forecast",
            each null,
            type nullable number
        ),

    TotalVehicleAddPartId =
        Table.AddColumn(
            TotalVehicleAddVolumeForecast,
            "Part Id",
            each null,
            type nullable text
        ),

    TotalVehicleAddPartDescription =
        Table.AddColumn(
            TotalVehicleAddPartId,
            "Part Description",
            each null,
            type nullable text
        ),

    TotalVehicleFinal =
        Table.SelectColumns(
            TotalVehicleAddPartDescription,
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
            }
        ),

    CombinedFinalRows =
        Table.Combine(
            {
                PartRowsFinal,
                TotalVehicleFinal
            }
        ),

    RemoveBlankVolumes =
        Table.SelectRows(
            CombinedFinalRows,
            each [Volume Produced] <> null
        ),

    FinalTyped =
        Table.TransformColumnTypes(
            RemoveBlankVolumes,
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

    FinalOutput =
        Table.ReorderColumns(
            FinalTyped,
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
            }
        )

in
    FinalOutput


Thought for a few seconds
You are right — my “safer” change was wrong for your Power Query version.

Use the original sort format:

MonthMetadataSorted =
    Table.Sort(
        MonthMetadataFiltered,
        {{"MonthStartDate", Order.Ascending}}
    ),
And later use:

FirstTotalCompleteVehicleRow =
    Table.FirstN(
        Table.Sort(
            TotalCompleteVehicleRows,
            {{"SourceRowNumber", Order.Ascending}}
        ),
        1
    ),
So the issue is only the sort syntax. Replace both Table.Sort(..., {"ColumnName"}) steps with the nested-list format:

{{"ColumnName", Order.Ascending}}

please send full script

Thought for a couple of seconds
Here is the full script again with the correct Table.Sort format:

/**************************************************************************************
Purpose:
    Transform the original Pilzen Production Volume Excel file into the OneSchema import
    format for production volume data.

What this query does:
    1. Reads the "Production Volumes" sheet from the Excel file.
    2. Detects valid monthly columns dynamically using the Excel date headers.
    3. Ignores ACT / Q3FC / BP / quarter labels because those labels are not reliable.
    4. Keeps only realistic month columns from 2025 onward.
    5. Excludes invalid typo columns such as the bad "Juli 05" column.
    6. Fills down Program values so each part row has a Product/Line Name.
    7. Converts part-level monthly volumes into OneSchema format.
    8. Dynamically finds the first "Total complete vehicle" row and adds it separately.
    9. Ignores duplicate/later "Total complete vehicle" rows.
    10. Outputs the final OneSchema-ready columns.

Important:
    - This script does NOT depend on fixed Excel row numbers for detail rows.
    - This script does NOT depend on ACT / Q3FC labels.
    - The first valid "Total complete vehicle" row is included dynamically.
**************************************************************************************/

let
    // 1. Connect to Excel workbook.
    Source = Excel.Workbook(
        File.Contents("C:\Development\fabric-local-dev\data\Actuals-March-2026.xlsx"), 
        null, 
        true
    ),

    // 2. Navigate to the source sheet.
    ProductionVolumesSheet =
        Source{[Item = "Production Volumes", Kind = "Sheet"]}[Data],

    // 3. Add source row number so we can preserve original row order.
    AddSourceRowNumber =
        Table.AddIndexColumn(
            ProductionVolumesSheet,
            "SourceRowNumber",
            1,
            1,
            Int64.Type
        ),

    // 4. Header row with Program, Part Number, Description, and month dates.
    HeaderRow =
        AddSourceRowNumber{4},

    // 5. Get all raw column names.
    RawColumnNames =
        Table.ColumnNames(AddSourceRowNumber),

    // 6. Identify columns where the header row contains a real Excel date.
    MonthColumnCandidates =
        List.Select(
            RawColumnNames,
            each
                let
                    HeaderValue = Record.Field(HeaderRow, _)
                in
                    Value.Is(HeaderValue, type date)
                    or Value.Is(HeaderValue, type datetime)
        ),

    // 7. Build month metadata table: raw column name + real month start date.
    MonthMetadataRaw =
        Table.FromRecords(
            List.Transform(
                MonthColumnCandidates,
                each
                    [
                        MonthColumnName = _,
                        MonthStartDate = Date.From(Record.Field(HeaderRow, _))
                    ]
            )
        ),

    // 8. Remove invalid typo date columns, such as the bad 1905 date.
    MonthMetadataFiltered =
        Table.SelectRows(
            MonthMetadataRaw,
            each [MonthStartDate] >= #date(2025, 1, 1)
        ),

    // 9. Sort month columns chronologically.
    MonthMetadataSorted =
        Table.Sort(
            MonthMetadataFiltered,
            {{"MonthStartDate", Order.Ascending}}
        ),

    // 10. Extract the valid month column names.
    ValidMonthColumnNames =
        MonthMetadataSorted[MonthColumnName],

    // 11. Keep only data rows after the header area.
    DataRowsOnly =
        Table.SelectRows(
            AddSourceRowNumber,
            each [SourceRowNumber] > 5
        ),

    // 12. Rename key source columns.
    RenameBaseColumns =
        Table.RenameColumns(
            DataRowsOnly,
            {
                {"Column2", "Program"},
                {"Column3", "Part Number"},
                {"Column6", "Description"}
            },
            MissingField.Ignore
        ),

    // 13. Fill down Program so detail rows inherit the correct Program.
    FillDownProgram =
        Table.FillDown(
            RenameBaseColumns,
            {"Program"}
        ),

    // 14. Keep only real part detail rows.
    PartDetailRows =
        Table.SelectRows(
            FillDownProgram,
            each
                [Part Number] <> null
                and Text.Trim(Text.From([Part Number])) <> ""
                and [Description] <> null
                and Text.Trim(Text.From([Description])) <> ""
        ),

    // 15. Keep only fields needed for part-level transformation.
    PartRowsSelectedColumns =
        Table.SelectColumns(
            PartDetailRows,
            List.Combine(
                {
                    {"Program", "Part Number", "Description"},
                    ValidMonthColumnNames
                }
            ),
            MissingField.Ignore
        ),

    // 16. Unpivot month columns into one row per part per month.
    PartRowsUnpivoted =
        Table.Unpivot(
            PartRowsSelectedColumns,
            ValidMonthColumnNames,
            "MonthColumnName",
            "Volume Produced"
        ),

    // 17. Join month metadata so each unpivoted row gets Period Start.
    PartRowsWithMonthDate =
        Table.NestedJoin(
            PartRowsUnpivoted,
            {"MonthColumnName"},
            MonthMetadataSorted,
            {"MonthColumnName"},
            "MonthInfo",
            JoinKind.LeftOuter
        ),

    // 18. Expand Period Start.
    PartRowsExpandMonthDate =
        Table.ExpandTableColumn(
            PartRowsWithMonthDate,
            "MonthInfo",
            {"MonthStartDate"},
            {"Period Start"}
        ),

    // 19. Add Period End.
    PartRowsAddPeriodEnd =
        Table.AddColumn(
            PartRowsExpandMonthDate,
            "Period End",
            each Date.EndOfMonth([Period Start]),
            type date
        ),

    // 20. Add blank OneSchema fields.
    PartRowsAddReportDate =
        Table.AddColumn(
            PartRowsAddPeriodEnd,
            "ReportDate",
            each null,
            type nullable date
        ),

    PartRowsAddProductLineId =
        Table.AddColumn(
            PartRowsAddReportDate,
            "Product/Line ID",
            each null,
            type nullable text
        ),

    PartRowsAddVolumeForecast =
        Table.AddColumn(
            PartRowsAddProductLineId,
            "Volume Forecast",
            each null,
            type nullable number
        ),

    // 21. Rename part-level fields to OneSchema names.
    PartRowsRenameFinalFields =
        Table.RenameColumns(
            PartRowsAddVolumeForecast,
            {
                {"Program", "Product/Line Name"},
                {"Part Number", "Part Id"},
                {"Description", "Part Description"}
            },
            MissingField.Ignore
        ),

    // 22. Select final part-level OneSchema columns.
    PartRowsFinal =
        Table.SelectColumns(
            PartRowsRenameFinalFields,
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
            }
        ),

    // 23. Dynamically find rows containing "Total complete vehicle".
    TotalCompleteVehicleRows =
        Table.SelectRows(
            AddSourceRowNumber,
            each
                List.Contains(
                    List.Transform(
                        Record.FieldValues(_),
                        each Text.Lower(Text.Trim(Text.From(_)))
                    ),
                    "total complete vehicle"
                )
        ),

    // 24. Keep only the first occurrence.
    FirstTotalCompleteVehicleRow =
        Table.FirstN(
            Table.Sort(
                TotalCompleteVehicleRows,
                {{"SourceRowNumber", Order.Ascending}}
            ),
            1
        ),

    // 25. Keep only month columns from the Total complete vehicle row.
    TotalVehicleSelectedColumns =
        Table.SelectColumns(
            FirstTotalCompleteVehicleRow,
            ValidMonthColumnNames,
            MissingField.Ignore
        ),

    // 26. Unpivot Total complete vehicle months.
    TotalVehicleUnpivoted =
        Table.Unpivot(
            TotalVehicleSelectedColumns,
            ValidMonthColumnNames,
            "MonthColumnName",
            "Volume Produced"
        ),

    // 27. Join month metadata to Total complete vehicle rows.
    TotalVehicleWithMonthDate =
        Table.NestedJoin(
            TotalVehicleUnpivoted,
            {"MonthColumnName"},
            MonthMetadataSorted,
            {"MonthColumnName"},
            "MonthInfo",
            JoinKind.LeftOuter
        ),

    // 28. Expand Period Start.
    TotalVehicleExpandMonthDate =
        Table.ExpandTableColumn(
            TotalVehicleWithMonthDate,
            "MonthInfo",
            {"MonthStartDate"},
            {"Period Start"}
        ),

    // 29. Add Period End.
    TotalVehicleAddPeriodEnd =
        Table.AddColumn(
            TotalVehicleExpandMonthDate,
            "Period End",
            each Date.EndOfMonth([Period Start]),
            type date
        ),

    // 30. Add OneSchema fields for Total complete vehicle.
    TotalVehicleAddReportDate =
        Table.AddColumn(
            TotalVehicleAddPeriodEnd,
            "ReportDate",
            each null,
            type nullable date
        ),

    TotalVehicleAddProductLineName =
        Table.AddColumn(
            TotalVehicleAddReportDate,
            "Product/Line Name",
            each "Total complete vehicle",
            type text
        ),

    TotalVehicleAddProductLineId =
        Table.AddColumn(
            TotalVehicleAddProductLineName,
            "Product/Line ID",
            each null,
            type nullable text
        ),

    TotalVehicleAddVolumeForecast =
        Table.AddColumn(
            TotalVehicleAddProductLineId,
            "Volume Forecast",
            each null,
            type nullable number
        ),

    TotalVehicleAddPartId =
        Table.AddColumn(
            TotalVehicleAddVolumeForecast,
            "Part Id",
            each null,
            type nullable text
        ),

    TotalVehicleAddPartDescription =
        Table.AddColumn(
            TotalVehicleAddPartId,
            "Part Description",
            each null,
            type nullable text
        ),

    // 31. Select final Total complete vehicle OneSchema columns.
    TotalVehicleFinal =
        Table.SelectColumns(
            TotalVehicleAddPartDescription,
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
            }
        ),

    // 32. Append part rows and Total complete vehicle rows.
    CombinedFinalRows =
        Table.Combine(
            {
                PartRowsFinal,
                TotalVehicleFinal
            }
        ),

    // 33. Remove rows with blank volume.
    RemoveBlankVolumes =
        Table.SelectRows(
            CombinedFinalRows,
            each [Volume Produced] <> null
        ),

    // 34. Set final data types.
    FinalTyped =
        Table.TransformColumnTypes(
            RemoveBlankVolumes,
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

    // 35. Reorder columns to match OneSchema template.
    FinalOutput =
        Table.ReorderColumns(
            FinalTyped,
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
            }
        )

in
    FinalOutput


Pasted text.txt
Document
lets do this, check to see if this one will do what I need: 

Thought for 5s
Yes — this script is very close, but I would not use it as-is. 


Main issues I see
1. It may include the bad Juli 05 column
The script keeps any date column where:

Date.Year(...) >= 2025
That removes old dates, but it does not fully validate the expected Jan → Dec sequence. If a bad typo is parsed as a future date, it could still get included.

2. It filters out zero volumes
This line removes zero values:

each [Volume] <> null and [Volume] <> 0
I would be careful here. If OneSchema expects actual production records even when volume is 0, then zeros should stay. I would only remove null, not 0.

3. It depends on promoted headers
This can work, but it is more fragile because the month headers become column names. My earlier approach keeps raw rows longer and reads the header row directly, which is safer for this type of messy Excel.

4. Total complete vehicle detection may be too narrow
It only checks:

[#"Part Number"]
That works only if Total complete vehicle is always in that column. Safer is to search the whole row.

What it does well
✅ Loads the correct sheet

✅ Fills down Program

✅ Dynamically detects date columns

✅ Unpivots months

✅ Adds Period Start / Period End

✅ Adds Total complete vehicle separately

✅ Maps to the OneSchema output format

My recommendation
Use this script as a good draft, but adjust these before production:

Validate month columns by expected chronological sequence.

Do not remove zero volumes unless the business confirms.

Search the full row for Total complete vehicle, not only Part Number.

Keep only the first Total complete vehicle.

So: yes, the logic direction is right, but I would make those fixes before trusting it in Fabric.


ok, use this script I sent and correct what is necessary

Thought for a few seconds
Below is your script corrected with the main fixes:

Keeps your structure.

Does not rely on ACT/Q3FC.

Detects valid month columns dynamically.

Removes bad/out-of-sequence dates.

Does not remove zero volumes.

Finds Total complete vehicle dynamically across the whole row.

Keeps only the first Total complete vehicle row. 


let
    // ============================================================================
    // STEP 1: Load Excel File
    // ============================================================================
    Source = Excel.Workbook(
        File.Contents("C:\Development\fabric-local-dev\data\Actuals-March-2026.xlsx"), 
        null, 
        true
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

give it to me again, but this time insert the comment block in the beggining with all the steps taken and also for each block of code make sure to add comments so that you and me understand it later

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



