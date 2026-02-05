# OpenChamber Desktop

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
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-GPL%20v3-blue.svg" alt="License"></a>
  <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-brightgreen" alt="Platforms">
</p>

<p align="center">
  <b>The official-unofficial lightweight desktop launcher for OpenChamber.</b><br>
  A high-performance, secure, and cross-platform container for your OpenCode AI environment.
</p>

---

## 🚀 Quick Start

### 📋 Prerequisites

**You need to have OpenCode installed separately.** This script only installs the OpenChamber Desktop launcher, not OpenCode itself.

Install OpenCode first:
```bash
# Via Bun (recommended)
curl -fsSL https://bun.sh/install | bash
bun install -g @openchamber/web

# Or via npm
npm install -g @openchamber/web
```

### 📦 Install

**Windows (PowerShell - Admin):**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.ps1 | iex
```

**Linux / macOS (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.sh | bash
```

### 🔄 Update

**Windows:**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.ps1 | iex
```

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.sh | bash
```

### 🗑️ Uninstall

**Windows:**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.ps1 | iex
```

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.sh | bash
```

---

## ✨ Features

| Feature | Description |
| :--- | :--- |
| 🎯 **Smart Package Manager**| Automatically selects the best available runtime (Bun → pnpm → npm). |
| 🎨 **Modern Shortcuts** | Native desktop entries with proper icons and OS integration. |
| ⚡ **Single Instance** | Ensures only one window runs at a time. |
| 🔍 **Auto-Detection** | Automatically locates `openchamber` in your system PATH. |
| 🔒 **Secure Sandbox** | Runs the web interface in a hardened iframe. |
| 🧹 **Lifecycle Management** | Automatically terminates all processes when you close the app. |

---

## 📦 Alternative Installation

If you prefer manual control:

**Bun:**
```bash
bun install -g openchamber-desktop
```

**NPM:**
```bash
npm install -g openchamber-desktop
```

**PNPM:**
```bash
pnpm add -g openchamber-desktop
```

---

## 🎮 Usage

Once installed:
- `ocd` - Launches the application (shorthand)
- `openchamber-desktop` - Launches the application

---

## 🎹 Keyboard Shortcuts

| Shortcut (PC) | Shortcut (Mac) | Action |
| :--- | :--- | :--- |
| `F11` | `F11` | Toggle Fullscreen |
| `Ctrl` + `+` | `Cmd` + `+` | Zoom In |
| `Ctrl` + `-` | `Cmd` + `-` | Zoom Out |
| `Ctrl` + `0` | `Cmd` + `0` | Reset Zoom |
| `Ctrl` + `Q` | `Cmd` + `Q` | Quit |

---

## 🔧 Troubleshooting

**Problem:** App says "OpenChamber not found"  
**Solution:**
```bash
# Install OpenCode first
bun add -g @openchamber/web
# or
npm install -g @openchamber/web
```

**Problem:** Port conflicts  
**Solution:**
```bash
# Kill process on port 1504
lsof -ti:1504 | xargs kill -9
```

---

## 🚧 Development

```bash
# Clone & Install
git clone https://github.com/aencyorganization/openchamber-desktop.git
cd openchamber-desktop
bun install

# Run Development Mode
bun run dev
```

---

## 🤝 Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md)

---

## 📄 License

**GNU General Public License v3.0 (GPL-3.0)**

See [LICENSE](LICENSE)

---

<p align="center">
  Made with 💚 by <a href="https://github.com/aencyorganization">Aency Organization</a>
</p>
