terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = var.default_tags
  }
}