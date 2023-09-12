resource "aws_eip" "public_subnets_eip" {
  count = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name = "${var.stage}-${var.project_name}-eip"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidrs)
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(local.availability_zones, count.index)
  vpc_id = aws_vpc.main_vpc.id
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.stage}-${var.project_name}-public-subnet-${element(local.availability_zones, count.index)}"
  }
}

resource "aws_nat_gateway" "ngw" {
  count = length(var.public_subnet_cidrs)
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.public_subnets_eip.*.allocation_id, count.index)

  tags = {
    Name = "${var.stage}-${var.project_name}-ngw-${element(local.availability_zones, count.index)}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  count = length(var.public_subnet_cidrs)

  tags = {
    Name = "${var.stage}-${var.project_name}-public-rt-${element(local.availability_zones, count.index)}"
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
