
provider "aws"  {
      region = var.aws_region
      access_key = var.aws_access_key_id
      secret_key = var.aws_secret_access_key
}

resource "aws_vpc" "firstvpc" {
      cidr_block = "10.0.0.0/16"
      tags = {
            Name = "My First VPC"
      }
}