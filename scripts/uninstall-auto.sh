#!/bin/bash

# OpenChamber Desktop - Auto Uninstaller (Linux/macOS)
# Removes everything automatically
# Usage: curl -fsSL <url> | bash

set -e

PKG_NAME="openchamber-desktop"
CORE_PKG="@openchamber/web"
APP_NAME="OpenChamber Desktop"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${CYAN}[OCD]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get package manager
get_package_manager() {
    if command_exists bun; then
        echo "bun"
    elif command_exists pnpm; then
        echo "pnpm"
    elif command_exists npm; then
        echo "npm"
    else
        echo ""
    fi
}

# Main uninstall
main() {
    echo ""
    echo -e "${CYAN}OpenChamber Desktop - Auto Uninstaller${NC}"
    echo -e "${CYAN}=======================================${NC}"
    echo ""
    
    local pm=$(get_package_manager)
    
    # Remove OCD
    if [ -n "$pm" ]; then
        log "Removing OpenChamber Desktop..."
        case "$pm" in
            bun) bun uninstall -g $PKG_NAME 2>/dev/null || true ;;
            pnpm) pnpm remove -g $PKG_NAME 2>/dev/null || true ;;
            npm) npm uninstall -g $PKG_NAME 2>/dev/null || true ;;
        esac
        success "OCD removed"
    fi
    
    # Remove OpenChamber Core
    log "Removing OpenChamber Core..."
    if command_exists openchamber; then
        # Try to uninstall via package manager first
        case "$pm" in
            bun) bun uninstall -g $CORE_PKG 2>/dev/null || true ;;
            pnpm) pnpm remove -g $CORE_PKG 2>/dev/null || true ;;
            npm) npm uninstall -g $CORE_PKG 2>/dev/null || true ;;
        esac
        
        # Also try to remove binary directly
        rm -f "$(which openchamber 2>/dev/null)" 2>/dev/null || true
    fi
    success "OpenChamber Core removed"
    
    # Remove shortcuts
    log "Removing desktop shortcuts..."
    local os=$(uname -s)
    if [ "$os" = "Linux" ]; then
        rm -f "$HOME/.local/share/applications/ocd.desktop"
    elif [ "$os" = "Darwin" ]; then
        rm -rf "$HOME/Applications/$APP_NAME.app"
    fi
    success "Shortcuts removed"
    
    # Remove aliases
    log "Removing shell aliases..."
    local shell_config=""
    if [ -f "$HOME/.zshrc" ]; then
        shell_config="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        shell_config="$HOME/.bashrc"
    fi
    
    if [ -n "$shell_config" ]; then
        sed -i.bak '/alias ocd=/d' "$shell_config" 2>/dev/null || true
        sed -i.bak '/alias openchamber-desktop=/d' "$shell_config" 2>/dev/null || true
        rm -f "${shell_config}.bak" 2>/dev/null || true
        success "Aliases removed"
    fi
    
    # Remove config
    log "Removing configuration..."
    rm -rf "$HOME/.config/openchamber" 2>/dev/null || true
    success "Configuration removed"
    
    echo ""
    echo -e "${GREEN}=======================================${NC}"
    echo -e "${GREEN}Uninstallation Complete!${NC}"
    echo -e "${GREEN}=======================================${NC}"
    echo ""
}

main
