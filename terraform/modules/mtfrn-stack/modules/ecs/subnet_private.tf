resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidrs)
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(local.availability_zones, count.index)
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stage}-${var.project_name}-private-subnet-${element(local.availability_zones, count.index)}"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id
  count = length(var.public_subnet_cidrs)

  tags = {
    Name = "${var.stage}-${var.project_name}-private-rt-${element(local.availability_zones, count.index)}"
  }
}

resource "aws_route" "ngw_route" {
  count = length(var.public_subnet_cidrs)
  route_table_id = element(aws_route_table.private_rt.*.id, count.index)
  gateway_id = element(aws_nat_gateway.ngw.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_subnet_rt" {
  count = length(var.public_subnet_cidrs)
  route_table_id = element(aws_route_table.private_rt.*.id, count.index)
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
}
