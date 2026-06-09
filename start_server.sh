#!/bin/bash
# ============================================================
# TribalLine — Servidor Dedicado (Linux/Mac)
# ============================================================
GAME="./triballine.x86_64"
CONFIG="server.cfg"

if [ ! -f "$GAME" ]; then
    echo "ERRO: $GAME não encontrado!"
    echo "Exporte como Dedicated Server e coloque aqui."
    exit 1
fi

# Lê porta do config
PORT=$(grep "^port" "$CONFIG" | cut -d= -f2 | tr -d ' ')
PORT=${PORT:-7777}

echo "============================================================"
echo " TribalLine Server — porta $PORT"
echo " PID: $$  |  Ctrl+C para parar"
echo "============================================================"

chmod +x "$GAME"
"$GAME" --headless -- --server --port "$PORT"
