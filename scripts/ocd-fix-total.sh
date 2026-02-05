#!/bin/bash
#
# OpenChamber Desktop - CORREÇÃO TOTAL
# Remove tudo e recria corretamente a entrada de desktop
# Este script resolve: ícone não aparece, fixar abre Neutralino ao invés do app
#

set -e

APP_NAME="openchamber-desktop"
DISPLAY_NAME="OpenChamber Desktop"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[OCD-FIX]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

info() {
    echo -e "${CYAN}[i]${NC} $1"
}

# ============================================
# ETAPA 1: REMOVER TUDO
# ============================================

log "============================================"
log "  ETAPA 1: REMOÇÃO TOTAL"
log "============================================"
echo ""

# 1.1 Remover todas as entradas .desktop
remove_all_desktop_entries() {
    log "Removendo todas as entradas de desktop..."
    
    local desktop_dirs=(
        "$HOME/.local/share/applications"
        "/usr/share/applications"
        "/usr/local/share/applications"
    )
    
    local patterns=(
        "*openchamber*.desktop"
        "*ocd*.desktop"
        "*neutralino*.desktop"
    )
    
    local removed_count=0
    
    for dir in "${desktop_dirs[@]}"; do
        if [ -d "$dir" ]; then
            for pattern in "${patterns[@]}"; do
                while IFS= read -r -d '' file; do
                    if [ -f "$file" ]; then
                        log "Removendo: $file"
                        rm -f "$file"
                        ((removed_count++))
                    fi
                done < <(find "$dir" -maxdepth 1 -type f -name "$pattern" -print0 2>/dev/null)
            done
        fi
    done
    
    if [ $removed_count -eq 0 ]; then
        info "Nenhuma entrada de desktop encontrada para remover"
    else
        success "Removidas $removed_count entradas de desktop"
    fi
}

# 1.2 Limpar cache KDE profundamente
clean_kde_deep() {
    log "Limpando cache do KDE profundamente..."
    
    # Parar serviços do KDE
    if pgrep -x "plasmashell" >/dev/null 2>&1; then
        log "Parando plasmashell temporariamente..."
        killall plasmashell 2>/dev/null || true
        sleep 2
    fi
    
    if pgrep -x "krunner" >/dev/null 2>&1; then
        log "Parando krunner..."
        killall krunner 2>/dev/null || true
    fi
    
    # Limpar caches
    local cache_dirs=(
        "$HOME/.cache/menus"
        "$HOME/.cache/icon-cache.kcache"
        "$HOME/.cache/ksycoca5"
        "$HOME/.cache/krunner"
        "$HOME/.cache/kactivitymanagerd"
        "$HOME/.cache/plasmashell"
        "$HOME/.cache/kded5"
    )
    
    for dir in "${cache_dirs[@]}"; do
        if [ -e "$dir" ]; then
            rm -rf "$dir" 2>/dev/null || true
            log "Removido: $dir"
        fi
    done
    
    # Limpar configurações de applets e painéis
    if [ -f "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" ]; then
        log "Backup das configurações do Plasma..."
        cp "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" \
           "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc.backup.$(date +%s)"
    fi
    
    # Remover favoritos que podem estar corrompidos
    if [ -f "$HOME/.config/kactivitymanagerd-statsrc" ]; then
        rm -f "$HOME/.config/kactivitymanagerd-statsrc"
        log "Removido cache de estatísticas de atividades"
    fi
    
    success "Cache do KDE limpo"
}

# 1.3 Atualizar banco de dados
database_update() {
    log "Atualizando bancos de dados..."
    
    # Desktop database
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
        success "Desktop database atualizado"
    fi
    
    # KDE cache rebuild
    if command -v kbuildsycoca5 >/dev/null 2>&1; then
        log "Reconstruindo cache do sistema KDE..."
        kbuildsycoca5 --noincremental 2>/dev/null || true
        success "Cache KDE reconstruído"
    fi
}

# ============================================
# ETAPA 2: ENCONTRAR EXECUTÁVEL CORRETO
# ============================================

find_correct_executable() {
    log "============================================"
    log "  ETAPA 2: LOCALIZANDO EXECUTÁVEL CORRETO"
    log "============================================"
    echo ""
    
    # Procurar por todos os possíveis executáveis
    local possible_paths=(
        # Wrappers/scripts (CORRETOS - devem apontar para esses)
        "$HOME/.local/bin/openchamber-desktop"
        "$HOME/.local/lib/openchamber-desktop/bin/openchamber-launcher"
        "/usr/local/bin/openchamber-desktop"
        "/opt/openchamber-desktop/bin/openchamber-launcher"
        "/usr/bin/openchamber-desktop"
        # Comandos
        "openchamber-desktop"
        "ocd"
        # Caminhos bun
        "$HOME/.bun/bin/openchamber-desktop"
    )
    
    local correct_exec=""
    
    for path in "${possible_paths[@]}"; do
        info "Verificando: $path"
        
        if [ -f "$path" ]; then
            # É um arquivo, verificar se é script Node (wrapper correto)
            if head -n 1 "$path" 2>/dev/null | grep -q "node\|bash\|sh"; then
                # Verificar conteúdo
                if grep -q "cli.js\|node" "$path" 2>/dev/null; then
                    success "Wrapper Node encontrado: $path"
                    correct_exec="$path"
                    break
                fi
            fi
        elif command -v "$path" >/dev/null 2>&1; then
            # É um comando no PATH
            local cmd_path=$(command -v "$path")
            if head -n 1 "$cmd_path" 2>/dev/null | grep -q "node\|bash\|sh"; then
                success "Wrapper Node encontrado no PATH: $cmd_path"
                correct_exec="$cmd_path"
                break
            fi
        fi
    done
    
    # Se não encontrou, tentar encontrar diretório de instalação
    if [ -z "$correct_exec" ]; then
        warn "Wrapper não encontrado nos locais padrão"
        log "Procurando instalação local..."
        
        local install_dirs=(
            "$HOME/.local/lib/openchamber-desktop"
            "/opt/openchamber-desktop"
            "$HOME/.local/share/openchamber-desktop"
        )
        
        for dir in "${install_dirs[@]}"; do
            if [ -f "$dir/bin/cli.js" ]; then
                success "Instalação encontrada em: $dir"
                
                # Criar wrapper temporário/corrigido
                correct_exec="$HOME/.local/bin/openchamber-desktop"
                mkdir -p "$HOME/.local/bin"
                
                cat > "$correct_exec" <<EOF
#!/bin/bash
# OpenChamber Desktop Launcher (Corrigido)
exec node "$dir/bin/cli.js" "\$@"
EOF
                chmod +x "$correct_exec"
                success "Wrapper criado em: $correct_exec"
                break
            fi
        done
    fi
    
    if [ -z "$correct_exec" ]; then
        error "NÃO FOI POSSÍVEL ENCONTRAR OU CRIAR O EXECUTÁVEL CORRETO!"
        error "O OpenChamber Desktop pode não estar instalado."
        error ""
        error "Instale primeiro com:"
        error "  curl -fsSL https://get.openchamber.io | bash"
        exit 1
    fi
    
    # Testar se o executável funciona
    log "Testando executável: $correct_exec"
    if $correct_exec --version >/dev/null 2>&1 || timeout 2 $correct_exec --help >/dev/null 2>&1; then
        success "Executável funciona corretamente!"
    else
        warn "Não foi possível testar o executável, mas vamos continuar..."
    fi
    
    CORRECT_EXEC="$correct_exec"
}

# ============================================
# ETAPA 3: CRIAR ENTRADA CORRETA
# ============================================

create_correct_entry() {
    log "============================================"
    log "  ETAPA 3: CRIANDO ENTRADA CORRETA"
    log "============================================"
    echo ""
    
    local desktop_dir="$HOME/.local/share/applications"
    local desktop_file="$desktop_dir/openchamber-desktop.desktop"
    local icon_dir="$HOME/.local/share/icons/hicolor/256x256/apps"
    local icon_file="$icon_dir/openchamber-desktop.png"
    
    mkdir -p "$desktop_dir"
    mkdir -p "$icon_dir"
    
    # Baixar ou encontrar ícone
    if [ ! -f "$icon_file" ]; then
        log "Baixando ícone..."
        curl -fsSL "https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/assets/openchamber-logo-dark.png" -o "$icon_file" 2>/dev/null || {
            warn "Não foi possível baixar o ícone"
            icon_file="utilities-terminal"
        }
    fi
    
    if [ -f "$icon_file" ]; then
        success "Ícone pronto: $icon_file"
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
    
    log "Criando arquivo .desktop..."
    log "  Exec: $CORRECT_EXEC"
    log "  WM_CLASS: $wm_class"
    
    cat > "$desktop_file" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$DISPLAY_NAME
Comment=OpenChamber Desktop - AI Coding Assistant
Exec=$CORRECT_EXEC
Icon=openchamber-desktop
Terminal=false
Categories=Development;IDE;Utility;
Keywords=openchamber;opencode;ai;coding;ocd;
StartupNotify=true
StartupWMClass=$wm_class
X-GNOME-SingleWindow=true
X-KDE-StartupNotify=true
X-KDE-SubstituteUID=false
TryExec=$CORRECT_EXEC
MimeType=x-scheme-handler/openchamber;
X-Desktop-File-Install-Version=0.26
EOF
    
    chmod +x "$desktop_file"
    success "Entrada de desktop criada: $desktop_file"
    
    # Mostrar conteúdo
    echo ""
    info "Conteúdo do arquivo:"
    cat "$desktop_file"
    echo ""
}

# ============================================
# ETAPA 4: FINALIZAR
# ============================================

finalize() {
    log "============================================"
    log "  ETAPA 4: FINALIZANDO"
    log "============================================"
    echo ""
    
    # Atualizar tudo novamente
    database_update
    
    # Reiniciar serviços KDE
    log "Reiniciando serviços do KDE..."
    
    if command -v kstart5 >/dev/null 2>&1; then
        kstart5 plasmashell 2>/dev/null || true
        success "Plasma Shell reiniciado"
    fi
    
    if command -v krunner >/dev/null 2>&1; then
        krunner & 2>/dev/null || true
        success "KRunner reiniciado"
    fi
    
    echo ""
    success "============================================"
    success "  CORREÇÃO CONCLUÍDA!"
    success "============================================"
    echo ""
    echo -e "${CYAN}INSTRUÇÕES IMPORTANTES:${NC}"
    echo ""
    echo "1. ${YELLOW}REMOVA QUALQUER ÍCONE ANTIGO${NC} da dock/barra de tarefas:"
    echo "   - Clique direito no ícone existente → 'Remover' ou 'Unpin'"
    echo ""
    echo "2. ${YELLOW}ABRA PELO MENU${NC}:"
    echo "   - Pressione Alt+F2 ou abra o menu de aplicativos"
    echo "   - Procure por 'OpenChamber Desktop'"
    echo "   - Clique para abrir"
    echo ""
    echo "3. ${YELLOW}FIXE O ÍCONE NOVO${NC}:"
    echo "   - Com o app aberto, clique direito no ícone na barra de tarefas"
    echo "   - Escolha 'Fixar na área de trabalho' ou 'Add to Panel'"
    echo ""
    echo "4. ${YELLOW}TESTE${NC}:"
    echo "   - Feche o app"
    echo "   - Clique no ícone fixado na dock"
    echo "   - O app deve abrir corretamente!"
    echo ""
    echo -e "${YELLOW}Se ainda houver problemas, faça logout e login novamente.${NC}"
    echo ""
}

# ============================================
# EXECUÇÃO PRINCIPAL
# ============================================

main() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}OpenChamber Desktop - Correção Total${NC}          ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Verificar se é Linux
    if [[ "$OSTYPE" != "linux-gnu"* ]] && [[ "$OSTYPE" != "linux"* ]]; then
        error "Este script é apenas para Linux!"
        exit 1
    fi
    
    # Executar etapas
    remove_all_desktop_entries
    echo ""
    clean_kde_deep
    echo ""
    database_update
    echo ""
    find_correct_executable
    echo ""
    create_correct_entry
    echo ""
    finalize
}

main "$@"
