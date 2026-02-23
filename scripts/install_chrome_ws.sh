#!/bin/bash
# Instala Docker (se necessario), sobe Browserless e emite CHROME_WS/CHROME_BIN para eval.
# Uso no instalador: eval "$(./scripts/install_chrome_ws.sh)"
# Opcional: --port 3999 (ou primeira porta livre a partir dela)

set -e

SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do
  SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" 2>/dev/null && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" 2>/dev/null && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose-browserless.yml"

check_port() {
  local p="$1"
  if command -v ss &>/dev/null; then
    ss -tlnp 2>/dev/null | grep -q ":$p " && return 0 || return 1
  elif command -v netstat &>/dev/null; then
    netstat -tln 2>/dev/null | grep -q ":$p " && return 0 || return 1
  fi
  return 1
}

find_free_port() {
  local start="${1:-3999}"
  local p="$start"
  while [[ $p -lt $((start + 20)) ]]; do
    if ! check_port "$p"; then
      echo "$p"
      return 0
    fi
    ((p++)) || true
  done
  echo "$start"
}

if [[ "${1:-}" == "--help" ]]; then
  echo "Uso: install_chrome_ws.sh [--port 3999]"
  echo "  Emite CHROME_WS= e CHROME_BIN= para eval pelo instalador."
  exit 0
fi

PORT="${BROWSERLESS_PORT:-3999}"
if [[ "${1:-}" == "--port" && -n "${2:-}" ]]; then
  PORT="$2"
fi
PORT=$(find_free_port "$PORT")

if ! command -v docker &>/dev/null; then
  echo "CHROME_BIN="
  echo "CHROME_WS="
  echo "BROWSERLESS_TOKEN="
  echo "BROWSERLESS_PORT="
  echo "# Docker nao encontrado. Rode: curl -fsSL https://get.docker.com | sh" >&2
  exit 1
fi

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "CHROME_BIN="
  echo "CHROME_WS="
  echo "BROWSERLESS_TOKEN="
  echo "BROWSERLESS_PORT="
  echo "# Arquivo $COMPOSE_FILE nao encontrado." >&2
  exit 1
fi

TOKEN="wagrupos-$(openssl rand -hex 16 2>/dev/null || echo "token-$(date +%s)")"
export BROWSERLESS_TOKEN="$TOKEN"
export BROWSERLESS_PORT="$PORT"

cd "$SCRIPT_DIR"
if docker compose version &>/dev/null; then
  docker compose -f docker-compose-browserless.yml up -d 2>/dev/null || true
else
  docker-compose -f docker-compose-browserless.yml up -d 2>/dev/null || true
fi

CHROME_WS_VALUE="ws://127.0.0.1:${PORT}?token=${TOKEN}"
echo "CHROME_BIN="
echo "CHROME_WS=$CHROME_WS_VALUE"
echo "BROWSERLESS_TOKEN=$TOKEN"
echo "BROWSERLESS_PORT=$PORT"
