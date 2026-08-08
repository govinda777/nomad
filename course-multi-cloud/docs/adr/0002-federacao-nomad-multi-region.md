# ADR 0002: Federação de Clusters Nomad vs Cluster Único Estendido para Multi-Cloud

* **Status:** Aceito
* **Data:** 2026-08-08
* **Autores:** Antigravity (IA), Govinda

## Contexto e Problema

Precisamos implantar uma infraestrutura de orquestração de containers que se estende por múltiplos provedores de nuvem (AWS e GCP). O protocolo de consenso utilizado pelos servidores do HashiCorp Nomad (Raft) exige latência extremamente baixa (< 10ms) para evitar perda de quorum e falhas na liderança do cluster. A latência de rede entre diferentes regiões e provedores de nuvem frequentemente excede esse limite, tornando inviável a criação de um único cluster Nomad estendido geograficamente.

## Decisão Consensual

Decidimos adotar a **Federação de Clusters Nomad Enterprise** em vez de um único cluster estendido:

1. **Clusters Independentes por Nuvem:** AWS e GCP possuirão seus próprios clusters Nomad autocontidos (cada um com seus próprios servidores e clientes, rodando Raft internamente).
2. **Federação RPC Assíncrona:** Conectaremos os clusters via RPC federado assíncrono. Isso remove a dependência do Raft entre as nuvens.
3. **Uso da Stanza `multiregion`:** Os deploys globais serão definidos em HCL usando `multiregion`, configurando políticas de `auto_revert` e `fail_local` para isolar falhas de deploy de forma independente por provedor.

## Consequências

### Positivas
* **Resiliência a Latência:** Instabilidades na conexão inter-cloud não causam quedas no plano de controle local de cada nuvem.
* **Isolamento de Falhas:** Um erro de deploy ou pane em uma nuvem não se propaga para a outra devido ao `fail_local`.

### Negativas
* **Complexidade Operacional:** Aumenta o custo administrativo, pois é necessário gerenciar e monitorar múltiplos painéis/control planes de Nomad.
