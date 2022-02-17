# Terraform VPC Module

## What gets created
- 1 VPC
- A configurable amount of private subnets (subnets that route to the internet via NAT Gateway)
- A configurable amount of public subnets (subnets that route to the internet via Internet Gateway)
- 1 NAT Gateway if desired.
- 1 EIP for the NAT Gateway.
- Route tables and route table associations.

## Features
- Configurable VPC CIDR block
- Configurable `default_tags`
- Configurable number of public and private subnets
    - Public Subnets have a mandatory internet gateway
    - Private subnets have an optional NAT Gateway
- Optional NAT Gateway creation
- Configurable subnet Availability Zone placement
- Configurable subnet offset, allowing you to customize what prefix length your subnets have
- Makes efficient use of the VPC cidr space:
    - VPC CIDR block is divided in half; ie. a /24 becomes 2 /25 subnets.
    - Prefix length for subnets is determined by `*_subnet_prefix_offset` variable

## Variables

`public_subnet_az_override_list`: A list of AZ lettered-identifiers, ie. `["a","b","c"]`

`private_subnet_az_override_list`: same as above

`vpc_cidr_block`: the CIDR block assigned to the VPC

`public_subnet_count`: number of public subnets

`private_subnet_count`: number of private subnets

`vpc_name_tag`: the `Name` tag value on the VPC

`public_subnet_name_tag`: the `Name` tag value on the public subnet

`private_subnet_name_tag`: the `Name` tag value on the private subnet

`public_subnet_map_public_ip_on_launch`: true or false, weather the public subnet will map public IPs on instance launch.

### Prefix Offset Examples
Suppose your VPC CIDR block is 172.23.0.0/16.

The Public Supernet will be calculated as 172.23.0.0/17
The Private Supernet will be caulcated as 172.23.128.0/17

If the variable `private_subnet_prefix_offset` == 7, then all subnets will have prefix lengths of 17 + 7 == 24. So all subnets will have a /24 netmask that is a subnet of the Private Supernet.

If the variable `public_subnet_prefix_offset` == 4, then all subnets will have prefix lengths of 17 + 4 == 21. So all subnets will have a /21 netmask that is a subnet of the Private Supernet.

Given the above parameters, if the `public_subnet_count` == 3, then we will have 3 subnets numbering:
- 172.23.0.0/21
- 172.23.8.0/21
- 172.23.16.0/21

If the `private_subnet_count` == 3, then we will have 3 subnets numbering:
- 172.23.128.0/24
- 172.23.129.0/24
- 172.23.130.0/24