#!/bin/bash

# DevSecOps Workshop - Infrastructure Deployment Script
# Deploy secure AWS infrastructure using Terraform

set -e

echo "🏗️  DevSecOps Workshop - Infrastructure Deployment"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TERRAFORM_DIR="$PROJECT_ROOT/infrastructure/terraform"
ENVIRONMENT=${1:-dev}

echo -e "📁 ${BLUE}Project Root${NC}: $PROJECT_ROOT"
echo -e "🏗️  ${BLUE}Terraform Directory${NC}: $TERRAFORM_DIR"
echo -e "🌍 ${BLUE}Environment${NC}: $ENVIRONMENT"
echo ""

# Check prerequisites
check_prerequisites() {
    echo -e "🔍 ${YELLOW}Checking prerequisites...${NC}"
    
    # Check if AWS CLI is installed and configured
    if ! command -v aws >/dev/null 2>&1; then
        echo -e "❌ ${RED}AWS CLI not found${NC}"
        echo "Please install AWS CLI: https://aws.amazon.com/cli/"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        echo -e "❌ ${RED}AWS credentials not configured${NC}"
        echo "Please run: aws configure"
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform >/dev/null 2>&1; then
        echo -e "❌ ${RED}Terraform not found${NC}"
        echo "Please install Terraform: https://www.terraform.io/downloads.html"
        exit 1
    fi
    
    # Check kubectl
    if ! command -v kubectl >/dev/null 2>&1; then
        echo -e "⚠️  ${YELLOW}kubectl not found${NC}"
        echo "Install kubectl for EKS management"
    fi
    
    echo -e "✅ ${GREEN}Prerequisites check completed${NC}"
    echo ""
}

# Initialize Terraform
init_terraform() {
    echo -e "🔧 ${YELLOW}Initializing Terraform...${NC}"
    
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform
    if terraform init; then
        echo -e "✅ ${GREEN}Terraform initialized successfully${NC}"
    else
        echo -e "❌ ${RED}Terraform initialization failed${NC}"
        exit 1
    fi
    
    echo ""
}

# Validate Terraform configuration
validate_terraform() {
    echo -e "🔍 ${YELLOW}Validating Terraform configuration...${NC}"
    
    cd "$TERRAFORM_DIR"
    
    # Format Terraform files
    terraform fmt -recursive
    
    # Validate configuration
    if terraform validate; then
        echo -e "✅ ${GREEN}Terraform configuration is valid${NC}"
    else
        echo -e "❌ ${RED}Terraform validation failed${NC}"
        exit 1
    fi
    
    echo ""
}

# Plan Terraform deployment
plan_terraform() {
    echo -e "📋 ${YELLOW}Planning Terraform deployment...${NC}"
    
    cd "$TERRAFORM_DIR"
    
    # Create terraform.tfvars for the environment if it doesn't exist
    TFVARS_FILE="environments/${ENVIRONMENT}/terraform.tfvars"
    if [ ! -f "$TFVARS_FILE" ]; then
        echo -e "📄 ${YELLOW}Creating $TFVARS_FILE...${NC}"
        mkdir -p "environments/${ENVIRONMENT}"
        cat > "$TFVARS_FILE" << EOF
# DevSecOps Workshop - ${ENVIRONMENT} Environment Configuration
aws_region     = "ap-southeast-1"
environment    = "${ENVIRONMENT}"
project_name   = "devsecops-workshop"
owner          = "DevSecOps-Team"

# Network Configuration
vpc_cidr = "10.0.0.0/16"

# EKS Configuration
eks_version = "1.28"
node_instance_types = ["t3.medium"]
node_desired_capacity = 2
node_max_capacity = 5
node_min_capacity = 1

# RDS Configuration
rds_instance_class = "db.t3.micro"
rds_allocated_storage = 20
rds_db_name = "ecommerce"
rds_username = "dbadmin"

# Security Configuration
enable_geo_blocking = false
allowed_countries = ["TH", "SG", "US"]

# Thai Compliance
enable_pdpa_compliance = true
data_residency_requirement = true
enable_audit_logging = true
EOF
        echo -e "✅ ${GREEN}Created $TFVARS_FILE${NC}"
    fi
    
    # Plan deployment
    if terraform plan -var-file="$TFVARS_FILE" -out="terraform-${ENVIRONMENT}.tfplan"; then
        echo -e "✅ ${GREEN}Terraform plan completed successfully${NC}"
        echo ""
        echo -e "📋 ${BLUE}Plan Summary:${NC}"
        terraform show -no-color "terraform-${ENVIRONMENT}.tfplan" | grep -E "(Plan:|Changes to Outputs)"
    else
        echo -e "❌ ${RED}Terraform planning failed${NC}"
        exit 1
    fi
    
    echo ""
}

# Apply Terraform deployment
apply_terraform() {
    echo -e "🚀 ${YELLOW}Applying Terraform deployment...${NC}"
    echo -e "⚠️  ${YELLOW}This will create AWS resources and may incur costs${NC}"
    echo ""
    
    # Confirm deployment
    read -p "Do you want to proceed with the deployment? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo -e "❌ ${RED}Deployment cancelled${NC}"
        exit 0
    fi
    
    cd "$TERRAFORM_DIR"
    
    # Apply the plan
    if terraform apply "terraform-${ENVIRONMENT}.tfplan"; then
        echo -e "✅ ${GREEN}Infrastructure deployed successfully!${NC}"
        
        # Save outputs
        terraform output -json > "outputs-${ENVIRONMENT}.json"
        echo -e "📄 ${GREEN}Outputs saved to outputs-${ENVIRONMENT}.json${NC}"
    else
        echo -e "❌ ${RED}Terraform deployment failed${NC}"
        exit 1
    fi
    
    echo ""
}

# Configure kubectl for EKS
configure_kubectl() {
    echo -e "⚙️  ${YELLOW}Configuring kubectl for EKS...${NC}"
    
    cd "$TERRAFORM_DIR"
    
    # Get cluster name from Terraform output
    CLUSTER_NAME=$(terraform output -raw eks_cluster_name 2>/dev/null || echo "")
    AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "ap-southeast-1")
    
    if [ -n "$CLUSTER_NAME" ]; then
        echo -e "🔧 ${BLUE}Configuring kubectl for cluster: $CLUSTER_NAME${NC}"
        
        if aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"; then
            echo -e "✅ ${GREEN}kubectl configured successfully${NC}"
            
            # Test connection
            echo -e "🔍 ${YELLOW}Testing kubectl connection...${NC}"
            if kubectl get nodes; then
                echo -e "✅ ${GREEN}EKS cluster is accessible${NC}"
            else
                echo -e "⚠️  ${YELLOW}EKS cluster may still be initializing${NC}"
            fi
        else
            echo -e "❌ ${RED}Failed to configure kubectl${NC}"
        fi
    else
        echo -e "⚠️  ${YELLOW}Could not retrieve cluster name from Terraform output${NC}"
    fi
    
    echo ""
}

# Display deployment summary
show_summary() {
    echo -e "🎉 ${GREEN}Deployment Summary${NC}"
    echo "=========================="
    
    cd "$TERRAFORM_DIR"
    
    # Display key outputs
    echo -e "📋 ${BLUE}Infrastructure Details:${NC}"
    
    if terraform output >/dev/null 2>&1; then
        echo "AWS Region: $(terraform output -raw aws_region 2>/dev/null || echo 'N/A')"
        echo "VPC ID: $(terraform output -raw vpc_id 2>/dev/null || echo 'N/A')"
        echo "EKS Cluster: $(terraform output -raw eks_cluster_name 2>/dev/null || echo 'N/A')"
        echo "RDS Endpoint: $(terraform output -raw rds_endpoint 2>/dev/null || echo 'N/A')"
        
        echo ""
        echo -e "💰 ${BLUE}Estimated Monthly Cost:${NC}"
        terraform output estimated_monthly_cost 2>/dev/null || echo "Cost information not available"
        
        echo ""
        echo -e "🔗 ${BLUE}Next Steps:${NC}"
        terraform output next_steps 2>/dev/null || echo "Next steps information not available"
    else
        echo "Terraform outputs not available"
    fi
    
    echo ""
    echo -e "📚 ${BLUE}Useful Commands:${NC}"
    echo "  # View all Terraform outputs"
    echo "  terraform output"
    echo ""
    echo "  # Configure kubectl (if not done automatically)"
    echo "  aws eks update-kubeconfig --region ap-southeast-1 --name \$(terraform output -raw eks_cluster_name)"
    echo ""
    echo "  # Check EKS nodes"
    echo "  kubectl get nodes"
    echo ""
    echo "  # Deploy applications"
    echo "  ./scripts/deployment/deploy-applications.sh"
    echo ""
    echo "  # Setup monitoring"
    echo "  ./scripts/deployment/deploy-monitoring.sh"
    echo ""
}

# Cleanup function
cleanup() {
    echo ""
    echo -e "🧹 ${YELLOW}Cleaning up temporary files...${NC}"
    cd "$TERRAFORM_DIR"
    rm -f "terraform-${ENVIRONMENT}.tfplan"
}

# Error handling
handle_error() {
    echo ""
    echo -e "❌ ${RED}An error occurred during deployment${NC}"
    echo ""
    echo -e "🔍 ${BLUE}Troubleshooting steps:${NC}"
    echo "1. Check AWS credentials: aws sts get-caller-identity"
    echo "2. Verify Terraform configuration: terraform validate"
    echo "3. Check AWS permissions for EC2, EKS, RDS, IAM"
    echo "4. Review Terraform logs for detailed error messages"
    echo ""
    echo -e "📚 ${BLUE}Documentation:${NC}"
    echo "  Module 1 docs: modules/01-infrastructure-security/docs/README.md"
    echo "  Troubleshooting: docs/troubleshooting/common-issues.md"
    echo ""
    cleanup
    exit 1
}

# Set up error handling
trap handle_error ERR

# Main execution
main() {
    echo -e "🚀 ${GREEN}Starting infrastructure deployment for ${ENVIRONMENT} environment${NC}"
    echo ""
    
    check_prerequisites
    init_terraform
    validate_terraform
    plan_terraform
    apply_terraform
    configure_kubectl
    show_summary
    cleanup
    
    echo -e "🎉 ${GREEN}Infrastructure deployment completed successfully!${NC}"
    echo ""
    echo -e "📖 ${BLUE}What's next?${NC}"
    echo "1. Review the deployed infrastructure in AWS Console"
    echo "2. Proceed to Module 2: Container Security"
    echo "3. Deploy the sample e-commerce application"
    echo "4. Set up monitoring and security scanning"
    echo ""
}

# Execute main function
main "$@"