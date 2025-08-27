#!/bin/bash

# DevSecOps Workshop - Prerequisites Checker
# ตรวจสอบและแสดง prerequisites ที่จำเป็น

set -e

echo "🔒 DevSecOps Workshop - Prerequisites Checker"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if command exists
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}$1${NC} is installed"
        return 0
    else
        echo -e "❌ ${RED}$1${NC} is not installed"
        return 1
    fi
}

# Check version
check_version() {
    local cmd=$1
    local min_version=$2
    local current_version=$3
    
    echo -e "📋 ${YELLOW}$cmd${NC} version: $current_version (minimum: $min_version)"
}

echo ""
echo "📋 Checking required tools..."
echo ""

MISSING_TOOLS=0

# Docker
if check_command "docker"; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
    check_version "Docker" "20.10+" "$DOCKER_VERSION"
else
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
fi

# kubectl
if check_command "kubectl"; then
    KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null | cut -d' ' -f3)
    check_version "kubectl" "1.25+" "$KUBECTL_VERSION"
else
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
fi

# Terraform
if check_command "terraform"; then
    TERRAFORM_VERSION=$(terraform version | head -n1 | cut -d' ' -f2)
    check_version "Terraform" "1.5+" "$TERRAFORM_VERSION"
else
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
fi

# AWS CLI
if check_command "aws"; then
    AWS_VERSION=$(aws --version | cut -d' ' -f1 | cut -d'/' -f2)
    check_version "AWS CLI" "2.0+" "$AWS_VERSION"
    
    # Check AWS credentials
    echo ""
    echo "🔐 Checking AWS credentials..."
    if aws sts get-caller-identity >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}AWS credentials${NC} are configured"
        AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
        AWS_USER=$(aws sts get-caller-identity --query Arn --output text)
        echo -e "📋 Account: ${YELLOW}$AWS_ACCOUNT${NC}"
        echo -e "📋 User/Role: ${YELLOW}$AWS_USER${NC}"
    else
        echo -e "❌ ${RED}AWS credentials${NC} are not configured"
        echo "   Run: aws configure"
        MISSING_TOOLS=$((MISSING_TOOLS + 1))
    fi
else
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
fi

# Node.js
if check_command "node"; then
    NODE_VERSION=$(node --version)
    check_version "Node.js" "18+" "$NODE_VERSION"
else
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
fi

# npm
if check_command "npm"; then
    NPM_VERSION=$(npm --version)
    check_version "npm" "8+" "$NPM_VERSION"
else
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
fi

# Helm
if check_command "helm"; then
    HELM_VERSION=$(helm version --short | cut -d' ' -f1)
    check_version "Helm" "3.10+" "$HELM_VERSION"
else
    echo -e "⚠️  ${YELLOW}helm${NC} is not installed (optional, will be installed by setup script)"
fi

# Git
if check_command "git"; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    check_version "Git" "2.30+" "$GIT_VERSION"
else
    MISSING_TOOLS=$((MISSING_TOOLS + 1))
fi

echo ""
echo "🔍 Checking system requirements..."
echo ""

# Check operating system
OS=$(uname -s)
case $OS in
    "Linux")
        echo -e "✅ ${GREEN}Linux${NC} detected"
        # Check memory
        MEMORY_GB=$(free -g | awk '/^Mem:/{print $2}')
        if [ "$MEMORY_GB" -ge 8 ]; then
            echo -e "✅ ${GREEN}Memory${NC}: ${MEMORY_GB}GB (minimum: 8GB)"
        else
            echo -e "⚠️  ${YELLOW}Memory${NC}: ${MEMORY_GB}GB (recommended: 8GB+)"
        fi
        ;;
    "Darwin")
        echo -e "✅ ${GREEN}macOS${NC} detected"
        # Check memory on macOS
        MEMORY_GB=$(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2}' | cut -d' ' -f1)
        echo -e "📋 ${YELLOW}Memory${NC}: ${MEMORY_GB}GB"
        ;;
    *)
        echo -e "⚠️  ${YELLOW}$OS${NC} detected (Linux/macOS recommended)"
        ;;
esac

# Check disk space
DISK_SPACE=$(df -h . | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "${DISK_SPACE%.*}" -ge 20 ]; then
    echo -e "✅ ${GREEN}Disk space${NC}: Available space is sufficient"
else
    echo -e "⚠️  ${YELLOW}Disk space${NC}: ${DISK_SPACE}GB available (recommended: 20GB+)"
fi

echo ""
echo "================================================"

if [ $MISSING_TOOLS -eq 0 ]; then
    echo -e "🎉 ${GREEN}All prerequisites are met!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run: ./scripts/setup/install-tools.sh (to install optional tools)"
    echo "2. Run: ./scripts/deployment/deploy-infrastructure.sh"
    echo ""
    exit 0
else
    echo -e "❌ ${RED}$MISSING_TOOLS tool(s) missing${NC}"
    echo ""
    echo "📋 Installation guide:"
    echo ""
    echo "🐳 Docker:"
    echo "   - Linux: https://docs.docker.com/engine/install/"
    echo "   - macOS: https://docs.docker.com/desktop/mac/"
    echo "   - Windows: https://docs.docker.com/desktop/windows/"
    echo ""
    echo "☸️  kubectl:"
    echo "   curl -LO \"https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\""
    echo "   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl"
    echo ""
    echo "🏗️  Terraform:"
    echo "   - Download from: https://developer.hashicorp.com/terraform/downloads"
    echo "   - Or use package manager: brew install terraform (macOS)"
    echo ""
    echo "☁️  AWS CLI:"
    echo "   - Download from: https://aws.amazon.com/cli/"
    echo "   - Configure: aws configure"
    echo ""
    echo "🟢 Node.js:"
    echo "   - Download from: https://nodejs.org/"
    echo "   - Or use nvm: nvm install 18"
    echo ""
    echo "Or run the automated installer:"
    echo "./scripts/setup/install-tools.sh"
    echo ""
    exit 1
fi