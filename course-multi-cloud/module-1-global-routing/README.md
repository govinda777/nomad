# Módulo 1: Fundamentos de Arquiteturas Ativo-Ativo e Roteamento Global

A primeira barreira de defesa contra a queda de um provedor de nuvem está muito antes dos pacotes chegarem aos seus servidores. Ela reside na **borda da internet (Edge)**.

## O Problema
Se sua aplicação está hospedada inteiramente na AWS (usando ELB, EC2, RDS) e a região `us-east-1` cai, seus usuários ficarão olhando para uma tela de erro. No modelo tradicional de *Disaster Recovery* (Ativo-Passivo), você precisaria subir a infraestrutura em outra região ou nuvem e atualizar os apontamentos DNS manualmente, o que leva minutos ou horas.

No modelo **Ativo-Ativo**, a aplicação já está rodando em duas (ou mais) nuvens simultaneamente. O desafio passa a ser: *Como dividimos o tráfego entre elas e como o sistema percebe que uma nuvem caiu para parar de enviar usuários para lá?*

## Conceitos Chave
1.  **DNS Global & Anycast**: Diferente de um DNS normal que retorna um único IP, roteadores globais podem retornar IPs diferentes baseados na localização física de quem pergunta (GeoDNS) ou da latência de rede (Latency-Based Routing).
2.  **Global Health Checks**: A provedora de DNS (ex: Cloudflare, AWS Route53) testa constantemente as pontas (seus Load Balancers na AWS e no GCP). Se a AWS parar de responder com HTTP 200, a borda remove a AWS do pool do DNS e joga 100% do tráfego para o GCP, instantaneamente.

## Exercício Prático (PoC Multi-Cloud)
Vamos simular dois Load Balancers representando as duas nuvens, e configurar regras de DNS com Health Checks para observar o failover ativo-ativo na prática.

**Passo 1**: Acione o Agente de IA para executar a SKILL de tráfego global.
*(Diga ao Agente: "Por favor, execute a SKILL de Global Traffic Manager para provisionar a PoC do Módulo 1")*

**Passo 2**: Verifique a resposta de tráfego rodando `curl`. O tráfego deve ser balanceado entre os endpoints.

**Passo 3**: Simule a queda do servidor primário (o Agente pode lhe ajudar a derrubar a instância via linha de comando).

**Passo 4**: Verifique novamente o roteamento, provando que nenhum usuário foi impactado pela queda da nuvem primária.
