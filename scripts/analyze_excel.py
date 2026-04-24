import pandas as pd
import sys

# Read Excel file
excel_path = '/opt/data/Actuals-March-2026.xlsx'
xl = pd.ExcelFile(excel_path)

print('='*80)
print('AVAILABLE SHEETS:')
print('='*80)
for i, sheet in enumerate(xl.sheet_names, 1):
    print(f'{i}. {sheet}')

# Read Production Volumes sheet
df = pd.read_excel(excel_path, sheet_name='Production Volumes')

print('\n' + '='*80)
print('SHEET: Production Volumes')
print('='*80)
print(f'\nDimensions: {df.shape[0]} rows x {df.shape[1]} columns')

print('\n' + '-'*80)
print('COLUMN NAMES:')
print('-'*80)
for i, col in enumerate(df.columns.tolist(), 1):
    print(f'{i:2d}. {col}')

print('\n' + '-'*80)
print('DATA TYPES:')
print('-'*80)
print(df.dtypes)

print('\n' + '-'*80)
print('NULL/MISSING VALUES:')
print('-'*80)
null_counts = df.isnull().sum()
print(null_counts[null_counts > 0] if null_counts.sum() > 0 else 'No null values found')

print('\n' + '-'*80)
print('FIRST 20 ROWS:')
print('-'*80)
pd.set_option('display.max_columns', None)
pd.set_option('display.width', None)
pd.set_option('display.max_colwidth', 50)
print(df.head(20).to_string(index=True))

print('\n' + '-'*80)
print('LAST 10 ROWS:')
print('-'*80)
print(df.tail(10).to_string(index=True))

print('\n' + '-'*80)
print('SUMMARY STATISTICS (Numeric Columns):')
print('-'*80)
print(df.describe().to_string())

print('\n' + '-'*80)
print('UNIQUE VALUES PER COLUMN:')
print('-'*80)
for col in df.columns:
    unique_count = df[col].nunique()
    print(f'{col}: {unique_count} unique values')
    if unique_count <= 10:
        print(f'  Values: {sorted(df[col].dropna().unique().tolist())}')
