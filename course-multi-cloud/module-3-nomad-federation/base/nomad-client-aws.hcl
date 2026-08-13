region     = "us-east"
datacenter = "dc-aws"
data_dir   = "/nomad/data"

client {
  enabled = true
  servers = ["nomad-server-aws:4647"]
}

ports {
  http = 4646
}

bind_addr = "0.0.0.0"
