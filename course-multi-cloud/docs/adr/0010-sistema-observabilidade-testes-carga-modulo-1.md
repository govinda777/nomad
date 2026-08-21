# ADR 0010: Sistema de Observabilidade e Testes de Carga para o Módulo 1

* **Status:** Aceito
* **Data:** 2026-08-13
* **Autores:** Antigravity (IA), Govinda

## Contexto e Problema

No Módulo 1 (Roteamento Global Ativo-Ativo), validamos como o tráfego se comporta quando um provedor de nuvem (AWS) cai e o tráfego é redirecionado para outro (GCP). No entanto, para comprovar a eficácia dessa arquitetura sob condições reais, precisamos de:
1. **Métricas em tempo real** para observar o tempo de resposta, taxa de erro (erros 5xx) e distribuição de tráfego.
2. **Carga simulada (Testes de Carga)** para testar o comportamento do failover dinâmico sob estresse de requisições simultâneas.
3. **Visibilidade estruturada** unindo a infraestrutura à telemetria local.

## Decisão Consensual

Decidimos implementar um sistema de observabilidade e gerador de testes de carga local focado no Módulo 1:

1. **Observabilidade (Prometheus + Grafana + HAProxy Exporter):**
   - Configurar o HAProxy (`haproxy.cfg`) para expor métricas compatíveis com Prometheus na porta `1936` sob a rota `/metrics`.
   - Adicionar o **Prometheus** e o **Grafana** ao arquivo de composição Docker do Módulo 1 (`docker-compose.yml`) com dashboards pré-configurados para monitorar o status dos servidores backend (AWS e GCP) e taxas de requisição.

2. **Ferramenta de Testes de Carga (Locust ou K6):**
   - Usar **K6** (ou um script em Python com requests concorrentes) para injetar tráfego simulando múltiplos usuários simultâneos no Global Traffic Manager (GTM).
   - O script de carga será executável por um comando simples via `Makefile`.

3. **Scripts e Automação:**
   - Criar um script `load_test.py` ou `load_test.sh` que gera carga concorrente HTTP no GTM.
   - Fornecer visibilidade imediata no terminal do número de requisições, sucessos (200 OK) e falhas (503 Service Unavailable) durante a injeção do caos (derrubando o container AWS).

## Consequências

### Positivas
* **Evidência Visual:** O aluno pode abrir o Grafana e ver a linha do gráfico de requisições da AWS cair para zero e a do GCP subir instantaneamente no momento do failover.
* **Validação de Estresse:** Permite provar que o failover dinâmico funciona sem derrubar conexões ativas ou estourar a capacidade do servidor de backup.

### Negativas
* **Maior pegada de recursos:** Adiciona dois novos containers ao módulo (Prometheus e Grafana), aumentando o consumo de memória RAM do laboratório local em cerca de 200MB.
