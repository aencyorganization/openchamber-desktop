#!/bin/bash

# OpenChamber Desktop (OCD) Manager
# Pure Bash - No external dependencies
# Usage: curl -fsSL .../ocd-manager.sh | bash

# Check if we're running from a pipe (curl | bash)
if [ ! -t 0 ]; then
    # We're being piped, need to save to file first for reliability
    TMP_SCRIPT="/tmp/ocd-manager-$$.sh"
    
    # Copy stdin to temp file
    cat > "$TMP_SCRIPT" 2>/dev/null || {
        echo "ERROR: Cannot write to temporary file"
        echo "Try: curl -fsSL <url> > ~/ocd-manager.sh && bash ~/ocd-manager.sh"
        exit 1
    }
    
    # Check if we got the full script
    if [ ! -s "$TMP_SCRIPT" ] || [ $(wc -l < "$TMP_SCRIPT") -lt 10 ]; then
        echo "ERROR: Download incomplete"
        rm -f "$TMP_SCRIPT"
        exit 1
    fi
    
    # Reopen stdin from terminal for interactive prompts
    exec 0</dev/tty 2>/dev/null || {
        echo "ERROR: Cannot access terminal for interactive input."
        echo "Run without pipe: bash $TMP_SCRIPT"
        exit 1
    }
    
    # Execute the saved script
    bash "$TMP_SCRIPT"
    EXIT_CODE=$?
    rm -f "$TMP_SCRIPT"
    exit $EXIT_CODE
fi

# Colors - Extended palette
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BRIGHT_BLACK='\033[1;30m'
BRIGHT_RED='\033[1;31m'
BRIGHT_GREEN='\033[1;32m'
BRIGHT_YELLOW='\033[1;33m'
BRIGHT_BLUE='\033[1;34m'
BRIGHT_MAGENTA='\033[1;35m'
BRIGHT_CYAN='\033[1;36m'
BRIGHT_WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'

# App config
APP_NAME="OpenChamber Desktop"
PKG_NAME="openchamber-desktop"
CORE_PKG="@openchamber/web"
VERSION="2.1.0"
AUTHOR="Aency Organization"
REPO="github.com/aencyorganization/openchamber-desktop"

# Terminal dimensions
get_term_size() {
    local cols=$(tput cols 2>/dev/null || echo 80)
    local lines=$(tput lines 2>/dev/null || echo 24)
    echo "${cols}x${lines}"
}

# Center text
center_text() {
    local text="$1"
    local width=$(tput cols 2>/dev/null || echo 80)
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%${padding}s%s\n" "" "$text"
}

# Draw horizontal line
draw_line() {
    local char="${1:-─}"
    local color="${2:-$CYAN}"
    local width=$(tput cols 2>/dev/null || echo 80)
    echo -e "${color}$(printf "%${width}s" "" | tr ' ' "$char")${NC}"
}

# Clear screen and show enhanced header
clear_screen() {
    clear
    local term_size=$(get_term_size)
    local cols=$(echo "$term_size" | cut -d'x' -f1)
    
    echo ""
    echo -e "${BRIGHT_CYAN}"
    center_text "  ____                   _           _           _"
    center_text " / __ \                 | |         | |         | |"
    center_text "| |  | |_ __   ___ _ __| |__   ___ | | ___   __| | ___"
    center_text "| |  | | '_ \ / _ \ '__| '_ \ / _ \| |/ _ \ / _\` |/ _ \\"
    center_text "| |__| | |_) |  __/ |  | | | | (_) | | (_) | (_| |  __/"
    center_text " \____/| .__/ \___|_|  |_| |_|\___/|_|\___/ \__,_|\___|"
    center_text "       | |                                            "
    center_text "       |_|  DESKTOP MANAGER${NC}"
    echo ""
    
    draw_line "═" "$BRIGHT_CYAN"
    echo -e "  ${DIM}Version:${NC} ${BRIGHT_WHITE}${VERSION}${NC}  ${DIM}|${NC}  ${DIM}Author:${NC} ${BRIGHT_WHITE}${AUTHOR}${NC}"
    draw_line "═" "$BRIGHT_CYAN"
    echo ""
}

# Draw fancy box with title
draw_box() {
    local title="$1"
    local width=60
    local cols=$(tput cols 2>/dev/null || echo 80)
    local padding=$(( (cols - width) / 2 ))
    local left_pad=$(printf "%${padding}s" "")
    
    echo -e "${left_pad}${BRIGHT_CYAN}╔$(printf '═%.0s' $(seq 1 $((width-2))))╗${NC}"
    echo -e "${left_pad}${BRIGHT_CYAN}║${NC}  ${BRIGHT_WHITE}${BOLD}${title}${NC}$(printf '%*s' $((width - ${#title} - 4)) '')${BRIGHT_CYAN}║${NC}"
    echo -e "${left_pad}${BRIGHT_CYAN}╚$(printf '═%.0s' $(seq 1 $((width-2))))╝${NC}"
}

# Draw menu item
draw_menu_item() {
    local num="$1"
    local icon="$2"
    local text="$3"
    local desc="$4"
    
    echo -e "  ${BRIGHT_CYAN}[${BRIGHT_WHITE}${num}${BRIGHT_CYAN}]${NC} ${icon}  ${BRIGHT_WHITE}${text}${NC}"
    if [ -n "$desc" ]; then
        echo -e "      ${DIM}${desc}${NC}"
    fi
}

# Show enhanced menu
show_menu() {
    clear_screen
    draw_box "MAIN MENU"
    echo ""
    
    draw_menu_item "1" "[+]" "Install / Update" "Install or update OCD and dependencies"
    echo ""
    draw_menu_item "2" "[-]" "Uninstall" "Remove OCD, shortcuts and configuration"
    echo ""
    draw_menu_item "3" "[i]" "System Info" "Display system and installation status"
    echo ""
    draw_menu_item "4" "[x]" "Exit" "Close this manager"
    
    echo ""
    draw_line "─" "$DIM"
    echo -e "  ${BRIGHT_YELLOW}TIP:${NC} ${DIM}Type a number (1-4) and press Enter${NC}"
    echo ""
}

# Get input with styled prompt
get_input() {
    local prompt="$1"
    local default="$2"
    
    echo -ne "  ${BRIGHT_CYAN}${prompt}${NC}"
    if [ -n "$default" ]; then
        echo -ne " ${DIM}[${NC}${BRIGHT_YELLOW}${default}${NC}${DIM}]${NC}: "
    else
        echo -ne ": "
    fi
    
    read input < /dev/tty
    if [ -z "$input" ] && [ -n "$default" ]; then
        input="$default"
    fi
    echo "$input"
}

# Enhanced Yes/No prompt
confirm() {
    local prompt="$1"
    local default="${2:-y}"
    
    while true; do
        echo -ne "  ${BRIGHT_CYAN}${prompt}${NC} "
        if [ "$default" = "y" ]; then
            echo -ne "${DIM}[${NC}${BRIGHT_GREEN}Y${NC}${DIM}/${NC}${BRIGHT_RED}n${NC}${DIM}]${NC}: "
        else
            echo -ne "${DIM}[${NC}${BRIGHT_GREEN}y${NC}${DIM}/${NC}${BRIGHT_RED}N${NC}${DIM}]${NC}: "
        fi
        
        read answer < /dev/tty
        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
        
        if [ -z "$answer" ]; then
            answer="$default"
        fi
        
        case "$answer" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
        esac
        
        echo -e "  ${BRIGHT_RED}Please answer yes or no${NC}"
    done
}

# Progress bar
show_progress() {
    local current=$1
    local total=$2
    local msg="$3"
    local width=40
    
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    printf "\r  ${BRIGHT_CYAN}[${NC}"
    printf "${BRIGHT_GREEN}%${filled}s${NC}" | tr ' ' '█'
    printf "${DIM}%${empty}s${NC}" | tr ' ' '░'
    printf "${BRIGHT_CYAN}]${NC} ${BRIGHT_WHITE}%3d%%${NC} ${DIM}${msg}${NC}" "$percent"
    
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

# Spinner with message
spinner() {
    local msg="$1"
    local pid=$2
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    echo -ne "  ${BRIGHT_CYAN}${msg}${NC} "
    while kill -0 "$pid" 2>/dev/null; do
        for (( i=0; i<${#spinstr}; i++ )); do
            printf "${BRIGHT_CYAN}%s${NC}\b" "${spinstr:$i:1}"
            sleep $delay
        done
    done
    printf "    \b\b\b"
    echo -e "${BRIGHT_GREEN}OK${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get package manager with priority
detect_package_manager() {
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

# Get package manager display name
pm_display_name() {
    case "$1" in
        bun) echo "Bun (Ultra-fast)" ;;
        pnpm) echo "pnpm (Efficient)" ;;
        npm) echo "npm (Standard)" ;;
        *) echo "Unknown" ;;
    esac
}

# Install Bun
install_bun() {
    clear_screen
    draw_box "INSTALLING BUN PACKAGE MANAGER"
    echo ""
    echo -e "  ${DIM}Bun is an ultra-fast JavaScript runtime and package manager${NC}"
    echo ""
    
    (
        curl -fsSL https://bun.sh/install | bash 2>&1
    ) > /tmp/bun-install.log 2>&1 &
    local pid=$!
    
    spinner "Downloading and installing Bun..." $pid
    wait $pid
    
    if [ $? -eq 0 ]; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        echo -e "  ${BRIGHT_GREEN}Bun installed successfully${NC}"
        echo ""
        echo -e "  ${DIM}Location: ~/.bun/bin/bun${NC}"
    else
        echo -e "  ${BRIGHT_RED}Failed to install Bun${NC}"
        echo -e "  ${DIM}Check /tmp/bun-install.log for details${NC}"
        sleep 2
        return 1
    fi
    
    sleep 1
    return 0
}

# Step header
step_header() {
    local step="$1"
    local total="$2"
    local title="$3"
    
    echo ""
    draw_line "─" "$DIM"
    echo -e "  ${BRIGHT_CYAN}STEP ${step}/${total}:${NC} ${BRIGHT_WHITE}${BOLD}${title}${NC}"
    draw_line "─" "$DIM"
    echo ""
}

# Install flow
install_flow() {
    clear_screen
    draw_box "INSTALL / UPDATE OPENCHAMBER DESKTOP"
    echo ""
    echo -e "  ${DIM}This wizard will guide you through the installation process${NC}"
    
    local total_steps=5
    local current_step=0
    
    # Step 1: Package Manager
    current_step=1
    step_header "$current_step" "$total_steps" "Package Manager Selection"
    
    local pm=$(detect_package_manager)
    
    if [ -n "$pm" ]; then
        echo -e "  ${BRIGHT_GREEN}Detected:${NC} $(pm_display_name "$pm")"
        echo ""
        if confirm "Use this package manager?" "y"; then
            :
        else
            echo ""
            echo -e "  ${BRIGHT_CYAN}Available options:${NC}"
            echo -e "    ${BRIGHT_WHITE}[1]${NC} Bun (Ultra-fast JavaScript runtime)"
            echo -e "    ${BRIGHT_WHITE}[2]${NC} pnpm (Disk space efficient)"
            echo -e "    ${BRIGHT_WHITE}[3]${NC} npm (Node.js standard)"
            echo ""
            local choice=$(get_input "Select option" "1")
            case "$choice" in
                1) pm="bun" ;;
                2) pm="pnpm" ;;
                3) pm="npm" ;;
                *) pm="bun" ;;
            esac
        fi
    else
        echo -e "  ${BRIGHT_YELLOW}No package manager detected${NC}"
        echo ""
        echo -e "  ${DIM}Bun will be installed (recommended for best performance)${NC}"
        echo ""
        
        if confirm "Install Bun package manager?" "y"; then
            if ! install_bun; then
                echo -e "  ${BRIGHT_RED}Cannot continue without package manager${NC}"
                sleep 2
                return
            fi
            pm="bun"
        else
            echo -e "  ${BRIGHT_RED}Installation cancelled${NC}"
            sleep 2
            return
        fi
    fi
    
    # Install selected PM if needed
    if [ "$pm" = "bun" ] && ! command_exists bun; then
        if ! install_bun; then
            return
        fi
    fi
    
    show_progress 1 5 "Package manager ready"
    sleep 0.5
    
    # Step 2: OpenChamber Core
    current_step=2
    step_header "$current_step" "$total_steps" "OpenChamber Core"
    
    if command_exists openchamber; then
        local oc_version=$(openchamber --version 2>/dev/null || echo "unknown")
        echo -e "  ${BRIGHT_GREEN}Already installed${NC} ${DIM}(version: ${oc_version})${NC}"
        echo ""
        if confirm "Reinstall or update OpenChamber Core?" "n"; then
            (
                $pm install -g $CORE_PKG 2>&1
            ) > /tmp/oc-install.log 2>&1 &
            spinner "Updating OpenChamber Core..." $!
            wait $!
            show_progress 2 5 "Core updated"
        else
            show_progress 2 5 "Core already present"
        fi
    else
        echo -e "  ${BRIGHT_YELLOW}OpenChamber Core not found${NC}"
        echo ""
        if confirm "Install OpenChamber Core?" "y"; then
            (
                $pm install -g $CORE_PKG 2>&1
            ) > /tmp/oc-install.log 2>&1 &
            spinner "Installing OpenChamber Core..." $!
            wait $!
            show_progress 2 5 "Core installed"
        else
            show_progress 2 5 "Core skipped"
        fi
    fi
    sleep 0.5
    
    # Step 3: OCD
    current_step=3
    step_header "$current_step" "$total_steps" "OpenChamber Desktop"
    
    if command_exists $PKG_NAME; then
        echo -e "  ${BRIGHT_GREEN}Already installed${NC}"
        echo ""
        if confirm "Update to latest version?" "n"; then
            (
                $pm install -g $PKG_NAME 2>&1
            ) > /tmp/ocd-install.log 2>&1 &
            spinner "Updating OCD..." $!
            wait $!
            show_progress 3 5 "OCD updated"
        else
            show_progress 3 5 "OCD already present"
        fi
    else
        (
            $pm install -g $PKG_NAME 2>&1
        ) > /tmp/ocd-install.log 2>&1 &
        spinner "Installing OpenChamber Desktop..." $!
        wait $!
        show_progress 3 5 "OCD installed"
    fi
    sleep 0.5
    
    # Step 4: Aliases
    current_step=4
    step_header "$current_step" "$total_steps" "Shell Aliases"
    
    if confirm "Create convenient shell aliases?" "y"; then
        local shell_config=""
        if [ -f "$HOME/.zshrc" ]; then
            shell_config="$HOME/.zshrc"
        elif [ -f "$HOME/.bashrc" ]; then
            shell_config="$HOME/.bashrc"
        fi
        
        if [ -n "$shell_config" ]; then
            local aliases_added=0
            
            echo ""
            if confirm "Create alias 'ocd'?" "y"; then
                if ! grep -q "alias ocd=" "$shell_config" 2>/dev/null; then
                    echo "alias ocd='$PKG_NAME'" >> "$shell_config"
                    echo -e "    ${BRIGHT_GREEN}+${NC} ocd"
                    ((aliases_added++))
                else
                    echo -e "    ${DIM}~ ocd (already exists)${NC}"
                fi
            fi
            
            if confirm "Create alias 'openchamber-desktop'?" "y"; then
                if ! grep -q "alias openchamber-desktop=" "$shell_config" 2>/dev/null; then
                    echo "alias openchamber-desktop='$PKG_NAME'" >> "$shell_config"
                    echo -e "    ${BRIGHT_GREEN}+${NC} openchamber-desktop"
                    ((aliases_added++))
                else
                    echo -e "    ${DIM}~ openchamber-desktop (already exists)${NC}"
                fi
            fi
            
            if confirm "Create custom alias?" "n"; then
                local custom=$(get_input "Enter alias name")
                if [ -n "$custom" ]; then
                    echo "alias $custom='$PKG_NAME'" >> "$shell_config"
                    echo -e "    ${BRIGHT_GREEN}+${NC} $custom"
                    ((aliases_added++))
                fi
            fi
            
            echo ""
            if [ $aliases_added -gt 0 ]; then
                echo -e "  ${BRIGHT_GREEN}Aliases added to $(basename "$shell_config")${NC}"
                echo -e "  ${YELLOW}Run: source ${shell_config}${NC}"
            fi
        else
            echo -e "  ${BRIGHT_RED}No shell config found (.bashrc or .zshrc)${NC}"
        fi
    fi
    show_progress 4 5 "Aliases configured"
    sleep 0.5
    
    # Step 5: Shortcuts
    current_step=5
    step_header "$current_step" "$total_steps" "Desktop Integration"
    
    if confirm "Create desktop shortcuts?" "y"; then
        create_shortcuts
    else
        echo -e "  ${DIM}Desktop shortcuts skipped${NC}"
    fi
    show_progress 5 5 "Installation complete"
    
    # Done
    clear_screen
    draw_box "INSTALLATION COMPLETE"
    echo ""
    echo -e "  ${BRIGHT_GREEN}${BOLD}OpenChamber Desktop is ready to use!${NC}"
    echo ""
    echo -e "  ${BRIGHT_CYAN}Quick Start:${NC}"
    echo -e "    ${BRIGHT_WHITE}ocd${NC}                  Launch OpenChamber Desktop"
    echo -e "    ${BRIGHT_WHITE}openchamber-desktop${NC}  Alternative command"
    echo ""
    echo -e "  ${DIM}For help and documentation:${NC}"
    echo -e "    ${UNDERLINE}https://${REPO}${NC}"
    echo ""
    
    echo -e "  ${BRIGHT_YELLOW}Press Enter to return to menu...${NC}"
    read < /dev/tty
}

# Create desktop shortcuts
create_shortcuts() {
    local os=$(uname -s)
    local icon_dir="$HOME/.config/openchamber"
    local icon_path="$icon_dir/icon.png"
    
    mkdir -p "$icon_dir"
    
    # Download icon
    if [ ! -f "$icon_path" ]; then
        echo -e "  ${DIM}Downloading application icon...${NC}"
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
Categories=Development;Utility;IDE;
Keywords=openchamber;opencode;ai;coding;
StartupNotify=false
X-GNOME-SingleWindow=true
EOF
        chmod +x "$desktop_path"
        echo -e "  ${BRIGHT_GREEN}Linux desktop entry created${NC}"
        echo -e "    ${DIM}Location: ~/.local/share/applications/ocd.desktop${NC}"
        
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
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.12</string>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
EOF
        
        [ -f "$icon_path" ] && cp "$icon_path" "$app_path/Contents/Resources/icon.png"
        echo -e "  ${BRIGHT_GREEN}macOS app bundle created${NC}"
        echo -e "    ${DIM}Location: ~/Applications/$APP_NAME.app${NC}"
    fi
}

# Uninstall flow
uninstall_flow() {
    clear_screen
    draw_box "UNINSTALL OPENCHAMBER DESKTOP"
    echo ""
    
    echo -e "  ${BRIGHT_RED}WARNING: This will remove the following:${NC}"
    echo ""
    echo -e "    ${BRIGHT_RED}-${NC} OpenChamber Desktop (ocd package)"
    echo -e "    ${BRIGHT_RED}-${NC} Desktop shortcuts and application menu entries"
    echo -e "    ${BRIGHT_RED}-${NC} Shell aliases"
    echo ""
    echo -e "  ${BRIGHT_YELLOW}Optional:${NC} OpenChamber Core (can be kept for other tools)"
    echo ""
    draw_line "─" "$DIM"
    
    local confirm_text=$(get_input "Type 'uninstall' to confirm" "")
    if [ "$confirm_text" != "uninstall" ]; then
        echo ""
        echo -e "  ${BRIGHT_YELLOW}Uninstall cancelled${NC}"
        sleep 2
        return
    fi
    
    local pm=$(detect_package_manager)
    local total_items=3
    local current_item=0
    
    # Remove OCD
    if [ -n "$pm" ]; then
        echo ""
        (
            $pm uninstall -g $PKG_NAME 2>&1
        ) > /tmp/ocd-uninstall.log 2>&1 &
        spinner "Removing OpenChamber Desktop..." $!
        wait $!
        ((current_item++))
        show_progress $current_item $total_items "OCD removed"
    fi
    
    # Ask about core
    echo ""
    if confirm "Remove OpenChamber Core too? (not recommended if using other tools)" "n"; then
        if [ -n "$pm" ]; then
            (
                $pm uninstall -g $CORE_PKG 2>&1
            ) > /tmp/oc-uninstall.log 2>&1 &
            spinner "Removing OpenChamber Core..." $!
            wait $!
        fi
    fi
    ((current_item++))
    show_progress $current_item $total_items "Components removed"
    
    # Remove shortcuts
    echo ""
    local os=$(uname -s)
    if [ "$os" = "Linux" ]; then
        rm -f "$HOME/.local/share/applications/ocd.desktop"
        echo -e "  ${BRIGHT_GREEN}Linux desktop entry removed${NC}"
    elif [ "$os" = "Darwin" ]; then
        rm -rf "$HOME/Applications/$APP_NAME.app"
        echo -e "  ${BRIGHT_GREEN}macOS app bundle removed${NC}"
    fi
    ((current_item++))
    show_progress $current_item $total_items "Shortcuts removed"
    
    # Remove aliases
    local shell_config=""
    if [ -f "$HOME/.zshrc" ]; then
        shell_config="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        shell_config="$HOME/.bashrc"
    fi
    
    if [ -n "$shell_config" ]; then
        sed -i.bak '/alias ocd=/d' "$shell_config" 2>/dev/null || true
        sed -i.bak '/alias openchamber-desktop=/d' "$shell_config" 2>/dev/null || true
        rm -f "${shell_config}.bak"
        echo -e "  ${BRIGHT_GREEN}Shell aliases removed${NC}"
    fi
    
    echo ""
    draw_box "UNINSTALLATION COMPLETE"
    echo ""
    echo -e "  ${BRIGHT_GREEN}OpenChamber Desktop has been removed${NC}"
    echo ""
    echo -e "  ${DIM}To reinstall, run this script again and select Install${NC}"
    echo ""
    
    echo -e "  ${BRIGHT_YELLOW}Press Enter to return to menu...${NC}"
    read < /dev/tty
}

# System info
system_info() {
    clear_screen
    draw_box "SYSTEM INFORMATION"
    echo ""
    
    local os=$(uname -s)
    local arch=$(uname -m)
    local pm=$(detect_package_manager)
    local pm_display=$(pm_display_name "$pm")
    
    # System section
    echo -e "  ${BRIGHT_CYAN}${BOLD}System${NC}"
    draw_line "─" "$DIM"
    echo -e "    ${BRIGHT_WHITE}Operating System:${NC}  ${os}"
    echo -e "    ${BRIGHT_WHITE}Architecture:${NC}      ${arch}"
    echo -e "    ${BRIGHT_WHITE}Package Manager:${NC}   ${pm_display}"
    echo ""
    
    # Installation section
    echo -e "  ${BRIGHT_CYAN}${BOLD}Installation Status${NC}"
    draw_line "─" "$DIM"
    
    if command_exists openchamber; then
        local oc_ver=$(openchamber --version 2>/dev/null || echo "Installed")
        echo -e "    ${BRIGHT_GREEN}OpenChamber Core:${NC}  ${oc_ver}"
    else
        echo -e "    ${BRIGHT_RED}OpenChamber Core:${NC}  Not installed"
    fi
    
    if command_exists $PKG_NAME; then
        local ocd_path=$(which $PKG_NAME 2>/dev/null)
        echo -e "    ${BRIGHT_GREEN}OCD:${NC}               Installed"
        echo -e "      ${DIM}Path: ${ocd_path}${NC}"
    else
        echo -e "    ${BRIGHT_RED}OCD:${NC}               Not installed"
    fi
    
    # Shortcuts section
    echo ""
    echo -e "  ${BRIGHT_CYAN}${BOLD}Desktop Integration${NC}"
    draw_line "─" "$DIM"
    
    if [ "$os" = "Linux" ]; then
        if [ -f "$HOME/.local/share/applications/ocd.desktop" ]; then
            echo -e "    ${BRIGHT_GREEN}Linux Desktop Entry:${NC} Present"
        else
            echo -e "    ${BRIGHT_RED}Linux Desktop Entry:${NC} Not found"
        fi
    elif [ "$os" = "Darwin" ]; then
        if [ -d "$HOME/Applications/$APP_NAME.app" ]; then
            echo -e "    ${BRIGHT_GREEN}macOS App Bundle:${NC}    Present"
        else
            echo -e "    ${BRIGHT_RED}macOS App Bundle:${NC}    Not found"
        fi
    fi
    
    # Aliases section
    local shell_config=""
    if [ -f "$HOME/.zshrc" ]; then
        shell_config="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        shell_config="$HOME/.bashrc"
    fi
    
    if [ -n "$shell_config" ]; then
        echo ""
        echo -e "  ${BRIGHT_CYAN}${BOLD}Shell Aliases${NC} (${DIM}in $(basename "$shell_config")${NC})"
        draw_line "─" "$DIM"
        
        if grep -q "alias ocd=" "$shell_config" 2>/dev/null; then
            echo -e "    ${BRIGHT_GREEN}ocd${NC}                 Configured"
        else
            echo -e "    ${BRIGHT_RED}ocd${NC}                 Not configured"
        fi
        
        if grep -q "alias openchamber-desktop=" "$shell_config" 2>/dev/null; then
            echo -e "    ${BRIGHT_GREEN}openchamber-desktop${NC} Configured"
        else
            echo -e "    ${BRIGHT_RED}openchamber-desktop${NC} Not configured"
        fi
    fi
    
    echo ""
    draw_line "═" "$BRIGHT_CYAN"
    echo ""
    echo -e "  ${DIM}For support and documentation:${NC}"
    echo -e "    ${UNDERLINE}https://${REPO}${NC}"
    echo ""
    
    echo -e "  ${BRIGHT_YELLOW}Press Enter to return to menu...${NC}"
    read < /dev/tty
}

# Main loop
main() {
    while true; do
        show_menu
        
        echo -ne "  ${BRIGHT_CYAN}Enter choice [1-4]:${NC} "
        read choice < /dev/tty
        
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
                echo ""
                center_text "${BRIGHT_GREEN}Thank you for using OpenChamber Desktop${NC}"
                center_text "${DIM}Goodbye!${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo ""
                echo -e "  ${BRIGHT_RED}Invalid option: ${choice}${NC}"
                echo -e "  ${DIM}Please enter a number between 1 and 4${NC}"
                sleep 1
                ;;
        esac
    done
}

# Run
main
