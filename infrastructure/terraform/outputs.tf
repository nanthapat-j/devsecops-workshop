# DevSecOps Workshop - Infrastructure Outputs
# Important information for connecting applications and monitoring

# VPC Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = module.vpc.database_subnet_ids
}

# EKS Cluster Information
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "eks_cluster_version" {
  description = "The Kubernetes version for the cluster"
  value       = module.eks.cluster_version
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "eks_oidc_issuer_url" {
  description = "The URL of the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "eks_node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = module.eks.node_group_arn
}

# Database Information
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.db_instance_port
}

output "rds_database_name" {
  description = "RDS database name"
  value       = module.rds.db_instance_name
}

output "rds_username" {
  description = "RDS instance master username"
  value       = module.rds.db_instance_username
  sensitive   = true
}

output "rds_arn" {
  description = "RDS instance ARN"
  value       = module.rds.db_instance_arn
}

# Security Information
output "kms_cluster_key_arn" {
  description = "ARN of the KMS key used for EKS cluster encryption"
  value       = module.kms.cluster_key_arn
}

output "kms_rds_key_arn" {
  description = "ARN of the KMS key used for RDS encryption"
  value       = module.kms.rds_key_arn
}

output "kms_cloudtrail_key_arn" {
  description = "ARN of the KMS key used for CloudTrail encryption"
  value       = module.kms.cloudtrail_key_arn
}

output "security_group_eks_cluster_id" {
  description = "Security group ID for EKS cluster"
  value       = module.security_groups.eks_cluster_security_group_id
}

output "security_group_eks_nodes_id" {
  description = "Security group ID for EKS worker nodes"
  value       = module.security_groups.eks_nodes_security_group_id
}

output "security_group_rds_id" {
  description = "Security group ID for RDS"
  value       = module.security_groups.rds_security_group_id
}

# WAF Information
output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = module.waf.web_acl_arn
}

output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = module.waf.web_acl_id
}

# CloudTrail Information
output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = module.cloudtrail.cloudtrail_arn
}

output "cloudtrail_s3_bucket" {
  description = "S3 bucket name for CloudTrail logs"
  value       = module.cloudtrail.s3_bucket_name
}

# Region and Account Information
output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

# kubectl Configuration Command
output "kubectl_config_command" {
  description = "Command to configure kubectl for this EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

# Application Connection Information
output "application_config" {
  description = "Configuration information for applications"
  value = {
    database = {
      host     = module.rds.db_instance_endpoint
      port     = module.rds.db_instance_port
      database = module.rds.db_instance_name
      username = module.rds.db_instance_username
    }
    kubernetes = {
      cluster_name = module.eks.cluster_name
      endpoint     = module.eks.cluster_endpoint
      region       = var.aws_region
    }
    security = {
      waf_web_acl_arn = module.waf.web_acl_arn
      kms_keys = {
        cluster    = module.kms.cluster_key_arn
        rds        = module.kms.rds_key_arn
        cloudtrail = module.kms.cloudtrail_key_arn
      }
    }
  }
  sensitive = true
}

# Monitoring Endpoints
output "monitoring_config" {
  description = "Monitoring configuration for Prometheus and Grafana"
  value = {
    cloudwatch_log_groups = [
      "/aws/eks/${module.eks.cluster_name}/cluster",
      "/aws/rds/instance/${module.rds.db_instance_identifier}/postgresql"
    ]
    cloudtrail_s3_bucket = module.cloudtrail.s3_bucket_name
    security_hub_arn     = "arn:aws:securityhub:${var.aws_region}:${data.aws_caller_identity.current.account_id}:hub/default"
  }
}

# Cost Information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown (USD)"
  value = {
    eks_cluster    = "72.00"  # $0.10/hour * 24 * 30
    eks_nodes      = "43.80"  # t3.medium * 2 * $0.0416/hour * 24 * 30
    rds_instance   = "13.14"  # db.t3.micro * $0.018/hour * 24 * 30
    nat_gateway    = "135.00" # $45/month * 3 AZs
    cloudtrail     = "2.00"   # Estimated based on API calls
    guardduty      = "5.00"   # Estimated for small workload
    total_estimate = "270.94"
    note          = "Costs may vary based on actual usage and AWS pricing changes"
  }
}

# Thai Market Specific Outputs
output "thai_compliance_info" {
  description = "Thai market compliance and regulatory information"
  value = {
    pdpa_compliance = {
      data_encryption_at_rest    = "Enabled with AWS KMS"
      data_encryption_in_transit = "Enabled with TLS 1.2+"
      audit_logging             = "Enabled with CloudTrail"
      data_residency            = "ap-southeast-1 (Singapore) - Nearest AWS region to Thailand"
    }
    banking_compliance = {
      bot_guidelines = "Architecture follows Bank of Thailand IT risk management guidelines"
      network_segmentation = "Multi-tier VPC with isolated subnets"
      access_controls = "IAM roles with least privilege principle"
      monitoring = "24/7 monitoring with GuardDuty and Security Hub"
    }
    security_certifications = [
      "SOC 1/2/3",
      "ISO 27001", 
      "PCI DSS Level 1",
      "FedRAMP"
    ]
  }
}

# Next Steps Information
output "next_steps" {
  description = "Next steps after infrastructure deployment"
  value = {
    configure_kubectl = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
    deploy_applications = "./scripts/deployment/deploy-applications.sh"
    setup_monitoring = "./scripts/deployment/deploy-monitoring.sh"
    access_grafana = "kubectl port-forward svc/grafana 3001:3000 -n monitoring"
    security_dashboard = "https://console.aws.amazon.com/securityhub/home?region=${var.aws_region}"
  }
}