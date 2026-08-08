terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {}

# Mocks para o Módulo 2: Simulando dois datacenters locais com HashiCorp Consul para Service Mesh
resource "docker_image" "consul" {
  name         = "hashicorp/consul:1.15"
  keep_locally = false
}

# Consul simulando a AWS (Primary Datacenter)
resource "docker_container" "consul_aws" {
  image = docker_image.consul.image_id
  name  = "consul-aws"
  command = ["agent", "-server", "-bootstrap-expect=1", "-ui", "-datacenter=dc-aws", "-client=0.0.0.0"]
  ports {
    internal = 8500
    external = 8500 # UI e API para AWS
  }
}

# Consul simulando o GCP (Secondary Datacenter)
# Em um cenário real, eles se comunicariam via túnel WireGuard/WAN.
resource "docker_container" "consul_gcp" {
  image = docker_image.consul.image_id
  name  = "consul-gcp"
  command = [
    "agent", "-server", "-bootstrap-expect=1", "-ui",
    "-datacenter=dc-gcp",
    "-retry-join-wan=${docker_container.consul_aws.network_data[0].ip_address}", # WAN Join Mock
    "-client=0.0.0.0"
  ]
  ports {
    internal = 8500
    external = 8501 # UI e API para GCP
  }
}
