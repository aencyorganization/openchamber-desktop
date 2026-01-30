#!/bin/bash
set -e

APP_NAME="OpenChamber Desktop"
INSTALL_DIR="/Applications/$APP_NAME.app"

echo "Uninstalling $APP_NAME..."

rm -rf "$INSTALL_DIR"

echo "$APP_NAME has been removed successfully!"
