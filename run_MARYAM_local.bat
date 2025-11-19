@echo off
REM Change to the script's directory (project root)
REM **FIX MARYAM PAth
cd /d "C:\Users\MagicTouch\Desktop\Nick\repos\External_Remakes" 

REM Run the Python script using uv
powershell.exe -Command "uv run python -m src.main"

pause