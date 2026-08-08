#!/bin/bash
# inject_chaos.sh
# MOCK SCRIPT - Não rode isso numa máquina host importante sem isolamento!
# Este script seria executado dentro de containers/VMs específicos pelo Agente IA para causar pânico simulado na rede.

set -e

echo "⚠️ [SKILL: Chaos Simulator] Iniciando Game Day!"

TARGET_INTERFACE="eth0"
ACTION=$1

if [ -z "$ACTION" ]; then
  echo "Uso: $0 [delay|blackhole|heal]"
  exit 1
fi

case "$ACTION" in
  delay)
    echo "🌀 Injetando 500ms de latência e 5% de packet loss na interface $TARGET_INTERFACE..."
    # 'tc' é usado para Controle de Tráfego no Kernel Linux
    tc qdisc add dev $TARGET_INTERFACE root netem delay 500ms 50ms distribution normal loss 5%
    echo "Caos implementado: Latência ativada. Aplicações vão sofrer com Timeouts."
    ;;

  blackhole)
    echo "🕳️ Injetando Blackhole! Derrubando TODO tráfego TCP simulando queda total do datacenter..."
    # Bloqueia pacotes de entrada silenciosamente (sem mandar resposta TCP RST)
    iptables -A INPUT -p tcp -j DROP
    echo "Caos implementado: Nó completamente isolado do cluster."
    ;;

  heal)
    echo "💊 Curando o Nó! Removendo restrições de rede..."
    tc qdisc del dev $TARGET_INTERFACE root 2> /dev/null || true
    iptables -D INPUT -p tcp -j DROP 2> /dev/null || true
    echo "Sistema curado. Observar tempo de re-estabilização nos dashboards."
    ;;

  *)
    echo "Ação inválida."
    exit 1
    ;;
esac
