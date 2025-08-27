# DevSecOps Workshop - Infrastructure Security Module
# Main Terraform configuration for secure AWS infrastructure

terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  # Uncomment for remote state (recommended for production)
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "devsecops-workshop/terraform.tfstate"
  #   region         = "ap-southeast-1"
  #   dynamodb_table = "terraform-state-locks"
  #   encrypt        = true
  # }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region

  # Default tags for all resources
  default_tags {
    tags = {
      Project     = "DevSecOps-Workshop"
      Environment = var.environment
      Owner       = var.owner
      Workshop    = "Infrastructure-Security"
      CreatedBy   = "Terraform"
      # Thai specific tags
      Department  = var.department
      CostCenter  = var.cost_center
    }
  }
}

# Random suffix for globally unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# Local values for consistent naming
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    Workshop    = "DevSecOps"
  }
  
  # Thai market specific configuration
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  name               = "${local.name_prefix}-vpc"
  cidr               = var.vpc_cidr
  availability_zones = local.availability_zones
  
  # Enable security features
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_flow_logs     = true
  
  tags = local.common_tags
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"

  vpc_id      = module.vpc.vpc_id
  name_prefix = local.name_prefix
  
  tags = local.common_tags
}

# EKS Cluster Module
module "eks" {
  source = "./modules/eks"

  cluster_name    = "${local.name_prefix}-eks"
  cluster_version = var.eks_version
  
  vpc_id                = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnet_ids
  control_plane_subnet_ids = module.vpc.private_subnet_ids
  
  # Security hardening
  endpoint_private_access = true
  endpoint_public_access  = true
  endpoint_public_access_cidrs = var.allowed_public_cidrs
  
  # Enable security features
  enable_cluster_encryption = true
  kms_key_arn              = module.kms.cluster_key_arn
  
  # Logging configuration
  cluster_enabled_log_types = [
    "api",
    "audit", 
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  
  tags = local.common_tags
}

# RDS Module with encryption
module "rds" {
  source = "./modules/rds"

  identifier = "${local.name_prefix}-db"
  
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group_name
  security_group_ids   = [module.security_groups.rds_security_group_id]
  
  # Database configuration
  engine          = "postgres"
  engine_version  = "15.3"
  instance_class  = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
  
  db_name  = var.rds_db_name
  username = var.rds_username
  
  # Security features
  storage_encrypted     = true
  kms_key_id           = module.kms.rds_key_arn
  backup_retention_period = 7
  backup_window        = "03:00-04:00"
  maintenance_window   = "Sun:04:00-Sun:05:00"
  
  # Enhanced monitoring
  monitoring_interval = 60
  performance_insights_enabled = true
  
  # Network security
  publicly_accessible = false
  
  tags = local.common_tags
}

# KMS Module for encryption
module "kms" {
  source = "./modules/kms"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

# WAF Module for web application protection
module "waf" {
  source = "./modules/waf"

  name_prefix = local.name_prefix
  environment = var.environment
  
  # Thai market specific rules
  enable_geo_blocking = var.enable_geo_blocking
  allowed_countries   = var.allowed_countries
  
  tags = local.common_tags
}

# CloudTrail for audit logging
module "cloudtrail" {
  source = "./modules/cloudtrail"

  trail_name          = "${local.name_prefix}-cloudtrail"
  s3_bucket_name      = "${local.name_prefix}-cloudtrail-${random_id.suffix.hex}"
  kms_key_arn         = module.kms.cloudtrail_key_arn
  
  # Enhanced logging
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_log_file_validation   = true
  
  tags = local.common_tags
}

# Security Hub for centralized security findings
resource "aws_securityhub_account" "main" {
  enable_default_standards = true
}

# GuardDuty for threat detection
resource "aws_guardduty_detector" "main" {
  enable = true
  
  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }
  
  tags = local.common_tags
}