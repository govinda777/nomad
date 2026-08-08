# Cenários de Chaos Engineering para Multi-Cloud

Exemplos de "Receitas de Caos" e qual arquitetura é validada ao injetar cada falha.

## Cenário 1: "O Fio Cortado" (Network Partitioning)
**Método**: Inserir regras rígidas no roteador de borda da nuvem ou DROP via `iptables`.
**O que ataca?**: Interrompe completamente o fluxo inter-cloud, gerando Split-Brain.
**Sistemas Validados**:
1. Valida se o banco de dados tem um quórum impar (Raft) com um nó *Witness* sobrevivente. Se não houver, ambos os clusters bloquearão a escrita tentando não perder o estado.
2. Valida se o Service Mesh consegue rotear requisições para fallbacks locais em vez de travar esperando resposta do serviço distante.

## Cenário 2: "O Engarrafamento" (Massive Latency)
**Método**: Usar `tc qdisc` (Traffic Control) com Netem para atrasar o trânsito da placa de rede.
`tc qdisc add dev eth0 root netem delay 2000ms 200ms distribution normal`
**O que ataca?**: Transações TCP demoram horrores, lotando threads e conexões nos servidores Web. Pior tipo de falha, pois a máquina "finge" estar viva.
**Sistemas Validados**:
1. Valida as lógicas de **Timeouts** da aplicação. (Nunca faça requisições sem limitadores de tempo).
2. Valida os **Circuit Breakers** (ex: Consul Envoy). Se 3 requisições falharem com timeout seguido, o Envoy "corta a chave" (*trip the circuit*) imediatamente, aliviando o servidor.

## Cenário 3: "A Máquina Exausta" (CPU/RAM Exhaustion)
**Método**: Usar ferramentas como o `stress-ng`.
`stress-ng --cpu 4 --io 2 --vm 1 --vm-bytes 1G --timeout 60s`
**O que ataca?**: Simula uma rotina pesada engolindo o servidor.
**Sistemas Validados**:
1. O Nomad (ou K8s) percebe a indisponibilidade de CPU/OOMKilled e precisa orquestrar o evicting/migração da task (Container) para uma máquina mais vazia e o Health Check de L7 tira o servidor da rotação pública.