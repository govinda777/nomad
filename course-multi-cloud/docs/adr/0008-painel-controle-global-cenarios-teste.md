# ADR 0008: Painel de Controle Global para Automação de Cenários de Teste e Monitoramento

* **Status:** Aceito
* **Data:** 2026-08-08
* **Autores:** Antigravity (IA), Govinda

## Contexto e Problema

O curso possui 5 módulos práticos contendo cenários complexos (failover de DNS, federação de service mesh, split-brain e injeção de caos de rede). Para validar e experimentar esses cenários, o aluno precisa alternar entre múltiplos terminais, rodar comandos manuais de Docker e ler logs brutos. Essa fricção operacional reduz o tempo focado em conceitos de arquitetura distribuída. É necessário ter uma interface visual centralizada que permita orquestrar os testes e visualizar o comportamento dinâmico do ecossistema.

## Decisão Consensual

Decidimos desenvolver um **Painel de Controle Global** baseado em uma interface web interativa:

1. **Arquitetura da Aplicação:**
   - Um serviço web Node.js leve servindo uma página single-page application (SPA) moderna e premium (com design dark-mode, glassmorphism e animações).
   - O painel será executado em um container Docker compartilhando o socket `/var/run/docker.sock` do host, permitindo que ele interaja diretamente com as APIs do Docker para monitorar a saúde dos containers e iniciar/parar serviços e cenários de testes dos módulos.

2. **Cenários de Teste Unificados (One-Click Scenarios):**
   - A interface web oferecerá botões para acionar os cenários descritos nos laboratórios práticos (ex: "Derrubar AWS Region", "Simular Latência WAN", "Curar Rede").
   - O painel executará os scripts `./sandbox.sh test` correspondentes no backend e transmitirá os logs em tempo real para o usuário.

3. **Integração com Observabilidade:**
   - A interface exibirá links diretos e painéis incorporados para o Consul UI, Nomad UI, Cockroach Console e dashboards do Grafana.

## Consequências

### Positivas
* **Experiência Visual Excepcional:** Alunos conseguem "ver" o desastre acontecer visualmente com um clique, facilitando o aprendizado.
* **Consolidação de Ferramentas:** Uma única porta centraliza o acesso a todas as UIs da infraestrutura (Nomad, Consul, Cockroach, Grafana).

### Negativas
* **Dependência do Docker Socket:** O painel requer acesso ao `/var/run/docker.sock`, o que exige atenção extra quanto a permissões de execução locais.
