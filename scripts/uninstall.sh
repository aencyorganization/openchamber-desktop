#!/bin/bash
#
# OpenChamber Desktop - Uninstall Script
# Completely removes OpenChamber Desktop from the system
# Usage: curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.sh | bash
#

set -e

APP_NAME="OpenChamber Desktop"
PKG_NAME="openchamber-desktop"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[OCD-UNINSTALL]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Stop processes
stop_processes() {
    log "Stopping all OpenChamber processes..."
    pkill -f "openchamber" 2>/dev/null || true
    pkill -f "neutralino" 2>/dev/null || true
    sleep 1
    success "Processes stopped"
}

# Uninstall packages
uninstall_packages() {
    log "Uninstalling packages..."
    
    # Try all package managers
    if command -v bun >/dev/null 2>&1; then
        bun remove -g "$PKG_NAME" 2>/dev/null || true
        bun remove -g "@openchamber/web" 2>/dev/null || true
        bun remove -g "openchamber" 2>/dev/null || true
    fi
    
    if command -v pnpm >/dev/null 2>&1; then
        pnpm remove -g "$PKG_NAME" 2>/dev/null || true
        pnpm remove -g "@openchamber/web" 2>/dev/null || true
        pnpm remove -g "openchamber" 2>/dev/null || true
    fi
    
    if command -v yarn >/dev/null 2>&1; then
        yarn global remove "$PKG_NAME" 2>/dev/null || true
        yarn global remove "@openchamber/web" 2>/dev/null || true
        yarn global remove "openchamber" 2>/dev/null || true
    fi
    
    if command -v npm >/dev/null 2>&1; then
        npm uninstall -g "$PKG_NAME" 2>/dev/null || true
        npm uninstall -g "@openchamber/web" 2>/dev/null || true
        npm uninstall -g "openchamber" 2>/dev/null || true
    fi
    
    success "Packages uninstalled"
}

# Remove shortcuts
remove_shortcuts() {
    log "Removing shortcuts..."
    
    rm -f "$HOME/.local/share/applications/openchamber-desktop.desktop" 2>/dev/null || true
    rm -f "$HOME/.local/share/applications/ocd.desktop" 2>/dev/null || true
    rm -f "$HOME/Desktop/OpenChamber Desktop.lnk" 2>/dev/null || true
    rm -rf "$HOME/Applications/OpenChamber Desktop.app" 2>/dev/null || true
    
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    fi
    
    success "Shortcuts removed"
}

# Remove configs
remove_configs() {
    log "Removing configurations..."
    
    rm -rf "$HOME/.config/openchamber" 2>/dev/null || true
    rm -rf "$HOME/.local/share/openchamber-desktop" 2>/dev/null || true
    rm -rf "$HOME/.local/lib/openchamber-desktop" 2>/dev/null || true
    rm -rf "/opt/openchamber-desktop" 2>/dev/null || true
    
    # Remove aliases
    for config in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$config" ]; then
            sed -i.bak '/alias ocd=/d' "$config" 2>/dev/null || true
            sed -i.bak '/alias openchamber-desktop=/d' "$config" 2>/dev/null || true
        fi
    done
    
    success "Configurations removed"
}

# Clear cache
clear_cache() {
    log "Clearing cache..."
    
    rm -rf "$HOME/.cache/menus"/* 2>/dev/null || true
    rm -f "$HOME/.cache/icon-cache.kcache" 2>/dev/null || true
    rm -rf "$HOME/.cache/ksycoca5"* 2>/dev/null || true
    
    if command -v kbuildsycoca5 >/dev/null 2>&1; then
        kbuildsycoca5 --noincremental 2>/dev/null || true
    fi
    
    success "Cache cleared"
}

# Main
main() {
    echo ""
    echo -e "${BOLD}${RED}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${RED}║${NC}  ${RED}OpenChamber Desktop - Uninstall${NC}                      ${BOLD}${RED}║${NC}"
    echo -e "${BOLD}${RED}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    warn "This will completely remove $APP_NAME from your system!"
    read -p "Are you sure? Type 'yes' to continue: " confirm
    
    if [ "$confirm" != "yes" ]; then
        echo "Uninstall canceled."
        exit 0
    fi
    
    stop_processes
    uninstall_packages
    remove_shortcuts
    remove_configs
    clear_cache
    
    echo ""
    echo -e "${GREEN}============================================================${NC}"
    echo -e "${GREEN}Uninstall Completed!${NC}"
    echo -e "${GREEN}============================================================${NC}"
    echo ""
    echo -e "${GREEN}$APP_NAME has been completely removed.${NC}"
    echo ""
}

main "$@"
