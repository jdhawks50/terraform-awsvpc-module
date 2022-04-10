variable "public_subnet_availability_zones" {
  type = list(string)
  default = []
}

variable "private_subnet_availability_zones" {
  type = list(string)
  default = []
}

variable "vpc_cidr_block" {
  type = string
  default = "172.22.0.0/16"
}
variable "public_subnet_count" {
  type = number
  default = 3
}

variable "private_subnet_count" {
  type = number
  default = 3
}

variable "vpc_name_tag_prefix" {
  type = string
  default = "vpc"
}

variable "private_subnet_name_tag_prefix" {
  type = string
  default = "private-subnet"
}

variable "public_subnet_name_tag_prefix" {
  type = string
  default = "public-subnet"
}

variable "public_subnet_prefix_offset" {
  type = number
  default = 7
}
variable "private_subnet_prefix_offset" {
  type = number
  default = 7
}

variable "public_subnet_map_public_ip_on_launch" {
  type = bool
  default = true
}

variable "provision_nat_gateway" {
  type = bool
  default = true
}

variable "public_route_table_name_tag_prefix" {
  type = string
  default = "route-table"
}
variable "private_route_table_name_tag_prefix" {
  type = string
  default = "route-table"
}

variable "create_dhcp_options" {
  type = bool
  default = false
}

variable "vpc_dhcp_option_domain_name" {
  type = string
  default = "ec2.internal"
}
variable "vpc_dhcp_option_domain_name_servers" {
  type = list(string)
  default = ["AmazonProvidedDNS"]
}
variable "vpc_dhcp_option_ntp_servers" {
  type = list(string)
  default = []
}
variable "vpc_dhcp_option_netbios_name_servers" {
  type = list(string)
  default = []
}
variable "vpc_dhcp_option_netbios_node_type" {
  type = string
  default = ""
}

variable "enable_dns_support" {
  type = bool
  default = true
}

variable "enable_dns_hostnames" {
  type = bool
  default = true
}