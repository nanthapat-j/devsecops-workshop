# ⚖️ Module 6: Thai Compliance & Governance

## 📋 ภาพรวม Module

Module นี้จะสอนการปฏิบัติตามกฎระเบียบและข้อกำหนดของประเทศไทย โดยเฉพาะ PDPA และแนวทางการบริหารความเสี่ยงด้าน IT ของธนาคารแห่งประเทศไทย รวมถึงการใช้ Policy as Code สำหรับ automated compliance

### 🎯 Learning Objectives

เมื่อจบ Module นี้ คุณจะสามารถ:

1. **⚖️ PDPA Compliance**
   - เข้าใจหลักการและข้อกำหนดของ PDPA
   - ใช้งาน data classification และ retention policies
   - ตั้งค่า consent management และ data subject rights

2. **🏛️ Banking Regulations**
   - ปฏิบัติตามแนวทางของธนาคารแห่งประเทศไทย
   - ใช้งาน risk management frameworks
   - ตั้งค่า audit และ reporting systems

3. **📋 Policy as Code**
   - ใช้ Open Policy Agent (OPA) สำหรับ compliance automation
   - สร้าง Kubernetes admission controllers
   - ตั้งค่า AWS Config rules

4. **📊 Compliance Monitoring**
   - สร้าง compliance dashboards
   - ตั้งค่า automated reporting
   - ใช้งาน continuous compliance monitoring

## 🇹🇭 Personal Data Protection Act (PDPA)

### 📖 PDPA Overview

PDPA ใช้บังคับตั้งแต่ 1 มิถุนายน 2565 และมีผลกับทุกองค์กรที่เก็บรวบรวม ใช้ หรือเปิดเผยข้อมูลส่วนบุคคล

**Key Principles:**
- **Lawfulness** - มีฐานทางกฎหมายในการเก็บข้อมูล
- **Fairness** - เก็บข้อมูลโดยสุจริตและโปร่งใส
- **Transparency** - แจ้งวัตถุประสงค์และวิธีการใช้ข้อมูล
- **Purpose Limitation** - ใช้ข้อมูลตามวัตถุประสงค์ที่แจ้งไว้เท่านั้น
- **Data Minimization** - เก็บข้อมูลเท่าที่จำเป็น
- **Accuracy** - รักษาความถูกต้องของข้อมูล
- **Storage Limitation** - เก็บข้อมูลไม่เกินระยะเวลาที่จำเป็น
- **Security** - มีมาตรการรักษาความปลอดภัยข้อมูล

### 🔒 Technical Implementation

**1. Data Classification**

```yaml
# data-classification-policy.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: data-classification-policy
  namespace: compliance
data:
  policy.rego: |
    package dataclassification
    
    # PDPA Data Categories
    sensitive_data := {
        "personal_data": {
            "description": "ข้อมูลส่วนบุคคล",
            "examples": ["name", "email", "phone", "address"],
            "retention_days": 2555,  # 7 years
            "encryption_required": true,
            "access_logging": true
        },
        "sensitive_personal_data": {
            "description": "ข้อมูลส่วนบุคคลอ่อนไหว",
            "examples": ["race", "religion", "health", "financial"],
            "retention_days": 1825,  # 5 years
            "encryption_required": true,
            "access_logging": true,
            "additional_consent": true
        },
        "public_data": {
            "description": "ข้อมูลสาธารณะ",
            "examples": ["company_info", "product_details"],
            "retention_days": 3650,  # 10 years
            "encryption_required": false,
            "access_logging": false
        }
    }
    
    # Classification Rules
    classify_data(data_type) = classification {
        classification := sensitive_data[data_type]
    }
    
    # Retention Policy
    retention_required(data_type, days_stored) {
        max_days := sensitive_data[data_type].retention_days
        days_stored > max_days
    }
```

**2. Consent Management**

```javascript
// consent-management.js
class PDPAConsentManager {
    constructor() {
        this.consentTypes = {
            NECESSARY: 'necessary',           // จำเป็นสำหรับการให้บริการ
            FUNCTIONAL: 'functional',         // ปรับปรุงการใช้งาน
            ANALYTICS: 'analytics',           // วิเคราะห์การใช้งาน
            MARKETING: 'marketing'            // การตลาด
        };
    }

    // บันทึก Consent
    async recordConsent(userId, consentData) {
        const consent = {
            userId: userId,
            timestamp: new Date().toISOString(),
            consentId: this.generateConsentId(),
            purpose: consentData.purpose,
            consentTypes: consentData.consentTypes,
            ipAddress: consentData.ipAddress,
            userAgent: consentData.userAgent,
            expiryDate: this.calculateExpiryDate(consentData.purpose),
            pdpaVersion: '2565',  // PDPA BE 2565
            language: 'th'
        };

        // เข้ารหัสและบันทึกลงฐานข้อมูล
        await this.encryptAndStore(consent);
        
        // Log การให้ consent
        await this.auditLog('CONSENT_RECORDED', consent);
        
        return consent.consentId;
    }

    // ตรวจสอบ Consent
    async validateConsent(userId, purpose) {
        const consent = await this.getLatestConsent(userId, purpose);
        
        if (!consent) {
            return { valid: false, reason: 'NO_CONSENT' };
        }
        
        if (new Date() > new Date(consent.expiryDate)) {
            return { valid: false, reason: 'CONSENT_EXPIRED' };
        }
        
        return { valid: true, consent: consent };
    }

    // ถอน Consent (Right to Withdraw)
    async withdrawConsent(userId, consentId, reason) {
        const withdrawal = {
            userId: userId,
            consentId: consentId,
            withdrawalDate: new Date().toISOString(),
            reason: reason,
            status: 'WITHDRAWN'
        };
        
        await this.updateConsentStatus(consentId, 'WITHDRAWN');
        await this.auditLog('CONSENT_WITHDRAWN', withdrawal);
        
        // ทำการลบข้อมูลหรือหยุดการประมวลผลตามที่จำเป็น
        await this.processDataDeletion(userId, consentId);
        
        return withdrawal;
    }

    // สิทธิในการเข้าถึงข้อมูล (Right of Access)
    async exportUserData(userId, requestId) {
        const dataCategories = await this.getUserDataCategories(userId);
        const exportData = {};
        
        for (const category of dataCategories) {
            const data = await this.getDataByCategory(userId, category);
            exportData[category] = this.anonymizeIfRequired(data, category);
        }
        
        // สร้างรายงานการส่งออกข้อมูล
        const exportReport = {
            requestId: requestId,
            userId: userId,
            exportDate: new Date().toISOString(),
            dataCategories: Object.keys(exportData),
            format: 'JSON',
            encryption: 'AES-256'
        };
        
        await this.auditLog('DATA_EXPORT', exportReport);
        
        return {
            data: exportData,
            report: exportReport
        };
    }
}
```

**3. Data Retention Implementation**

```python
# data_retention.py
import boto3
from datetime import datetime, timedelta
from typing import Dict, List
import logging

class PDPADataRetention:
    def __init__(self):
        self.s3_client = boto3.client('s3')
        self.rds_client = boto3.client('rds')
        self.retention_policies = {
            'personal_data': 2555,      # 7 years
            'financial_data': 1825,     # 5 years  
            'marketing_data': 365,      # 1 year
            'analytics_data': 730,      # 2 years
            'audit_logs': 3650         # 10 years (regulatory requirement)
        }
    
    def apply_retention_policy(self, data_type: str, bucket_name: str):
        """ใช้ retention policy กับ S3 objects"""
        
        retention_days = self.retention_policies.get(data_type)
        if not retention_days:
            raise ValueError(f"No retention policy for {data_type}")
        
        # ตั้งค่า S3 Lifecycle Policy
        lifecycle_config = {
            'Rules': [
                {
                    'ID': f'{data_type}_retention_rule',
                    'Status': 'Enabled',
                    'Filter': {
                        'Prefix': f'{data_type}/'
                    },
                    'Expiration': {
                        'Days': retention_days
                    },
                    'Transitions': [
                        {
                            'Days': 30,
                            'StorageClass': 'STANDARD_IA'
                        },
                        {
                            'Days': 90,
                            'StorageClass': 'GLACIER'
                        }
                    ]
                }
            ]
        }
        
        self.s3_client.put_bucket_lifecycle_configuration(
            Bucket=bucket_name,
            LifecycleConfiguration=lifecycle_config
        )
        
        logging.info(f"Applied retention policy for {data_type}: {retention_days} days")

    def schedule_data_deletion(self, user_id: str, data_categories: List[str]):
        """จัดกำหนดการลบข้อมูลอัตโนมัติ"""
        
        for category in data_categories:
            retention_days = self.retention_policies.get(category)
            deletion_date = datetime.now() + timedelta(days=retention_days)
            
            # บันทึกกำหนดการลบในระบบ
            deletion_schedule = {
                'user_id': user_id,
                'data_category': category,
                'deletion_date': deletion_date.isoformat(),
                'status': 'SCHEDULED',
                'created_at': datetime.now().isoformat()
            }
            
            self.create_deletion_schedule(deletion_schedule)
    
    def execute_scheduled_deletions(self):
        """ดำเนินการลบข้อมูลตามกำหนดการ"""
        
        today = datetime.now().date()
        scheduled_deletions = self.get_due_deletions(today)
        
        for deletion in scheduled_deletions:
            try:
                # ลบข้อมูลจากแหล่งต่างๆ
                self.delete_user_data(
                    deletion['user_id'], 
                    deletion['data_category']
                )
                
                # อัพเดทสถานะ
                self.update_deletion_status(deletion['id'], 'COMPLETED')
                
                # บันทึก audit log
                self.audit_log('DATA_DELETED', deletion)
                
            except Exception as e:
                logging.error(f"Failed to delete data: {e}")
                self.update_deletion_status(deletion['id'], 'FAILED')

    def generate_retention_report(self) -> Dict:
        """สร้างรายงานการเก็บรักษาข้อมูล"""
        
        report = {
            'report_date': datetime.now().isoformat(),
            'retention_policies': self.retention_policies,
            'active_schedules': self.count_active_schedules(),
            'completed_deletions': self.count_completed_deletions(),
            'compliance_status': 'COMPLIANT'
        }
        
        return report
```

## 🏛️ Bank of Thailand (BOT) IT Risk Management

### 📋 BOT Requirements

ธนาคารแห่งประเทศไทยกำหนดแนวทางการบริหารความเสี่ยงด้าน IT สำหรับสถาบันการเงิน:

**Key Requirements:**
1. **IT Governance** - การกำกับดูแลระบบ IT
2. **Risk Management** - การบริหารความเสี่ยง
3. **Business Continuity** - ความต่อเนื่องทางธุรกิจ
4. **Information Security** - ความปลอดภัยข้อมูล
5. **Outsourcing Management** - การบริหาร vendor

### 🔒 Technical Implementation

**1. Risk Assessment Framework**

```yaml
# bot-risk-assessment.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: bot-risk-assessment
  namespace: compliance
data:
  risk-framework.yaml: |
    risk_categories:
      operational:
        description: "ความเสี่ยงด้านการดำเนินงาน"
        controls:
          - access_management
          - change_management
          - incident_response
          - business_continuity
        
      credit:
        description: "ความเสี่ยงด้านเครดิต"
        controls:
          - credit_scoring
          - portfolio_monitoring
          - exposure_limits
          
      market:
        description: "ความเสี่ยงด้านตลาด"
        controls:
          - market_data_integrity
          - trading_limits
          - valuation_controls
          
      liquidity:
        description: "ความเสี่ยงด้านสภาพคล่อง"
        controls:
          - cash_management
          - funding_monitoring
          - stress_testing
    
    risk_levels:
      high:
        score_range: [8, 10]
        approval_required: "board_level"
        monitoring_frequency: "daily"
        
      medium:
        score_range: [4, 7]
        approval_required: "management_level"
        monitoring_frequency: "weekly"
        
      low:
        score_range: [1, 3]
        approval_required: "operational_level"
        monitoring_frequency: "monthly"
```

**2. Business Continuity Planning**

```terraform
# business-continuity.tf
# Multi-region deployment for business continuity

# Primary region (ap-southeast-1)
provider "aws" {
  alias  = "primary"
  region = "ap-southeast-1"
}

# Secondary region (ap-southeast-2) for DR
provider "aws" {
  alias  = "secondary"
  region = "ap-southeast-2"
}

# RDS Cross-region backup
resource "aws_db_instance" "primary" {
  provider = aws.primary
  
  allocated_storage     = 100
  engine               = "postgres"
  engine_version       = "14.9"
  instance_class       = "db.r5.large"
  identifier           = "${var.environment}-primary-db"
  
  # Backup configuration for BOT compliance
  backup_retention_period = 35  # 35 days retention
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"
  
  # Cross-region automated backups
  copy_tags_to_snapshot = true
  
  # Encryption (required for financial data)
  storage_encrypted = true
  kms_key_id       = aws_kms_key.database.arn
  
  tags = {
    Environment = var.environment
    Compliance  = "BOT"
    DataType    = "Financial"
    BackupType  = "Primary"
  }
}

# Cross-region read replica for disaster recovery
resource "aws_db_instance" "dr_replica" {
  provider = aws.secondary
  
  identifier             = "${var.environment}-dr-replica"
  replicate_source_db    = aws_db_instance.primary.identifier
  instance_class         = "db.r5.large"
  
  # Auto-failover configuration
  auto_minor_version_upgrade = false
  
  tags = {
    Environment = var.environment
    Compliance  = "BOT"
    Purpose     = "DisasterRecovery"
  }
}

# CloudWatch monitoring for RTO/RPO compliance
resource "aws_cloudwatch_metric_alarm" "database_availability" {
  alarm_name          = "${var.environment}-db-availability"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors database availability"
  
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.primary.id
  }
  
  alarm_actions = [aws_sns_topic.bot_alerts.arn]
  
  tags = {
    Compliance = "BOT"
    AlertType  = "Availability"
  }
}
```

**3. Audit Trail and Reporting**

```python
# bot_audit.py
class BOTAuditCompliance:
    def __init__(self):
        self.audit_requirements = {
            'transaction_logs': {
                'retention_period': 2555,  # 7 years
                'fields_required': [
                    'timestamp', 'user_id', 'transaction_type',
                    'amount', 'account_number', 'ip_address',
                    'device_id', 'risk_score'
                ]
            },
            'access_logs': {
                'retention_period': 1095,  # 3 years
                'fields_required': [
                    'timestamp', 'user_id', 'resource_accessed',
                    'action', 'result', 'ip_address', 'user_agent'
                ]
            },
            'system_logs': {
                'retention_period': 365,   # 1 year
                'fields_required': [
                    'timestamp', 'service', 'level', 'message',
                    'trace_id', 'environment'
                ]
            }
        }
    
    def generate_bot_report(self, start_date: str, end_date: str) -> Dict:
        """สร้างรายงานสำหรับ BOT"""
        
        report = {
            'report_period': {
                'start_date': start_date,
                'end_date': end_date
            },
            'compliance_metrics': {
                'system_availability': self.calculate_availability(),
                'incident_count': self.count_incidents(),
                'security_events': self.count_security_events(),
                'backup_success_rate': self.calculate_backup_success_rate()
            },
            'risk_assessment': {
                'operational_risk': self.assess_operational_risk(),
                'cyber_risk': self.assess_cyber_risk(),
                'third_party_risk': self.assess_third_party_risk()
            },
            'audit_findings': self.get_audit_findings(),
            'remediation_actions': self.get_remediation_actions()
        }
        
        return report
    
    def validate_transaction_integrity(self, transaction_id: str) -> bool:
        """ตรวจสอบความถูกต้องของธุรกรรม"""
        
        transaction = self.get_transaction(transaction_id)
        
        # ตรวจสอบ digital signature
        if not self.verify_digital_signature(transaction):
            return False
        
        # ตรวจสอบ hash integrity
        if not self.verify_hash_integrity(transaction):
            return False
        
        # ตรวจสอบ timestamp
        if not self.verify_timestamp(transaction):
            return False
        
        return True
    
    def monitor_regulatory_compliance(self) -> Dict:
        """ติดตามการปฏิบัติตามกฎระเบียบ"""
        
        compliance_status = {
            'pdpa_compliance': self.check_pdpa_compliance(),
            'bot_guidelines': self.check_bot_guidelines(),
            'data_retention': self.check_data_retention(),
            'security_controls': self.check_security_controls(),
            'business_continuity': self.check_business_continuity()
        }
        
        overall_score = sum(compliance_status.values()) / len(compliance_status)
        
        return {
            'overall_compliance_score': overall_score,
            'individual_scores': compliance_status,
            'last_assessment': datetime.now().isoformat(),
            'next_assessment': (datetime.now() + timedelta(days=30)).isoformat()
        }
```

## 📋 Policy as Code with Open Policy Agent (OPA)

### 🔧 OPA Implementation

**1. Kubernetes Admission Controller**

```rego
# kubernetes-policies.rego
package kubernetes.admission

import data.kubernetes.resources

# ห้ามใช้ privileged containers (BOT security requirement)
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.object.spec.containers[_].securityContext.privileged == true
    msg := "Privileged containers are not allowed"
}

# บังคับใช้ resource limits (performance และ availability)
deny[msg] {
    input.request.kind.kind == "Pod"
    container := input.request.object.spec.containers[_]
    not container.resources.limits.memory
    msg := sprintf("Container '%s' must have memory limits", [container.name])
}

# บังคับใช้ Thai data residency labels
deny[msg] {
    input.request.kind.kind == "Pod"
    not input.request.object.metadata.labels["data.residency"]
    msg := "Pods must have data residency labels for compliance"
}

# ตรวจสอบ image registry (security requirement)
deny[msg] {
    input.request.kind.kind == "Pod"
    container := input.request.object.spec.containers[_]
    not startswith(container.image, "your-secure-registry.com/")
    msg := sprintf("Container '%s' must use approved registry", [container.name])
}

# PDPA compliance check
deny[msg] {
    input.request.kind.kind == "Pod"
    input.request.object.metadata.labels["data.type"] == "personal"
    not input.request.object.metadata.labels["pdpa.consent"]
    msg := "Personal data pods must have PDPA consent labels"
}
```

**2. AWS Config Rules**

```python
# aws_config_rules.py
import boto3
import json

class ThaiComplianceConfigRules:
    def __init__(self):
        self.config_client = boto3.client('config')
    
    def create_pdpa_compliance_rules(self):
        """สร้าง AWS Config rules สำหรับ PDPA compliance"""
        
        rules = [
            {
                'ConfigRuleName': 'encrypted-volumes-pdpa',
                'Description': 'Check if EBS volumes are encrypted (PDPA requirement)',
                'Source': {
                    'Owner': 'AWS',
                    'SourceIdentifier': 'ENCRYPTED_VOLUMES'
                },
                'InputParameters': json.dumps({
                    'kmsId': 'alias/pdpa-encryption-key'
                })
            },
            {
                'ConfigRuleName': 'rds-storage-encrypted-pdpa',
                'Description': 'Check if RDS storage is encrypted (PDPA requirement)',
                'Source': {
                    'Owner': 'AWS',
                    'SourceIdentifier': 'RDS_STORAGE_ENCRYPTED'
                }
            },
            {
                'ConfigRuleName': 's3-bucket-ssl-requests-only',
                'Description': 'Check if S3 buckets require SSL requests',
                'Source': {
                    'Owner': 'AWS',
                    'SourceIdentifier': 'S3_BUCKET_SSL_REQUESTS_ONLY'
                }
            },
            {
                'ConfigRuleName': 'cloudtrail-enabled-thai-region',
                'Description': 'Check if CloudTrail is enabled in Thai-compliant regions',
                'Source': {
                    'Owner': 'AWS',
                    'SourceIdentifier': 'CLOUD_TRAIL_ENABLED'
                },
                'InputParameters': json.dumps({
                    'requiredRegions': 'ap-southeast-1'
                })
            }
        ]
        
        for rule in rules:
            self.config_client.put_config_rule(ConfigRule=rule)
    
    def create_bot_compliance_rules(self):
        """สร้าง AWS Config rules สำหรับ BOT compliance"""
        
        rules = [
            {
                'ConfigRuleName': 'multi-az-rds-bot',
                'Description': 'Check if RDS instances are Multi-AZ (BOT requirement)',
                'Source': {
                    'Owner': 'AWS',
                    'SourceIdentifier': 'RDS_MULTI_AZ_SUPPORT'
                }
            },
            {
                'ConfigRuleName': 'backup-enabled-bot',
                'Description': 'Check if automated backups are enabled',
                'Source': {
                    'Owner': 'AWS',
                    'SourceIdentifier': 'DB_INSTANCE_BACKUP_ENABLED'
                },
                'InputParameters': json.dumps({
                    'requiredRetentionDays': '35'
                })
            }
        ]
        
        for rule in rules:
            self.config_client.put_config_rule(ConfigRule=rule)
```

## 📊 Compliance Monitoring and Reporting

### 📈 Compliance Dashboard

```yaml
# compliance-dashboard.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: compliance-dashboard-config
  namespace: monitoring
data:
  dashboard.json: |
    {
      "dashboard": {
        "title": "Thai Compliance Dashboard",
        "panels": [
          {
            "title": "PDPA Compliance Score",
            "type": "stat",
            "targets": [
              {
                "expr": "pdpa_compliance_score",
                "legendFormat": "PDPA Score"
              }
            ],
            "thresholds": [
              {"color": "red", "value": 0.7},
              {"color": "yellow", "value": 0.8},
              {"color": "green", "value": 0.9}
            ]
          },
          {
            "title": "BOT Compliance Status",
            "type": "table",
            "targets": [
              {
                "expr": "bot_compliance_metrics",
                "format": "table"
              }
            ]
          },
          {
            "title": "Data Retention Compliance",
            "type": "graph",
            "targets": [
              {
                "expr": "data_retention_compliance_by_category",
                "legendFormat": "{{category}}"
              }
            ]
          },
          {
            "title": "Audit Events",
            "type": "logs",
            "targets": [
              {
                "expr": "{job=\"audit-service\"} |= \"COMPLIANCE\""
              }
            ]
          }
        ]
      }
    }
```

### 📋 Automated Compliance Reporting

```python
# compliance_reporter.py
from datetime import datetime, timedelta
from typing import Dict, List
import boto3
import pandas as pd

class ThaiComplianceReporter:
    def __init__(self):
        self.s3_client = boto3.client('s3')
        self.config_client = boto3.client('config')
        self.cloudwatch_client = boto3.client('cloudwatch')
    
    def generate_monthly_compliance_report(self) -> Dict:
        """สร้างรายงานการปฏิบัติตามกฎระเบียบรายเดือน"""
        
        end_date = datetime.now()
        start_date = end_date - timedelta(days=30)
        
        report = {
            'report_metadata': {
                'report_type': 'monthly_compliance',
                'period_start': start_date.isoformat(),
                'period_end': end_date.isoformat(),
                'generated_at': datetime.now().isoformat(),
                'report_version': '1.0'
            },
            'pdpa_compliance': self.assess_pdpa_compliance(start_date, end_date),
            'bot_compliance': self.assess_bot_compliance(start_date, end_date),
            'security_metrics': self.get_security_metrics(start_date, end_date),
            'incident_summary': self.get_incident_summary(start_date, end_date),
            'recommendations': self.generate_recommendations()
        }
        
        # บันทึกรายงานใน S3
        self.save_report_to_s3(report, 'monthly-compliance-reports')
        
        return report
    
    def assess_pdpa_compliance(self, start_date: datetime, end_date: datetime) -> Dict:
        """ประเมินการปฏิบัติตาม PDPA"""
        
        return {
            'data_processing_consent': {
                'total_processing_activities': self.count_processing_activities(start_date, end_date),
                'activities_with_consent': self.count_consented_activities(start_date, end_date),
                'consent_rate': self.calculate_consent_rate(start_date, end_date)
            },
            'data_subject_rights': {
                'access_requests': self.count_access_requests(start_date, end_date),
                'deletion_requests': self.count_deletion_requests(start_date, end_date),
                'response_time_avg': self.calculate_avg_response_time(start_date, end_date),
                'compliance_rate': self.calculate_rights_compliance_rate(start_date, end_date)
            },
            'data_retention': {
                'categories_monitored': self.count_data_categories(),
                'expired_data_deleted': self.count_expired_data_deletions(start_date, end_date),
                'retention_compliance_rate': self.calculate_retention_compliance_rate()
            },
            'security_incidents': {
                'data_breaches': self.count_data_breaches(start_date, end_date),
                'breach_notifications': self.count_breach_notifications(start_date, end_date),
                'notification_timeliness': self.assess_notification_timeliness(start_date, end_date)
            }
        }
    
    def assess_bot_compliance(self, start_date: datetime, end_date: datetime) -> Dict:
        """ประเมินการปฏิบัติตามแนวทาง BOT"""
        
        return {
            'system_availability': {
                'uptime_percentage': self.calculate_system_uptime(start_date, end_date),
                'rto_compliance': self.assess_rto_compliance(start_date, end_date),
                'rpo_compliance': self.assess_rpo_compliance(start_date, end_date)
            },
            'risk_management': {
                'risk_assessments_completed': self.count_risk_assessments(start_date, end_date),
                'high_risk_items': self.count_high_risk_items(),
                'mitigation_actions': self.count_mitigation_actions(start_date, end_date)
            },
            'audit_compliance': {
                'audit_logs_retained': self.verify_audit_log_retention(),
                'transaction_integrity': self.verify_transaction_integrity(start_date, end_date),
                'control_effectiveness': self.assess_control_effectiveness()
            },
            'third_party_management': {
                'vendor_assessments': self.count_vendor_assessments(start_date, end_date),
                'sla_compliance': self.calculate_sla_compliance(start_date, end_date),
                'contract_reviews': self.count_contract_reviews(start_date, end_date)
            }
        }
    
    def generate_recommendations(self) -> List[Dict]:
        """สร้างข้อเสนอแนะสำหรับการปรับปรุง"""
        
        recommendations = []
        
        # ตรวจสอบคะแนน compliance และให้ข้อเสนอแนะ
        pdpa_score = self.get_pdpa_compliance_score()
        if pdpa_score < 0.9:
            recommendations.append({
                'category': 'PDPA',
                'priority': 'HIGH',
                'title': 'ปรับปรุงการจัดการ Consent',
                'description': 'อัตราการได้รับ consent ยังต่ำกว่าเป้าหมาย',
                'action_items': [
                    'ปรับปรุง UI/UX สำหรับการขอ consent',
                    'เพิ่มการอธิบายเหตุผลการใช้ข้อมูล',
                    'ติดตั้งระบบ consent management ที่ดีขึ้น'
                ]
            })
        
        bot_score = self.get_bot_compliance_score()
        if bot_score < 0.85:
            recommendations.append({
                'category': 'BOT',
                'priority': 'MEDIUM',
                'title': 'เสริมสร้างความต่อเนื่องทางธุรกิจ',
                'description': 'ระบบ backup และ disaster recovery ต้องปรับปรุง',
                'action_items': [
                    'ทดสอบ disaster recovery plan',
                    'ปรับปรุงระบบ automated backup',
                    'เพิ่ม cross-region redundancy'
                ]
            })
        
        return recommendations
```

## 🧪 Hands-on Exercise

### 📝 Exercise 1: PDPA Consent Management

**Goal:** ติดตั้งระบบจัดการ consent ที่สอดคล้องกับ PDPA

```bash
# 1. Deploy consent management service
kubectl apply -f compliance/pdpa/consent-service.yaml

# 2. Configure data retention policies
kubectl apply -f compliance/pdpa/retention-policies.yaml

# 3. Set up audit logging
kubectl apply -f compliance/pdpa/audit-logging.yaml

# 4. Test consent workflow
curl -X POST http://localhost:8080/api/consent \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "test-user-001",
    "purpose": "analytics",
    "consentTypes": ["functional", "analytics"],
    "language": "th"
  }'

# 5. Verify consent storage
kubectl exec -it consent-service-pod -- \
  cat /data/consent/test-user-001.json
```

### 📝 Exercise 2: BOT Compliance Monitoring

**Goal:** ตั้งค่า monitoring สำหรับ BOT compliance requirements

```bash
# 1. Deploy compliance monitoring
kubectl apply -f compliance/bot/monitoring-stack.yaml

# 2. Configure alerting rules
kubectl apply -f compliance/bot/alert-rules.yaml

# 3. Test availability monitoring
# Simulate service downtime
kubectl scale deployment api-gateway --replicas=0

# Check alert firing
curl http://prometheus:9090/api/v1/alerts

# Restore service
kubectl scale deployment api-gateway --replicas=3

# 4. Generate compliance report
python scripts/compliance/generate-bot-report.py \
  --start-date="2024-01-01" \
  --end-date="2024-01-31"
```

## 📊 Assessment

### ✅ Knowledge Check

**1. PDPA Requirements**
```
Q: ระยะเวลาการเก็บรักษาข้อมูลส่วนบุคคลตาม PDPA คือเท่าไหร่?
A: ขึ้นอยู่กับวัตถุประสงค์ แต่โดยทั่วไป:
   - ข้อมูลทั่วไป: 7 ปี
   - ข้อมูลการเงิน: 5 ปี (ตามกฎหมายบัญชี)
   - ข้อมูลการตลาด: 1 ปี
```

**2. BOT Guidelines**
```
Q: RTO (Recovery Time Objective) ที่แนะนำสำหรับระบบธนาคารคือเท่าไหร่?
A: ระบบสำคัญ (Critical): 2-4 ชั่วโมง
   ระบบทั่วไป (Important): 8-24 ชั่วโมง
```

### 🧪 Practical Assessment

**Deploy Complete Compliance Stack:**

```bash
# 1. Deploy all compliance components
make deploy-compliance

# 2. Run compliance assessment
make assess-compliance

# 3. Generate reports
make generate-compliance-reports

# 4. Verify all requirements
make validate-thai-compliance
```

**Success Criteria:**
- ✅ PDPA consent management operational
- ✅ Data retention policies enforced
- ✅ BOT monitoring and alerting active
- ✅ Audit trails comprehensive
- ✅ Compliance reports generated
- ✅ Policy as Code implemented

## 🎯 Next Steps

**Module 6 Completed! 🎉**

You have successfully:
- ✅ Implemented PDPA compliance framework
- ✅ Set up BOT compliance monitoring
- ✅ Created Policy as Code with OPA
- ✅ Built automated compliance reporting

**Career Impact:**
- 💼 Ready for fintech and banking interviews
- 📋 Portfolio demonstrates compliance expertise
- ⚖️ Understanding of Thai regulatory landscape
- 🚀 Prepared for senior security roles

**Final Workshop Steps:**
1. **Complete Portfolio**: Add compliance demonstrations
2. **Practice Presentations**: Prepare for interviews
3. **Continue Learning**: Stay updated with regulations

**Continue to:** [Module 7: Career Guide](07-career-guide.md)

---

**📚 Additional Resources:**

- [PDPA Official Text (Thai)](https://www.pdpc.gov.sg/overview-of-pdpa)
- [BOT IT Guidelines](https://www.bot.or.th/)
- [Open Policy Agent Documentation](https://www.openpolicyagent.org/docs/)
- [AWS Config Rules Library](https://docs.aws.amazon.com/config/)
- [Thai Cybersecurity Standards](https://www.ncsa.or.th/)