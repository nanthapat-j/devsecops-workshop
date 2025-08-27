#!/bin/bash

# DevSecOps Workshop - Automated Tool Installer
# ติดตั้งเครื่องมือที่จำเป็นสำหรับ workshop

set -e

echo "🔒 DevSecOps Workshop - Tool Installer"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect OS
OS=$(uname -s)
ARCH=$(uname -m)

# Convert architecture names
case $ARCH in
    x86_64) ARCH="amd64" ;;
    arm64|aarch64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

echo -e "🖥️  ${BLUE}Detected OS${NC}: $OS"
echo -e "🏗️  ${BLUE}Architecture${NC}: $ARCH"
echo ""

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

install_helm() {
    echo -e "⚙️  ${YELLOW}Installing Helm...${NC}"
    
    if command -v helm >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}Helm already installed${NC}"
        return 0
    fi
    
    cd $TEMP_DIR
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    
    echo -e "✅ ${GREEN}Helm installed successfully${NC}"
}

install_trivy() {
    echo -e "⚙️  ${YELLOW}Installing Trivy...${NC}"
    
    if command -v trivy >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}Trivy already installed${NC}"
        return 0
    fi
    
    cd $TEMP_DIR
    
    case $OS in
        "Linux")
            wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
            echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
            sudo apt-get update
            sudo apt-get install trivy -y
            ;;
        "Darwin")
            if command -v brew >/dev/null 2>&1; then
                brew install trivy
            else
                echo -e "❌ ${RED}Homebrew not found. Please install Homebrew first.${NC}"
                return 1
            fi
            ;;
        *)
            echo -e "⚠️  ${YELLOW}Manual installation required for $OS${NC}"
            echo "Please visit: https://aquasecurity.github.io/trivy/latest/getting-started/installation/"
            return 1
            ;;
    esac
    
    echo -e "✅ ${GREEN}Trivy installed successfully${NC}"
}

install_dive() {
    echo -e "⚙️  ${YELLOW}Installing Dive (Docker image analyzer)...${NC}"
    
    if command -v dive >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}Dive already installed${NC}"
        return 0
    fi
    
    cd $TEMP_DIR
    
    case $OS in
        "Linux")
            wget https://github.com/wagoodman/dive/releases/download/v0.10.0/dive_0.10.0_linux_amd64.deb
            sudo apt install ./dive_0.10.0_linux_amd64.deb
            ;;
        "Darwin")
            if command -v brew >/dev/null 2>&1; then
                brew install dive
            else
                echo -e "❌ ${RED}Homebrew not found. Please install Homebrew first.${NC}"
                return 1
            fi
            ;;
        *)
            echo -e "⚠️  ${YELLOW}Manual installation required for $OS${NC}"
            echo "Please visit: https://github.com/wagoodman/dive"
            return 1
            ;;
    esac
    
    echo -e "✅ ${GREEN}Dive installed successfully${NC}"
}

install_k9s() {
    echo -e "⚙️  ${YELLOW}Installing k9s (Kubernetes CLI)...${NC}"
    
    if command -v k9s >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}k9s already installed${NC}"
        return 0
    fi
    
    case $OS in
        "Linux")
            if command -v snap >/dev/null 2>&1; then
                sudo snap install k9s
            else
                cd $TEMP_DIR
                wget https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz
                tar -xzf k9s_Linux_amd64.tar.gz
                sudo mv k9s /usr/local/bin/
                sudo chmod +x /usr/local/bin/k9s
            fi
            ;;
        "Darwin")
            if command -v brew >/dev/null 2>&1; then
                brew install k9s
            else
                echo -e "❌ ${RED}Homebrew not found. Please install Homebrew first.${NC}"
                return 1
            fi
            ;;
        *)
            echo -e "⚠️  ${YELLOW}Manual installation required for $OS${NC}"
            echo "Please visit: https://github.com/derailed/k9s"
            return 1
            ;;
    esac
    
    echo -e "✅ ${GREEN}k9s installed successfully${NC}"
}

install_opa() {
    echo -e "⚙️  ${YELLOW}Installing OPA (Open Policy Agent)...${NC}"
    
    if command -v opa >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}OPA already installed${NC}"
        return 0
    fi
    
    cd $TEMP_DIR
    
    case $OS in
        "Linux")
            curl -L -o opa https://openpolicyagent.org/downloads/v0.55.0/opa_linux_${ARCH}_static
            sudo mv opa /usr/local/bin/
            sudo chmod +x /usr/local/bin/opa
            ;;
        "Darwin")
            if command -v brew >/dev/null 2>&1; then
                brew install opa
            else
                curl -L -o opa https://openpolicyagent.org/downloads/v0.55.0/opa_darwin_${ARCH}
                sudo mv opa /usr/local/bin/
                sudo chmod +x /usr/local/bin/opa
            fi
            ;;
        *)
            echo -e "⚠️  ${YELLOW}Manual installation required for $OS${NC}"
            echo "Please visit: https://www.openpolicyagent.org/docs/latest/#running-opa"
            return 1
            ;;
    esac
    
    echo -e "✅ ${GREEN}OPA installed successfully${NC}"
}

install_tfsec() {
    echo -e "⚙️  ${YELLOW}Installing tfsec (Terraform security scanner)...${NC}"
    
    if command -v tfsec >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}tfsec already installed${NC}"
        return 0
    fi
    
    case $OS in
        "Linux"|"Darwin")
            if command -v brew >/dev/null 2>&1; then
                brew install tfsec
            else
                cd $TEMP_DIR
                OS_LOWER=$(echo $OS | tr '[:upper:]' '[:lower:]')
                curl -L -o tfsec https://github.com/aquasecurity/tfsec/releases/download/v1.28.1/tfsec-${OS_LOWER}-${ARCH}
                sudo mv tfsec /usr/local/bin/
                sudo chmod +x /usr/local/bin/tfsec
            fi
            ;;
        *)
            echo -e "⚠️  ${YELLOW}Manual installation required for $OS${NC}"
            echo "Please visit: https://github.com/aquasecurity/tfsec"
            return 1
            ;;
    esac
    
    echo -e "✅ ${GREEN}tfsec installed successfully${NC}"
}

setup_docker_compose() {
    echo -e "⚙️  ${YELLOW}Setting up Docker Compose files...${NC}"
    
    # Create docker-compose.yml for local development
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Local PostgreSQL for development
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: devuser
      POSTGRES_PASSWORD: devpass123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./applications/databases/init:/docker-entrypoint-initdb.d
    networks:
      - ecommerce-network

  # Redis for caching
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    networks:
      - ecommerce-network

  # Local DynamoDB for development
  dynamodb-local:
    image: amazon/dynamodb-local
    command: ["-jar", "DynamoDBLocal.jar", "-sharedDb", "-dbPath", "./data"]
    ports:
      - "8000:8000"
    volumes:
      - dynamodb_data:/home/dynamodblocal/data
    networks:
      - ecommerce-network

  # Prometheus for monitoring
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    networks:
      - monitoring-network

  # Grafana for visualization
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/provisioning:/etc/grafana/provisioning
    networks:
      - monitoring-network

volumes:
  postgres_data:
  dynamodb_data:
  prometheus_data:
  grafana_data:

networks:
  ecommerce-network:
    driver: bridge
  monitoring-network:
    driver: bridge
EOF
    
    echo -e "✅ ${GREEN}Docker Compose configuration created${NC}"
}

create_makefile() {
    echo -e "⚙️  ${YELLOW}Creating Makefile for common tasks...${NC}"
    
    cat > Makefile << 'EOF'
.PHONY: help setup check-prereq install-tools clean start stop logs

# Default target
help:
	@echo "🔒 DevSecOps Workshop - Available Commands"
	@echo "==========================================="
	@echo ""
	@echo "Setup Commands:"
	@echo "  make check-prereq    - Check prerequisites"
	@echo "  make install-tools   - Install additional tools"
	@echo "  make setup          - Complete setup (prereq + tools)"
	@echo ""
	@echo "Development Commands:"
	@echo "  make start          - Start local development environment"
	@echo "  make stop           - Stop local development environment"
	@echo "  make logs           - View logs from all services"
	@echo "  make clean          - Clean up containers and volumes"
	@echo ""
	@echo "Infrastructure Commands:"
	@echo "  make deploy-infra   - Deploy AWS infrastructure"
	@echo "  make deploy-apps    - Deploy applications to EKS"
	@echo "  make deploy-monitoring - Deploy monitoring stack"
	@echo ""
	@echo "Security Commands:"
	@echo "  make scan-images    - Scan Docker images for vulnerabilities"
	@echo "  make scan-terraform - Scan Terraform code for security issues"
	@echo "  make scan-code      - Run SAST scanning on application code"
	@echo ""

check-prereq:
	@./scripts/setup/check-prerequisites.sh

install-tools:
	@./scripts/setup/install-tools.sh

setup: check-prereq install-tools
	@echo "✅ Setup completed successfully!"

start:
	@echo "🚀 Starting local development environment..."
	@docker-compose up -d
	@echo "✅ Development environment started!"
	@echo "📊 Grafana: http://localhost:3001 (admin/admin123)"
	@echo "📈 Prometheus: http://localhost:9090"
	@echo "🗄️  PostgreSQL: localhost:5432 (devuser/devpass123)"
	@echo "🔴 Redis: localhost:6379"
	@echo "📚 DynamoDB Local: http://localhost:8000"

stop:
	@echo "🛑 Stopping local development environment..."
	@docker-compose down
	@echo "✅ Development environment stopped!"

logs:
	@docker-compose logs -f

clean:
	@echo "🧹 Cleaning up containers and volumes..."
	@docker-compose down -v
	@docker system prune -f
	@echo "✅ Cleanup completed!"

deploy-infra:
	@./scripts/deployment/deploy-infrastructure.sh

deploy-apps:
	@./scripts/deployment/deploy-applications.sh

deploy-monitoring:
	@./scripts/deployment/deploy-monitoring.sh

scan-images:
	@echo "🔍 Scanning Docker images..."
	@find . -name "Dockerfile" -exec dirname {} \; | sort -u | while read dir; do \
		echo "Scanning $$dir..."; \
		trivy fs $$dir; \
	done

scan-terraform:
	@echo "🔍 Scanning Terraform code..."
	@tfsec ./infrastructure/terraform/

scan-code:
	@echo "🔍 Running SAST scanning..."
	@if command -v semgrep >/dev/null 2>&1; then \
		semgrep --config=auto ./applications/; \
	else \
		echo "⚠️  Semgrep not installed. Install with: pip install semgrep"; \
	fi
EOF
    
    echo -e "✅ ${GREEN}Makefile created${NC}"
}

# Main installation process
echo "📦 Installing additional DevSecOps tools..."
echo ""

# Install tools
install_helm
install_trivy
install_dive
install_k9s
install_opa
install_tfsec

echo ""
echo "⚙️  Setting up development environment..."
echo ""

# Setup development environment
setup_docker_compose
create_makefile

echo ""
echo "================================================"
echo -e "🎉 ${GREEN}All tools installed successfully!${NC}"
echo ""
echo "📋 Installed tools:"
echo "  ✅ Helm - Kubernetes package manager"
echo "  ✅ Trivy - Container vulnerability scanner"
echo "  ✅ Dive - Docker image analyzer"
echo "  ✅ k9s - Kubernetes CLI"
echo "  ✅ OPA - Open Policy Agent"
echo "  ✅ tfsec - Terraform security scanner"
echo ""
echo "📁 Created files:"
echo "  ✅ docker-compose.yml - Local development environment"
echo "  ✅ Makefile - Common tasks automation"
echo ""
echo "🚀 Next steps:"
echo "  1. Configure AWS credentials: aws configure"
echo "  2. Start local environment: make start"
echo "  3. Deploy infrastructure: make deploy-infra"
echo ""
echo "💡 Use 'make help' to see all available commands"
echo ""