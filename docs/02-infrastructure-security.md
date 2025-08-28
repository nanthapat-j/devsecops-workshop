# 🏗️ Module 2: Infrastructure Security Foundation

## 📋 ภาพรวม Module

Module นี้จะสอนการสร้างโครงสร้างพื้นฐานที่ปลอดภัยบน AWS ด้วย Infrastructure as Code (Terraform) โดยเน้นการปฏิบัติตามมาตรฐานความปลอดภัยและข้อกำหนดของประเทศไทย

### 🎯 Learning Objectives

เมื่อจบ Module นี้ คุณจะสามารถ:

1. **🔧 Terraform Fundamentals**
   - เข้าใจหลักการ Infrastructure as Code
   - สร้างและจัดการ Terraform modules
   - ใช้ Terraform state management ที่ปลอดภัย

2. **🌐 Secure Network Architecture**
   - ออกแบบ VPC ด้วยหลักการ Defense in Depth
   - ตั้งค่า Network segmentation และ Security Groups
   - เปิดใช้งาน VPC Flow Logs สำหรับ monitoring

3. **🐳 Kubernetes Security**
   - สร้าง EKS cluster ด้วยการ hardening
   - ตั้งค่า RBAC และ Pod Security Standards
   - ใช้ Network Policies สำหรับ micro-segmentation

4. **🗄️ Database Security**
   - ตั้งค่า RDS PostgreSQL ด้วย encryption
   - กำหนด backup และ recovery strategies
   - ใช้ Database parameter groups สำหรับ security

5. **🔒 Security Services**
   - ตั้งค่า AWS KMS สำหรับ key management
   - เปิดใช้งาน AWS WAF สำหรับ web application protection
   - กำหนด CloudTrail และ CloudWatch สำหรับ monitoring

## 🌏 Thai Compliance Requirements

### 📍 Data Residency (การเก็บข้อมูลในประเทศ)

**Thailand Data Protection Act (PDPA) Requirements:**

```hcl
# ตั้งค่า AWS Region สำหรับข้อมูลที่ต้องเก็บในประเทศไทย
provider "aws" {
  region = "ap-southeast-1"  # Singapore - ใกล้ที่สุดกับไทย
  
  default_tags {
    tags = {
      "DataClassification" = "Sensitive"
      "ComplianceFramework" = "PDPA"
      "DataResidency" = "ASEAN"
    }
  }
}
```

**Key Compliance Points:**
- 🌏 ใช้ `ap-southeast-1` (Singapore) สำหรับ data residency
- 🔒 เปิดใช้งาน encryption ทั้ง at rest และ in transit
- 📊 Log และ monitor ทุก data access
- ⚖️ ใช้ retention policies ตาม PDPA requirements

### 🏛️ Banking Regulations (BOT Guidelines)

**Bank of Thailand IT Risk Management:**

```hcl
# Example: High availability configuration for financial services
variable "availability_zones" {
  description = "Multi-AZ deployment for BOT compliance"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}
```

## 🏗️ Architecture Overview

### 🌐 Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │   Public Subnet │  │   Public Subnet │  │   Public    │  │
│  │   10.0.1.0/24   │  │   10.0.2.0/24   │  │   Subnet    │  │
│  │   (AZ-1a)       │  │   (AZ-1b)       │  │   10.0.3.0  │  │
│  └─────────────────┘  └─────────────────┘  └─────────────┘  │
│           │                     │                    │      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │  Private Subnet │  │  Private Subnet │  │   Private   │  │
│  │  10.0.11.0/24   │  │  10.0.12.0/24   │  │   Subnet    │  │
│  │   (EKS Nodes)   │  │   (EKS Nodes)   │  │   10.0.13.0 │  │
│  └─────────────────┘  └─────────────────┘  └─────────────┘  │
│           │                     │                    │      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │    DB Subnet    │  │    DB Subnet    │  │   DB Subnet │  │
│  │  10.0.21.0/24   │  │  10.0.22.0/24   │  │   10.0.23.0 │  │
│  │   (RDS Only)    │  │   (RDS Only)    │  │   (RDS Only)│  │
│  └─────────────────┘  └─────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 🔒 Security Layers

1. **Network Layer**
   - Private subnets สำหรับ application workloads
   - Dedicated database subnets
   - NACLs และ Security Groups

2. **Application Layer**
   - EKS cluster ใน private subnets
   - Pod Security Standards
   - Network Policies

3. **Data Layer**
   - RDS ใน isolated subnets
   - Encryption at rest ด้วย KMS
   - Automated backups

## 🛠️ Hands-on Implementation

### 1. VPC Module Creation

**File:** `infrastructure/terraform/modules/vpc/main.tf`

```hcl
# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
    Environment = var.environment
    ManagedBy = "terraform"
    ComplianceFramework = "PDPA"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
    Environment = var.environment
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
    Type = "Public"
    Environment = var.environment
    "kubernetes.io/role/elb" = "1"  # For EKS Load Balancers
  }
}

# Private Subnets for EKS
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 11)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-private-${count.index + 1}"
    Type = "Private"
    Environment = var.environment
    "kubernetes.io/role/internal-elb" = "1"  # For EKS Internal Load Balancers
  }
}

# Database Subnets
resource "aws_subnet" "database" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 21)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-db-${count.index + 1}"
    Type = "Database"
    Environment = var.environment
  }
}

# NAT Gateways
resource "aws_eip" "nat" {
  count = length(var.availability_zones)
  domain = "vpc"

  tags = {
    Name = "${var.environment}-nat-eip-${count.index + 1}"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = length(var.availability_zones)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.environment}-nat-${count.index + 1}"
    Environment = var.environment
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.environment}-private-rt-${count.index + 1}"
    Environment = var.environment
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# VPC Flow Logs for Security Monitoring
resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-vpc-flow-logs"
    Environment = var.environment
    SecurityMonitoring = "enabled"
  }
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "/aws/vpc/flowlogs/${var.environment}"
  retention_in_days = 30  # Adjust based on compliance requirements

  tags = {
    Name = "${var.environment}-vpc-flow-logs"
    Environment = var.environment
  }
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_log" {
  name = "${var.environment}-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-vpc-flow-log-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "flow_log" {
  name = "${var.environment}-vpc-flow-log-policy"
  role = aws_iam_role.flow_log.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}
```

**File:** `infrastructure/terraform/modules/vpc/variables.tf`

```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
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

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
```

**File:** `infrastructure/terraform/modules/vpc/outputs.tf`

```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = aws_flow_log.main.id
}
```

### 2. Security Module

**File:** `infrastructure/terraform/modules/security/main.tf`

```hcl
# KMS Key for Encryption
resource "aws_kms_key" "main" {
  description             = "KMS key for ${var.environment} environment"
  deletion_window_in_days = 7
  enable_key_rotation     = true

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
      }
    ]
  })

  tags = {
    Name = "${var.environment}-kms-key"
    Environment = var.environment
    Purpose = "encryption"
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.environment}-main"
  target_key_id = aws_kms_key.main.key_id
}

# Security Groups
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.environment}-eks-cluster-"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-eks-cluster-sg"
    Environment = var.environment
    Type = "EKS-Cluster"
  }
}

resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.environment}-eks-nodes-"
  vpc_id      = var.vpc_id

  ingress {
    description = "Cluster to node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  ingress {
    description = "Node to node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-eks-nodes-sg"
    Environment = var.environment
    Type = "EKS-Nodes"
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.environment}-rds-"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from EKS nodes"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  tags = {
    Name = "${var.environment}-rds-sg"
    Environment = var.environment
    Type = "Database"
  }
}

# WAF Web ACL
resource "aws_wafv2_web_acl" "main" {
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
        limit              = 10000  # requests per 5 minutes
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

  # AWS Managed Rules
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

  # OWASP Top 10 Rules
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

  tags = {
    Name = "${var.environment}-web-acl"
    Environment = var.environment
    Purpose = "WebApplicationFirewall"
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "webACL"
    sampled_requests_enabled   = true
  }
}

data "aws_caller_identity" "current" {}
```

### 3. Practice Exercise

**📝 Exercise: Deploy Secure VPC**

1. **Create Development Environment:**

```bash
cd infrastructure/terraform/environments/dev

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var="environment=dev"

# Apply changes
terraform apply -auto-approve
```

2. **Verify Security Configuration:**

```bash
# Check VPC Flow Logs
aws logs describe-log-groups --log-group-name-prefix "/aws/vpc/flowlogs"

# Verify KMS key rotation
aws kms describe-key --key-id alias/dev-main

# Check Security Groups
aws ec2 describe-security-groups --filters "Name=group-name,Values=dev-*"
```

3. **Security Validation:**

```bash
# Run infrastructure security scanning
make terraform-security-scan

# Check compliance
make compliance-check
```

## 🔍 Security Best Practices

### 1. Network Security

**Principle of Least Privilege:**
```hcl
# Example: Restrictive Security Group
resource "aws_security_group_rule" "database_access" {
  type                     = "ingress"
  from_port               = 5432
  to_port                 = 5432
  protocol                = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id       = aws_security_group.rds.id
  description            = "PostgreSQL access from EKS nodes only"
}
```

**Network Segmentation:**
```hcl
# Database subnet route table (no internet access)
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  
  # No default route to internet gateway
  # Only local VPC traffic allowed
  
  tags = {
    Name = "${var.environment}-database-rt"
    SecurityLevel = "high"
  }
}
```

### 2. Encryption Best Practices

**KMS Key Management:**
```hcl
# Separate keys for different data types
resource "aws_kms_key" "database" {
  description = "Database encryption key"
  key_usage   = "ENCRYPT_DECRYPT"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DatabaseAccess"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### 3. Monitoring and Logging

**Comprehensive Logging:**
```hcl
# CloudTrail for API logging
resource "aws_cloudtrail" "main" {
  name                          = "${var.environment}-cloudtrail"
  s3_bucket_name               = aws_s3_bucket.cloudtrail.bucket
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_logging               = true

  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::${aws_s3_bucket.app_data.bucket}/*"]
    }
  }

  tags = {
    Name = "${var.environment}-cloudtrail"
    Environment = var.environment
    ComplianceFramework = "PDPA"
  }
}
```

## 💰 Cost Optimization

### 🎯 Development Environment Savings

```hcl
# Cost-optimized configuration for development
variable "cost_optimization" {
  description = "Enable cost optimization for development"
  type        = bool
  default     = true
}

# Conditional NAT Gateway (ประหยัดค่าใช้จ่าย dev environment)
resource "aws_nat_gateway" "main" {
  count = var.cost_optimization ? 1 : length(var.availability_zones)
  
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id
  
  tags = {
    Name = "${var.environment}-nat-shared"
    CostOptimization = "enabled"
  }
}
```

**Expected Costs (Monthly):**
- **Development**: ฿2,000-3,000
- **Staging**: ฿5,000-8,000  
- **Production**: ฿12,000-20,000

## 📊 Assessment & Validation

### ✅ Knowledge Check

**1. Network Security (คำถามเครือข่าย)**

```bash
# Q: How would you restrict database access to only application pods?
# A: Use Security Groups with source_security_group_id

# Example implementation:
resource "aws_security_group_rule" "db_from_app" {
  type                     = "ingress"
  from_port               = 5432
  to_port                 = 5432
  protocol                = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id       = aws_security_group.rds.id
}
```

**2. Thai Compliance (คำถามการปฏิบัติตามกฎหมายไทย)**

```hcl
# Q: How to ensure data residency compliance for Thai companies?
# A: Use ap-southeast-1 region and tag resources appropriately

provider "aws" {
  region = "ap-southeast-1"  # Singapore for ASEAN compliance
  
  default_tags {
    tags = {
      DataResidency = "ASEAN"
      ComplianceFramework = "PDPA"
      DataClassification = "Sensitive"
    }
  }
}
```

### 🧪 Practical Test

**Deploy and Validate Infrastructure:**

```bash
# 1. Deploy infrastructure
make terraform-apply

# 2. Run security scans
make security-scan

# 3. Validate compliance
make compliance-check

# 4. Test network connectivity
make test-network

# 5. Verify encryption
make test-encryption
```

**Success Criteria:**
- ✅ All security scans pass
- ✅ VPC Flow Logs enabled
- ✅ KMS keys created with rotation
- ✅ Security Groups follow least privilege
- ✅ WAF rules active
- ✅ CloudTrail logging enabled

## 🎯 Next Steps

**Module 2 Completed! 🎉**

You have successfully:
- ✅ Created secure VPC with proper network segmentation
- ✅ Implemented Thai compliance requirements
- ✅ Set up comprehensive logging and monitoring
- ✅ Applied infrastructure security best practices

**What's Next:**
1. **Review**: Security configurations และ cost implications
2. **Practice**: Try deploying in different environments (staging/prod)
3. **Optimize**: Fine-tune for your specific use case

**Continue to:** [Module 3: Container Security](03-container-security.md)

---

**📚 Additional Resources:**

- [AWS Security Best Practices](https://docs.aws.amazon.com/security/)
- [PDPA Compliance Guide](https://www.pdpc.gov.sg/overview-of-pdpa)
- [Terraform Security Practices](https://learn.hashicorp.com/terraform/security)
- [Thai Banking IT Guidelines](https://www.bot.or.th/)