# OpenChamber Desktop - Universal Uninstaller (Windows)
# Run with: irm https://github.com/aencyorganization/openchamber-desktop/raw/main/scripts/uninstall-all.ps1 | iex

$AppName = "OpenChamber Desktop"
$AppPackage = "openchamber-desktop"

function Write-Status($message) {
    Write-Host "[INFO] $message" -ForegroundColor Blue
}

function Write-Success($message) {
    Write-Host "[SUCCESS] $message" -ForegroundColor Green
}

function Write-Warning($message) {
    Write-Host "[WARNING] $message" -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host "[ERROR] $message" -ForegroundColor Red
}

function Remove-SystemIntegration {
    Write-Status "Removing Windows system integration..."
    
    # Remove Start Menu shortcut
    $StartMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$AppName.lnk"
    if (Test-Path $StartMenuPath) {
        Remove-Item $StartMenuPath -Force
        Write-Success "Removed Start Menu shortcut"
    } else {
        Write-Warning "Start Menu shortcut not found"
    }
    
    # Remove Desktop shortcut
    $DesktopPath = "$env:USERPROFILE\Desktop\$AppName.lnk"
    if (Test-Path $DesktopPath) {
        Remove-Item $DesktopPath -Force
        Write-Success "Removed Desktop shortcut"
    }
}

function Uninstall-App {
    Write-Status "Uninstalling $AppName..."
    
    # Try bun
    if (Get-Command bun -ErrorAction SilentlyContinue) {
        Write-Status "Removing via Bun..."
        bun remove -g $AppPackage 2>$null
    }
    
    # Try npm
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Status "Removing via npm..."
        npm uninstall -g $AppPackage 2>$null
    }
    
    # Try pnpm
    if (Get-Command pnpm -ErrorAction SilentlyContinue) {
        Write-Status "Removing via pnpm..."
        pnpm remove -g $AppPackage 2>$null
    }
    
    if (Get-Command openchamber-desktop -ErrorAction SilentlyContinue) {
        Write-Warning "App may still be installed. Manual removal may be required."
    } else {
        Write-Success "$AppName uninstalled successfully!"
    }
}

# Main
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  $AppName - Universal Uninstaller" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Confirm
Write-Host "This will remove $AppName and all system integration." -ForegroundColor Yellow
Write-Host "Bun will NOT be removed." -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Are you sure? (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Status "Uninstallation cancelled."
    exit 0
}

Remove-SystemIntegration
Uninstall-App

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Success "Uninstallation complete!"
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: Bun was kept installed." -ForegroundColor Green
Write-Host "To remove Bun manually, delete: ~\.bun" -ForegroundColor Yellow
Write-Host ""
