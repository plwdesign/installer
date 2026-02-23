#!/bin/bash
# Lista portas usadas pelo instalador e indica se estao EM USO ou livre (evitar conflito entre instancias)

SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do
  SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" 2>/dev/null && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" 2>/dev/null && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

check_port() {
  local p="$1"
  if command -v ss &>/dev/null; then
    ss -tlnp 2>/dev/null | grep -q ":$p " && echo "EM USO" || echo "livre"
  elif command -v netstat &>/dev/null; then
    netstat -tln 2>/dev/null | grep -q ":$p " && echo "EM USO" || echo "livre"
  else
    echo "?"
  fi
}

echo ""
echo -e "${CYAN}=== Portas usadas pelo instalador (evitar conflito entre instancias) ===${NC}"
echo ""
echo -e "  ${BOLD}Servico              Porta    Uso${NC}"
echo "  ------------------------------------------------"
printf "  %-20s %-7s %s\n" "Nginx HTTP"     "80"    "SSL/redirect"
printf "  %-20s %-7s %s\n" "Nginx HTTPS"    "443"   "SSL"
printf "  %-20s %-7s %s\n" "PostgreSQL"     "5432"  "Banco"
printf "  %-20s %-7s %s\n" "Redis"          "6379"  "BullMQ/session"
printf "  %-20s %-7s %s\n" "Backend (API)"  "4250"  "1a instancia sugerida"
printf "  %-20s %-7s %s\n" "Frontend (PM2)" "3000"  "1a instancia sugerida"
printf "  %-20s %-7s %s\n" "Frontend Vite"  "5173"  "Dev"
printf "  %-20s %-7s %s\n" "Browserless"    "3999"  "Docker Chrome WS"
echo "  ------------------------------------------------"
echo ""
echo -e "  ${BOLD}Status no sistema:${NC}"
echo ""

for p in 80 443 5432 6379 3000 3999 4250 5173; do
  st=$(check_port "$p")
  if [[ "$st" == "EM USO" ]]; then
    printf "    %5s -> ${RED}EM USO${NC}\n" "$p"
  else
    printf "    %5s -> ${GREEN}livre${NC}\n" "$p"
  fi
done

echo ""
echo -e "  ${YELLOW}Dica:${NC} Para 2a instancia use portas diferentes (ex: backend 4251, frontend 3001)."
echo "  Rode este script antes de instalar para escolher portas livres."
echo ""
