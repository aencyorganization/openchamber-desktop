@echo off
setlocal

set "DISPLAY_NAME=OpenChamber Desktop"
set "INSTALL_DIR=%LOCALAPPDATA%\OpenChamber Desktop"

echo Uninstalling %DISPLAY_NAME%...

if exist "%INSTALL_DIR%" rd /S /Q "%INSTALL_DIR%"

set "SHORTCUT_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%DISPLAY_NAME%.lnk"
if exist "%SHORTCUT_PATH%" del "%SHORTCUT_PATH%"

set "DESKTOP_SHORTCUT=%USERPROFILE%\Desktop\%DISPLAY_NAME%.lnk"
if exist "%DESKTOP_SHORTCUT%" del "%DESKTOP_SHORTCUT%"

echo %DISPLAY_NAME% has been removed successfully!
pause
