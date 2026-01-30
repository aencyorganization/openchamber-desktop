#!/bin/bash

# ==============================================================================
# OpenChamber Desktop - macOS Installation Script
# ==============================================================================
# Requirements:
# 1. Comprehensive error handling with set -euo pipefail
# 2. Logging using the logger.js system
# 3. Prerequisites check: Node.js >= 18, permissions
# 4. Source verification
# 5. Backup mechanism
# 6. Rollback mechanism
# 7. Post-installation verification
# 8. User (~/Applications) and System (/Applications) support
# 9. Proper App Bundle structure
# 10. Quarantine attribute handling
# ==============================================================================

# 1. Comprehensive error handling
set -euo pipefail

# Configuration
APP_NAME="OpenChamber Desktop"
APP_BUNDLE_NAME="OpenChamber Desktop.app"
BUNDLE_ID="com.openchamber.desktop"
EXECUTABLE_NAME="OpenChamber"

# Get directories
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VERSION=$(node -e "console.log(require('$SOURCE_DIR/package.json').version)" 2>/dev/null || echo "1.1.0")

# 8. Handle both user and system installs
USER_INSTALL=true
if [[ $EUID -eq 0 ]]; then
    USER_INSTALL=false
fi

# Parse arguments
for arg in "$@"; do
  case $arg in
    --system)
      USER_INSTALL=false
      ;;
    --user)
      USER_INSTALL=true
      ;;
    --help)
      echo "Usage: $0 [--user|--system]"
      echo "  --user:   Install to ~/Applications (default if not root)"
      echo "  --system: Install to /Applications (default if root)"
      exit 0
      ;;
  esac
done

if [ "$USER_INSTALL" = true ]; then
    INSTALL_BASE="$HOME/Applications"
    mkdir -p "$INSTALL_BASE"
else
    INSTALL_BASE="/Applications"
fi

INSTALL_DIR="$INSTALL_BASE/$APP_BUNDLE_NAME"
LOG_DIR="$HOME/Library/Logs/OpenChamber Desktop"
LOG_FILE="$LOG_DIR/install.log"
LOGGER_PATH="$SOURCE_DIR/scripts/lib/logger.js"

mkdir -p "$LOG_DIR"

# 2. Logging helper (using logger.js system)
log() {
    local level=$1
    local message=$2
    
    # Try to use node logger if available
    if command -v node &> /dev/null && [ -f "$LOGGER_PATH" ]; then
        # Escape double quotes for node command
        local safe_msg=$(echo "$message" | sed 's/"/\\"/g')
        node -e "
            try {
                const { Logger } = require('$LOGGER_PATH');
                const l = new Logger({
                    appName: 'openchamber-desktop',
                    logDir: '$LOG_DIR',
                    logFile: '$LOG_FILE',
                    logToConsole: true
                });
                if (typeof l['$level'] === 'function') {
                    l['$level'](\"$safe_msg\");
                } else {
                    l.info(\"[$level] $safe_msg\");
                }
            } catch (e) {
                console.log('[$level] ' + \"$safe_msg\");
            }
        " >> "$LOG_FILE" 2>&1 || echo "[$level] $message" | tee -a "$LOG_FILE"
    else
        echo "[$level] $message" | tee -a "$LOG_FILE"
    fi
}

# 6. Rollback mechanism
BACKUP_PATH=""
rollback() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "error" "Installation failed with exit code $exit_code. Initiating rollback..."
        
        if [ -n "$BACKUP_PATH" ] && [ -d "$BACKUP_PATH" ]; then
            log "info" "Restoring previous installation from backup..."
            rm -rf "$INSTALL_DIR"
            cp -Ra "$BACKUP_PATH" "$INSTALL_DIR"
            log "success" "Restored previous installation."
        else
            log "info" "No backup found or creation failed. Cleaning up partial installation..."
            rm -rf "$INSTALL_DIR"
        fi
        
        log "error" "Installation aborted."
        exit $exit_code
    fi
}

# Set traps
trap rollback ERR
trap 'rm -rf "$BACKUP_PATH" 2>/dev/null || true' EXIT

# 3. Check prerequisites
check_prerequisites() {
    log "info" "Verifying system requirements..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        log "error" "Node.js is not installed. Required version: >= 18."
        return 1
    fi
    
    local node_ver=$(node -v | cut -d 'v' -f 2)
    local major_ver=$(echo "$node_ver" | cut -d '.' -f 1)
    if [ "$major_ver" -lt 18 ]; then
        log "error" "Node.js version $node_ver detected. Required: >= 18."
        return 1
    fi
    log "success" "Node.js $node_ver detected."

    # Check curl and unzip
    if ! command -v curl &> /dev/null; then
        log "error" "curl is required but not installed."
        return 1
    fi
    if ! command -v unzip &> /dev/null; then
        log "error" "unzip is required but not installed."
        return 1
    fi

    # Check permissions
    local dir_to_check
    if [ -d "$INSTALL_DIR" ]; then
        dir_to_check="$INSTALL_DIR"
    else
        dir_to_check="$(dirname "$INSTALL_DIR")"
    fi
    
    if [ ! -w "$dir_to_check" ]; then
        log "error" "No write permission for $dir_to_check. Please run with sudo for system-wide installation."
        return 1
    fi
    log "success" "Write permissions verified for $dir_to_check."
    
    return 0
}

# 4. Verify source files
verify_source() {
    log "info" "Verifying source files..."
    local missing=()
    
    [ ! -d "$SOURCE_DIR/bin" ] && missing+=("bin/")
    [ ! -d "$SOURCE_DIR/resources" ] && missing+=("resources/")
    [ ! -f "$SOURCE_DIR/package.json" ] && missing+=("package.json")
    
    if [ ${#missing[@]} -gt 0 ]; then
        log "warn" "Local source files missing: ${missing[*]}"
        return 1
    fi
    
    log "success" "Local source files verified."
    return 0
}

# Main Installation Logic
install() {
    log "info" "Starting installation of $APP_NAME v$VERSION..."
    log "info" "Target directory: $INSTALL_DIR"

    # Step 1: Prerequisites
    if ! check_prerequisites; then
        exit 1
    fi

    # Step 2: Backup existing
    if [ -d "$INSTALL_DIR" ]; then
        log "info" "Creating backup of existing installation..."
        BACKUP_PATH="$(mktemp -d)/$APP_BUNDLE_NAME.bak"
        cp -Ra "$INSTALL_DIR" "$BACKUP_PATH"
        log "success" "Backup created at $BACKUP_PATH"
    fi

    # Step 3: Create Bundle Structure
    log "info" "Creating $APP_BUNDLE_NAME structure..."
    mkdir -p "$INSTALL_DIR/Contents/MacOS"
    mkdir -p "$INSTALL_DIR/Contents/Resources"

    # Step 4: Copy/Download files
    if verify_source; then
        log "info" "Copying files from source directory..."
        cp -Ra "$SOURCE_DIR/bin" "$INSTALL_DIR/Contents/Resources/"
        cp -Ra "$SOURCE_DIR/resources" "$INSTALL_DIR/Contents/Resources/"
        
        if [ -d "$SOURCE_DIR/assets" ]; then
            cp -Ra "$SOURCE_DIR/assets" "$INSTALL_DIR/Contents/Resources/"
        fi
        
        cp "$SOURCE_DIR/package.json" "$INSTALL_DIR/Contents/Resources/"
        cp "$SOURCE_DIR/neutralino.config.json" "$INSTALL_DIR/Contents/Resources/"
    else
        log "info" "Local source incomplete. Attempting to download latest release..."
        local temp_zip=$(mktemp)
        curl -L -s -o "$temp_zip" "https://github.com/aencyorganization/openchamber-desktop/releases/latest/download/openchamber-desktop-mac_universal.zip"
        if [ $? -ne 0 ]; then
            log "error" "Failed to download release from GitHub."
            exit 1
        fi
        unzip -q "$temp_zip" -d "$INSTALL_DIR/Contents/Resources/"
        rm -f "$temp_zip"
        log "success" "Downloaded and extracted latest release."
    fi

    # Step 5: Create Executable Wrapper
    log "info" "Creating executable wrapper..."
    cat <<EOF > "$INSTALL_DIR/Contents/MacOS/$EXECUTABLE_NAME"
#!/bin/bash
# OpenChamber Desktop Launcher
DIR="\$(cd "\$(dirname "\$0")" && pwd)"
cd "\$DIR/../Resources"

if command -v node &> /dev/null; then
    exec node bin/cli.js "\$@"
else
    # Try common Node.js locations or show error
    NODE_BIN="/usr/local/bin/node"
    if [ -x "\$NODE_BIN" ]; then
        exec "\$NODE_BIN" bin/cli.js "\$@"
    else
        osascript -e 'display alert "Node.js Not Found" message "OpenChamber Desktop requires Node.js >= 18. Please install it from nodejs.org or using Homebrew." as critical'
        exit 1
    fi
fi
EOF
    chmod +x "$INSTALL_DIR/Contents/MacOS/$EXECUTABLE_NAME"

    # Step 6: Create Info.plist
    log "info" "Generating Info.plist..."
    cat <<EOF > "$INSTALL_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$EXECUTABLE_NAME</string>
    <key>CFBundleIconFile</key>
    <string>icon.icns</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
</dict>
</plist>
EOF

    # Step 7: Create PkgInfo
    echo -n "APPL????" > "$INSTALL_DIR/Contents/PkgInfo"

    # Step 8: Handle quarantine attributes
    log "info" "Removing quarantine attributes if present..."
    xattr -rd com.apple.quarantine "$INSTALL_DIR" 2>/dev/null || true

    # Step 9: Verify installation
    log "info" "Verifying installation..."
    if [ ! -x "$INSTALL_DIR/Contents/MacOS/$EXECUTABLE_NAME" ]; then
        log "error" "Verification failed: Executable not found or not executable."
        exit 1
    fi
    
    if [ ! -f "$INSTALL_DIR/Contents/Info.plist" ]; then
        log "error" "Verification failed: Info.plist missing."
        exit 1
    fi

    log "success" "Installation of $APP_NAME completed successfully!"
    
    echo ""
    echo "===================================================="
    echo "  $APP_NAME v$VERSION"
    echo "===================================================="
    echo "  Installed to: $INSTALL_DIR"
    echo "  Logs:         $LOG_FILE"
    echo "===================================================="
    echo "  You can now launch it from your Applications folder."
    echo ""
}

# Start installation
install
