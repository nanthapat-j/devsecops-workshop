# DevSecOps Workshop - Thai Market Ready
# Makefile for automation and ease of use

.PHONY: help check-prerequisites install-tools deploy-all terraform-plan terraform-apply terraform-destroy
.PHONY: build-apps test-apps deploy-apps security-scan vulnerability-report compliance-check
.PHONY: setup-monitoring open-monitoring view-logs cost-report setup-billing-alerts cleanup-resources

# Default target
help: ## Show this help message
	@echo "🔒 DevSecOps Workshop - Available Commands"
	@echo "=========================================="
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Setup and Prerequisites
check-prerequisites: ## Check if all required tools are installed
	@echo "🔍 Checking prerequisites..."
	@./scripts/setup/check-prerequisites.sh

install-tools: ## Install required tools (requires sudo)
	@echo "🛠️ Installing required tools..."
	@./scripts/setup/install-dependencies.sh

##@ Infrastructure Management
terraform-plan: ## Review infrastructure changes (requires AWS credentials)
	@echo "📋 Planning Terraform deployment..."
	@cd infrastructure/terraform/environments/dev && terraform plan

terraform-apply: ## Deploy infrastructure to AWS
	@echo "🚀 Deploying infrastructure..."
	@cd infrastructure/terraform/environments/dev && terraform apply -auto-approve

terraform-destroy: ## Destroy infrastructure (use with caution!)
	@echo "💥 Destroying infrastructure..."
	@read -p "Are you sure? Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ] && \
	cd infrastructure/terraform/environments/dev && terraform destroy -auto-approve

##@ Application Management
build-apps: ## Build all applications
	@echo "🏗️ Building applications..."
	@./scripts/deployment/build-applications.sh

test-apps: ## Run application tests
	@echo "🧪 Running application tests..."
	@./scripts/deployment/test-applications.sh

deploy-apps: ## Deploy applications to Kubernetes
	@echo "🚢 Deploying applications..."
	@./scripts/deployment/deploy-applications.sh

##@ Security Operations
security-scan: ## Run comprehensive security scans
	@echo "🔍 Running security scans..."
	@./scripts/security/run-security-scans.sh

vulnerability-report: ## Generate vulnerability report
	@echo "📊 Generating vulnerability report..."
	@./scripts/security/generate-vulnerability-report.sh

compliance-check: ## Verify compliance status
	@echo "⚖️ Checking compliance status..."
	@./scripts/security/check-compliance.sh

##@ Monitoring and Observability
setup-monitoring: ## Deploy monitoring stack (Prometheus, Grafana)
	@echo "📊 Setting up monitoring..."
	@./scripts/monitoring/setup-monitoring.sh

open-monitoring: ## Open Grafana dashboard in browser
	@echo "🌐 Opening monitoring dashboard..."
	@kubectl port-forward svc/grafana 3000:80 -n monitoring &
	@sleep 3
	@echo "Grafana available at: http://localhost:3000"
	@echo "Default credentials: admin/admin"

view-logs: ## Stream application logs
	@echo "📜 Streaming application logs..."
	@kubectl logs -f deployment/api-gateway -n devsecops-workshop

##@ Cost Management
cost-report: ## Generate daily cost report
	@echo "💰 Generating cost report..."
	@./scripts/monitoring/generate-cost-report.sh

setup-billing-alerts: ## Configure AWS billing alerts
	@echo "🚨 Setting up billing alerts..."
	@./scripts/monitoring/setup-billing-alerts.sh

cleanup-resources: ## Clean up unused AWS resources
	@echo "🧹 Cleaning up unused resources..."
	@./scripts/monitoring/cleanup-resources.sh

##@ Complete Workflows
deploy-all: check-prerequisites terraform-apply build-apps deploy-apps setup-monitoring ## Deploy entire workshop environment
	@echo "🎉 Complete deployment finished!"
	@echo "Access monitoring: make open-monitoring"
	@echo "Run security scan: make security-scan"

destroy-all: terraform-destroy ## Destroy all resources and clean up
	@echo "🧹 All resources destroyed!"

##@ Development
dev-setup: ## Setup development environment
	@echo "👨‍💻 Setting up development environment..."
	@./scripts/setup/dev-setup.sh

test-all: test-apps security-scan compliance-check ## Run all tests and checks
	@echo "✅ All tests completed!"

##@ Documentation
docs-serve: ## Serve documentation locally
	@echo "📚 Serving documentation..."
	@cd docs && python3 -m http.server 8080

##@ Thai Specific
thai-compliance-report: ## Generate Thai compliance report
	@echo "🇹🇭 Generating Thai compliance report..."
	@./scripts/compliance/generate-thai-report.sh

pdpa-audit: ## Run PDPA compliance audit
	@echo "⚖️ Running PDPA compliance audit..."
	@./scripts/compliance/pdpa-audit.sh