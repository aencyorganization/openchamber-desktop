#!/bin/bash
#
# OpenChamber Desktop - Nuclear Fix (One-liner)
# Download e executa correção completa
#

REPO_RAW="https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  OpenChamber Desktop - Correção Completa (Nuclear)        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

if [[ "$OSTYPE" != "linux-gnu"* ]] && [[ "$OSTYPE" != "linux"* ]]; then
    echo "❌ Este script é apenas para Linux!"
    exit 1
fi

TEMP_SCRIPT="/tmp/ocd-nuclear-$(date +%s).sh"

echo "📥 Baixando script de correção nuclear..."
if curl -fsSL "$REPO_RAW/scripts/ocd-nuclear-fix.sh" -o "$TEMP_SCRIPT" 2>/dev/null; then
    chmod +x "$TEMP_SCRIPT"
    echo "✅ Script baixado"
    echo ""
    echo "🔧 Executando correção completa..."
    echo ""
    bash "$TEMP_SCRIPT"
    rm -f "$TEMP_SCRIPT"
else
    echo "❌ Falha ao baixar"
    echo ""
    echo "Tente manualmente:"
    echo "  git clone $REPO_URL"
    echo "  cd openchamber-desktop"
    echo "  bash ./scripts/ocd-nuclear-fix.sh"
    exit 1
fi
