variable "ami_name" {
  type    = string
  default = "dev-tools-week4-hw"
}

locals {
  ami_id         = "ami-0fed77069cd5a6d6c"

  instance_type  = "t2.micro"
}

resource "aws_key_pair" "terraform-keys" {
  key_name = "terraform-keys"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdFL3F7puWNRnXItMBzLn0AnM4cCZZiGiVRtDSMyVZfrZlK1Sd+NJuU2TVxQCdsI9Va92OOiMePdEuJbFj/F2k4akG9UbG/cypn6JxoL2W8QVzwSw91Mmn0dWQg84/2fs/dHPUAbCk2sM8v2B8G1Zw1vy6rlbe1WsTbPIp+XzkCg5CanY6OtkR5Jo+E6/9AiDwL4zhDQqcPLFVJrJBnDLfhO0twmhTPSmckj1kuzbHlc2GoqIe1q8ZK6ijGDRumsC/syxh8uq4GP3yn7nU39LG2b/i2NHiRgClvqIcSrb5ZzmY1GMp7XJEBw8blejNTbOgWAuTsn6fuV+ute4xeXgp"
}

resource "aws_vpc" "vpc-week4" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "week4-hw"
  }
}

resource "aws_eip" "ip-week4-hw" {
  instance = aws_instance.app-week4-hw.id
  vpc      = true
}

resource "aws_subnet" "subnet-uno" {
  cidr_block = cidrsubnet(aws_vpc.vpc-week4.cidr_block, 3, 1)
  vpc_id = aws_vpc.vpc-week4.id
  availability_zone = "ap-southeast-1a"
}

resource "aws_route_table" "app-route-table" {
  vpc_id = aws_vpc.vpc-week4.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-gw.id
  }
  tags = {
    Name = "app-route-table"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.subnet-uno.id
  route_table_id = aws_route_table.app-route-table.id
}

resource "aws_internet_gateway" "app-gw" {
  vpc_id = aws_vpc.vpc-week4.id
  tags = {
    Name = "app-gw"
  }
}

resource "aws_security_group" "ingress-one-only" {
  name = "allow-one-ip-only-sg"
  vpc_id = aws_vpc.vpc-week4.id

  ingress {
    cidr_blocks = ["180.129.87.181/32"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app-week4-hw" {
  ami             = local.ami_id
  instance_type   = local.instance_type
  key_name        = aws_key_pair.terraform-keys.key_name
  security_groups = [aws_security_group.ingress-one-only.id]
  
  tags = {
    Name = var.ami_name
  }

  subnet_id = aws_subnet.subnet-uno.id
}