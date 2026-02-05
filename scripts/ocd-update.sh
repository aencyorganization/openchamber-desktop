#!/bin/bash
#
# OpenChamber Desktop - Atualização de Configuração
# Limpa configs antigas e migra para nova versão
#

set -e

APP_NAME="OpenChamber Desktop"
PKG_NAME="openchamber-desktop"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[OCD-UPDATE]${NC} $1"
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
# LIMPAR CONFIGS ANTIGAS
# ============================================
cleanup_old_configs() {
    header "LIMPANDO CONFIGURAÇÕES ANTIGAS"
    
    # Parar processos
    log "Parando processos..."
    pkill -f "openchamber" 2>/dev/null || true
    pkill -f "neutralino" 2>/dev/null || true
    sleep 1
    
    # Limpar localStorage do Neutralino (arquivos de config)
    log "Limpando configurações salvas..."
    
    # Configs do Neutralino/LocalStorage
    rm -rf "$HOME/.config/openchamber" 2>/dev/null || true
    rm -rf "$HOME/.local/share/openchamber-desktop" 2>/dev/null || true
    
    # Limpar localStorage específico (se houver)
    if [ -d "$HOME/.config/Neutralinojs" ]; then
        rm -rf "$HOME/.config/Neutralinojs"/*openchamber* 2>/dev/null || true
    fi
    
    success "Configurações antigas limpas"
}

# ============================================
# REINSTALAR PACOTE
# ============================================
reinstall_package() {
    header "REINSTALANDO PACOTE"
    
    log "Verificando instalação atual..."
    
    # Detectar package manager
    if command -v bun >/dev/null 2>&1; then
        PM="bun"
    elif command -v pnpm >/dev/null 2>&1; then
        PM="pnpm"
    elif command -v yarn >/dev/null 2>&1; then
        PM="yarn"
    elif command -v npm >/dev/null 2>&1; then
        PM="npm"
    else
        error "Nenhum package manager encontrado!"
        exit 1
    fi
    
    success "Package manager: $PM"
    
    # Reinstalar
    log "Reinstalando $PKG_NAME..."
    case "$PM" in
        bun)
            bun remove -g "$PKG_NAME" 2>/dev/null || true
            bun install -g "$PKG_NAME"
            ;;
        pnpm)
            pnpm remove -g "$PKG_NAME" 2>/dev/null || true
            pnpm add -g "$PKG_NAME"
            ;;
        yarn)
            yarn global remove "$PKG_NAME" 2>/dev/null || true
            yarn global add "$PKG_NAME"
            ;;
        npm)
            npm uninstall -g "$PKG_NAME" 2>/dev/null || true
            npm install -g "$PKG_NAME"
            ;;
    esac
    
    success "Pacote reinstalado"
}

# ============================================
# RECRIAR DESKTOP ENTRY
# ============================================
recreate_desktop_entry() {
    header "RECREANDO DESKTOP ENTRY"
    
    local desktop_dir="$HOME/.local/share/applications"
    local desktop_file="$desktop_dir/openchamber-desktop.desktop"
    local icon_dir="$HOME/.local/share/icons/hicolor/256x256/apps"
    
    # Remover entry antiga
    rm -f "$desktop_file" 2>/dev/null || true
    rm -f "$desktop_dir/ocd.desktop" 2>/dev/null || true
    
    mkdir -p "$desktop_dir"
    mkdir -p "$icon_dir"
    
    # Baixar ícone
    log "Baixando ícone..."
    curl -fsSL "https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/assets/openchamber-logo-dark.png" -o "$icon_dir/openchamber-desktop.png" 2>/dev/null || true
    
    # Detectar arquitetura
    local arch=$(uname -m)
    local wm_class
    case "$arch" in
        x86_64) wm_class="neutralino-linux_x64" ;;
        aarch64|arm64) wm_class="neutralino-linux_arm64" ;;
        armv7l|armhf) wm_class="neutralino-linux_armhf" ;;
        *) wm_class="neutralino-linux_x64" ;;
    esac
    
    # Criar entry
    log "Criando nova desktop entry..."
    cat > "$desktop_file" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=OpenChamber Desktop - AI Coding Assistant
Exec=$PKG_NAME
Icon=openchamber-desktop
Terminal=false
Categories=Development;IDE;Utility;
Keywords=openchamber;opencode;ai;coding;ocd;
StartupNotify=true
StartupWMClass=$wm_class
X-GNOME-SingleWindow=true
X-KDE-StartupNotify=true
TryExec=$PKG_NAME
X-Desktop-File-Install-Version=0.26
EOF
    
    chmod +x "$desktop_file"
    
    # Atualizar database
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$desktop_dir" 2>/dev/null || true
    fi
    
    success "Desktop entry recriada"
}

# ============================================
# LIMPAR CACHE
# ============================================
clear_cache() {
    header "LIMPANDO CACHE"
    
    # Cache KDE
    rm -rf "$HOME/.cache/menus"/* 2>/dev/null || true
    rm -f "$HOME/.cache/icon-cache.kcache" 2>/dev/null || true
    rm -rf "$HOME/.cache/ksycoca5"* 2>/dev/null || true
    
    # Rebuild KDE
    if command -v kbuildsycoca5 >/dev/null 2>&1; then
        log "Reconstruindo cache KDE..."
        kbuildsycoca5 --noincremental 2>/dev/null || true
    fi
    
    success "Cache limpo"
}

# ============================================
# FINALIZAR
# ============================================
finish() {
    header "ATUALIZAÇÃO CONCLUÍDA!"
    
    echo -e "${GREEN}$APP_NAME foi atualizado com sucesso!${NC}"
    echo ""
    echo -e "${BOLD}${CYAN}O QUE FOI FEITO:${NC}"
    echo "  ✓ Configurações antigas removidas"
    echo "  ✓ Pacote reinstalado com correções"
    echo "  ✓ Desktop entry recriada"
    echo "  ✓ Cache limpo"
    echo ""
    echo -e "${BOLD}${CYAN}PRÓXIMOS PASSOS:${NC}"
    echo ""
    echo -e "${YELLOW}1. REMOVA ÍCONES ANTIGOS DA DOCK:${NC}"
    echo "   Clique direito no ícone → 'Remover'"
    echo ""
    echo -e "${YELLOW}2. ABRA PELO MENU:${NC}"
    echo "   Alt+F2 → digite 'OpenChamber'"
    echo ""
    echo -e "${YELLOW}3. FIXE O NOVO ÍCONE:${NC}"
    echo "   Clique direito na barra → 'Fixar'"
    echo ""
    echo -e "${CYAN}O problema da tela branca foi corrigido!${NC}"
    echo ""
}

# ============================================
# EXECUÇÃO
# ============================================
main() {
    echo ""
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${GREEN}OpenChamber Desktop - Atualização de Config${NC}          ${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "$OSTYPE" != "linux-gnu"* ]] && [[ "$OSTYPE" != "linux"* ]]; then
        error "Este script é apenas para Linux!"
        exit 1
    fi
    
    read -p "Deseja atualizar? (s/n): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Cancelado."
        exit 0
    fi
    
    cleanup_old_configs
    reinstall_package
    recreate_desktop_entry
    clear_cache
    finish
}

main "$@"
