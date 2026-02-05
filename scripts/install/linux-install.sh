#!/bin/bash

# ==============================================================================
# OpenChamber Desktop Linux Installation Script
# ==============================================================================
# This script handles both user-level and system-wide installations.
# ==============================================================================

set -euo pipefail

# --- Configuration ---
APP_NAME="openchamber-desktop"
DISPLAY_NAME="OpenChamber Desktop"
MIN_NODE_VERSION=18
REPO_URL="aencyorganization/openchamber-desktop"

# --- Path Detection ---
if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    INSTALL_ROOT="/opt"
    BIN_ROOT="/usr/local/bin"
    DESKTOP_ROOT="/usr/share/applications"
    LOG_FILE="/var/log/openchamber-desktop-install.log"
    info_prefix="[System]"
else
    INSTALL_ROOT="$HOME/.local/lib"
    BIN_ROOT="$HOME/.local/bin"
    DESKTOP_ROOT="$HOME/.local/share/applications"
    LOG_FILE="$HOME/.local/share/openchamber-desktop/logs/install.log"
    info_prefix="[User]"
fi

INSTALL_DIR="$INSTALL_ROOT/$APP_NAME"
BIN_PATH="$BIN_ROOT/$APP_NAME"
DESKTOP_FILE="$DESKTOP_ROOT/$APP_NAME.desktop"
BACKUP_DIR="${INSTALL_DIR}_backup_$(date +%Y%m%d_%H%M%S)"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# --- Logging Functions ---
log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    printf "[%s] [%-5s] %s %s\n" "$timestamp" "$level" "$info_prefix" "$message" | tee -a "$LOG_FILE"
}

info() { log "INFO" "$1"; }
warn() { log "WARN" "$1"; }
error() { log "ERROR" "$1" >&2; }

# --- Rollback Mechanism ---
cleanup_on_failure() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        error "Installation failed with exit code $exit_code. Initiating rollback..."
        
        if [ -d "$BACKUP_DIR" ]; then
            info "Restoring from backup: $BACKUP_DIR"
            [ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR"
            mv "$BACKUP_DIR" "$INSTALL_DIR"
        else
            info "No backup found. Cleaning up partial installation..."
            [ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR"
            [ -f "$BIN_PATH" ] && rm -f "$BIN_PATH"
            [ -f "$DESKTOP_FILE" ] && rm -f "$DESKTOP_FILE"
        fi
        
        info "Rollback completed."
    fi
}
trap cleanup_on_failure EXIT

# --- Prerequisite Checks ---
check_prerequisites() {
    info "Checking prerequisites..."
    
    # Node.js check
    if ! command -v node &> /dev/null; then
        error "Node.js is not found in PATH. Please install Node.js >= $MIN_NODE_VERSION."
        return 1
    fi
    
    local node_version
    node_version=$(node --version | sed 's/v//' | cut -d. -f1)
    if [ "$node_version" -lt "$MIN_NODE_VERSION" ]; then
        error "Node.js version $node_version detected, but >= $MIN_NODE_VERSION is required."
        return 1
    fi
    info "Node.js $(node --version) found."

    # Write permissions check
    local target_dirs=("$INSTALL_ROOT" "$BIN_ROOT" "$DESKTOP_ROOT")
    for dir in "${target_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            info "Creating directory $dir..."
            mkdir -p "$dir" || { error "Failed to create $dir"; return 1; }
        fi
        if [ ! -w "$dir" ]; then
            error "No write permission to $dir. Try running with sudo?"
            return 1
        fi
    done
    
    return 0
}

# --- Desktop Integration ---
integrate_desktop() {
    info "Integrating with desktop environment..."
    
    # Detect the correct binary name for WM_CLASS
    local detected_arch
    detected_arch=$(uname -m)
    local wm_class
    case "$detected_arch" in
        x86_64) wm_class="neutralino-linux_x64" ;;
        aarch64|arm64) wm_class="neutralino-linux_arm64" ;;
        armv7l|armhf) wm_class="neutralino-linux_armhf" ;;
        *) wm_class="neutralino-linux_x64" ;;
    esac
    
    # Copy icon to a standard location for better compatibility
    local icon_dir="$HOME/.local/share/icons/hicolor/256x256/apps"
    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        icon_dir="/usr/share/icons/hicolor/256x256/apps"
    fi
    
    mkdir -p "$icon_dir"
    if [ -f "$INSTALL_DIR/assets/openchamber-logo-dark.png" ]; then
        cp "$INSTALL_DIR/assets/openchamber-logo-dark.png" "$icon_dir/openchamber-desktop.png"
        info "Icon installed to $icon_dir/openchamber-desktop.png"
    fi
    
    # Create .desktop file with correct WM_CLASS matching
    # The WM_CLASS is set by the Neutralino binary, not our wrapper script
    cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=$DISPLAY_NAME
Comment=Desktop launcher for OpenChamber
Exec=$BIN_PATH
Icon=openchamber-desktop
Type=Application
Categories=Utility;Development;
Terminal=false
Keywords=OpenChamber;Desktop;Launcher;
StartupNotify=true
StartupWMClass=$wm_class
X-Desktop-File-Install-Version=0.26
X-KDE-SubstituteUID=false
X-KDE-Username=
MimeType=x-scheme-handler/openchamber;
EOF
    chmod 644 "$DESKTOP_FILE"

    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$DESKTOP_ROOT" || warn "Could not update desktop database."
    fi
    
    # Update icon cache if possible
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || true
    fi
}

# --- Main Installation Logic ---
main() {
    check_prerequisites

    info "Starting installation for $DISPLAY_NAME..."
    
    # Determine source directory
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local source_dir
    source_dir="$(cd "$script_dir/../.." && pwd)"
    
    info "Source directory identified as: $source_dir"

    # Handle source files (local build vs download)
    if [ -d "$source_dir/bin" ] && [ -d "$source_dir/resources" ]; then
        info "Installing from local source files..."
        
        # Verify critical files
        local required=("bin/cli.js" "package.json" "neutralino.config.json")
        for f in "${required[@]}"; do
            if [ ! -f "$source_dir/$f" ]; then
                error "Required file missing in source: $source_dir/$f"
                return 1
            fi
        done
        
        # Backup existing installation
        if [ -d "$INSTALL_DIR" ]; then
            info "Backing up existing installation to $BACKUP_DIR..."
            mv "$INSTALL_DIR" "$BACKUP_DIR"
        fi

        # Copy files
        mkdir -p "$INSTALL_DIR"
        cp -ra "$source_dir/bin" "$INSTALL_DIR/"
        cp -ra "$source_dir/resources" "$INSTALL_DIR/"
        [ -d "$source_dir/assets" ] && cp -ra "$source_dir/assets" "$INSTALL_DIR/"
        cp "$source_dir/package.json" "$INSTALL_DIR/"
        cp "$source_dir/neutralino.config.json" "$INSTALL_DIR/"
        
    else
        info "Local source files not found or incomplete. Attempting to download latest release..."
        
        if ! command -v curl &> /dev/null || ! command -v unzip &> /dev/null; then
            error "curl and unzip are required for downloading releases."
            return 1
        fi

        local temp_dir
        temp_dir=$(mktemp -d)
        pushd "$temp_dir" > /dev/null
        
        info "Fetching latest release info from GitHub..."
        local download_url
        download_url=$(curl -s "https://api.github.com/repos/$REPO_URL/releases/latest" \
            | grep "browser_download_url.*linux.*\.zip" \
            | cut -d '"' -f 4 || echo "")
        
        if [ -z "$download_url" ]; then
            # Fallback to any zip if linux specific not found
            download_url=$(curl -s "https://api.github.com/repos/$REPO_URL/releases/latest" \
                | grep "browser_download_url.*\.zip" \
                | head -n 1 \
                | cut -d '"' -f 4 || echo "")
        fi

        if [ -z "$download_url" ]; then
            error "Could not find a valid release download URL."
            popd > /dev/null
            return 1
        fi

        info "Downloading $download_url..."
        curl -L -o release.zip "$download_url"
        
        # Backup existing installation
        if [ -d "$INSTALL_DIR" ]; then
            info "Backing up existing installation to $BACKUP_DIR..."
            mv "$INSTALL_DIR" "$BACKUP_DIR"
        fi
        
        mkdir -p "$INSTALL_DIR"
        unzip -q release.zip -d "$INSTALL_DIR"
        
        popd > /dev/null
        rm -rf "$temp_dir"
    fi

    # Create symlink for binary with correct name (fixes "Neutralino X64" showing in taskbar)
    info "Creating binary symlink with app name..."
    local detected_arch
    detected_arch=$(uname -m)
    local binary_name
    case "$detected_arch" in
        x86_64) binary_name="neutralino-linux_x64" ;;
        aarch64|arm64) binary_name="neutralino-linux_arm64" ;;
        armv7l|armhf) binary_name="neutralino-linux_armhf" ;;
        *) binary_name="neutralino-linux_x64" ;;
    esac
    
    if [ -f "$INSTALL_DIR/bin/$binary_name" ]; then
        ln -sf "$INSTALL_DIR/bin/$binary_name" "$INSTALL_DIR/bin/openchamber-launcher"
        info "Created symlink: openchamber-launcher -> $binary_name"
    fi

    # Create launcher script
    info "Creating launcher at $BIN_PATH..."
    cat <<EOF > "$BIN_PATH"
#!/bin/bash
# $DISPLAY_NAME Launcher
# Generated by install script on $(date)

if ! command -v node &> /dev/null; then
    echo "Error: Node.js is required but not found in PATH." >&2
    exit 1
fi

exec node "$INSTALL_DIR/bin/cli.js" "\$@"
EOF
    chmod +x "$BIN_PATH"

    # Desktop integration
    integrate_desktop

    # Verification
    info "Verifying installation..."
    if [ ! -f "$BIN_PATH" ] || [ ! -x "$BIN_PATH" ]; then
        error "Verification failed: Launcher script not found or not executable."
        return 1
    fi
    
    if [ ! -f "$INSTALL_DIR/bin/cli.js" ]; then
        error "Verification failed: Main entry point missing in $INSTALL_DIR."
        return 1
    fi

    info "$DISPLAY_NAME has been installed successfully!"
    info "You can launch it by running '$APP_NAME' or via your application menu."

    # Remove backup on success
    if [ -d "$BACKUP_DIR" ]; then
        info "Cleaning up backup..."
        rm -rf "$BACKUP_DIR"
    fi
    
    return 0
}

# Run main
if main "$@"; then
    exit 0
else
    exit 1
fi
