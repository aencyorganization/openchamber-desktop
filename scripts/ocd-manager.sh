#!/bin/bash

# OpenChamber Desktop (OCD) Manager with Gum
# Beautiful TUI installer using Charm.sh Gum
# Usage: curl -fsSL .../ocd-manager.sh | bash

set -e

# Colors for fallback (when gum is not available)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
APP_NAME="OpenChamber Desktop"
PKG_NAME="openchamber-desktop"
CORE_PKG="@openchamber/web"
REPO_URL="https://github.com/aencyorganization/openchamber-desktop"

# Check and install Gum
check_install_gum() {
    if command -v gum &> /dev/null; then
        return 0
    fi
    
    echo -e "${CYAN}Installing Gum (Charm.sh)...${NC}"
    
    # Detect OS and architecture
    OS=$(uname -s)
    ARCH=$(uname -m)
    
    # Map architecture names
    case "$ARCH" in
        x86_64) ARCH="x86_64" ;;
        amd64) ARCH="x86_64" ;;
        arm64) ARCH="arm64" ;;
        aarch64) ARCH="arm64" ;;
        armv7l) ARCH="armv7" ;;
    esac
    
    # Map OS names
    case "$OS" in
        Linux) OS="Linux" ;;
        Darwin) OS="Darwin" ;;
    esac
    
    # Download Gum
    GUM_VERSION="0.17.0"
    GUM_URL="https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/gum_${GUM_VERSION}_${OS}_${ARCH}.tar.gz"
    
    TMP_DIR=$(mktemp -d)
    if curl -fsSL "$GUM_URL" -o "$TMP_DIR/gum.tar.gz" 2>/dev/null; then
        tar -xzf "$TMP_DIR/gum.tar.gz" -C "$TMP_DIR" 2>/dev/null
        if [ -f "$TMP_DIR/gum" ]; then
            # Try to install to /usr/local/bin, fallback to ~/.local/bin
            if [ -w "/usr/local/bin" ]; then
                mv "$TMP_DIR/gum" /usr/local/bin/gum
                chmod +x /usr/local/bin/gum
            elif [ -d "$HOME/.local/bin" ]; then
                mv "$TMP_DIR/gum" "$HOME/.local/bin/gum"
                chmod +x "$HOME/.local/bin/gum"
                export PATH="$HOME/.local/bin:$PATH"
            else
                # Use from temp directory
                export PATH="$TMP_DIR:$PATH"
            fi
            echo -e "${GREEN}✓ Gum installed${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Could not install Gum, using fallback mode${NC}"
        USE_FALLBACK=1
    fi
    
    rm -rf "$TMP_DIR"
}

# Header with Gum or fallback
show_header() {
    if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
        gum style \
            --border double \
            --border-foreground 212 \
            --align center \
            --width 50 \
            --margin "1 2" \
            --padding "1 2" \
            "OpenChamber Desktop" "Manager"
    else
        clear
        echo -e "${CYAN}"
        echo "  ██████╗  ██████╗██████╗ "
        echo " ██╔═══██╗██╔════╝██╔══██╗"
        echo " ██║   ██║██║     ██║  ██║"
        echo " ██║   ██║██║     ██║  ██║"
        echo " ╚██████╔╝╚██████╗██████╔╝"
        echo "  ╚═════╝  ╚═════╝╚═════╝ "
        echo -e "   ${APP_NAME}${NC}"
        echo ""
    fi
}

# Menu with Gum or fallback
show_menu() {
    if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
        CHOICE=$(gum choose \
            --header "Select an option:" \
            --header.foreground 212 \
            "📦 Install/Update OCD" \
            "🗑️  Uninstall" \
            "ℹ️  System Info" \
            "🚪 Exit")
        echo "$CHOICE"
    else
        echo ""
        echo -e "${CYAN}1)${NC} 📦 Install/Update OCD"
        echo -e "${CYAN}2)${NC} 🗑️  Uninstall"
        echo -e "${CYAN}3)${NC} ℹ️  System Info"
        echo -e "${CYAN}4)${NC} 🚪 Exit"
        echo ""
        read -p "Select option [1-4]: " choice
        case $choice in
            1) echo "📦 Install/Update OCD" ;;
            2) echo "🗑️  Uninstall" ;;
            3) echo "ℹ️  System Info" ;;
            4) echo "🚪 Exit" ;;
        esac
    fi
}

# Get package manager
get_package_manager() {
    if command -v bun &> /dev/null; then
        echo "bun"
    elif command -v pnpm &> /dev/null; then
        echo "pnpm"
    elif command -v npm &> /dev/null; then
        echo "npm"
    else
        echo ""
    fi
}

# Install package manager
install_package_manager() {
    if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
        gum spin --spinner dot --title "Installing Bun..." -- \
            bash -c 'curl -fsSL https://bun.sh/install | bash'
    else
        echo -e "${CYAN}Installing Bun...${NC}"
        curl -fsSL https://bun.sh/install | bash
    fi
    
    # Source bun
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
}

# Install flow with Gum
install_flow() {
    show_header
    
    if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
        # Step 1: Choose package manager
        PM=$(gum choose \
            --header "Select package manager:" \
            "🥟 Bun (Recommended - Fastest)" \
            "📦 pnpm" \
            "📦 npm" \
            "🔍 Auto-detect")
        
        # Extract just the name
        case "$PM" in
            *Bun*) PM="bun" ;;
            *pnpm*) PM="pnpm" ;;
            *npm*) PM="npm" ;;
            *Auto*) PM="auto" ;;
        esac
    else
        echo ""
        echo -e "${CYAN}Select package manager:${NC}"
        echo "1) 🥟 Bun (Recommended - Fastest)"
        echo "2) 📦 pnpm"
        echo "3) 📦 npm"
        echo "4) 🔍 Auto-detect"
        read -p "[1-4]: " pm_choice
        case $pm_choice in
            1) PM="bun" ;;
            2) PM="pnpm" ;;
            3) PM="npm" ;;
            4) PM="auto" ;;
        esac
    fi
    
    # Auto-detect or install
    if [ "$PM" = "auto" ] || [ -z "$PM" ]; then
        PM=$(get_package_manager)
        if [ -z "$PM" ]; then
            install_package_manager
            PM="bun"
        fi
    elif [ "$PM" = "bun" ] && ! command -v bun &> /dev/null; then
        install_package_manager
    fi
    
    # Show selected
    if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
        gum style --foreground 212 "Using: $PM"
    else
        echo -e "${GREEN}Using: $PM${NC}"
    fi
    
    # Step 2: Check/OpenChamber
    if ! command -v openchamber &> /dev/null; then
        if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
            gum spin --spinner dot --title "Installing OpenChamber Core..." -- \
                bash -c "$PM install -g $CORE_PKG"
            gum style --foreground 82 "✓ OpenChamber Core installed"
        else
            echo -e "${CYAN}Installing OpenChamber Core...${NC}"
            $PM install -g $CORE_PKG
            echo -e "${GREEN}✓ OpenChamber Core installed${NC}"
        fi
    else
        if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
            gum style --foreground 82 "✓ OpenChamber already installed"
        else
            echo -e "${GREEN}✓ OpenChamber already installed${NC}"
        fi
    fi
    
    # Step 3: Install OCD
    if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
        gum spin --spinner dot --title "Installing OCD..." -- \
            bash -c "$PM install -g $PKG_NAME"
        gum style --foreground 82 "✓ OCD installed"
    else
        echo -e "${CYAN}Installing OCD...${NC}"
        $PM install -g $PKG_NAME
        echo -e "${GREEN}✓ OCD installed${NC}"
    fi
    
    # Step 4: Aliases
    if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
        ALIASES=$(gum choose --no-limit \
            --header "Select aliases to create:" \
            "ocd" \
            "openchamber-desktop" \
            "custom")
    else
        echo ""
        echo -e "${CYAN}Create aliases?${NC}"
        read -p "ocd [Y/n]: " a1
        read -p "openchamber-desktop [Y/n]: " a2
        ALIASES=""
        [[ ! "$a1" =~ ^[Nn]$ ]] && ALIASES="ocd"
        [[ ! "$a2" =~ ^[Nn]$ ]] && ALIASES="$ALIASES openchamber-desktop"
    fi
    
    # Add custom alias
    if echo "$ALIASES" | grep -q "custom"; then
        if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
            CUSTOM=$(gum input --placeholder "Enter custom alias name")
        else
            read -p "Enter custom alias name: " CUSTOM
        fi
        ALIASES=$(echo "$ALIASES" | sed 's/custom//')
        ALIASES="$ALIASES $CUSTOM"
    fi
    
    # Add to shell config
    SHELL_CONFIG=""
    if [ -f "$HOME/.zshrc" ]; then SHELL_CONFIG="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then SHELL_CONFIG="$HOME/.bashrc"
    fi
    
    if [ -n "$SHELL_CONFIG" ]; then
        for alias in $ALIASES; do
            if ! grep -q "alias $alias=" "$SHELL_CONFIG" 2>/dev/null; then
                echo "alias $alias='$PKG_NAME'" >> "$SHELL_CONFIG"
            fi
        done
        if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
            gum style --foreground 82 "✓ Aliases added to $(basename $SHELL_CONFIG)"
        else
            echo -e "${GREEN}✓ Aliases added${NC}"
        fi
    fi
    
    # Step 5: Shortcuts
    if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
        if gum confirm "Create desktop shortcuts?"; then
            create_shortcuts
        fi
    else
        read -p "Create desktop shortcuts? [Y/n]: " sc
        [[ ! "$sc" =~ ^[Nn]$ ]] && create_shortcuts
    fi
    
    # Success message
    if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
        gum style \
            --border double \
            --border-foreground 82 \
            --align center \
            --width 40 \
            --margin "1 2" \
            --padding "1 2" \
            "✓ Installation Complete!" \
            "" \
            "Run 'ocd' to start"
    else
        echo ""
        echo -e "${GREEN}✓ Installation Complete!${NC}"
        echo -e "Run ${CYAN}ocd${NC} to start"
    fi
    
    read -p "Press Enter to continue..."
}

# Create desktop shortcuts
create_shortcuts() {
    OS=$(uname -s)
    ICON_PATH="$HOME/.config/openchamber/icon.png"
    
    # Ensure icon directory exists
    mkdir -p "$HOME/.config/openchamber"
    
    # Download icon if not present
    if [ ! -f "$ICON_PATH" ]; then
        curl -fsSL "https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/assets/openchamber-logo-dark.png" -o "$ICON_PATH" 2>/dev/null || true
    fi
    
    if [ "$OS" = "Linux" ]; then
        # Create .desktop entry
        ENTRY_PATH="$HOME/.local/share/applications/ocd.desktop"
        mkdir -p "$(dirname "$ENTRY_PATH")"
        
        cat > "$ENTRY_PATH" <<EOF
[Desktop Entry]
Name=$APP_NAME
Comment=OpenChamber Desktop Launcher
Exec=$PKG_NAME
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Development;Utility;
StartupNotify=false
EOF
        chmod +x "$ENTRY_PATH"
        
        if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
            gum style --foreground 82 "✓ Desktop entry created"
        else
            echo -e "${GREEN}✓ Desktop entry created${NC}"
        fi
        
    elif [ "$OS" = "Darwin" ]; then
        # macOS app bundle
        APP_PATH="$HOME/Applications/$APP_NAME.app"
        mkdir -p "$APP_PATH/Contents/MacOS"
        mkdir -p "$APP_PATH/Contents/Resources"
        
        cat > "$APP_PATH/Contents/MacOS/launcher" <<EOF
#!/bin/bash
export PATH="/usr/local/bin:/opt/homebrew/bin:\$HOME/.bun/bin:\$PATH"
$PKG_NAME
EOF
        chmod +x "$APP_PATH/Contents/MacOS/launcher"
        
        cat > "$APP_PATH/Contents/Info.plist" <<EOF
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
        
        [ -f "$ICON_PATH" ] && cp "$ICON_PATH" "$APP_PATH/Contents/Resources/icon.png"
        
        if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
            gum style --foreground 82 "✓ App bundle created in ~/Applications"
        else
            echo -e "${GREEN}✓ App bundle created${NC}"
        fi
    fi
}

# Uninstall flow
uninstall_flow() {
    show_header
    
    if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
        if ! gum confirm --affirmative "Yes, uninstall" --negative "Cancel" "Are you sure you want to uninstall?"; then
            return
        fi
    else
        read -p "Are you sure? Type 'yes' to confirm: " confirm
        [ "$confirm" != "yes" ] && return
    fi
    
    PM=$(get_package_manager)
    
    # Remove OCD
    if [ -n "$PM" ]; then
        if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
            gum spin --spinner dot --title "Removing OCD..." -- \
                bash -c "$PM uninstall -g $PKG_NAME 2>/dev/null || true"
            gum style --foreground 212 "✓ OCD removed"
        else
            echo -e "${CYAN}Removing OCD...${NC}"
            $PM uninstall -g $PKG_NAME 2>/dev/null || true
            echo -e "${GREEN}✓ OCD removed${NC}"
        fi
    fi
    
    # Ask about core
    if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
        if gum confirm "Remove OpenChamber Core too?"; then
            gum spin --spinner dot --title "Removing Core..." -- \
                bash -c "$PM uninstall -g $CORE_PKG 2>/dev/null || true"
            gum style --foreground 212 "✓ Core removed"
        fi
    else
        read -p "Remove OpenChamber Core too? [y/N]: " rm_core
        if [[ "$rm_core" =~ ^[Yy]$ ]]; then
            $PM uninstall -g $CORE_PKG 2>/dev/null || true
            echo -e "${GREEN}✓ Core removed${NC}"
        fi
    fi
    
    # Remove shortcuts
    OS=$(uname -s)
    if [ "$OS" = "Linux" ]; then
        rm -f "$HOME/.local/share/applications/ocd.desktop"
    elif [ "$OS" = "Darwin" ]; then
        rm -rf "$HOME/Applications/$APP_NAME.app"
    fi
    
    # Remove aliases
    SHELL_CONFIG=""
    if [ -f "$HOME/.zshrc" ]; then SHELL_CONFIG="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then SHELL_CONFIG="$HOME/.bashrc"
    fi
    
    if [ -n "$SHELL_CONFIG" ]; then
        sed -i '/alias ocd=/d' "$SHELL_CONFIG" 2>/dev/null || sed -i '' '/alias ocd=/d' "$SHELL_CONFIG" 2>/dev/null || true
        sed -i '/alias openchamber-desktop=/d' "$SHELL_CONFIG" 2>/dev/null || sed -i '' '/alias openchamber-desktop=/d' "$SHELL_CONFIG" 2>/dev/null || true
    fi
    
    if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
        gum style \
            --border double \
            --border-foreground 212 \
            --align center \
            --width 40 \
            --margin "1 2" \
            --padding "1 2" \
            "✓ Uninstall Complete"
    else
        echo -e "${GREEN}✓ Uninstall Complete${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

# System info
system_info() {
    show_header
    
    OS=$(uname -s)
    ARCH=$(uname -m)
    PM=$(get_package_manager || echo "None")
    
    if command -v openchamber &> /dev/null; then
        OC_VER=$(openchamber --version 2>/dev/null || echo "Installed")
    else
        OC_VER="Not Installed"
    fi
    
    if command -v $PKG_NAME &> /dev/null; then
        OCD_VER=$($PKG_NAME --version 2>/dev/null || echo "Installed")
    else
        OCD_VER="Not Installed"
    fi
    
    if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
        # Beautiful table with Gum
        echo ""
        gum style --foreground 212 --bold "System Information"
        echo ""
        printf "%-20s %s\n" "OS:" "$OS"
        printf "%-20s %s\n" "Architecture:" "$ARCH"
        printf "%-20s %s\n" "Package Manager:" "$PM"
        printf "%-20s %s\n" "OpenChamber:" "$OC_VER"
        printf "%-20s %s\n" "OCD:" "$OCD_VER"
        echo ""
    else
        echo ""
        echo -e "${CYAN}System Information${NC}"
        echo "-------------------"
        echo -e "OS: ${GREEN}$OS${NC}"
        echo -e "Architecture: ${GREEN}$ARCH${NC}"
        echo -e "Package Manager: ${GREEN}$PM${NC}"
        echo -e "OpenChamber: ${GREEN}$OC_VER${NC}"
        echo -e "OCD: ${GREEN}$OCD_VER${NC}"
        echo ""
    fi
    
    read -p "Press Enter to continue..."
}

# Main
main() {
    check_install_gum
    
    while true; do
        show_header
        CHOICE=$(show_menu)
        
        case "$CHOICE" in
            *Install*)
                install_flow
                ;;
            *Uninstall*)
                uninstall_flow
                ;;
            *System*)
                system_info
                ;;
            *Exit*)
                if command -v gum &> /dev/null && [ -z "$USE_FALLBACK" ]; then
                    gum style --foreground 212 "Goodbye! 👋"
                else
                    echo -e "${CYAN}Goodbye!${NC}"
                fi
                exit 0
                ;;
        esac
    done
}

main
