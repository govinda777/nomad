# ADR 0005: Estratégia de Testes de Resiliência via Injeção de Caos (iptables e tc)

* **Status:** Aceito
* **Data:** 2026-08-08
* **Autores:** Antigravity (IA), Govinda

## Contexto e Problema

Validar se uma arquitetura ativa-ativa de fato sobrevive a desastres requer a simulação prática e reprodutível desses cenários. O failover do Anycast/DNS, a reconexão automática do Consul Federation e a resistência a split-brain do CockroachDB precisam ser testados sem depender de quedas físicas imprevisíveis de provedores reais.

## Decisão Consensual

Decidimos padronizar os testes de resiliência e validação da arquitetura usando **Injeção de Caos via comandos de rede do Linux**, executados sob controle do Agente de IA (`[SKILL: Chaos Simulator]`):

1. **Simulação de Degradação de Latência (tc):**
   - Utilização do comando `tc qdisc` (`iproute2`) na interface de rede do WireGuard ou nas placas físicas para injetar atrasos artificiais (ex: `tc qdisc add dev wg0 root netem delay 200ms`).
   - Objetivo: Testar os limites de timeout do Nomad Raft e do CockroachDB.
2. **Simulação de Partição Total de Rede (iptables):**
   - Bloqueio completo de tráfego inter-cloud de forma unilateral ou bilateral usando regras de firewall (`iptables -A INPUT -p udp --dport 51820 -j DROP` para simular queda do WireGuard).
   - Objetivo: Forçar o CockroachDB e o Nomad a acionar mecanismos de sobrevivência a split-brain e fail-local.

## Consequências

### Positivas
* **Previsibilidade sob Stress:** Demonstra exatamente como a aplicação se comporta em falhas severas de tráfego.
* **Automação:** A IA pode iniciar o caos e avaliar as métricas de recuperação de forma estruturada.

### Negativas
* **Requisito de Privilégios:** Exige acesso de `root` (`sudo`) nos servidores locais de simulação ou VMs na nuvem.
