output "vpc" {
  description = "Main VPC details (ID, name, CIDR block, etc.)"
  value       = aws_vpc.main.id
}

output "public_subnets_id" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public_subnet.*.id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}
