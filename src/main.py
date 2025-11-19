# src/main.py
import os
from pathlib import Path
from .db_handler import execute_sql_to_dataframe
from .sheets_handler import SheetsHandler  # <-- Added this import

# Define project root and SQL queries directory
PROJECT_ROOT = Path(__file__).parent.parent
SQL_QUERIES_DIR = PROJECT_ROOT / "sql_query"

# Mapping: SQL filename → Desired Google Sheet tab name (feel free to customize!)
SQL_TO_SHEET_TAB = {
    "remake_cases.sql": "Cases Import",
    "revenue_by_day.sql": "Revenue Import",
    "report_table_strats.sql": "Report Table Import",
}

def main():
    print("Starting ETL: SQL Server → Google Sheets\n")

    # === 1. Initialize Google Sheets Handler ===
    try:
        sheets_handler = SheetsHandler()
        print("Google Sheets authenticated successfully!\n")
    except Exception as e:
        print(f"Failed to authenticate with Google Sheets: {e}")
        print("Check your GOOGLE_SERVICE_ACCOUNT_JSON and GOOGLE_SPREADSHEET_ID in .env")
        return {}

    # === 2. Execute SQL Queries ===
    query_files = [
        "remake_cases.sql",
        "revenue_by_day.sql",
        "report_table_strats.sql",
    ]

    dataframes = {}

    for query_file in query_files:
        file_path = SQL_QUERIES_DIR / query_file
        
        if not file_path.exists():
            print(f"Warning: {file_path} not found! Skipping...")
            continue
        
        print(f"="*60)
        print(f"Executing: {query_file}")
        print(f"="*60)
        
        df = execute_sql_to_dataframe(str(file_path))
        
        if df.empty:
            print(f"No data returned or error occurred for {query_file}\n")
            continue

        print(f"Success: Loaded {len(df):,} rows × {len(df.columns)} columns")
        print(f"Columns: {list(df.columns)}\n")
        
        # Store in dictionary
        df_name = query_file.replace(".sql", "")
        dataframes[df_name] = df

        # === 3. Upload to Google Sheets ===
        tab_name = SQL_TO_SHEET_TAB.get(query_file, df_name.replace("_", " ").title())
        
        print(f"Uploading to Google Sheets → Tab: '{tab_name}'")
        
        success = sheets_handler.write_dataframe_to_sheet(
            df=df,
            sheet_name=tab_name,
            clear_sheet=True
        )
        
        if success:
            print(f"Uploaded successfully to '{tab_name}'\n")
        else:
            print(f"Failed to upload to '{tab_name}'\n")

    # === Summary ===
    print(f"ETL Complete!")
    print(f"Successfully processed {len(dataframes)} queries")
    print(f"Updated Google Sheets tabs:")
    for query_file, tab_name in SQL_TO_SHEET_TAB.items():
        if query_file in [q for q in query_files if (SQL_QUERIES_DIR / q).exists()]:
            status = "Success" if query_file.replace(".sql", "") in dataframes else "Failed"
            print(f"  • {tab_name} → {status}")

    return dataframes


if __name__ == "__main__":
    dataframes = main()