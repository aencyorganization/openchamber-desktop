# OpenChamber Desktop - Universal Installer (Windows)
# Run with: irm https://github.com/aencyorganization/openchamber-desktop/raw/main/scripts/install-all.ps1 | iex

$AppName = "OpenChamber Desktop"
$AppPackage = "openchamber-desktop"
$BunInstallUrl = "https://bun.sh/install"

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

function Install-Bun {
    if (Get-Command bun -ErrorAction SilentlyContinue) {
        Write-Success "Bun is already installed ($(bun --version))"
        return
    }
    
    Write-Status "Installing Bun..."
    try {
        powershell -c "irm $BunInstallUrl|iex"
        
        # Add to PATH for current session
        $env:BUN_INSTALL = "$env:USERPROFILE\.bun"
        $env:PATH = "$env:BUN_INSTALL\bin;$env:PATH"
        
        if (Get-Command bun -ErrorAction SilentlyContinue) {
            Write-Success "Bun installed successfully ($(bun --version))"
        } else {
            throw "Bun not found after installation"
        }
    } catch {
        Write-Error "Bun installation failed. Please install manually from: $BunInstallUrl"
        exit 1
    }
}

function Install-App {
    Write-Status "Installing $AppName via Bun..."
    
    try {
        if (Get-Command openchamber-desktop -ErrorAction SilentlyContinue) {
            Write-Warning "$AppName is already installed. Updating..."
            bun install -g $AppPackage --force
        } else {
            bun install -g $AppPackage
        }
        
        Write-Success "$AppName installed successfully!"
    } catch {
        Write-Error "Installation failed. Trying with npm..."
        npm install -g $AppPackage
    }
}

function Create-SystemIntegration {
    Write-Status "Creating Windows system integration..."
    
    # Find bun bin directory
    $BunBin = "$env:USERPROFILE\.bun\bin"
    $AppExe = "$BunBin\openchamber-desktop.exe"
    
    if (-not (Test-Path $AppExe)) {
        $AppExe = (Get-Command openchamber-desktop).Source
    }
    
    # Create Start Menu shortcut
    $StartMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$AppName.lnk"
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($StartMenuPath)
    $Shortcut.TargetPath = $AppExe
    $Shortcut.WorkingDirectory = "$env:USERPROFILE"
    $Shortcut.Description = "$AppName (Unofficial)"
    $Shortcut.Save()
    
    Write-Success "Created Start Menu shortcut"
    
    # Ask for Desktop shortcut
    $createDesktop = Read-Host "Create Desktop shortcut? (y/N)"
    if ($createDesktop -eq 'y' -or $createDesktop -eq 'Y') {
        $DesktopPath = "$env:USERPROFILE\Desktop\$AppName.lnk"
        $Shortcut2 = $WshShell.CreateShortcut($DesktopPath)
        $Shortcut2.TargetPath = $AppExe
        $Shortcut2.WorkingDirectory = "$env:USERPROFILE"
        $Shortcut2.Description = "$AppName (Unofficial)"
        $Shortcut2.Save()
        Write-Success "Created Desktop shortcut"
    }
    
    Write-Success "You can now find $AppName in your Start Menu!"
}

# Main
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  $AppName - Universal Installer" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Install-Bun
Install-App
Create-SystemIntegration

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Success "Installation complete!"
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now run:"
Write-Host "  openchamber-desktop    (or just: ocd)" -ForegroundColor Green
Write-Host ""
Write-Host "To uninstall later, run:"
Write-Host "  openchamber-desktop --uninstall-all" -ForegroundColor Yellow
Write-Host ""
