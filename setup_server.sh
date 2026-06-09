#!/bin/bash
# ============================================================
# TribalLine — Setup inicial do servidor (rodar UMA vez)
# Baixa o Godot Linux headless e clona o codigo do jogo.
# Uso: ./setup_server.sh
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
GODOT_DIR="$BASE_DIR/godot"
GAME_DIR="$BASE_DIR/TribalLine"

GODOT_VERSION="4.6.1"
GODOT_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
GODOT_BIN="$GODOT_DIR/godot.linuxbsd.template_release.x86_64"

echo "============================================================"
echo " TribalLine — Setup do Servidor"
echo "============================================================"

# --- Godot ---
if [ -f "$GODOT_BIN" ]; then
    echo "[Setup] Godot ja instalado: $GODOT_BIN"
else
    echo "[Setup] Baixando Godot $GODOT_VERSION headless..."
    mkdir -p "$GODOT_DIR"
    TMP_ZIP="/tmp/godot_linux.zip"
    curl -L "$GODOT_URL" -o "$TMP_ZIP"
    unzip -o "$TMP_ZIP" -d "$GODOT_DIR"
    # O zip vem com nome longo — renomeia para o nome padrao
    EXTRACTED=$(find "$GODOT_DIR" -name "Godot_v*linux*" -type f | head -1)
    if [ -z "$EXTRACTED" ]; then
        echo "ERRO: nao encontrou o binario extraido."
        exit 1
    fi
    mv "$EXTRACTED" "$GODOT_BIN"
    chmod +x "$GODOT_BIN"
    rm "$TMP_ZIP"
    echo "[Setup] Godot instalado: $GODOT_BIN"
fi

# --- Codigo do jogo ---
if [ -d "$GAME_DIR/.git" ]; then
    echo "[Setup] TribalLine ja clonado. Fazendo git pull..."
    cd "$GAME_DIR" && git pull
else
    echo "[Setup] Clonando TribalLine..."
    git clone https://github.com/luanlgo/TribalLine.git "$GAME_DIR"
fi

# --- Redis URL ---
echo ""
echo "============================================================"
echo " IMPORTANTE: defina a URL do Redis PROD antes de iniciar:"
echo ""
echo "   export TRIBALLINE_REDIS_URL=\"redis://default:SENHA@zephyr.proxy.rlwy.net:40233\""
echo ""
echo " Adicione ao ~/.bashrc ou ~/.profile para persistir entre restarts."
echo "============================================================"
echo ""
echo "[Setup] Concluido! Para iniciar o servidor:"
echo "   cd $SCRIPT_DIR && ./start_server.sh"
