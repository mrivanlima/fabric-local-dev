import pandas as pd
import sys

# Read the OneSchema v3 Excel file
file_path = '/opt/data/Pilzen_Production_Volume_Cleaned_OneSchema_v3.xlsx'

try:
    # Try to read all sheets
    xls = pd.ExcelFile(file_path)
    print("=" * 80)
    print(f"SHEET NAMES: {xls.sheet_names}")
    print("=" * 80)
    
    # Read first sheet
    df = pd.read_excel(file_path, sheet_name=0)
    
    print(f"\nSHAPE: {df.shape}")
    print(f"\nCOLUMNS: {df.columns.tolist()}")
    print("\n" + "=" * 80)
    print("FIRST 10 ROWS:")
    print("=" * 80)
    print(df.head(10).to_string())
    
    print("\n" + "=" * 80)
    print("ROWS CONTAINING 'Total complete vehicle' in Product/Line Name:")
    print("=" * 80)
    
    # Check if Product/Line Name column exists
    if 'Product/Line Name' in df.columns:
        total_vehicle_rows = df[df['Product/Line Name'].astype(str).str.contains('total complete vehicle', case=False, na=False)]
        print(f"\nFound {len(total_vehicle_rows)} rows")
        if len(total_vehicle_rows) > 0:
            print("\n" + total_vehicle_rows.to_string())
            print("\n" + "=" * 80)
            print("FIRST ROW DETAILS:")
            print("=" * 80)
            for col in df.columns:
                print(f"{col}: {total_vehicle_rows.iloc[0][col]}")
    else:
        print("No 'Product/Line Name' column found!")
        print(f"Available columns: {df.columns.tolist()}")
    
    print("\n" + "=" * 80)
    print("UNIQUE VALUES IN Product/Line Name (first 20):")
    print("=" * 80)
    if 'Product/Line Name' in df.columns:
        unique_vals = df['Product/Line Name'].unique()
        for i, val in enumerate(unique_vals[:20]):
            print(f"{i+1}. {val}")
        print(f"\nTotal unique values: {len(unique_vals)}")
    
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
