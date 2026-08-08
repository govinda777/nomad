# ADR 0001: Padrão de Registro de Decisões de Arquitetura (ADR)

* **Status:** Aceito
* **Data:** 2026-08-08
* **Autores:** Antigravity (IA), Govinda

## Contexto e Problema

Este projeto é um laboratório/curso prático de arquitetura multi-cloud resiliente (ativo-ativo) usando HashiCorp Nomad, Consul, WireGuard e CockroachDB. À medida que o projeto evolui com PoCs, infraestrutura simulada localmente e implantações na nuvem real, decisões de design complexas precisam ser tomadas e documentadas de forma transparente. Sem uma estrutura formal, o raciocínio por trás de escolhas críticas (como simulação local de latência e uso de Consensus Raft) se perderia.

## Decisão Consensual

Decidimos adotar a prática de **Architecture Decision Records (ADRs)** para registrar as decisões arquiteturais fundamentais do projeto.

As ADRs serão armazenadas no diretório `docs/adr/` sob as seguintes regras:
1. **Nomenclatura:** `<4-digitos-id>-<slug-da-decisao>.md` (ex: `0001-padrao-adrs.md`).
2. **Formato:** Markdown com seções claras para:
   - Título e Metadados (Status: Proposto/Aceito/Rejeitado/Superado, Data, Autor).
   - Contexto e Problema.
   - Decisão Consensual.
   - Consequências (Positivas e Negativas).
3. **Escopo:** Decisões que impactam o fluxo de desenvolvimento, estratégias de testes de caos, stacks tecnológicas e documentação integrada ao ecossistema de Agentes de IA.

## Consequências

### Positivas
* **Histórico de Raciocínio:** Facilita a compreensão do "porquê" de certas escolhas de design difíceis (ex: CockroachDB vs bancos tradicionais).
* **Alinhamento:** Garante consistência entre os desenvolvedores humanos e os Agentes de IA que operam no repositório.

### Negativas
* **Sobrecarga de Manutenção:** Requer esforço contínuo para atualizar ou marcar ADRs anteriores como "Superadas" à medida que novas escolhas substituem as antigas.
