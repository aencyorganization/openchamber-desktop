# OpenChamber Launcher

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![NeutralinoJS](https://img.shields.io/badge/NeutralinoJS-v5.3.0-green.svg)](https://neutralino.js.org/)
[![OpenChamber](https://img.shields.io/badge/OpenChamber-Desktop%20Interface-orange.svg)](https://github.com/btriapitsyn/openchamber)

A lightweight, cross-platform desktop launcher for [OpenChamber](https://github.com/btriapitsyn/openchamber) built with [NeutralinoJS](https://neutralino.js.org/). Automatically detects, launches, and embeds OpenChamber in a secure container.

![OpenChamber Launcher](assets/openchamber-logo-dark.png)

## Features

- 🚀 **Auto-Detection**: Automatically detects if OpenChamber is running or installed
- 🎯 **Smart Port Detection**: Scans common ports and detects which port OpenChamber is using
- 🔒 **Secure Container**: Embeds OpenChamber in a sandboxed iframe with full system access
- 🧹 **Auto-Cleanup**: Kills all OpenChamber processes when the app closes
- 🖥️ **Cross-Platform**: Works on Linux, macOS, and Windows
- 📦 **AppImage Support**: Single-file executable for Linux distributions

## Screenshots

*Loading Screen - Minimal black interface with elegant spinner*

## Requirements

### System Requirements

- **OS**: Linux (x64), macOS (Intel/Apple Silicon), or Windows (x64)
- **RAM**: 512 MB minimum (1 GB recommended)
- **Disk Space**: 50 MB for the launcher
- **Network**: Internet connection (for OpenChamber functionality)

### Software Requirements

- **[OpenChamber](https://github.com/btriapitsyn/openchamber)** must be installed and available in your system PATH
- **[OpenCode CLI](https://opencode.ai)** (required by OpenChamber)

### Installing OpenChamber & OpenCode

#### Quick Install (Universal)

```bash
# Install OpenChamber via curl (recommended)
curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash

# Or install OpenCode directly
curl -fsSL https://opencode.ai/install.sh | bash
```

#### Package Managers

**Bun (Recommended):**
```bash
bun add -g @openchamber/web
# or
bun add -g @opencode-ai/cli
```

**npm:**
```bash
npm install -g @openchamber/web
# or
npm install -g @opencode-ai/cli
```

**pnpm:**
```bash
pnpm add -g @openchamber/web
# or
pnpm add -g @opencode-ai/cli
```

**Yarn:**
```bash
yarn global add @openchamber/web
# or
yarn global add @opencode-ai/cli
```

#### Distribution-Specific Installation

**Arch Linux (AUR):**
```bash
# Using yay
yay -S openchamber
# or
yay -S opencode

# Using paru
paru -S openchamber
```

**Ubuntu/Debian:**
```bash
# Download and install .deb package
wget https://github.com/btriapitsyn/openchamber/releases/latest/download/openchamber-linux-amd64.deb
sudo dpkg -i openchamber-linux-amd64.deb
sudo apt-get install -f  # Fix dependencies if needed
```

**Fedora/RHEL/CentOS:**
```bash
# Download and install .rpm package
wget https://github.com/btriapitsyn/openchamber/releases/latest/download/openchamber-linux-amd64.rpm
sudo rpm -i openchamber-linux-amd64.rpm
```

**macOS (Homebrew):**
```bash
# Coming soon
# brew install openchamber

# For now, use npm or curl
npm install -g @openchamber/web
```

**Windows (PowerShell):**
```powershell
# Using npm
npm install -g @openchamber/web

# Or download installer from releases
# https://github.com/btriapitsyn/openchamber/releases
```

#### Verify Installation

```bash
# Check if openchamber is in PATH
which openchamber
# or
command -v openchamber

# Check version
openchamber --version
```

## Installation

### Download Pre-built Binaries

Download the latest release from the [Releases](https://github.com/yourusername/openchamber-desktop/releases) page.

### Linux (AppImage)

```bash
# Download the AppImage
wget https://github.com/yourusername/openchamber-desktop/releases/latest/download/OpenChamber-Launcher-x86_64.AppImage

# Make it executable
chmod +x OpenChamber-Launcher-x86_64.AppImage

# Run it
./OpenChamber-Launcher-x86_64.AppImage
```

### macOS

```bash
# Download and extract
curl -L -o openchamber-launcher-mac.zip https://github.com/yourusername/openchamber-desktop/releases/latest/download/openchamber-launcher-mac.zip
unzip openchamber-launcher-mac.zip

# Run
./openchamber-launcher-mac/openchamber-launcher-mac_x64
```

### Windows

Download and run `openchamber-launcher-win_x64.exe` from the releases page.

## Building from Source

### Prerequisites

- [Bun](https://bun.sh/) or Node.js
- NeutralinoJS CLI

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/openchamber-desktop.git
cd openchamber-desktop

# Install dependencies
bun install

# Download Neutralino binaries
bun run update
```

### Development

```bash
# Run in development mode
bun run dev
```

### Building

```bash
# Build for all platforms
bun run build

# Build release version
bun run build:release

# Build AppImage (Linux only)
bun run build:appimage
```

## Project Structure

```
openchamber-desktop/
├── bin/                          # Neutralino binaries
│   ├── neutralino-linux_x64
│   ├── neutralino-mac_x64
│   ├── neutralino-win_x64.exe
│   └── ...
├── resources/
│   ├── index.html               # Main UI
│   ├── styles/
│   │   └── main.css             # Styles
│   └── js/
│       ├── neutralino.js        # Neutralino client library
│       └── main.js              # Main application logic
├── assets/
│   └── openchamber-logo-dark.png # App icon
├── neutralino.config.json       # App configuration
├── build-appimage.js            # AppImage build script
├── package.json
├── LICENSE
└── README.md
```

## How It Works

1. **Auto-Start**: The app immediately tries to run `openchamber` command
2. **Port Detection**: Listens to process output or scans ports to find where OpenChamber is running
3. **Embed**: Loads OpenChamber in an iframe with full sandbox permissions
4. **Cleanup**: When the window closes (via X or any method), all OpenChamber processes are killed

## Configuration

Edit `neutralino.config.json` to customize:

```json
{
  "applicationId": "com.openchamber.launcher",
  "version": "1.0.0",
  "modes": {
    "window": {
      "title": "OpenChamber Launcher",
      "width": 900,
      "height": 700
    }
  }
}
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Credits

### Original Projects

- **[OpenChamber](https://github.com/btriapitsyn/openchamber)** - Desktop and web interface for OpenCode AI agent
  - Created by [Bogdan Triapitsyn](https://github.com/btriapitsyn)
  - Repository: https://github.com/btriapitsyn/openchamber

- **[OpenCode](https://opencode.ai)** - AI coding assistant for the terminal
  - Developed by [Anomaly Innovations](https://anomalyinnovations.com)
  - Website: https://opencode.ai

### Technologies

- **[NeutralinoJS](https://neutralino.js.org/)** - Cross-platform desktop application framework
- **[neutralino-appimage-bundler](https://github.com/krypt0nn/neutralino-appimage-bundler)** - AppImage packaging

### Contributors

- OpenCode Team and Contributors
- Anomaly Innovations Team
- All contributors to the OpenChamber project

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0) - see the [LICENSE](LICENSE) file for details.

This means:
- You can use, modify, and distribute this software
- If you distribute modified versions, you must also distribute the source code
- Any derivative works must also be licensed under GPL-3.0

## Acknowledgments

- Built with [NeutralinoJS](https://neutralino.js.org/)
- AppImage bundling powered by [neutralino-appimage-bundler](https://github.com/krypt0nn/neutralino-appimage-bundler)
- Inspired by the amazing work of the OpenCode and OpenChamber teams

## Support

If you encounter any issues, please [open an issue](https://github.com/yourusername/openchamber-desktop/issues/new).

---

**Disclaimer**: This is an independent project and is not officially affiliated with OpenCode or Anomaly Innovations. OpenChamber and OpenCode are trademarks of their respective owners.
