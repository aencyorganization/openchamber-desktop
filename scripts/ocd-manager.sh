#!/bin/bash

# OpenChamber Desktop (OCD) Manager
# Pure Bash - No external dependencies
# Usage: curl -fsSL .../ocd-manager.sh | bash

set -e

# Reopen stdin from terminal (fixes curl | bash closing immediately)
# This allows interactive prompts to work when script is piped
if [ -t 0 ]; then
    : # stdin is already a terminal
else
    # Reopen /dev/tty for interactive input
    exec 0</dev/tty 2>/dev/null || {
        echo "Error: Cannot access terminal for interactive input."
        echo "Please run: curl -fsSL .../ocd-manager.sh > /tmp/ocd-manager.sh && bash /tmp/ocd-manager.sh"
        exit 1
    }
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# App config
APP_NAME="OpenChamber Desktop"
PKG_NAME="openchamber-desktop"
CORE_PKG="@openchamber/web"
VERSION="2.0.0"

# Clear screen and show header
clear_screen() {
    clear
    echo -e "${CYAN}"
    echo "  ██████╗  ██████╗ ██████╗"
    echo " ██╔═══██╗██╔════╝██╔═══██╗"
    echo " ██║   ██║██║     ██║   ██║"
    echo " ██║   ██║██║     ██║   ██║"
    echo " ╚██████╔╝╚██████╗╚██████╔╝"
    echo "  ╚═════╝  ╚═════╝ ╚═════╝"
    echo -e "${WHITE}  ${APP_NAME} Manager v${VERSION}${NC}"
    echo ""
}

# Draw box
draw_box() {
    local text="$1"
    local width=50
    local padding=2
    
    echo -e "${CYAN}╔$(printf '═%.0s' $(seq 1 $width))╗${NC}"
    echo -e "${CYAN}║${NC}$(printf '%*s' $padding '')${WHITE}${text}$(printf '%*s' $((width - ${#text} - padding)) '')${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚$(printf '═%.0s' $(seq 1 $width))╝${NC}"
}

# Show menu
show_menu() {
    clear_screen
    draw_box "MAIN MENU"
    echo ""
    echo -e "  ${CYAN}[1]${NC} 📦  Install / Update OCD"
    echo -e "  ${CYAN}[2]${NC} 🗑️   Uninstall"
    echo -e "  ${CYAN}[3]${NC} ℹ️   System Info"
    echo -e "  ${CYAN}[4]${NC} 🚪  Exit"
    echo ""
    echo -e "  ${YELLOW}Use arrow keys or type number [1-4]${NC}"
    echo ""
}

# Get input with prompt
get_input() {
    local prompt="$1"
    local default="$2"
    
    echo -ne "${CYAN}${prompt}${NC}"
    if [ -n "$default" ]; then
        echo -ne " [${YELLOW}${default}${NC}]: "
    else
        echo -ne ": "
    fi
    
    read input
    if [ -z "$input" ] && [ -n "$default" ]; then
        input="$default"
    fi
    echo "$input"
}

# Yes/No prompt
confirm() {
    local prompt="$1"
    local default="${2:-y}"
    
    while true; do
        echo -ne "${CYAN}${prompt}${NC} "
        if [ "$default" = "y" ]; then
            echo -ne "[${GREEN}Y${NC}/${RED}n${NC}]: "
        else
            echo -ne "[${GREEN}y${NC}/${RED}N${NC}]: "
        fi
        
        read answer
        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
        
        if [ -z "$answer" ]; then
            answer="$default"
        fi
        
        case "$answer" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
        esac
    done
}

# Spinner for long operations
spinner() {
    local msg="$1"
    local pid=$2
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    echo -ne "${CYAN}${msg} ${NC}"
    while kill -0 "$pid" 2>/dev/null; do
        for i in $(seq 0 $((${#spinstr}-1))); do
            printf "${CYAN}%s${NC}\b" "${spinstr:$i:1}"
            sleep $delay
        done
    done
    printf "   \b\b\b"
    echo -e "${GREEN}✓${NC}"
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

# Install Bun
install_bun() {
    clear_screen
    draw_box "INSTALLING BUN"
    echo ""
    
    (
        curl -fsSL https://bun.sh/install | bash
    ) &
    local pid=$!
    spinner "Installing Bun..." $pid
    wait $pid
    
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    
    echo -e "${GREEN}✓ Bun installed successfully${NC}"
    sleep 1
}

# Install flow
install_flow() {
    clear_screen
    draw_box "INSTALL / UPDATE OCD"
    echo ""
    
    # Step 1: Package Manager
    echo -e "${CYAN}Step 1/5: Package Manager${NC}"
    echo ""
    
    local pm=$(get_package_manager)
    
    if [ -n "$pm" ]; then
        echo -e "Found: ${GREEN}${pm}${NC}"
        if confirm "Use ${pm}?" "y"; then
            :
        else
            echo ""
            echo -e "${CYAN}Select package manager:${NC}"
            echo "  [1] Bun (Fastest)"
            echo "  [2] pnpm"
            echo "  [3] npm"
            echo ""
            local choice=$(get_input "Choice" "1")
            case "$choice" in
                1) pm="bun" ;;
                2) pm="pnpm" ;;
                3) pm="npm" ;;
                *) pm="bun" ;;
            esac
        fi
    else
        echo -e "${YELLOW}No package manager found${NC}"
        if confirm "Install Bun?" "y"; then
            install_bun
            pm="bun"
        else
            echo -e "${RED}Cannot continue without package manager${NC}"
            sleep 2
            return
        fi
    fi
    
    # Install selected PM if needed
    if [ "$pm" = "bun" ] && ! command_exists bun; then
        install_bun
    fi
    
    echo -e "${GREEN}✓ Using: ${pm}${NC}"
    sleep 0.5
    
    # Step 2: OpenChamber Core
    echo ""
    echo -e "${CYAN}Step 2/5: OpenChamber Core${NC}"
    
    if command_exists openchamber; then
        echo -e "${GREEN}✓ OpenChamber already installed${NC}"
        local oc_version=$(openchamber --version 2>/dev/null || echo "unknown")
        echo "  Version: ${oc_version}"
        if confirm "Reinstall/Update?" "n"; then
            (
                $pm install -g $CORE_PKG
            ) &
            spinner "Updating OpenChamber..." $!
            wait $!
        fi
    else
        if confirm "Install OpenChamber Core?" "y"; then
            (
                $pm install -g $CORE_PKG
            ) &
            spinner "Installing OpenChamber..." $!
            wait $!
            echo -e "${GREEN}✓ OpenChamber Core installed${NC}"
        fi
    fi
    sleep 0.5
    
    # Step 3: OCD
    echo ""
    echo -e "${CYAN}Step 3/5: OpenChamber Desktop${NC}"
    
    if command_exists $PKG_NAME; then
        echo -e "${GREEN}✓ OCD already installed${NC}"
        if confirm "Update OCD?" "n"; then
            (
                $pm install -g $PKG_NAME
            ) &
            spinner "Updating OCD..." $!
            wait $!
        fi
    else
        (
            $pm install -g $PKG_NAME
        ) &
        spinner "Installing OCD..." $!
        wait $!
        echo -e "${GREEN}✓ OCD installed${NC}"
    fi
    sleep 0.5
    
    # Step 4: Aliases
    echo ""
    echo -e "${CYAN}Step 4/5: Shell Aliases${NC}"
    
    if confirm "Create shell aliases?" "y"; then
        local shell_config=""
        if [ -f "$HOME/.zshrc" ]; then
            shell_config="$HOME/.zshrc"
        elif [ -f "$HOME/.bashrc" ]; then
            shell_config="$HOME/.bashrc"
        fi
        
        if [ -n "$shell_config" ]; then
            local aliases_added=""
            
            if confirm "Create alias 'ocd'?" "y"; then
                if ! grep -q "alias ocd=" "$shell_config" 2>/dev/null; then
                    echo "alias ocd='$PKG_NAME'" >> "$shell_config"
                    aliases_added="$aliases_added ocd"
                fi
            fi
            
            if confirm "Create alias 'openchamber-desktop'?" "y"; then
                if ! grep -q "alias openchamber-desktop=" "$shell_config" 2>/dev/null; then
                    echo "alias openchamber-desktop='$PKG_NAME'" >> "$shell_config"
                    aliases_added="$aliases_added openchamber-desktop"
                fi
            fi
            
            if confirm "Create custom alias?" "n"; then
                local custom=$(get_input "Alias name")
                if [ -n "$custom" ]; then
                    echo "alias $custom='$PKG_NAME'" >> "$shell_config"
                    aliases_added="$aliases_added $custom"
                fi
            fi
            
            if [ -n "$aliases_added" ]; then
                echo -e "${GREEN}✓ Aliases added:${aliases_added}${NC}"
                echo -e "${YELLOW}  Run: source ${shell_config}${NC}"
            fi
        else
            echo -e "${RED}✗ No shell config found (.bashrc or .zshrc)${NC}"
        fi
    fi
    sleep 0.5
    
    # Step 5: Shortcuts
    echo ""
    echo -e "${CYAN}Step 5/5: Desktop Shortcuts${NC}"
    
    if confirm "Create desktop shortcuts?" "y"; then
        create_shortcuts
    fi
    
    # Done
    clear_screen
    draw_box "INSTALLATION COMPLETE"
    echo ""
    echo -e "${GREEN}✓ OpenChamber Desktop is ready!${NC}"
    echo ""
    echo -e "  ${CYAN}Run:${NC} ${WHITE}ocd${NC} or ${WHITE}openchamber-desktop${NC}"
    echo ""
    echo -e "  ${YELLOW}Press Enter to continue...${NC}"
    read
}

# Create desktop shortcuts
create_shortcuts() {
    local os=$(uname -s)
    local icon_dir="$HOME/.config/openchamber"
    local icon_path="$icon_dir/icon.png"
    
    mkdir -p "$icon_dir"
    
    # Download icon
    if [ ! -f "$icon_path" ]; then
        (
            curl -fsSL "https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/assets/openchamber-logo-dark.png" -o "$icon_path" 2>/dev/null
        ) &
        spinner "Downloading icon..." $!
        wait $!
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
        echo -e "${GREEN}✓ Desktop entry created${NC}"
        
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
        echo -e "${GREEN}✓ App bundle created in ~/Applications${NC}"
    fi
}

# Uninstall flow
uninstall_flow() {
    clear_screen
    draw_box "UNINSTALL"
    echo ""
    
    echo -e "${RED}This will remove:${NC}"
    echo "  • OpenChamber Desktop (OCD)"
    echo "  • Desktop shortcuts"
    echo "  • Shell aliases"
    echo ""
    
    local confirm_text=$(get_input "Type 'yes' to confirm" "")
    if [ "$confirm_text" != "yes" ]; then
        echo -e "${YELLOW}Uninstall cancelled${NC}"
        sleep 1
        return
    fi
    
    local pm=$(get_package_manager)
    
    # Remove OCD
    if [ -n "$pm" ]; then
        echo ""
        (
            $pm uninstall -g $PKG_NAME 2>/dev/null || true
        ) &
        spinner "Removing OCD..." $!
        wait $!
        echo -e "${GREEN}✓ OCD removed${NC}"
    fi
    
    # Ask about core
    echo ""
    if confirm "Remove OpenChamber Core too?" "n"; then
        if [ -n "$pm" ]; then
            (
                $pm uninstall -g $CORE_PKG 2>/dev/null || true
            ) &
            spinner "Removing Core..." $!
            wait $!
            echo -e "${GREEN}✓ Core removed${NC}"
        fi
    fi
    
    # Remove shortcuts
    echo ""
    local os=$(uname -s)
    if [ "$os" = "Linux" ]; then
        rm -f "$HOME/.local/share/applications/ocd.desktop"
        echo -e "${GREEN}✓ Desktop entry removed${NC}"
    elif [ "$os" = "Darwin" ]; then
        rm -rf "$HOME/Applications/$APP_NAME.app"
        echo -e "${GREEN}✓ App bundle removed${NC}"
    fi
    
    # Remove aliases
    local shell_config=""
    if [ -f "$HOME/.zshrc" ]; then
        shell_config="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        shell_config="$HOME/.bashrc"
    fi
    
    if [ -n "$shell_config" ]; then
        sed -i '/alias ocd=/d' "$shell_config" 2>/dev/null || true
        sed -i '/alias openchamber-desktop=/d' "$shell_config" 2>/dev/null || true
        echo -e "${GREEN}✓ Aliases removed${NC}"
    fi
    
    echo ""
    draw_box "UNINSTALL COMPLETE"
    sleep 1
}

# System info
system_info() {
    clear_screen
    draw_box "SYSTEM INFORMATION"
    echo ""
    
    local os=$(uname -s)
    local arch=$(uname -m)
    local pm=$(get_package_manager)
    
    echo -e "  ${CYAN}Operating System:${NC}  ${WHITE}${os}${NC}"
    echo -e "  ${CYAN}Architecture:${NC}      ${WHITE}${arch}${NC}"
    echo -e "  ${CYAN}Package Manager:${NC}   ${WHITE}${pm:-None}${NC}"
    echo ""
    
    if command_exists openchamber; then
        local oc_ver=$(openchamber --version 2>/dev/null || echo "Installed")
        echo -e "  ${CYAN}OpenChamber:${NC}       ${GREEN}${oc_ver}${NC}"
    else
        echo -e "  ${CYAN}OpenChamber:${NC}       ${RED}Not installed${NC}"
    fi
    
    if command_exists $PKG_NAME; then
        echo -e "  ${CYAN}OCD:${NC}               ${GREEN}Installed${NC}"
    else
        echo -e "  ${CYAN}OCD:${NC}               ${RED}Not installed${NC}"
    fi
    
    echo ""
    echo -e "  ${YELLOW}Press Enter to continue...${NC}"
    read
}

# Main loop
main() {
    while true; do
        show_menu
        
        echo -ne "${CYAN}Select option [1-4]:${NC} "
        read choice
        
        case "$choice" in
            1)
                install_flow
                ;;
            2)
                uninstall_flow
                ;;
            3)
                system_info
                ;;
            4)
                clear_screen
                echo -e "${GREEN}Goodbye! 👋${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# Run
main
