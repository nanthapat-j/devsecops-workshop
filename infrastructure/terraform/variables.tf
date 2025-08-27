# DevSecOps Workshop - Infrastructure Variables
# Thai market focused configuration variables

variable "aws_region" {
  description = "AWS region for resources (recommended: ap-southeast-1 for Thailand)"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devsecops-workshop"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "DevSecOps-Team"
}

# Thai market specific variables
variable "department" {
  description = "Department name (for Thai organizations)"
  type        = string
  default     = "IT-Security"
}

variable "cost_center" {
  description = "Cost center for billing (Thai organization structure)"
  type        = string
  default     = "CC-DevSecOps"
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "allowed_public_cidrs" {
  description = "CIDR blocks allowed to access EKS public endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Restrict this for production!
}

# EKS Configuration
variable "eks_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "node_instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.medium", "t3.large"]
}

variable "node_desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_capacity" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 10
}

variable "node_min_capacity" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

# RDS Configuration
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage (GB)"
  type        = number
  default     = 20
}

variable "rds_db_name" {
  description = "RDS database name"
  type        = string
  default     = "ecommerce"
}

variable "rds_username" {
  description = "RDS master username"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

# Security Configuration
variable "enable_geo_blocking" {
  description = "Enable geographic blocking in WAF"
  type        = bool
  default     = false
}

variable "allowed_countries" {
  description = "Allowed countries for WAF (ISO 3166-1 alpha-2 codes)"
  type        = list(string)
  default     = ["TH", "SG", "US"]  # Thailand, Singapore, US
}

# Monitoring Configuration
variable "enable_enhanced_monitoring" {
  description = "Enable enhanced monitoring for RDS"
  type        = bool
  default     = true
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
}

# Backup Configuration
variable "backup_retention_period" {
  description = "Backup retention period for RDS (days)"
  type        = number
  default     = 7
  
  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 1 and 35 days."
  }
}

# Thai Compliance Configuration
variable "enable_pdpa_compliance" {
  description = "Enable PDPA (Personal Data Protection Act) compliance features"
  type        = bool
  default     = true
}

variable "data_residency_requirement" {
  description = "Require data to remain in Thailand (for PDPA compliance)"
  type        = bool
  default     = true
}

variable "enable_audit_logging" {
  description = "Enable comprehensive audit logging"
  type        = bool
  default     = true
}

# Cost Optimization
variable "enable_cost_optimization" {
  description = "Enable cost optimization features (spot instances, scheduled scaling)"
  type        = bool
  default     = true
}

variable "business_hours_start" {
  description = "Business hours start (24h format, Thailand timezone)"
  type        = string
  default     = "08:00"
}

variable "business_hours_end" {
  description = "Business hours end (24h format, Thailand timezone)"
  type        = string
  default     = "18:00"
}

# Security Features
variable "enable_secrets_encryption" {
  description = "Enable encryption for secrets and sensitive data"
  type        = bool
  default     = true
}

variable "enable_network_flow_logs" {
  description = "Enable VPC Flow Logs for network monitoring"
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = true
}

variable "enable_guardduty" {
  description = "Enable AWS GuardDuty"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable AWS Config for compliance monitoring"
  type        = bool
  default     = true
}

# Application Configuration
variable "application_environments" {
  description = "List of application environments to create"
  type        = list(string)
  default     = ["dev", "staging"]
}

variable "enable_blue_green_deployment" {
  description = "Enable blue-green deployment capability"
  type        = bool
  default     = true
}

# Database Configuration
variable "enable_multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
  default     = false  # Set to true for production
}

variable "enable_performance_insights" {
  description = "Enable Performance Insights for RDS"
  type        = bool
  default     = true
}

# Thai Banking Sector Specific
variable "banking_compliance_mode" {
  description = "Enable banking sector compliance features (BOT guidelines)"
  type        = bool
  default     = false
}

variable "require_encryption_in_transit" {
  description = "Require encryption in transit for all communications"
  type        = bool
  default     = true
}

variable "require_encryption_at_rest" {
  description = "Require encryption at rest for all storage"
  type        = bool
  default     = true
}

# Emergency Access
variable "emergency_access_accounts" {
  description = "List of AWS account IDs that can access resources in emergency"
  type        = list(string)
  default     = []
}

variable "enable_break_glass_access" {
  description = "Enable break-glass access for emergency situations"
  type        = bool
  default     = false
}