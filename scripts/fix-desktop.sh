#!/bin/bash
#
# OpenChamber Desktop - Fix Desktop Entries
# One-liner para corrigir entradas duplicadas no KDE/Linux
#
# Uso: curl -fsSL https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main/scripts/fix-desktop.sh | bash
#

set -e

REPO_RAW="https://raw.githubusercontent.com/aencyorganization/openchamber-desktop/main"

echo "========================================"
echo "  OpenChamber Desktop Entry Fixer"
echo "========================================"
echo ""

# Verificar se é Linux
if [[ "$OSTYPE" != "linux-gnu"* ]] && [[ "$OSTYPE" != "linux"* ]]; then
    echo "❌ Este script é apenas para Linux!"
    exit 1
fi

# Baixar e executar o script de limpeza
TEMP_SCRIPT="/tmp/ocd-clean-$(date +%s).sh"

echo "📥 Baixando script de limpeza..."
if curl -fsSL "$REPO_RAW/scripts/clean-desktop-entries.sh" -o "$TEMP_SCRIPT"; then
    chmod +x "$TEMP_SCRIPT"
    echo "✅ Script baixado"
    echo ""
    echo "🧹 Executando limpeza..."
    echo ""
    bash "$TEMP_SCRIPT"
    rm -f "$TEMP_SCRIPT"
else
    echo "❌ Falha ao baixar o script de limpeza"
    echo "   Tente manualmente:"
    echo "   bash ./scripts/clean-desktop-entries.sh"
    exit 1
fi
