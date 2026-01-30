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

# Robust command check - verifies command exists AND works
function Test-CommandWorks($cmd) {
    # Check if command exists
    $command = Get-Command -Name $cmd -ErrorAction SilentlyContinue
    if (-not $command) {
        return $false
    }
    
    # Verify it actually runs by checking version
    try {
        switch ($cmd) {
            "bun" { 
                $version = & bun --version 2>$null
                return ($version -match "\d+\.\d+\.\d+")
            }
            "pnpm" { 
                $version = & pnpm --version 2>$null
                return ($version -match "\d+\.\d+\.\d+")
            }
            "npm" { 
                $version = & npm --version 2>$null
                return ($version -match "\d+\.\d+\.\d+")
            }
            "openchamber" { 
                $version = & openchamber --version 2>$null
                return ($version -match "\d+\.\d+")
            }
            default { return $true }
        }
    } catch {
        return $false
    }
}

# Check if Bun is properly installed with priority
def Check-Bun {
    # Check if bun command works
    if (Test-CommandWorks "bun") {
        $version = & bun --version 2>$null
        Write-Info "Bun detected: version $version"
        return $true
    }
    
    # Check common Bun locations
    $bunPaths = @(
        "$env:USERPROFILE\.bun\bin\bun.exe"
        "$env:USERPROFILE\.bun\bin\bun.cmd"
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Bun\bun.exe"
    )
    
    foreach ($path in $bunPaths) {
        if (Test-Path $path) {
            # Add to PATH for this session
            $env:PATH += ";$(Split-Path $path)"
            if (Test-CommandWorks "bun") {
                Write-Info "Bun found at: $path"
                return $true
            }
        }
    }
    
    return $false
}

# Install Bun
function Install-Bun {
    Write-Info "Installing Bun package manager..."
    try {
        powershell -Command "irm bun.sh/install.ps1 | iex"
        $env:PATH += ";$env:USERPROFILE\.bun\bin"
        # Verify installation
        if (-not (Test-CommandWorks "bun")) {
            throw "Bun installation verification failed"
        }
        Write-Success "Bun installed"
    } catch {
        Write-Error "Failed to install Bun: $_"
        throw
    }
}

# Detect or install package manager - PRIORITY: Bun > pnpm > npm
function Setup-PackageManager {
    Write-Info "Detecting package manager (priority: Bun > pnpm > npm)..."
    
    # Priority 1: Bun (check thoroughly)
    if (Check-Bun) {
        Write-Success "Bun selected (priority 1)"
        return "bun"
    }
    
    # Priority 2: pnpm
    if (Test-CommandWorks "pnpm") {
        $version = & pnpm --version 2>$null
        Write-Success "pnpm selected (priority 2) - version $version"
        return "pnpm"
    }
    
    # Priority 3: npm
    if (Test-CommandWorks "npm") {
        $version = & npm --version 2>$null
        Write-Success "npm selected (priority 3) - version $version"
        return "npm"
    }
    
    # None found, install Bun
    Write-Info "No working package manager found, installing Bun..."
    Install-Bun
    return "bun"
}

# Robust check for OpenChamber
def Check-OpenChamber {
    # Check if openchamber command exists and works
    if (-not (Test-CommandWorks "openchamber")) {
        return $false
    }
    
    # Get version to confirm it's really working
    try {
        $version = & openchamber --version 2>$null
        if ($version) {
            Write-Info "OpenChamber detected: $version"
            return $true
        }
    } catch {
        return $false
    }
    
    return $false
}

# Install OpenChamber Core only if not present
function Install-OpenChamber($pm) {
    Write-Info "Checking OpenChamber Core..."
    
    if (Check-OpenChamber) {
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
