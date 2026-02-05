# OpenChamber Desktop - One-line Installer for Windows
# Installs OpenChamber Desktop on Windows
# Usage: irm https://get.openchamber.io/win | iex

param(
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# Configuration
$AppName = "OpenChamber Desktop"
$PkgName = "openchamber-desktop"
$CorePkg = "@openchamber/web"
$RepoUrl = "https://github.com/aencyorganization/openchamber-desktop"

# Colors for PowerShell
function Write-Info($Message) {
    Write-Host "[OCD] $Message" -ForegroundColor Cyan
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

# Test if command exists
function Test-Command($Command) {
    return [bool](Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

# Setup package manager (priority: Bun > pnpm > yarn > npm)
function Setup-PackageManager {
    Write-Info "Detecting package manager (priority: Bun > pnpm > yarn > npm)..."
    
    # Check Bun
    if (Test-Command "bun") {
        $version = (bun --version 2>$null)
        if ($version) {
            Write-Success "Bun selected (priority 1) - version $version"
            return "bun"
        }
    }
    
    # Check pnpm
    if (Test-Command "pnpm") {
        $version = (pnpm --version 2>$null)
        if ($version) {
            Write-Success "pnpm selected (priority 2) - version $version"
            return "pnpm"
        }
    }
    
    # Check yarn
    if (Test-Command "yarn") {
        $version = (yarn --version 2>$null)
        if ($version) {
            Write-Success "yarn selected (priority 3) - version $version"
            return "yarn"
        }
    }
    
    # Check npm
    if (Test-Command "npm") {
        $version = (npm --version 2>$null)
        if ($version) {
            Write-Success "npm selected (priority 4) - version $version"
            return "npm"
        }
    }
    
    # Install Bun if nothing found
    Write-Info "No package manager found. Installing Bun..."
    try {
        powershell -c "irm bun.sh/install.ps1 | iex"
        Write-Success "Bun installed"
        return "bun"
    }
    catch {
        Write-Error "Failed to install Bun. Please install Node.js manually."
        exit 1
    }
}

# Install OpenChamber Core
function Install-OpenChamberCore {
    param($PM)
    
    Write-Info "Installing OpenChamber Core..."
    
    switch ($PM) {
        "bun" { bun add -g $CorePkg }
        "pnpm" { pnpm add -g $CorePkg }
        "yarn" { yarn global add $CorePkg }
        "npm" { npm install -g $CorePkg }
    }
    
    Write-Success "OpenChamber Core installed"
}

# Install OCD
function Install-OCD {
    param($PM)
    
    Write-Info "Installing OpenChamber Desktop..."
    
    if (Test-Command $PkgName) {
        Write-Warn "$PkgName already installed, updating..."
    }
    
    switch ($PM) {
        "bun" { bun install -g $PkgName }
        "pnpm" { pnpm add -g $PkgName }
        "yarn" { yarn global add $PkgName }
        "npm" { npm install -g $PkgName }
    }
    
    Write-Success "$PkgName installed/updated"
}

# Create desktop shortcut
function Create-DesktopShortcut {
    Write-Info "Creating desktop shortcut..."
    
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\OpenChamber Desktop.lnk")
    
    # Find the executable
    $ExecPath = ""
    if (Test-Command "openchamber-desktop") {
        $ExecPath = (Get-Command "openchamber-desktop").Source
    }
    
    if (-not $ExecPath) {
        # Fallback to common locations
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
        $Shortcut.TargetPath = $ExecPath
        $Shortcut.WorkingDirectory = "$env:USERPROFILE"
        $Shortcut.IconLocation = "powershell.exe,0"
        $Shortcut.Save()
        Write-Success "Desktop shortcut created"
    }
    else {
        Write-Warn "Could not find executable for shortcut"
    }
}

# Add to PATH if needed
function Add-ToPath {
    param($PM)
    
    $PathsToAdd = @()
    
    switch ($PM) {
        "bun" { $PathsToAdd += "$env:USERPROFILE\.bun\bin" }
        "pnpm" { $PathsToAdd += "$env:LOCALAPPDATA\pnpm" }
        "yarn" { $PathsToAdd += "$env:LOCALAPPDATA\Yarn\bin" }
    }
    
    foreach ($Path in $PathsToAdd) {
        if (Test-Path $Path) {
            $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
            if ($CurrentPath -notlike "*$Path*") {
                [Environment]::SetEnvironmentVariable("Path", "$CurrentPath;$Path", "User")
                Write-Success "Added $Path to PATH"
            }
        }
    }
}

# Main
function Main {
    Write-Host ""
    Write-Host "OpenChamber Desktop - One-line Installer for Windows" -ForegroundColor Cyan
    Write-Host "====================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $PM = Setup-PackageManager
    Install-OpenChamberCore -PM $PM
    Install-OCD -PM $PM
    Add-ToPath -PM $PM
    Create-DesktopShortcut
    
    Write-Host ""
    Write-Host "====================================================" -ForegroundColor Green
    Write-Host "Installation Complete!" -ForegroundColor Green
    Write-Host "====================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Run: " -NoNewline
    Write-Host "openchamber-desktop" -ForegroundColor Cyan -NoNewline
    Write-Host " or " -NoNewline
    Write-Host "ocd" -ForegroundColor Cyan
    Write-Host ""
    
    if (-not $Silent) {
        Write-Host "Note: You may need to restart your terminal for PATH changes to take effect." -ForegroundColor Yellow
        Write-Host ""
    }
}

Main
