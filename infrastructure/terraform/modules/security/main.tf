# Security Module Main Configuration
# DevSecOps Workshop - Comprehensive Security Setup

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_vpc" "main" {
  id = var.vpc_id
}

# =============================================================================
# KMS Key Management
# =============================================================================

# Main KMS Key for general encryption
resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.environment} environment - ${var.compliance_framework} compliant"
  deletion_window_in_days = var.key_deletion_window
  enable_key_rotation     = var.enable_key_rotation
  key_usage              = var.key_usage

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      },
      {
        Sid    = "Allow RDS Service"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow EKS Service"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name                = "${var.environment}-main-kms-key"
    Environment         = var.environment
    Purpose            = "GeneralEncryption"
    DataClassification = var.data_classification
    ComplianceFramework = var.compliance_framework
    KeyRotation        = var.enable_key_rotation ? "enabled" : "disabled"
  })
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.environment}-main"
  target_key_id = aws_kms_key.main.key_id
}

# Database-specific KMS Key
resource "aws_kms_key" "database" {
  description             = "KMS key for database encryption - ${var.environment}"
  deletion_window_in_days = var.key_deletion_window
  enable_key_rotation     = var.enable_key_rotation

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow RDS Service"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name                = "${var.environment}-database-kms-key"
    Environment         = var.environment
    Purpose            = "DatabaseEncryption"
    DataClassification = "Restricted"
    ComplianceFramework = var.compliance_framework
  })
}

resource "aws_kms_alias" "database" {
  name          = "alias/${var.environment}-database"
  target_key_id = aws_kms_key.database.key_id
}

# =============================================================================
# Security Groups
# =============================================================================

# ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.environment}-alb-"
  vpc_id      = var.vpc_id
  description = "Security group for Application Load Balancer"

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-alb-sg"
    Environment = var.environment
    Type = "LoadBalancer"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.environment}-eks-cluster-"
  vpc_id      = var.vpc_id
  description = "Security group for EKS cluster control plane"

  # Allow nodes to communicate with cluster API
  ingress {
    description = "Node to cluster communication"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    self        = true
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-eks-cluster-sg"
    Environment = var.environment
    Type = "EKS-Cluster"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# EKS Nodes Security Group
resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.environment}-eks-nodes-"
  vpc_id      = var.vpc_id
  description = "Security group for EKS worker nodes"

  # Node to node communication
  ingress {
    description = "Node to node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Cluster to node communication
  ingress {
    description     = "Cluster to node communication"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  # Node port services
  ingress {
    description = "Node port services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-eks-nodes-sg"
    Environment = var.environment
    Type = "EKS-Nodes"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name_prefix = "${var.environment}-rds-"
  vpc_id      = var.vpc_id
  description = "Security group for RDS instances"

  # PostgreSQL from EKS nodes
  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  # PostgreSQL from bastion (if SSH access is allowed)
  dynamic "ingress" {
    for_each = length(var.allowed_ssh_cidrs) > 0 ? [1] : []
    content {
      description = "PostgreSQL from bastion"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      security_groups = [aws_security_group.bastion[0].id]
    }
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-rds-sg"
    Environment = var.environment
    Type = "Database"
    DataClassification = "Restricted"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Bastion Host Security Group (Optional)
resource "aws_security_group" "bastion" {
  count = length(var.allowed_ssh_cidrs) > 0 ? 1 : 0

  name_prefix = "${var.environment}-bastion-"
  vpc_id      = var.vpc_id
  description = "Security group for bastion host"

  # SSH access
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-bastion-sg"
    Environment = var.environment
    Type = "Bastion"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# AWS WAF (Web Application Firewall)
# =============================================================================

resource "aws_wafv2_web_acl" "main" {
  count = var.enable_waf ? 1 : 0

  name  = "${var.environment}-web-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # Rate limiting rule
  rule {
    name     = "RateLimitRule"
    priority = 1

    override_action {
      none {}
    }

    statement {
      rate_based_statement {
        limit              = var.waf_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }

    action {
      block {}
    }
  }

  # AWS Managed Rules - Common Rule Set
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - Known Bad Inputs
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - SQL Injection
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Geo-blocking rule (if countries specified)
  dynamic "rule" {
    for_each = length(var.waf_blocked_countries) > 0 ? [1] : []
    content {
      name     = "GeoBlockRule"
      priority = 5

      action {
        block {}
      }

      statement {
        geo_match_statement {
          country_codes = var.waf_blocked_countries
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "GeoBlockRule"
        sampled_requests_enabled   = true
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-web-acl"
    Environment = var.environment
    Purpose = "WebApplicationFirewall"
    ComplianceFramework = var.compliance_framework
  })

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "webACL"
    sampled_requests_enabled   = true
  }
}

# =============================================================================
# AWS GuardDuty
# =============================================================================

resource "aws_guardduty_detector" "main" {
  count = var.enable_guardduty ? 1 : 0

  enable                       = true
  finding_publishing_frequency = var.guardduty_finding_frequency

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

  tags = merge(var.tags, {
    Name = "${var.environment}-guardduty"
    Environment = var.environment
    Purpose = "ThreatDetection"
  })
}

# =============================================================================
# AWS Security Hub
# =============================================================================

resource "aws_securityhub_account" "main" {
  count = var.enable_security_hub ? 1 : 0

  enable_default_standards = true

  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_securityhub_standards_subscription" "standards" {
  count = var.enable_security_hub ? length(var.security_hub_standards) : 0

  standards_arn = "arn:aws:securityhub:::ruleset/finding-format/${var.security_hub_standards[count.index]}/v/1.2.0"
  depends_on    = [aws_securityhub_account.main]
}

# =============================================================================
# SNS Topic for Security Notifications
# =============================================================================

resource "aws_sns_topic" "security_alerts" {
  count = var.enable_sns_notifications ? 1 : 0

  name              = "${var.environment}-security-alerts"
  kms_master_key_id = aws_kms_key.main.arn

  tags = merge(var.tags, {
    Name = "${var.environment}-security-alerts"
    Environment = var.environment
    Purpose = "SecurityNotifications"
  })
}

resource "aws_sns_topic_subscription" "email" {
  count = var.enable_sns_notifications && var.notification_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.security_alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# =============================================================================
# CloudWatch Alarms for Security
# =============================================================================

# GuardDuty High Severity Findings
resource "aws_cloudwatch_metric_alarm" "guardduty_high_severity" {
  count = var.enable_guardduty && var.enable_sns_notifications ? 1 : 0

  alarm_name          = "${var.environment}-guardduty-high-severity-findings"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FindingCount"
  namespace           = "AWS/GuardDuty"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors GuardDuty high severity findings"
  alarm_actions       = [aws_sns_topic.security_alerts[0].arn]

  dimensions = {
    DetectorId = aws_guardduty_detector.main[0].id
    Severity   = "High"
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-guardduty-high-severity-alarm"
    Environment = var.environment
  })
}