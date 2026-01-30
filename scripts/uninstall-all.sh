#!/bin/bash

# OpenChamber Desktop - Universal Uninstaller
# This script removes the app and system integration but keeps Bun

set -e

APP_NAME="OpenChamber Desktop"
APP_PACKAGE="openchamber-desktop"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     OS=Linux;;
        Darwin*)    OS=Mac;;
        CYGWIN*|MINGW*|MSYS*) OS=Windows;;
        *)          OS=Unknown;;
    esac
    print_status "Detected OS: $OS"
}

# Remove system integration
remove_system_integration() {
    print_status "Removing system integration..."
    
    case "$OS" in
        Linux)
            remove_linux_integration
            ;;
        Mac)
            remove_mac_integration
            ;;
        Windows)
            print_warning "On Windows, please run the uninstaller from PowerShell:"
            print_warning "  irm https://github.com/aencyorganization/openchamber-desktop/raw/main/scripts/uninstall-all.ps1 | iex"
            ;;
        *)
            print_warning "Unknown OS. System integration may not be fully removed."
            ;;
    esac
}

# Remove Linux integration
remove_linux_integration() {
    print_status "Removing Linux desktop entry..."
    
    DESKTOP_FILE="$HOME/.local/share/applications/openchamber-desktop.desktop"
    
    if [ -f "$DESKTOP_FILE" ]; then
        rm "$DESKTOP_FILE"
        print_success "Removed desktop entry"
    else
        print_warning "Desktop entry not found"
    fi
    
    # Update desktop database
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
}

# Remove macOS integration
remove_mac_integration() {
    print_status "Removing macOS integration..."
    
    APP_LINK="$HOME/Applications/OpenChamber Desktop"
    
    if [ -L "$APP_LINK" ]; then
        rm "$APP_LINK"
        print_success "Removed Applications symlink"
    else
        print_warning "Applications symlink not found"
    fi
}

# Uninstall the app
uninstall_app() {
    print_status "Uninstalling $APP_NAME..."
    
    # Try bun first
    if command -v bun >/dev/null 2>&1; then
        print_status "Removing via Bun..."
        bun remove -g "$APP_PACKAGE" 2>/dev/null || true
    fi
    
    # Try npm as fallback
    if command -v npm >/dev/null 2>&1; then
        print_status "Removing via npm..."
        npm uninstall -g "$APP_PACKAGE" 2>/dev/null || true
    fi
    
    # Try pnpm as fallback
    if command -v pnpm >/dev/null 2>&1; then
        print_status "Removing via pnpm..."
        pnpm remove -g "$APP_PACKAGE" 2>/dev/null || true
    fi
    
    # Check if still installed
    if command -v openchamber-desktop >/dev/null 2>&1; then
        print_warning "App may still be installed. Manual removal may be required."
    else
        print_success "$APP_NAME uninstalled successfully!"
    fi
}

# Main uninstall flow
main() {
    echo "=========================================="
    echo "  $APP_NAME - Universal Uninstaller"
    echo "=========================================="
    echo ""
    
    detect_os
    
    if [ "$OS" = "Windows" ]; then
        print_error "For Windows, please use PowerShell:"
        print_error "  irm https://github.com/aencyorganization/openchamber-desktop/raw/main/scripts/uninstall-all.ps1 | iex"
        exit 1
    fi
    
    # Confirm uninstallation
    echo "This will remove $APP_NAME and all system integration."
    echo "Bun will NOT be removed."
    echo ""
    read -p "Are you sure? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Uninstallation cancelled."
        exit 0
    fi
    
    remove_system_integration
    uninstall_app
    
    echo ""
    echo "=========================================="
    print_success "Uninstallation complete!"
    echo "=========================================="
    echo ""
    echo "Note: Bun was kept installed."
    echo "To remove Bun manually, delete: ~/.bun"
    echo ""
}

main "$@"
