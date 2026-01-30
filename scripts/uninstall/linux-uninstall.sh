#!/bin/bash
set -e

APP_NAME="openchamber-desktop"
INSTALL_DIR="$HOME/.local/lib/openchamber-desktop"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"

if [ "$EUID" -eq 0 ]; then
    INSTALL_DIR="/opt/openchamber-desktop"
    BIN_DIR="/usr/local/bin"
    DESKTOP_DIR="/usr/share/applications"
fi

echo "Uninstalling OpenChamber Desktop..."

rm -rf "$INSTALL_DIR"
rm -f "$BIN_DIR/$APP_NAME"
rm -f "$DESKTOP_DIR/$APP_NAME.desktop"

echo "OpenChamber Desktop has been removed successfully!"
