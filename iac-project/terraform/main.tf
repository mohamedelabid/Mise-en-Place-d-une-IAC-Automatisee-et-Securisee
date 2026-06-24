terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "iac_net" {
  name = "iac-network"
  ipam_config {
    subnet  = "192.168.56.0/24"
    gateway = "192.168.56.1"
  }
}

resource "docker_image" "ubuntu_ssh" {
  name         = "ubuntu-ssh:22.04"
  keep_locally = true
}

resource "docker_container" "web" {
  name     = "web-server"
  image    = docker_image.ubuntu_ssh.image_id
  must_run = true
  restart  = "always"
  networks_advanced {
    name         = docker_network.iac_net.name
    ipv4_address = "192.168.56.10"
  }
  ports {
    internal = 22
    external = 2210
  }
  ports {
    internal = 80
    external = 8080
  }
}

resource "docker_container" "app" {
  name     = "app-server"
  image    = docker_image.ubuntu_ssh.image_id
  must_run = true
  restart  = "always"
  networks_advanced {
    name         = docker_network.iac_net.name
    ipv4_address = "192.168.56.11"
  }
  ports {
    internal = 22
    external = 2211
  }
  ports {
    internal = 3000
    external = 3000
  }
}

resource "docker_container" "db" {
  name     = "db-server"
  image    = docker_image.ubuntu_ssh.image_id
  must_run = true
  restart  = "always"
  networks_advanced {
    name         = docker_network.iac_net.name
    ipv4_address = "192.168.56.12"
  }
  ports {
    internal = 22
    external = 2212
  }
  ports {
    internal = 5432
    external = 5432
  }
}

resource "docker_container" "zabbix" {
  name     = "zabbix-server"
  image    = "zabbix/zabbix-appliance:latest"
  must_run = true
  restart  = "always"
  networks_advanced {
    name         = docker_network.iac_net.name
    ipv4_address = "192.168.56.20"
  }
  ports {
    internal = 80
    external = 8090
  }
  ports {
    internal = 10051
    external = 10051
  }
  env = [
    "ZBX_SERVER_HOST=192.168.56.20",
    "PHP_TZ=Africa/Casablanca"
  ]
}
