provider "aws" {
	region = var.aws_region
	access_key = var.aws_access_key_id
	secret_key = var.aws_secret_access_key
}

resource "aws_vpc" "demo_vpc" {
	cidr_block = "172.17.0.0/16"

	tags = {
		Name = "Demo VPC"
	}
}

resource "aws_internet_gateway" "demo_igw" {
	vpc_id = aws_vpc.demo_vpc.id

	tags = {
		Name = "Demo Internet Gateway"
	}
}

resource "aws_default_route_table" "demo_default_route" {
	default_route_table_id = aws_vpc.demo_vpc.default_route_table_id

	tags = {
		Name = "Demo Default Route"
	}

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.demo_igw.id
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

resource "aws_instance" "demo_ec2" {
	vpc_security_group_ids = [aws_security_group.demo_sg.id]

	tags = {
		Name = "Demo Server"
	}

	subnet_id = aws_subnet.demo_subnet.id
	instance_type = "t2.micro"
	ami = "ami-000672b48f97f5c94"
}
