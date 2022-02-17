output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
    value = tolist(aws_subnet.public_subnet.*.id)
}
output "private_subnet_ids" {
    value = tolist(aws_subnet.private_subnet.*.id)
}

output "natgw_ip" {
    value = var.provision_nat_gateway ? aws_eip.natgw[0].public_ip  : ""
}

output "public_subnet_availability_zones" {
  value = local.public_az_override
}

output "private_subnet_availability_zones" {
  value = local.private_az_override
}