provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_vpc" "demo_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "Demo VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "Demo IGW"
  }
}

resource "aws_route_table" "demo_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Demo Route Table"
  }
}

resource "aws_route_table_association" "demo_rt_assoc" {
  subnet_id      = aws_subnet.demo_subnet.id
  route_table_id = aws_route_table.demo_rt.id
}

resource "aws_subnet" "demo_subnet" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = "172.16.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "Demo Subnet"
  }
}

resource "aws_security_group" "demo_sg" {
  name        = "Demo-SG"
  description = "Security group"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "demo_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "demo_key_pair" {
  key_name   = "demo-key"
  public_key = tls_private_key.demo_key.public_key_openssh
}

resource "aws_instance" "demo_ec2" {
  ami                    = "ami-003034168dd454f47"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.demo_subnet.id
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  key_name               = aws_key_pair.demo_key_pair.key_name

  tags = {
    Name = "Demo Server"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> public_ip.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt -y update",
      "sudo apt install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.demo_key.private_key_pem
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'destroy' >> public_ip.txt"
  }
}
