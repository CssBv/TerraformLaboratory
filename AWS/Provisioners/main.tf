provider "aws" {
      region = var.aws_region
      access_key = var.aws_access_key_id
      secret_key = var.aws_secret_access_key
}

resource "aws_vpc" "demo_vpc" {
      cidr_block = "172.16.0.0/16"

      tags {
            Name = "Demo VPC"
      }

} 

resource "aws_internet_gateway" "igw" {
      vpc_id = aws_vpc.DemoVPC.id

      tags {
            Name = "Demo IGW"
      }

      route {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.igw.id
      }
}

resource "aws_subnet" "demo_subnet" {
      vpc_id = aws_vpc.demo_vpc.id
      cidr_block = "172.17.1.0/24"
      map_public_ip_on_launch = true
      availability_zone = "${var.aws_region}a"

      
      tags = {
	      Name = "Demo Subnet"
	}
}

resource "aws_security_group" "demo_sg" {
	name = "Demo-SG"
	description = "Security group"
	vpc_id = aws_vpc.demo_vpc.id

	ingress {
		from_port   = 0
		to_port     = 0
		protocol    = -1
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port   = 0
		to_port     = 0
		protocol    = -1
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "tls_private_key" "demo_key" {
      algorithm = "RSA"
      rsa_bits = 4096
}

resource "aws_key_pair" "demo_pair" {
      key_name = "demo-key"
      public_key = tls_private_key.demo_key.public_key_openssh
}