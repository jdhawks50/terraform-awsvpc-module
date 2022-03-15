terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "aws_vpc" {
    source = "github.com/jdhawks50/terraform-awsvpc-module"
    
    vpc_cidr_block = "172.23.0.0/16"
    public_subnet_count = 3
    private_subnet_count = 3
    vpc_name_tag = "jdhawks50-vpc"
    private_subnet_name_tag = "jdhawks50-public-subnet"
    public_subnet_name_tag = "jdhawks50-private-subnet"

    # Don't provision a NAT Gateway -- I am cheap and impatient.
    provision_nat_gateway = false

    # Public subnets will use AZs A, B and C
    public_subnet_az_override_list = ["a", "b", "c"]

    # When calculating the public subnet prefix length, extend the `local.public_supernet` value by this many bits.
    public_subnet_prefix_offset = 4

    # Private subnets will use AZs D, E and F
    private_subnet_az_override_list = ["d","e","f"]

    # When calculating the private subnet prefix length, extend the `local.private_supernet` value by this many bits.
    private_subnet_prefix_offset = 7

    default_tags = {
        "project" = "github.com/jdhawks50/terraform-awsvpc-module"
        "MyCoolTag" = "Tags Are Fun!"
    }
}