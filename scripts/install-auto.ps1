#!/usr/bin/env pwsh

# OpenChamber Desktop - Auto Installer (Windows)
# Automatic installation with no prompts
# Usage: irm <url> | iex

$ErrorActionPreference = "Stop"

$APP_NAME = "OpenChamber Desktop"
$PKG_NAME = "openchamber-desktop"
$CORE_PKG = "@openchamber/web"

# Colors
function Write-Info($msg) { Write-Host "[OCD] $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Error($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

# Check if command exists
function Test-Command($cmd) {
    return [bool](Get-Command -Name $cmd -ErrorAction SilentlyContinue)
}

# Install Bun
function Install-Bun {
    Write-Info "Installing Bun package manager..."
    try {
        powershell -Command "irm bun.sh/install.ps1 | iex"
        $env:PATH += ";$env:USERPROFILE\.bun\bin"
        Write-Success "Bun installed"
    } catch {
        Write-Error "Failed to install Bun: $_"
        throw
    }
}

# Detect or install package manager
function Setup-PackageManager {
    Write-Info "Checking package manager..."
    
    if (Test-Command "bun") {
        Write-Success "Bun found"
        return "bun"
    } elseif (Test-Command "pnpm") {
        Write-Success "pnpm found"
        return "pnpm"
    } elseif (Test-Command "npm") {
        Write-Success "npm found"
        return "npm"
    } else {
        Write-Info "No package manager found, installing Bun..."
        Install-Bun
        return "bun"
    }
}

# Install OpenChamber Core only if not present
function Install-OpenChamber($pm) {
    Write-Info "Checking OpenChamber Core..."
    
    if (Test-Command "openchamber") {
        Write-Warn "OpenChamber already installed via system package manager"
        Write-Info "Skipping OpenChamber installation to avoid conflicts"
        return
    }
    
    Write-Info "Installing OpenChamber Core via $pm..."
    switch ($pm) {
        "bun" { bun add -g $CORE_PKG }
        "pnpm" { pnpm add -g $CORE_PKG }
        "npm" { npm install -g $CORE_PKG }
    }
    Write-Success "OpenChamber Core installed"
}

# Install or update OCD
function Install-OCD($pm) {
    Write-Info "Checking OpenChamber Desktop..."
    
    if (Test-Command $PKG_NAME) {
        Write-Warn "OCD already installed, updating..."
    }
    
    Write-Info "Installing OCD via $pm..."
    switch ($pm) {
        "bun" { bun install -g $PKG_NAME }
        "pnpm" { pnpm add -g $PKG_NAME }
        "npm" { npm install -g $PKG_NAME }
    }
    Write-Success "OCD installed/updated"
}

# Create shortcuts
function Create-Shortcuts {
    Write-Info "Creating desktop shortcuts..."
    
    $WshShell = New-Object -ComObject WScript.Shell
    
    # Determine executable path based on package manager location
    $execPath = ""
    if (Test-Path "$env:USERPROFILE\.bun\bin\$PKG_NAME.cmd") {
        $execPath = "$env:USERPROFILE\.bun\bin\$PKG_NAME.cmd"
    } elseif (Test-Path "$env:APPDATA\npm\$PKG_NAME.cmd") {
        $execPath = "$env:APPDATA\npm\$PKG_NAME.cmd"
    } elseif (Test-Path "$env:LOCALAPPDATA\pnpm\$PKG_NAME.cmd") {
        $execPath = "$env:LOCALAPPDATA\pnpm\$PKG_NAME.cmd"
    } else {
        $execPath = "openchamber-desktop"
    }
    
    # Desktop shortcut
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcut = $WshShell.CreateShortcut("$desktopPath\$APP_NAME.lnk")
    $shortcut.TargetPath = $execPath
    $shortcut.WorkingDirectory = "$env:USERPROFILE"
    $shortcut.Description = "OpenChamber Desktop Launcher"
    
    # Try to set icon
    $iconPath = "$env:USERPROFILE\.config\openchamber\icon.ico"
    if (Test-Path $iconPath) {
        $shortcut.IconLocation = $iconPath
    }
    
    $shortcut.Save()
    Write-Success "Desktop shortcut created"
    
    # Start Menu shortcut
    $startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
    if (Test-Path $startMenuPath) {
        $shortcut2 = $WshShell.CreateShortcut("$startMenuPath\$APP_NAME.lnk")
        $shortcut2.TargetPath = $execPath
        $shortcut2.WorkingDirectory = "$env:USERPROFILE"
        $shortcut2.Description = "OpenChamber Desktop Launcher"
        if (Test-Path $iconPath) {
            $shortcut2.IconLocation = $iconPath
        }
        $shortcut2.Save()
        Write-Success "Start Menu shortcut created"
    }
}

# Download icon
function Download-Icon {
    $iconDir = "$env:USERPROFILE\.config\openchamber"
    New-Item -ItemType Directory -Force -Path $iconDir | Out-Null
    
    $iconPath = "$iconDir\icon.png"
    if (-not (Test-Path $iconPath)) {
        try {
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/assets/openchamber-logo-dark.png" -OutFile $iconPath -UseBasicParsing
        } catch {
            Write-Warn "Could not download icon"
        }
    }
}

# Main installation
function Main {
    Write-Host ""
    Write-Host "OpenChamber Desktop - Auto Installer" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    
    $pm = Setup-PackageManager
    Download-Icon
    Install-OpenChamber $pm
    Install-OCD $pm
    Create-Shortcuts
    
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "Installation Complete!" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Run: " -NoNewline
    Write-Host "ocd" -ForegroundColor Cyan -NoNewline
    Write-Host " or " -NoNewline
    Write-Host "openchamber-desktop" -ForegroundColor Cyan
    Write-Host ""
}

Main
