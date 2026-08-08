# ADR 0004: Persistência Geodistribuída com CockroachDB e Nós de Arbitragem (Witness)

* **Status:** Aceito
* **Data:** 2026-08-08
* **Autores:** Antigravity (IA), Govinda

## Contexto e Problema

Em uma aplicação ativo-ativo que roda em múltiplos provedores de nuvem, a persistência de dados é o maior gargalo. Bancos de dados relacionais tradicionais dependem de replicação mestre-escravo, o que causa perda de dados (RPO > 0) ou indisponibilidade de escrita se o mestre cair. Precisamos de consistência forte e capacidade de sobrevivência a quedas completas de regiões sem perda de dados (RPO = 0, RTO de segundos).

## Decisão Consensual

Decidimos adotar o **CockroachDB (NewSQL)** estruturado com as seguintes especificidades de resiliência:

1. **Uso de Localities:** Configuração de zonas e localidades geográficas distintas correspondentes a cada nuvem (`cloud=aws,region=us-east-1` vs `cloud=gcp,region=us-east-1`).
2. **Nós de Arbitragem (Witness):** Como o consenso Raft exige maioria simples de votos para aceitar escritas (quórum ímpar, mínimo 3 nós), e temos apenas 2 nuvens, implantaremos um nó "Witness" (testemunha) em uma terceira localidade/provedor neutro (ex: infraestrutura local ou provedor alternativo leve). O nó Witness não guarda cópia de dados, apenas participa da votação.
3. **Prevenção de Split-Brain:** Se a conectividade entre a AWS e o GCP cair, a nuvem que conseguir formar quórum com o nó Witness continuará operando normalmente, enquanto a outra recusará escritas temporariamente, garantindo consistência estrita (Teorema CAP orientado a CP).

## Consequências

### Positivas
* **Consistência Forte:** Sem conflitos de replicação ou divergência de dados.
* **Sobrevivência a Desastres:** Queda completa da AWS ou do GCP permite failover automático de escrita sem intervenção manual.

### Negativas
* **Latência de Escrita Elevada:** Toda transação de escrita deve obter quórum geográfico, o que adiciona a latência de tráfego de rede inter-cloud ao tempo de commit.
