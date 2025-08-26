# 🔒 DevSecOps Workshop
> **Workshop การพัฒนาและปรับใช้ระบบความปลอดภัยแบบบูรณาการ**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Workshop Status](https://img.shields.io/badge/Status-Active-green.svg)]()
[![Thai Support](https://img.shields.io/badge/Thai-Supported-blue.svg)]()

## 📋 **ภาพรวม Workshop**

Workshop นี้ออกแบบมาเพื่อสอนการบูรณาการความปลอดภัย (Security) เข้ากับ DevOps pipeline แบบครบวงจร ตั้งแต่การพัฒนาโค้ด ไปจนถึงการ deploy และ monitor ในสภาพแวดล้อม production

### 🎯 **เป้าหมายการเรียนรู้**
- เข้าใจหลักการ DevSecOps และความสำคัญในยุคดิจิทัล
- สามารถสร้าง secure CI/CD pipeline ที่ครบวงจร
- ใช้เครื่องมือ security scanning และ monitoring ได้จริง
- ประยุกต์ใช้ security best practices ในโปรเจคจริง

## 🚀 **Quick Start**

```bash
# Clone repository
git clone https://github.com/nanthapat-j/devsecops-workshop.git
cd devsecops-workshop

# One-command setup (รันทุกอย่างอัตโนมัติ)
./scripts/setup.sh

# Deploy sample microservices
./scripts/deploy.sh

# Access monitoring dashboard
kubectl port-forward svc/grafana 3000:80 -n monitoring
