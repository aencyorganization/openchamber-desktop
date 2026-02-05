# OpenChamber Launcher

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

A forma mais rápida de instalar o OpenChamber Desktop é através dos nossos **Instaladores em Uma Linha**. Eles detectam automaticamente seu sistema, instalam dependências e criam atalhos otimizados.

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

### 📦 Instalador em Uma Linha (Recomendado)

Execute o comando abaixo no seu terminal:

**Windows (PowerShell - Admin):**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.ps1 | iex
```

**Linux / macOS (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/install.sh | bash
```

### 🔄 Atualização

Para atualizar para a versão mais recente:

**Windows:**
```powershell
irm https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.ps1 | iex
```

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/update.sh | bash
```

### 🗑️ Desinstalação

Para remover completamente o OpenChamber Desktop:

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
- [Instalação](#-instalação)
- [Uso](#-uso)
- [Atalhos de Teclado](#-atalhos-de-teclado)
- [Desenvolvimento](#-desenvolvimento)
- [Compilação](#-compilação)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Solução de Problemas](#-solução-de-problemas)
- [Créditos](#-créditos)
- [Licença](#-licença)

---

## ✨ Funcionalidades

| Funcionalidade | Descrição |
|----------------|-----------|
| 🔍 **Autodetecção** | Encontra automaticamente a instalação do OpenChamber no sistema |
| 🎯 **Detecção Inteligente de Porta** | Detecta automaticamente em qual porta o OpenChamber está rodando |
| 🔒 **Contêiner Seguro** | Executa o OpenChamber em um iframe isolado com permissões controladas |
| 🧹 **Limpeza Automática** | Encerra automaticamente todos os processos do OpenChamber ao fechar |
| 🖥️ **Multiplataforma** | Funciona em Linux (x64/ARM), macOS (Intel/Apple Silicon) e Windows |
| 📦 **Múltiplos Métodos de Instalação** | Instale via npm, Bun, AppImage ou download direto |
| ⌨️ **Atalhos de Teclado** | Tela cheia (F11), Zoom (Ctrl +/-), Resetar Zoom (Ctrl+0) |
| 🎨 **UI Minimalista** | Interface preta limpa com animação de carregamento elegante |
| 🚀 **Início Rápido** | Detecta OpenChamber existente ou inicia automaticamente |
| 🛡️ **Tratamento de Erros** | Mensagens de erro elegantes e recuperação automática |

---

## 📦 Requisitos

### Requisitos do Sistema

- **Sistema Operacional:**
  - Linux: x64, ARM64, ARMv7
  - macOS: Intel (x64), Apple Silicon (ARM64)
  - Windows: x64
- **RAM:** 512 MB mínimo (1 GB recomendado)
- **Espaço em Disco:** 50 MB para o launcher
- **Rede:** Conexão com internet (para funcionalidade do OpenChamber)

### Requisitos de Software

**Você deve ter o OpenChamber instalado:**

```bash
# Instalação rápida via curl
curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash

# Ou instalar via Bun
bun add -g @openchamber/web

# Ou instalar via npm
npm install -g @openchamber/web

# Verificar instalação
which openchamber
openchamber --version
```

---

## 🚀 Instalação

### Opção 1: Gerenciador de Pacotes (Recomendado)

**Bun (Mais Rápido):**
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

### Opção 2: AppImage (Linux)

```bash
# Baixar
curl -L -o OpenChamber-Launcher-x86_64.AppImage \
  https://github.com/aencyorganization/openchamber-desktop/releases/latest/download/OpenChamber-Launcher-x86_64.AppImage

# Tornar executável
chmod +x OpenChamber-Launcher-x86_64.AppImage

# Executar
./OpenChamber-Launcher-x86_64.AppImage

# Opcional: Instalar no sistema
sudo mv OpenChamber-Launcher-x86_64.AppImage /usr/local/bin/openchamber-desktop
```

### Opção 3: Download Direto do Binário

Baixe o binário apropriado para sua plataforma em [GitHub Releases](https://github.com/aencyorganization/openchamber-desktop/releases):

| Plataforma | Arquitetura | Arquivo |
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

### Iniciando o App

```bash
# Se instalado via gerenciador de pacotes
openchamber-desktop

# Ou use o atalho
ocd

# Se usando AppImage
./OpenChamber-Launcher-x86_64.AppImage

# Se usando binário diretamente
./openchamber-launcher-linux_x64
```

### O Que Acontece Quando Você Inicia

1. **Fase de Detecção:** O app verifica se o OpenChamber já está rodando
2. **Scan de Porta:** Se estiver rodando, detecta qual porta está usando (3000, 3001, 8080, etc.)
3. **Auto-início:** Se não estiver rodando, inicia o OpenChamber automaticamente
4. **Conexão:** Conecta ao OpenChamber e exibe na janela incorporada
5. **Limpeza:** Quando você fecha a janela, todos os processos do OpenChamber são encerrados

---

## ⌨️ Atalhos de Teclado

| Atalho | Ação | Descrição |
|--------|------|-----------|
| `F11` | Alternar Tela Cheia | Alterna entre modo janela e tela cheia |
| `Ctrl` + `+` | Aumentar Zoom | Aumenta o nível de zoom da interface |
| `Ctrl` + `-` | Diminuir Zoom | Diminui o nível de zoom da interface |
| `Ctrl` + `0` | Resetar Zoom | Retorna ao zoom padrão (100%) |
| `Cmd` + `+` | Aumentar Zoom (Mac) | Alternativa para macOS |
| `Cmd` + `-` | Diminuir Zoom (Mac) | Alternativa para macOS |
| `Cmd` + `0` | Resetar Zoom (Mac) | Alternativa para macOS |

---

## 🛠️ Desenvolvimento

### Pré-requisitos

- [Bun](https://bun.sh/) ou Node.js 18+
- [NeutralinoJS CLI](https://neutralino.js.org/)
- Git

### Configurar Ambiente de Desenvolvimento

```bash
# Clonar o repositório
git clone https://github.com/aencyorganization/openchamber-desktop.git
cd openchamber-desktop

# Instalar dependências
bun install

# Baixar binários do Neutralino
bun run update

# Iniciar servidor de desenvolvimento (com hot-reload)
bun run dev
```

### Scripts Disponíveis

```bash
# Modo desenvolvimento com hot-reload
bun run dev

# Compilar para todas as plataformas
bun run build

# Compilar versão release (otimizada)
bun run build:release

# Compilar AppImage (Linux apenas)
bun run build:appimage

# Iniciar aplicação compilada
bun start
```

---

## 🔨 Compilação

### Compilar para Todas as Plataformas

```bash
# Instalar dependências
bun install

# Baixar binários
bun run update

# Compilar
bun run build:release
```

Os arquivos compilados estarão no diretório `dist/`.

### Compilar AppImage (Linux)

```bash
bun run build:appimage
```

Saída: `dist/OpenChamber-Launcher-x86_64.AppImage`

---

## 📁 Estrutura do Projeto

```
openchamber-desktop/
├── 📁 assets/                  # Imagens, ícones, logos
├── 📁 bin/                     # Binários compilados
├── 📁 config/                  # Arquivos de configuração
├── 📁 docs/                    # Documentação
├── 📁 resources/               # Recursos da aplicação
├── 📁 scripts/                 # Scripts de build
├── 📁 .github/                 # Templates e workflows do GitHub
├── 📄 package.json            # Configuração principal
├── 📄 neutralino.config.json  # Configuração do Neutralino
├── 📄 README.md               # Este arquivo (Inglês)
├── 📄 README.pt.md            # Versão em Português
├── 📄 README.es.md            # Versão em Espanhol
├── 📄 README.fr.md            # Versão em Francês
├── 📄 README.de.md            # Versão em Alemão
└── 📄 LICENSE                 # Licença GPL-3.0
```

---

## 🔧 Solução de Problemas

### App diz "OpenChamber not found"

**Problema:** OpenChamber não está instalado ou não está no PATH.

**Solução:**
```bash
# Instalar OpenChamber
curl -fsSL https://raw.githubusercontent.com/btriapitsyn/openchamber/main/scripts/install.sh | bash

# Verificar se está no PATH
which openchamber

# Se não estiver no PATH, adicione (exemplo para Bun)
export PATH="$HOME/.bun/bin:$PATH"
```

### Timeout na detecção de porta

**Problema:** App não consegue detectar em qual porta o OpenChamber está rodando.

**Solução:**
- Verifique se o OpenChamber está realmente rodando: `openchamber --version`
- Verifique se as portas 3000-3010 estão disponíveis
- Tente especificar a porta manualmente na configuração do OpenChamber

### Erro "NE_CL_IVCTOKN"

**Problema:** Erro de token de autenticação com o Neutralino.

**Solução:**
- Reinicie a aplicação
- Limpe o session storage do navegador
- Se persistir, delete a pasta `.tmp/` e reinicie

### AppImage não executa

**Problema:** AppImage não executa.

**Solução:**
```bash
# Tornar executável
chmod +x OpenChamber-Launcher-x86_64.AppImage

# Instalar FUSE (se faltar)
sudo apt install libfuse2  # Ubuntu/Debian
sudo pacman -S fuse2       # Arch

# Ou use a flag --appimage-extract
./OpenChamber-Launcher-x86_64.AppImage --appimage-extract
./squashfs-root/AppRun
```

---

## 🙏 Créditos

### Projetos Originais

- **[OpenChamber](https://github.com/btriapitsyn/openchamber)** - Interface desktop e web para o agente de IA OpenCode
  - Criado por [Bogdan Triapitsyn](https://github.com/btriapitsyn)
  - Repositório: https://github.com/btriapitsyn/openchamber

- **[OpenCode](https://opencode.ai)** - Assistente de IA para terminal
  - Desenvolvido por [Anomaly Innovations](https://anomalyinnovations.com)
  - Website: https://opencode.ai

### Tecnologias Utilizadas

- [NeutralinoJS](https://neutralino.js.org/) - Framework desktop multiplataforma
- [neutralino-appimage-bundler](https://github.com/krypt0nn/neutralino-appimage-bundler) - Ferramenta de empacotamento AppImage
- [Bun](https://bun.sh/) - Runtime JavaScript rápido e gerenciador de pacotes

---

## 📄 Licença

Este projeto está licenciado sob a **GNU General Public License v3.0 (GPL-3.0)**.

Veja o arquivo [LICENSE](LICENSE) para detalhes completos.

---

## ⚠️ Aviso Legal

Este é um **projeto independente** e não é oficialmente afiliado ao OpenCode ou Anomaly Innovations. OpenChamber e OpenCode são marcas registradas de seus respectivos proprietários.

---

<p align="center">
  Feito com 💚 por <a href="https://github.com/aencyorganization">Aency Organization</a>
</p>
