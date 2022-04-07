locals {
  public_supernet = cidrsubnet(var.vpc_cidr_block, 1, 0)
  private_supernet = cidrsubnet(var.vpc_cidr_block, 1, 1)
}

data "aws_availability_zones" "availability_zones" {
  count =  length(var.public_subnet_availability_zones) == 0 || length(var.private_subnet_availability_zones) == 0  ? 1 : 0
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Shuffle the AZ list for funsies
resource "random_shuffle" "availability_zones" {
  count =  length(var.public_subnet_availability_zones) == 0 || length(var.private_subnet_availability_zones) == 0  ? 1 : 0
  input = data.aws_availability_zones.availability_zones[count.index].names
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.vpc_name_tag_prefix}vpc/${var.vpc_cidr_block}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_nat_gateway" "natgw" {
  count = var.private_subnet_count > 0 ? (var.provision_nat_gateway ? 1 : 0) : 0
  subnet_id     = aws_subnet.public_subnet[count.index].id
  allocation_id = aws_eip.natgw[count.index].id
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_eip" "natgw" {
  count = var.provision_nat_gateway ? 1 : 0
  vpc = true
  depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "public_subnet" {
  count = var.public_subnet_count > 0 ? var.public_subnet_count : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(
    local.public_supernet, 
    (var.public_subnet_prefix_offset > 0 ? var.public_subnet_prefix_offset : var.public_subnet_count), 
    count.index
  )
  availability_zone       = length(var.public_subnet_availability_zones) > 0 ? element(var.public_subnet_availability_zones, count.index) : element(random_shuffle.availability_zones[0].result, count.index)
  map_public_ip_on_launch = var.public_subnet_map_public_ip_on_launch ? "true" : "false"
  tags = {
    Name = "${var.public_subnet_name_tag_prefix}subnet/${cidrsubnet(local.public_supernet, (var.public_subnet_prefix_offset > 0 ? var.public_subnet_prefix_offset : var.public_subnet_count), count.index)}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = var.private_subnet_count > 0 ? var.private_subnet_count : 0
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(
    local.private_supernet, 
    (var.private_subnet_prefix_offset > 0 ? var.private_subnet_prefix_offset : var.private_subnet_count), 
    count.index
  )
  availability_zone       = length(var.private_subnet_availability_zones) > 0 ? element(var.private_subnet_availability_zones, count.index) : element(random_shuffle.availability_zones[0].result, count.index)
  map_public_ip_on_launch = "false"
  tags = {
    Name = "${var.private_subnet_name_tag_prefix}subnet/${cidrsubnet(local.private_supernet, (var.private_subnet_prefix_offset > 0 ? var.private_subnet_prefix_offset : var.private_subnet_count), count.index)}"
  }
}

resource "aws_route_table" "public_subnet" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.public_route_table_name_tag_prefix}route-table/public"
  }
}

resource "aws_route_table" "private_subnet" {
  count  = var.provision_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw[count.index].id
  }
  
  tags = {
    Name = "${var.private_route_table_name_tag_prefix}route-table/private"
  }
}

resource "aws_route_table_association" "private_subnets" {
  count =  var.private_subnet_count > 0 ? var.private_subnet_count : 0
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = var.provision_nat_gateway ? aws_route_table.private_subnet[0].id : aws_route_table.public_subnet.id
}

resource "aws_route_table_association" "public_subnets" {
  count =  var.public_subnet_count > 0 ? var.public_subnet_count : 0
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_subnet.id
}