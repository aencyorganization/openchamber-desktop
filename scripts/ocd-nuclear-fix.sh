#!/bin/bash
#
# OpenChamber Desktop - Script Nuclear de Correção Completa
# Limpa TUDO, reinstala e configura corretamente para Linux/KDE
# Uso: curl -fsSL ... | bash
#

set -e

APP_NAME="OpenChamber Desktop"
PKG_NAME="openchamber-desktop"
REPO_URL="https://github.com/aencyorganization/openchamber-desktop"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[OCD-NUCLEAR]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
}

info() {
    echo -e "${CYAN}[i]${NC} $1"
}

header() {
    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}$1${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ============================================
# ETAPA 1: PARAR TUDO
# ============================================
stop_everything() {
    header "ETAPA 1: PARANDO TUDO"
    
    # Parar processos do OpenChamber
    log "Parando processos do OpenChamber..."
    pkill -f "openchamber" 2>/dev/null || true
    pkill -f "neutralino" 2>/dev/null || true
    
    # Parar serviços KDE
    if pgrep -x "plasmashell" >/dev/null 2>&1; then
        log "Parando plasmashell..."
        killall plasmashell 2>/dev/null || true
        sleep 2
    fi
    
    if pgrep -x "krunner" >/dev/null 2>&1; then
        log "Parando krunner..."
        killall krunner 2>/dev/null || true
    fi
    
    success "Processos parados"
}

# ============================================
# ETAPA 2: LIMPEZA NUCLEAR
# ============================================
nuclear_cleanup() {
    header "ETAPA 2: LIMPEZA NUCLEAR"
    
    # 2.1 Remover desktop entries
    log "Removendo todas as desktop entries..."
    
    desktop_dirs=(
        "$HOME/.local/share/applications"
        "/usr/share/applications"
        "/usr/local/share/applications"
    )
    
    for dir in "${desktop_dirs[@]}"; do
        if [ -d "$dir" ]; then
            find "$dir" -maxdepth 1 -type f \( -name "*openchamber*.desktop" -o -name "*ocd*.desktop" \) -exec rm -f {} \; 2>/dev/null || true
        fi
    done
    success "Desktop entries removidas"
    
    # 2.2 Limpar cache KDE
    log "Limpando cache do KDE..."
    rm -rf "$HOME/.cache/menus"/* 2>/dev/null || true
    rm -rf "$HOME/.cache/ksycoca5"* 2>/dev/null || true
    rm -f "$HOME/.cache/icon-cache.kcache" 2>/dev/null || true
    rm -rf "$HOME/.cache/krunner"/* 2>/dev/null || true
    rm -rf "$HOME/.cache/kactivitymanagerd"/* 2>/dev/null || true
    rm -rf "$HOME/.cache/plasmashell"/* 2>/dev/null || true
    success "Cache KDE limpo"
    
    # 2.3 Limpar configurações antigas
    log "Limpando configurações antigas..."
    rm -rf "$HOME/.config/openchamber" 2>/dev/null || true
    rm -rf "$HOME/.local/share/openchamber-desktop" 2>/dev/null || true
    rm -rf "$HOME/.local/lib/openchamber-desktop" 2>/dev/null || true
    
    # 2.4 Desinstalar pacotes npm/bun
    log "Desinstalando pacotes antigos..."
    
    if command -v bun >/dev/null 2>&1; then
        bun remove -g "$PKG_NAME" 2>/dev/null || true
        bun remove -g "@openchamber/web" 2>/dev/null || true
        bun remove -g "openchamber" 2>/dev/null || true
    fi
    
    if command -v npm >/dev/null 2>&1; then
        npm uninstall -g "$PKG_NAME" 2>/dev/null || true
        npm uninstall -g "@openchamber/web" 2>/dev/null || true
        npm uninstall -g "openchamber" 2>/dev/null || true
    fi
    
    # 2.5 Remover binários
    log "Removendo binários antigos..."
    rm -f "$HOME/.local/bin/openchamber-desktop" 2>/dev/null || true
    rm -f "$HOME/.local/bin/openchamber" 2>/dev/null || true
    rm -f "$HOME/.bun/bin/openchamber-desktop" 2>/dev/null || true
    rm -f "$HOME/.bun/bin/openchamber" 2>/dev/null || true
    rm -rf "$HOME/.local/lib/openchamber-desktop" 2>/dev/null || true
    rm -rf "/opt/openchamber-desktop" 2>/dev/null || true
    
    # 2.6 Remover aliases
    log "Removendo aliases..."
    for config in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$config" ]; then
            sed -i.bak '/alias ocd=/d' "$config" 2>/dev/null || true
            sed -i.bak '/alias openchamber-desktop=/d' "$config" 2>/dev/null || true
        fi
    done
    
    success "Limpeza nuclear concluída"
}

# ============================================
# ETAPA 3: REINSTALAÇÃO
# ============================================
reinstall() {
    header "ETAPA 3: REINSTALAÇÃO"
    
    # Detectar package manager
    log "Detectando package manager..."
    
    if command -v bun >/dev/null 2>&1 && bun --version >/dev/null 2>&1; then
        PM="bun"
        success "Bun encontrado"
    elif command -v pnpm >/dev/null 2>&1; then
        PM="pnpm"
        success "pnpm encontrado"
    elif command -v yarn >/dev/null 2>&1; then
        PM="yarn"
        success "yarn encontrado"
    elif command -v npm >/dev/null 2>&1; then
        PM="npm"
        success "npm encontrado"
    else
        # Instalar bun
        log "Instalando Bun..."
        curl -fsSL https://bun.sh/install | bash
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        PM="bun"
        success "Bun instalado"
    fi
    
    # Instalar OpenChamber Core
    log "Instalando OpenChamber Core..."
    case "$PM" in
        bun)
            bun add -g "@openchamber/web"
            ;;
        pnpm)
            pnpm add -g "@openchamber/web"
            ;;
        yarn)
            yarn global add "@openchamber/web"
            ;;
        npm)
            npm install -g "@openchamber/web"
            ;;
    esac
    success "OpenChamber Core instalado"
    
    # Instalar OpenChamber Desktop
    log "Instalando OpenChamber Desktop..."
    case "$PM" in
        bun)
            bun install -g "$PKG_NAME"
            ;;
        pnpm)
            pnpm add -g "$PKG_NAME"
            ;;
        yarn)
            yarn global add "$PKG_NAME"
            ;;
        npm)
            npm install -g "$PKG_NAME"
            ;;
    esac
    success "OpenChamber Desktop instalado"
    
    # Verificar instalação
    if ! command -v "$PKG_NAME" >/dev/null 2>&1; then
        error "Instalação falhou! Comando $PKG_NAME não encontrado"
        exit 1
    fi
    
    success "Reinstalação concluída"
}

# ============================================
# ETAPA 4: CONFIGURAR DESKTOP ENTRY
# ============================================
configure_desktop() {
    header "ETAPA 4: CONFIGURANDO DESKTOP ENTRY"
    
    local desktop_dir="$HOME/.local/share/applications"
    local desktop_file="$desktop_dir/openchamber-desktop.desktop"
    local icon_dir="$HOME/.local/share/icons/hicolor/256x256/apps"
    local icon_file="$icon_dir/openchamber-desktop.png"
    local config_dir="$HOME/.config/openchamber"
    
    mkdir -p "$desktop_dir"
    mkdir -p "$icon_dir"
    mkdir -p "$config_dir"
    
    # Baixar ícone
    log "Baixando ícone..."
    if curl -fsSL "$REPO_URL/raw/main/assets/openchamber-logo-dark.png" -o "$icon_file" 2>/dev/null; then
        success "Ícone baixado"
    else
        warn "Não foi possível baixar ícone, usando padrão"
        icon_file="utilities-terminal"
    fi
    
    # Detectar arquitetura para WM_CLASS
    local arch=$(uname -m)
    local wm_class
    case "$arch" in
        x86_64) wm_class="neutralino-linux_x64" ;;
        aarch64|arm64) wm_class="neutralino-linux_arm64" ;;
        armv7l|armhf) wm_class="neutralino-linux_armhf" ;;
        *) wm_class="neutralino-linux_x64" ;;
    esac
    
    # Encontrar executável
    local exec_path
    if command -v "$PKG_NAME" >/dev/null 2>&1; then
        exec_path="$PKG_NAME"
    elif [ -x "$HOME/.bun/bin/$PKG_NAME" ]; then
        exec_path="$HOME/.bun/bin/$PKG_NAME"
    elif [ -x "$HOME/.local/bin/$PKG_NAME" ]; then
        exec_path="$HOME/.local/bin/$PKG_NAME"
    else
        exec_path="$PKG_NAME"
    fi
    
    # Criar desktop entry
    log "Criando desktop entry..."
    cat > "$desktop_file" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=OpenChamber Desktop - AI Coding Assistant
Exec=$exec_path
Icon=openchamber-desktop
Terminal=false
Categories=Development;IDE;Utility;
Keywords=openchamber;opencode;ai;coding;ocd;
StartupNotify=true
StartupWMClass=$wm_class
X-GNOME-SingleWindow=true
X-KDE-StartupNotify=true
X-KDE-SubstituteUID=false
TryExec=$exec_path
MimeType=x-scheme-handler/openchamber;
X-Desktop-File-Install-Version=0.26
EOF
    
    chmod +x "$desktop_file"
    success "Desktop entry criada: $desktop_file"
    
    # Atualizar banco de dados
    log "Atualizando banco de dados..."
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$desktop_dir" 2>/dev/null || true
    fi
    
    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
    fi
    
    success "Desktop configurado"
}

# ============================================
# ETAPA 5: REINICIAR KDE
# ============================================
restart_kde() {
    header "ETAPA 5: REINICIANDO KDE"
    
    # Atualizar cache
    if command -v kbuildsycoca5 >/dev/null 2>&1; then
        log "Reconstruindo cache do KDE..."
        kbuildsycoca5 --noincremental 2>/dev/null || true
    fi
    
    # Reiniciar serviços
    log "Reiniciando serviços..."
    
    if command -v kstart5 >/dev/null 2>&1; then
        # Reiniciar plasmashell
        if ! pgrep -x "plasmashell" >/dev/null 2>&1; then
            kstart5 plasmashell 2>/dev/null || true
            success "Plasma Shell iniciado"
        fi
    fi
    
    # Iniciar krunner
    if command -v krunner >/dev/null 2>&1; then
        krunner & 2>/dev/null || true
        success "KRunner iniciado"
    fi
    
    success "KDE reiniciado"
}

# ============================================
# ETAPA 6: FINALIZAR
# ============================================
finish() {
    header "CONCLUÍDO!"
    
    echo -e "${GREEN}$APP_NAME foi completamente reinstalado!${NC}"
    echo ""
    echo -e "${BOLD}${CYAN}PRÓXIMOS PASSOS:${NC}"
    echo ""
    echo -e "${YELLOW}1. REMOVA ÍCONES ANTIGOS DA DOCK:${NC}"
    echo "   - Clique direito em qualquer ícone antigo do OpenChamber"
    echo "   - Selecione 'Remover' ou 'Unpin'"
    echo ""
    echo -e "${YELLOW}2. ABRA PELO MENU:${NC}"
    echo "   - Pressione Alt+F2 ou abra o menu de aplicativos"
    echo "   - Procure por '$APP_NAME'"
    echo "   - Clique para abrir"
    echo ""
    echo -e "${YELLOW}3. FIXE O ÍCONE CORRETO:${NC}"
    echo "   - Com o app aberto, clique direito no ícone na barra"
    echo "   - Selecione 'Fixar na área de trabalho' ou 'Add to Panel'"
    echo ""
    echo -e "${YELLOW}4. TESTE:${NC}"
    echo "   - Feche o app e clique no ícone fixado"
    echo "   - O app deve abrir corretamente!"
    echo ""
    echo -e "${CYAN}Comandos disponíveis:${NC}"
    echo "  Terminal: ${BOLD}openchamber-desktop${NC} ou ${BOLD}ocd${NC}"
    echo ""
    echo -e "${YELLOW}Nota:${NC} Se ainda houver problemas, faça logout/login."
    echo ""
}

# ============================================
# EXECUÇÃO PRINCIPAL
# ============================================
main() {
    echo ""
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${GREEN}OpenChamber Desktop - Correção Nuclear${NC}                ${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Verificar Linux
    if [[ "$OSTYPE" != "linux-gnu"* ]] && [[ "$OSTYPE" != "linux"* ]]; then
        error "Este script é apenas para Linux!"
        exit 1
    fi
    
    # Confirmação
    echo -e "${YELLOW}⚠️  ATENÇÃO:${NC} Este script vai:"
    echo "   • Parar todos os processos do OpenChamber"
    echo "   • Remover TODAS as instalações antigas"
    echo "   • Limpar configs e cache"
    echo "   • Reinstalar do zero"
    echo ""
    read -p "Continuar? (s/n): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Cancelado."
        exit 0
    fi
    
    # Executar etapas
    stop_everything
    nuclear_cleanup
    reinstall
    configure_desktop
    restart_kde
    finish
}

main "$@"
