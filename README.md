# OpenChamber Launcher

<p align="center">
  <img src="https://raw.githubusercontent.com/btriapitsyn/openchamber/main/docs/references/badges/openchamber-logo-light.svg" width="120" alt="OpenChamber Logo">
</p>

<p align="center">
  <a href="README.md">🇺🇸 English</a> | 
  <a href="README.pt.md">🇧🇷 Português</a> | 
  <a href="README.es.md">🇪🇸 Español</a> | 
  <a href="README.fr.md">🇫🇷 Français</a> | 
  <a href="README.de.md">🇩🇪 Deutsch</a>
</p>

<p align="center">
  <a href="https://www.npmjs.com/package/openchamber-desktop"><img src="https://img.shields.io/npm/v/openchamber-desktop.svg" alt="npm version"></a>
  <a href="https://github.com/aencyorganization/openchamber-desktop/releases"><img src="https://img.shields.io/github/v/release/aencyorganization/openchamber-desktop" alt="GitHub release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-GPL%20v3-blue.svg" alt="License"></a>
</p>

<p align="center">
  <b>A lightweight desktop launcher for OpenChamber</b><br>
  Cross-platform • Auto-detection • Minimalist • Secure
</p>

---

## 🚀 Quick Start (One-Line Install)

### 🎯 Universal Installer (Recommended)

**Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install-all.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install-all.ps1 | iex
```

**What it does:**
1. ✅ Checks your system
2. ✅ Installs Bun (if not present)
3. ✅ Installs OpenChamber Desktop
4. ✅ Creates system shortcuts (Menu/Apps)

---

### 📦 Manual Installation (Package Manager Priority)

**1. Bun (Fastest - Recommended):**
```bash
curl -fsSL https://bun.sh/install | bash
bun install -g openchamber-desktop
```

**2. pnpm (Fast):**
```bash
npm install -g pnpm
pnpm add -g openchamber-desktop
```

**3. npm (Standard):**
```bash
npm install -g openchamber-desktop
```

---

### 🗑️ Uninstall

**Universal Uninstaller (Keeps Bun):**

**Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall-all.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall-all.ps1 | iex
```

**What it removes:**
- ✅ OpenChamber Desktop app
- ✅ System shortcuts (Menu/Apps)
- ✅ Desktop entries

**What it keeps:**
- ✅ Bun (for other projects)

---

### 📱 AppImage (Linux - Portable)

```bash
# Download
wget https://github.com/aencyorganization/openchamber-desktop/releases/latest/download/OpenChamber-Launcher-x86_64.AppImage
chmod +x OpenChamber-Launcher-x86_64.AppImage
./OpenChamber-Launcher-x86_64.AppImage
```

---

## 📋 Table of Contents

- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Keyboard Shortcuts](#-keyboard-shortcuts)
- [Development](#-development)
- [Building from Source](#-building-from-source)
- [Project Structure](#-project-structure)
- [Troubleshooting](#-troubleshooting)
- [Credits](#-credits)
- [License](#-license)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔍 **Auto-Detection** | Automatically finds OpenChamber installation in your system |
| 🎯 **Smart Port Detection** | Detects which port OpenChamber is running on automatically |
| 🔒 **Secure Container** | Runs OpenChamber in a sandboxed iframe with controlled permissions |
| 🧹 **Auto-Cleanup** | Automatically kills all OpenChamber processes when you close the app |
| 🖥️ **Cross-Platform** | Works on Linux (x64/ARM), macOS (Intel/Apple Silicon), and Windows |
| 📦 **Multiple Install Methods** | Install via npm, Bun, AppImage, or direct download |
| ⌨️ **Keyboard Shortcuts** | Fullscreen (F11), Zoom (Ctrl +/-), Reset Zoom (Ctrl+0) |
| 🎨 **Minimalist UI** | Clean black interface with elegant loading animation |
| 🚀 **Fast Startup** | Detects existing OpenChamber or starts it automatically |
| 🛡️ **Error Handling** | Graceful error messages and automatic recovery |

---

## 📦 Requirements

### System Requirements

- **Operating System:**
  - Linux: x64, ARM64, ARMv7
  - macOS: Intel (x64), Apple Silicon (ARM64)
  - Windows: x64
- **RAM:** 512 MB minimum (1 GB recommended)
- **Disk Space:** 50 MB for the launcher
- **Network:** Internet connection (for OpenChamber functionality)

### Software Requirements

**You must have OpenChamber installed:**

```bash
# Quick install via curl
curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash

# Or install via Bun
bun add -g @openchamber/web

# Or install via npm
npm install -g @openchamber/web

# Verify installation
which openchamber
openchamber --version
```

---

## 🚀 Installation

### Option 1: Package Manager (Recommended)

**Bun (Fastest):**
```bash
bun install -g openchamber-desktop
```

**npm:**
```bash
npm install -g openchamber-desktop
```

**pnpm:**
```bash
pnpm add -g openchamber-desktop
```

**Yarn:**
```bash
yarn global add openchamber-desktop
```

### Option 2: AppImage (Linux)

```bash
# Download
curl -L -o OpenChamber-Launcher-x86_64.AppImage \
  https://github.com/aencyorganization/openchamber-desktop/releases/latest/download/OpenChamber-Launcher-x86_64.AppImage

# Make executable
chmod +x OpenChamber-Launcher-x86_64.AppImage

# Run
./OpenChamber-Launcher-x86_64.AppImage

# Optional: Install to system
sudo mv OpenChamber-Launcher-x86_64.AppImage /usr/local/bin/openchamber-desktop
```

### Option 3: Direct Binary Download

Download the appropriate binary for your platform from [GitHub Releases](https://github.com/aencyorganization/openchamber-desktop/releases):

| Platform | Architecture | File |
|----------|-------------|------|
| Linux | x64 | `openchamber-launcher-linux_x64` |
| Linux | ARM64 | `openchamber-launcher-linux_arm64` |
| Linux | ARMv7 | `openchamber-launcher-linux_armhf` |
| macOS | Intel | `openchamber-launcher-mac_x64` |
| macOS | Apple Silicon | `openchamber-launcher-mac_arm64` |
| macOS | Universal | `openchamber-launcher-mac_universal` |
| Windows | x64 | `openchamber-launcher-win_x64.exe` |

---

## 🎮 Usage

### Starting the App

```bash
# If installed via package manager
openchamber-desktop

# Or use the shorthand
ocd

# If using AppImage
./OpenChamber-Launcher-x86_64.AppImage

# If using binary directly
./openchamber-launcher-linux_x64
```

### What Happens When You Start

1. **Detection Phase:** The app checks if OpenChamber is already running
2. **Port Scan:** If running, detects which port it's using (3000, 3001, 8080, etc.)
3. **Auto-Start:** If not running, automatically starts OpenChamber
4. **Connection:** Connects to OpenChamber and displays it in the embedded window
5. **Cleanup:** When you close the window, all OpenChamber processes are terminated

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action | Description |
|----------|--------|-------------|
| `F11` | Toggle Fullscreen | Switch between windowed and fullscreen mode |
| `Ctrl` + `+` | Zoom In | Increase the interface zoom level |
| `Ctrl` + `-` | Zoom Out | Decrease the interface zoom level |
| `Ctrl` + `0` | Reset Zoom | Return to default zoom level (100%) |
| `Cmd` + `+` | Zoom In (Mac) | macOS alternative |
| `Cmd` + `-` | Zoom Out (Mac) | macOS alternative |
| `Cmd` + `0` | Reset Zoom (Mac) | macOS alternative |

---

## 🛠️ Development

### Prerequisites

- [Bun](https://bun.sh/) or Node.js 18+
- [NeutralinoJS CLI](https://neutralino.js.org/)
- Git

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/aencyorganization/openchamber-desktop.git
cd openchamber-desktop

# Install dependencies
bun install

# Download Neutralino binaries
bun run update

# Start development server (with hot-reload)
bun run dev
```

### Available Scripts

```bash
# Development mode with hot-reload
bun run dev

# Build for all platforms
bun run build

# Build release version (optimized)
bun run build:release

# Build AppImage (Linux only)
bun run build:appimage

# Start the built application
bun start
```

---

## 🔨 Building from Source

### Build for All Platforms

```bash
# Install dependencies
bun install

# Download binaries
bun run update

# Build
bun run build:release
```

The built files will be in the `dist/` directory.

### Build AppImage (Linux)

```bash
bun run build:appimage
```

Output: `dist/OpenChamber-Launcher-x86_64.AppImage`

---

## 📁 Project Structure

```
openchamber-desktop/
├── 📁 assets/                  # Images, icons, logos
│   └── openchamber-logo-dark.png
├── 📁 bin/                     # Compiled binaries
│   ├── cli.js                 # CLI entry point
│   ├── neutralino-linux_x64   # Linux x64 binary
│   ├── neutralino-linux_arm64 # Linux ARM64 binary
│   ├── neutralino-linux_armhf # Linux ARMv7 binary
│   ├── neutralino-mac_x64     # macOS Intel binary
│   ├── neutralino-mac_arm64   # macOS Apple Silicon binary
│   ├── neutralino-mac_universal # macOS Universal binary
│   └── neutralino-win_x64.exe # Windows binary
├── 📁 config/                  # Configuration files
│   └── npm-package.json       # npm-specific config
├── 📁 docs/                    # Documentation
│   ├── CHANGELOG.md           # Version history
│   ├── CODE_OF_CONDUCT.md     # Community guidelines
│   ├── CONTRIBUTING.md        # How to contribute
│   └── PUBLISHING.md          # Release guide
├── 📁 resources/               # Application resources
│   ├── index.html            # Main UI file
│   ├── js/
│   │   ├── main.js           # Main application logic
│   │   └── neutralino.js     # Neutralino client library
│   └── styles/
│       └── main.css          # Application styles
├── 📁 scripts/                 # Build and utility scripts
│   ├── build/
│   │   ├── build-appimage.js # AppImage builder
│   │   └── publish-npm.sh    # npm publish helper
│   └── postinstall.js        # Post-install script
├── 📁 .github/                 # GitHub templates and workflows
│   ├── workflows/
│   │   └── release.yml       # Automated release workflow
│   └── ISSUE_TEMPLATE/
├── 📄 package.json            # Main package configuration
├── 📄 neutralino.config.json  # Neutralino app configuration
├── 📄 README.md               # This file (English)
├── 📄 README.pt.md            # Portuguese version
├── 📄 README.es.md            # Spanish version
├── 📄 README.fr.md            # French version
├── 📄 README.de.md            # German version
└── 📄 LICENSE                 # GPL-3.0 License
```

---

## 🔧 Troubleshooting

### App says "OpenChamber not found"

**Problem:** OpenChamber is not installed or not in PATH.

**Solution:**
```bash
# Install OpenChamber
curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash

# Verify it's in PATH
which openchamber

# If not in PATH, add it (example for Bun)
export PATH="$HOME/.bun/bin:$PATH"
```

### Port detection timeout

**Problem:** App can't detect which port OpenChamber is using.

**Solution:**
- Make sure OpenChamber is actually running: `openchamber --version`
- Check if ports 3000-3010 are available
- Try manually specifying the port in OpenChamber config

### "NE_CL_IVCTOKN" error

**Problem:** Authentication token error with Neutralino.

**Solution:**
- Restart the application
- Clear browser session storage
- If persists, delete `.tmp/` folder and restart

### AppImage won't run

**Problem:** AppImage doesn't execute.

**Solution:**
```bash
# Make executable
chmod +x OpenChamber-Launcher-x86_64.AppImage

# Install FUSE (if missing)
sudo apt install libfuse2  # Ubuntu/Debian
sudo pacman -S fuse2       # Arch

# Or use --appimage-extract flag
./OpenChamber-Launcher-x86_64.AppImage --appimage-extract
./squashfs-root/AppRun
```

---

## 🙏 Credits

### Original Projects

- **[OpenChamber](https://github.com/btriapitsyn/openchamber)** - Desktop and web interface for OpenCode AI agent
  - Created by [Bogdan Triapitsyn](https://github.com/btriapitsyn)
  - Repository: https://github.com/btriapitsyn/openchamber
  - License: MIT

- **[OpenCode](https://opencode.ai)** - AI coding assistant for the terminal
  - Developed by [Anomaly Innovations](https://anomalyinnovations.com)
  - Website: https://opencode.ai

### Technologies Used

- [NeutralinoJS](https://neutralino.js.org/) - Cross-platform desktop application framework
- [neutralino-appimage-bundler](https://github.com/krypt0nn/neutralino-appimage-bundler) - AppImage packaging tool
- [Bun](https://bun.sh/) - Fast JavaScript runtime and package manager

### Contributors

- OpenCode Team and Contributors
- Anomaly Innovations Team
- All contributors to the OpenChamber project

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.

See [LICENSE](LICENSE) file for full details.

**Key points:**
- You can use, modify, and distribute this software
- If you distribute modified versions, you must share the source code
- Any derivative works must also be GPL-3.0 licensed

---

## ⚠️ Disclaimer

This is an **independent project** and is not officially affiliated with OpenCode or Anomaly Innovations. OpenChamber and OpenCode are trademarks of their respective owners.

---

<p align="center">
  Made with 💚 by <a href="https://github.com/aencyorganization">Aency Organization</a>
</p>

<p align="center">
  <a href="https://github.com/aencyorganization/openchamber-desktop/stargazers">⭐ Star this repo</a> • 
  <a href="https://github.com/aencyorganization/openchamber-desktop/issues">🐛 Report issues</a> • 
  <a href="https://github.com/aencyorganization/openchamber-desktop/discussions">💬 Discussions</a>
</p>
