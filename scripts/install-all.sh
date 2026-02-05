#!/bin/bash

# OpenChamber Desktop - Universal Installer
# This script detects the OS, installs Bun if needed, installs the app, and creates system integration

set -e

APP_NAME="OpenChamber Desktop"
APP_PACKAGE="openchamber-desktop"
BUN_INSTALL_URL="https://bun.sh/install"
REPO_URL="https://github.com/aencyorganization/openchamber-desktop"

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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Bun
install_bun() {
    if command_exists bun; then
        print_success "Bun is already installed ($(bun --version))"
        return 0
    fi
    
    print_status "Installing Bun..."
    curl -fsSL "$BUN_INSTALL_URL" | bash
    
    # Add to PATH for current session
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    
    if command_exists bun; then
        print_success "Bun installed successfully ($(bun --version))"
    else
        print_error "Bun installation failed. Please install manually: $BUN_INSTALL_URL"
        exit 1
    fi
}

# Install OpenChamber Desktop via Bun
install_app() {
    print_status "Installing $APP_NAME via Bun..."
    
    if command_exists openchamber-desktop; then
        print_warning "$APP_NAME is already installed. Updating..."
        bun install -g "$APP_PACKAGE" --force
    else
        bun install -g "$APP_PACKAGE"
    fi
    
    if command_exists openchamber-desktop; then
        print_success "$APP_NAME installed successfully!"
    else
        print_error "Installation failed. Trying with npm..."
        npm install -g "$APP_PACKAGE"
    fi
}

# Create system integration
create_system_integration() {
    print_status "Creating system integration..."
    
    case "$OS" in
        Linux)
            create_linux_integration
            ;;
        Mac)
            create_mac_integration
            ;;
        Windows)
            print_warning "On Windows, please run the installer from PowerShell as Administrator:"
            print_warning "  irm $REPO_URL/raw/main/scripts/install-all.ps1 | iex"
            ;;
        *)
            print_warning "Unknown OS. System integration not created."
            ;;
    esac
}

# Linux integration
create_linux_integration() {
    print_status "Creating Linux desktop entry..."
    
    # Find where bun installed the app
    BUN_BIN="${BUN_INSTALL:-$HOME/.bun}/bin"
    APP_EXE="$BUN_BIN/openchamber-desktop"
    
    if [ ! -f "$APP_EXE" ]; then
        APP_EXE="$(which openchamber-desktop)"
    fi
    
    # Remover entradas antigas/duplicadas primeiro
    if [ -f "$HOME/.local/share/applications/ocd.desktop" ]; then
        print_status "Removendo entrada antiga ocd.desktop..."
        rm -f "$HOME/.local/share/applications/ocd.desktop"
    fi
    
    # Create .desktop file
    DESKTOP_FILE="$HOME/.local/share/applications/openchamber-desktop.desktop"
    mkdir -p "$HOME/.local/share/applications"
    
    # Detectar arquitetura para WM_CLASS
    local arch=$(uname -m)
    local wm_class
    case "$arch" in
        x86_64) wm_class="neutralino-linux_x64" ;;
        aarch64|arm64) wm_class="neutralino-linux_arm64" ;;
        armv7l|armhf) wm_class="neutralino-linux_armhf" ;;
        *) wm_class="neutralino-linux_x64" ;;
    esac
    
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=$APP_NAME
Exec=$APP_EXE
Icon=utilities-terminal
Type=Application
Categories=Development;IDE;System;
Terminal=false
Comment=OpenChamber Desktop Launcher (Unofficial)
Keywords=openchamber;opencode;ai;coding;
StartupNotify=true
StartupWMClass=$wm_class
TryExec=$APP_EXE
EOF
    
    chmod +x "$DESKTOP_FILE"
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    
    print_success "Desktop entry created at $DESKTOP_FILE"
    print_status "You can now find $APP_NAME in your applications menu!"
}

# macOS integration
create_mac_integration() {
    print_status "Creating macOS integration..."
    
    BUN_BIN="${BUN_INSTALL:-$HOME/.bun}/bin"
    APP_EXE="$BUN_BIN/openchamber-desktop"
    
    if [ ! -f "$APP_EXE" ]; then
        APP_EXE="$(which openchamber-desktop)"
    fi
    
    # Create Applications symlink
    APP_LINK="$HOME/Applications/OpenChamber Desktop"
    mkdir -p "$HOME/Applications"
    
    if [ -L "$APP_LINK" ]; then
        rm "$APP_LINK"
    fi
    
    ln -sf "$APP_EXE" "$APP_LINK"
    
    print_success "Created symlink at $APP_LINK"
    print_status "You can now find $APP_NAME in Launchpad or Spotlight!"
}

# Main installation flow
main() {
    echo "=========================================="
    echo "  $APP_NAME - Universal Installer"
    echo "=========================================="
    echo ""
    
    detect_os
    
    if [ "$OS" = "Windows" ]; then
        print_error "For Windows, please use PowerShell:"
        print_error "  irm $REPO_URL/raw/main/scripts/install-all.ps1 | iex"
        exit 1
    fi
    
    install_bun
    install_app
    create_system_integration
    
    echo ""
    echo "=========================================="
    print_success "Installation complete!"
    echo "=========================================="
    echo ""
    echo "You can now run:"
    echo "  openchamber-desktop    (or just: ocd)"
    echo ""
    echo "To uninstall later, run:"
    echo "  openchamber-desktop --uninstall-all"
    echo ""
}

main "$@"
