job "global-nginx" {
  type = "service"

  # Multiregion stanza for multi-cloud deployment
  multiregion {
    strategy {
      max_parallel = 1
      on_failure   = "fail_local"
    }

    region "us-east" {
      count       = 1
      datacenters = ["dc-aws"]
    }

    region "us-west" {
      count       = 1
      datacenters = ["dc-gcp"]
    }
  }

  group "web" {
    network {
      port "http" {
        to = 80
      }
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:alpine"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
