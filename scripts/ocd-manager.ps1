<#
.SYNOPSIS
    OpenChamber Desktop Manager for Windows.
.DESCRIPTION
    A comprehensive TUI for installing, updating, and managing OpenChamber Desktop.
#>

$ErrorActionPreference = "Stop"

# --- Constants & Configuration ---
$OCD_PACKAGE = "openchamber-desktop"
$OC_PACKAGE = "@openchamber/web"
$ASSETS_DIR = "$PSScriptRoot\..\assets"
$LOGO_PATH = "$ASSETS_DIR\openchamber-logo-dark.png"
$SHORTCUT_NAME = "OpenChamber Desktop"

# Colors
$ColSuccess = "Green"
$ColError = "Red"
$ColWarning = "Yellow"
$ColInfo = "Cyan"
$ColHeader = "Magenta"

# --- Helper Functions ---

function Test-Command($Command) {
    return (Get-Command $Command -ErrorAction SilentlyContinue) -ne $null
}

function Get-PackageManager {
    if (Test-Command "bun") { return "bun" }
    if (Test-Command "pnpm") { return "pnpm" }
    if (Test-Command "npm") { return "npm" }
    return $null
}

function Install-PackageManager {
    Show-Progress 1 1 "Installing Bun..."
    try {
        powershell -ExecutionPolicy Bypass -c "irm bun.sh/install.ps1 | iex"
        # Refresh path for current session
        $env:PATH += ";$env:USERPROFILE\.bun\bin"
        if (Test-Command "bun") {
            Show-Success "Bun installed successfully!"
            return "bun"
        }
    } catch {
        Show-Error "Failed to install Bun: $_"
    }
    return $null
}

function Create-Shortcut {
    param(
        [string]$Path,
        [string]$TargetPath,
        [string]$IconPath,
        [string]$Description
    )
    try {
        $Shell = New-Object -ComObject WScript.Shell
        $Shortcut = $Shell.CreateShortcut($Path)
        $Shortcut.TargetPath = $TargetPath
        if ($IconPath -and (Test-Path $IconPath)) {
            $Shortcut.IconLocation = $IconPath
        }
        $Shortcut.Description = $Description
        $Shortcut.Save()
        return $true
    } catch {
        Show-Error "Failed to create shortcut at $Path: $_"
        return $false
    }
}

function Remove-Shortcut($Path) {
    if (Test-Path $Path) {
        Remove-Item $Path -Force
        return $true
    }
    return $false
}

function Show-Header {
    Clear-Host
    Write-Host @"
$([char]9556)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9557)
$([char]9553)   ____                   _____ _                     _           $([char]9553)
$([char]9553)  / __ \                 / ____| |                   | |          $([char]9553)
$([char]9553) | |  | |_ __   ___ _ __| |    | |__   __ _ _ __ ___ | |__   ___ _ __ $([char]9553)
$([char]9553) | |  | | '_ \ / _ \ '_ \ |    | '_ \ / _' | '_ ' _ \| '_ \ / _ \ '__|$([char]9553)
$([char]9553) | |__| | |_) |  __/ | | | |____| | | | (_| | | | | | | |_) |  __/ |   $([char]9553)
$([char]9553)  \____/| .__/ \___|_| |_|\_____|_| |_|\__,_|_| |_| |_|_.__/ \___|_|   $([char]9553)
$([char]9553)       | |                                                            $([char]9553)
$([char]9553)       |_|              D E S K T O P   M A N A G E R             $([char]9553)
$([char]9558)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9559)
"@ -ForegroundColor $ColHeader
    Write-Host ""
}

function Show-Progress($Step, $Total, $Message) {
    Write-Host "[$Step/$Total] " -NoNewline -ForegroundColor $ColInfo
    Write-Host $Message
    Start-Sleep -Milliseconds 200
}

function Show-Success($Message) {
    Write-Host "[OK] $Message" -ForegroundColor $ColSuccess
}

function Show-Error($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor $ColError
}

function Show-Warning($Message) {
    Write-Host "[WARN] $Message" -ForegroundColor $ColWarning
}

function Show-Menu {
    Write-Host "$([char]9556)$([char]9552)$([char]9552) Main Menu $([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9557)"
    Write-Host "$([char]9553) 1. Install/Update OCD                       $([char]9553)"
    Write-Host "$([char]9553) 2. Complete Uninstall                       $([char]9553)"
    Write-Host "$([char]9553) 3. System Info                             $([char]9553)"
    Write-Host "$([char]9553) 4. Exit                                    $([char]9553)"
    Write-Host "$([char]9558)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9552)$([char]9559)"
    Write-Host ""
}

# --- Main Logic ---

function Invoke-Install {
    Show-Header
    Show-Progress 1 3 "Checking Package Manager..."
    $PM = Get-PackageManager
    if (-not $PM) {
        Show-Warning "No package manager found. Attempting to install Bun..."
        $PM = Install-PackageManager
        if (-not $PM) {
            Show-Error "Could not install Bun. Please install Node.js or Bun manually."
            Read-Host "Press Enter to return to menu..."
            return
        }
    }
    Show-Success "Using $PM as package manager."

    Show-Progress 2 3 "Installing/Updating OpenChamber components..."
    
    # Install OpenChamber Core
    Write-Host "Checking for OpenChamber Core..."
    if ($PM -eq "bun") { bun add -g $OC_PACKAGE }
    elseif ($PM -eq "pnpm") { pnpm add -g $OC_PACKAGE }
    else { npm install -g $OC_PACKAGE }
    
    # Install OCD
    Write-Host "Installing OpenChamber Desktop globally..."
    if ($PM -eq "bun") { bun add -g $OCD_PACKAGE }
    elseif ($PM -eq "pnpm") { pnpm add -g $OCD_PACKAGE }
    else { npm install -g $OCD_PACKAGE }
    
    Show-Success "OpenChamber Desktop installed globally."

    Show-Progress 3 3 "Configuration..."
    
    # Alias questions as requested
    Write-Host "Configuring Aliases..." -ForegroundColor $ColInfo
    $UseOcd = (Read-Host "Use 'ocd' as alias? (Y/n)") -ne "n"
    $UseFull = (Read-Host "Use 'openchamber-desktop' as alias? (Y/n)") -ne "n"
    $CustomAlias = Read-Host "Enter custom alias (or leave empty)"
    
    if ($CustomAlias) {
        Write-Host "Note: Custom alias '$CustomAlias' will need to be added to your PowerShell profile manually." -ForegroundColor $ColWarning
    }

    # Shortcut selection
    $DoDesktop = (Read-Host "Create Desktop shortcut? (Y/n)") -ne "n"
    $DoStartMenu = (Read-Host "Create Start Menu entry? (Y/n)") -ne "n"

    # Resolve Binary Path
    $BinPath = (Get-Command ocd -ErrorAction SilentlyContinue).Source
    if (-not $BinPath) {
        # Fallback guesses
        if ($PM -eq "bun") { 
            $BinPath = "$env:USERPROFILE\.bun\bin\ocd.exe" 
            if (-not (Test-Path $BinPath)) { $BinPath = "$env:USERPROFILE\.bun\bin\ocd" }
        }
        else { $BinPath = "$env:APPDATA\npm\ocd.cmd" }
    }

    if ($DoDesktop) {
        $DesktopPath = "$env:USERPROFILE\Desktop\$SHORTCUT_NAME.lnk"
        Create-Shortcut -Path $DesktopPath -TargetPath $BinPath -IconPath $LOGO_PATH -Description "Launch OpenChamber Desktop"
        Show-Success "Desktop shortcut created."
    }

    if ($DoStartMenu) {
        $StartMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$SHORTCUT_NAME.lnk"
        Create-Shortcut -Path $StartMenuPath -TargetPath $BinPath -IconPath $LOGO_PATH -Description "Launch OpenChamber Desktop"
        Show-Success "Start Menu entry created."
    }

    Show-Success "OpenChamber Desktop is ready to use!"
    Read-Host "Press Enter to return to menu..."
}

function Invoke-Uninstall {
    Show-Header
    Show-Warning "This will remove OpenChamber Desktop and its shortcuts."
    $Confirm = Read-Host "Type 'yes' to confirm"
    if ($Confirm -ne "yes") {
        Write-Host "Operation cancelled."
        Read-Host "Press Enter to return to menu..."
        return
    }

    Show-Progress 1 3 "Removing OpenChamber Desktop..."
    $PM = Get-PackageManager
    if ($PM) {
        if ($PM -eq "bun") { bun remove -g $OCD_PACKAGE }
        elseif ($PM -eq "pnpm") { pnpm remove -g $OCD_PACKAGE }
        else { npm uninstall -g $OCD_PACKAGE }
        Show-Success "OCD uninstalled."
    }

    $RemoveOC = (Read-Host "Remove OpenChamber Core (@openchamber/web) as well? (y/N)") -eq "y"
    if ($RemoveOC -and $PM) {
        Show-Progress 2 3 "Removing OpenChamber Core..."
        if ($PM -eq "bun") { bun remove -g $OC_PACKAGE }
        elseif ($PM -eq "pnpm") { pnpm remove -g $OC_PACKAGE }
        else { npm uninstall -g $OC_PACKAGE }
        Show-Success "OpenChamber Core removed."
    }

    Show-Progress 3 3 "Removing Shortcuts..."
    Remove-Shortcut "$env:USERPROFILE\Desktop\$SHORTCUT_NAME.lnk"
    Remove-Shortcut "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$SHORTCUT_NAME.lnk"
    Show-Success "Shortcuts removed."

    Show-Success "Uninstall complete."
    Read-Host "Press Enter to return to menu..."
}

function Invoke-SystemInfo {
    Show-Header
    Write-Host "--- System Information ---" -ForegroundColor $ColInfo
    $OS = Get-WmiObject Win32_OperatingSystem
    Write-Host "OS: $($OS.Caption) ($($OS.Version))"
    Write-Host "Architecture: $env:PROCESSOR_ARCHITECTURE"
    
    $PM = Get-PackageManager
    Write-Host "Package Manager: $(if ($PM) { $PM } else { 'None' })"
    
    if (Test-Command "openchamber") {
        $OCVer = openchamber --version
        Write-Host "OpenChamber Core: $OCVer"
    } else {
        Write-Host "OpenChamber Core: Not installed"
    }

    if (Test-Command "ocd") {
        Write-Host "OCD Status: Installed"
        Write-Host "Binary Path: $((Get-Command ocd).Source)"
    } else {
        Write-Host "OCD Status: Not installed"
    }

    Write-Host "`nPaths:"
    Write-Host "- Manager Script: $PSCommandPath"
    Write-Host "- Assets: $ASSETS_DIR"
    
    Write-Host ""
    Read-Host "Press Enter to return to menu..."
}

# --- Execution Loop ---

$Exit = $false
do {
    try {
        Show-Header
        Show-Menu
        $Choice = Read-Host "Select an option (1-4)"

        switch ($Choice) {
            "1" { Invoke-Install }
            "2" { Invoke-Uninstall }
            "3" { Invoke-SystemInfo }
            "4" { $Exit = $true }
            default { Show-Error "Invalid option. Please try again." ; Start-Sleep -Seconds 1 }
        }
    } catch {
        Show-Error "An unexpected error occurred: $_"
        Read-Host "Press Enter to continue..."
    }
} until ($Exit)

Show-Header
Write-Host "Thank you for using OpenChamber Desktop! Goodbye." -ForegroundColor $ColSuccess
Start-Sleep -Seconds 1
