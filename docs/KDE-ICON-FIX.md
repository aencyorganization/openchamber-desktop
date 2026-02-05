# 🔧 Problema do Ícone no KDE - SOLUÇÃO

## 📋 Descrição do Problema

Quando você fixa o OpenChamber Desktop na dock do KDE Plasma:
1. ❌ O ícone não aparece (aparece um ícone genérico ou do Neutralino)
2. ❌ Quando fecha e reabre pela dock, abre algo relacionado ao "neutralino" em vez do app
3. ✅ Mas abrindo pelo menu de aplicativos funciona normalmente

## 🔍 Causa Raiz

O problema é a **incompatibilidade do `StartupWMClass`** no arquivo `.desktop`.

### O que acontece:

```
Menu Iniciar → openchamber-desktop.desktop → Exec → node cli.js → neutralino-linux_x64
                                                       ↓
                                                  WM_CLASS="neutralino-linux_x64"
                                                       ↓
KDE não reconhece que a janela pertence ao .desktop (StartupWMClass ≠ WM_CLASS real)
                                                       ↓
Ícone não aparece na dock / Comportamento errado
```

### Por que funciona no menu mas não na dock:

- **Menu**: O KDE executa o `.desktop` diretamente e monitora o processo inicial
- **Dock**: O KDE tenta associar a janela ao arquivo `.desktop` usando a `WM_CLASS` da janela
- Se `StartupWMClass` no `.desktop` não corresponder à `WM_CLASS` real do binário, a associação falha

## ✅ Solução Completa

### Passo 1: Rodar o Script de Correção

```bash
cd /caminho/para/openchamber-desktop
./scripts/fix-kde-icon.sh
```

Este script vai:
1. Detectar qual `WM_CLASS` o Neutralino está realmente usando
2. Corrigir o arquivo `.desktop` com o valor correto
3. Instalar o ícone no local padrão do sistema
4. Limpar caches do KDE

### Passo 2: Refixar o Ícone na Dock

1. **Remova o ícone atual da dock**:
   - Clique direito no ícone → "Remover" ou "Unpin"

2. **Abra o app pelo menu de aplicativos** (KMenu)

3. **Fixe novamente**:
   - Clique direito no ícone na barra de tarefas
   - Escolha "Fixar na área de trabalho" ou "Add to Panel"

4. **Teste**:
   - Feche o app
   - Abra pela dock
   - O ícone correto deve aparecer!

## 🔧 Correção Manual (Alternativa)

Se preferir fazer manualmente, edite o arquivo `~/.local/share/applications/openchamber-desktop.desktop`:

```ini
[Desktop Entry]
Name=OpenChamber Desktop
Comment=Desktop launcher for OpenChamber
Exec=/home/SEU_USUARIO/.local/bin/openchamber-desktop
Icon=openchamber-desktop
Type=Application
Categories=Utility;Development;
Terminal=false
Keywords=OpenChamber;Desktop;Launcher;
StartupNotify=true
StartupWMClass=neutralino-linux_x64  ← CORRIGIR ESTA LINHA
```

### Como descobrir a WM_CLASS correta:

```bash
# Abra o OpenChamber Desktop
# Em outro terminal, execute:
xprop WM_CLASS
# Clique na janela do OpenChamber
# O resultado será algo como: WM_CLASS(STRING) = "neutralino", "neutralino-linux_x64"
# Use o segundo valor (sem aspas) no StartupWMClass
```

## 📁 Arquivos Modificados

1. **`scripts/install/linux-install.sh`** - Corrigido para gerar `.desktop` correto
2. **`scripts/fix-kde-icon.sh`** - Script de diagnóstico e correção (NOVO)

## 🎯 Mudanças Específicas

### Antes (problemático):
```ini
StartupWMClass=openchamber-launcher
Icon=/opt/openchamber-desktop/assets/openchamber-logo-dark.png
```

### Depois (corrigido):
```ini
StartupWMClass=neutralino-linux_x64  ; ← Nome real do binário
Icon=openchamber-desktop              ; ← Nome do ícone no tema
X-KDE-SubstituteUID=false             ; ← Melhor integração KDE
```

## 🧪 Testado em

- ✅ CachyOS com KDE Plasma
- ✅ Outras distros com KDE devem funcionar

## 📝 Notas

- O problema ocorre porque o Neutralinojs define a WM_CLASS baseado no nome do binário
- Nosso wrapper script (`cli.js`) não controla a WM_CLASS da janela
- O KDE é mais estrito que outros DEs (GNOME, XFCE) nessa associação

## 🆘 Ainda com problemas?

1. Verifique se o ícone está instalado:
   ```bash
   ls -la ~/.local/share/icons/hicolor/256x256/apps/openchamber-desktop.png
   ```

2. Limpe o cache do KDE:
   ```bash
   kbuildsycoca5 --noincremental
   ```

3. Reinicie a sessão do Plasma (logout/login)

4. Verifique logs:
   ```bash
   journalctl -xe | grep -i openchamber
   ```
