# Lanzador de OpenChamber

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

La forma más rápida de instalar OpenChamber Desktop es a través de nuestros **Instaladores en Una Línea**. Detectan automáticamente tu sistema, instalan dependencias y crean accesos directos optimizados.

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

### 📦 Instalador en Una Línea (Recomendado)

Ejecuta el siguiente comando en tu terminal:

**Windows (PowerShell - Admin):**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.ps1 | iex
```

**Linux / macOS (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.sh | bash
```

### 🔄 Actualización

Para actualizar a la versión más reciente:

**Windows:**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.ps1 | iex
```

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.sh | bash
```

### 🗑️ Desinstalación

Para eliminar completamente OpenChamber Desktop:

**Windows:**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.ps1 | iex
```

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/uninstall.sh | bash
```

---

## 📋 Índice

- [Funcionalidades](#-funcionalidades)
- [Requisitos](#-requisitos)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [Atajos de Teclado](#-atajos-de-teclado)
- [Desarrollo](#-desarrollo)
- [Compilación](#-compilación)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Solución de Problemas](#-solución-de-problemas)
- [Créditos](#-créditos)
- [Licencia](#-licencia)

---

## ✨ Funcionalidades

| Funcionalidad | Descripción |
|----------------|-----------|
| 🔍 **Autodetección** | Encuentra automáticamente la instalación de OpenChamber en el sistema |
| 🎯 **Detección Inteligente de Puerto** | Detecta automáticamente en qué puerto se está ejecutando OpenChamber |
| 🔒 **Contenedor Seguro** | Ejecuta OpenChamber en un iframe aislado con permisos controlados |
| 🧹 **Limpieza Automática** | Cierra automáticamente todos los procesos de OpenChamber al cerrar |
| 🖥️ **Multiplataforma** | Funciona en Linux (x64/ARM), macOS (Intel/Apple Silicon) y Windows |
| 📦 **Múltiples Métodos de Instalación** | Instala a través de npm, Bun, AppImage o descarga directa |
| ⌨️ **Atajos de Teclado** | Pantalla completa (F11), Zoom (Ctrl +/-), Restablecer Zoom (Ctrl+0) |
| 🎨 **UI Minimalista** | Interfaz negra limpia con una elegante animación de carga |
| 🚀 **Inicio Rápido** | Detecta OpenChamber existente o lo inicia automáticamente |
| 🛡️ **Manejo de Errores** | Mensajes de error elegantes y recuperación automática |

---

## 📦 Requisitos

### Requisitos del Sistema

- **Sistema Operativo:**
  - Linux: x64, ARM64, ARMv7
  - macOS: Intel (x64), Apple Silicon (ARM64)
  - Windows: x64
- **RAM:** 512 MB mínimo (1 GB recomendado)
- **Espacio en Disco:** 50 MB para el lanzador
- **Red:** Conexión a internet (para la funcionalidad de OpenChamber)

### Requisitos de Software

**Debes tener instalado OpenChamber:**

```bash
# Instalación rápida a través de curl
curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash

# O instalar a través de Bun
bun add -g @openchamber/web

# O instalar a través de npm
npm install -g @openchamber/web

# Verificar instalación
which openchamber
openchamber --version
```

---

## 🚀 Instalación

### Opción 1: Gestor de Paquetes (Recomendado)

**Bun (Más Rápido):**
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

### Opción 2: AppImage (Linux)

```bash
# Descargar
curl -L -o OpenChamber-Launcher-x86_64.AppImage \
  https://github.com/aencyorganization/openchamber-desktop/releases/latest/download/OpenChamber-Launcher-x86_64.AppImage

# Hacer ejecutable
chmod +x OpenChamber-Launcher-x86_64.AppImage

# Ejecutar
./OpenChamber-Launcher-x86_64.AppImage

# Opcional: Instalar en el sistema
sudo mv OpenChamber-Launcher-x86_64.AppImage /usr/local/bin/openchamber-desktop
```

### Opción 3: Descarga Directa del Binario

Descarga el binario apropiado para tu plataforma en [GitHub Releases](https://github.com/aencyorganization/openchamber-desktop/releases):

| Plataforma | Arquitectura | Archivo |
|------------|-------------|---------|
| Linux | x64 | `openchamber-launcher-linux_x64` |
| Linux | ARM64 | `openchamber-launcher-linux_arm64` |
| Linux | ARMv7 | `openchamber-launcher-linux_armhf` |
| macOS | Intel | `openchamber-launcher-mac_x64` |
| macOS | Apple Silicon | `openchamber-launcher-mac_arm64` |
| macOS | Universal | `openchamber-launcher-mac_universal` |
| Windows | x64 | `openchamber-launcher-win_x64.exe` |

---

## 🎮 Uso

### Iniciando la App

```bash
# Si se instaló a través del gestor de paquetes
openchamber-desktop

# O usa el atajo
ocd

# Si usas AppImage
./OpenChamber-Launcher-x86_64.AppImage

# Si usas el binario directamente
./openchamber-launcher-linux_x64
```

### Qué Sucede Cuando Inicias

1. **Fase de Detección:** La aplicación verifica si OpenChamber ya se está ejecutando
2. **Escaneo de Puerto:** Si se está ejecutando, detecta qué puerto está usando (3000, 3001, 8080, etc.)
3. **Inicio Automático:** Si no se está ejecutando, inicia OpenChamber automáticamente
4. **Conexión:** Se conecta a OpenChamber y lo muestra en la ventana integrada
5. **Limpieza:** Cuando cierras la ventana, todos los procesos de OpenChamber se cierran

---

## ⌨️ Atajos de Teclado

| Atajo | Acción | Descripción |
|--------|------|-----------|
| `F11` | Alternar Pantalla Completa | Alterna entre modo ventana y pantalla completa |
| `Ctrl` + `+` | Aumentar Zoom | Aumenta el nivel de zoom de la interfaz |
| `Ctrl` + `-` | Disminuir Zoom | Disminuye el nivel de zoom de la interfaz |
| `Ctrl` + `0` | Restablecer Zoom | Vuelve al zoom predeterminado (100%) |
| `Cmd` + `+` | Aumentar Zoom (Mac) | Alternativa para macOS |
| `Cmd` + `-` | Disminuir Zoom (Mac) | Alternativa para macOS |
| `Cmd` + `0` | Restablecer Zoom (Mac) | Alternativa para macOS |

---

## 🛠️ Desarrollo

### Prerrequisitos

- [Bun](https://bun.sh/) o Node.js 18+
- [NeutralinoJS CLI](https://neutralino.js.org/)
- Git

### Configurar el Entorno de Desarrollo

```bash
# Clonar el repositorio
git clone https://github.com/aencyorganization/openchamber-desktop.git
cd openchamber-desktop

# Instalar dependencias
bun install

# Descargar binarios de Neutralino
bun run update

# Iniciar servidor de desarrollo (con hot-reload)
bun run dev
```

### Scripts Disponibles

```bash
# Modo desarrollo con hot-reload
bun run dev

# Compilar para todas las plataformas
bun run build

# Compilar versión release (optimizada)
bun run build:release

# Compilar AppImage (solo Linux)
bun run build:appimage

# Iniciar aplicación compilada
bun start
```

---

## 🔨 Compilación

### Compilar para Todas las Plataformas

```bash
# Instalar dependencias
bun install

# Descargar binarios
bun run update

# Compilar
bun run build:release
```

Los archivos compilados estarán en el directorio `dist/`.

### Compilar AppImage (Linux)

```bash
bun run build:appimage
```

Salida: `dist/OpenChamber-Launcher-x86_64.AppImage`

---

## 📁 Estructura del Proyecto

```
openchamber-desktop/
├── 📁 assets/                  # Imágenes, iconos, logos
├── 📁 bin/                     # Binarios compilados
├── 📁 config/                  # Archivos de configuración
├── 📁 docs/                    # Documentación
├── 📁 resources/               # Recursos de la aplicación
├── 📁 scripts/                 # Scripts de construcción
├── 📁 .github/                 # Plantillas y flujos de trabajo de GitHub
├── 📄 package.json            # Configuración principal
├── 📄 neutralino.config.json  # Configuración de Neutralino
├── 📄 README.md               # Este archivo (Inglés)
├── 📄 README.pt.md            # Versión en Portugués
├── 📄 README.es.md            # Versión en Español
├── 📄 README.fr.md            # Versión en Francés
├── 📄 README.de.md            # Versión en Alemán
└── 📄 LICENSE                 # Licencia GPL-3.0
```

---

## 🔧 Solución de Problemas

### La aplicación dice "OpenChamber not found"

**Problema:** OpenChamber no está instalado o no está en el PATH.

**Solución:**
```bash
# Instalar OpenChamber
curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash

# Verificar si está en el PATH
which openchamber

# Si no está en el PATH, añádelo (ejemplo para Bun)
export PATH="$HOME/.bun/bin:$PATH"
```

### Tiempo de espera en la detección de puerto

**Problema:** La aplicación no puede detectar en qué puerto se está ejecutando OpenChamber.

**Solución:**
- Verifica si OpenChamber se está ejecutando realmente: `openchamber --version`
- Verifica si los puertos 3000-3010 están disponibles
- Intenta especificar el puerto manualmente en la configuración de OpenChamber

### Error "NE_CL_IVCTOKN"

**Problema:** Error de token de autenticación con Neutralino.

**Solución:**
- Reinicia la aplicación
- Limpia el almacenamiento de sesión del navegador
- Si persiste, elimina la carpeta `.tmp/` y reinicia

### AppImage no se ejecuta

**Problema:** AppImage no se ejecuta.

**Solución:**
```bash
# Hacer ejecutable
chmod +x OpenChamber-Launcher-x86_64.AppImage

# Instalar FUSE (si falta)
sudo apt install libfuse2  # Ubuntu/Debian
sudo pacman -S fuse2       # Arch

# O usa la bandera --appimage-extract
./OpenChamber-Launcher-x86_64.AppImage --appimage-extract
./squashfs-root/AppRun
```

---

## 🙏 Créditos

### Proyectos Originales

- **[OpenChamber](https://github.com/btriapitsyn/openchamber)** - Interfaz de escritorio y web para el agente de IA OpenCode
  - Creado por [Bogdan Triapitsyn](https://github.com/btriapitsyn)
  - Repositorio: https://github.com/btriapitsyn/openchamber

- **[OpenCode](https://opencode.ai)** - Asistente de IA para terminal
  - Desarrollado por [Anomaly Innovations](https://anomalyinnovations.com)
  - Sitio web: https://opencode.ai

### Tecnologías Utilizadas

- [NeutralinoJS](https://neutralino.js.org/) - Framework de escritorio multiplataforma
- [neutralino-appimage-bundler](https://github.com/krypt0nn/neutralino-appimage-bundler) - Herramienta de empaquetado AppImage
- [Bun](https://bun.sh/) - Runtime de JavaScript rápido y gestor de paquetes

---

## 📄 Licencia

Este proyecto está licenciado bajo la **GNU General Public License v3.0 (GPL-3.0)**.

Consulta el archivo [LICENSE](LICENSE) para obtener detalles completos.

---

## ⚠️ Aviso Legal

Este es un **proyecto independiente** y no está oficialmente afiliado a OpenCode o Anomaly Innovations. OpenChamber y OpenCode son marcas registradas de sus respectivos propietarios.

---

<p align="center">
  Hecho con 💚 por <a href="https://github.com/aencyorganization">Aency Organization</a>
</p>
