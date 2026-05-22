output "vpc_id" {
  value = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
}

output "vpc_cidr_block" {
  value = var.create_vpc ? aws_vpc.this[0].cidr_block : var.vpc_cidr
}

output "traffic_destination_logs" {
  value = var.create_flow_log ? aws_flow_log.this[0].log_destination : ""
}