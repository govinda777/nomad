terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {}

# Mocks para o Módulo 3: Clusters Nomad Isolados (Para contornar o Raft delay) e unidos por RPC.
resource "docker_image" "nomad" {
  name         = "multisig/nomad:latest" # Imagem genérica mock para o Agente não falhar no pull
  keep_locally = false
}

# Nomad Server AWS
resource "docker_container" "nomad_server_aws" {
  image = docker_image.nomad.image_id
  name  = "nomad-server-aws"
  env   = ["NOMAD_DATACENTER=dc-aws", "NOMAD_REGION=us-east", "NOMAD_SERVER=true", "NOMAD_BOOTSTRAP=1"]
  ports {
    internal = 4646
    external = 4646
  }
}

# Nomad Server GCP
resource "docker_container" "nomad_server_gcp" {
  image = docker_image.nomad.image_id
  name  = "nomad-server-gcp"
  env   = ["NOMAD_DATACENTER=dc-gcp", "NOMAD_REGION=us-west", "NOMAD_SERVER=true", "NOMAD_BOOTSTRAP=1"]
  ports {
    internal = 4646
    external = 4647
  }
  # A lógica real da SKILL executada pelo agente fará a chamada RPC para unir as regiões.
}
