#!/bin/bash
# DevSecOps Workshop - Prerequisites Checker
# Check if all required tools are installed for the workshop

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Thai messages
TITLE="🔒 DevSecOps Workshop - การตรวจสอบเครื่องมือที่จำเป็น"
CHECKING="🔍 กำลังตรวจสอบ"
FOUND="✅ พบแล้ว"
NOT_FOUND="❌ ไม่พบ"
WARNING="⚠️ คำเตือน"
SUCCESS="🎉 สำเร็จ"

echo -e "${BLUE}${TITLE}${NC}"
echo "=============================================="

# Function to check if command exists
check_command() {
    local cmd=$1
    local name=$2
    local version_cmd=$3
    local min_version=${4:-""}
    
    printf "%-30s" "${CHECKING} ${name}..."
    
    if command -v "$cmd" &> /dev/null; then
        local version=$(eval "$version_cmd" 2>/dev/null || echo "unknown")
        echo -e "${GREEN}${FOUND}${NC} (${version})"
        return 0
    else
        echo -e "${RED}${NOT_FOUND}${NC}"
        return 1
    fi
}

# Function to check AWS credentials
check_aws_credentials() {
    printf "%-30s" "${CHECKING} AWS Credentials..."
    
    if aws sts get-caller-identity &> /dev/null; then
        local account=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
        local region=$(aws configure get region 2>/dev/null || echo "not-set")
        echo -e "${GREEN}${FOUND}${NC} (Account: ${account}, Region: ${region})"
        
        # Check if region is set to ap-southeast-1 for Thai compliance
        if [[ "$region" != "ap-southeast-1" ]]; then
            echo -e "${YELLOW}${WARNING}${NC} แนะนำให้ใช้ ap-southeast-1 สำหรับการปฏิบัติตามกฎหมายไทย"
        fi
        return 0
    else
        echo -e "${RED}${NOT_FOUND}${NC}"
        echo -e "${YELLOW}${WARNING}${NC} กรุณาตั้งค่า AWS credentials: aws configure"
        return 1
    fi
}

# Function to check Kubernetes cluster access
check_kubernetes() {
    printf "%-30s" "${CHECKING} Kubernetes Cluster..."
    
    if kubectl cluster-info &> /dev/null; then
        local context=$(kubectl config current-context 2>/dev/null || echo "unknown")
        echo -e "${GREEN}${FOUND}${NC} (Context: ${context})"
        return 0
    else
        echo -e "${YELLOW}${WARNING}${NC} ไม่มี cluster (จะสร้างใหม่ด้วย Terraform)"
        return 0  # This is OK, we'll create the cluster
    fi
}

# Function to check Docker daemon
check_docker_daemon() {
    printf "%-30s" "${CHECKING} Docker Daemon..."
    
    if docker info &> /dev/null; then
        echo -e "${GREEN}${FOUND}${NC} (Running)"
        return 0
    else
        echo -e "${RED}${NOT_FOUND}${NC}"
        echo -e "${YELLOW}${WARNING}${NC} กรุณาเริ่มต้น Docker daemon"
        return 1
    fi
}

# Initialize counters
missing_tools=0
total_checks=0

echo ""
echo "🛠️ Core Tools (เครื่องมือหลัก):"
echo "================================"

# Check core tools
tools=(
    "aws:AWS CLI:aws --version"
    "terraform:Terraform:terraform version"
    "kubectl:Kubernetes CLI:kubectl version --client"
    "docker:Docker:docker --version"
    "helm:Helm:helm version --short"
    "node:Node.js:node --version"
    "npm:NPM:npm --version"
    "git:Git:git --version"
    "jq:jq JSON processor:jq --version"
    "curl:cURL:curl --version | head -1"
)

for tool in "${tools[@]}"; do
    IFS=':' read -r cmd name version_cmd <<< "$tool"
    total_checks=$((total_checks + 1))
    if ! check_command "$cmd" "$name" "$version_cmd"; then
        missing_tools=$((missing_tools + 1))
    fi
done

echo ""
echo "🔐 Security Tools (เครื่องมือด้านความปลอดภัย):"
echo "============================================="

# Check security tools (optional but recommended)
security_tools=(
    "trivy:Trivy Scanner:trivy --version"
    "hadolint:Dockerfile Linter:hadolint --version"
    "tfsec:Terraform Security:tfsec --version"
    "checkov:Infrastructure Scanner:checkov --version"
)

optional_missing=0
for tool in "${security_tools[@]}"; do
    IFS=':' read -r cmd name version_cmd <<< "$tool"
    if ! check_command "$cmd" "$name" "$version_cmd"; then
        optional_missing=$((optional_missing + 1))
    fi
done

echo ""
echo "☁️ Cloud and Kubernetes (คลาวด์และ Kubernetes):"
echo "=============================================="

# Check cloud and kubernetes connectivity
total_checks=$((total_checks + 1))
if ! check_aws_credentials; then
    missing_tools=$((missing_tools + 1))
fi

check_kubernetes
check_docker_daemon

echo ""
echo "📊 System Information (ข้อมูลระบบ):"
echo "===================================="

# System information
echo "Operating System: $(uname -s) $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Available Memory: $(free -h 2>/dev/null | awk '/^Mem:/ {print $2}' || echo 'N/A')"
echo "Available Disk: $(df -h . 2>/dev/null | awk 'NR==2 {print $4}' || echo 'N/A')"

echo ""
echo "📋 Summary (สรุปผล):"
echo "===================="

if [[ $missing_tools -eq 0 ]]; then
    echo -e "${GREEN}${SUCCESS} All required tools are installed! (เครื่องมือครบทุกอย่าง!)${NC}"
    echo ""
    echo "🚀 Ready to start the workshop! Run:"
    echo "   make deploy-all"
    exit 0
else
    echo -e "${RED}Missing ${missing_tools} required tools (ขาดเครื่องมือ ${missing_tools} ชิ้น)${NC}"
    echo ""
    echo "📥 To install missing tools (ติดตั้งเครื่องมือที่ขาด):"
    echo "   make install-tools"
    echo ""
    echo "📚 Manual installation guide:"
    echo "   https://github.com/nanthapat-j/devsecops-workshop/blob/main/docs/installation.md"
    exit 1
fi

if [[ $optional_missing -gt 0 ]]; then
    echo -e "${YELLOW}Note: ${optional_missing} optional security tools are missing${NC}"
    echo "These will be installed automatically during setup if needed."
fi