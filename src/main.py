# src/main.py
import os
from pathlib import Path
from .db_handler import execute_sql_to_dataframe

# Define project root and SQL queries directory
PROJECT_ROOT = Path(__file__).parent.parent  # goes up from src/ to root
SQL_QUERIES_DIR = PROJECT_ROOT / "sql_query"

def main():
    print("Starting SQL query execution...\n")
    # List of SQL query files to execute
    query_files = [
        "remake_cases.sql",
        "revenue_by_day.sql",
        "customer_remakes.sql",
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
        else:
            print(f"Success: Loaded {len(df):,} rows and {len(df.columns)} columns")
            print(f"Columns: {list(df.columns)}\n")
            
            # Store in dictionary with nice name (without .sql)
            df_name = query_file.replace(".sql", "").replace(" ", "_")
            dataframes[df_name] = df

    # Now you have all DataFrames in the `dataframes` dict!
    print(f"\nAll queries completed. Loaded {len(dataframes)} DataFrame(s):")
    for name in dataframes:
        print(f"  - {name}: {dataframes[name].shape}")

    #Example: access them later
    df_cases = dataframes.get("remake_cases")
    df_revenue = dataframes.get("revenue_by_day")
    df_customers = dataframes.get("customer_remakes")

    # Keep the script running if you want to explore in interactive mode
    # (useful when running with python -i src/main.py)
    print("\nTip: You can now explore the 'dataframes' dictionary interactively!")

    return dataframes


if __name__ == "__main__":
    # This allows running with: python src/main.py
    # Or python -i src/main.py to drop into interactive shell after
    dataframes = main()