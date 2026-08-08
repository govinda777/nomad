job "backend-api" {
  type = "service"

  # A configuração multiregion permite submeter um arquivo único que gerenciará
  # infraestrutura em nuvens distintas, sem precisar de um CICD duplicado.
  multiregion {
    strategy {
      max_parallel = 1
      on_failure   = "fail_local"
    }

    # Especifica que queremos instâncias na AWS
    region "aws-us-east" {
      count = 5
      datacenters = ["dc1"]
      meta { target = "aws-rds-db" }
    }

    # E simultaneamente na GCP
    region "gcp-us-west" {
      count = 3
      datacenters = ["dc2"]
      meta { target = "gcp-cloud-sql" }
    }
  }

  update {
    max_parallel      = 1
    # Se quebrar, reverta para a versão anterior. Crucial para resiliência Ativo-Ativo.
    auto_revert       = true
  }

  group "web" {
    task "api" {
      driver = "docker"
      config {
        image = "minha-empresa/api:v2.0"
        ports = ["http"]
      }
      resources {
        cpu    = 250
        memory = 512
      }
    }
  }
}