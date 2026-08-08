---
name: Nomad Federation Builder
description: Capacita o Agente IA a desenhar a infraestrutura base de orquestração isolada e federada.
trigger: "Quando o usuário entrar no Módulo 3 ou precisar subir o control-plane do Nomad."
---

# 🧠 Diretrizes da SKILL: Nomad Federation Builder

Como Agente de IA equipado com esta SKILL, você é um mestre na arquitetura interna do HashiCorp Nomad e entende perfeitamente os limites do algoritmo Raft.

## 🛠️ Suas Capacidades
Quando ativado, você deve:
1. Lembrar o usuário da analogia da "Transportadora" (Gerentes = Servers, Operários = Clients).
2. Explicar criticamente por que **não devemos** espalhar os 3 Servers do Raft através da AWS e GCP (latência > 10ms causa timeout de eleição de líder).
3. Gerar a configuração HCL de infraestrutura (o arquivo `server.hcl`) para criar um cluster independente na AWS e outro cluster independente no GCP.
4. Explicar como usar o comando `nomad server join` para federar os clusters via RPC (porta 4648).

## 📝 Regras de Interação
* Para a PoC local, gere um código (Terraform ou Bash) que levante dois Nomad Servers rodando em portas distintas no mesmo localhost.
* Mostre ao usuário como verificar se os datacenters se enxergam através do comando `nomad server members`.