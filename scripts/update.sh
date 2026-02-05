#!/bin/bash
#
# OpenChamber Desktop - Configuration Update
# Cleans old configs and migrates to new version
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
    echo -e "${BLUE}[OCD-UPDATE]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
}

info() {
    echo -e "${CYAN}[i]${NC} $1"
}

header() {
    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}$1${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ============================================
# CLEANUP OLD CONFIGS
# ============================================
cleanup_old_configs() {
    header "CLEANING OLD CONFIGURATIONS"
    
    # Stop processes
    log "Stopping processes..."
    pkill -f "openchamber" 2>/dev/null || true
    pkill -f "neutralino" 2>/dev/null || true
    sleep 1
    
    # Clean saved configs
    log "Cleaning saved configurations..."
    
    rm -rf "$HOME/.config/openchamber" 2>/dev/null || true
    rm -rf "$HOME/.local/share/openchamber-desktop" 2>/dev/null || true
    
    if [ -d "$HOME/.config/Neutralinojs" ]; then
        rm -rf "$HOME/.config/Neutralinojs"/*openchamber* 2>/dev/null || true
    fi
    
    success "Old configurations cleaned"
}

# ============================================
# REINSTALL PACKAGE
# ============================================
reinstall_package() {
    header "REINSTALLING PACKAGE"
    
    log "Checking current installation..."
    
    # Detect package manager
    if command -v bun >/dev/null 2>&1; then
        PM="bun"
    elif command -v pnpm >/dev/null 2>&1; then
        PM="pnpm"
    elif command -v yarn >/dev/null 2>&1; then
        PM="yarn"
    elif command -v npm >/dev/null 2>&1; then
        PM="npm"
    else
        error "No package manager found!"
        exit 1
    fi
    
    success "Package manager: $PM"
    
    # Reinstall
    log "Reinstalling $PKG_NAME..."
    case "$PM" in
        bun)
            bun remove -g "$PKG_NAME" 2>/dev/null || true
            bun install -g "$PKG_NAME"
            ;;
        pnpm)
            pnpm remove -g "$PKG_NAME" 2>/dev/null || true
            pnpm add -g "$PKG_NAME"
            ;;
        yarn)
            yarn global remove "$PKG_NAME" 2>/dev/null || true
            yarn global add "$PKG_NAME"
            ;;
        npm)
            npm uninstall -g "$PKG_NAME" 2>/dev/null || true
            npm install -g "$PKG_NAME"
            ;;
    esac
    
    success "Package reinstalled"
}

# ============================================
# RECREATE DESKTOP ENTRY
# ============================================
recreate_desktop_entry() {
    header "RECREATING DESKTOP ENTRY"
    
    local desktop_dir="$HOME/.local/share/applications"
    local desktop_file="$desktop_dir/openchamber-desktop.desktop"
    local icon_dir="$HOME/.local/share/icons/hicolor/256x256/apps"
    
    rm -f "$desktop_file" 2>/dev/null || true
    rm -f "$desktop_dir/ocd.desktop" 2>/dev/null || true
    
    mkdir -p "$desktop_dir"
    mkdir -p "$icon_dir"
    
    # Download icon
    log "Downloading icon..."
    curl -fsSL "https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/assets/openchamber-logo-dark.png" -o "$icon_dir/openchamber-desktop.png" 2>/dev/null || true
    
    # Detect architecture
    local arch=$(uname -m)
    local wm_class
    case "$arch" in
        x86_64) wm_class="neutralino-linux_x64" ;;
        aarch64|arm64) wm_class="neutralino-linux_arm64" ;;
        armv7l|armhf) wm_class="neutralino-linux_armhf" ;;
        *) wm_class="neutralino-linux_x64" ;;
    esac
    
    # Create entry
    log "Creating new desktop entry..."
    cat > "$desktop_file" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=OpenChamber Desktop - AI Coding Assistant
Exec=$PKG_NAME
Icon=openchamber-desktop
Terminal=false
Categories=Development;IDE;Utility;
Keywords=openchamber;opencode;ai;coding;ocd;
StartupNotify=true
StartupWMClass=$wm_class
X-GNOME-SingleWindow=true
X-KDE-StartupNotify=true
TryExec=$PKG_NAME
X-Desktop-File-Install-Version=0.26
EOF
    
    chmod +x "$desktop_file"
    
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$desktop_dir" 2>/dev/null || true
    fi
    
    success "Desktop entry recreated"
}

# ============================================
# CLEAR CACHE
# ============================================
clear_cache() {
    header "CLEARING CACHE"
    
    rm -rf "$HOME/.cache/menus"/* 2>/dev/null || true
    rm -f "$HOME/.cache/icon-cache.kcache" 2>/dev/null || true
    rm -rf "$HOME/.cache/ksycoca5"* 2>/dev/null || true
    
    if command -v kbuildsycoca5 >/dev/null 2>&1; then
        log "Rebuilding KDE cache..."
        kbuildsycoca5 --noincremental 2>/dev/null || true
    fi
    
    success "Cache cleared"
}

# ============================================
# FINISH
# ============================================
finish() {
    header "UPDATE COMPLETED!"
    
    echo -e "${GREEN}$APP_NAME has been successfully updated!${NC}"
    echo ""
    echo -e "${BOLD}${CYAN}WHAT WAS DONE:${NC}"
    echo "  ✓ Old configurations removed"
    echo "  ✓ Package reinstalled with fixes"
    echo "  ✓ Desktop entry recreated"
    echo "  ✓ Cache cleared"
    echo ""
    echo -e "${BOLD}${CYAN}NEXT STEPS:${NC}"
    echo ""
    echo -e "${YELLOW}1. REMOVE OLD ICONS FROM DOCK:${NC}"
    echo "   Right-click on icon → 'Remove'"
    echo ""
    echo -e "${YELLOW}2. OPEN FROM MENU:${NC}"
    echo "   Alt+F2 → type 'OpenChamber'"
    echo ""
    echo -e "${YELLOW}3. PIN THE NEW ICON:${NC}"
    echo "   Right-click on taskbar → 'Pin'"
    echo ""
    echo -e "${CYAN}The white screen issue has been fixed!${NC}"
    echo ""
}

# ============================================
# MAIN
# ============================================
main() {
    echo ""
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${GREEN}OpenChamber Desktop - Configuration Update${NC}          ${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "$OSTYPE" != "linux-gnu"* ]] && [[ "$OSTYPE" != "linux"* ]]; then
        error "This script is for Linux only!"
        exit 1
    fi
    
    read -p "Do you want to update? (y/n): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Canceled."
        exit 0
    fi
    
    cleanup_old_configs
    reinstall_package
    recreate_desktop_entry
    clear_cache
    finish
}

main "$@"
