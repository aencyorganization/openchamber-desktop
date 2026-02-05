# OpenChamber Desktop - Update Script for Windows
# Updates OpenChamber Desktop to the latest version
# Usage: irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.ps1 | iex

param(
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

$AppName = "OpenChamber Desktop"
$PkgName = "openchamber-desktop"
$CorePkg = "@openchamber/web"

function Write-Info($Message) {
    Write-Host "[OCD-UPDATE] $Message" -ForegroundColor Cyan
}

function Write-Success($Message) {
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn($Message) {
    Write-Host "[!] $Message" -ForegroundColor Yellow
}

function Write-Error($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-Command($Command) {
    return [bool](Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

# Stop processes
function Stop-Processes {
    Write-Info "Stopping OpenChamber processes..."
    
    Get-Process | Where-Object { $_.Name -like "*openchamber*" -or $_.Name -like "*neutralino*" } | ForEach-Object {
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        Write-Info "Stopped: $($_.Name)"
    }
    
    Start-Sleep -Seconds 1
    Write-Success "Processes stopped"
}

# Clean old configs
function Clear-OldConfigs {
    Write-Info "Cleaning old configurations..."
    
    $ConfigPaths = @(
        "$env:APPDATA\openchamber"
        "$env:LOCALAPPDATA\openchamber-desktop"
    )
    
    foreach ($Path in $ConfigPaths) {
        if (Test-Path $Path) {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Info "Removed: $Path"
        }
    }
    
    Write-Success "Old configurations cleaned"
}

# Detect package manager
function Get-PackageManager {
    Write-Info "Detecting package manager..."
    
    if (Test-Command "bun") { return "bun" }
    if (Test-Command "pnpm") { return "pnpm" }
    if (Test-Command "yarn") { return "yarn" }
    if (Test-Command "npm") { return "npm" }
    
    Write-Error "No package manager found!"
    exit 1
}

# Reinstall package
function Reinstall-Package {
    param($PM)
    
    Write-Info "Reinstalling packages..."
    
    # Remove old
    switch ($PM) {
        "bun" {
            bun remove -g $PkgName 2>$null
            bun remove -g $CorePkg 2>$null
        }
        "pnpm" {
            pnpm remove -g $PkgName 2>$null
            pnpm remove -g $CorePkg 2>$null
        }
        "yarn" {
            yarn global remove $PkgName 2>$null
            yarn global remove $CorePkg 2>$null
        }
        "npm" {
            npm uninstall -g $PkgName 2>$null
            npm uninstall -g $CorePkg 2>$null
        }
    }
    
    # Install new
    switch ($PM) {
        "bun" {
            bun add -g $CorePkg
            bun install -g $PkgName
        }
        "pnpm" {
            pnpm add -g $CorePkg
            pnpm add -g $PkgName
        }
        "yarn" {
            yarn global add $CorePkg
            yarn global add $PkgName
        }
        "npm" {
            npm install -g $CorePkg
            npm install -g $PkgName
        }
    }
    
    Write-Success "Packages reinstalled"
}

# Update desktop shortcut
function Update-DesktopShortcut {
    Write-Info "Updating desktop shortcut..."
    
    $DesktopPath = "$env:USERPROFILE\Desktop\OpenChamber Desktop.lnk"
    
    # Remove old
    if (Test-Path $DesktopPath) {
        Remove-Item $DesktopPath -Force
        Write-Info "Removed old shortcut"
    }
    
    # Find executable
    $ExecPath = ""
    if (Test-Command "openchamber-desktop") {
        $ExecPath = (Get-Command "openchamber-desktop").Source
    }
    
    if (-not $ExecPath) {
        $PossiblePaths = @(
            "$env:USERPROFILE\.bun\bin\openchamber-desktop.cmd"
            "$env:APPDATA\npm\openchamber-desktop.cmd"
            "$env:LOCALAPPDATA\pnpm\openchamber-desktop.cmd"
        )
        
        foreach ($Path in $PossiblePaths) {
            if (Test-Path $Path) {
                $ExecPath = $Path
                break
            }
        }
    }
    
    if ($ExecPath) {
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($DesktopPath)
        $Shortcut.TargetPath = $ExecPath
        $Shortcut.WorkingDirectory = "$env:USERPROFILE"
        $Shortcut.IconLocation = "powershell.exe,0"
        $Shortcut.Save()
        Write-Success "Desktop shortcut updated"
    }
}

# Main
function Main {
    Write-Host ""
    Write-Host "OpenChamber Desktop - Update for Windows" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    
    if (-not $Silent) {
        $Continue = Read-Host "Do you want to update? (y/n)"
        if ($Continue -ne 'y' -and $Continue -ne 'Y') {
            Write-Host "Canceled."
            exit 0
        }
    }
    
    Stop-Processes
    Clear-OldConfigs
    $PM = Get-PackageManager
    Reinstall-Package -PM $PM
    Update-DesktopShortcut
    
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host "Update Completed!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "$AppName has been updated to the latest version!" -ForegroundColor Green
    Write-Host ""
    Write-Host "The white screen issue has been fixed!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Remove old icons from taskbar" -ForegroundColor Yellow
    Write-Host "2. Open from Start Menu or Run dialog (Win+R)" -ForegroundColor Yellow
    Write-Host "3. Pin the new icon to taskbar" -ForegroundColor Yellow
    Write-Host ""
}

Main
