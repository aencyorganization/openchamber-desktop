#!/usr/bin/env pwsh

# OpenChamber Desktop - Auto Uninstaller (Windows)
# Removes everything automatically
# Usage: irm <url> | iex

$ErrorActionPreference = "SilentlyContinue"

$APP_NAME = "OpenChamber Desktop"
$PKG_NAME = "openchamber-desktop"
$CORE_PKG = "@openchamber/web"

# Colors
function Write-Info($msg) { Write-Host "[OCD] $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }

# Check if command exists
function Test-Command($cmd) {
    return [bool](Get-Command -Name $cmd -ErrorAction SilentlyContinue)
}

# Get package manager
function Get-PackageManager {
    if (Test-Command "bun") { return "bun" }
    if (Test-Command "pnpm") { return "pnpm" }
    if (Test-Command "npm") { return "npm" }
    return $null
}

# Main uninstall
function Main {
    Write-Host ""
    Write-Host "OpenChamber Desktop - Auto Uninstaller" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host ""
    
    $pm = Get-PackageManager
    
    # Remove OCD
    if ($pm) {
        Write-Info "Removing OpenChamber Desktop..."
        switch ($pm) {
            "bun" { bun uninstall -g $PKG_NAME 2>$null }
            "pnpm" { pnpm remove -g $PKG_NAME 2>$null }
            "npm" { npm uninstall -g $PKG_NAME 2>$null }
        }
        Write-Success "OCD removed"
    }
    
    # Remove OpenChamber Core
    Write-Info "Removing OpenChamber Core..."
    if (Test-Command "openchamber") {
        switch ($pm) {
            "bun" { bun uninstall -g $CORE_PKG 2>$null }
            "pnpm" { pnpm remove -g $CORE_PKG 2>$null }
            "npm" { npm uninstall -g $CORE_PKG 2>$null }
        }
        
        # Also remove binary directly
        $ocPath = (Get-Command openchamber -ErrorAction SilentlyContinue).Source
        if ($ocPath) {
            Remove-Item $ocPath -Force
        }
    }
    Write-Success "OpenChamber Core removed"
    
    # Remove shortcuts
    Write-Info "Removing desktop shortcuts..."
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    Remove-Item "$desktopPath\$APP_NAME.lnk" -Force
    
    $startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
    Remove-Item "$startMenuPath\$APP_NAME.lnk" -Force
    Write-Success "Shortcuts removed"
    
    # Remove config
    Write-Info "Removing configuration..."
    Remove-Item "$env:USERPROFILE\.config\openchamber" -Recurse -Force
    Write-Success "Configuration removed"
    
    Write-Host ""
    Write-Host "=======================================" -ForegroundColor Green
    Write-Host "Uninstallation Complete!" -ForegroundColor Green
    Write-Host "=======================================" -ForegroundColor Green
    Write-Host ""
}

Main
