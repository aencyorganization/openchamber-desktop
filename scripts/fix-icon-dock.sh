#!/bin/bash
#
# OpenChamber Desktop - Fix Total (One-liner)
# Download e executa a correção completa
#

REPO_RAW="https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main"

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║  OpenChamber Desktop - Correção de Ícone     ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

if [[ "$OSTYPE" != "linux-gnu"* ]] && [[ "$OSTYPE" != "linux"* ]]; then
    echo "❌ Este script é apenas para Linux!"
    exit 1
fi

TEMP_SCRIPT="/tmp/ocd-fix-total-$(date +%s).sh"

echo "📥 Baixando script de correção..."
if curl -fsSL "$REPO_RAW/scripts/ocd-fix-total.sh" -o "$TEMP_SCRIPT" 2>/dev/null; then
    chmod +x "$TEMP_SCRIPT"
    echo "✅ Script baixado com sucesso"
    echo ""
    echo "🔧 Executando correção..."
    echo ""
    bash "$TEMP_SCRIPT"
    rm -f "$TEMP_SCRIPT"
else
    echo "❌ Falha ao baixar o script"
    echo ""
    echo "Tente executar manualmente:"
    echo "  git clone https://github.com/aencyorganization/openchamber-desktop.git"
    echo "  cd openchamber-desktop"
    echo "  bash ./scripts/ocd-fix-total.sh"
    exit 1
fi
