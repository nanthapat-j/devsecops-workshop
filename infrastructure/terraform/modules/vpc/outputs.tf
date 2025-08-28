# Terraform Outputs for VPC Module
# DevSecOps Workshop - Thai Market Ready

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_default_security_group_id" {
  description = "ID of the default security group"
  value       = aws_vpc.main.default_security_group_id
}

output "vpc_default_network_acl_id" {
  description = "ID of the default network ACL"
  value       = aws_vpc.main.default_network_acl_id
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "ARNs of the public subnets"
  value       = aws_subnet.public[*].arn
}

output "public_subnet_cidr_blocks" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_arns" {
  description = "ARNs of the private subnets"
  value       = aws_subnet.private[*].arn
}

output "private_subnet_cidr_blocks" {
  description = "CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "database_subnet_arns" {
  description = "ARNs of the database subnets"
  value       = aws_subnet.database[*].arn
}

output "database_subnet_group_id" {
  description = "ID of the database subnet group"
  value       = aws_db_subnet_group.main.id
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = aws_db_subnet_group.main.name
}

# Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "internet_gateway_arn" {
  description = "ARN of the Internet Gateway"
  value       = aws_internet_gateway.main.arn
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "nat_gateway_network_interface_ids" {
  description = "Network interface IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].network_interface_id
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

output "database_route_table_id" {
  description = "ID of the database route table"
  value       = aws_route_table.database.id
}

# Security Outputs
output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = var.enable_flow_logs ? aws_flow_log.main[0].id : null
}

output "vpc_flow_log_cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for VPC Flow Logs"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.vpc_flow_log[0].name : null
}

# Compliance Outputs
output "compliance_tags" {
  description = "Compliance tags applied to resources"
  value = {
    DataClassification    = var.data_classification
    ComplianceFramework  = var.compliance_framework
    DataResidency        = var.data_residency
    Environment          = var.environment
  }
}

output "availability_zones" {
  description = "Availability zones used"
  value       = var.availability_zones
}

# Cost Optimization Outputs
output "nat_gateway_cost_optimization" {
  description = "NAT Gateway configuration for cost optimization"
  value = {
    single_nat_gateway = var.single_nat_gateway
    nat_gateway_count  = var.single_nat_gateway ? 1 : length(var.availability_zones)
    estimated_monthly_cost_usd = var.single_nat_gateway ? 45 : (45 * length(var.availability_zones))
  }
}

# Network Configuration Summary
output "network_summary" {
  description = "Summary of network configuration"
  value = {
    vpc_cidr             = var.vpc_cidr
    public_subnets       = length(aws_subnet.public)
    private_subnets      = length(aws_subnet.private)
    database_subnets     = length(aws_subnet.database)
    availability_zones   = length(var.availability_zones)
    nat_gateways        = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0
    flow_logs_enabled   = var.enable_flow_logs
  }
}