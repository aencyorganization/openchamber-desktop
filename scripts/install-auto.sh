#!/bin/bash

# OpenChamber Desktop - Auto Installer (Linux/macOS)
# Automatic installation with no prompts
# Usage: curl -fsSL <url> | bash

set -e

APP_NAME="OpenChamber Desktop"
PKG_NAME="openchamber-desktop"
CORE_PKG="@openchamber/web"
REPO_URL="https://github.com/aencyorganization/openchamber-desktop"

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

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get OS
get_os() {
    uname -s
}

# Install Bun
install_bun() {
    log "Installing Bun package manager..."
    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    success "Bun installed"
}

# Detect or install package manager
setup_package_manager() {
    log "Checking package manager..."
    
    if command_exists bun; then
        success "Bun found"
        PM="bun"
    elif command_exists pnpm; then
        success "pnpm found"
        PM="pnpm"
    elif command_exists npm; then
        success "npm found"
        PM="npm"
    else
        log "No package manager found, installing Bun..."
        install_bun
        PM="bun"
    fi
    
    export PM
}

# Install OpenChamber Core only if not present
install_openchamber() {
    log "Checking OpenChamber Core..."
    
    if command_exists openchamber; then
        warn "OpenChamber already installed via system package manager"
        log "Skipping OpenChamber installation to avoid conflicts"
        return 0
    fi
    
    log "Installing OpenChamber Core..."
    curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash
    success "OpenChamber Core installed"
}

# Install or update OCD
install_ocd() {
    log "Checking OpenChamber Desktop..."
    
    if command_exists $PKG_NAME; then
        warn "OCD already installed, updating..."
    fi
    
    log "Installing OCD via $PM..."
    case "$PM" in
        bun) bun install -g $PKG_NAME ;;
        pnpm) pnpm add -g $PKG_NAME ;;
        npm) npm install -g $PKG_NAME ;;
    esac
    success "OCD installed/updated"
}

# Create shell aliases
create_aliases() {
    log "Creating shell aliases..."
    
    local shell_config=""
    if [ -f "$HOME/.zshrc" ]; then
        shell_config="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        shell_config="$HOME/.bashrc"
    fi
    
    if [ -n "$shell_config" ]; then
        # Add ocd alias if not exists
        if ! grep -q "alias ocd=" "$shell_config" 2>/dev/null; then
            echo "alias ocd='$PKG_NAME'" >> "$shell_config"
            success "Alias 'ocd' added"
        fi
        
        # Add openchamber-desktop alias if not exists
        if ! grep -q "alias openchamber-desktop=" "$shell_config" 2>/dev/null; then
            echo "alias openchamber-desktop='$PKG_NAME'" >> "$shell_config"
            success "Alias 'openchamber-desktop' added"
        fi
    fi
}

# Create desktop shortcuts
create_shortcuts() {
    log "Creating desktop shortcuts..."
    
    local os=$(get_os)
    local icon_dir="$HOME/.config/openchamber"
    local icon_path="$icon_dir/icon.png"
    
    mkdir -p "$icon_dir"
    
    # Download icon
    if [ ! -f "$icon_path" ]; then
        curl -fsSL "https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/assets/openchamber-logo-dark.png" -o "$icon_path" 2>/dev/null || true
    fi
    
    if [ "$os" = "Linux" ]; then
        local desktop_path="$HOME/.local/share/applications/ocd.desktop"
        mkdir -p "$(dirname "$desktop_path")"
        
        cat > "$desktop_path" <<EOF
[Desktop Entry]
Name=$APP_NAME
Comment=OpenChamber Desktop Launcher
Exec=$PKG_NAME
Icon=$icon_path
Terminal=false
Type=Application
Categories=Development;Utility;
StartupNotify=false
EOF
        chmod +x "$desktop_path"
        success "Linux desktop entry created"
        
    elif [ "$os" = "Darwin" ]; then
        local app_path="$HOME/Applications/$APP_NAME.app"
        mkdir -p "$app_path/Contents/MacOS"
        mkdir -p "$app_path/Contents/Resources"
        
        cat > "$app_path/Contents/MacOS/launcher" <<'EOF'
#!/bin/bash
export PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/.bun/bin:$PATH"
exec openchamber-desktop
EOF
        chmod +x "$app_path/Contents/MacOS/launcher"
        
        cat > "$app_path/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIconFile</key>
    <string>icon.png</string>
    <key>CFBundleIdentifier</key>
    <string>com.openchamber.desktop</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
</dict>
</plist>
EOF
        
        [ -f "$icon_path" ] && cp "$icon_path" "$app_path/Contents/Resources/icon.png"
        success "macOS app bundle created"
    fi
}

# Main installation
main() {
    echo ""
    echo -e "${CYAN}OpenChamber Desktop - Auto Installer${NC}"
    echo -e "${CYAN}=====================================${NC}"
    echo ""
    
    setup_package_manager
    install_openchamber
    install_ocd
    create_aliases
    create_shortcuts
    
    echo ""
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}Installation Complete!${NC}"
    echo -e "${GREEN}=====================================${NC}"
    echo ""
    echo -e "Run: ${CYAN}ocd${NC} or ${CYAN}openchamber-desktop${NC}"
    echo ""
    
    # Show next steps
    if [ -f "$HOME/.zshrc" ] || [ -f "$HOME/.bashrc" ]; then
        echo -e "${YELLOW}Note:${NC} Run ${CYAN}source ~/.bashrc${NC} or ${CYAN}source ~/.zshrc${NC} to use aliases immediately"
        echo ""
    fi
}

main
