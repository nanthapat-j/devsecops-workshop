# Security Variables for DevSecOps Workshop
# Comprehensive security configuration options

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_id" {
  description = "VPC ID where security resources will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
  default     = ""
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
  default     = []
}

# KMS Configuration
variable "enable_key_rotation" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = true
}

variable "key_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
  validation {
    condition     = var.key_deletion_window >= 7 && var.key_deletion_window <= 30
    error_message = "Key deletion window must be between 7 and 30 days."
  }
}

variable "key_usage" {
  description = "Intended use of the KMS key"
  type        = string
  default     = "ENCRYPT_DECRYPT"
  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY"], var.key_usage)
    error_message = "Key usage must be ENCRYPT_DECRYPT or SIGN_VERIFY."
  }
}

# WAF Configuration
variable "enable_waf" {
  description = "Enable AWS WAF Web ACL"
  type        = bool
  default     = true
}

variable "waf_rate_limit" {
  description = "Rate limit for WAF (requests per 5 minutes)"
  type        = number
  default     = 10000
  validation {
    condition     = var.waf_rate_limit >= 100 && var.waf_rate_limit <= 20000000
    error_message = "WAF rate limit must be between 100 and 20,000,000."
  }
}

variable "waf_blocked_countries" {
  description = "List of country codes to block in WAF"
  type        = list(string)
  default     = []
}

# Security Groups Configuration
variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = []
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed for HTTP/HTTPS access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# GuardDuty Configuration
variable "enable_guardduty" {
  description = "Enable AWS GuardDuty"
  type        = bool
  default     = true
}

variable "guardduty_finding_frequency" {
  description = "GuardDuty finding publishing frequency"
  type        = string
  default     = "FIFTEEN_MINUTES"
  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.guardduty_finding_frequency)
    error_message = "GuardDuty frequency must be FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

# Security Hub Configuration
variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = true
}

variable "security_hub_standards" {
  description = "List of Security Hub standards to enable"
  type        = list(string)
  default = [
    "aws-foundational-security-standard",
    "cis-aws-foundations-benchmark",
    "pci-dss"
  ]
}

# CloudTrail Configuration
variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_log_retention" {
  description = "CloudTrail log retention in days"
  type        = number
  default     = 90
  validation {
    condition     = var.cloudtrail_log_retention >= 1 && var.cloudtrail_log_retention <= 3653
    error_message = "CloudTrail log retention must be between 1 and 3653 days."
  }
}

variable "enable_cloudtrail_insights" {
  description = "Enable CloudTrail Insights"
  type        = bool
  default     = false  # Costs extra
}

# Config Configuration
variable "enable_config" {
  description = "Enable AWS Config"
  type        = bool
  default     = true
}

variable "config_delivery_frequency" {
  description = "AWS Config delivery frequency"
  type        = string
  default     = "TwentyFour_Hours"
  validation {
    condition = contains([
      "One_Hour", "Three_Hours", "Six_Hours", 
      "Twelve_Hours", "TwentyFour_Hours"
    ], var.config_delivery_frequency)
    error_message = "Invalid Config delivery frequency."
  }
}

# Notification Configuration
variable "enable_sns_notifications" {
  description = "Enable SNS notifications for security events"
  type        = bool
  default     = true
}

variable "notification_email" {
  description = "Email address for security notifications"
  type        = string
  default     = ""
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  default     = ""
  sensitive   = true
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
    condition     = contains(["PDPA", "BOT", "SOC2", "ISO27001", "PCI-DSS"], var.compliance_framework)
    error_message = "Compliance framework must be PDPA, BOT, SOC2, ISO27001, or PCI-DSS."
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

variable "enable_pdpa_compliance" {
  description = "Enable PDPA-specific compliance features"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}