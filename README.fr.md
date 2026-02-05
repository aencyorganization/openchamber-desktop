# OpenChamber Desktop

<p align="center">
  <img src="https://raw.githubusercontent.com/btriapitsyn/openchamber/main/docs/references/badges/openchamber-logo-light.svg" width="120" alt="Logo OpenChamber">
</p>

<p align="center">
  <a href="README.md">🇺🇸 English</a> | 
  <a href="README.pt.md">🇧🇷 Português</a> | 
  <a href="README.es.md">🇪🇸 Español</a> | 
  <a href="README.fr.md">🇫🇷 Français</a> | 
  <a href="README.de.md">🇩🇪 Deutsch</a>
</p>

<p align="center">
  <b>Un lanceur de bureau léger pour OpenChamber</b><br>
  Multiplateforme • Détection automatique • Minimaliste • Sécurisé
</p>

---

## 🚀 Démarrage Rapide

### 📋 Prérequis

**Vous devez avoir OpenCode installé séparément.** Ce script installe uniquement le launcher OpenChamber Desktop, pas OpenCode lui-même.

Installez OpenCode d'abord :
```bash
# Via Bun (recommandé)
curl -fsSL https://bun.sh/install | bash
bun install -g @openchamber/web

# Ou via npm
npm install -g @openchamber/web
```

### 📦 Installer

**Windows (PowerShell - Admin) :**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.ps1 | iex
```

**Linux / macOS (Bash) :**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.sh | bash
```

### 🔄 Mettre à Jour

**Windows :**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.ps1 | iex
```

**Linux / macOS :**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.sh | bash
```

### 🗑️ Désinstaller

**Windows :**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.ps1 | iex
```

**Linux / macOS :**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.sh | bash
```

---

## ✨ Fonctionnalités

| Fonctionnalité | Description |
| :--- | :--- |
| 🎯 **Gestionnaire Intelligent** | Sélectionne automatiquement le meilleur runtime (Bun → pnpm → npm). |
| 🎨 **Raccourcis Modernes** | Entrées de bureau natives avec icônes et intégration OS. |
| ⚡ **Instance Unique** | Garantit qu'une seule fenêtre s'exécute à la fois. |
| 🔍 **Détection Automatique** | Localise automatiquement `openchamber` dans le PATH. |
| 🔒 **Sandbox Sécurisé** | Exécute l'interface web dans une iframe isolée. |
| 🧹 **Gestion de Cycle** | Arrête automatiquement tous les processus à la fermeture. |

---

## 📦 Installation Alternative

Si vous préférez le contrôle manuel :

**Bun :**
```bash
bun install -g openchamber-desktop
```

**NPM :**
```bash
npm install -g openchamber-desktop
```

**PNPM :**
```bash
pnpm add -g openchamber-desktop
```

---

## 🎮 Utilisation

Une fois installé :
- `ocd` - Lance l'application (raccourci)
- `openchamber-desktop` - Lance l'application

---

## ⌨️ Raccourcis Clavier

| Raccourci (PC) | Raccourci (Mac) | Action |
| :--- | :--- | :--- |
| `F11` | `F11` | Plein Écran |
| `Ctrl` + `+` | `Cmd` + `+` | Zoom Avant |
| `Ctrl` + `-` | `Cmd` + `-` | Zoom Arrière |
| `Ctrl` + `0` | `Cmd` + `0` | Réinitialiser Zoom |
| `Ctrl` + `Q` | `Cmd` + `Q` | Quitter |

---

## 🔧 Dépannage

**Problème :** L'app dit "OpenChamber not found"  
**Solution :**
```bash
# Installez OpenCode d'abord
bun add -g @openchamber/web
# ou
npm install -g @openchamber/web
```

**Problème :** Conflit de ports  
**Solution :**
```bash
# Tuez le processus sur le port 1504
lsof -ti:1504 | xargs kill -9
```

---

## 🚧 Développement

```bash
# Cloner & Installer
git clone https://github.com/aencyorganization/openchamber-desktop.git
cd openchamber-desktop
bun install

# Exécuter en mode développement
bun run dev
```

---

## 🤝 Contribuer

Voir [CONTRIBUTING.md](docs/CONTRIBUTING.md)

---

## 📄 Licence

**GNU General Public License v3.0 (GPL-3.0)**

Voir [LICENSE](LICENSE)

---

<p align="center">
  Fait avec 💚 par <a href="https://github.com/aencyorganization">Aency Organization</a>
</p>
