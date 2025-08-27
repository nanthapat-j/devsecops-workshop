# Module 1: Infrastructure Security

## 🎯 Learning Objectives

ในโมดูลนี้ คุณจะได้เรียนรู้:

1. **การออกแบบ VPC แบบ Multi-tier** ตามมาตรฐานความปลอดภัยของธนาคาร
2. **การตั้งค่า EKS Cluster** พร้อม security hardening
3. **การจัดการ IAM Roles และ Policies** แบบ automated
4. **การเข้ารหัสข้อมูล** ด้วย AWS KMS
5. **การป้องกันระดับ network** ด้วย WAF และ Security Groups

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                           AWS Account                           │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    VPC (10.0.0.0/16)                       ││
│  │  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐││
│  │  │  Public Subnet  │ │  Public Subnet  │ │  Public Subnet  ││
│  │  │  10.0.1.0/24    │ │  10.0.2.0/24    │ │  10.0.3.0/24    ││
│  │  │   AZ-1a         │ │    AZ-1b        │ │    AZ-1c        ││
│  │  │   NAT Gateway   │ │   NAT Gateway   │ │   NAT Gateway   ││
│  │  └─────────────────┘ └─────────────────┘ └─────────────────┘││
│  │  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐││
│  │  │ Private Subnet  │ │ Private Subnet  │ │ Private Subnet  ││
│  │  │  10.0.11.0/24   │ │  10.0.12.0/24   │ │  10.0.13.0/24   ││
│  │  │  EKS Workers    │ │  EKS Workers    │ │  EKS Workers    ││
│  │  └─────────────────┘ └─────────────────┘ └─────────────────┘││
│  │  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐││
│  │  │Database Subnet  │ │Database Subnet  │ │Database Subnet  ││
│  │  │  10.0.21.0/24   │ │  10.0.22.0/24   │ │  10.0.23.0/24   ││
│  │  │    RDS          │ │    RDS          │ │    RDS          ││
│  │  └─────────────────┘ └─────────────────┘ └─────────────────┘││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## 📚 Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform v1.5+
- Basic understanding of AWS networking
- Familiarity with Kubernetes concepts

## 🚀 Quick Start

### Step 1: Environment Setup

```bash
# Navigate to infrastructure directory
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply the configuration
terraform apply -var-file="environments/dev/terraform.tfvars"
```

### Step 2: Verify Deployment

```bash
# Check VPC creation
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=devsecops-workshop"

# Verify EKS cluster
aws eks describe-cluster --name devsecops-workshop-dev-eks

# Configure kubectl
aws eks update-kubeconfig --region ap-southeast-1 --name devsecops-workshop-dev-eks

# Test connectivity
kubectl get nodes
```

## 🔐 Security Features Implemented

### 1. **Network Segmentation**
- **3-tier architecture**: Public, Private, Database subnets
- **Network ACLs**: Additional layer of security beyond security groups
- **VPC Flow Logs**: Complete network traffic monitoring
- **NAT Gateways**: Secure outbound internet access for private resources

### 2. **EKS Security Hardening**
- **Private API endpoint**: Cluster control plane not publicly accessible
- **Pod Security Standards**: Enforced security policies for workloads
- **RBAC integration**: Fine-grained access control
- **Audit logging**: Complete API call logging
- **Encryption at rest**: All data encrypted using AWS KMS

### 3. **Database Security**
- **Encryption at rest**: PostgreSQL data encrypted with KMS
- **Encryption in transit**: SSL/TLS enforced for all connections
- **Network isolation**: Database in isolated subnets
- **Automated backups**: 7-day retention with encryption
- **Performance Insights**: Query-level monitoring

### 4. **IAM Security**
- **Least privilege principle**: Minimal required permissions
- **Service roles**: Dedicated roles for each service
- **Cross-service trust**: Secure service-to-service communication
- **OIDC integration**: Modern authentication for EKS workloads

### 5. **Monitoring & Compliance**
- **CloudTrail**: Complete API audit trail
- **Security Hub**: Centralized security findings
- **GuardDuty**: Threat detection and intelligence
- **Config**: Configuration compliance monitoring

## 🇹🇭 Thai Market Compliance

### **PDPA (Personal Data Protection Act) Compliance**
- ✅ **Data Encryption**: All personal data encrypted at rest and in transit
- ✅ **Access Logging**: Complete audit trail of data access
- ✅ **Data Residency**: Infrastructure in ap-southeast-1 (nearest to Thailand)
- ✅ **Right to be Forgotten**: Database design supports data deletion

### **Banking Sector (BOT Guidelines)**
- ✅ **Network Segmentation**: Multi-tier architecture isolates critical systems
- ✅ **Encryption Standards**: AES-256 encryption for all data
- ✅ **Access Controls**: Multi-factor authentication and RBAC
- ✅ **Audit Requirements**: 90-day log retention for financial data

### **Government Cloud Standards**
- ✅ **Security Certifications**: AWS SOC, ISO 27001, PCI DSS compliance
- ✅ **Data Sovereignty**: Infrastructure in ASEAN region
- ✅ **Incident Response**: 24/7 monitoring and automated alerting

## 📝 Hands-on Exercises

### **Exercise 1: VPC Security Analysis**
1. Deploy the infrastructure
2. Analyze the security groups and NACLs
3. Test network connectivity between tiers
4. Review VPC Flow Logs

**Expected Outcome**: Understanding of network security layers

### **Exercise 2: EKS Security Hardening**
1. Review EKS cluster configuration
2. Test Pod Security Standards
3. Verify encryption settings
4. Check audit logging

**Expected Outcome**: Secure Kubernetes cluster configuration

### **Exercise 3: Database Security Assessment**
1. Connect to RDS instance
2. Verify encryption settings
3. Test backup and restore
4. Review monitoring metrics

**Expected Outcome**: Secure database configuration

## 🔧 Troubleshooting Guide

### **Common Issues**

#### **Issue 1: Terraform Permission Errors**
```bash
# Error: AccessDenied when creating VPC
# Solution: Ensure your AWS user has EC2FullAccess policy

aws iam attach-user-policy --user-name your-username --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
```

#### **Issue 2: EKS Cluster Creation Timeout**
```bash
# Error: Timeout waiting for EKS cluster to be created
# Solution: Check CloudFormation stack for detailed errors

aws cloudformation describe-stack-events --stack-name eksctl-your-cluster-name
```

#### **Issue 3: kubectl Access Denied**
```bash
# Error: You must be logged in to the server (Unauthorized)
# Solution: Update kubeconfig and check IAM permissions

aws eks update-kubeconfig --region ap-southeast-1 --name your-cluster-name
kubectl auth can-i "*" "*" --as=system:serviceaccount:kube-system:aws-node
```

## 💰 Cost Optimization

### **Monthly Cost Breakdown (USD)**
- **EKS Cluster**: $72 (Control plane)
- **Worker Nodes**: $44 (2x t3.medium)
- **RDS Instance**: $13 (db.t3.micro)
- **NAT Gateways**: $135 (3x $45/month)
- **Data Transfer**: $10 (estimated)
- **Total**: ~$274/month

### **Cost Optimization Strategies**
1. **Use Spot Instances** for non-critical worker nodes (50-70% savings)
2. **Single NAT Gateway** for development (save $90/month)
3. **Reserved Instances** for predictable workloads (up to 75% savings)
4. **Auto Scaling** to match demand patterns

## 📈 Monitoring & Alerts

### **Key Metrics to Monitor**
- **VPC Flow Logs**: Unusual traffic patterns
- **EKS Cluster Health**: Node failures, pod restarts
- **RDS Performance**: CPU, memory, disk usage
- **Security Events**: Failed authentication attempts

### **Recommended Alerts**
- High CPU usage on EKS nodes (>80%)
- Database connection failures
- Unusual network traffic patterns
- Security group changes

## 🔗 Next Steps

After completing this module:

1. **Proceed to Module 2**: Container Security
2. **Set up monitoring**: Deploy Prometheus and Grafana
3. **Deploy applications**: Use the secure infrastructure
4. **Security testing**: Run penetration tests

## 📚 Additional Resources

### **Official Documentation**
- [AWS VPC Security Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [EKS Security Best Practices](https://aws.github.io/aws-eks-best-practices/security/docs/)
- [RDS Security](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.html)

### **Thai Resources**
- [PDPA Compliance Guide](https://www.pdpc.gov.sg/Help-and-Resources/2020/01/Guide-to-the-PDPA)
- [BOT IT Risk Management](https://www.bot.or.th/Thai/PrudentialRegulation/Documents/IT_Risk_Management.pdf)
- [Thai Cybersecurity Framework](https://www.ncsa.or.th/)

### **Training Materials**
- [AWS Security Fundamentals](https://aws.amazon.com/training/classroom/aws-security-fundamentals/)
- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)

---

## 💡 Pro Tips

1. **Always use least privilege** principle for IAM roles
2. **Enable all logging features** - storage cost is minimal compared to incident cost
3. **Test disaster recovery** procedures regularly
4. **Keep Terraform state secure** - use S3 backend with encryption
5. **Document everything** - future you will thank present you

Ready to secure your cloud infrastructure? Let's get started! 🚀