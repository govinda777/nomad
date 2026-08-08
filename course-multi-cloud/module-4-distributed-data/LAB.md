# Laboratório: Global Consensus DB (Sobrevivendo ao Split-Brain)

Vamos provar que é possível ter consistência forte de banco de dados através da internet pública espalhando um Banco NewSQL (CockroachDB) entre 3 nuvens, utilizando nós do tipo Witness (Árbitros).

## Objetivos
1. Criar um Cluster DB entre: AWS, GCP e Azure.
2. Inserir dados.
3. Simular a morte bruta do banco Primário.
4. Recuperar o dado no secundário sem corrupção.

---

## Passo 1: O Quorum (Acionando o Agente)
Invoque o Agente de IA:
> *"Agente, ative a SKILL Global Consensus DB. Use Docker para simular três nós (AWS, GCP e Azure Witness) formando um cluster CockroachDB com localidades isoladas."*

## Passo 2: Inserção Distribuída
Uma vez que o cluster suba, conecte no nó da AWS (`localhost:26257`) usando um cliente SQL e insira o dado (o Agente pode gerar o script bash para injetar no container, basta pedir a ele).

O dado bate no banco AWS, mas para ser confirmado para sua aplicação, o Raft empurra o voto para os nós no GCP e Azure. Como precisam ser 2 votos de 3, assim que a Azure confirmar, o usuário vê "Success", mesmo se o GCP estiver um pouco atrasado.

## Passo 3: O Teste de Sangue
Derrube (mate o processo/container) agressivamente o nó da AWS.
Se fôssemos uma arquitetura de banco legado Ativo-Passivo, estaríamos no chão. Se fosse uma replicação Master-Master assíncrona, teríamos perdido o dado do Passo 2.

## Passo 4: A Prova
Conecte-se agora ao container da GCP (`localhost:26258`).
Rode um `SELECT` na tabela. Você verá o dado perfeitamente íntegro!
O cluster usou o nó da Azure (Witness) para desempatar, reconheceu a morte da AWS, e promoveu o nó GCP para líder de leitura e escrita temporário.