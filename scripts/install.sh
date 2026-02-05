#!/bin/bash
#
# OpenChamber Desktop - One-line Installer
# Installs OpenChamber Desktop with Bun (preferred) or npm
# Usage: curl -fsSL https://get.openchamber.io | bash
#

set -e

APP_NAME="OpenChamber Desktop"
PKG_NAME="openchamber-desktop"
CORE_PKG="@openchamber/web"
REPO_URL="https://github.com/aencyorganization/openchamber-desktop"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[OCD]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Check if command works
command_works() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        return 1
    fi
    case "$cmd" in
        bun) "$cmd" --version >/dev/null 2>&1 || return 1 ;;
        pnpm) "$cmd" --version >/dev/null 2>&1 || return 1 ;;
        yarn) "$cmd" --version >/dev/null 2>&1 || return 1 ;;
        npm) "$cmd" --version >/dev/null 2>&1 || return 1 ;;
        openchamber) "$cmd" --version >/dev/null 2>&1 || return 1 ;;
        *) "$cmd" --help >/dev/null 2>&1 || return 1 ;;
    esac
    return 0
}

# Detect OS
get_os() {
    uname -s
}

# Check Bun installation
check_bun() {
    local bun_paths=(
        "$HOME/.bun/bin/bun"
        "/usr/local/bin/bun"
        "/opt/homebrew/bin/bun"
    )
    
    if command_works bun; then
        local bun_version=$(bun --version 2>/dev/null)
        if [ -n "$bun_version" ]; then
            log "Bun detected: version $bun_version"
            return 0
        fi
    fi
    
    for path in "${bun_paths[@]}"; do
        if [ -x "$path" ]; then
            export PATH="$(dirname "$path"):$PATH"
            if command_works bun; then
                log "Bun found at: $path"
                return 0
            fi
        fi
    done
    
    return 1
}

# Install Bun
install_bun() {
    log "Installing Bun package manager..."
    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    success "Bun installed"
}

# Setup package manager (priority: Bun > pnpm > yarn > npm)
setup_package_manager() {
    log "Detecting package manager (priority: Bun > pnpm > yarn > npm)..."
    
    if check_bun; then
        success "Bun selected (priority 1)"
        PM="bun"
        export PM
        return 0
    fi
    
    if command_works pnpm; then
        local pnpm_version=$(pnpm --version 2>/dev/null)
        success "pnpm selected (priority 2) - version $pnpm_version"
        PM="pnpm"
        export PM
        return 0
    fi
    
    if command_works yarn; then
        local yarn_version=$(yarn --version 2>/dev/null)
        success "yarn selected (priority 3) - version $yarn_version"
        PM="yarn"
        export PM
        return 0
    fi
    
    if command_works npm; then
        local npm_version=$(npm --version 2>/dev/null)
        success "npm selected (priority 4) - version $npm_version"
        PM="npm"
        export PM
        return 0
    fi
    
    log "No working package manager found, installing Bun..."
    install_bun
    PM="bun"
    export PM
}

# Check OpenChamber Core
check_openchamber() {
    if ! command_works openchamber; then
        return 1
    fi
    
    local oc_version=$(openchamber --version 2>/dev/null | head -1)
    if [ -n "$oc_version" ]; then
        log "OpenChamber detected: $oc_version"
        return 0
    fi
    
    return 1
}

# Install OpenChamber Core
install_openchamber() {
    log "Checking OpenChamber Core..."
    
    if check_openchamber; then
        warn "OpenChamber already installed"
        log "Skipping OpenChamber installation to avoid conflicts"
        return 0
    fi
    
    log "Installing OpenChamber Core via $PM..."
    case "$PM" in
        bun)
            bun add -g $CORE_PKG
            ;;
        pnpm)
            pnpm add -g $CORE_PKG
            ;;
        yarn)
            yarn global add $CORE_PKG
            ;;
        npm)
            npm install -g $CORE_PKG
            ;;
    esac
    success "OpenChamber Core installed"
}

# Install OCD
install_ocd() {
    log "Checking OpenChamber Desktop..."
    
    if command_exists $PKG_NAME; then
        warn "$PKG_NAME already installed, updating..."
    fi
    
    log "Installing $PKG_NAME via $PM..."
    case "$PM" in
        bun) bun install -g $PKG_NAME ;;
        pnpm) pnpm add -g $PKG_NAME ;;
        yarn) yarn global add $PKG_NAME ;;
        npm) npm install -g $PKG_NAME ;;
    esac
    success "$PKG_NAME installed/updated"
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
        if ! grep -q "alias ocd=" "$shell_config" 2>/dev/null; then
            echo "alias ocd='$PKG_NAME'" >> "$shell_config"
            success "Alias 'ocd' added"
        fi
        
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
    
    if [ ! -f "$icon_path" ]; then
        curl -fsSL "https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/assets/openchamber-logo-dark.png" -o "$icon_path" 2>/dev/null || true
    fi
    
    if [ "$os" = "Linux" ]; then
        # Remove old entries
        local desktop_dir="$HOME/.local/share/applications"
        rm -f "$desktop_dir/ocd.desktop" 2>/dev/null || true
        rm -f "$desktop_dir/openchamber-desktop.desktop" 2>/dev/null || true
        
        local desktop_path="$desktop_dir/openchamber-desktop.desktop"
        mkdir -p "$(dirname "$desktop_path")"
        
        # Detect architecture for WM_CLASS
        local arch=$(uname -m)
        local wm_class
        case "$arch" in
            x86_64) wm_class="neutralino-linux_x64" ;;
            aarch64|arm64) wm_class="neutralino-linux_arm64" ;;
            armv7l|armhf) wm_class="neutralino-linux_armhf" ;;
            *) wm_class="neutralino-linux_x64" ;;
        esac
        
        cat > "$desktop_path" <<EOF
[Desktop Entry]
Name=$APP_NAME
Comment=OpenChamber Desktop Launcher
Exec=$PKG_NAME
Icon=$icon_path
Terminal=false
Type=Application
Categories=Development;Utility;
StartupNotify=true
StartupWMClass=$wm_class
TryExec=$PKG_NAME
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

# Main
main() {
    echo ""
    echo -e "${CYAN}OpenChamber Desktop - One-line Installer${NC}"
    echo -e "${CYAN}=========================================${NC}"
    echo ""
    
    setup_package_manager
    install_openchamber
    install_ocd
    create_aliases
    create_shortcuts
    
    echo ""
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}Installation Complete!${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""
    echo -e "Run: ${CYAN}ocd${NC} or ${CYAN}openchamber-desktop${NC}"
    echo ""
    
    if [ -f "$HOME/.zshrc" ] || [ -f "$HOME/.bashrc" ]; then
        echo -e "${YELLOW}Note:${NC} Run ${CYAN}source ~/.bashrc${NC} or ${CYAN}source ~/.zshrc${NC} to use aliases immediately"
        echo ""
    fi
}

main
