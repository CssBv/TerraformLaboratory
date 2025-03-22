# Reference Docker provider
terraform {
      required_providers {
        docker = {
            source = "kreuzwerker/docker"
            version = "3.0.2"
        }
      }    
}

provider "docker" {}

resource "docker_network" "private_network" {
      name = "cluster-network"

      ipam_config {
            subnet = "192.168.1.0/24"
            gateway = "192.168.1.1"
      }
}

resource "docker_image" "ubuntu"{
      name = "ubuntu:latest"
}

# Create first Ubuntu container 
resource "docker_container" "ubuntu-container" {
      image = docker_image.ubuntu.image_id
      name = "ubuntu-container-1"

      # Keep the container running
      command = ["sleep", "infinity"]

      networks_advanced {
            name = docker_network.private_network.name
      }
}

# Create second Ubuntu container 
resource "docker_container" "ubuntu-container-2" {
      image = docker_image.ubuntu.image_id
      name = "ubuntu-container-2"

      # Keep the container running
      command = ["sleep", "infinity"]

      networks_advanced {
            name = docker_network.private_network.name
      }
}







