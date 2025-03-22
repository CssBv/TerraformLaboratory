
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

# Pulls Ubuntu image
resource "docker_image" "ubuntu"{
      name = "ubuntu:latest"
}

# Create Ubuntu container 
resource "docker_container" "ubuntu-container" {
      image = docker_image.ubuntu.image_id
      name = "ubuntu-container"

      # Keep the container running
      command = ["sleep", "infinity"]
}
