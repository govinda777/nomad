terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "cockroachdb" {
  name         = "cockroachdb/cockroach:v23.1.5"
  keep_locally = false
}

# Nó simulando estar na AWS
resource "docker_container" "crdb_aws" {
  image = docker_image.cockroachdb.image_id
  name  = "crdb-aws"
  command = [
    "start", "--insecure",
    "--locality=cloud=aws,region=us-east-1",
    "--join=crdb-aws,crdb-gcp,crdb-azure"
  ]
  ports {
    internal = 26257
    external = 26257
  }
}

# Nó simulando estar na GCP
resource "docker_container" "crdb_gcp" {
  image = docker_image.cockroachdb.image_id
  name  = "crdb-gcp"
  command = [
    "start", "--insecure",
    "--locality=cloud=gcp,region=us-west1",
    "--join=crdb-aws,crdb-gcp,crdb-azure"
  ]
}

# Nó Witness simulando estar na Azure (Árbitro para quorum Raft)
resource "docker_container" "crdb_azure_witness" {
  image = docker_image.cockroachdb.image_id
  name  = "crdb-azure"
  command = [
    "start", "--insecure",
    "--locality=cloud=azure,region=centralus",
    "--join=crdb-aws,crdb-gcp,crdb-azure"
  ]
}
