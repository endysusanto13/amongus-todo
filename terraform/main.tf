variable "ami_name" {
  type    = string
  default = "capstone-devtools"
}

locals {
  ami_id         = "ami-0fed77069cd5a6d6c"

  instance_type  = "t2.micro"
}

resource "aws_key_pair" "terraform-keys" {
  key_name = "terraform-keys"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6a+uPuIm383pp+64qj0wqEK2RZiS+8pVLXroNJ/RlHonoecs2xfsHj+BkoJ/jIpKnzXsq1j/7IMnJcBiYqMeaOOXMaD0Rla95E1uI+u7X/WsCYp6nEd1TGJ99DaHfUwCWveXXbJvVuAeYQpJaX2S7TKMY6Z/qqqTpLo0g3cPC7B4vRc31eGNM/5sDkBlj6lJCOsZpK8MNehCRR3OfrimnUhf58PBtWJPq49yHZ4pSODSyGofsy+TK/tNZDl3T0lpsOWXhhcns06SyMIVhaR+nQQ7x68SrDAyz4WbcDJmNmq76DZCDRD4HrXA9pXMEw7CzDuiEsmHt0ZFqIvkrWSr7"
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "vpc-capstone-devtools"
  }
}

resource "aws_eip" "this" {
  instance = aws_instance.this.id
  vpc      = true
}

resource "aws_subnet" "subnet-uno" {
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 3, 1)
  vpc_id = aws_vpc.this.id
  availability_zone = "ap-southeast-1a"
}

resource "aws_route_table" "app-route-table" {
  vpc_id = aws_vpc.this.id

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
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "app-gw"
  }
}

resource "aws_security_group" "ingress-one-only" {
  name = "allow-one-ip-only-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    cidr_blocks = ["180.129.87.181/32", "20.106.72.79/32"]
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

resource "aws_instance" "this" {
  ami             = local.ami_id
  instance_type   = local.instance_type
  key_name        = aws_key_pair.terraform-keys.key_name
  security_groups = [aws_security_group.ingress-one-only.id]
  
  tags = {
    Name = var.ami_name
  }

  subnet_id = aws_subnet.subnet-uno.id
}