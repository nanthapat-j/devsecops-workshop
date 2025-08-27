# Exercise 1: VPC Security Architecture Design

## 🎯 Objective
ออกแบบและสร้าง secure VPC architecture สำหรับ e-commerce platform ตามมาตรฐานความปลอดภัยของธนาคารไทย

## 📚 Prerequisites
- AWS CLI configured
- Terraform v1.5+
- Basic understanding of AWS networking
- อ่าน VPC Security Best Practices documentation

## 🔧 Exercise Overview

คุณจะได้สร้าง multi-tier VPC architecture ที่ปลอดภัย พร้อมทั้งทดสอบและตรวจสอบการทำงานของระบบความปลอดภัย

### Architecture Requirements

```
┌─────────────────────────────────────────────────────────────────┐
│                     VPC: 10.0.0.0/16                          │
│                                                                 │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐           │
│  │ Public Subnet │ │ Public Subnet │ │ Public Subnet │           │
│  │ 10.0.1.0/24  │ │ 10.0.2.0/24  │ │ 10.0.3.0/24  │           │
│  │    AZ-1a     │ │    AZ-1b     │ │    AZ-1c     │           │
│  │              │ │              │ │              │           │
│  │ NAT Gateway  │ │ NAT Gateway  │ │ NAT Gateway  │           │
│  │ ALB          │ │              │ │              │           │
│  └──────────────┘ └──────────────┘ └──────────────┘           │
│           │               │               │                   │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐           │
│  │Private Subnet│ │Private Subnet│ │Private Subnet│           │
│  │ 10.0.11.0/24 │ │ 10.0.12.0/24 │ │ 10.0.13.0/24 │           │
│  │              │ │              │ │              │           │
│  │ EKS Workers  │ │ EKS Workers  │ │ EKS Workers  │           │
│  │ Application  │ │ Application  │ │ Application  │           │
│  └──────────────┘ └──────────────┘ └──────────────┘           │
│           │               │               │                   │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐           │
│  │Database Subnet│ │Database Subnet│ │Database Subnet│          │
│  │ 10.0.21.0/24 │ │ 10.0.22.0/24 │ │ 10.0.23.0/24 │           │
│  │              │ │              │ │              │           │
│  │     RDS      │ │              │ │              │           │
│  │  PostgreSQL  │ │              │ │              │           │
│  └──────────────┘ └──────────────┘ └──────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

## 📝 Tasks

### Task 1: VPC และ Subnet Creation (30 นาที)

1. **สร้าง VPC Configuration**
   ```bash
   cd infrastructure/terraform
   ```

2. **ตรวจสอบและปรับแต่ง terraform.tfvars**
   ```hcl
   # infrastructure/terraform/environments/dev/terraform.tfvars
   aws_region = "ap-southeast-1"
   environment = "dev"
   
   # Network Configuration
   vpc_cidr = "10.0.0.0/16"
   
   # Security Settings
   enable_pdpa_compliance = true
   data_residency_requirement = true
   enable_audit_logging = true
   ```

3. **Deploy VPC Infrastructure**
   ```bash
   terraform init
   terraform plan -var-file="environments/dev/terraform.tfvars"
   terraform apply -var-file="environments/dev/terraform.tfvars"
   ```

4. **ตรวจสอบการสร้าง VPC**
   ```bash
   # ตรวจสอบ VPC
   aws ec2 describe-vpcs --filters "Name=tag:Project,Values=devsecops-workshop"
   
   # ตรวจสอบ Subnets
   aws ec2 describe-subnets --filters "Name=tag:Project,Values=devsecops-workshop"
   
   # ตรวจสอบ Route Tables
   aws ec2 describe-route-tables --filters "Name=tag:Project,Values=devsecops-workshop"
   ```

### Task 2: Security Groups Analysis (20 นาที)

1. **ตรวจสอบ Security Groups ที่สร้างขึ้น**
   ```bash
   aws ec2 describe-security-groups --filters "Name=tag:Project,Values=devsecops-workshop"
   ```

2. **วิเคราะห์ Security Group Rules**
   - EKS Cluster Security Group
   - EKS Node Security Group  
   - RDS Security Group

3. **ตรวจสอบ Network ACLs**
   ```bash
   aws ec2 describe-network-acls --filters "Name=tag:Project,Values=devsecops-workshop"
   ```

### Task 3: VPC Flow Logs Testing (25 นาที)

1. **ตรวจสอบ VPC Flow Logs**
   ```bash
   aws logs describe-log-groups --log-group-name-prefix "/aws/vpc/flowlogs"
   ```

2. **สร้าง Test Traffic**
   ```bash
   # Launch a test EC2 instance in public subnet
   aws ec2 run-instances \
     --image-id ami-0c02fb55956c7d316 \
     --instance-type t3.micro \
     --subnet-id $(terraform output -raw public_subnet_ids | jq -r '.[0]') \
     --security-group-ids $(terraform output -raw security_group_eks_cluster_id) \
     --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=test-instance}]'
   ```

3. **ตรวจสอบ Flow Logs**
   ```bash
   aws logs get-log-events \
     --log-group-name "/aws/vpc/flowlogs/devsecops-workshop-dev-vpc" \
     --log-stream-name $(aws logs describe-log-streams \
       --log-group-name "/aws/vpc/flowlogs/devsecops-workshop-dev-vpc" \
       --query 'logStreams[0].logStreamName' --output text)
   ```

### Task 4: Network Connectivity Testing (25 นาที)

1. **ทดสอบ Internet Gateway Connectivity**
   ```bash
   # SSH เข้า test instance ใน public subnet
   # Test internet connectivity
   curl -I http://www.google.com
   ```

2. **ทดสอบ NAT Gateway Connectivity**
   ```bash
   # Launch instance in private subnet และทดสอบ outbound internet
   # (ใช้ Session Manager หรือ bastion host)
   ```

3. **ทดสอบ Database Connectivity**
   ```bash
   # ทดสอบการเชื่อมต่อจาก private subnet ไป database subnet
   telnet <rds-endpoint> 5432
   ```

## 🔍 Security Validation Checklist

### ✅ **Network Segmentation**
- [ ] Public subnets สามารถเข้า internet ได้
- [ ] Private subnets ไม่สามารถเข้า internet โดยตรง
- [ ] Database subnets isolated จาก internet
- [ ] NAT Gateways ใช้งานได้ปกติ

### ✅ **Security Groups**
- [ ] EKS cluster security group มี minimal required rules
- [ ] RDS security group อนุญาตเฉพาะ private subnet
- [ ] ไม่มี 0.0.0.0/0 ใน inbound rules (ยกเว้น public subnet)

### ✅ **Network ACLs**
- [ ] Public subnet NACL อนุญาต HTTP/HTTPS inbound
- [ ] Private subnet NACL อนุญาตเฉพาะ VPC traffic
- [ ] Database subnet NACL อนุญาตเฉพาะ database ports

### ✅ **Monitoring & Logging**
- [ ] VPC Flow Logs เปิดใช้งาน
- [ ] CloudTrail logging เปิดใช้งาน
- [ ] Security Hub เปิดใช้งาน
- [ ] GuardDuty เปิดใช้งาน

## 📊 Expected Results

### **VPC Summary**
```
VPC CIDR: 10.0.0.0/16
Subnets: 9 (3 public, 3 private, 3 database)
AZs: 3 (ap-southeast-1a, 1b, 1c)
NAT Gateways: 3 (high availability)
Internet Gateway: 1
Route Tables: 7 (1 public, 3 private, 3 database)
```

### **Security Configuration**
```
Security Groups: 3
Network ACLs: 3
VPC Flow Logs: Enabled
Encryption: All data encrypted in transit and at rest
Compliance: PDPA ready
```

## 🚨 Common Issues & Solutions

### **Issue 1: Terraform Permission Errors**
```bash
# Error: AccessDenied when creating VPC
# Solution: Add required IAM permissions

aws iam attach-user-policy --user-name your-username \
  --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess
```

### **Issue 2: NAT Gateway Creation Fails**
```bash
# Error: InsufficientFreeAddressesInSubnet
# Solution: Ensure public subnets have available IP addresses

aws ec2 describe-subnets --subnet-ids <subnet-id> \
  --query 'Subnets[0].AvailableIpAddressCount'
```

### **Issue 3: Security Group Rules Not Working**
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

# Verify NACL rules
aws ec2 describe-network-acls --network-acl-ids <nacl-id>
```

## 🎯 Success Criteria

เมื่อทำแบบฝึกหัดนี้เสร็จ คุณควรจะ:

1. **เข้าใจ VPC Architecture** - รู้วิธีออกแบบ multi-tier network
2. **ใช้ Security Groups ได้** - สามารถกำหนด firewall rules
3. **ตั้งค่า Network Monitoring** - รู้วิธีเปิด Flow Logs และ CloudTrail
4. **ทดสอบ Network Connectivity** - ตรวจสอบการทำงานของ network
5. **ปฏิบัติตาม Security Best Practices** - ทำตามมาตรฐานความปลอดภัย

## 📚 Additional Learning

### **Thai Banking Compliance**
- ศึกษา BOT IT Risk Management Guidelines
- ทำความเข้าใจ data residency requirements
- เรียนรู้ network isolation สำหรับ financial services

### **Next Steps**
1. Proceed to Exercise 2: EKS Security Hardening
2. Deploy monitoring stack
3. Implement additional security controls

---

## 💡 Pro Tips

1. **ใช้ Resource Tags** - แท็กทุก resource เพื่อง่ายต่อการจัดการ
2. **Document Everything** - บันทึกการตั้งค่าและเหตุผล
3. **Test Regularly** - ทดสอบ security controls เป็นประจำ
4. **Monitor Costs** - ติดตาม AWS costs โดยเฉพาะ NAT Gateway
5. **Backup Configuration** - เก็บ Terraform state อย่างปลอดภัย

Ready to secure your VPC? Let's build! 🏗️