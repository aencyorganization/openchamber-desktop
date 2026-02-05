# OpenChamber Launcher

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

Le moyen le plus rapide d'installer OpenChamber Desktop est via nos **Installateurs en Une Ligne**. Ils détectent automatiquement votre système, installent les dépendances et créent des raccourcis optimisés.

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

### 📦 Installateur en Une Ligne (Recommandé)

Exécutez la commande ci-dessous dans votre terminal :

**Windows (PowerShell - Admin) :**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.ps1 | iex
```

**Linux / macOS (Bash) :**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.sh | bash
```

### 🔄 Mise à Jour

Pour mettre à jour vers la dernière version :

**Windows :**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.ps1 | iex
```

**Linux / macOS :**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.sh | bash
```

### 🗑️ Désinstallation

Pour supprimer complètement OpenChamber Desktop :

**Windows :**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.ps1 | iex
```

**Linux / macOS :**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.sh | bash
```

---

## 📋 Table des Matières

- [Fonctionnalités](#-fonctionnalités)
- [Configuration Requise](#-configuration-requise)
- [Installation](#-installation)
- [Utilisation](#-utilisation)
- [Raccourcis Clavier](#-raccourcis-clavier)
- [Développement](#-développement)
- [Compilation](#-compilation)
- [Structure du Projet](#-structure-du-projet)
- [Dépannage](#-dépannage)
- [Crédits](#-crédits)
- [Licence](#-licence)

---

## ✨ Fonctionnalités

| Fonctionnalité | Description |
|----------------|-----------|
| 🔍 **Détection Automatique** | Trouve automatiquement l'installation d'OpenChamber sur le système |
| 🎯 **Détection de Port Intelligente** | Détecte automatiquement sur quel port OpenChamber s'exécute |
| 🔒 **Conteneur Sécurisé** | Exécute OpenChamber dans une iframe isolée avec des permissions contrôlées |
| 🧹 **Nettoyage Automatique** | Arrête automatiquement tous les processus OpenChamber à la fermeture |
| 🖥️ **Multiplateforme** | Fonctionne sur Linux (x64/ARM), macOS (Intel/Apple Silicon) et Windows |
| 📦 **Plusieurs Méthodes d'Installation** | Installation via npm, Bun, AppImage ou téléchargement direct |
| ⌨️ **Raccourcis Clavier** | Plein écran (F11), Zoom (Ctrl +/-), Réinitialiser le Zoom (Ctrl+0) |
| 🎨 **UI Minimaliste** | Interface noire épurée avec une animation de chargement élégante |
| 🚀 **Lancement Rapide** | Détecte l'OpenChamber existant ou le démarre automatiquement |
| 🛡️ **Gestion des Erreurs** | Messages d'erreur élégants et récupération automatique |

---

## 📦 Configuration Requise

### Configuration Système

- **Système d'Exploitation :**
  - Linux : x64, ARM64, ARMv7
  - macOS : Intel (x64), Apple Silicon (ARM64)
  - Windows : x64
- **RAM :** 512 Mo minimum (1 Go recommandé)
- **Espace Disque :** 50 Mo pour le lanceur
- **Réseau :** Connexion Internet (pour les fonctionnalités d'OpenChamber)

### Prérequis Logiciels

**Vous devez avoir installé OpenChamber :**

```bash
# Installation rapide via curl
curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash

# Ou installation via Bun
bun add -g @openchamber/web

# Ou installation via npm
npm install -g @openchamber/web

# Vérifier l'installation
which openchamber
openchamber --version
```

---

## 🚀 Installation

### Option 1 : Gestionnaire de Paquets (Recommandé)

**Bun (Le plus rapide) :**
```bash
bun install -g openchamber-desktop
```

**npm :**
```bash
npm install -g openchamber-desktop
```

**pnpm :**
```bash
pnpm add -g openchamber-desktop
```

**Yarn :**
```bash
yarn global add openchamber-desktop
```

### Option 2 : AppImage (Linux)

```bash
# Télécharger
curl -L -o OpenChamber-Launcher-x86_64.AppImage \
  https://github.com/aencyorganization/openchamber-desktop/releases/latest/download/OpenChamber-Launcher-x86_64.AppImage

# Rendre exécutable
chmod +x OpenChamber-Launcher-x86_64.AppImage

# Exécuter
./OpenChamber-Launcher-x86_64.AppImage

# Optionnel : Installer sur le système
sudo mv OpenChamber-Launcher-x86_64.AppImage /usr/local/bin/openchamber-desktop
```

### Option 3 : Téléchargement Direct du Binaire

Téléchargez le binaire approprié pour votre plateforme sur [GitHub Releases](https://github.com/aencyorganization/openchamber-desktop/releases) :

| Plateforme | Architecture | Fichier |
|------------|-------------|---------|
| Linux | x64 | `openchamber-launcher-linux_x64` |
| Linux | ARM64 | `openchamber-launcher-linux_arm64` |
| Linux | ARMv7 | `openchamber-launcher-linux_armhf` |
| macOS | Intel | `openchamber-launcher-mac_x64` |
| macOS | Apple Silicon | `openchamber-launcher-mac_arm64` |
| macOS | Universal | `openchamber-launcher-mac_universal` |
| Windows | x64 | `openchamber-launcher-win_x64.exe` |

---

## 🎮 Utilisation

### Démarrage de l'App

```bash
# Si installé via gestionnaire de paquets
openchamber-desktop

# Ou utiliser le raccourci
ocd

# Si vous utilisez AppImage
./OpenChamber-Launcher-x86_64.AppImage

# Si vous utilisez le binaire directement
./openchamber-launcher-linux_x64
```

### Que se passe-t-il au démarrage

1. **Phase de Détection :** L'app vérifie si OpenChamber s'exécute déjà
2. **Scan de Port :** S'il s'exécute, détecte quel port il utilise (3000, 3001, 8080, etc.)
3. **Auto-démarrage :** S'il ne s'exécute pas, démarre automatiquement OpenChamber
4. **Connexion :** Se connecte à OpenChamber et l'affiche dans la fenêtre intégrée
5. **Nettoyage :** Lorsque vous fermez la fenêtre, tous les processus OpenChamber sont arrêtés

---

## ⌨️ Raccourcis Clavier

| Raccourci | Action | Description |
|-----------|--------|-------------|
| `F11` | Basculer Plein Écran | Alterne entre le mode fenêtre et plein écran |
| `Ctrl` + `+` | Zoom Avant | Augmente le niveau de zoom de l'interface |
| `Ctrl` + `-` | Zoom Arrière | Diminue le niveau de zoom de l'interface |
| `Ctrl` + `0` | Réinitialiser le Zoom | Revient au zoom par défaut (100%) |
| `Cmd` + `+` | Zoom Avant (Mac) | Alternative pour macOS |
| `Cmd` + `-` | Zoom Arrière (Mac) | Alternative pour macOS |
| `Cmd` + `0` | Réinitialiser le Zoom (Mac) | Alternative pour macOS |

---

## 🛠️ Développement

### Prérequis

- [Bun](https://bun.sh/) ou Node.js 18+
- [NeutralinoJS CLI](https://neutralino.js.org/)
- Git

### Configurer l'Environnement de Développement

```bash
# Cloner le dépôt
git clone https://github.com/aencyorganization/openchamber-desktop.git
cd openchamber-desktop

# Installer les dépendances
bun install

# Télécharger les binaires Neutralino
bun run update

# Démarrer le serveur de développement (avec hot-reload)
bun run dev
```

### Scripts Disponibles

```bash
# Mode développement avec hot-reload
bun run dev

# Compiler pour toutes les plateformes
bun run build

# Compiler la version release (optimisée)
bun run build:release

# Compiler AppImage (Linux uniquement)
bun run build:appimage

# Démarrer l'application compilée
bun start
```

---

## 🔨 Compilation

### Compiler pour Toutes les Plateformes

```bash
# Installer les dépendances
bun install

# Télécharger les binaires
bun run update

# Compiler
bun run build:release
```

Les fichiers compilés se trouveront dans le répertoire `dist/`.

### Compiler AppImage (Linux)

```bash
bun run build:appimage
```

Sortie : `dist/OpenChamber-Launcher-x86_64.AppImage`

---

## 📁 Structure du Projet

```
openchamber-desktop/
├── 📁 assets/                  # Images, icônes, logos
├── 📁 bin/                     # Binaires compilés
├── 📁 config/                  # Fichiers de configuration
├── 📁 docs/                    # Documentation
├── 📁 resources/               # Ressources de l'application
├── 📁 scripts/                 # Scripts de build
├── 📁 .github/                 # Templates et workflows GitHub
├── 📄 package.json            # Configuration principale
├── 📄 neutralino.config.json  # Configuration Neutralino
├── 📄 README.md               # Ce fichier (Anglais)
├── 📄 README.pt.md            # Version Portugaise
├── 📄 README.es.md            # Version Espagnole
├── 📄 README.fr.md            # Version Française
├── 📄 README.de.md            # Version Allemande
└── 📄 LICENSE                 # Licence GPL-3.0
```

---

## 🔧 Dépannage

### L'app affiche "OpenChamber not found"

**Problème :** OpenChamber n'est pas installé ou n'est pas dans le PATH.

**Solution :**
```bash
# Installer OpenChamber
curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash

# Vérifier s'il est dans le PATH
which openchamber

# S'il n'est pas dans le PATH, ajoutez-le (exemple pour Bun)
export PATH="$HOME/.bun/bin:$PATH"
```

### Timeout lors de la détection de port

**Problème :** L'app ne parvient pas à détecter sur quel port OpenChamber s'exécute.

**Solution :**
- Vérifiez si OpenChamber s'exécute réellement : `openchamber --version`
- Vérifiez si les ports 3000-3010 sont disponibles
- Essayez de spécifier le port manuellement dans la configuration d'OpenChamber

### Erreur "NE_CL_IVCTOKN"

**Problème :** Erreur de jeton d'authentification avec Neutralino.

**Solution :**
- Redémarrez l'application
- Effacez le session storage du navigateur
- Si le problème persiste, supprimez le dossier `.tmp/` et redémarrez

### L'AppImage ne se lance pas

**Problème :** L'AppImage ne s'exécute pas.

**Solution :**
```bash
# Rendre exécutable
chmod +x OpenChamber-Launcher-x86_64.AppImage

# Installer FUSE (si manquant)
sudo apt install libfuse2  # Ubuntu/Debian
sudo pacman -S fuse2       # Arch

# Ou utiliser le flag --appimage-extract
./OpenChamber-Launcher-x86_64.AppImage --appimage-extract
./squashfs-root/AppRun
```

---

## 🙏 Crédits

### Projets Originaux

- **[OpenChamber](https://github.com/btriapitsyn/openchamber)** - Interface bureau et web pour l'agent IA OpenCode
  - Créé par [Bogdan Triapitsyn](https://github.com/btriapitsyn)
  - Dépôt : https://github.com/btriapitsyn/openchamber

- **[OpenCode](https://opencode.ai)** - Assistant IA pour terminal
  - Développé par [Anomaly Innovations](https://anomalyinnovations.com)
  - Site web : https://opencode.ai

### Technologies Utilisées

- [NeutralinoJS](https://neutralino.js.org/) - Framework de bureau multiplateforme
- [neutralino-appimage-bundler](https://github.com/krypt0nn/neutralino-appimage-bundler) - Outil de packaging AppImage
- [Bun](https://bun.sh/) - Runtime JavaScript rapide et gestionnaire de paquets

---

## 📄 Licence

Ce projet est sous licence **GNU General Public License v3.0 (GPL-3.0)**.

Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## ⚠️ Avertissement Légal

Ceci est un **projet indépendant** et n'est pas officiellement affilié à OpenCode ou Anomaly Innovations. OpenChamber et OpenCode sont des marques déposées de leurs propriétaires respectifs.

---

<p align="center">
  Fait avec 💚 par <a href="https://github.com/aencyorganization">Aency Organization</a>
</p>
