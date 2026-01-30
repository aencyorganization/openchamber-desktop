#!/bin/bash
#
# OpenChamber Desktop Uninstaller for macOS
# This script calls the unified Node.js uninstaller
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNINSTALL_JS="${SCRIPT_DIR}/uninstall.js"

echo "=========================================="
echo "  OpenChamber Desktop Uninstaller"
echo "=========================================="
echo ""

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo -e "${RED}ERROR: Node.js is not installed or not in PATH${NC}"
    echo "Please install Node.js from https://nodejs.org/"
    echo "Or use: brew install node"
    exit 1
fi

# Check if the uninstall script exists
if [[ ! -f "$UNINSTALL_JS" ]]; then
    echo -e "${RED}ERROR: Uninstall script not found at $UNINSTALL_JS${NC}"
    exit 1
fi

# Run the uninstaller
echo "Starting uninstallation process..."
echo ""

if node "$UNINSTALL_JS"; then
    echo ""
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${GREEN}  Uninstallation Complete${NC}"
    echo -e "${GREEN}==========================================${NC}"
else
    EXIT_CODE=$?
    echo ""
    echo -e "${RED}==========================================${NC}"
    echo -e "${RED}  Uninstallation Failed (code: $EXIT_CODE)${NC}"
    echo -e "${RED}==========================================${NC}"
    exit $EXIT_CODE
fi
