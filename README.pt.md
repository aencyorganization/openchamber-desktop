# OpenChamber Desktop

<p align="center">
  <img src="https://raw.githubusercontent.com/btriapitsyn/openchamber/main/docs/references/badges/openchamber-logo-light.svg" width="120" alt="Logo do OpenChamber">
</p>

<p align="center">
  <a href="README.md">🇺🇸 English</a> | 
  <a href="README.pt.md">🇧🇷 Português</a> | 
  <a href="README.es.md">🇪🇸 Español</a> | 
  <a href="README.fr.md">🇫🇷 Français</a> | 
  <a href="README.de.md">🇩🇪 Deutsch</a>
</p>

<p align="center">
  <b>Um launcher desktop leve para o OpenChamber</b><br>
  Multiplataforma • Autodetecção • Minimalista • Seguro
</p>

---

## 🚀 Início Rápido

### 📋 Pré-requisitos

**Você precisa ter o OpenCode instalado separadamente.** Este script instala apenas o launcher do OpenChamber Desktop, não o OpenCode em si.

Instale o OpenCode primeiro:
```bash
# Via Bun (recomendado)
curl -fsSL https://bun.sh/install | bash
bun install -g @openchamber/web

# Ou via npm
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

### 🔄 Atualizar

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

| Funcionalidade | Descrição |
|----------------|-----------|
| 🎯 **Gerenciador Inteligente** | Seleciona automaticamente o melhor runtime (Bun → pnpm → npm). |
| 🎨 **Atalhos Modernos** | Entradas de desktop nativas com ícones e integração com SO. |
| ⚡ **Instância Única** | Garante que apenas uma janela execute por vez. |
| 🔍 **Autodetecção** | Localiza automaticamente o `openchamber` no PATH. |
| 🔒 **Sandbox Seguro** | Executa a interface web em um iframe isolado. |
| 🧹 **Gerenciamento de Ciclo** | Encerra automaticamente todos os processos ao fechar. |

---

## 📦 Instalação Alternativa

Se preferir controle manual:

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

Após instalado:
- `ocd` - Inicia a aplicação (atalho)
- `openchamber-desktop` - Inicia a aplicação

---

## ⌨️ Atalhos de Teclado

| Atalho (PC) | Atalho (Mac) | Ação |
| :--- | :--- | :--- |
| `F11` | `F11` | Tela Cheia |
| `Ctrl` + `+` | `Cmd` + `+` | Aumentar Zoom |
| `Ctrl` + `-` | `Cmd` + `-` | Diminuir Zoom |
| `Ctrl` + `0` | `Cmd` + `0` | Resetar Zoom |
| `Ctrl` + `Q` | `Cmd` + `Q` | Sair |

---

## 🔧 Solução de Problemas

**Problema:** App diz "OpenChamber not found"  
**Solução:**
```bash
# Instale o OpenCode primeiro
bun add -g @openchamber/web
# ou
npm install -g @openchamber/web
```

**Problema:** Conflito de portas  
**Solução:**
```bash
# Mate o processo na porta 1504
lsof -ti:1504 | xargs kill -9
```

---

## 🚧 Desenvolvimento

```bash
# Clone & Instale
git clone https://github.com/aencyorganization/openchamber-desktop.git
cd openchamber-desktop
bun install

# Execute em modo desenvolvimento
bun run dev
```

---

## 🤝 Contribuindo

Veja [CONTRIBUTING.md](docs/CONTRIBUTING.md)

---

## 📄 Licença

**GNU General Public License v3.0 (GPL-3.0)**

Veja [LICENSE](LICENSE)

---

<p align="center">
  Feito com 💚 por <a href="https://github.com/aencyorganization">Aency Organization</a>
</p>
