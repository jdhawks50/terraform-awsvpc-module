locals {
  public_supernet = cidrsubnet(var.vpc_cidr_block, 1, 0)
  private_supernet = cidrsubnet(var.vpc_cidr_block, 1, 1)
  az_number = data.aws_region.current.name == "us-east-1" ? [
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
  ] : [
    "a",
    "b",
    "c",
  ]
  
  static_az_names_list = [
    for az in local.az_number : format("%s%s", data.aws_region.current.name, az)
  ]

  private_az_override = length(var.private_subnet_az_override_list) > 0 ? [ 
    for az in range(0, length(var.private_subnet_az_override_list)) : format("%s%s", data.aws_region.current.name, element(var.private_subnet_az_override_list, az))
  ] : []

  public_az_override = length(var.public_subnet_az_override_list) > 0 ? [ 
    for az in range(0, length(var.public_subnet_az_override_list)) : format("%s%s", data.aws_region.current.name, element(var.public_subnet_az_override_list, az))
  ] : []
}

variable "public_subnet_az_override_list" {
  type = list(string)
  default = []
}

variable "private_subnet_az_override_list" {
  type = list(string)
  default = []
}

variable "vpc_cidr_block" {
  type = string
  default = "172.22.0.0/16"
}
variable "public_subnet_count" {
  type = number
  default = 2
}

variable "private_subnet_count" {
  type = number
  default = 3
}

variable "vpc_name_tag" {
  type = string
  default = "my-vpc"
}

variable "private_subnet_name_tag" {
  type = string
  default = "private-subnet"
}

variable "public_subnet_name_tag" {
  type = string
  default = "public-subnet"
}

variable "public_subnet_prefix_offset" {
  type = number
  default = 0
}
variable "private_subnet_prefix_offset" {
  type = number
  default = 0
}

variable "public_subnet_map_public_ip_on_launch" {
  type = bool
  default = true
}

variable "provision_nat_gateway" {
  type = bool
  default = true
}