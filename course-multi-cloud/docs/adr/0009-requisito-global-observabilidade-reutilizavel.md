# ADR 0009: Requisito de Observabilidade Global e Reutilizável com Prometheus e Grafana

* **Status:** Aceito
* **Data:** 2026-08-08
* **Autores:** Antigravity (IA), Govinda

## Contexto e Problema

Em sistemas distribuídos multi-cloud ativo-ativo, a falha é inevitável. Sem telemetria unificada, diagnosticar por que uma transação de escrita levou 150ms ou por que um deploy falhou em uma nuvem mas funcionou na outra é extremamente difícil. Precisamos de uma infraestrutura de observabilidade global que monitore dinamicamente o status de todas as PoCs e seja reutilizável em todos os módulos, permitindo que o aluno comprove visualmente o impacto dos testes de caos nos gráficos de métricas.

## Decisão Consensual

Decidimos estabelecer a **Observabilidade como Requisito Global e Central** do projeto, implementando uma stack de monitoramento reutilizável:

1. **Stack Centralizada de Métricas:**
   - Provisionamento de uma stack global com **Prometheus** e **Grafana** compartilhada.
   - Configuração do Prometheus (`prometheus.yml`) contendo regras dinâmicas de *static_configs* que apontam para os serviços de todos os módulos. Os alvos serão escaneados automaticamente à medida que as PoCs de cada módulo forem iniciadas.

2. **Endpoints de Telemetria Padronizados:**
   - **Módulo 1:** Métricas do HAProxy expostas nativamente ou via exporter na porta `1936`.
   - **Módulo 2:** Consul Telemetry exposto na porta `/v1/agent/metrics` usando formato Prometheus.
   - **Módulo 3:** Nomad Telemetry habilitado e exposto na porta `/v1/metrics`.
   - **Módulo 4:** CockroachDB expondo métricas nativas compatíveis com Prometheus na rota `/_status/vars` de cada nó.

3. **Grafana Dashboards Reutilizáveis:**
   - Criação de dashboards pré-configurados do Grafana para rastrear:
     - Saúde de quórum do CockroachDB (status de réplicas e quantidade de nós ativos).
     - Status da federação do Consul e latência WAN.
     - Métricas de requisição e erros HTTP do roteador de borda (HAProxy).

## Consequências

### Positivas
* **Visibilidade em Tempo Real:** Alunos podem analisar o tráfego e a telemetria antes, durante e depois da injeção de falhas (Módulo 5).
* **Stack Única:** Evita subir instâncias duplicadas de monitoramento em cada módulo, economizando recursos de hardware locais.

### Negativas
* **Consumo de Memória:** Executar Prometheus e Grafana consome memória adicional (~300MB a mais no ambiente de desenvolvimento do aluno).
