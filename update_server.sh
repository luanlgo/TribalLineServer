#!/bin/bash
# ============================================================
# TribalLine — Atualizar e reiniciar o servidor
# Uso: ./update_server.sh
#
# Faz git pull no codigo do jogo e reinicia o servidor.
# O autosave roda a cada 60s — espera um pouco apos Ctrl+C
# antes de rodar este script para nao perder o ultimo save.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GAME_DIR="$(dirname "$SCRIPT_DIR")/TribalLine"

echo "[Update] Parando servidor..."
pkill -f "TribalLine.*--server" 2>/dev/null
sleep 2

echo "[Update] Atualizando codigo..."
cd "$GAME_DIR" || { echo "ERRO: $GAME_DIR nao encontrado"; exit 1; }
git pull

echo "[Update] Reiniciando servidor..."
cd "$SCRIPT_DIR"
nohup ./start_server.sh >> server.log 2>&1 &
echo "[Update] Servidor iniciado (PID $!). Log: $SCRIPT_DIR/server.log"
