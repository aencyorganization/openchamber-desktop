# OpenChamber Desktop

<p align="center">
  <img src="https://raw.githubusercontent.com/btriapitsyn/openchamber/main/docs/references/badges/openchamber-logo-light.svg" width="120" alt="Logo de OpenChamber">
</p>

<p align="center">
  <a href="README.md">🇺🇸 English</a> | 
  <a href="README.pt.md">🇧🇷 Português</a> | 
  <a href="README.es.md">🇪🇸 Español</a> | 
  <a href="README.fr.md">🇫🇷 Français</a> | 
  <a href="README.de.md">🇩🇪 Deutsch</a>
</p>

<p align="center">
  <b>Un lanzador de escritorio ligero para OpenChamber</b><br>
  Multiplataforma • Autodetección • Minimalista • Seguro
</p>

---

## 🚀 Inicio Rápido

### 📋 Prerrequisitos

**Necesitas tener OpenCode instalado por separado.** Este script solo instala el launcher de OpenChamber Desktop, no el OpenCode en sí.

Instala OpenCode primero:
```bash
# Via Bun (recomendado)
curl -fsSL https://bun.sh/install | bash
bun install -g @openchamber/web

# O via npm
npm install -g @openchamber/web
```

### 📦 Instalar

**Windows (PowerShell - Admin):**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.ps1 | iex
```

**Linux / macOS (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.sh | bash
```

### 🔄 Actualizar

**Windows:**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.ps1 | iex
```

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.sh | bash
```

### 🗑️ Desinstalar

**Windows:**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.ps1 | iex
```

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.sh | bash
```

---

## ✨ Funcionalidades

| Funcionalidad | Descripción |
| :--- | :--- |
| 🎯 **Gestor Inteligente** | Selecciona automáticamente el mejor runtime (Bun → pnpm → npm). |
| 🎨 **Accesos Directos** | Entradas de escritorio nativas con iconos e integración con SO. |
| ⚡ **Instancia Única** | Garantiza que solo una ventana se ejecute a la vez. |
| 🔍 **Autodetección** | Localiza automáticamente `openchamber` en el PATH. |
| 🔒 **Sandbox Seguro** | Ejecuta la interfaz web en un iframe aislado. |
| 🧹 **Gestión de Ciclo** | Cierra automáticamente todos los procesos al cerrar. |

---

## 📦 Instalación Alternativa

Si prefieres control manual:

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

## 🎮 Uso

Una vez instalado:
- `ocd` - Inicia la aplicación (atajo)
- `openchamber-desktop` - Inicia la aplicación

---

## ⌨️ Atajos de Teclado

| Atajo (PC) | Atajo (Mac) | Acción |
| :--- | :--- | :--- |
| `F11` | `F11` | Pantalla Completa |
| `Ctrl` + `+` | `Cmd` + `+` | Zoom Acercar |
| `Ctrl` + `-` | `Cmd` + `-` | Zoom Alejar |
| `Ctrl` + `0` | `Cmd` + `0` | Resetear Zoom |
| `Ctrl` + `Q` | `Cmd` + `Q` | Salir |

---

## 🔧 Solución de Problemas

**Problema:** App dice "OpenChamber not found"  
**Solución:**
```bash
# Instala OpenCode primero
bun add -g @openchamber/web
# o
npm install -g @openchamber/web
```

**Problema:** Conflicto de puertos  
**Solución:**
```bash
# Mata el proceso en el puerto 1504
lsof -ti:1504 | xargs kill -9
```

---

## 🚧 Desarrollo

```bash
# Clonar & Instalar
git clone https://github.com/aencyorganization/openchamber-desktop.git
cd openchamber-desktop
bun install

# Ejecutar en modo desarrollo
bun run dev
```

---

## 🤝 Contribuyendo

Ve [CONTRIBUTING.md](docs/CONTRIBUTING.md)

---

## 📄 Licencia

**GNU General Public License v3.0 (GPL-3.0)**

Ve [LICENSE](LICENSE)

---

<p align="center">
  Hecho con 💚 por <a href="https://github.com/aencyorganization">Aency Organization</a>
</p>
