#!/bin/bash
#
# OpenChamber Desktop - Script de Diagnóstico
# Identifica problemas comuns de instalação e execução
#

set -e

APP_NAME="OpenChamber Desktop"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[DIAG]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  OpenChamber Desktop - Diagnóstico de Instalação          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# ============================================
# 1. Sistema Operacional
# ============================================
log "1. Sistema Operacional"
echo "   OS: $(uname -s)"
echo "   Arch: $(uname -m)"
echo "   Kernel: $(uname -r)"
echo ""

# ============================================
# 2. Verificar comandos
# ============================================
log "2. Verificando comandos OpenChamber"
echo ""

check_command() {
    local cmd="$1"
    local full_path
    
    if command -v "$cmd" >/dev/null 2>&1; then
        full_path=$(command -v "$cmd")
        success "✓ $cmd encontrado: $full_path"
        
        # Verificar se é um script
        if head -n 1 "$full_path" 2>/dev/null | grep -q "node\|bash\|sh"; then
            info "  → É um script wrapper"
        else
            warn "  → Pode ser um binário direto"
        fi
        
        # Tentar executar --version
        if timeout 2 "$cmd" --version 2>/dev/null | head -1; then
            success "  → Executável funciona"
        else
            error "  → Não responde a --version"
        fi
        
        return 0
    else
        error "✗ $cmd não encontrado no PATH"
        return 1
    fi
}

FOUND_OC=0
FOUND_OCD=0

check_command "openchamber" && FOUND_OC=1
check_command "openchamber-desktop" && FOUND_OCD=1

echo ""

# ============================================
# 3. Verificar PATH
# ============================================
log "3. Verificando PATH"
echo "   PATH=$PATH"
echo ""

# Verificar diretórios comuns
common_dirs=(
    "$HOME/.bun/bin"
    "$HOME/.local/bin"
    "/usr/local/bin"
    "/usr/bin"
)

for dir in "${common_dirs[@]}"; do
    if [[ ":$PATH:" == *":$dir:"* ]]; then
        success "✓ $dir está no PATH"
    else
        warn "✗ $dir NÃO está no PATH"
    fi
done
echo ""

# ============================================
# 4. Verificar instalações
# ============================================
log "4. Verificando instalações locais"
echo ""

install_dirs=(
    "$HOME/.local/lib/openchamber-desktop"
    "/opt/openchamber-desktop"
    "$HOME/.local/share/openchamber-desktop"
    "$HOME/.bun/install/global/node_modules/openchamber-desktop"
)

for dir in "${install_dirs[@]}"; do
    if [ -d "$dir" ]; then
        success "✓ Diretório encontrado: $dir"
        
        if [ -f "$dir/bin/cli.js" ]; then
            success "  → cli.js presente"
        else
            warn "  → cli.js NÃO encontrado"
        fi
        
        if [ -f "$dir/neutralino.config.json" ]; then
            success "  → neutralino.config.json presente"
        fi
    fi
done
echo ""

# ============================================
# 5. Verificar Neutralino binário
# ============================================
log "5. Verificando binários Neutralino"
echo ""

arch=$(uname -m)
case "$arch" in
    x86_64) binary_name="neutralino-linux_x64" ;;
    aarch64|arm64) binary_name="neutralino-linux_arm64" ;;
    armv7l|armhf) binary_name="neutralino-linux_armhf" ;;
    *) binary_name="neutralino-linux_x64" ;;
esac

for dir in "${install_dirs[@]}"; do
    if [ -f "$dir/bin/$binary_name" ]; then
        success "✓ Binário Neutralino encontrado: $dir/bin/$binary_name"
        ls -la "$dir/bin/$binary_name"
    fi
done
echo ""

# ============================================
# 6. Verificar desktop entries
# ============================================
log "6. Verificando entradas de desktop"
echo ""

desktop_dirs=(
    "$HOME/.local/share/applications"
    "/usr/share/applications"
)

for dir in "${desktop_dirs[@]}"; do
    if [ -d "$dir" ]; then
        entries=$(find "$dir" -maxdepth 1 -name "*openchamber*.desktop" -o -name "*ocd*.desktop" 2>/dev/null)
        if [ -n "$entries" ]; then
            echo "   Entradas em $dir:"
            echo "$entries" | while read -r entry; do
                if [ -f "$entry" ]; then
                    echo "     - $entry"
                    exec_line=$(grep "^Exec=" "$entry" 2>/dev/null | head -1)
                    if [ -n "$exec_line" ]; then
                        echo "       Exec: ${exec_line#Exec=}"
                    fi
                fi
            done
        fi
    fi
done
echo ""

# ============================================
# 7. Testar execução
# ============================================
log "7. Testando execução"
echo ""

if [ $FOUND_OCD -eq 1 ] || [ $FOUND_OC -eq 1 ]; then
    CMD_TO_TEST=$([ $FOUND_OCD -eq 1 ] && echo "openchamber-desktop" || echo "openchamber")
    
    info "Testando: $CMD_TO_TEST --version"
    if timeout 3 $CMD_TO_TEST --version 2>&1; then
        success "✓ Comando funciona!"
    else
        error "✗ Comando falhou ou demorou demais"
    fi
else
    error "✗ Nenhum comando OpenChamber encontrado para testar"
fi
echo ""

# ============================================
# 8. Verificar dependências
# ============================================
log "8. Verificando dependências"
echo ""

check_dep() {
    local cmd="$1"
    local name="$2"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        success "✓ $name instalado"
        return 0
    else
        error "✗ $name NÃO encontrado"
        return 1
    fi
}

check_dep "node" "Node.js"
check_dep "npm" "npm"

# Verificar se bun está instalado (opcional mas recomendado)
if command -v "bun" >/dev/null 2>&1; then
    success "✓ Bun instalado: $(bun --version)"
else
    warn "✗ Bun não encontrado (instalação via npm será usada)"
fi

echo ""

# ============================================
# 9. Verificar portas
# ============================================
log "9. Verificando portas em uso"
echo ""

for port in 1504 1505 1506; do
    if ss -tln 2>/dev/null | grep -q ":$port " || netstat -tln 2>/dev/null | grep -q ":$port "; then
        warn "⚠ Porta $port está em uso"
        lsof -i:$port 2>/dev/null || true
    else
        success "✓ Porta $port livre"
    fi
done
echo ""

# ============================================
# RESUMO
# ============================================
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  RESUMO                                                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

if [ $FOUND_OCD -eq 0 ] && [ $FOUND_OC -eq 0 ]; then
    error "❌ OpenChamber NÃO está instalado ou não está no PATH"
    echo ""
    info "Para instalar, execute:"
    echo "  curl -fsSL https://get.openchamber.io | bash"
    echo ""
    exit 1
else
    success "✓ OpenChamber está instalado"
    
    if [ $FOUND_OCD -eq 0 ]; then
        warn "⚠ 'openchamber-desktop' não encontrado, mas 'openchamber' sim"
        warn "  Isso pode causar problemas com o launcher"
    fi
    
    echo ""
    info "Diagnóstico concluído!"
    echo ""
    info "Se o launcher ainda não funcionar:"
    echo "  1. Verifique se o comando funciona no terminal:"
    echo "     openchamber-desktop --version"
    echo ""
    echo "  2. Se funcionar no terminal mas não no launcher,"
    echo "     o problema pode ser o PATH no Neutralino."
    echo ""
    echo "  3. Tente reiniciar o launcher ou fazer logout/login"
    echo ""
fi
