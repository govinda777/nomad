region     = "us-west"
datacenter = "dc-gcp"
data_dir   = "/nomad/data"

server {
  enabled          = true
  bootstrap_expect = 1
}

ports {
  http = 4646
  rpc  = 4647
  serf = 4648
}

bind_addr = "0.0.0.0"
