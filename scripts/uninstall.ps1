# OpenChamber Desktop - Uninstall Script for Windows
# Completely removes OpenChamber Desktop from the system
# Usage: irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.ps1 | iex

param(
    [switch]$Silent,
    [switch]$KeepConfig
)

$ErrorActionPreference = "Stop"

$AppName = "OpenChamber Desktop"
$PkgName = "openchamber-desktop"

function Write-Info($Message) {
    Write-Host "[OCD-UNINSTALL] $Message" -ForegroundColor Cyan
}

function Write-Success($Message) {
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn($Message) {
    Write-Host "[!] $Message" -ForegroundColor Yellow
}

function Test-Command($Command) {
    return [bool](Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

# Stop processes
function Stop-Processes {
    Write-Info "Stopping all OpenChamber processes..."
    
    $Processes = Get-Process | Where-Object { 
        $_.Name -like "*openchamber*" -or 
        $_.Name -like "*neutralino*" -or
        $_.ProcessName -like "*openchamber*"
    }
    
    foreach ($Process in $Processes) {
        try {
            Stop-Process -Id $Process.Id -Force -ErrorAction SilentlyContinue
            Write-Info "Stopped: $($Process.Name) (PID: $($Process.Id))"
        }
        catch {
            Write-Warn "Could not stop: $($Process.Name)"
        }
    }
    
    Start-Sleep -Seconds 1
    Write-Success "Processes stopped"
}

# Uninstall packages
function Uninstall-Packages {
    Write-Info "Uninstalling packages..."
    
    $PackageManagers = @("bun", "pnpm", "yarn", "npm")
    
    foreach ($PM in $PackageManagers) {
        if (Test-Command $PM) {
            Write-Info "Checking $PM..."
            
            switch ($PM) {
                "bun" {
                    bun remove -g $PkgName 2>$null
                    bun remove -g "@openchamber/web" 2>$null
                    bun remove -g "openchamber" 2>$null
                }
                "pnpm" {
                    pnpm remove -g $PkgName 2>$null
                    pnpm remove -g "@openchamber/web" 2>$null
                    pnpm remove -g "openchamber" 2>$null
                }
                "yarn" {
                    yarn global remove $PkgName 2>$null
                    yarn global remove "@openchamber/web" 2>$null
                    yarn global remove "openchamber" 2>$null
                }
                "npm" {
                    npm uninstall -g $PkgName 2>$null
                    npm uninstall -g "@openchamber/web" 2>$null
                    npm uninstall -g "openchamber" 2>$null
                }
            }
        }
    }
    
    Write-Success "Packages uninstalled"
}

# Remove shortcuts
function Remove-Shortcuts {
    Write-Info "Removing shortcuts..."
    
    $ShortcutPaths = @(
        "$env:USERPROFILE\Desktop\OpenChamber Desktop.lnk"
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\OpenChamber Desktop.lnk"
    )
    
    foreach ($Path in $ShortcutPaths) {
        if (Test-Path $Path) {
            Remove-Item $Path -Force
            Write-Info "Removed: $Path"
        }
    }
    
    Write-Success "Shortcuts removed"
}

# Remove configs
function Remove-Configs {
    if ($KeepConfig) {
        Write-Warn "Skipping config removal (--KeepConfig specified)"
        return
    }
    
    Write-Info "Removing configurations..."
    
    $ConfigPaths = @(
        "$env:APPDATA\openchamber"
        "$env:LOCALAPPDATA\openchamber-desktop"
        "$env:USERPROFILE\.config\openchamber"
    )
    
    foreach ($Path in $ConfigPaths) {
        if (Test-Path $Path) {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Info "Removed: $Path"
        }
    }
    
    Write-Success "Configurations removed"
}

# Remove from PATH
function Remove-FromPath {
    Write-Info "Cleaning PATH entries..."
    
    $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $PathsToRemove = @(
        "$env:USERPROFILE\.bun\bin"
        "$env:LOCALAPPDATA\pnpm"
    )
    
    $NewPath = $CurrentPath
    foreach ($Path in $PathsToRemove) {
        $NewPath = $NewPath -replace [regex]::Escape($Path), ""
        $NewPath = $NewPath -replace ";;", ";"
    }
    
    if ($NewPath -ne $CurrentPath) {
        [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
        Write-Success "PATH cleaned"
    }
}

# Main
function Main {
    Write-Host ""
    Write-Host "OpenChamber Desktop - Uninstall for Windows" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
    Write-Host ""
    
    if (-not $Silent) {
        Write-Warn "This will completely remove $AppName from your system!"
        $Confirm = Read-Host "Are you sure? Type 'yes' to continue"
        
        if ($Confirm -ne "yes") {
            Write-Host "Uninstall canceled."
            exit 0
        }
    }
    
    Stop-Processes
    Uninstall-Packages
    Remove-Shortcuts
    Remove-Configs
    Remove-FromPath
    
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "Uninstall Completed!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "$AppName has been completely removed." -ForegroundColor Green
    Write-Host ""
    
    if (-not $KeepConfig) {
        Write-Host "Note: You may want to restart your computer to complete the uninstallation." -ForegroundColor Yellow
    }
}

Main
