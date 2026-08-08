# ADR 0003: Conectividade Segura Inter-Cloud via WireGuard e Consul Federation

* **Status:** Aceito
* **Data:** 2026-08-08
* **Autores:** Antigravity (IA), Govinda

## Contexto e Problema

Os clusters do Nomad localizados no GCP e na AWS precisam de comunicação segura de baixa latência para service discovery de microsserviços cruzados e sincronização do control plane. Expor os IPs públicos das instâncias ou usar túneis VPN tradicionais de provedores de nuvem pode ser caro, complexo e expor portas críticas à internet pública.

## Decisão Consensual

Decidimos estabelecer uma rede overlay segura inter-cloud utilizando uma combinação de:

1. **WireGuard Site-to-Site:** Configuração de túneis VPN ponto a ponto em nível de kernel usando WireGuard para criptografar todo o tráfego de rede inter-cloud sem a sobrecarga de protocolos pesados como IPsec.
2. **Consul Federation com mTLS:** Federação dos clusters Consul de cada nuvem através da rede overlay criada pelo WireGuard. A comunicação entre os serviços será controlada por políticas de intenção (Consul Intentions) e criptografada via mTLS nativo na Service Mesh.

## Consequências

### Positivas
* **Segurança Zero-Trust:** Nenhuma porta do Nomad, Consul ou CockroachDB precisa ser exposta publicamente.
* **Performance:** WireGuard opera no kernel do Linux, oferecendo throughput superior e menor latência comparado a soluções em user-space.

### Negativas
* **Gerenciamento de Chaves:** A troca e rotação de chaves públicas/privadas do WireGuard precisa ser gerenciada (automatizada via Ansible neste projeto).
