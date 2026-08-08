# Laboratório: Mesh Interconnect (Service Mesh Inter-Cloud)

Neste laboratório, você verá na prática como garantir que dois serviços possam conversar independentemente de onde estejam hospedados (AWS ou GCP), usando o HashiCorp Consul para aplicar mTLS (criptografia).

## Objetivos
1. Levantar dois servidores Consul representando nuvens diferentes.
2. Unir (federar) os servidores.
3. Observar a impossibilidade de comunicação insegura.

---

## Passo 1: Preparação (Acionando o Agente)
Invoque o Agente de IA com o seguinte prompt:
> *"Agente, ative a SKILL Mesh Interconnect. Gere a PoC via Docker subindo um Consul Primary (AWS) e um Secondary (GCP) federados via WAN."*

O Agente subirá os containers e usará o IP interno da rede Docker para simular o túnel WireGuard que conectaria fisicamente as duas instâncias no mundo real.

## Passo 2: Verificando a Federação
Acesse o terminal do seu host e execute:
```bash
docker exec -it consul-aws consul members -wan
```
Você deverá ver ambos os Data Centers listados (`dc-aws` e `dc-gcp`). Isso significa que a API de um Data Center conhece o estado do outro.

## Passo 3: O Desafio mTLS
No mundo real, quando configuramos o Envoy Proxy acoplado ao Consul, todas as portas padrão da sua aplicação são fechadas para a rede externa.
Se você tentasse fazer um `curl http://10.0.0.8:8080` de fora do ecossistema Consul, você tomaria *Connection Refused*, pois a porta física só aceita tráfego criptografado com o certificado TLS nativo do Mesh.
