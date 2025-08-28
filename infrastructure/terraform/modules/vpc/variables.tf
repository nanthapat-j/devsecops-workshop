# Terraform Variables for VPC Module
# DevSecOps Workshop - Thai Market Ready

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones are required for high availability."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Retention period for VPC Flow Logs"
  type        = number
  default     = 30
  validation {
    condition     = var.flow_logs_retention_days >= 1 && var.flow_logs_retention_days <= 3653
    error_message = "Flow logs retention must be between 1 and 3653 days."
  }
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for cost optimization (dev only)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

# Thai Compliance Variables
variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "Sensitive"
  validation {
    condition     = contains(["Public", "Internal", "Sensitive", "Restricted"], var.data_classification)
    error_message = "Data classification must be Public, Internal, Sensitive, or Restricted."
  }
}

variable "compliance_framework" {
  description = "Compliance framework to adhere to"
  type        = string
  default     = "PDPA"
  validation {
    condition     = contains(["PDPA", "BOT", "SOC2", "ISO27001"], var.compliance_framework)
    error_message = "Compliance framework must be PDPA, BOT, SOC2, or ISO27001."
  }
}

variable "data_residency" {
  description = "Data residency requirement"
  type        = string
  default     = "ASEAN"
  validation {
    condition     = contains(["ASEAN", "Global", "Thailand"], var.data_residency)
    error_message = "Data residency must be ASEAN, Global, or Thailand."
  }
}