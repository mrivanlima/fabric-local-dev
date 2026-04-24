import pandas as pd

# Read Excel file
excel_path = '/opt/data/Actuals-March-2026.xlsx'
df = pd.read_excel(excel_path, sheet_name='Production Volumes', header=None)

print('='*80)
print('ROW 68 (Excel line 68, pandas index 67):')
print('='*80)
print(df.iloc[67])

print('\n' + '='*80)
print('ROWS 65-70 for context:')
print('='*80)
print(df.iloc[64:70].to_string())

print('\n' + '='*80)
print('ALL ROWS WITH "total" or "complete" in Description column (Column 4):')
print('='*80)
# After skipping 3 rows and promoting headers, Description is column index 4
for idx, row in df.iterrows():
    desc = str(row[4]) if pd.notna(row[4]) else ""
    if "total" in desc.lower() or "complete" in desc.lower():
        print(f'Row {idx+1} (Excel line {idx+1}): Description = {desc}')
