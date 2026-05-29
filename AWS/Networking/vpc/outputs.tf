output "vpc_id" {
  description = "VPC ID."
  value       = local.vpc_id
}

output "vpc_cidr_block" {
  description = "Primary VPC CIDR block."
  value       = local.vpc_cidr_block
}

output "availability_zones" {
  description = "Availability zones used by the module."
  value       = local.availability_zones
}

output "internet_gateway_id" {
  description = "Internet Gateway ID, if created."
  value       = try(aws_internet_gateway.this[0].id, null)
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs."
  value       = aws_nat_gateway.this[*].id
}

output "nat_gateway_public_ips" {
  description = "Public IPs assigned to NAT Gateways."
  value       = aws_eip.nat[*].public_ip
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = aws_subnet.private[*].id
}

output "isolated_subnet_ids" {
  description = "Isolated subnet IDs."
  value       = aws_subnet.isolated[*].id
}

output "public_subnet_cidr_blocks" {
  description = "Public subnet CIDR blocks."
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidr_blocks" {
  description = "Private subnet CIDR blocks."
  value       = aws_subnet.private[*].cidr_block
}

output "isolated_subnet_cidr_blocks" {
  description = "Isolated subnet CIDR blocks."
  value       = aws_subnet.isolated[*].cidr_block
}

output "public_route_table_ids" {
  description = "Public route table IDs."
  value       = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  description = "Private route table IDs."
  value       = aws_route_table.private[*].id
}

output "isolated_route_table_ids" {
  description = "Isolated route table IDs."
  value       = aws_route_table.isolated[*].id
}

output "traffic_destination_logs" {
  description = "VPC Flow Log destination, if enabled."
  value       = var.create_flow_log ? aws_flow_log.this[0].log_destination : ""
}
