# Módulo 3: Orquestração Multi-Cluster com Nomad Enterprise

Para orquestrar cargas de trabalho em múltiplas nuvens sem explodir a complexidade de operação, usamos o **HashiCorp Nomad**. Diferente de Kubernetes (que possui dependências externas pesadas como ETCD), o Nomad é projetado para ser leve e suportar **Federação Nativa** de múltiplas regiões.

---

## 🚚 Entendendo o Nomad (Analogia Prática)

Para entender de forma prática e visual, imagine o Nomad como a **central de logística de uma transportadora**:

1. Os **Nomad Servers** são os **gerentes** no escritório central. Eles sabem quais encomendas (aplicações) precisam ser entregues e distribuídas, mas não carregam peso físico.
2. Os **Nomad Clients** são os **operários e galpões** espalhados. Eles têm o espaço físico (recursos de CPU e memória) e fazem o trabalho prático de carregar e executar as suas aplicações.

Aqui está o passo a passo de como você coloca essa estrutura de pé e hospeda aplicações nela:

---

### Passo 1: Como você coloca o Nomad para rodar (A Infraestrutura)

Diferente de outros orquestradores complexos, o Nomad é apenas **um único arquivo binário** executável (`nomad`). Você não precisa instalar dezenas de microsserviços adicionais ou bancos de dados para fazê-lo funcionar.

1. **Você cria as suas máquinas (físicas ou virtuais)**: Por exemplo, você pode subir 5 máquinas virtuais na nuvem (usando Terraform ou manualmente).
2. **Você baixa e instala o mesmo binário do Nomad em todas elas**.
3. **Você define o papel de cada máquina** em um arquivo de configuração simples (`.hcl`):
   * Nas máquinas **01, 02 e 03**, você configura e inicia o Nomad em **modo Server**. Elas vão conversar entre si usando o algoritmo de consenso *Raft* para formar o "cérebro" e plano de controle do cluster.
   * Nas máquinas **04 e 05**, você configura e inicia o Nomad em **modo Client**. Elas vão se conectar de forma automática aos Servers e avisar: *"Estamos online e temos X de CPU e Y de memória livres para uso"*.

---

### Passo 2: Como as aplicações são hospedadas (O Fluxo de Trabalho)

Para hospedar as suas aplicações, você não precisa acessar cada servidor e configurar tudo na mão. Você escreve um arquivo de texto simples chamado **Job Specification (jobspec)** usando a linguagem declarativa HCL.

Esse arquivo de configuração define o estado desejado da sua aplicação e segue uma estrutura hierárquica bem direta:

* **Job**: O nome do seu projeto ou serviço geral (ex: `"meu-site"`).
* **Group**: Um conjunto de tarefas que **precisam rodar obrigatoriamente juntas na mesma máquina** (co-localizadas).
* **Task**: O processo real que você quer rodar (seu container ou executável). É aqui que você define o **driver** ideal, como Docker, Java ou binários puros.

#### Exemplo de arquivo de aplicação (`site.nomad.hcl`):
```hcl
job "meu-site" {
  datacenters = ["dc1"]
  type        = "service" # Define que é um serviço web contínuo

  group "web" {
    count = 2 # O Nomad vai garantir que 2 cópias idênticas dessa aplicação rodem no cluster

    task "nginx" {
      driver = "docker" # Instrução para rodar como container

      config {
        image = "nginx:alpine" # Imagem que será baixada do Docker Hub
      }

      resources {
        cpu    = 100 # Reserva 100 MHz de CPU
        memory = 128 # Reserva 128 MB de RAM
      }
    }
  }
}
```

---

### Passo 3: O comando que coloca tudo no ar

Com o arquivo salvo no seu computador de desenvolvimento, você interage com o cluster enviando o job pelo terminal:

```bash
nomad job run site.nomad.hcl
```

### 🧠 O que acontece por trás dos panos?

1. **O recebimento**: O comando envia a definição do job em HCL para os **Nomad Servers**.
2. **O planejamento**: Os Servers interpretam a especificação: *"Preciso rodar 2 cópias de um container Docker do Nginx, consumindo no máximo 128MB de RAM cada"*.
3. **A decisão de posicionamento (Scheduling)**: O Server consulta o estado atual dos **Clients**, verifica quais têm espaço livre de recursos e decide onde as tarefas vão rodar.
4. **O envio da tarefa**: O Server envia uma instrução (chamada de **alocação**) para as máquinas Client escolhidas.
5. **A execução local**: O agente do Nomad em cada um dos Clients escolhidos recebe a ordem, comunica-se com o Docker local instalado no sistema, faz o download da imagem e inicia o container.
6. **A auto-recuperação**: O Nomad monitora continuamente a saúde da sua aplicação. Se uma das máquinas Client sofrer uma falha física ou perder energia, o Server detectará o problema e automaticamente recriará as aplicações afetadas em outro Client saudável.

---

## 🌍 O Desafio Multi-Cloud: Constraints do Raft e Federação

Quando expandimos isso para o cenário Multi-Cloud (ex: AWS e GCP ao mesmo tempo), o algoritmo *Raft* (usado pelos Nomad Servers para tomar as decisões de scheduling que lemos acima) exige que os Servers tenham **latência muito baixa (< 10ms)** entre eles.

Como não podemos garantir menos de 10ms entre AWS e GCP, **não podemos colocar Servers de nuvens diferentes no mesmo cluster Raft**. A solução é a **Federação**:
1. Criamos um cluster isolado (Servers + Clients) na AWS.
2. Criamos outro cluster isolado (Servers + Clients) no GCP.
3. Federamos ambos. Assim, a comunicação administrativa via RPC é permitida, e usamos a diretiva `multiregion` nos jobs (Enterprise) para despachar aplicações globais, mantendo rollbacks (`auto_revert`) isolados caso uma das nuvens sofra falhas durante a atualização!

**Exercício PoC**: Fale com o Agente para ativar a SKILL `[SKILL: Nomad Federation Builder]` e depois implemente a SKILL `[SKILL: Multi-Region Job Operator]` para observar os servidores das duas nuvens gerenciando cargas descentralizadas.