# 🚀 Curso: Desenvolvimento e Arquitetura de Aplicações Ativo-Ativo Multi-Cloud
*(Versão: HashiCorp Nomad Federation & Resiliência Avançada)*

![](./docs/assets/Central_de_Logística_de_Infraestrutura.png)


Bem-vindo ao curso definitivo sobre resiliência inter-cloud. Este projeto é estritamente **prático (PoC-driven)** e desenhado para ensinar como construir sistemas que sobrevivem a falhas totais de regiões ou provedores de nuvem inteiros.



## 🎯 Objetivo
Abordar os fundamentos de arquiteturas distribuídas, focando nas limitações do Teorema CAP (latência da luz) e como orquestradores modernos lidam com estado através de múltiplas nuvens.

Utilizaremos uma stack open-source focada na HashiCorp:
* **Orquestração:** Nomad Enterprise (Federated Clusters & Multi-Region Jobs)
* **Rede & Segurança:** Consul (Service Discovery, mTLS) & WireGuard
* **Camada de Dados:** CockroachDB (Raft Consenso Geográfico)
* **Provisionamento:** Terraform e Ansible

---

## 📚 Estrutura dos Módulos

### [Módulo 1: Fundamentos de Arquiteturas Ativo-Ativo e Roteamento Global](./module-1-global-routing/)
* Redirecionamento na borda.
* DNS Anycast, GeoDNS, Latency-Based Routing.
* Prova de Conceito: Terraform provisionando Health Checks globais no Route53/Cloudflare isolando tráfego de nuvens "caídas".

### [Módulo 2: Conectividade, ACLs e RPC Inter-Cloud](./module-2-mesh-network/)
* Unindo regiões de forma segura.
* WireGuard para túneis Site-to-Site.
* Consul Federation (Replicação de estado, mTLS sem IPs públicos expostos).
* Prova de Conceito: Conectando VPCs da AWS e GCP (ou instâncias locais simuladas) via rede Overlay.

### [Módulo 3: Orquestração Multi-Cluster com Nomad Enterprise](./module-3-nomad-federation/)
* Lidando com as restrições do Consenso Raft (~10ms limit).
* Single Cluster vs Federated Clusters.
* `multiregion` stanza, Two-Phase Job Submission.
* Prova de Conceito: Deploy Multi-Region com `auto_revert` e `fail_local` para rollbacks independentes por nuvem.

### [Módulo 4: Persistência e Consistência de Dados Multi-Cloud](./module-4-distributed-data/)
* Bancos NewSQL e Consistência Forte.
* CockroachDB: Localities e nós de Arbitragem (Witness).
* Prova de Conceito: Simulando um Split-Brain e comprovando que não há perda de dados em trânsito.

### [Módulo 5: Caos, Resiliência e Cascading Failures](./module-5-chaos-engineering/)
* O "Game Day" da infraestrutura.
* Monitoramento isolado das nuvens de carga.
* Prova de Conceito: Injeção de regras de firewall (DROP) simulando a queda de um Data Center inteiro (Cascading Failure stress test).

---

## 🤖 A Matriz de SKILLs (Agent-Driven Learning)

Este curso é **Skill-Based**. Isso significa que existe um `AGENTS.md` na raiz do projeto orientando a Inteligência Artificial que acompanha este repositório. O Agente de IA possui capacidades (Skills) escritas em Terraform e Ansible para subir rapidamente a infraestrutura de suporte para você.

O objetivo **não é** que você gaste 10 horas configurando chaves SSH, mas sim que o Agente suba as PoCs para que você possa focar em arquitetura, testar limites de latência e brincar de "Engenheiro do Caos" derrubando servidores.

Verifique a pasta `/skills` para ver os templates de infraestrutura gerenciados pelo Agente.

---

## 🏛️ Decisões de Arquitetura (ADRs)

Decisões fundamentais sobre desenvolvimento, testes e documentação são documentadas usando registros estruturados. Consulte o índice de decisões em:
* [Registro de ADRs (Architecture Decision Records)](file:///Users/govinda/projetos/nomad/course-multi-cloud/docs/adr/README.md)

