# OCD Installer - Modern TUI with Bubble Tea

A beautiful, interactive terminal installer for OpenChamber Desktop built with [Bubble Tea](https://github.com/charmbracelet/bubbletea) (Charm.sh).

## Features

- 🎨 **Modern TUI** - Beautiful interface with Bubble Tea framework
- ⌨️ **Keyboard Navigation** - Use arrow keys (↑↓) to navigate, Enter to select
- 📦 **Smart Installation** - Auto-detects package manager (Bun → pnpm → npm)
- ✅ **Interactive Wizard** - Step-by-step installation with checkboxes and radio buttons
- 📊 **Progress Indicators** - Real-time spinners and progress bars
- 🖥️ **Cross-Platform** - Works on Windows, macOS, and Linux

## Installation

### Quick Install (Pre-built Binaries)

Download the latest binary for your platform from the releases page.

### Build from Source

Requirements:
- Go 1.21 or higher

```bash
cd scripts/ocd-installer

# Download dependencies
go mod download

# Build for current platform
go build -o ocd-installer

# Or build for all platforms:
# Windows
go build -o ocd-installer-windows.exe

# macOS (Intel)
GOOS=darwin GOARCH=amd64 go build -o ocd-installer-mac-x64

# macOS (Apple Silicon)
GOOS=darwin GOARCH=arm64 go build -o ocd-installer-mac-arm64

# Linux (x64)
GOOS=linux GOARCH=amd64 go build -o ocd-installer-linux-x64

# Linux (ARM64)
GOOS=linux GOARCH=arm64 go build -o ocd-installer-linux-arm64
```

## Usage

Simply run the binary:

```bash
./ocd-installer
```

### Navigation

- **↑/↓** - Navigate through options
- **Enter** - Select/Confirm
- **Space** - Toggle checkboxes
- **Tab** - Next field
- **Esc** - Go back/Cancel
- **Ctrl+C** - Quit

### Menu Options

1. **📦 Install/Update OCD** - Full installation wizard
   - Select package manager (Bun/pnpm/npm/Auto)
   - Choose aliases (ocd, openchamber-desktop, custom)
   - Select shortcuts (Desktop, Start Menu, Dock)
   - Watch progress with beautiful spinner

2. **🗑️ Uninstall** - Complete removal
   - Confirm with "yes"
   - Select what to remove (OCD, Core, Shortcuts)
   - Progress tracking

3. **ℹ️ System Info** - Display system information
   - OS and Architecture
   - Package Manager status
   - OpenChamber and OCD versions

4. **🚪 Exit** - Quit the installer

## Screenshots

```
┌─────────────────────────────────────────┐
│  OpenChamber Desktop Installer          │
│                                         │
│  📦 Install/Update OCD                  │
│  🗑️  Uninstall                          │
│  ℹ️  System Info                        │
│  🚪 Exit                                │
│                                         │
│  Use ↑/↓ to navigate, Enter to select   │
└─────────────────────────────────────────┘
```

## Architecture

Built with:
- [Bubble Tea](https://github.com/charmbracelet/bubbletea) - TUI framework
- [Lip Gloss](https://github.com/charmbracelet/lipgloss) - Styling
- [Bubbles](https://github.com/charmbracelet/bubbles) - Components (spinner, progress, input)

## License

GPL-3.0 - Same as OpenChamber Desktop
