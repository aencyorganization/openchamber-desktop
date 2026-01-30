@echo off
setlocal enabledelayedexpansion

:: OpenChamber Desktop Uninstaller for Windows
:: This script calls the unified Node.js uninstaller

echo ==========================================
echo  OpenChamber Desktop Uninstaller
echo ==========================================
echo.

:: Check if Node.js is available
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

:: Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"
set "UNINSTALL_JS=%SCRIPT_DIR%uninstall.js"

:: Check if the uninstall script exists
if not exist "%UNINSTALL_JS%" (
    echo ERROR: Uninstall script not found at %UNINSTALL_JS%
    pause
    exit /b 1
)

:: Run the uninstaller
echo Starting uninstallation process...
echo.
node "%UNINSTALL_JS%"

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Uninstallation failed with code %errorlevel%
    pause
    exit /b %errorlevel%
)

echo.
echo ==========================================
echo  Uninstallation Complete
echo ==========================================
pause
exit /b 0
