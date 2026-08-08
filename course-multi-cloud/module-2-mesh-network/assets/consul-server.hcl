datacenter = "dc-aws"
data_dir = "/opt/consul"
bind_addr = "0.0.0.0"

# O 'primary_datacenter' é crucial para a replicação de ACLs e a emissão
# de certificados globais na Federação.
primary_datacenter = "dc-aws"

server = true
bootstrap_expect = 3

ui_config {
  enabled = true
}

connect {
  enabled = true
}

# Define as portas padrões. 8302 é usada para WAN Gossip (Inter-Cloud)
ports {
  grpc = 8502
  serf_lan = 8301
  serf_wan = 8302
}

# Ativação do Mesh Gateway. Sem isso, os Envoys de um Data Center
# não conseguem rotear pacotes para Envoys de outro Data Center de forma transparente.
mesh_gateway {
  enabled = true
}