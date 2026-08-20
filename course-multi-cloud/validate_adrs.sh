#!/usr/bin/env bash
# Script de Validação de Conformidade com as ADRs
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${BOLD}Iniciando Auditoria de Conformidade com as ADRs...${NC}\n"

# 1. Validando ADR 0001 (Presença das ADRs)
echo -n "ADR 0001 - Verificando estrutura de documentação ADR: "
if [ -d "docs/adr" ] && [ -f "docs/adr/README.md" ]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FALHA (Pasta docs/adr/ ou index não encontrado)${NC}"
fi

# 2. Validando ADR 0006 (Estrutura de Ensino)
echo -e "\nADR 0006 - Verificando estrutura dos módulos (base, exercises, README, LAB):"
MODULES=(
    "module-1-global-routing"
    "module-2-mesh-network"
    "module-3-nomad-federation"
    "module-4-distributed-data"
    "module-5-chaos-engineering"
)

for mod in "${MODULES[@]}"; do
    echo -n "  - $mod: "
    MISSING=()
    [ -f "$mod/README.md" ] || MISSING+=("README.md")
    [ -f "$mod/LAB.md" ] || MISSING+=("LAB.md")
    [ -d "$mod/base" ] || MISSING+=("base/")
    [ -d "$mod/exercises" ] || MISSING+=("exercises/")
    
    if [ ${#MISSING[@]} -eq 0 ]; then
        echo -e "${GREEN}Conforme${NC}"
    else
        echo -e "${RED}Incompleto (Faltando: ${MISSING[*]} )${NC}"
    fi
done

# 3. Validando ADR 0007 (Ambiente Sandbox Local e Scripts)
echo -e "\nADR 0007 - Verificando scripts sandbox.sh:"
echo -n "  - Raiz (sandbox.sh): "
if [ -f "sandbox.sh" ] && [ -x "sandbox.sh" ]; then
    echo -e "${GREEN}OK (Executável)${NC}"
else
    echo -e "${RED}FALHA (Ausente ou sem permissão de execução)${NC}"
fi

for mod in "${MODULES[@]}"; do
    echo -n "  - $mod/sandbox.sh: "
    if [ -f "$mod/sandbox.sh" ] && [ -x "$mod/sandbox.sh" ]; then
        echo -e "${GREEN}OK (Executável)${NC}"
    else
        echo -e "${RED}FALHA (Ausente ou sem permissão de execução)${NC}"
    fi
done

# 4. Validando ADR 0008 (Painel de Controle Global)
echo -e "\nADR 0008 - Verificando Painel de Controle:"
echo -n "  - Pasta control-panel: "
if [ -d "global-services/control-panel" ] && [ -f "global-services/control-panel/Dockerfile" ]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FALHA (Dockerfile ou diretório ausente)${NC}"
fi

echo -n "  - Serviço Docker Compose do Painel: "
if grep -q "control-panel:" global-services/docker-compose.yml; then
    echo -e "${GREEN}OK (Definido no compose global)${NC}"
else
    echo -e "${RED}FALHA (Serviço não declarado no docker-compose)${NC}"
fi

# 5. Validando ADR 0009 (Observabilidade Reutilizável)
echo -e "\nADR 0009 - Verificando Stack de Observabilidade:"
echo -n "  - Prometheus (prometheus.yml): "
if [ -f "global-services/prometheus.yml" ]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FALHA (prometheus.yml não encontrado)${NC}"
fi

echo -n "  - Docker Compose Global (Prometheus/Grafana): "
if grep -q "prometheus:" global-services/docker-compose.yml && grep -q "grafana:" global-services/docker-compose.yml; then
    echo -e "${GREEN}OK (Prometheus e Grafana configurados)${NC}"
else
    echo -e "${RED}FALHA (Serviços de métricas ausentes no compose)${NC}"
fi

echo -e "\n${BOLD}Auditoria Concluída.${NC}"
