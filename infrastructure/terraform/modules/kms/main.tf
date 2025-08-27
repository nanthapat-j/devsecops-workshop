# KMS Module for encryption key management
resource "aws_kms_key" "cluster" {
  description             = "EKS Cluster encryption key"
  deletion_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eks-cluster-key"
    Purpose = "EKS-Encryption"
  })
}

resource "aws_kms_alias" "cluster" {
  name          = "alias/${var.name_prefix}-eks-cluster"
  target_key_id = aws_kms_key.cluster.key_id
}

resource "aws_kms_key" "rds" {
  description             = "RDS database encryption key"
  deletion_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds-key"
    Purpose = "RDS-Encryption"
  })
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.name_prefix}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_kms_key" "cloudtrail" {
  description             = "CloudTrail logs encryption key"
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable CloudTrail Encrypt"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cloudtrail-key"
    Purpose = "CloudTrail-Encryption"
  })
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/${var.name_prefix}-cloudtrail"
  target_key_id = aws_kms_key.cloudtrail.key_id
}

data "aws_caller_identity" "current" {}