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
  <b>Ein leichtgewichtiger Desktop-Launcher für OpenChamber</b><br>
  Plattformübergreifend • Automatische Erkennung • Minimalistisch • Sicher
</p>

---

## 🚀 Schnellstart

### Option 1: Paketmanager (Prioritätsreihenfolge)
```bash
# 1. Bun (Am schnellsten - Empfohlen)
curl -fsSL https://bun.sh/install | bash
bun install -g openchamber-desktop

# 2. pnpm (Schnell)
npm install -g pnpm
pnpm add -g openchamber-desktop

# 3. npm (Standard)
npm install -g openchamber-desktop
```

### Option 2: AppImage (Linux - Portabel)
```bash
# Ein-Zeilen-Installation
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install/install.sh | bash

# Oder manuell:
wget https://github.com/aencyorganization/openchamber-desktop/releases/latest/download/OpenChamber-Launcher-x86_64.AppImage
chmod +x OpenChamber-Launcher-x86_64.AppImage
./OpenChamber-Launcher-x86_64.AppImage
```

### Option 3: Systeminstallation (Menü/Apps Integration)
```bash
# Nach der Installation über den oben genannten Paketmanager ausführen:
openchamber-desktop --install-system

# Oder manuell:
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install/install.sh | bash
```

### Deinstallation
```bash
# Vom System entfernen
openchamber-desktop --uninstall-system

# Oder manuell:
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall/uninstall.sh | bash
```

---

## 📋 Inhaltsverzeichnis

- [Funktionen](#-funktionen)
- [Anforderungen](#-anforderungen)
- [Installation](#-installation)
- [Verwendung](#-verwendung)
- [Tastenkombinationen](#-tastenkombinationen)
- [Entwicklung](#-entwicklung)
- [Kompilierung](#-kompilierung)
- [Projektstruktur](#-projektstruktur)
- [Fehlerbehebung](#-fehlerbehebung)
- [Credits](#-credits)
- [Lizenz](#-lizenz)

---

## ✨ Funktionen

| Funktion | Beschreibung |
|----------|--------------|
| 🔍 **Auto-Erkennung** | Findet automatisch die OpenChamber-Installation auf Ihrem System |
| 🎯 **Intelligente Porterkennung** | Erkennt automatisch, auf welchem Port OpenChamber läuft |
| 🔒 **Sicherer Container** | Führt OpenChamber in einem isolierten Iframe mit kontrollierten Berechtigungen aus |
| 🧹 **Automatisches Aufräumen** | Beendet automatisch alle OpenChamber-Prozesse beim Schließen |
| 🖥️ **Plattformübergreifend** | Funktioniert auf Linux (x64/ARM), macOS (Intel/Apple Silicon) und Windows |
| 📦 **Mehrere Installationsmethoden** | Installation über npm, Bun, AppImage oder direkten Download |
| ⌨️ **Tastenkombinationen** | Vollbild (F11), Zoom (Strg +/-), Zoom zurücksetzen (Strg+0) |
| 🎨 **Minimalistische UI** | Saubere schwarze Oberfläche mit eleganter Ladeanimation |
| 🚀 **Schnellstart** | Erkennt vorhandenes OpenChamber oder startet es automatisch |
| 🛡️ **Fehlerbehandlung** | Elegante Fehlermeldungen und automatische Wiederherstellung |

---

## 📦 Anforderungen

### Systemanforderungen

- **Betriebssystem:**
  - Linux: x64, ARM64, ARMv7
  - macOS: Intel (x64), Apple Silicon (ARM64)
  - Windows: x64
- **RAM:** Mindestens 512 MB (1 GB empfohlen)
- **Festplattenspeicher:** 50 MB für den Launcher
- **Netzwerk:** Internetverbindung (für OpenChamber-Funktionen)

### Softwareanforderungen

**OpenChamber muss installiert sein:**

```bash
# Schnellinstallation über curl
curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash

# Oder über Bun installieren
bun add -g @openchamber/web

# Oder über npm installieren
npm install -g @openchamber/web

# Installation überprüfen
which openchamber
openchamber --version
```

---

## 🚀 Installation

### Option 1: Paketmanager (Empfohlen)

**Bun (Am schnellsten):**
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
# Herunterladen
curl -L -o OpenChamber-Launcher-x86_64.AppImage \
  https://github.com/aencyorganization/openchamber-desktop/releases/latest/download/OpenChamber-Launcher-x86_64.AppImage

# Ausführbar machen
chmod +x OpenChamber-Launcher-x86_64.AppImage

# Ausführen
./OpenChamber-Launcher-x86_64.AppImage

# Optional: Systemweit installieren
sudo mv OpenChamber-Launcher-x86_64.AppImage /usr/local/bin/openchamber-desktop
```

### Option 3: Direkter Download der Binärdatei

Laden Sie die passende Binärdatei für Ihre Plattform unter [GitHub Releases](https://github.com/aencyorganization/openchamber-desktop/releases) herunter:

| Plattform | Architektur | Datei |
|-----------|-------------|-------|
| Linux | x64 | `openchamber-launcher-linux_x64` |
| Linux | ARM64 | `openchamber-launcher-linux_arm64` |
| Linux | ARMv7 | `openchamber-launcher-linux_armhf` |
| macOS | Intel | `openchamber-launcher-mac_x64` |
| macOS | Apple Silicon | `openchamber-launcher-mac_arm64` |
| macOS | Universal | `openchamber-launcher-mac_universal` |
| Windows | x64 | `openchamber-launcher-win_x64.exe` |

---

## 🎮 Verwendung

### App starten

```bash
# Wenn über Paketmanager installiert
openchamber-desktop

# Oder verwende das Kürzel
ocd

# Bei Verwendung von AppImage
./OpenChamber-Launcher-x86_64.AppImage

# Bei Verwendung der Binärdatei direkt
./openchamber-launcher-linux_x64
```

### Was beim Start passiert

1. **Erkennungsphase:** Die App prüft, ob OpenChamber bereits läuft
2. **Port-Scan:** Wenn es läuft, wird erkannt, welcher Port verwendet wird (3000, 3001, 8080, etc.)
3. **Autostart:** Wenn es nicht läuft, wird OpenChamber automatisch gestartet
4. **Verbindung:** Verbindet sich mit OpenChamber und zeigt es im eingebetteten Fenster an
5. **Aufräumen:** Beim Schließen des Fensters werden alle OpenChamber-Prozesse beendet

---

## ⌨️ Tastenkombinationen

| Kürzel | Aktion | Beschreibung |
|--------|--------|--------------|
| `F11` | Vollbild umschalten | Wechselt zwischen Fenster- und Vollbildmodus |
| `Strg` + `+` | Vergrößern | Erhöht die Zoomstufe der Oberfläche |
| `Strg` + `-` | Verkleinern | Verringert die Zoomstufe der Oberfläche |
| `Strg` + `0` | Zoom zurücksetzen | Kehrt zum Standardzoom (100%) zurück |
| `Cmd` + `+` | Vergrößern (Mac) | Alternative für macOS |
| `Cmd` + `-` | Verkleinern (Mac) | Alternative für macOS |
| `Cmd` + `0` | Zoom zurücksetzen (Mac) | Alternative für macOS |

---

## 🛠️ Entwicklung

### Voraussetzungen

- [Bun](https://bun.sh/) oder Node.js 18+
- [NeutralinoJS CLI](https://neutralino.js.org/)
- Git

### Entwicklungsumgebung einrichten

```bash
# Repository klonen
git clone https://github.com/aencyorganization/openchamber-desktop.git
cd openchamber-desktop

# Abhängigkeiten installieren
bun install

# Neutralino-Binärdateien herunterladen
bun run update

# Entwicklungsserver starten (mit Hot-Reload)
bun run dev
```

### Verfügbare Skripte

```bash
# Entwicklungsmodus mit Hot-Reload
bun run dev

# Für alle Plattformen kompilieren
bun run build

# Release-Version kompilieren (optimiert)
bun run build:release

# AppImage kompilieren (nur Linux)
bun run build:appimage

# Kompilierte Anwendung starten
bun start
```

---

## 🔨 Kompilierung

### Für alle Plattformen kompilieren

```bash
# Abhängigkeiten installieren
bun install

# Binärdateien herunterladen
bun run update

# Kompilieren
bun run build:release
```

Die kompilierten Dateien befinden sich im Verzeichnis `dist/`.

### AppImage kompilieren (Linux)

```bash
bun run build:appimage
```

Ausgabe: `dist/OpenChamber-Launcher-x86_64.AppImage`

---

## 📁 Projektstruktur

```
openchamber-desktop/
├── 📁 assets/                  # Bilder, Icons, Logos
├── 📁 bin/                     # Kompilierte Binärdateien
├── 📁 config/                  # Konfigurationsdateien
├── 📁 docs/                    # Dokumentation
├── 📁 resources/               # Anwendungsressourcen
├── 📁 scripts/                 # Build-Skripte
├── 📁 .github/                 # GitHub-Templates und Workflows
├── 📄 package.json            # Hauptkonfiguration
├── 📄 neutralino.config.json  # Neutralino-Konfiguration
├── 📄 README.md               # Diese Datei (Englisch)
├── 📄 README.pt.md            # Portugiesische Version
├── 📄 README.es.md            # Spanische Version
├── 📄 README.fr.md            # Französische Version
├── 📄 README.de.md            # Deutsche Version
└── 📄 LICENSE                 # GPL-3.0 Lizenz
```

---

## 🔧 Fehlerbehebung

### App sagt "OpenChamber not found"

**Problem:** OpenChamber ist nicht installiert oder nicht im PATH.

**Lösung:**
```bash
# OpenChamber installieren
curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash

# Überprüfen, ob es im PATH ist
which openchamber

# Wenn nicht im PATH, hinzufügen (Beispiel für Bun)
export PATH="$HOME/.bun/bin:$PATH"
```

### Timeout bei der Porterkennung

**Problem:** Die App kann nicht erkennen, auf welchem Port OpenChamber läuft.

**Lösung:**
- Überprüfen Sie, ob OpenChamber tatsächlich läuft: `openchamber --version`
- Überprüfen Sie, ob die Ports 3000-3010 verfügbar sind
- Versuchen Sie, den Port manuell in der OpenChamber-Konfiguration anzugeben

### Fehler "NE_CL_IVCTOKN"

**Problem:** Authentifizierungstoken-Fehler mit Neutralino.

**Lösung:**
- Anwendung neu starten
- Session Storage des Browsers löschen
- Wenn das Problem weiterhin besteht, den Ordner `.tmp/` löschen und neu starten

### AppImage startet nicht

**Problem:** AppImage lässt sich nicht ausführen.

**Lösung:**
```bash
# Ausführbar machen
chmod +x OpenChamber-Launcher-x86_64.AppImage

# FUSE installieren (falls fehlt)
sudo apt install libfuse2  # Ubuntu/Debian
sudo pacman -S fuse2       # Arch

# Oder das Flag --appimage-extract verwenden
./OpenChamber-Launcher-x86_64.AppImage --appimage-extract
./squashfs-root/AppRun
```

---

## 🙏 Credits

### Originalprojekte

- **[OpenChamber](https://github.com/btriapitsyn/openchamber)** - Desktop- und Web-Interface für den OpenCode KI-Agenten
  - Erstellt von [Bogdan Triapitsyn](https://github.com/btriapitsyn)
  - Repository: https://github.com/btriapitsyn/openchamber

- **[OpenCode](https://opencode.ai)** - KI-Assistent für das Terminal
  - Entwickelt von [Anomaly Innovations](https://anomalyinnovations.com)
  - Webseite: https://opencode.ai

### Verwendete Technologien

- [NeutralinoJS](https://neutralino.js.org/) - Plattformübergreifendes Desktop-Framework
- [neutralino-appimage-bundler](https://github.com/krypt0nn/neutralino-appimage-bundler) - AppImage-Packaging-Tool
- [Bun](https://bun.sh/) - Schnelle JavaScript-Runtime und Paketmanager

---

## 📄 Lizenz

Dieses Projekt steht unter der **GNU General Public License v3.0 (GPL-3.0)**.

Weitere Details finden Sie in der Datei [LICENSE](LICENSE).

---

## ⚠️ Haftungsausschluss

Dies ist ein **unabhängiges Projekt** und steht in keiner offiziellen Verbindung zu OpenCode oder Anomaly Innovations. OpenChamber und OpenCode sind Marken ihrer jeweiligen Eigentümer.

---

<p align="center">
  Erstellt mit 💚 von <a href="https://github.com/aencyorganization">Aency Organization</a>
</p>
