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
  <b>Ein leichtgewichtiger Desktop-Launcher für OpenChamber</b><br>
  Plattformübergreifend • Automatische Erkennung • Minimalistisch • Sicher
</p>

---

## 🚀 Schnellstart

### 📋 Voraussetzungen

**Sie müssen OpenCode separat installiert haben.** Dieses Skript installiert nur den OpenChamber Desktop Launcher, nicht OpenCode selbst.

Installieren Sie zuerst OpenCode:
```bash
# Via Bun (empfohlen)
curl -fsSL https://bun.sh/install | bash
bun install -g @openchamber/web

# Oder via npm
npm install -g @openchamber/web
```

### 📦 Installieren

**Windows (PowerShell - Admin):**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.ps1 | iex
```

**Linux / macOS (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.sh | bash
```

### 🔄 Aktualisieren

**Windows:**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.ps1 | iex
```

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.sh | bash
```

### 🗑️ Deinstallieren

**Windows:**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.ps1 | iex
```

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.sh | bash
```

---

## ✨ Funktionen

| Funktion | Beschreibung |
| :--- | :--- |
| 🎯 **Intelligenter Manager** | Wählt automatisch die beste Runtime (Bun → pnpm → npm). |
| 🎨 **Moderne Verknüpfungen** | Native Desktopeinträge mit Symbolen und OS-Integration. |
| ⚡ **Einzelinstanz** | Stellt sicher, dass nur ein Fenster gleichzeitig läuft. |
| 🔍 **Automatische Erkennung** | Findet `openchamber` automatisch im PATH. |
| 🔒 **Sicherer Sandbox** | Führt die Webinterface in einem isolierten iframe aus. |
| 🧹 **Lebenszyklus-Management** | Beendet automatisch alle Prozesse beim Schließen. |

---

## 📦 Alternative Installation

Wenn Sie manuelle Kontrolle bevorzugen:

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

## 🎮 Verwendung

Sobald installiert:
- `ocd` - Startet die Anwendung (Kurzbefehl)
- `openchamber-desktop` - Startet die Anwendung

---

## ⌨️ Tastenkürzel

| Kürzel (PC) | Kürzel (Mac) | Aktion |
| :--- | :--- | :--- |
| `F11` | `F11` | Vollbild |
| `Ctrl` + `+` | `Cmd` + `+` | Reinzoomen |
| `Ctrl` + `-` | `Cmd` + `-` | Rauszoomen |
| `Ctrl` + `0` | `Cmd` + `0` | Zoom zurücksetzen |
| `Ctrl` + `Q` | `Cmd` + `Q` | Beenden |

---

## 🔧 Fehlerbehebung

**Problem:** App sagt "OpenChamber not found"  
**Lösung:**
```bash
# Installieren Sie zuerst OpenCode
bun add -g @openchamber/web
# oder
npm install -g @openchamber/web
```

**Problem:** Portkonflikte  
**Lösung:**
```bash
# Beenden Sie den Prozess auf Port 1504
lsof -ti:1504 | xargs kill -9
```

---

## 🚧 Entwicklung

```bash
# Klonen & Installieren
git clone https://github.com/aencyorganization/openchamber-desktop.git
cd openchamber-desktop
bun install

# Im Entwicklungsmodus ausführen
bun run dev
```

---

## 🤝 Mitwirken

Siehe [CONTRIBUTING.md](docs/CONTRIBUTING.md)

---

## 📄 Lizenz

**GNU General Public License v3.0 (GPL-3.0)**

Siehe [LICENSE](LICENSE)

---

<p align="center">
  Gemacht mit 💚 von <a href="https://github.com/aencyorganization">Aency Organization</a>
</p>
