#!/bin/bash
# ============================================================
# TribalLine — Servidor Dedicado (Linux)
# Roda direto do codigo-fonte via Godot headless.
# Nao precisa exportar o jogo — so dar git pull e reiniciar.
#
# Uso: ./start_server.sh
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/server.cfg"
GODOT_PATH_FILE="$SCRIPT_DIR/godot_path.txt"

# --- Codigo-fonte do jogo (clonado ao lado desta pasta) ---
GAME_DIR="$(dirname "$SCRIPT_DIR")/TribalLine"

# --- Godot headless ---
GODOT=""
if [ -f "$GODOT_PATH_FILE" ]; then
    GODOT=$(cat "$GODOT_PATH_FILE" | tr -d '[:space:]')
fi
if [ -z "$GODOT" ] || [ ! -f "$GODOT" ]; then
    # Tenta achar na pasta godot/ ao lado
    FALLBACK="$(dirname "$SCRIPT_DIR")/godot/godot.linuxbsd.template_release.x86_64"
    if [ -f "$FALLBACK" ]; then
        GODOT="$FALLBACK"
    fi
fi
if [ -z "$GODOT" ] || [ ! -f "$GODOT" ]; then
    echo "ERRO: Godot nao encontrado."
    echo "Execute ./setup_server.sh ou coloque o caminho em godot_path.txt"
    exit 1
fi

# --- Porta ---
PORT=$(grep "^port" "$CONFIG" 2>/dev/null | cut -d= -f2 | tr -d ' ')
PORT=${PORT:-7777}

# --- Redis ---
if [ -z "$TRIBALLINE_REDIS_URL" ] && [ -z "$REDIS_URL" ]; then
    echo "AVISO: TRIBALLINE_REDIS_URL nao definida. Servidor vai falhar ao conectar no banco."
    echo "       Defina: export TRIBALLINE_REDIS_URL=redis://..."
fi

echo "============================================================"
echo " TribalLine — Servidor Dedicado"
echo " Projeto : $GAME_DIR"
echo " Porta   : $PORT"
echo " PID     : $$"
echo " Ctrl+C para parar"
echo "============================================================"

chmod +x "$GODOT"
exec "$GODOT" --headless --path "$GAME_DIR" -- --server --port "$PORT"
