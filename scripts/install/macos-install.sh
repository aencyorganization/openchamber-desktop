#!/bin/bash
set -e

APP_NAME="OpenChamber Desktop"
INSTALL_DIR="/Applications/$APP_NAME.app"

echo "Installing $APP_NAME..."

mkdir -p "$INSTALL_DIR/Contents/MacOS"
mkdir -p "$INSTALL_DIR/Contents/Resources"

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [ -d "$SOURCE_DIR/bin" ]; then
    echo "Copying files from $SOURCE_DIR..."
    cp -ra "$SOURCE_DIR/bin" "$INSTALL_DIR/Contents/Resources/"
    cp -ra "$SOURCE_DIR/resources" "$INSTALL_DIR/Contents/Resources/"
    cp -ra "$SOURCE_DIR/assets" "$INSTALL_DIR/Contents/Resources/"
    cp "$SOURCE_DIR/package.json" "$INSTALL_DIR/Contents/Resources/"
    cp "$SOURCE_DIR/neutralino.config.json" "$INSTALL_DIR/Contents/Resources/"
else
    echo "Source not found, downloading latest release..."
    TEMP_DIR=$(mktemp -d)
    curl -L -o "$TEMP_DIR/release.zip" "https://github.com/aencyorganization/openchamber-desktop/releases/latest/download/openchamber-desktop-mac_universal.zip"
    unzip "$TEMP_DIR/release.zip" -d "$INSTALL_DIR/Contents/Resources/"
    rm -rf "$TEMP_DIR"
fi

# Create executable wrapper
cat <<EOF > "$INSTALL_DIR/Contents/MacOS/OpenChamber"
#!/bin/bash
DIR="\$(cd "\$(dirname "\$0")" && pwd)"
cd "\$DIR/../Resources"
node bin/cli.js "\$@"
EOF
chmod +x "$INSTALL_DIR/Contents/MacOS/OpenChamber"

# Create Info.plist
cat <<EOF > "$INSTALL_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>OpenChamber</string>
    <key>CFBundleIconFile</key>
    <string>icon.icns</string>
    <key>CFBundleIdentifier</key>
    <string>com.openchamber.desktop</string>
    <key>CFBundleName</key>
    <string>OpenChamber Desktop</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.1.0</string>
</dict>
</plist>
EOF

echo "$APP_NAME installed successfully in /Applications!"
