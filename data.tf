# Debian 10 Buster
# Debian 10 Buster
data "aws_ami" "debian-10" {
  most_recent = true
  owners = ["136693071363"]
  filter {
    name   = "name"
    values = ["debian-10-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
# Debian 11 Bullseye
data "aws_ami" "debian-11" {
  most_recent = true
  owners = ["136693071363"]
  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_subnet_ids" "default" {
  vpc_id = aws_default_vpc.default.id
}

data "aws_subnet" "default" {
  id    = element(tolist(data.aws_subnet_ids.default.ids), 0)
}

### Locals

locals {

  terraform_version = var.terraform_version

  tags = {
    terraform_version = local.terraform_version
  }

}


