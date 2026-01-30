@echo off
setlocal enabledelayedexpansion

:: ==============================================================================
:: OpenChamber Desktop - Windows Installation Script
:: ==============================================================================

:: Configuration
set "APP_NAME=openchamber-desktop"
set "DISPLAY_NAME=OpenChamber Desktop"
set "INSTALL_DIR=%LOCALAPPDATA%\OpenChamber Desktop"
set "LOG_DIR=%LOCALAPPDATA%\OpenChamber Desktop\logs"
set "LOG_FILE=%LOG_DIR%\install.log"
set "SOURCE_DIR=%~dp0..\.."
set "BACKUP_DIR=%LOCALAPPDATA%\OpenChamber Desktop.bak"
set "TEMP_ZIP=%TEMP%\ocd-release.zip"

:: Ensure Log Directory exists
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" 2>nul

:: PowerShell Command Wrapper
set "PS_CMD=powershell -NoProfile -ExecutionPolicy Bypass -Command"

:: Clear previous log for fresh installation attempt
echo. > "%LOG_FILE%"

call :Log "INFO" "Starting installation of %DISPLAY_NAME%..."
echo Installing %DISPLAY_NAME%...
echo Detailed progress: %LOG_FILE%
echo.

:: 1. Check Prerequisites
call :Log "INFO" "Checking prerequisites..."

:: Check PowerShell
where powershell >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] PowerShell is required but not found in PATH.
    echo [ERRO] O PowerShell e necessario mas nao foi encontrado no PATH.
    exit /b 1
)

:: Check Node.js
call :Log "INFO" "Checking Node.js installation..."
where node >nul 2>&1
if %ERRORLEVEL% neq 0 (
    call :Die "Node.js is required but not found in PATH. Please install Node.js 18+." "O Node.js e necessario mas nao foi encontrado no PATH. Por favor, instale o Node.js 18+."
)

:: Verify Node.js version >= 18
for /f "tokens=*" %%v in ('node -v') do set "NODE_VER=%%v"
call :Log "INFO" "Found Node.js version: %NODE_VER%"
%PS_CMD% "$v = '%NODE_VER%'; if ([int]$v.Split('.')[0].Trim('v') -lt 18) { exit 1 }"
if %ERRORLEVEL% neq 0 (
    call :Die "Node.js 18 or higher is required. Found: %NODE_VER%" "O Node.js 18 ou superior e necessario. Encontrado: %NODE_VER%"
)

:: 2. Verify Source Files or Download
call :Log "INFO" "Verifying source files at %SOURCE_DIR%..."
set "CAN_COPY=1"
if not exist "%SOURCE_DIR%\bin" set "CAN_COPY=0"
if not exist "%SOURCE_DIR%\resources" set "CAN_COPY=0"
if not exist "%SOURCE_DIR%\package.json" set "CAN_COPY=0"

if "%CAN_COPY%"=="1" (
    call :Log "INFO" "Source files verified. Proceeding with local copy."
) else (
    call :Log "WARN" "Source files not found or incomplete. Attempting to download latest release..."
    echo Source files not found locally, downloading latest release...
    
    %PS_CMD% "Try { Invoke-WebRequest -Uri 'https://github.com/aencyorganization/openchamber-desktop/releases/latest/download/openchamber-desktop-win_x64.zip' -OutFile '%TEMP_ZIP%' -ErrorAction Stop } Catch { exit 1 }"
    if %ERRORLEVEL% neq 0 (
        call :Die "Failed to download the latest release. Please check your internet connection." "Falha ao baixar a versao mais recente. Verifique sua conexao com a internet."
    )
    call :Log "INFO" "Download complete."
)

:: 3. Backup existing installation
if exist "%INSTALL_DIR%" (
    call :Log "INFO" "Existing installation found at %INSTALL_DIR%. Creating backup..."
    echo Backing up existing installation...
    
    if exist "%BACKUP_DIR%" (
        call :Log "INFO" "Removing previous backup..."
        rmdir /s /q "%BACKUP_DIR%" 2>nul
    )
    
    :: Attempt to rename/move (fast and preserves permissions)
    move "%INSTALL_DIR%" "%BACKUP_DIR%" >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        call :Log "ERROR" "Failed to move %INSTALL_DIR% to %BACKUP_DIR%. Files might be in use."
        call :Die "Failed to backup existing installation. Please ensure the application is closed." "Falha ao fazer backup da instalacao existente. Certifique-se de que o aplicativo esteja fechado."
    )
    call :Log "INFO" "Backup created at %BACKUP_DIR%"
)

:: 4. Create Installation Directory
call :Log "INFO" "Creating installation directory: %INSTALL_DIR%"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if %ERRORLEVEL% neq 0 (
    call :Die "Failed to create installation directory. Permission denied?" "Falha ao criar o diretorio de instalacao. Permissao negada?"
)

:: 5. Install Files
if "%CAN_COPY%"=="1" (
    call :Log "INFO" "Copying files..."
    echo Copying files...
    
    xcopy /E /I /Y "%SOURCE_DIR%\bin" "%INSTALL_DIR%\bin" >> "%LOG_FILE%" 2>&1
    if %ERRORLEVEL% neq 0 goto Rollback
    
    xcopy /E /I /Y "%SOURCE_DIR%\resources" "%INSTALL_DIR%\resources" >> "%LOG_FILE%" 2>&1
    if %ERRORLEVEL% neq 0 goto Rollback
    
    if exist "%SOURCE_DIR%\assets" (
        xcopy /E /I /Y "%SOURCE_DIR%\assets" "%INSTALL_DIR%\assets" >> "%LOG_FILE%" 2>&1
        if %ERRORLEVEL% neq 0 goto Rollback
    )
    
    copy /Y "%SOURCE_DIR%\package.json" "%INSTALL_DIR%\" >> "%LOG_FILE%" 2>&1
    if %ERRORLEVEL% neq 0 goto Rollback
    
    if exist "%SOURCE_DIR%\neutralino.config.json" (
        copy /Y "%SOURCE_DIR%\neutralino.config.json" "%INSTALL_DIR%\" >> "%LOG_FILE%" 2>&1
        if %ERRORLEVEL% neq 0 goto Rollback
    )
) else (
    call :Log "INFO" "Extracting downloaded release..."
    echo Extracting files...
    %PS_CMD% "Try { Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%INSTALL_DIR%' -Force -ErrorAction Stop } Catch { exit 1 }"
    if %ERRORLEVEL% neq 0 goto Rollback
    del "%TEMP_ZIP%" 2>nul
)

:: 6. Verify Installation
call :Log "INFO" "Verifying installation integrity..."
set "VERIFY_FAILED=0"
if not exist "%INSTALL_DIR%\bin" set "VERIFY_FAILED=1"
if not exist "%INSTALL_DIR%\bin\cli.js" set "VERIFY_FAILED=1"
if not exist "%INSTALL_DIR%\package.json" set "VERIFY_FAILED=1"

if "%VERIFY_FAILED%"=="1" (
    call :Log "ERROR" "Verification failed: Essential files missing after copy."
    goto Rollback
)
call :Log "INFO" "Installation verified."

:: 7. Create Start Menu Shortcut
call :Log "INFO" "Creating Start Menu shortcut..."
set "SHORTCUT_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%DISPLAY_NAME%.lnk"
set "ICON_PATH=%INSTALL_DIR%\assets\openchamber-logo-dark.png"
if not exist "%ICON_PATH%" set "ICON_PATH=%INSTALL_DIR%\resources\icon.ico"

%PS_CMD% "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SHORTCUT_PATH%'); $s.TargetPath = 'node.exe'; $s.Arguments = '\"%INSTALL_DIR%\bin\cli.js\"'; $s.WorkingDirectory = '%INSTALL_DIR%'; if (Test-Path '%ICON_PATH%') { $s.IconLocation = '%ICON_PATH%' }; $s.Save()"
if %ERRORLEVEL% neq 0 (
    call :Log "WARN" "Failed to create shortcut. Installation will continue."
) else (
    call :Log "INFO" "Shortcut created successfully at %SHORTCUT_PATH%"
)

:: 8. Add to PATH
call :Log "INFO" "Adding %INSTALL_DIR%\bin to User PATH..."
%PS_CMD% "$target = '%INSTALL_DIR%\bin'; $path = [Environment]::GetEnvironmentVariable('Path', 'User'); if ($path -notlike \"*$target*\") { [Environment]::SetEnvironmentVariable('Path', \"$path;$target\", 'User'); Write-Host 'Path updated' } else { Write-Host 'Already in path' }" >> "%LOG_FILE%" 2>&1
if %ERRORLEVEL% neq 0 (
    call :Log "WARN" "Failed to update PATH environment variable."
)

:: 9. Finalize
call :Log "INFO" "Installation successful."
if exist "%BACKUP_DIR%" (
    call :Log "INFO" "Cleaning up backup..."
    rmdir /s /q "%BACKUP_DIR%" 2>nul
)

echo.
echo %DISPLAY_NAME% has been installed successfully!
echo Shortcut created in Start Menu.
echo.
echo Log de instalacao: %LOG_FILE%
echo.
pause
exit /b 0

:: ==============================================================================
:: Helper Functions
:: ==============================================================================

:Log
set "LEVEL=%~1"
set "MSG=%~2"
for /f "tokens=1-3 delims=:.," %%a in ("%time%") do set "t=%%a:%%b:%%c"
set "TIMESTAMP=%date% %t%"
:: Log to file
echo [%TIMESTAMP%] [%LEVEL%] [win32-x64] %MSG% >> "%LOG_FILE%"
:: Log to console if ERROR or WARN
if "%LEVEL%"=="ERROR" echo [ERROR] %MSG%
if "%LEVEL%"=="WARN" echo [WARN] %MSG%
exit /b

:Die
set "MSG_EN=%~1"
set "MSG_PT=%~2"
call :Log "ERROR" "%MSG_EN%"
echo.
echo ************************************************************
echo ERROR: %MSG_EN%
echo ERRO: %MSG_PT%
echo ************************************************************
echo.
echo Check logs for details: %LOG_FILE%
echo.
pause
exit /b 1

:Rollback
call :Log "ERROR" "Installation failed during file operations. Initiating rollback..."
echo.
echo An error occurred. Rolling back changes...
echo Um erro ocorreu. Revertendo alteracoes...

if exist "%INSTALL_DIR%" (
    call :Log "INFO" "Removing failed installation directory..."
    rmdir /s /q "%INSTALL_DIR%" 2>nul
)

if exist "%BACKUP_DIR%" (
    call :Log "INFO" "Restoring from backup..."
    move "%BACKUP_DIR%" "%INSTALL_DIR%" >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        call :Log "ERROR" "Critical failure: Could not restore backup from %BACKUP_DIR%"
    ) else (
        call :Log "INFO" "Backup restored successfully."
    )
)

call :Die "Installation failed and was rolled back." "A instalacao falhou e foi revertida."
