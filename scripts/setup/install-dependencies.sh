#!/bin/bash
# DevSecOps Workshop - Tool Installation Script
# Install required tools for the workshop

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Thai messages
TITLE="🛠️ DevSecOps Workshop - การติดตั้งเครื่องมือ"
INSTALLING="📥 กำลังติดตั้ง"
INSTALLED="✅ ติดตั้งสำเร็จ"
SKIPPED="⏭️ ข้าม (มีอยู่แล้ว)"
ERROR="❌ เกิดข้อผิดพลาด"

echo -e "${BLUE}${TITLE}${NC}"
echo "=============================================="

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if command -v apt-get &> /dev/null; then
        DISTRO="ubuntu"
    elif command -v yum &> /dev/null; then
        DISTRO="rhel"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
fi

echo "Detected OS: $OS"

# Function to install tool if not exists
install_if_missing() {
    local cmd=$1
    local name=$2
    local install_func=$3
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${YELLOW}${SKIPPED}${NC} $name"
        return 0
    fi
    
    echo -e "${BLUE}${INSTALLING}${NC} $name..."
    if $install_func; then
        echo -e "${GREEN}${INSTALLED}${NC} $name"
        return 0
    else
        echo -e "${RED}${ERROR}${NC} $name"
        return 1
    fi
}

# Installation functions
install_aws_cli() {
    if [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install awscli
        else
            echo "Please install Homebrew first: https://brew.sh"
            return 1
        fi
    elif [[ "$OS" == "linux" ]]; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
    fi
}

install_terraform() {
    local version="1.6.0"
    if [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew tap hashicorp/tap
            brew install hashicorp/tap/terraform
        else
            # Manual installation for macOS
            curl -fsSL "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_darwin_amd64.zip" -o terraform.zip
            unzip -q terraform.zip
            sudo mv terraform /usr/local/bin/
            rm terraform.zip
        fi
    elif [[ "$OS" == "linux" ]]; then
        curl -fsSL "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip" -o terraform.zip
        unzip -q terraform.zip
        sudo mv terraform /usr/local/bin/
        rm terraform.zip
    fi
}

install_kubectl() {
    if [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install kubectl
        else
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
            chmod +x kubectl
            sudo mv kubectl /usr/local/bin/
        fi
    elif [[ "$OS" == "linux" ]]; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
    fi
}

install_docker() {
    if [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install --cask docker
            echo "Please start Docker Desktop manually"
        else
            echo "Please install Docker Desktop for Mac: https://docs.docker.com/docker-for-mac/install/"
            return 1
        fi
    elif [[ "$OS" == "linux" ]]; then
        if [[ "$DISTRO" == "ubuntu" ]]; then
            # Install Docker on Ubuntu
            sudo apt-get update
            sudo apt-get install -y ca-certificates curl gnupg lsb-release
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io
            sudo usermod -aG docker $USER
            sudo systemctl enable docker
            sudo systemctl start docker
        else
            echo "Please install Docker manually for your distribution"
            return 1
        fi
    fi
}

install_helm() {
    if [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install helm
        else
            curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        fi
    elif [[ "$OS" == "linux" ]]; then
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
}

install_nodejs() {
    local version="18"
    if [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install node@${version}
            brew link node@${version}
        else
            echo "Please install Node.js manually: https://nodejs.org"
            return 1
        fi
    elif [[ "$OS" == "linux" ]]; then
        # Install Node.js using NodeSource repository
        curl -fsSL https://deb.nodesource.com/setup_${version}.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
}

install_security_tools() {
    echo ""
    echo "🔐 Installing Security Tools (ติดตั้งเครื่องมือด้านความปลอดภัย):"
    echo "============================================="
    
    # Install Trivy
    if ! command -v trivy &> /dev/null; then
        echo -e "${BLUE}${INSTALLING}${NC} Trivy..."
        if [[ "$OS" == "linux" ]]; then
            sudo apt-get update
            sudo apt-get install -y wget apt-transport-https gnupg lsb-release
            wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
            echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
            sudo apt-get update
            sudo apt-get install -y trivy
        elif [[ "$OS" == "macos" ]] && command -v brew &> /dev/null; then
            brew install trivy
        fi
    fi
    
    # Install hadolint
    if ! command -v hadolint &> /dev/null; then
        echo -e "${BLUE}${INSTALLING}${NC} Hadolint..."
        if [[ "$OS" == "linux" ]]; then
            sudo wget -O /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
            sudo chmod +x /usr/local/bin/hadolint
        elif [[ "$OS" == "macos" ]] && command -v brew &> /dev/null; then
            brew install hadolint
        fi
    fi
    
    # Install tfsec
    if ! command -v tfsec &> /dev/null; then
        echo -e "${BLUE}${INSTALLING}${NC} TFSec..."
        if [[ "$OS" == "linux" ]]; then
            curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
        elif [[ "$OS" == "macos" ]] && command -v brew &> /dev/null; then
            brew install tfsec
        fi
    fi
    
    # Install Checkov
    if ! command -v checkov &> /dev/null; then
        echo -e "${BLUE}${INSTALLING}${NC} Checkov..."
        pip3 install checkov
    fi
}

# Main installation process
echo ""
echo "🛠️ Core Tools (เครื่องมือหลัก):"
echo "================================"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${YELLOW}Warning: Running as root. Some installations might behave differently.${NC}"
fi

# Install core tools
install_if_missing "aws" "AWS CLI" install_aws_cli
install_if_missing "terraform" "Terraform" install_terraform
install_if_missing "kubectl" "Kubectl" install_kubectl
install_if_missing "docker" "Docker" install_docker
install_if_missing "helm" "Helm" install_helm
install_if_missing "node" "Node.js" install_nodejs

# Install additional tools
if [[ "$OS" == "linux" ]] && [[ "$DISTRO" == "ubuntu" ]]; then
    echo ""
    echo "📦 Additional Tools:"
    echo "==================="
    sudo apt-get update
    sudo apt-get install -y jq curl git unzip tree make
elif [[ "$OS" == "macos" ]] && command -v brew &> /dev/null; then
    echo ""
    echo "📦 Additional Tools:"
    echo "==================="
    brew install jq curl git unzip tree make
fi

# Install security tools
install_security_tools

echo ""
echo "✅ Installation Complete! (การติดตั้งเสร็จสิ้น!)"
echo "=============================================="
echo ""
echo "🔄 Please restart your terminal or run:"
echo "   source ~/.bashrc  # หรือ source ~/.zshrc"
echo ""
echo "🧪 To verify installation:"
echo "   make check-prerequisites"
echo ""
echo "🚀 To start the workshop:"
echo "   make deploy-all"

# Post-installation notes
echo ""
echo "📝 Post-installation Notes (หมายเหตุหลังติดตั้ง):"
echo "=============================================="
echo "1. AWS CLI: Run 'aws configure' to set up credentials"
echo "2. Docker: Make sure Docker daemon is running"
echo "3. Kubernetes: EKS cluster will be created during deployment"
echo "4. กรุณาตั้งค่า AWS region เป็น ap-southeast-1 สำหรับการปฏิบัติตามกฎหมายไทย"