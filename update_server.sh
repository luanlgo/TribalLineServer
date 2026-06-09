#!/bin/bash
# ============================================================
# TribalLine — Atualizar e reiniciar o servidor via PM2
# Uso: ./update_server.sh
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GAME_DIR="$(dirname "$SCRIPT_DIR")/TribalLine"

echo "[Update] Atualizando codigo..."
cd "$GAME_DIR" || { echo "ERRO: $GAME_DIR nao encontrado"; exit 1; }
git pull

echo "[Update] Reiniciando via PM2..."
pm2 restart triballine

echo "[Update] Pronto! Status:"
pm2 show triballine
