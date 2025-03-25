# Reference Docker provider
terraform {
      required_providers {
        docker = {
            source = "kreuzwerker/docker"
            version = "3.0.2"
        }
      }    
}

provider docker {}

# Extract bin action
resource "null_resource" "extract_bin" {
      triggers = {
            always_run = "${timestamp()}"
      }

      provisioner "local-exec" {
            command = <<EOT
                  cd ${path.module}/Files &&
                  sh nso-6.2.11.container-image-build.linux.x86_64.signed.bin
                  EOT
      }
}

# Docker load action on previously extracted NSO file
resource "null_resource" "load_image" {
      depends_on = [null_resource.extract_bin]

      provisioner "local-exec" {
            command = <<EOT
                  cd ${path.module}/Files &&
                  gunzip -c nso-6.2.11.container-image-build.linux.x86_64.tar.gz | docker load
            EOT
      }
}

resource "docker_container" "nso_6_2_container"{
      name = "nso_container"
      image = "cisco-nso-build:6.2.11"

      ports {
            internal = 80
            external = 8080
      }
      depends_on = [null_resource.load_image]

      # Keep the container running
      command = ["sleep", "infinity"]
}



