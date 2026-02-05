#!/bin/bash

# ==============================================================================
# OpenChamber Desktop - Diagnóstico e Correção do Ícone no KDE
# ==============================================================================
# Este script verifica qual WM_CLASS o Neutralino está usando e corrige o
# arquivo .desktop para que o KDE reconheça corretamente o ícone na dock.
# ==============================================================================

set -euo pipefail

APP_NAME="openchamber-desktop"
DISPLAY_NAME="OpenChamber Desktop"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

error() {
    echo -e "${RED}[ERRO]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

# Detectar caminhos
if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    INSTALL_ROOT="/opt"
    DESKTOP_ROOT="/usr/share/applications"
    ICON_ROOT="/usr/share/icons"
else
    INSTALL_ROOT="$HOME/.local/lib"
    DESKTOP_ROOT="$HOME/.local/share/applications"
    ICON_ROOT="$HOME/.local/share/icons"
fi

INSTALL_DIR="$INSTALL_ROOT/$APP_NAME"
DESKTOP_FILE="$DESKTOP_ROOT/$APP_NAME.desktop"
BIN_PATH="${INSTALL_ROOT%/lib}/bin/$APP_NAME"

echo "=========================================="
echo "  Diagnóstico OpenChamber Desktop"
echo "=========================================="
echo ""

# Verificar se o app está instalado
if [ ! -d "$INSTALL_DIR" ]; then
    error "OpenChamber Desktop não está instalado em: $INSTALL_DIR"
    echo ""
    echo "Execute primeiro: ./scripts/install/linux-install.sh"
    exit 1
fi

success "Instalação encontrada em: $INSTALL_DIR"

# Verificar arquivos necessários
if [ ! -f "$INSTALL_DIR/bin/cli.js" ]; then
    error "Arquivo cli.js não encontrado!"
    exit 1
fi

# Verificar binário Neutralino
NEUTRALINO_BIN=""
for bin in neutralino-linux_x64 neutralino-linux_arm64 neutralino-linux_armhf; do
    if [ -f "$INSTALL_DIR/bin/$bin" ]; then
        NEUTRALINO_BIN="$bin"
        success "Binário Neutralino encontrado: $bin"
        break
    fi
done

if [ -z "$NEUTRALINO_BIN" ]; then
    error "Binário Neutralino não encontrado!"
    exit 1
fi

# Detectar WM_CLASS
info "Detectando WM_CLASS do binário..."

# Criar um script temporário para capturar WM_CLASS
TEMP_SCRIPT=$(mktemp)
cat << 'SCRIPT_EOF' > "$TEMP_SCRIPT"
#!/bin/bash
# Esperar a janela aparecer e capturar WM_CLASS
sleep 3
WINDOW_ID=$(xdotool search --class "neutralino" 2>/dev/null | head -n 1)
if [ -n "$WINDOW_ID" ]; then
    xprop -id "$WINDOW_ID" WM_CLASS 2>/dev/null
fi
SCRIPT_EOF
chmod +x "$TEMP_SCRIPT"

# Iniciar o app em background e capturar WM_CLASS
info "Iniciando OpenChamber Desktop por 5 segundos para diagnóstico..."
node "$INSTALL_DIR/bin/cli.js" &
APP_PID=$!

# Esperar e capturar
sleep 2
WM_CLASS_OUTPUT=""
if command -v xprop &> /dev/null && command -v xdotool &> /dev/null; then
    WINDOW_ID=$(xdotool search --class "neutralino" 2>/dev/null | head -n 1 || echo "")
    if [ -n "$WINDOW_ID" ]; then
        WM_CLASS_OUTPUT=$(xprop -id "$WINDOW_ID" WM_CLASS 2>/dev/null || echo "")
    fi
    
    # Tentar outras buscas
    if [ -z "$WM_CLASS_OUTPUT" ]; then
        WINDOW_ID=$(xdotool search --name "OpenChamber" 2>/dev/null | head -n 1 || echo "")
        if [ -n "$WINDOW_ID" ]; then
            WM_CLASS_OUTPUT=$(xprop -id "$WINDOW_ID" WM_CLASS 2>/dev/null || echo "")
        fi
    fi
fi

# Matar o app após diagnóstico
sleep 3
kill $APP_PID 2>/dev/null || true
wait $APP_PID 2>/dev/null || true

# Extrair WM_CLASS
DETECTED_WM_CLASS=""
if [ -n "$WM_CLASS_OUTPUT" ]; then
    DETECTED_WM_CLASS=$(echo "$WM_CLASS_OUTPUT" | grep -o '"[^"]*"' | tail -n 1 | tr -d '"')
    success "WM_CLASS detectada: $DETECTED_WM_CLASS"
else
    warn "Não foi possível detectar WM_CLASS automaticamente"
    DETECTED_WM_CLASS="$NEUTRALINO_BIN"
    info "Usando valor padrão: $DETECTED_WM_CLASS"
fi

# Verificar .desktop atual
echo ""
echo "------------------------------------------"
echo "  Verificando .desktop atual"
echo "------------------------------------------"

if [ -f "$DESKTOP_FILE" ]; then
    success "Arquivo .desktop encontrado: $DESKTOP_FILE"
    echo ""
    echo "Conteúdo atual:"
    echo "---"
    cat "$DESKTOP_FILE"
    echo "---"
    
    CURRENT_WM_CLASS=$(grep "^StartupWMClass=" "$DESKTOP_FILE" | cut -d= -f2 || echo "")
    echo ""
    info "StartupWMClass atual: $CURRENT_WM_CLASS"
    info "WM_CLASS detectada: $DETECTED_WM_CLASS"
    
    if [ "$CURRENT_WM_CLASS" != "$DETECTED_WM_CLASS" ]; then
        warn "StartupWMClass não corresponde à WM_CLASS real!"
        echo "Isso explica o problema do ícone na dock do KDE."
    else
        success "StartupWMClass está correto."
    fi
else
    warn "Arquivo .desktop não encontrado em: $DESKTOP_FILE"
fi

# Verificar ícone
echo ""
echo "------------------------------------------"
echo "  Verificando ícone"
echo "------------------------------------------"

ICON_FILE="$ICON_ROOT/hicolor/256x256/apps/openchamber-desktop.png"
if [ -f "$ICON_FILE" ]; then
    success "Ícone encontrado em: $ICON_FILE"
else
    warn "Ícone não encontrado no local padrão"
    if [ -f "$INSTALL_DIR/assets/openchamber-logo-dark.png" ]; then
        info "Ícone de origem encontrado em: $INSTALL_DIR/assets/openchamber-logo-dark.png"
    fi
fi

echo ""
echo "=========================================="
echo "  CORREÇÃO"
echo "=========================================="
echo ""

# Perguntar se quer corrigir
read -p "Deseja corrigir o arquivo .desktop agora? (s/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Ss]$ ]]; then
    info "Criando backup do .desktop atual..."
    if [ -f "$DESKTOP_FILE" ]; then
        cp "$DESKTOP_FILE" "$DESKTOP_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Copiar ícone para o local correto
    info "Instalando ícone..."
    mkdir -p "$ICON_ROOT/hicolor/256x256/apps"
    if [ -f "$INSTALL_DIR/assets/openchamber-logo-dark.png" ]; then
        cp "$INSTALL_DIR/assets/openchamber-logo-dark.png" "$ICON_ROOT/hicolor/256x256/apps/openchamber-desktop.png"
        success "Ícone instalado"
        ICON_NAME="openchamber-desktop"
    else
        warn "Ícone não encontrado, usando caminho absoluto"
        ICON_NAME="$INSTALL_DIR/assets/openchamber-logo-dark.png"
    fi
    
    # Criar novo .desktop
    info "Gerando novo arquivo .desktop..."
    cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=$DISPLAY_NAME
Comment=Desktop launcher for OpenChamber
Exec=$BIN_PATH
Icon=$ICON_NAME
Type=Application
Categories=Utility;Development;
Terminal=false
Keywords=OpenChamber;Desktop;Launcher;
StartupNotify=true
StartupWMClass=$DETECTED_WM_CLASS
X-Desktop-File-Install-Version=0.26
X-KDE-SubstituteUID=false
X-KDE-Username=
MimeType=x-scheme-handler/openchamber;
EOF
    chmod 644 "$DESKTOP_FILE"
    
    success "Arquivo .desktop atualizado!"
    echo ""
    echo "Novo conteúdo:"
    echo "---"
    cat "$DESKTOP_FILE"
    echo "---"
    
    # Atualizar banco de dados
    info "Atualizando banco de dados de aplicativos..."
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$DESKTOP_ROOT" 2>/dev/null || warn "Não foi possível atualizar desktop-database"
    fi
    
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f -t "$ICON_ROOT/hicolor" 2>/dev/null || true
    fi
    
    # Limpar cache do KDE (se for KDE)
    if [ -n "${XDG_CURRENT_DESKTOP:-}" ] && [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
        info "Limpando cache do KDE..."
        kbuildsycoca5 --noincremental 2>/dev/null || true
    fi
    
    success "Correção aplicada!"
    echo ""
    echo "=============================================="
    echo "  INSTRUÇÕES IMPORTANTES"
    echo "=============================================="
    echo ""
    echo "1. Remova o ícone atual da dock do KDE:"
    echo "   - Clique direito no ícone → 'Remover' ou 'Unpin'"
    echo ""
    echo "2. Abra o app pelo menu de aplicativos (KMenu)"
    echo ""
    echo "3. Quando o app estiver aberto, clique direito"
    echo "   no ícone na barra de tarefas e escolha"
    echo "   'Fixar na área de trabalho' ou 'Add to Panel'"
    echo ""
    echo "4. Feche e reabra o app pela dock para testar"
    echo ""
    echo "=============================================="
    
else
    echo "Correção cancelada."
fi

# Limpar
rm -f "$TEMP_SCRIPT"

echo ""
echo "Diagnóstico concluído!"
