job "api-global" {
  type = "service"

  # A diretiva multiregion é o núcleo da SKILL de Multi-Cluster Deployments
  multiregion {
    strategy {
      max_parallel = 1            # Atualiza uma região por vez (Canary)
      on_failure   = "fail_local" # Se GCP falhar, AWS continua intacta e não faz rollback
    }

    region "us-east" {
      count = 3
      datacenters = ["dc-aws"]
    }

    region "us-west" {
      count = 2
      datacenters = ["dc-gcp"]
    }
  }

  update {
    max_parallel      = 1
    auto_revert       = true # Voltar versão antiga na região com defeito
  }

  group "web" {
    task "app" {
      driver = "docker"
      config {
        image = "nginx:latest"
      }
      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
