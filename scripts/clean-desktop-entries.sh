#!/bin/bash
#
# OpenChamber Desktop - Script de Limpeza de Desktop Entries
# Corrige entradas duplicadas no KDE/Linux
#

set -e

APP_NAME="OpenChamber Desktop"
PKG_NAME="openchamber-desktop"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${CYAN}[OCD-CLEAN]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detectar e limpar entradas de desktop duplicadas
clean_desktop_entries() {
    log "Procurando entradas de desktop do OpenChamber..."
    
    local desktop_dirs=(
        "$HOME/.local/share/applications"
        "/usr/share/applications"
        "/usr/local/share/applications"
    )
    
    local found_entries=()
    
    for dir in "${desktop_dirs[@]}"; do
        if [ -d "$dir" ]; then
            # Buscar arquivos relacionados ao openchamber
            while IFS= read -r file; do
                if [ -f "$file" ]; then
                    # Verificar se é relacionado ao openchamber
                    if grep -q -i "openchamber\|ocd" "$file" 2>/dev/null; then
                        found_entries+=("$file")
                    fi
                fi
            done < <(find "$dir" -maxdepth 1 -type f \( -name "*openchamber*.desktop" -o -name "*ocd*.desktop" \) 2>/dev/null)
        fi
    done
    
    if [ ${#found_entries[@]} -eq 0 ]; then
        log "Nenhuma entrada de desktop encontrada."
    else
        log "Encontradas ${#found_entries[@]} entrada(s) de desktop:"
        for entry in "${found_entries[@]}"; do
            echo "  - $entry"
            
            # Mostrar detalhes do Exec
            local exec_line=$(grep "^Exec=" "$entry" 2>/dev/null | head -1)
            if [ -n "$exec_line" ]; then
                echo "    Exec: ${exec_line#Exec=}"
            fi
        done
        
        echo ""
        log "Removendo entradas antigas..."
        for entry in "${found_entries[@]}"; do
            rm -f "$entry"
            success "Removido: $entry"
        done
    fi
}

# Limpar cache do KDE
 clean_kde_cache() {
    log "Limpando cache do KDE..."
    
    # Limpar cache de menus
    if [ -d "$HOME/.cache/menus" ]; then
        rm -rf "$HOME/.cache/menus"/* 2>/dev/null || true
        success "Cache de menus limpo"
    fi
    
    # Limpar cache de ícones
    if [ -d "$HOME/.cache/icon-cache.kcache" ]; then
        rm -f "$HOME/.cache/icon-cache.kcache" 2>/dev/null || true
    fi
    
    # Limpar configurações de desktop do KDE
    if [ -d "$HOME/.config/kicker" ]; then
        rm -rf "$HOME/.config/kicker"/* 2>/dev/null || true
    fi
    
    if [ -d "$HOME/.config/kickoff" ]; then
        rm -rf "$HOME/.config/kickoff"/* 2>/dev/null || true
    fi
    
    # Limpar favoritos/plasmoids que podem referenciar entradas antigas
    local plasma_desktop_dir="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    if [ -f "$plasma_desktop_dir" ]; then
        warn "Verificando configurações do Plasma para referências antigas..."
        # Backup
        cp "$plasma_desktop_dir" "$plasma_desktop_dir.backup.$(date +%s)" 2>/dev/null || true
    fi
    
    success "Cache do KDE limpo"
}

# Atualizar banco de dados de desktop
update_desktop_database() {
    log "Atualizando banco de dados de aplicativos..."
    
    # Atualizar desktop database
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
        update-desktop-database "/usr/share/applications" 2>/dev/null || true
        success "Banco de dados de desktop atualizado"
    fi
    
    # Atualizar cache de ícones
    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons" 2>/dev/null || true
        gtk-update-icon-cache -f -t "/usr/share/icons/hicolor" 2>/dev/null || true
    fi
    
    # Atualizar mimeapps
    if command -v update-mime-database >/dev/null 2>&1; then
        update-mime-database "$HOME/.local/share/mime" 2>/dev/null || true
    fi
}

# Verificar qual executável funciona
find_working_executable() {
    log "Verificando executável válido..."
    
    # Possíveis executáveis
    local candidates=(
        "openchamber-desktop"
        "ocd"
        "$HOME/.bun/bin/openchamber-desktop"
        "/usr/bin/openchamber-desktop"
        "/usr/local/bin/openchamber-desktop"
    )
    
    for candidate in "${candidates[@]}"; do
        if command -v "$candidate" >/dev/null 2>&1; then
            # Testar se realmente funciona
            if $candidate --version >/dev/null 2>&1; then
                success "Executável válido encontrado: $candidate"
                WORKING_EXEC="$candidate"
                return 0
            fi
        fi
        
        # Verificar caminho absoluto
        if [ -x "$candidate" ]; then
            success "Executável válido encontrado: $candidate"
            WORKING_EXEC="$candidate"
            return 0
        fi
    done
    
    error "Nenhum executável válido do OpenChamber Desktop encontrado!"
    error "Instale o OCD primeiro com: curl -fsSL ... | bash"
    return 1
}

# Criar nova entrada de desktop única e correta
create_correct_desktop_entry() {
    log "Criando nova entrada de desktop única..."
    
    local desktop_dir="$HOME/.local/share/applications"
    mkdir -p "$desktop_dir"
    
    local desktop_file="$desktop_dir/openchamber-desktop.desktop"
    local icon_dir="$HOME/.config/openchamber"
    local icon_path="$icon_dir/icon.png"
    
    # Baixar ícone se não existir
    if [ ! -f "$icon_path" ]; then
        mkdir -p "$icon_dir"
        curl -fsSL "https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/assets/openchamber-logo-dark.png" -o "$icon_path" 2>/dev/null || {
            warn "Não foi possível baixar o ícone, usando ícone padrão"
            icon_path="utilities-terminal"
        }
    fi
    
    # Criar arquivo .desktop único
    cat > "$desktop_file" <<EOF
[Desktop Entry]
Name=$APP_NAME
Comment=OpenChamber Desktop - AI Coding Assistant
Exec=$WORKING_EXEC
Icon=$icon_path
Terminal=false
Type=Application
Categories=Development;IDE;Utility;System;
Keywords=openchamber;opencode;ai;coding;ocd;
StartupNotify=true
X-GNOME-SingleWindow=true
X-KDE-StartupNotify=true
X-Desktop-File-Install-Version=0.26
EOF
    
    chmod +x "$desktop_file"
    success "Nova entrada de desktop criada: $desktop_file"
    log "Exec: $WORKING_EXEC"
}

# Reiniciar serviços do KDE
restart_kde_services() {
    log "Reiniciando serviços do KDE..."
    
    # Verificar se estamos em uma sessão KDE
    if [ "$XDG_CURRENT_DESKTOP" = "KDE" ] || [ "$XDG_SESSION_DESKTOP" = "KDE" ]; then
        # Reiniciar krunner
        if pgrep -x "krunner" >/dev/null 2>&1; then
            killall krunner 2>/dev/null || true
            success "KRunner reiniciado"
        fi
        
        # Reiniciar plasmashell
        if pgrep -x "plasmashell" >/dev/null 2>&1; then
            killall plasmashell 2>/dev/null && sleep 2 && kstart5 plasmashell &
            success "Plasma Shell reiniciado"
        fi
        
        # Atualizar atalhos
        if command -v kbuildsycoca5 >/dev/null 2>&1; then
            kbuildsycoca5 --noincremental 2>/dev/null || true
            success "Cache do sistema KDE atualizado (kbuildsycoca5)"
        fi
    else
        log "Sessão KDE não detectada, pulando reinicialização de serviços"
    fi
}

# Mostrar resumo
show_summary() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Limpeza Concluída!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Ações realizadas:"
    echo "  ✓ Removidas entradas de desktop duplicadas"
    echo "  ✓ Limpo cache do KDE"
    echo "  ✓ Atualizado banco de dados de aplicativos"
    echo "  ✓ Criada nova entrada de desktop única"
    echo "  ✓ Reiniciados serviços do KDE (se aplicável)"
    echo ""
    echo "Você deve encontrar apenas uma entrada '$APP_NAME' no menu agora."
    echo ""
    echo "Se o problema persistir:"
    echo "  1. Faça logout e login novamente"
    echo "  2. Ou reinicie o sistema"
    echo ""
    echo "Para executar o OpenChamber Desktop:"
    echo "  Terminal: ${CYAN}openchamber-desktop${NC} ou ${CYAN}ocd${NC}"
    echo "  Menu: Procure por '$APP_NAME'"
    echo ""
}

# Execução principal
main() {
    echo ""
    echo -e "${CYAN}OpenChamber Desktop - Limpeza de Desktop Entries${NC}"
    echo -e "${CYAN}=================================================${NC}"
    echo ""
    
    log "Iniciando limpeza..."
    
    # 1. Limpar entradas existentes
    clean_desktop_entries
    
    # 2. Limpar cache KDE
    clean_kde_cache
    
    # 3. Atualizar banco de dados
    update_desktop_database
    
    # 4. Encontrar executável válido
    if ! find_working_executable; then
        error "Não foi possível encontrar um executável válido."
        error "A limpeza foi realizada, mas não foi possível recriar a entrada."
        exit 1
    fi
    
    # 5. Criar nova entrada correta
    create_correct_desktop_entry
    
    # 6. Atualizar novamente
    update_desktop_database
    
    # 7. Reiniciar serviços KDE
    restart_kde_services
    
    # 8. Mostrar resumo
    show_summary
}

# Verificar se está sendo executado no Linux
if [[ "$OSTYPE" != "linux-gnu"* ]] && [[ "$OSTYPE" != "linux"* ]]; then
    error "Este script é apenas para Linux!"
    exit 1
fi

main "$@"
