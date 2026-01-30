#!/bin/bash

# OpenChamber Desktop (OCD) Manager
# Comprehensive TUI for macOS/Linux

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# --- Configuration ---
REPO_DIR="/home/gabriel/openchamber-desktop"
ICON_PATH="$REPO_DIR/assets/openchamber-logo-dark.png"
APP_NAME="OpenChamber Desktop"
PKG_NAME="openchamber-desktop"
CORE_PKG="@openchamber/web"
DEFAULT_BIN="ocd"

# --- Helper Functions ---

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

show_header() {
    clear
    echo -e "${CYAN}"
    echo "  ██████╗  ██████╗██████╗ "
    echo " ██╔═══██╗██╔════╝██╔══██╗"
    echo " ██║   ██║██║     ██║  ██║"
    echo " ██║   ██║██║     ██║  ██║"
    echo " ╚██████╔╝╚██████╗██████╔╝"
    echo "  ╚═════╝  ╚═════╝╚═════╝ "
    echo -e "   OpenChamber Desktop Manager"
    echo -e "${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

show_success() {
    echo -e "${GREEN}✔ $1${NC}"
}

show_error() {
    echo -e "${RED}✘ Error: $1${NC}"
}

show_warning() {
    echo -e "${YELLOW}⚠ Warning: $1${NC}"
}

show_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

show_progress() {
    echo -e "${BLUE}➤ [$1/$2] $3...${NC}"
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

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

install_package_manager() {
    show_info "No package manager (bun/pnpm/npm) found. Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    # Source bun
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    if command_exists bun; then
        show_success "Bun installed successfully."
        return 0
    else
        show_error "Failed to install Bun."
        return 1
    fi
}

detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        *)          echo "unknown";;
    esac
}

detect_desktop_environment() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        echo "macOS"
    else
        echo "${XDG_CURRENT_DESKTOP:-Unknown}"
    fi
}

# --- Core Logic ---

install_flow() {
    show_header
    echo -e "${BOLD}Starting Installation/Update Flow${NC}"
    echo ""

    # Step 1: Check Package Manager
    show_progress 1 3 "Checking package manager"
    PM=$(get_package_manager)
    if [ -z "$PM" ]; then
        install_package_manager || return 1
        PM="bun"
    fi
    show_success "Using $PM"
    sleep 0.5

    # Step 2: Check OpenChamber Core
    show_progress 2 3 "Checking OpenChamber Core"
    if ! command_exists openchamber; then
        show_info "OpenChamber not found. Installing $CORE_PKG..."
        case $PM in
            bun) bun install -g $CORE_PKG & ;;
            pnpm) pnpm add -g $CORE_PKG & ;;
            npm) npm install -g $CORE_PKG & ;;
        esac
        spinner $!
        show_success "OpenChamber core installed."
    else
        VERSION=$(openchamber --version 2>/dev/null || echo "unknown")
        show_success "OpenChamber found (version: $VERSION)"
    fi
    sleep 0.5

    # Step 3: Install OCD
    show_progress 3 3 "Installing $APP_NAME"
    case $PM in
        bun) bun install -g $PKG_NAME & ;;
        pnpm) pnpm add -g $PKG_NAME & ;;
        npm) npm install -g $PKG_NAME & ;;
    esac
    spinner $!
    show_success "$APP_NAME installed globally."
    sleep 0.5

    # Alias Configuration
    echo ""
    echo -e "${BOLD}Alias Configuration${NC}"
    read -p "Create alias 'ocd'? (Y/n): " opt_ocd
    read -p "Create alias 'openchamber-desktop'? (Y/n): " opt_full
    read -p "Create custom alias? (leave empty for none): " opt_custom

    SHELL_CONFIG=""
    if [ -f "$HOME/.zshrc" ]; then SHELL_CONFIG="$HOME/.zshrc";
    elif [ -f "$HOME/.bashrc" ]; then SHELL_CONFIG="$HOME/.bashrc";
    fi

    if [ -n "$SHELL_CONFIG" ]; then
        # Convert to lowercase for comparison
        opt_ocd_l=$(echo "$opt_ocd" | tr '[:upper:]' '[:lower:]')
        opt_full_l=$(echo "$opt_full" | tr '[:upper:]' '[:lower:]')

        [[ "$opt_ocd_l" != "n" ]] && (grep -q "alias ocd=" "$SHELL_CONFIG" || echo "alias ocd='$PKG_NAME --single-instance'" >> "$SHELL_CONFIG")
        [[ "$opt_full_l" != "n" ]] && (grep -q "alias openchamber-desktop=" "$SHELL_CONFIG" || echo "alias openchamber-desktop='$PKG_NAME --single-instance'" >> "$SHELL_CONFIG")
        if [ -n "$opt_custom" ]; then
            grep -q "alias $opt_custom=" "$SHELL_CONFIG" || echo "alias $opt_custom='$PKG_NAME --single-instance'" >> "$SHELL_CONFIG"
        fi
        show_success "Aliases added to $SHELL_CONFIG"
    else
        show_warning "No shell config found to add aliases."
    fi

    # Desktop Entry
    echo ""
    read -p "Create desktop/menu entry? (Y/n): " opt_desktop
    opt_desktop_l=$(echo "$opt_desktop" | tr '[:upper:]' '[:lower:]')
    if [[ "$opt_desktop_l" != "n" ]]; then
        create_desktop_entry
    fi

    echo ""
    show_success "Installation Complete!"
    read -p "Press Enter to return to menu..."
}

create_desktop_entry() {
    OS=$(detect_os)
    if [ "$OS" == "linux" ]; then
        show_info "Creating Linux .desktop entry..."
        ENTRY_PATH="$HOME/.local/share/applications/ocd.desktop"
        mkdir -p "$(dirname "$ENTRY_PATH")"
        cat <<EOF > "$ENTRY_PATH"
[Desktop Entry]
Name=$APP_NAME
Comment=OpenChamber Desktop Manager
Exec=$PKG_NAME --single-instance
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Utility;Development;
StartupNotify=false
EOF
        chmod +x "$ENTRY_PATH"
        show_success "Desktop entry created at $ENTRY_PATH"
    elif [ "$OS" == "macos" ]; then
        show_info "Creating macOS App Bundle..."
        APP_PATH="/Applications/$APP_NAME.app"
        # We might not have permission for /Applications, fallback to ~/Applications
        if [ ! -w "/Applications" ]; then
            APP_PATH="$HOME/Applications/$APP_NAME.app"
        fi
        
        mkdir -p "$APP_PATH/Contents/MacOS"
        mkdir -p "$APP_PATH/Contents/Resources"
        
        # Create wrapper script
        cat <<EOF > "$APP_PATH/Contents/MacOS/launcher"
#!/bin/bash
export PATH="/usr/local/bin:/opt/homebrew/bin:\$PATH"
$PKG_NAME --single-instance &
EOF
        chmod +x "$APP_PATH/Contents/MacOS/launcher"
        
        # Minimal Info.plist
        cat <<EOF > "$APP_PATH/Contents/Info.plist"
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
        # Copy icon if possible (macOS likes .icns, but we can try)
        if [ -f "$ICON_PATH" ]; then
            cp "$ICON_PATH" "$APP_PATH/Contents/Resources/icon.png"
        fi
        
        show_success "App bundle created at $APP_PATH"
    fi
}

uninstall_flow() {
    show_header
    echo -e "${RED}${BOLD}UNINSTALL OCD${NC}"
    echo -e "${YELLOW}This will remove OCD, shortcuts, and aliases.${NC}"
    echo ""
    read -p "Are you sure? Type 'yes' to confirm: " confirm
    if [ "$confirm" != "yes" ]; then
        show_info "Uninstall cancelled."
        sleep 1
        return
    fi

    PM=$(get_package_manager)
    if [ -n "$PM" ]; then
        show_progress 1 4 "Removing $PKG_NAME"
        case $PM in
            bun) bun uninstall -g $PKG_NAME & ;;
            pnpm) pnpm remove -g $PKG_NAME & ;;
            npm) npm uninstall -g $PKG_NAME & ;;
        esac
        spinner $!
        show_success "OCD removed."
    fi

    read -p "Remove OpenChamber Core ($CORE_PKG) too? (y/N): " rm_core
    rm_core_l=$(echo "$rm_core" | tr '[:upper:]' '[:lower:]')
    if [[ "$rm_core_l" == "y" ]]; then
        show_progress 2 4 "Removing core"
        case $PM in
            bun) bun uninstall -g $CORE_PKG & ;;
            pnpm) pnpm remove -g $CORE_PKG & ;;
            npm) npm uninstall -g $CORE_PKG & ;;
        esac
        spinner $!
        show_success "Core removed."
    fi

    show_progress 3 4 "Removing shortcuts"
    OS=$(detect_os)
    if [ "$OS" == "linux" ]; then
        rm -f "$HOME/.local/share/applications/ocd.desktop"
    elif [ "$OS" == "macos" ]; then
        rm -rf "/Applications/$APP_NAME.app"
        rm -rf "$HOME/Applications/$APP_NAME.app"
    fi
    show_success "Shortcuts removed."

    show_progress 4 4 "Cleaning shell config"
    SHELL_CONFIG=""
    if [ -f "$HOME/.zshrc" ]; then SHELL_CONFIG="$HOME/.zshrc";
    elif [ -f "$HOME/.bashrc" ]; then SHELL_CONFIG="$HOME/.bashrc";
    fi

    if [ -n "$SHELL_CONFIG" ]; then
        sed -i "/alias ocd=/d" "$SHELL_CONFIG" 2>/dev/null || sed -i "" "/alias ocd=/d" "$SHELL_CONFIG"
        sed -i "/alias openchamber-desktop=/d" "$SHELL_CONFIG" 2>/dev/null || sed -i "" "/alias openchamber-desktop=/d" "$SHELL_CONFIG"
        show_success "Aliases removed from $SHELL_CONFIG"
    fi

    echo ""
    show_success "Uninstall Complete!"
    read -p "Press Enter to return to menu..."
}

system_info() {
    show_header
    echo -e "${BOLD}SYSTEM INFORMATION${NC}"
    echo "--------------------------------"
    echo -e "${CYAN}OS:${NC} $(uname -s) ($(uname -r))"
    echo -e "${CYAN}Arch:${NC} $(uname -m)"
    echo -e "${CYAN}DE:${NC} $(detect_desktop_environment)"
    echo -e "${CYAN}Package Manager:${NC} $(get_package_manager || echo "None")"
    
    if command_exists openchamber; then
        echo -e "${CYAN}OpenChamber:${NC} $(openchamber --version 2>/dev/null || echo "Installed")"
    else
        echo -e "${CYAN}OpenChamber:${NC} Not Installed"
    fi

    if command_exists $PKG_NAME; then
        echo -e "${CYAN}OCD:${NC} Installed"
    else
        echo -e "${CYAN}OCD:${NC} Not Installed"
    fi

    echo -e "${CYAN}Repo Path:${NC} $REPO_DIR"
    
    OS=$(detect_os)
    if [ "$OS" == "linux" ]; then
        echo -e "${CYAN}Desktop Entry:${NC} $HOME/.local/share/applications/ocd.desktop"
    elif [ "$OS" == "macos" ]; then
        echo -e "${CYAN}App Bundle:${NC} /Applications/$APP_NAME.app"
    fi
    
    echo "--------------------------------"
    echo ""
    read -p "Press Enter to return to menu..."
}

# --- Main Menu ---

while true; do
    if command_exists whiptail; then
        choice=$(whiptail --title "$APP_NAME Manager" --menu "Select an option" 16 60 4 \
            "1" "📦 Install/Update OCD" \
            "2" "🗑️ Complete Uninstall" \
            "3" "ℹ️ System Info" \
            "4" "🚪 Exit" 3>&1 1>&2 2>&3)
        exit_status=$?
        if [ $exit_status -ne 0 ]; then echo "Goodbye!"; exit 0; fi
    elif command_exists dialog; then
        choice=$(dialog --clear --title "$APP_NAME Manager" --menu "Select an option" 16 60 4 \
            "1" "📦 Install/Update OCD" \
            "2" "🗑️ Complete Uninstall" \
            "3" "ℹ️ System Info" \
            "4" "🚪 Exit" 3>&1 1>&2 2>&3)
        exit_status=$?
        if [ $exit_status -ne 0 ]; then echo "Goodbye!"; exit 0; fi
    else
        show_header
        echo -e " 1) ${GREEN}📦 Install/Update OCD${NC}"
        echo -e " 2) ${RED}🗑️ Complete Uninstall${NC}"
        echo -e " 3) ${CYAN}ℹ️ System Info${NC}"
        echo -e " 4) ${YELLOW}🚪 Exit${NC}"
        echo ""
        read -p "Select an option [1-4]: " choice
    fi

    case $choice in
        1) install_flow ;;
        2) uninstall_flow ;;
        3) system_info ;;
        4) echo "Goodbye!"; exit 0 ;;
        *) [[ -z "$choice" ]] || (show_error "Invalid option"; sleep 1) ;;
    esac
done
