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
  <a href="https://github.com/aencyorganization/openchamber-desktop/releases"><img src="https://img.shields.io/github/v/release/aencyorganization/openchamber-desktop" alt="GitHub release"></a>
  <a href="https://github.com/aencyorganization/openchamber-desktop/actions/workflows/release.yml"><img src="https://github.com/aencyorganization/openchamber-desktop/actions/workflows/release.yml/badge.svg" alt="Release Build"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-GPL%20v3-blue.svg" alt="License"></a>
  <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-brightgreen" alt="Platforms">
</p>

<p align="center">
  <b>The official-unofficial lightweight desktop launcher for OpenChamber.</b><br>
  A high-performance, secure, and cross-platform container for your OpenCode AI environment, now with an interactive TUI manager.
</p>

---

## 🚀 Quick Start

The fastest way to install OpenChamber Desktop is through our **One-Line Installers**. They automatically detect your system, install dependencies, and create optimized shortcuts.

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

### 📦 One-Line Installer (Recommended)

Run the command below in your terminal:

**Windows (PowerShell - Admin):**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.ps1 | iex
```

**Linux / macOS (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.sh | bash
```

**Linux / macOS (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.sh | bash
```

### 🔄 Update

To update to the latest version:

**Windows:**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.ps1 | iex
```

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.sh | bash
```

### 🗑️ Uninstall

To completely remove OpenChamber Desktop:

**Windows:**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.ps1 | iex
```

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.sh | bash
```

### 🛠️ What the TUI Manager Does

The OCD Manager provides a unified interface to handle everything related to your installation:

1.  **📦 Install/Update:** Performs a full system audit, installs `bun` if needed, and sets up both the core and launcher.
2.  **🗑️ Complete Uninstall:** Safely removes all binaries, shortcuts, and shell aliases.
3.  **ℹ️ System Info:** Displays current versions, paths, and environment status.
4.  **🎨 Custom Integration:** Let's you choose custom aliases (e.g., `ocd`) and creates native desktop entries.

#### The Installation Flow:
```text
[Detection] -> [Runtime Setup] -> [App Install] -> [Shortcuts] -> [Ready!]
    │               │                │               │
    ▼               ▼                ▼               ▼
OS & Arch       Bun/PNPM/NPM      Latest OCD       Desktop/Dock     Done
```

---

## ✨ Features

| Feature | Description |
| :--- | :--- |
| 🖥️ **TUI Manager** | Interactive terminal-based installer and manager for all platforms. |
| 🎯 **Smart Package Manager**| Automatically selects the best available runtime (Bun → pnpm → npm). |
| 🎨 **Modern Shortcuts** | Native desktop entries with proper icons and OS integration. |
| ⚡ **Single Instance** | Ensures only one window runs at a time, preventing dock/taskbar clutter. |
| 🔍 **Auto-Detection** | Automatically locates `openchamber` in your system PATH. |
| 🔒 **Secure Sandbox** | Runs the web interface in a hardened iframe with restricted permissions. |
| 🧹 **Lifecycle Management** | Automatically terminates all OpenChamber processes when you close the app. |
| 🛠️ **Developer Friendly** | Built with NeutralinoJS for extreme lightness and performance. |

---

## 📦 Alternative Installation

If you prefer manual control, you can use these alternative methods. These are recommended for advanced users only.

<details>
<summary><b>Option 1: Package Managers (NPM / Bun / PNPM)</b></summary>

Install globally using your favorite JavaScript package manager:

**Bun (Fastest):**
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

*Note: After installation, you can launch the app using the command `ocd` or `openchamber-desktop`.*
</details>

<details>
<summary><b>Option 2: Linux AppImage (Portable)</b></summary>

Download the standalone portable version:

```bash
# Download the latest release
curl -L -o OpenChamber.AppImage \
  https://github.com/aencyorganization/openchamber-desktop/releases/latest/download/OpenChamber-Launcher-x86_64.AppImage

# Make it executable
chmod +x OpenChamber.AppImage

# Run it
./OpenChamber.AppImage
```
</details>

<details>
<summary><b>Option 3: Direct Binary Download</b></summary>

Download the optimized binary for your specific architecture:

| Platform | Architecture | Binary Name |
| :--- | :--- | :--- |
| **Linux** | x64 | `openchamber-launcher-linux_x64` |
| | ARM64 | `openchamber-launcher-linux_arm64` |
| | ARMv7 | `openchamber-launcher-linux_armhf` |
| **macOS** | Intel | `openchamber-launcher-mac_x64` |
| | Apple Silicon | `openchamber-launcher-mac_arm64` |
| **Windows**| x64 | `openchamber-launcher-win_x64.exe` |

[View all downloads on GitHub Releases](https://github.com/aencyorganization/openchamber-desktop/releases)
</details>

---

## ⚙️ Configuration


OpenChamber Desktop is designed to be "zero-config," but it offers flexibility for advanced environments.

<details>
<summary><b>Configuration File (neutralino.config.json)</b></summary>

The core application settings are stored in `neutralino.config.json`. 

```json
{
  "applicationId": "com.openchamber.launcher",
  "version": "1.1.0",
  "defaultMode": "window",
  "port": 1504,
  "modes": {
    "window": {
      "title": "OpenChamber Desktop",
      "width": 900,
      "height": 700,
      "resizable": true
    }
  }
}
```

*Note: Modifying these values in the installed package may require a restart of the application.*
</details>

<details>
<summary><b>Environment Variables</b></summary>

The launcher respects the following environment variables:

| Variable | Description | Default |
| :--- | :--- | :--- |
| `PORT` | The port passed to the `openchamber` backend server. | `1504` |
| `NL_PORT` | The internal port for the NeutralinoJS server. | `Random` |
| `DEBUG` | Enables verbose logging in the terminal if set. | `false` |

</details>

<details>
<summary><b>Custom Port Management</b></summary>

By default, the app uses port **1504**. 

1.  **Conflict Resolution:** If port 1504 is occupied during startup, the app attempts to kill the occupying process to ensure a clean start.
2.  **Auto-detection:** The app polls the port for up to 30 seconds until the backend is ready to accept connections.
3.  **Cleanup:** Closing the window sends a `SIGKILL` to any process remaining on port 1504.
</details>

---

## 🎮 Usage

### Basic Commands
Once installed, you can use the following commands:
- `ocd` - Launches the application (shorthand).
- `openchamber-desktop` - Launches the application.
- `ocd --install-system` - Manually triggers the system integration (shortcuts).
- `ocd --uninstall-system` - Removes system integration.

### What happens at startup?
1.  **Backend Spawn:** The launcher looks for `openchamber` in your PATH.
2.  **Server Initialization:** It starts the OpenChamber server on a dedicated local port.
3.  **Secure Loading:** A splash screen is shown while the launcher waits for the backend to become responsive.
4.  **Ready:** The web interface is injected into the secure native container.

---

## 🎹 Keyboard Shortcuts

| Shortcut (PC) | Shortcut (Mac) | Action |
| :--- | :--- | :--- |
| `F11` | `F11` | Toggle Fullscreen |
| `Ctrl` + `+` | `Cmd` + `+` | Zoom In |
| `Ctrl` + `-` | `Cmd` + `-` | Zoom Out |
| `Ctrl` + `0` | `Cmd` + `0` | Reset Zoom (100%) |
| `Ctrl` + `Q` | `Cmd` + `Q` | Quit Application |
| `F12` | `Cmd` + `Opt` + `I` | Open DevTools (if enabled) |

---

## 🛠️ Advanced Usage

<details>
<summary><b>Running in Portable Mode</b></summary>

If you want to run the app without installing it to the system:
1. Download the binary for your OS.
2. Ensure `openchamber` is installed and available in your environment.
3. Run the binary directly from the terminal.
</details>

<details>
<summary><b>Manual Backend Association</b></summary>

If the app cannot find your OpenChamber installation, ensure that the path to the `openchamber` executable is added to your system's `PATH` variable. 

For Bun users:
```bash
export PATH="$HOME/.bun/bin:$PATH"
```
</details>

---

## 🔧 Troubleshooting

<details>
<summary><b>📦 TUI Manager Issues</b></summary>

**Problem:** Script fails with "Permission Denied" or "Command not found".
**Solution:**
1. Ensure you have `curl` (Linux/macOS) or `powershell` (Windows) updated.
2. Try running with `sudo` for Linux/macOS if global installation fails.
3. For Windows, ensure you are running PowerShell as **Administrator**.
4. **Debug Mode:** Run the script with `DEBUG=true` to see verbose logs:
   ```bash
   DEBUG=true curl -fsSL ... | bash
   ```
</details>

<details>
<summary><b>🔍 Detection Issues</b></summary>

**Problem:** App says "OpenChamber not found".
**Solution:**
1. Verify OpenChamber is installed: `openchamber --version`.
2. If not installed, run: `bun add -g @openchamber/web`.
3. Ensure your PATH is correctly set up.
</details>

<details>
<summary><b>🔌 Port Conflicts</b></summary>

**Problem:** Port detection timeout or "Port already in use".
**Solution:**
1. The app automatically tries to clear port 1504.
2. If it fails, manually kill the process: 
   - Linux/Mac: `lsof -ti:1504 | xargs kill -9`
   - Windows (CMD): `for /f "tokens=5" %a in ('netstat -aon ^| findstr :1504') do taskkill /f /pid %a`
</details>

<details>
<summary><b>🔑 Authentication Errors (NE_CL_IVCTOKN)</b></summary>

**Problem:** Standard Neutralino token error.
**Solution:**
1. Restart the application.
2. Clear the `.tmp` directory in the app folder if it exists.
3. This is usually caused by multiple instances trying to use the same token.
</details>

<details>
<summary><b>🐧 Linux AppImage Errors</b></summary>

**Problem:** AppImage won't start on Ubuntu/Debian.
**Solution:**
Install the FUSE library:
```bash
sudo apt install libfuse2
```
</details>

---

## 🏗️ Architecture

OpenChamber Desktop follows a "Manager-Worker" architecture:

```text
┌───────────────────────────┐      ┌───────────────────────────┐
│     NeutralinoJS Host     │      │    OpenChamber Backend    │
│  (Native OS Operations)   │◄────►│   (AI Agent & Terminal)   │
└─────────────┬─────────────┘      └─────────────┬─────────────┘
              │                                  │
              ▼                                  │
┌───────────────────────────┐                    │
│      Embedded Iframe      │◄───────────────────┘
│   (Secure Web Interface)  │     HTTP / Localhost:1504
└───────────────────────────┘
```

1.  **NeutralinoJS:** Handles window management, system PATH detection, and process spawning.
2.  **Child Process:** Spawns `openchamber` as a background worker.
3.  **Communication:** The frontend connects via a local-only socket/HTTP connection to port 1504.
4.  **Sandbox:** The UI is strictly isolated from native APIs except through defined Neutralino bridges.

---

## ❓ FAQ

<details>
<summary><b>Why use the Desktop app instead of just the browser?</b></summary>
The Desktop app provides a dedicated environment with OS integration (shortcuts, dock icon), automatic backend lifecycle management (starts/stops with the app), and hardware-accelerated performance without browser tab clutter.
</details>

<details>
<summary><b>Is it secure?</b></summary>
Yes. All communication is restricted to `localhost`. The web interface runs inside a sandboxed iframe with `allow-scripts` but restricted top-level navigation, protecting your local system.
</details>

<details>
<summary><b>Can I change the default port?</b></summary>
Currently, the port is set to 1504 to avoid conflicts with common development ports like 3000 or 8080. You can modify this in the source code under `resources/js/main.js`.
</details>

---

## 🚧 Development

<details>
<summary><b>Setup Environment</b></summary>

1.  **Prerequisites:**
    - [Bun](https://bun.sh/) (Runtime)
    - [Neutralino CLI](https://neutralino.js.org/docs/cli/neu-cli) (`npm install -g @neutralinojs/neu`)

2.  **Clone & Install:**
    ```bash
    git clone https://github.com/aencyorganization/openchamber-desktop.git
    cd openchamber-desktop
    bun install
    ```

3.  **Run Development Mode:**
    ```bash
    bun run dev
    ```
</details>

<details>
<summary><b>Build Scripts</b></summary>

- `bun run build` - Build for the current platform.
- `bun run build:release` - Build optimized binaries for all supported platforms.
- `bun run build:appimage` - Generate Linux AppImage (requires `appimagetool`).
</details>

---

## 🤝 Contributing

We welcome contributions! Please see our [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines on how to submit pull requests, report bugs, and suggest features.

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.

See the [LICENSE](LICENSE) file for the full text. 

**Summary:**
- ✅ Free to use, modify, and distribute.
- ⚠️ Modified versions must also be open-source under GPL-3.0.
- ⚠️ Source code must be made available when distributing.

---

<p align="center">
  Made with 💚 by <a href="https://github.com/aencyorganization">Aency Organization</a>
</p>

<p align="center">
  <a href="https://github.com/aencyorganization/openchamber-desktop/stargazers">⭐ Star this repo</a> • 
  <a href="https://github.com/aencyorganization/openchamber-desktop/issues">🐛 Report issues</a> • 
  <a href="https://github.com/aencyorganization/openchamber-desktop/discussions">💬 Discussions</a>
</p>
