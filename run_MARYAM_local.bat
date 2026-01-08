@echo off 
REM Change to the script's directory (project root)
cd /d "C:\Users\Partners\Documents\repos\External_Remakes"

REM Run the Python script using uv
powershell.exe -Command "uv run python -m src.main"

pause