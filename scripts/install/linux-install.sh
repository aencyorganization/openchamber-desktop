#!/bin/bash
set -e

APP_NAME="openchamber-desktop"
DISPLAY_NAME="OpenChamber Desktop"
INSTALL_DIR="$HOME/.local/lib/openchamber-desktop"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    INSTALL_DIR="/opt/openchamber-desktop"
    BIN_DIR="/usr/local/bin"
    DESKTOP_DIR="/usr/share/applications"
fi

echo "Installing $DISPLAY_NAME..."

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR"

# Determine source
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [ -d "$SOURCE_DIR/bin" ] && [ -d "$SOURCE_DIR/resources" ]; then
    echo "Copying files from $SOURCE_DIR..."
    cp -ra "$SOURCE_DIR/bin" "$INSTALL_DIR/"
    cp -ra "$SOURCE_DIR/resources" "$INSTALL_DIR/"
    cp -ra "$SOURCE_DIR/assets" "$INSTALL_DIR/" 2>/dev/null || true
    cp "$SOURCE_DIR/package.json" "$INSTALL_DIR/"
    cp "$SOURCE_DIR/neutralino.config.json" "$INSTALL_DIR/"
else
    echo "Source files not found, attempting to download latest release..."
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    curl -s https://api.github.com/repos/aencyorganization/openchamber-desktop/releases/latest \
    | grep "browser_download_url.*zip" \
    | cut -d '"' -f 4 \
    | xargs curl -L -o release.zip
    unzip release.zip -d "$INSTALL_DIR"
    rm -rf "$TEMP_DIR"
fi

# Create launcher script
cat <<EOF > "$BIN_DIR/$APP_NAME"
#!/bin/bash
node "$INSTALL_DIR/bin/cli.js" "\$@"
EOF
chmod +x "$BIN_DIR/$APP_NAME"

# Create .desktop file
cat <<EOF > "$DESKTOP_DIR/$APP_NAME.desktop"
[Desktop Entry]
Name=$DISPLAY_NAME
Exec=$BIN_DIR/$APP_NAME
Icon=$INSTALL_DIR/assets/openchamber-logo-dark.png
Type=Application
Categories=Utility;Development;
Comment=Desktop launcher for OpenChamber
Terminal=false
EOF

echo "$DISPLAY_NAME has been installed successfully!"
