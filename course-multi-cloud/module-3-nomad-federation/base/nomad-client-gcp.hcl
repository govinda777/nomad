region     = "us-west"
datacenter = "dc-gcp"
data_dir   = "/nomad/data"

client {
  enabled = true
  servers = ["nomad-server-gcp:4647"]
}

ports {
  http = 4646
}

bind_addr = "0.0.0.0"
