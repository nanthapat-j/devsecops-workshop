# 🔒 DevSecOps Workshop
> **Comprehensive DevSecOps Training for Thai Senior Cloud Engineers**  
> **Workshop การพัฒนาและปรับใช้ระบบความปลอดภัยแบบบูรณาการ สำหรับวิศวกรคลาวด์ระดับสูง**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Workshop Status](https://img.shields.io/badge/Status-Active-green.svg)]()
[![Thai Support](https://img.shields.io/badge/Thai-Supported-blue.svg)]()
[![AWS](https://img.shields.io/badge/AWS-Supported-orange.svg)]()
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-blue.svg)]()

## 📋 **ภาพรวม Workshop**

Workshop นี้ออกแบบมาสำหรับ **Senior Cloud Engineers** ในประเทศไทยที่ต้องการพัฒนาทักษะด้านความปลอดภัยและก้าวไปสู่ตำแหน่ง DevSecOps Engineer ในบริษัทชั้นนำของไทย

ผู้เรียนจะได้สร้าง **E-commerce Platform แบบครบวงจร** พร้อมระบบความปลอดภัยที่เป็นมาตรฐานสากล เหมาะสำหรับการสร้าง Portfolio และการสัมภาษณ์งาน

### 🎯 **เป้าหมายการเรียนรู้**
- **ออกแบบและสร้าง secure cloud infrastructure** บน AWS ตามมาตรฐาน banking และ e-commerce ไทย
- **พัฒนา security-first CI/CD pipeline** ที่ตรวจสอบความปลอดภัยอัตโนมัติ
- **ติดตั้งและใช้งาน security monitoring tools** เพื่อตรวจจับและตอบสนองภัยคุกคาม
- **ปฏิบัติตาม PDPA และข้อกำหนดของภาครัฐไทย** ในระบบคลาวด์
- **สร้าง portfolio ที่พร้อมใช้ในการสัมภาษณ์งาน** DevSecOps Engineer

### 🏢 **เป้าหมายตลาดไทย**
- **ธนาคารและสถาบันการเงิน**: SCB, BBL, KBANK, KTB
- **E-commerce และ FinTech**: Lazada, Shopee, SCB 10X, Kasikorn X
- **Enterprise และ Government Cloud**: Cloud providers ในไทย
- **Consulting และ System Integrator**: บริษัทที่ให้บริการ cloud transformation

## 🗺️ **Learning Path - เส้นทางการเรียนรู้**

### 📚 **Module 1: Infrastructure Security** 
*⏱️ 8-12 ชั่วโมง | 🎯 Portfolio: Secure AWS Infrastructure*
- **Terraform Infrastructure as Code** with security best practices
- **VPC Design** with proper network segmentation for banking standards
- **EKS Cluster** with CIS benchmarks and Pod Security Standards
- **RDS PostgreSQL** with encryption at rest/transit และ automated backup
- **IAM Roles & Policies** automation ตามหลักการ least privilege
- **AWS KMS** encryption management
- **AWS WAF** และ security groups configuration

### 🐳 **Module 2: Container Security**
*⏱️ 6-8 ชั่วโมง | 🎯 Portfolio: Secure Containerized Applications*
- **Multi-stage Dockerfiles** with security hardening
- **Container Image Scanning** with Trivy และ AWS ECR
- **Kubernetes Security Policies** (Pod Security Standards)
- **Network Policies** for micro-segmentation
- **Service Mesh Security** considerations with Istio
- **Runtime Security Monitoring** with Falco

### 🔄 **Module 3: CI/CD Security Pipeline**
*⏱️ 8-10 ชั่วโมง | 🎯 Portfolio: Automated Security Pipeline*
- **GitHub Actions** workflows with security gates
- **SAST Scanning** (CodeQL, SonarQube)
- **DAST Testing** integration
- **Dependency Scanning** (Snyk, npm audit)
- **Infrastructure Scanning** (Checkov, TFSec)
- **Secret Scanning** (TruffleHog, GitLeaks)
- **Security Approval Workflows** for production deployments

### 📊 **Module 4: Runtime Security & Monitoring**
*⏱️ 6-8 ชั่วโมง | 🎯 Portfolio: Security Operations Center*
- **AWS Security Hub** centralized security management
- **Amazon GuardDuty** threat detection
- **CloudTrail** logging และ analysis
- **Prometheus & Grafana** security dashboards
- **Falco** runtime anomaly detection
- **Incident Response** automation with Lambda

### 📋 **Module 5: Compliance & Governance**
*⏱️ 4-6 ชั่วโมง | 🎯 Portfolio: Compliance Framework*
- **Policy as Code** with Open Policy Agent (OPA)
- **PDPA Compliance** implementation และ data governance
- **Audit Logging** และ compliance reporting
- **Security Governance** frameworks
- **Risk Assessment** templates สำหรับองค์กรไทย

## 🛍️ **E-commerce Platform Architecture**

Workshop ใช้ **Real-world E-commerce Platform** เป็นตัวอย่าง:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   React.js      │    │   API Gateway    │    │   EKS Cluster       │
│   Frontend      │◄──►│   + Lambda       │◄──►│   Microservices     │
│   (Amplify)     │    │   (WAF enabled)  │    │   + Service Mesh    │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
                                                          │
                       ┌──────────────────┐              │
                       │   Monitoring     │◄─────────────┘
                       │   Prometheus     │
                       │   Grafana        │
                       │   Falco          │
                       └──────────────────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
        ┌───────▼────────┐ ┌───▼────┐ ┌───────▼────────┐
        │   PostgreSQL   │ │DynamoDB│ │  ElastiCache   │
        │   RDS          │ │   NoSQL│ │     Redis      │
        │   (Encrypted)  │ │        │ │    (Cluster)   │
        └────────────────┘ └────────┘ └────────────────┘
```

### 🏗️ **Application Components**
- **Frontend**: React.js with TypeScript, containerized และ secured
- **API Gateway**: AWS API Gateway + Lambda functions
- **Microservices**: 
  - User Service (Authentication & Authorization)
  - Product Service (Catalog & Inventory) 
  - Order Service (Shopping Cart & Payment)
- **Databases**: PostgreSQL RDS (encrypted) + DynamoDB
- **Cache**: ElastiCache Redis cluster
- **Messaging**: SQS/SNS for async communication

## 🚀 **Quick Start**

### 📋 **Prerequisites**
- **AWS Account** with appropriate permissions
- **Docker Desktop** (latest version)
- **kubectl** และ **helm** CLI tools
- **Terraform** v1.5+ 
- **Node.js** v18+ และ **npm**
- **Git** และ **GitHub account**

### ⚡ **One-Command Setup**
```bash
# Clone repository
git clone https://github.com/nanthapat-j/devsecops-workshop.git
cd devsecops-workshop

# Setup development environment (ตรวจสอบและติดตั้ง prerequisites)
./scripts/setup/check-prerequisites.sh
./scripts/setup/install-tools.sh

# Configure AWS credentials
aws configure

# Deploy infrastructure (Terraform)
./scripts/deployment/deploy-infrastructure.sh

# Deploy applications to EKS
./scripts/deployment/deploy-applications.sh

# Setup monitoring
./scripts/deployment/deploy-monitoring.sh
```

### 🔗 **Access Applications**
```bash
# Frontend Application
kubectl port-forward svc/frontend 3000:3000 -n ecommerce

# Grafana Monitoring Dashboard  
kubectl port-forward svc/grafana 3001:3000 -n monitoring

# Prometheus Metrics
kubectl port-forward svc/prometheus 9090:9090 -n monitoring

# Falco Security Dashboard
kubectl port-forward svc/falco-ui 8080:8080 -n security
```

## 📖 **Module Details**

### 🏗️ **Module 1: Infrastructure Security**
**เรียนรู้การสร้าง secure cloud infrastructure บน AWS**

#### 📚 Learning Objectives
- สร้าง VPC แบบ multi-tier ตามมาตรฐาน banking
- ติดตั้ง EKS cluster พร้อม security hardening
- จัดการ IAM roles และ policies แบบ automated
- เข้ารหัสข้อมูลด้วย KMS และ SSL/TLS
- ป้องกัน web application ด้วย WAF

#### 🛠️ Tools & Technologies
- **Terraform** - Infrastructure as Code
- **AWS VPC** - Network isolation
- **Amazon EKS** - Managed Kubernetes
- **AWS RDS** - Managed database with encryption
- **AWS KMS** - Key management
- **AWS WAF** - Web application firewall

#### 📁 Module Structure
```
modules/01-infrastructure-security/
├── docs/
│   ├── README.md                 # Module overview
│   ├── aws-security-best-practices.md
│   └── terraform-security-guide.md
├── exercises/
│   ├── 01-vpc-design.md
│   ├── 02-eks-hardening.md
│   ├── 03-rds-encryption.md
│   └── 04-waf-configuration.md
├── solutions/
│   └── terraform/
│       ├── vpc.tf
│       ├── eks.tf
│       ├── rds.tf
│       └── security.tf
└── scripts/
    ├── validate-security.sh
    └── cleanup.sh
```

### 🐳 **Module 2: Container Security**
**เรียนรู้การรักษาความปลอดภัยใน container environment**

#### 📚 Learning Objectives
- สร้าง secure Docker images ด้วย multi-stage builds
- ใช้ container image scanning tools
- จัดการ Kubernetes security policies
- ติดตั้ง network policies สำหรับ micro-segmentation
- Monitor container runtime security

#### 🛠️ Tools & Technologies
- **Docker** - Container platform
- **Trivy** - Container vulnerability scanner
- **Kubernetes Pod Security Standards**
- **Network Policies** - Traffic segmentation
- **Falco** - Runtime security monitoring
- **Amazon ECR** - Container registry with scanning

### 🔄 **Module 3: CI/CD Security Pipeline**
**เรียนรู้การสร้าง secure automation pipeline**

#### 📚 Learning Objectives
- สร้าง GitHub Actions workflow พร้อม security gates
- ใช้ SAST และ DAST scanning tools
- ตรวจสอบ dependencies และ infrastructure code
- จัดการ secrets อย่างปลอดภัย
- สร้าง approval workflow สำหรับ production

#### 🛠️ Tools & Technologies
- **GitHub Actions** - CI/CD platform
- **CodeQL** - Static application security testing
- **SonarQube** - Code quality และ security
- **Snyk** - Dependency scanning
- **TFSec/Checkov** - Infrastructure code scanning
- **TruffleHog** - Secret scanning

### 📊 **Module 4: Runtime Security & Monitoring**
**เรียนรู้การ monitor และ respond ต่อภัยคุกคาม**

#### 📚 Learning Objectives
- ตั้งค่า centralized security monitoring
- สร้าง security dashboards และ alerts
- ตรวจจับ anomalies และ threats
- สร้าง incident response playbook
- ใช้ threat intelligence feeds

#### 🛠️ Tools & Technologies
- **AWS Security Hub** - Centralized security findings
- **Amazon GuardDuty** - Threat detection
- **Prometheus** - Metrics collection
- **Grafana** - Visualization และ alerting
- **Falco** - Runtime security monitoring
- **CloudTrail** - API logging และ auditing

### 📋 **Module 5: Compliance & Governance**
**เรียนรู้การจัดการ compliance และ governance**

#### 📚 Learning Objectives
- สร้าง policy as code ด้วย OPA
- ปฏิบัติตาม PDPA และข้อกำหนดไทย
- จัดการ audit logging และ reporting
- สร้าง security governance framework
- ประเมิน risk และ vulnerability management

#### 🛠️ Tools & Technologies
- **Open Policy Agent (OPA)** - Policy as code
- **AWS Config** - Compliance monitoring
- **CloudFormation Guard** - Infrastructure policies
- **AWS CloudTrail** - Audit logging
- **Security compliance frameworks**

## 🎯 **Career Development Path**

### 💼 **Target Positions in Thailand**
- **DevSecOps Engineer** (฿80,000 - ฿150,000/month)
- **Cloud Security Architect** (฿100,000 - ฿200,000/month)  
- **Security Engineering Lead** (฿120,000 - ฿250,000/month)
- **Principal Security Engineer** (฿150,000 - ฿300,000/month)

### 🏢 **Target Companies**
- **Banks**: SCB, BBL, KBANK, KTB, TMB
- **FinTech**: SCB 10X, Kasikorn X, TrueMoney, Omise
- **E-commerce**: Lazada, Shopee, JD Central
- **Tech Companies**: LINE, Agoda, Grab Thailand
- **Consulting**: Accenture, Deloitte, PwC, AWS Professional Services

### 🎖️ **Certification Alignment**
- **AWS Security Specialty** - Modules 1, 4, 5
- **Certified Kubernetes Security Specialist (CKS)** - Modules 2, 3
- **CISSP** - All modules (security domains)
- **CISA** - Modules 4, 5 (audit และ governance)

## 🛡️ **Security Best Practices**

### 🔐 **Zero Trust Architecture**
- **Identity verification** for every user and device
- **Least privilege access** principles
- **Continuous monitoring** และ validation
- **Micro-segmentation** of network resources

### 🛡️ **Defense in Depth**
- **Perimeter security** (WAF, DDoS protection)
- **Network security** (VPC, Security Groups, NACLs)
- **Host security** (hardened AMIs, patch management)
- **Application security** (secure coding, SAST/DAST)
- **Data security** (encryption at rest/transit, DLP)

### 📊 **Security Metrics & KPIs**
- **Mean Time to Detection (MTTD)**
- **Mean Time to Response (MTTR)**
- **Vulnerability remediation time**
- **Security test coverage**
- **Compliance score**

## 🌏 **Thai Market Focus**

### 🏦 **Banking Sector Requirements**
- **Bank of Thailand (BOT)** IT risk management guidelines
- **Core banking system** security requirements
- **PCI DSS** compliance for payment processing
- **Data residency** requirements
- **Business continuity** planning

### 🛒 **E-commerce Compliance**
- **Personal Data Protection Act (PDPA)** compliance
- **Electronic Transactions Act** requirements
- **Consumer protection** regulations
- **Cross-border data transfer** restrictions

### 🏛️ **Government Cloud Regulations**
- **Government Cloud Service** (G-Cloud) requirements
- **Cybersecurity Act** compliance
- **National cybersecurity framework**
- **Critical information infrastructure** protection

## 🚀 **Getting Started**

### 📋 **Step-by-Step Setup**
1. **Prerequisites Check**: Run `./scripts/setup/check-prerequisites.sh`
2. **Tool Installation**: Run `./scripts/setup/install-tools.sh`
3. **AWS Configuration**: Configure your AWS credentials
4. **Infrastructure Deployment**: Deploy with Terraform
5. **Application Deployment**: Deploy to EKS
6. **Monitoring Setup**: Configure security monitoring

### 🔧 **Development Environment**
```bash
# Check if Docker is running
docker version

# Verify kubectl access
kubectl cluster-info

# Check Terraform installation
terraform version

# Verify AWS CLI configuration
aws sts get-caller-identity
```

### 📚 **Learning Resources**

#### 🎥 **Video Tutorials**
- [AWS Security Best Practices](docs/tutorials/aws-security-fundamentals.md)
- [Container Security Deep Dive](docs/tutorials/container-security.md)
- [CI/CD Security Implementation](docs/tutorials/cicd-security.md)

#### 📖 **Documentation**
- [Security Architecture Guide](docs/best-practices/security-architecture.md)
- [Thai Compliance Requirements](docs/best-practices/thai-compliance.md)
- [Troubleshooting Guide](docs/troubleshooting/common-issues.md)

#### 🔗 **External Resources**
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

## 🤝 **Contributing**

เรายินดีรับ contributions จากชุมชน! โปรดดู [CONTRIBUTING.md](CONTRIBUTING.md) สำหรับรายละเอียด

### 🐛 **Issue Reporting**
- ใช้ [GitHub Issues](https://github.com/nanthapat-j/devsecops-workshop/issues) สำหรับ bug reports
- ระบุ module และ environment ที่เกิดปัญหา
- แนบ error logs และ screenshots

### 💡 **Feature Requests**
- เสนอ features ใหม่ผ่าน GitHub Issues
- อธิบาย use case และ benefits
- พิจารณา Thai market requirements

## 📞 **Support & Community**

- **GitHub Discussions**: [Community Forum](https://github.com/nanthapat-j/devsecops-workshop/discussions)
- **Slack Channel**: #devsecops-thailand
- **LinkedIn Group**: DevSecOps Thailand
- **Meetup**: DevSecOps Bangkok Meetup

## 📜 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

### 🎉 **Ready to Start Your DevSecOps Journey?**

```bash
git clone https://github.com/nanthapat-j/devsecops-workshop.git
cd devsecops-workshop
./scripts/setup/check-prerequisites.sh
```

**Happy Learning! สนุกกับการเรียนรู้! 🚀**
