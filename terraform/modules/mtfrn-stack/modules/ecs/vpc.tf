resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "${var.stage}-${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "${var.stage}-${var.project_name}-igw"
  }
}

resource "aws_internet_gateway_attachment" "vpc_igw" {
  vpc_id = aws_vpc.main_vpc.id
  internet_gateway_id = aws_internet_gateway.igw.id
}
