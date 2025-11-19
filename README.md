# External Remakes

External Remakes pulls data from a SQL Server database, runs three reporting queries, and writes the results to Google Sheets. The repository includes the SQL queries used, a small Python codebase to read SQL into pandas DataFrames, and helpers to authenticate and write to Google Sheets.

## What it does

- Runs three SQL queries (in `sql_query/`) to produce different reports.
- Loads query results into pandas DataFrames using `pyodbc`.
- Writes DataFrames to Google Sheets using a Google service account.

## Repository layout

- `sql_query/`
  - `customer_remakes.sql` — counts cases and remakes by practice for the last ~91 days.
  - `remake_cases.sql` — detailed list of remake cases (linked cases), filtered to recent DateIn.
  - `revenue_by_day.sql` — daily revenue summary for recent days.
- `src/`
  - `db_handler.py` — reads SQL files, connects to SQL Server via ODBC, returns DataFrames.
  - `sheets_handler.py` — authenticates to Google Sheets (service account JSON in env) and writes/reads DataFrames.
  - `main.py` — project entrypoint (currently a simple placeholder printing a message).
- root scripts: `run_NICK_local.bat`, `run_MARYAM_local.bat`, `run_SERVER.bat` — convenience Windows batch files for running the project.

## Requirements

- Python 3.13 or newer (see `pyproject.toml`).
- Packages (from `pyproject.toml`): `dotenv`, `google-auth`, `gspread`, `gspread-dataframe`, `oauth2client`, `pandas`, `pyodbc`.
- An ODBC driver for SQL Server (the code uses `{ODBC Driver 17 for SQL Server}` by default).

Install common dependencies (example):

```powershell
python -m pip install --upgrade pip
python -m pip install python-dotenv google-auth gspread gspread-dataframe oauth2client pandas pyodbc
```

If you manage dependencies with a tool (Poetry, pip-tools, etc.) adapt accordingly.

## Environment variables

The code expects a few environment variables to be present (the project uses `python-dotenv` to load a `.env` file if present):

- SQL Server / DB connection:
  - `SQL_SERVER` — hostname or server\instance for SQL Server (e.g. `mydb.server.com` or `localhost\SQLEXPRESS`).
  - `SQL_DATABASE` — database name.
  - `SQL_USERNAME` — DB user.
  - `SQL_PASSWORD` — DB password.

- Google Sheets / Service Account:
  - `GOOGLE_SERVICE_ACCOUNT_JSON` — the full service account JSON contents as a single string (see notes below).
  - `GOOGLE_SPREADSHEET_ID` — the spreadsheet ID (the long ID in the Sheets URL) where reports will be written.
  - `GOOGLE_SHEET_NAME` — optional default sheet/tab name used by some demos.

Notes on `GOOGLE_SERVICE_ACCOUNT_JSON`:
- `sheets_handler.py` reads the entire JSON credentials blob from `GOOGLE_SERVICE_ACCOUNT_JSON` (as a string) and calls `Credentials.from_service_account_info()` — so you can either:
  - put the raw JSON text into your `.env` file under `GOOGLE_SERVICE_ACCOUNT_JSON` (ensure it's one-line or properly quoted), OR
  - export it in your environment before running the app, OR
  - modify `sheets_handler.py` to read credentials from a file path instead.

PowerShell example (temporary, per-session):

```powershell
$env:SQL_SERVER = 'my-sql-server'
$env:SQL_DATABASE = 'my_db'
$env:SQL_USERNAME = 'db_user'
$env:SQL_PASSWORD = 'secret'
# Load JSON credentials from a local file and assign to env var
$env:GOOGLE_SERVICE_ACCOUNT_JSON = Get-Content -Raw -Path '.\\service-account.json'
$env:GOOGLE_SPREADSHEET_ID = 'PUT_SPREADSHEET_ID_HERE'
python -m src.main
```

## How to run

- Option 1 — run via python module (recommended for debugging):

```powershell
python -m src.main
```

- Option 2 — use the included batch files on Windows (they call `uv run python -m src.main`):

```powershell
.\\run_NICK_local.bat
.\\run_MARYAM_local.bat  # NOTE: this script also contains a hard-coded `cd` path and may need editing for your machine
.\\run_SERVER.bat       # NOTE: may also contain a hard-coded path
```

## SQL queries

- `sql_query/customer_remakes.sql` — Counts cases and remakes by `PracticeName` for the last ~91 days.
- `sql_query/remake_cases.sql` — Retrieves linked case pairs where the `links.Notes` indicate a "Remake Of" relationship; includes several filters (status, date range).
- `sql_query/revenue_by_day.sql` — Aggregates daily revenue (Taxable + NonTaxable) for recent days.

These queries are authored for Microsoft SQL Server and use `GETDATE()` / `DATEADD()` functions and `dbo` schema references.

## Notes & next steps

- `src/main.py` is currently a placeholder that prints a message — integrate orchestration logic there to run queries, call `db_handler.execute_sql_to_dataframe()` for each SQL file, then call `SheetsHandler.write_dataframe_to_sheet()` to push results to Sheets.
- Consider storing the service account JSON in a secure secrets manager and loading it at runtime instead of placing it in `.env`.
- If your organization prefers using a credentials file instead of embedding JSON in an environment variable, update `sheets_handler.py` to use `Credentials.from_service_account_file()` or to read the file and pass the dict into `from_service_account_info()`.

## Troubleshooting

- ODBC errors: confirm the `ODBC Driver 17 for SQL Server` (or the driver you have) is installed.
- Google auth errors: verify the service account has access to the target spreadsheet (share the sheet with the service account email).

## Contact

If you need help wiring the orchestration (running all three queries and pushing them to separate sheets/tabs), tell me how you'd like the Sheets organized and I can add a `src/main.py` implementation that runs the queries and writes each result to its own tab.
