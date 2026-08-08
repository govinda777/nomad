# Módulo 4: Persistência e Consistência de Dados Multi-Cloud

Com os pacotes sendo roteados (DNS) e nossas aplicações distribuídas de forma segura e orquestrada (Nomad e Consul), enfrentamos o "Chefe Final" de sistemas distribuídos: **O Banco de Dados**.

## O Problema do Teorema CAP e a Velocidade da Luz
Imagine que um usuário faz uma transação na nuvem da AWS. O banco de dados salva a transação e diz "OK". Milissegundos depois, o Load Balancer manda o próximo acesso do usuário para a nuvem GCP. Se a transação não foi replicada a tempo para o GCP, o usuário verá o estado antigo.

1. Se usarmos **Replicação Síncrona**: O banco da AWS precisa esperar o banco do GCP confirmar o recebimento do dado antes de dizer "OK" para a aplicação. Como a internet tem latência física limitante, as requisições ficarão incrivelmente lentas e a aplicação pode até falhar por timeout de conexão.
2. Se usarmos **Replicação Assíncrona**: A AWS responde "OK" rápido, mas há risco real de perda de dados (*Split-Brain* e conflitos) caso as nuvens percam contato entre si.

## A Solução: Bancos NewSQL e Consciência Topológica

Para aplicações modernas e críticas em arquiteturas distribuídas, usamos bancos *NewSQL* nativos em nuvem, como o **CockroachDB**. Ele é baseado no protocolo Raft (assim como o Nomad).

Mas como ele resolve a latência sem perder consistência?
1. **Localities e Zonas de Sobrevivência**: Dizemos ao CockroachDB exatamente onde cada máquina está (ex: `--locality=cloud=aws`).
2. O dado é escrito no banco AWS e, em paralelo, tenta fazer cópia em outros nós. Ele **não** precisa esperar todas as nuvens confirmarem. Ele precisa de uma **maioria (Quorum)**.
3. **Nós Árbitros (Witness)**: Para que as nuvens AWS e GCP não parem de responder caso a comunicação entre as duas falhe, podemos instalar um "Nó Leve" numa terceira nuvem (ex: Azure) cuja única função é desempatar votos (aprovar ou rejeitar que uma nuvem assuma a liderança dos dados).

## Mapa de Arquitetura (CockroachDB Raft Quorum)

```mermaid
graph TD
    App([Aplicação na AWS])

    subgraph CRDB Cluster Global
        AWS_Node[(Nó AWS <br/> Leitura/Escrita)]
        GCP_Node[(Nó GCP <br/> Réplica)]
        Azure_Witness((Nó Witness <br/> Azure - Árbitro))
    end

    App -->|INSERT INTO ...| AWS_Node
    AWS_Node -->|Sincronização Raft <br/> (Precisa de aprovação de 2 de 3)| GCP_Node
    AWS_Node -->|Confirmação de Quorum| Azure_Witness

    Azure_Witness -.->|Aprova| AWS_Node
    GCP_Node -.->|Pode atrasar <br/> sem travar o cluster| AWS_Node

    style AWS_Node fill:#ff9900,stroke:#333
    style GCP_Node fill:#4285f4,stroke:#333
    style Azure_Witness fill:#00a4ef,stroke:#333
```

## Exercício Prático (PoC)

O Agente IA levantará um mini cluster CockroachDB local simulando nuvens distintas usando labels.

**Passo 1**: Acione o Agente para executar a `[SKILL: Global Consensus DB]`.

**Passo 2**: O Agente criará o banco e fará algumas inserções de dados.

**Passo 3**: O Agente fará um "kill" (forçará a queda) de um dos nós primários.

**Passo 4**: Execute um script de leitura SQL. Você verá que os dados persistem e o cluster não sofreu *Split-Brain*.
