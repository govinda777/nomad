# ADR 0007: Ambiente Sandbox Local para Execução Simplificada de PoCs e Exercícios

* **Status:** Aceito
* **Data:** 2026-08-08
* **Autores:** Antigravity (IA), Govinda

## Contexto e Problema

Subir infraestrutura de rede multi-cloud real na AWS e no GCP (envolvendo roteamento DNS, WireGuard, Consul Federation e CockroachDB) exige credenciais de provedores, gera custos financeiros e gasta muito tempo. Para um curso prático, os alunos precisam de um ambiente sandbox imediato, local e gratuito onde possam testar as mesmas regras de failover, conectividade mesh e injeção de caos com o menor atrito operacional possível.

## Decisão Consensual

Decidimos fornecer um **Ambiente Sandbox Local Unificado** baseado em Docker e scripts de orquestração local:

1. **Simulador de Topologia via Docker Compose:**
   - Criação de um ambiente Docker local simulando a rede AWS e GCP usando redes virtuais isoladas no Docker (`bridge` customizadas).
   - O Nomad local será executado em containers com privilégios de rede para permitir testes reais de rede.
2. **Scripts de Automação de Borda (One-Click Scripts):**
   - Criação de scripts bash utilitários simples na raiz de cada módulo e na raiz do projeto:
     - `./sandbox.sh up`: Inicia todo o ambiente mockado daquele módulo.
     - `./sandbox.sh down`: Limpa todos os recursos locais.
     - `./sandbox.sh test`: Roda validações automáticas de conectividade e saúde da PoC.
3. **Mapeamento de Volumes e Configuração Rápida:**
   - Montagem de volumes locais para que qualquer alteração de código ou de especificação de job Nomad (`.nomad.hcl`) feita pelo aluno reflita instantaneamente no container em execução, sem necessidade de rebuild.

## Consequências

### Positivas
* **Atrito Zero:** Alunos podem focar na arquitetura e nas configurações do Nomad sem perder tempo configurando chaves SSH, contas na nuvem ou acessos de segurança.
* **Segurança e Isolamento:** Testes destrutivos de rede (caos) ocorrem dentro do namespace do Docker, sem afetar o sistema operacional do estudante.

### Negativas
* **Fidelidade Limitada:** O Docker Compose local não simula com total precisão o comportamento real de DNS Anycast ou roteamento complexo de borda WAN da nuvem física, servindo como uma representação lógica das funcionalidades.
