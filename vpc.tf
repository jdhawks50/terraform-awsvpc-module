resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.vpc_name_tag}"
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
  availability_zone       = length(local.public_az_override) > 0 ? element(local.public_az_override, count.index) : element(local.static_az_names_list, count.index)
  map_public_ip_on_launch = var.public_subnet_map_public_ip_on_launch ? "true" : "false"
  tags = {
    Name = "${var.public_subnet_name_tag}-${count.index}"
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
  availability_zone       = length(local.private_az_override) > 0 ? element(local.private_az_override, count.index) : element(local.static_az_names_list, count.index)
  map_public_ip_on_launch = "false"
  tags = {
    Name = "${var.private_subnet_name_tag}-${count.index}"
  }
}

resource "aws_route_table" "public_subnet" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "default-route-table"
  }
}

resource "aws_route_table" "private_subnet" {
  vpc_id = aws_vpc.vpc.id

  route = [
    (
      var.provision_nat_gateway ? {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natgw[0].id
        carrier_gateway_id         = ""
        destination_prefix_list_id = ""
        egress_only_gateway_id     = ""
        gateway_id                 = ""
        instance_id                = ""
        ipv6_cidr_block            = ""
        local_gateway_id           = ""
        nat_gateway_id             = ""
        network_interface_id       = ""
        transit_gateway_id         = ""
        vpc_endpoint_id            = ""
        vpc_peering_connection_id  = ""
      } : {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = ""
        carrier_gateway_id         = ""
        destination_prefix_list_id = ""
        egress_only_gateway_id     = ""
        gateway_id                 = aws_internet_gateway.igw.id
        instance_id                = ""
        ipv6_cidr_block            = ""
        local_gateway_id           = ""
        nat_gateway_id             = ""
        network_interface_id       = ""
        transit_gateway_id         = ""
        vpc_endpoint_id            = ""
        vpc_peering_connection_id  = ""
      }
    )
  ]
}

resource "aws_route_table_association" "private_subnets" {
  count =  var.private_subnet_count > 0 ? var.private_subnet_count : 0
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_subnet.id
}

resource "aws_route_table_association" "public_subnets" {
  count =  var.public_subnet_count > 0 ? var.public_subnet_count : 0
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_subnet.id
}