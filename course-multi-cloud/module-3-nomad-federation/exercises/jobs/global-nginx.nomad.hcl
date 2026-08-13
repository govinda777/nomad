job "global-nginx" {
  type = "service"

  # TODO: Configure the multiregion block to deploy on both us-east (dc-aws) and us-west (dc-gcp)
  # Hint: Use the "multiregion" stanza, configure "strategy", and define each region block.
  # Set 'on_failure' to 'fail_local' to isolate deployment issues per cloud region.

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
