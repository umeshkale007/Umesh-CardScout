@echo off
setlocal enabledelayedexpansion
title Card-Scout Setup

echo.
echo ============================================================
echo   Umesh's Card-Scout — Setup
echo ============================================================
echo.

:: ── Step 1: Check Python ─────────────────────────────────────
echo [1/3] Checking for Python 3...

py --version >nul 2>&1
if %errorlevel% == 0 (
    for /f "tokens=*" %%v in ('py --version 2^>^&1') do set PYVER=%%v
    echo       Found: !PYVER!
    set PIP=py -m pip
) else (
    python --version >nul 2>&1
    if %errorlevel% == 0 (
        for /f "tokens=*" %%v in ('python --version 2^>^&1') do set PYVER=%%v
        echo       Found: !PYVER!
        set PIP=python -m pip
    ) else (
        echo.
        echo   ERROR: Python 3 was not found on this computer.
        echo.
        echo   Please install it from:
        echo     https://www.python.org/downloads/
        echo.
        echo   IMPORTANT: On the first installer screen, check the box that says
        echo   "Add Python to PATH" before clicking Install.
        echo.
        echo   After installing, close this window and double-click setup.bat again.
        echo.
        pause
        exit /b 1
    )
)

:: ── Step 2: Install Python libraries ─────────────────────────
echo.
echo [2/3] Installing required Python libraries...
echo       (openpyxl and Pillow — this may take a minute)
echo.

%PIP% install -r requirements.txt
if %errorlevel% neq 0 (
    echo.
    echo   ERROR: Library installation failed.
    echo   Check your internet connection and try again.
    echo   If the problem persists, run this manually:
    echo     py -m pip install openpyxl Pillow
    echo.
    pause
    exit /b 1
)

echo.
echo       Libraries installed successfully.

:: ── Step 3: Check Claude Code ────────────────────────────────
echo.
echo [3/3] Checking for Claude Code...

claude --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo   ERROR: The 'claude' command was not found.
    echo.
    echo   Please install Claude Code from:
    echo     https://claude.ai/code
    echo.
    echo   After installing, close this window and double-click setup.bat again.
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%v in ('claude --version 2^>^&1') do set CLAUDEVER=%%v
echo       Found: !CLAUDEVER!

:: ── All done ─────────────────────────────────────────────────
echo.
echo ============================================================
echo   Setup complete!
echo ============================================================
echo.
echo   Next steps:
echo     1. Open a terminal (Command Prompt or PowerShell) in this folder
echo     2. Type:  claude
echo     3. Then type:  /scan-card inbox/yourfile.jpg
echo.
echo   The full usage guide is in README.md
echo.
pause
