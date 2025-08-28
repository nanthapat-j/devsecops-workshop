# Security Module Outputs
# DevSecOps Workshop - Security Resource Outputs

# =============================================================================
# KMS Key Outputs
# =============================================================================

output "kms_key_id" {
  description = "ID of the main KMS key"
  value       = aws_kms_key.main.key_id
}

output "kms_key_arn" {
  description = "ARN of the main KMS key"
  value       = aws_kms_key.main.arn
}

output "kms_key_alias" {
  description = "Alias of the main KMS key"
  value       = aws_kms_alias.main.name
}

output "database_kms_key_id" {
  description = "ID of the database KMS key"
  value       = aws_kms_key.database.key_id
}

output "database_kms_key_arn" {
  description = "ARN of the database KMS key"
  value       = aws_kms_key.database.arn
}

output "database_kms_key_alias" {
  description = "Alias of the database KMS key"
  value       = aws_kms_alias.database.name
}

# =============================================================================
# Security Group Outputs
# =============================================================================

output "security_group_ids" {
  description = "Map of security group IDs"
  value = {
    alb         = aws_security_group.alb.id
    eks_cluster = aws_security_group.eks_cluster.id
    eks_nodes   = aws_security_group.eks_nodes.id
    rds         = aws_security_group.rds.id
    bastion     = length(aws_security_group.bastion) > 0 ? aws_security_group.bastion[0].id : null
  }
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "eks_cluster_security_group_id" {
  description = "ID of the EKS cluster security group"
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_security_group_id" {
  description = "ID of the EKS nodes security group"
  value       = aws_security_group.eks_nodes.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = length(aws_security_group.bastion) > 0 ? aws_security_group.bastion[0].id : null
}

# =============================================================================
# WAF Outputs
# =============================================================================

output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].id : null
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].arn : null
}

output "waf_web_acl_name" {
  description = "Name of the WAF Web ACL"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].name : null
}

# =============================================================================
# GuardDuty Outputs
# =============================================================================

output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].id : null
}

output "guardduty_detector_arn" {
  description = "ARN of the GuardDuty detector"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].arn : null
}

# =============================================================================
# Security Hub Outputs
# =============================================================================

output "security_hub_account_id" {
  description = "Security Hub account ID"
  value       = var.enable_security_hub ? aws_securityhub_account.main[0].id : null
}

output "security_hub_standards" {
  description = "List of enabled Security Hub standards"
  value       = var.enable_security_hub ? var.security_hub_standards : []
}

# =============================================================================
# SNS Outputs
# =============================================================================

output "security_alerts_topic_arn" {
  description = "ARN of the security alerts SNS topic"
  value       = var.enable_sns_notifications ? aws_sns_topic.security_alerts[0].arn : null
}

output "security_alerts_topic_name" {
  description = "Name of the security alerts SNS topic"
  value       = var.enable_sns_notifications ? aws_sns_topic.security_alerts[0].name : null
}

# =============================================================================
# Compliance Outputs
# =============================================================================

output "compliance_summary" {
  description = "Summary of compliance configurations"
  value = {
    data_classification     = var.data_classification
    compliance_framework    = var.compliance_framework
    data_residency         = var.data_residency
    pdpa_compliance_enabled = var.enable_pdpa_compliance
    encryption_enabled     = true
    key_rotation_enabled   = var.enable_key_rotation
    guardduty_enabled      = var.enable_guardduty
    security_hub_enabled   = var.enable_security_hub
    waf_enabled           = var.enable_waf
  }
}

# =============================================================================
# Security Configuration Summary
# =============================================================================

output "security_configuration" {
  description = "Summary of security configuration"
  value = {
    environment            = var.environment
    kms_keys_created      = 2  # main + database
    security_groups_created = length(var.allowed_ssh_cidrs) > 0 ? 5 : 4
    waf_enabled           = var.enable_waf
    waf_rate_limit        = var.enable_waf ? var.waf_rate_limit : null
    guardduty_enabled     = var.enable_guardduty
    security_hub_enabled  = var.enable_security_hub
    sns_notifications     = var.enable_sns_notifications
    key_rotation_enabled  = var.enable_key_rotation
    key_deletion_window   = var.key_deletion_window
  }
}

# =============================================================================
# Cost Optimization Outputs
# =============================================================================

output "cost_optimization_summary" {
  description = "Cost optimization information"
  value = {
    guardduty_estimated_monthly_cost = var.enable_guardduty ? "$3-10 USD (depends on data volume)" : "$0 USD"
    security_hub_estimated_monthly_cost = var.enable_security_hub ? "$0.30 per 10,000 findings" : "$0 USD"
    waf_estimated_monthly_cost = var.enable_waf ? "$1 USD + $0.60 per million requests" : "$0 USD"
    kms_estimated_monthly_cost = "$1 USD per key + $0.03 per 10,000 requests"
    total_estimated_monthly_cost = var.enable_guardduty && var.enable_security_hub && var.enable_waf ? "$10-20 USD" : "$5-10 USD"
  }
}

# =============================================================================
# Security Endpoints and URLs
# =============================================================================

output "security_endpoints" {
  description = "Security service endpoints and dashboards"
  value = {
    guardduty_console_url = var.enable_guardduty ? "https://${data.aws_region.current.name}.console.aws.amazon.com/guardduty/home?region=${data.aws_region.current.name}#/findings" : null
    security_hub_console_url = var.enable_security_hub ? "https://${data.aws_region.current.name}.console.aws.amazon.com/securityhub/home?region=${data.aws_region.current.name}#/findings" : null
    waf_console_url = var.enable_waf ? "https://${data.aws_region.current.name}.console.aws.amazon.com/wafv2/homev2/web-acl/${aws_wafv2_web_acl.main[0].name}/${aws_wafv2_web_acl.main[0].id}/overview?region=${data.aws_region.current.name}" : null
    cloudwatch_dashboards_url = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:"
  }
}

# =============================================================================
# Thai Compliance Specific Outputs
# =============================================================================

output "thai_compliance_status" {
  description = "Thai regulatory compliance status"
  value = {
    pdpa_compliance = {
      enabled = var.enable_pdpa_compliance
      data_encryption = "AES-256 with KMS"
      data_residency = var.data_residency
      audit_logging = var.enable_guardduty && var.enable_security_hub
      data_classification = var.data_classification
    }
    bot_compliance = {
      multi_az_ready = true
      encryption_at_rest = true
      encryption_in_transit = true
      audit_trail = var.enable_guardduty
      incident_response = var.enable_sns_notifications
      backup_encryption = true
    }
    security_controls = {
      waf_protection = var.enable_waf
      ddos_protection = "AWS Shield Standard included"
      threat_detection = var.enable_guardduty
      vulnerability_management = var.enable_security_hub
      access_control = "IAM + Security Groups + NACLs"
    }
  }
}

# =============================================================================
# Quick Commands for Security Management
# =============================================================================

output "security_commands" {
  description = "Useful commands for security management"
  value = {
    check_guardduty_findings = var.enable_guardduty ? "aws guardduty list-findings --detector-id ${aws_guardduty_detector.main[0].id}" : "GuardDuty not enabled"
    check_security_hub_findings = var.enable_security_hub ? "aws securityhub get-findings --max-results 10" : "Security Hub not enabled"
    view_waf_metrics = var.enable_waf ? "aws cloudwatch get-metric-statistics --namespace AWS/WAFV2 --metric-name AllowedRequests --dimensions Name=WebACL,Value=${aws_wafv2_web_acl.main[0].name} --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) --end-time $(date -u +%Y-%m-%dT%H:%M:%S) --period 3600 --statistics Sum" : "WAF not enabled"
    rotate_kms_key = "aws kms enable-key-rotation --key-id ${aws_kms_key.main.key_id}"
    check_kms_rotation = "aws kms get-key-rotation-status --key-id ${aws_kms_key.main.key_id}"
  }
}