@echo off
setlocal enabledelayedexpansion

set "APP_NAME=openchamber-desktop"
set "DISPLAY_NAME=OpenChamber Desktop"
set "INSTALL_DIR=%LOCALAPPDATA%\OpenChamber Desktop"

echo Installing %DISPLAY_NAME%...

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Determine source
set "SOURCE_DIR=%~dp0..\.."

if exist "%SOURCE_DIR%\bin" (
    echo Copying files from %SOURCE_DIR%...
    xcopy /E /I /Y "%SOURCE_DIR%\bin" "%INSTALL_DIR%\bin"
    xcopy /E /I /Y "%SOURCE_DIR%\resources" "%INSTALL_DIR%\resources"
    xcopy /E /I /Y "%SOURCE_DIR%\assets" "%INSTALL_DIR%\assets"
    copy /Y "%SOURCE_DIR%\package.json" "%INSTALL_DIR%\"
    copy /Y "%SOURCE_DIR%\neutralino.config.json" "%INSTALL_DIR%\"
) else (
    echo Source files not found, attempting to download latest release...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/aencyorganization/openchamber-desktop/releases/latest/download/openchamber-desktop-win_x64.zip' -OutFile '%TEMP%\release.zip'"
    powershell -Command "Expand-Archive -Path '%TEMP%\release.zip' -DestinationPath '%INSTALL_DIR%' -Force"
)

:: Create Start Menu shortcut
set "SHORTCUT_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%DISPLAY_NAME%.lnk"
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SHORTCUT_PATH%'); $s.TargetPath = 'node.exe'; $s.Arguments = '\"%INSTALL_DIR%\bin\cli.js\"'; $s.WorkingDirectory = '%INSTALL_DIR%'; $s.IconLocation = '%INSTALL_DIR%\assets\openchamber-logo-dark.png'; $s.Save()"

:: Add to PATH
setx PATH "%PATH%;%INSTALL_DIR%\bin"

echo %DISPLAY_NAME% has been installed successfully!
pause
