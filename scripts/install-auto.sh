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

# Robust command check - verifies command exists AND works
command_works() {
    local cmd="$1"
    # Check if command exists in PATH
    if ! command -v "$cmd" >/dev/null 2>&1; then
        return 1
    fi
    # Verify it actually runs (test with --version or similar)
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

# Get OS
get_os() {
    uname -s
}

# Check if Bun is properly installed and in PATH
check_bun() {
    # Check common Bun locations
    local bun_paths=(
        "$HOME/.bun/bin/bun"
        "/usr/local/bin/bun"
        "/opt/homebrew/bin/bun"
        "$HOME/.local/share/pnpm/bun"
    )
    
    # First check if bun command works
    if command_works bun; then
        # Verify it's actually bun, not something else
        local bun_version=$(bun --version 2>/dev/null)
        if [ -n "$bun_version" ]; then
            log "Bun detected: version $bun_version"
            return 0
        fi
    fi
    
    # Check specific paths
    for path in "${bun_paths[@]}"; do
        if [ -x "$path" ]; then
            # Add to PATH for this session
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

# Detect or install package manager - PRIORITY: Bun > pnpm > yarn > npm
setup_package_manager() {
    log "Detecting package manager (priority: Bun > pnpm > yarn > npm)..."
    
    # Priority 1: Bun (check thoroughly)
    if check_bun; then
        success "Bun selected (priority 1)"
        PM="bun"
        export PM
        return 0
    fi
    
    # Priority 2: pnpm
    if command_works pnpm; then
        local pnpm_version=$(pnpm --version 2>/dev/null)
        success "pnpm selected (priority 2) - version $pnpm_version"
        PM="pnpm"
        export PM
        return 0
    fi
    
    # Priority 3: yarn
    if command_works yarn; then
        local yarn_version=$(yarn --version 2>/dev/null)
        success "yarn selected (priority 3) - version $yarn_version"
        PM="yarn"
        export PM
        return 0
    fi
    
    # Priority 4: npm
    if command_works npm; then
        local npm_version=$(npm --version 2>/dev/null)
        success "npm selected (priority 4) - version $npm_version"
        PM="npm"
        export PM
        return 0
    fi
    
    # None found, install Bun
    log "No working package manager found, installing Bun..."
    install_bun
    PM="bun"
    export PM
}

# Detect Linux distribution family
detect_distro_family() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            arch|manjaro|endeavouros|garuda|artix|cachyos)
                echo "arch"
                ;;
            ubuntu|debian|linuxmint|pop|elementary|zorin|kali|parrot|devuan)
                echo "debian"
                ;;
            fedora|rhel|centos|rocky|almalinux|nobara|ultramarine)
                echo "fedora"
                ;;
            opensuse*|suse*)
                echo "suse"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/fedora-release ] || [ -f /etc/redhat-release ]; then
        echo "fedora"
    else
        echo "unknown"
    fi
}

# Robust check for OpenChamber with distro-specific paths
check_openchamber() {
    # Check if openchamber command exists and works
    if ! command_works openchamber; then
        # Check distro-specific installation paths
        local distro=$(detect_distro_family)
        local oc_path=""
        
        case "$distro" in
            arch)
                # Arch Linux: check AUR installation paths
                oc_path="/usr/bin/openchamber"
                ;;
            debian)
                # Ubuntu/Debian: check common paths
                oc_path="/usr/local/bin/openchamber"
                ;;
            fedora)
                # Fedora: check common paths
                oc_path="/usr/local/bin/openchamber"
                ;;
        esac
        
        # If found in distro-specific path, add to PATH
        if [ -n "$oc_path" ] && [ -x "$oc_path" ]; then
            export PATH="$(dirname "$oc_path"):$PATH"
            if command_works openchamber; then
                local oc_version=$(openchamber --version 2>/dev/null | head -1)
                log "OpenChamber detected at $oc_path: $oc_version"
                return 0
            fi
        fi
        
        return 1
    fi
    
    # Get version to confirm it's really working
    local oc_version=$(openchamber --version 2>/dev/null | head -1)
    if [ -n "$oc_version" ]; then
        log "OpenChamber detected: $oc_version"
        return 0
    fi
    
    return 1
}

# Install OpenChamber Core via detected package manager
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
        *)
            # Fallback to remote install script if no PM detected
            log "Installing via remote script..."
            curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash
            ;;
    esac
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
        yarn) yarn global add $PKG_NAME ;;
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
