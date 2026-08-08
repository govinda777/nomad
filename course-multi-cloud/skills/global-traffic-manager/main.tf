terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {}

# Mocks para as nuvens (Dois containers NGINX simples que retornarão textos diferentes)
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "mock_aws" {
  image = docker_image.nginx.image_id
  name  = "lb-mock-aws"
  ports {
    internal = 80
    external = 8081
  }
  upload {
    file = "/usr/share/nginx/html/index.html"
    content = "Resposta do Load Balancer AWS\n"
  }
}

resource "docker_container" "mock_gcp" {
  image = docker_image.nginx.image_id
  name  = "lb-mock-gcp"
  ports {
    internal = 80
    external = 8082
  }
  upload {
    file = "/usr/share/nginx/html/index.html"
    content = "Resposta do Load Balancer GCP\n"
  }
}

# (Nota: Em um cenário real, aqui entraria o recurso aws_route53_health_check
# e aws_route53_record ou regras de proxy do Cloudflare. Para simplificar a PoC local,
# usaremos um load balancer HAProxy local como 'borda global')
