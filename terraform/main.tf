terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.5.6"
}

resource "random_string" "uid" {
  length = 6
  special = false
}

provider "aws" {
  region = var.AWS_REGION

  default_tags {
    tags = {
      Project = "${var.project_name}-${random_string.uid.result}"
    }
  }
}

data "aws_availability_zones" "availability_zones" {
  state = "available"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_internet_gateway_attachment" "vpc_igw" {
  vpc_id = aws_vpc.main_vpc.id
  internet_gateway_id = aws_internet_gateway.igw.id
}

resource "aws_nat_gateway" "ngw" {
  count = length(var.public_subnet_cidrs)
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.public_subnets_eip.*.allocation_id, count.index)

  tags = {
    Name = "${var.project_name}-ngw-${element(data.aws_availability_zones.availability_zones.names, count.index)}"
  }
}

resource "aws_eip" "public_subnets_eip" {
  count = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidrs)
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.availability_zones.names, count.index)
  vpc_id = aws_vpc.main_vpc.id
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${element(data.aws_availability_zones.availability_zones.names, count.index)}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  count = length(var.public_subnet_cidrs)

  tags = {
    Name = "${var.project_name}-public-rt-${element(data.aws_availability_zones.availability_zones.names, count.index)}"
  }
}

resource "aws_route" "igw_route" {
  count = length(var.public_subnet_cidrs)
  route_table_id = element(aws_route_table.public_rt.*.id, count.index)
  gateway_id = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_subnet_rt" {
  count = length(var.public_subnet_cidrs)
  route_table_id = element(aws_route_table.public_rt.*.id, count.index)
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidrs)
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.availability_zones.names, count.index)
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}-private-subnet-${element(data.aws_availability_zones.availability_zones.names, count.index)}"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id
  count = length(var.public_subnet_cidrs)

  tags = {
    Name = "${var.project_name}-private-rt-${element(data.aws_availability_zones.availability_zones.names, count.index)}"
  }
}

resource "aws_route" "ngw_route" {
  count = length(var.public_subnet_cidrs)
  route_table_id = element(aws_route_table.private_rt.*.id, count.index)
  gateway_id = element(aws_nat_gateway.ngw.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_subnet_rt" {
  count = length(var.private_subnet_cidrs)
  route_table_id = element(aws_route_table.private_rt.*.id, count.index)
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
}