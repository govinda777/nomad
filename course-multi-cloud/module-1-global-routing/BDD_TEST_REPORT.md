# 📊 Relatório do Cenário de Teste BDD

Este documento ilustra e detalha o fluxo de execução do teste de integração BDD (`bdd_test.py`) para validação do roteamento dinâmico e failover ativo-ativo.

## 🗺️ Diagrama do Fluxo de Teste (BDD Sequence)

O diagrama abaixo descreve a interação entre o Executor do Teste (`bdd_test.py`), o Global Traffic Manager (`HAProxy`) e os clusters regionais (`AWS` e `GCP`) em cada etapa do cenário BDD:

```mermaid
sequenceDiagram
    autonumber
    actor TestRunner as Test Runner (bdd_test.py)
    participant GTM as GTM Edge (HAProxy :8080)
    participant AWS as AWS Mock (:8081)
    participant GCP as GCP Mock (:8082)

    %% GIVEN STEP
    Note over TestRunner, GCP: GIVEN: Infraestrutura iniciada e saudável
    TestRunner->>AWS: HTTP GET / (Verifica acessibilidade direta)
    AWS-->>TestRunner: 200 OK (AWS ativa)
    TestRunner->>GCP: HTTP GET / (Verifica acessibilidade direta)
    GCP-->>TestRunner: 200 OK (GCP ativa)
    TestRunner->>GTM: HTTP GET / (Valida rota padrão inicial)
    GTM-->>TestRunner: 200 OK (Entregue pela AWS)

    %% WHEN AWS FAILS
    Note over TestRunner, AWS: WHEN: AWS sofre um apagão (Blackout)
    TestRunner->>AWS: docker stop lb-mock-aws
    Note over AWS: Container Desligado (DOWN)
    Note over GTM: Health check falha (após 4 segundos de tolerância)

    %% THEN GTM FAILS OVER
    Note over TestRunner, GCP: THEN: Tráfego é redirecionado para o GCP
    TestRunner->>GTM: HTTP GET / (Consulta de Failover)
    GTM->>GCP: Encaminha requisição (já que AWS está inacessível)
    GCP-->>GTM: 200 OK (GCP Ativo)
    GTM-->>TestRunner: 200 OK (Resposta do GCP)

    %% WHEN AWS RECOVERS
    Note over TestRunner, AWS: WHEN: AWS se recupera e volta a ficar online
    TestRunner->>AWS: docker start lb-mock-aws
    Note over AWS: Container Iniciado (UP)
    Note over GTM: Health check detecta recuperação (após 3 segundos)

    %% THEN TRAFFIC REVERTS
    Note over TestRunner, AWS: THEN: Tráfego reverte automaticamente para a AWS
    TestRunner->>GTM: HTTP GET / (Consulta de Reversão)
    GTM->>AWS: Encaminha para o primário (AWS reestabelecida)
    AWS-->>GTM: 200 OK (AWS ativa)
    GTM-->>TestRunner: 200 OK (Resposta da AWS)
```

---

## 🔍 Detalhes dos Passos BDD

| Passo BDD | Ação Executada | Critério de Aceitação / Validação | Status |
| :--- | :--- | :--- | :--- |
| **GIVEN** | Verifica conectividade direta com as portas `:8081` (AWS) e `:8082` (GCP) | Ambas as portas devem retornar `HTTP 200` | **PASS** |
| **WHEN** | Executa o comando `docker stop lb-mock-aws` | O container AWS é desligado | **PASS** |
| **THEN** | Envia requisição HTTP para a porta global `:8080` | O retorno deve conter a assinatura de **GCP** | **PASS** |
| **WHEN** | Executa o comando `docker start lb-mock-aws` | O container AWS é reiniciado | **PASS** |
| **THEN** | Envia requisição HTTP para a porta global `:8080` | O retorno deve reverter para a assinatura de **AWS** | **PASS** |

---

## 📡 Arquitetura de Telemetria (Padrões OpenTelemetry - OTel)

Seguindo as melhores práticas de observabilidade moderna e padronização do **OpenTelemetry (OTel)**, o fluxo de coleta e entrega de métricas da PoC é estruturado de forma desacoplada através de coletores e agentes dedicados:

```mermaid
graph TD
    subgraph Multi-Cloud Resources
        GTM[GTM / HAProxy Edge :8080] -->|Exposes Metrics| GTM_M[Prometheus Exporter :1936]
        AWS_Node[AWS Region - Nomad Client] -->|Exposes Workload metrics| AWS_M[Prometheus Exporter :8081]
        GCP_Node[GCP Region - Nomad Client] -->|Exposes Workload metrics| GCP_M[Prometheus Exporter :8082]
    end

    subgraph OTel Telemetry Pipeline
        OTel_Collector[OpenTelemetry Collector]
        
        %% Scraping data
        OTel_Collector -->|Scrape Metrics| GTM_M
        OTel_Collector -->|Scrape Metrics| AWS_M
        OTel_Collector -->|Scrape Metrics| GCP_M
        
        Prometheus_TSDB[(Prometheus TSDB)]
        
        %% Exporting
        OTel_Collector -->|OTLP / Remote Write| Prometheus_TSDB
    end

    subgraph Visualization & Analytics
        Grafana[Grafana Dashboards]
        Grafana -->|Query PromQL| Prometheus_TSDB
    end

    style GTM fill:#f9f,stroke:#333,stroke-width:2px
    style OTel_Collector fill:#ff79c6,stroke:#333,stroke-width:2px,color:#fff
    style Prometheus_TSDB fill:#ff9900,stroke:#333,color:#fff
    style Grafana fill:#4285f4,stroke:#333,color:#fff
```

### Componentes do Pipeline OTel:
1. **Instrumentação / Exporters**: Cada componente do sistema (GTM/HAProxy e os workloads nos Nomad Clients) expõe suas métricas de forma nativa e padronizada.
2. **OTel Collector**: Centraliza a coleta (*scraping*) de métricas do HAProxy e de toda a infraestrutura, eliminando a dependência de múltiplos agentes específicos e unificando o tráfego de dados telemétricos.
3. **Prometheus TSDB**: Funciona como o banco de dados temporal de destino das métricas, populado através do pipeline de exportação do OTel Collector.
4. **Grafana**: A camada visual que lê os dados históricos do Prometheus para exibir gráficos consolidados de RPS e status do cluster.

