#!/bin/bash

# DevSecOps Workshop - Application Deployment Script
# Deploy secure microservices to EKS cluster

set -e

echo "🚀 DevSecOps Workshop - Application Deployment"
echo "=============================================="

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
KUBERNETES_DIR="$PROJECT_ROOT/infrastructure/kubernetes"
ENVIRONMENT=${1:-dev}

echo -e "📁 ${BLUE}Project Root${NC}: $PROJECT_ROOT"
echo -e "☸️  ${BLUE}Kubernetes Directory${NC}: $KUBERNETES_DIR"
echo -e "🌍 ${BLUE}Environment${NC}: $ENVIRONMENT"
echo ""

# Check prerequisites
check_prerequisites() {
    echo -e "🔍 ${YELLOW}Checking prerequisites...${NC}"
    
    # Check kubectl
    if ! command -v kubectl >/dev/null 2>&1; then
        echo -e "❌ ${RED}kubectl not found${NC}"
        echo "Please install kubectl: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
    
    # Check helm
    if ! command -v helm >/dev/null 2>&1; then
        echo -e "❌ ${RED}helm not found${NC}"
        echo "Please install helm: https://helm.sh/docs/intro/install/"
        exit 1
    fi
    
    # Check kubectl connectivity
    if ! kubectl cluster-info >/dev/null 2>&1; then
        echo -e "❌ ${RED}Cannot connect to Kubernetes cluster${NC}"
        echo "Please configure kubectl: aws eks update-kubeconfig --region <region> --name <cluster-name>"
        exit 1
    fi
    
    echo -e "✅ ${GREEN}Prerequisites check completed${NC}"
    echo ""
}

# Create namespaces
create_namespaces() {
    echo -e "📦 ${YELLOW}Creating Kubernetes namespaces...${NC}"
    
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce
  labels:
    app.kubernetes.io/name: ecommerce
    app.kubernetes.io/part-of: devsecops-workshop
---
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
  labels:
    app.kubernetes.io/name: monitoring
    app.kubernetes.io/part-of: devsecops-workshop
---
apiVersion: v1
kind: Namespace
metadata:
  name: security
  labels:
    app.kubernetes.io/name: security
    app.kubernetes.io/part-of: devsecops-workshop
EOF
    
    echo -e "✅ ${GREEN}Namespaces created${NC}"
    echo ""
}

# Deploy applications
deploy_applications() {
    echo -e "🚀 ${YELLOW}Deploying applications to EKS...${NC}"
    
    # Create placeholder deployment for user service
    kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: ecommerce
  labels:
    app: user-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        securityContext:
          runAsNonRoot: true
          runAsUser: 1001
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: ecommerce
spec:
  selector:
    app: user-service
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
    
    echo -e "✅ ${GREEN}Applications deployed${NC}"
    echo ""
}

# Show deployment status
show_status() {
    echo -e "📊 ${BLUE}Deployment Status${NC}"
    echo "==================="
    
    echo -e "\n📦 ${YELLOW}Namespaces:${NC}"
    kubectl get namespaces -l app.kubernetes.io/part-of=devsecops-workshop
    
    echo -e "\n🚀 ${YELLOW}Applications:${NC}"
    kubectl get all -n ecommerce
    
    echo -e "\n💡 ${BLUE}Next Steps:${NC}"
    echo "1. Deploy monitoring: ./scripts/deployment/deploy-monitoring.sh"
    echo "2. Setup ingress: kubectl apply -f infrastructure/kubernetes/manifests/ingress.yml"
    echo "3. Check logs: kubectl logs -n ecommerce -l app=user-service"
    echo ""
}

# Main execution
main() {
    echo -e "🚀 ${GREEN}Starting application deployment${NC}"
    echo ""
    
    check_prerequisites
    create_namespaces
    deploy_applications
    show_status
    
    echo -e "🎉 ${GREEN}Application deployment completed!${NC}"
}

# Execute main function
main "$@"