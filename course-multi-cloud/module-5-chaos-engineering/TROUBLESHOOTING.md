# Troubleshooting: Chaos Engineering e Resiliência

Problemas práticos ao executar Game Days na vida real.

## 1. O Raio de Explosão foi Muito Longe (Blast Radius Explosion)
**Problema**: Você decidiu testar a queda de um serviço Nginx interno derrubando sua rede, mas isso causou um erro em cascata não mapeado que derrubou o gateway de pagamento e bloqueou o login dos administradores do cloud.
**Causa**: Seu experimento de Chaos Engineering foi feito em um sistema monólito não-desacoplado, sem definir corretamente o **Blast Radius** (Raio da Explosão) e a **Condição de Aborto** (Abort Condition).
**Solução**: Comece os testes de forma atômica (um container isolado) antes de cortar uma VPC inteira. Crie scripts automáticos que cancelam o teste e executam a regra de "Cura" se a latência global passar de 2 segundos ou o índice de erro 500 do front-end passar de 5%.

## 2. Ferramentas de Caos Não Injetam (Permissão Negada)
**Problema**: Você tenta rodar `tc` ou `iptables` dentro de um container Docker no seu cluster ECS/Nomad/K8s, e recebe erro de `Operation not permitted`.
**Causa**: O kernel do Linux impede que os containers modifiquem regras globais de firewall da máquina hospedeira (*Host*) por segurança (Security Capabilities).
**Solução**: Ferramentas de engenharia do caos como o *Chaos Mesh* ou containers de testes precisam rodar em modo privilegiado (`--privileged` ou acionando a permissão `--cap-add=NET_ADMIN`) para poderem criar *Network Namespaces* distorcidos.

## 3. Observabilidade Inútil (Flying Blind)
**Problema**: A AWS caiu, o sistema sobreviveu rodando apenas na GCP, mas nenhum engenheiro foi alertado e os gráficos no Grafana ficaram em branco ("No Data").
**Causa**: Você hospedou sua central de Monitoramento, Métricas e Logs na AWS. Quando a nuvem AWS caiu, **os seus olhos caíram junto com ela**.
**Solução**: O cluster de observabilidade, métricas centrais e alertas DOVE de incidentes (*PagerDuty, OpsGenie*) **nunca deve residir unicamente na mesma infraestrutura da aplicação monitorada**. Ou se usa um SaaS externo e distribuído (Datadog, New Relic) ou o cluster Prometheus central deve ter redundância em pelo menos outra nuvem ou on-premise isolado.