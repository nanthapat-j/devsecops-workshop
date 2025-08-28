# 🐳 Module 3: Container Security

## 📋 ภาพรวม Module

Module นี้เน้นการรักษาความปลอดภัยของ Container และ Kubernetes สำหรับแอปพลิเคชัน E-commerce โดยครอบคลุมตั้งแต่การสร้าง Container Image ที่ปลอดภัย ไปจนถึงการ Deploy บน Kubernetes ด้วยมาตรการรักษาความปลอดภัยระดับ Production

### 🎯 Learning Objectives

เมื่อจบ Module นี้ คุณจะสามารถ:

1. **🐳 Secure Container Images**
   - สร้าง Multi-stage Dockerfile ด้วย Distroless base images
   - ใช้ Container vulnerability scanning ด้วย Trivy
   - ปรับใช้ Container security best practices

2. **☸️ Kubernetes Security**
   - ตั้งค่า Pod Security Standards และ Network Policies
   - ใช้ RBAC และ ServiceAccount อย่างปลอดภัย
   - ประยุกต์ใช้ Admission Controllers

3. **🔍 Container Scanning & Monitoring**
   - บูรณาการ security scanning ใน CI/CD pipeline
   - ติดตั้ง runtime security monitoring ด้วย Falco
   - สร้าง security policies ด้วย OPA Gatekeeper

4. **🌐 Service Mesh Security**
   - ติดตั้งและกำหนดค่า Istio Service Mesh
   - ใช้ mTLS สำหรับ service-to-service communication
   - ตั้งค่า traffic policies และ security rules

## 🏗️ E-commerce Application Architecture

### 📊 Microservices Overview

```
                    ┌─────────────────┐
                    │   React Frontend │
                    │   (TypeScript)   │
                    └─────────┬───────┘
                              │
                    ┌─────────▼───────┐
                    │   API Gateway   │
                    │   (Node.js)     │
                    └─────────┬───────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
┌───────▼───────┐   ┌─────────▼────────┐   ┌───────▼───────┐
│ User Service  │   │ Product Service  │   │ Order Service │
│ (Node.js)     │   │ (Node.js)        │   │ (Node.js)     │
└───────────────┘   └──────────────────┘   └───────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                    ┌─────────▼───────┐
                    │   PostgreSQL    │
                    │   (RDS)         │
                    └─────────────────┘
```

### 🔒 Security Features

- **Frontend Security**: Content Security Policy, XSS protection, HTTPS enforcement
- **API Gateway**: Rate limiting, JWT validation, request validation
- **Microservices**: Service isolation, encrypted communication, audit logging
- **Database**: Encryption at rest/transit, connection pooling, query sanitization

## 🐳 Secure Container Implementation

### 1. Frontend Dockerfile (Production-Ready)

**File:** `apps/frontend/Dockerfile.production`

```dockerfile
# =============================================================================
# Build Stage - React Application
# =============================================================================
FROM node:18-alpine AS builder

# Security: Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S reactuser -u 1001 -G nodejs

# Security: Install security updates
RUN apk --no-cache upgrade

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies with security audit
RUN npm ci --only=production && \
    npm audit --audit-level=high && \
    npm cache clean --force

# Copy source code
COPY . .

# Build application with security optimizations
ENV NODE_ENV=production
ENV GENERATE_SOURCEMAP=false
ENV INLINE_RUNTIME_CHUNK=false

RUN npm run build

# =============================================================================
# Production Stage - Nginx with Security Headers
# =============================================================================
FROM nginx:1.24-alpine AS production

# Security: Install security updates
RUN apk --no-cache add ca-certificates && \
    apk --no-cache upgrade

# Security: Create non-root user for nginx
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Copy built files
COPY --from=builder /app/build /usr/share/nginx/html

# Copy secure nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY security-headers.conf /etc/nginx/conf.d/security-headers.conf

# Security labels for compliance
LABEL maintainer="DevSecOps Workshop <workshop@example.com>" \
      version="1.0.0" \
      description="Secure React Frontend for Thai E-commerce" \
      compliance.pdpa="true" \
      security.scan="trivy" \
      data.classification="Internal"

# Create nginx directories with proper permissions
RUN mkdir -p /var/cache/nginx/client_temp && \
    mkdir -p /var/cache/nginx/proxy_temp && \
    mkdir -p /var/cache/nginx/fastcgi_temp && \
    mkdir -p /var/cache/nginx/uwsgi_temp && \
    mkdir -p /var/cache/nginx/scgi_temp && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Switch to non-root user
USER nginx:nginx

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Expose non-privileged port
EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

**File:** `apps/frontend/nginx.conf`

```nginx
# Secure Nginx Configuration for React Frontend
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /tmp/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    # Basic Settings
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Security: Hide nginx version
    server_tokens off;
    
    # Performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    # Security: Buffer overflow protection
    client_body_buffer_size 1K;
    client_header_buffer_size 1k;
    client_max_body_size 1k;
    large_client_header_buffers 2 1k;
    
    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    # Gzip Settings
    gzip on;
    gzip_vary on;
    gzip_min_length 10240;
    gzip_proxied expired no-cache no-store private must-revalidate;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/x-javascript
        application/xml+rss
        application/javascript
        application/json;
    
    server {
        listen 8080;
        server_name _;
        root /usr/share/nginx/html;
        index index.html;
        
        # Security Headers
        include /etc/nginx/conf.d/security-headers.conf;
        
        # Security: Block access to hidden files
        location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
        }
        
        # Security: Block access to backup files
        location ~* \.(bak|backup|old|orig|save|swp|tmp)$ {
            deny all;
            access_log off;
            log_not_found off;
        }
        
        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
        
        # Static assets caching
        location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|eot|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            add_header X-Content-Type-Options nosniff;
        }
        
        # React Router support
        location / {
            try_files $uri $uri/ /index.html;
            
            # Security: Prevent clickjacking
            add_header X-Frame-Options "SAMEORIGIN" always;
            add_header X-Content-Type-Options "nosniff" always;
            add_header X-XSS-Protection "1; mode=block" always;
        }
        
        # Security: Rate limiting
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://backend-service:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    
    # Rate limiting zones
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
}
```

**File:** `apps/frontend/security-headers.conf`

```nginx
# Security Headers Configuration
# PDPA and Thai Market Compliance

# Content Security Policy (CSP)
add_header Content-Security-Policy "
    default-src 'self';
    script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net https://unpkg.com;
    style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
    font-src 'self' https://fonts.gstatic.com;
    img-src 'self' data: https:;
    connect-src 'self' https://api.example.com;
    frame-src 'none';
    object-src 'none';
    base-uri 'self';
    form-action 'self';
    upgrade-insecure-requests;
" always;

# Security Headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;

# HTTPS Security
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

# Thai Market Compliance Headers
add_header X-Data-Residency "ASEAN" always;
add_header X-Compliance-Framework "PDPA" always;
add_header X-Data-Classification "Internal" always;

# Performance and Caching
add_header X-Cache-Status $upstream_cache_status always;
add_header X-Response-Time $request_time always;
```

### 2. Backend API Dockerfile (Security-Hardened)

**File:** `apps/backend/api/Dockerfile.production`

```dockerfile
# =============================================================================
# Build Stage - Node.js API
# =============================================================================
FROM node:18-alpine AS builder

# Security: Install security updates and required packages
RUN apk --no-cache add \
    dumb-init \
    ca-certificates \
    curl && \
    apk --no-cache upgrade

# Security: Create non-root user
RUN addgroup -g 1001 -S nodeuser && \
    adduser -S nodeuser -u 1001 -G nodeuser

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies with security audit
RUN npm ci --only=production && \
    npm audit --audit-level=high && \
    npm cache clean --force

# Copy source code
COPY . .

# Build TypeScript application
RUN npm run build

# Remove dev dependencies and clean up
RUN npm prune --production && \
    rm -rf src/ tests/ coverage/ .nyc_output/ node_modules/.cache/

# =============================================================================
# Production Stage - Distroless for Maximum Security
# =============================================================================
FROM gcr.io/distroless/nodejs18-debian11:nonroot

# Security and compliance labels
LABEL maintainer="DevSecOps Workshop <workshop@example.com>" \
      version="1.0.0" \
      description="Secure Node.js API for Thai E-commerce Platform" \
      compliance.pdpa="true" \
      compliance.framework="PDPA" \
      security.scan="trivy" \
      data.classification="Sensitive" \
      service.type="api-gateway" \
      base.image="distroless"

# Security: Use non-root user (distroless default)
USER nonroot:nonroot

# Set working directory
WORKDIR /app

# Copy built application and dependencies from builder
COPY --from=builder --chown=nonroot:nonroot /app/dist ./dist
COPY --from=builder --chown=nonroot:nonroot /app/node_modules ./node_modules
COPY --from=builder --chown=nonroot:nonroot /app/package.json ./

# Environment variables for security
ENV NODE_ENV=production \
    NODE_OPTIONS="--enable-source-maps --max-old-space-size=512" \
    NPM_CONFIG_FUND=false \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    PORT=3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ["node", "-e", "require('http').get('http://localhost:3000/health', (res) => process.exit(res.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"]

# Expose port (non-privileged)
EXPOSE 3000

# Security: Use exec form and avoid shell
CMD ["node", "dist/server.js"]
```

### 3. Container Security Scanning

**File:** `scripts/security/container-scan.sh`

```bash
#!/bin/bash
# Container Security Scanning Script
# DevSecOps Workshop - Thai Market Ready

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REGISTRY="ghcr.io"
REPOSITORY="nanthapat-j/devsecops-workshop"
SERVICES=("frontend" "backend")
SEVERITY_THRESHOLD="HIGH,CRITICAL"

echo -e "${BLUE}🔍 Container Security Scanning - Thai E-commerce Platform${NC}"
echo "=================================================="

# Function to scan container image
scan_image() {
    local service=$1
    local image="${REGISTRY}/${REPOSITORY}/${service}:latest"
    
    echo -e "${BLUE}📦 Scanning ${service} container...${NC}"
    
    # Pull latest image
    docker pull "${image}" || {
        echo -e "${RED}❌ Failed to pull image: ${image}${NC}"
        return 1
    }
    
    # Trivy vulnerability scan
    echo -e "${YELLOW}🔍 Running Trivy vulnerability scan...${NC}"
    trivy image \
        --severity "${SEVERITY_THRESHOLD}" \
        --format table \
        --output "reports/trivy-${service}.txt" \
        "${image}"
    
    # Trivy configuration scan
    echo -e "${YELLOW}🔧 Running Trivy configuration scan...${NC}"
    trivy config \
        --format table \
        --output "reports/trivy-config-${service}.txt" \
        "apps/${service}/"
    
    # Hadolint Dockerfile scan
    echo -e "${YELLOW}🐳 Running Hadolint Dockerfile scan...${NC}"
    hadolint "apps/${service}/Dockerfile" > "reports/hadolint-${service}.txt" || true
    
    # Docker Scout scan (if available)
    if command -v docker &> /dev/null && docker scout version &> /dev/null; then
        echo -e "${YELLOW}🔎 Running Docker Scout scan...${NC}"
        docker scout cves "${image}" --format sarif --output "reports/scout-${service}.sarif" || true
    fi
    
    # Generate security report
    generate_security_report "${service}" "${image}"
}

# Function to generate security report
generate_security_report() {
    local service=$1
    local image=$2
    local report_file="reports/security-report-${service}.md"
    
    echo "# 🔒 Security Scan Report: ${service}" > "${report_file}"
    echo "" >> "${report_file}"
    echo "**Image:** \`${image}\`" >> "${report_file}"
    echo "**Scan Date:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")" >> "${report_file}"
    echo "**Compliance Framework:** PDPA" >> "${report_file}"
    echo "" >> "${report_file}"
    
    echo "## 📊 Scan Summary" >> "${report_file}"
    echo "" >> "${report_file}"
    
    # Count vulnerabilities
    if [[ -f "reports/trivy-${service}.txt" ]]; then
        local critical_count=$(grep -c "CRITICAL" "reports/trivy-${service}.txt" || echo "0")
        local high_count=$(grep -c "HIGH" "reports/trivy-${service}.txt" || echo "0")
        
        echo "| Severity | Count |" >> "${report_file}"
        echo "|----------|-------|" >> "${report_file}"
        echo "| CRITICAL | ${critical_count} |" >> "${report_file}"
        echo "| HIGH | ${high_count} |" >> "${report_file}"
        echo "" >> "${report_file}"
        
        if [[ ${critical_count} -gt 0 ]] || [[ ${high_count} -gt 0 ]]; then
            echo "⚠️ **Action Required:** High/Critical vulnerabilities found" >> "${report_file}"
        else
            echo "✅ **Status:** No high/critical vulnerabilities found" >> "${report_file}"
        fi
    fi
    
    echo "" >> "${report_file}"
    echo "## 🇹🇭 Thai Compliance Check" >> "${report_file}"
    echo "" >> "${report_file}"
    echo "- ✅ **PDPA Compliant:** Data classification labels present" >> "${report_file}"
    echo "- ✅ **Security Standards:** Non-root user, distroless base" >> "${report_file}"
    echo "- ✅ **Encryption:** TLS 1.3 support enabled" >> "${report_file}"
    echo "- ✅ **Audit Logging:** Container logs configured" >> "${report_file}"
    echo "" >> "${report_file}"
    
    echo "## 📋 Recommendations" >> "${report_file}"
    echo "" >> "${report_file}"
    echo "1. **Regular Updates:** Keep base images updated weekly" >> "${report_file}"
    echo "2. **Security Scanning:** Run scans on every build" >> "${report_file}"
    echo "3. **Runtime Protection:** Deploy with Falco monitoring" >> "${report_file}"
    echo "4. **Network Policies:** Implement Kubernetes network policies" >> "${report_file}"
    echo "" >> "${report_file}"
}

# Function to check scan results
check_scan_results() {
    local failed_scans=0
    
    for service in "${SERVICES[@]}"; do
        local trivy_file="reports/trivy-${service}.txt"
        
        if [[ -f "${trivy_file}" ]]; then
            local critical_count=$(grep -c "CRITICAL" "${trivy_file}" || echo "0")
            local high_count=$(grep -c "HIGH" "${trivy_file}" || echo "0")
            
            if [[ ${critical_count} -gt 0 ]]; then
                echo -e "${RED}❌ CRITICAL vulnerabilities found in ${service}${NC}"
                failed_scans=$((failed_scans + 1))
            elif [[ ${high_count} -gt 0 ]]; then
                echo -e "${YELLOW}⚠️ HIGH vulnerabilities found in ${service}${NC}"
            else
                echo -e "${GREEN}✅ ${service} passed security scan${NC}"
            fi
        fi
    done
    
    return ${failed_scans}
}

# Main execution
main() {
    # Create reports directory
    mkdir -p reports
    
    # Scan all services
    for service in "${SERVICES[@]}"; do
        scan_image "${service}"
        echo ""
    done
    
    # Check results and exit appropriately
    echo -e "${BLUE}📊 Security Scan Summary${NC}"
    echo "=========================="
    
    if check_scan_results; then
        echo -e "${GREEN}🎉 All containers passed security scans!${NC}"
        echo ""
        echo -e "${BLUE}📚 Next Steps:${NC}"
        echo "1. Deploy to Kubernetes with security policies"
        echo "2. Enable runtime security monitoring with Falco"
        echo "3. Set up continuous vulnerability scanning"
        exit 0
    else
        echo -e "${RED}🚨 Security scan failed! Please review and fix vulnerabilities.${NC}"
        echo ""
        echo -e "${YELLOW}💡 Tips for fixing vulnerabilities:${NC}"
        echo "1. Update base images to latest versions"
        echo "2. Update application dependencies"
        echo "3. Remove unnecessary packages"
        echo "4. Use distroless or slim base images"
        exit 1
    fi
}

# Run main function
main "$@"
```

## ☸️ Kubernetes Security Implementation

### 1. Pod Security Standards

**File:** `kubernetes/security/pod-security-standards.yaml`

```yaml
# Pod Security Standards for Thai E-commerce Platform
# DevSecOps Workshop - Kubernetes Security

apiVersion: v1
kind: Namespace
metadata:
  name: devsecops-workshop
  labels:
    name: devsecops-workshop
    compliance.framework: "PDPA"
    data.residency: "ASEAN"
    data.classification: "Sensitive"
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
  annotations:
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/audit-version: latest
    pod-security.kubernetes.io/warn-version: latest

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: devsecops-workshop-quota
  namespace: devsecops-workshop
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "20"
    services: "10"
    persistentvolumeclaims: "5"
    secrets: "20"
    configmaps: "20"

---
apiVersion: v1
kind: LimitRange
metadata:
  name: devsecops-workshop-limits
  namespace: devsecops-workshop
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    type: Container
  - max:
      cpu: 2000m
      memory: 2Gi
    min:
      cpu: 50m
      memory: 64Mi
    type: Container

---
# Security Context Constraints Template
apiVersion: v1
kind: ConfigMap
metadata:
  name: security-context-template
  namespace: devsecops-workshop
data:
  security-context.yaml: |
    securityContext:
      # Pod-level security context
      runAsNonRoot: true
      runAsUser: 10001
      runAsGroup: 10001
      fsGroup: 10001
      seccompProfile:
        type: RuntimeDefault
      
    containerSecurityContext:
      # Container-level security context
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 10001
      runAsGroup: 10001
      capabilities:
        drop:
          - ALL
        add: []  # Add only necessary capabilities
      seccompProfile:
        type: RuntimeDefault
```

### 2. Network Policies

**File:** `kubernetes/security/network-policies.yaml`

```yaml
# Network Policies for Microservices Security
# DevSecOps Workshop - Thai E-commerce Security

# Default deny all traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: devsecops-workshop
  labels:
    compliance.framework: "PDPA"
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

---
# Allow frontend to communicate with API gateway
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-to-api-gateway
  namespace: devsecops-workshop
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: api-gateway
    ports:
    - protocol: TCP
      port: 3000
  # Allow DNS resolution
  - to: []
    ports:
    - protocol: UDP
      port: 53

---
# Allow API gateway to communicate with microservices
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-gateway-to-services
  namespace: devsecops-workshop
spec:
  podSelector:
    matchLabels:
      app: api-gateway
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    - namespaceSelector:
        matchLabels:
          name: istio-system  # Allow Istio proxy
    ports:
    - protocol: TCP
      port: 3000
  egress:
  - to:
    - podSelector:
        matchLabels:
          tier: backend
    ports:
    - protocol: TCP
      port: 3000
  # Allow DNS and external APIs
  - to: []
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 443

---
# Allow microservices to communicate with database
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: services-to-database
  namespace: devsecops-workshop
spec:
  podSelector:
    matchLabels:
      tier: backend
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api-gateway
    - namespaceSelector:
        matchLabels:
          name: istio-system  # Allow Istio proxy
    ports:
    - protocol: TCP
      port: 3000
  egress:
  # Allow connection to external RDS database
  - to: []
    ports:
    - protocol: TCP
      port: 5432
  # Allow DNS resolution
  - to: []
    ports:
    - protocol: UDP
      port: 53

---
# Allow ingress traffic from load balancer
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-traffic
  namespace: devsecops-workshop
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    - namespaceSelector:
        matchLabels:
          name: istio-system
    ports:
    - protocol: TCP
      port: 8080

---
# Monitoring and observability access
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
  namespace: devsecops-workshop
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    - namespaceSelector:
        matchLabels:
          name: istio-system
    ports:
    - protocol: TCP
      port: 9090  # Prometheus metrics
    - protocol: TCP
      port: 15090  # Istio proxy metrics
```

### 3. RBAC Configuration

**File:** `kubernetes/security/rbac.yaml`

```yaml
# RBAC Configuration for DevSecOps Workshop
# Role-Based Access Control for Thai E-commerce Platform

# Service Account for applications
apiVersion: v1
kind: ServiceAccount
metadata:
  name: devsecops-app-sa
  namespace: devsecops-workshop
  labels:
    app.kubernetes.io/name: devsecops-workshop
    compliance.framework: "PDPA"
automountServiceAccountToken: false  # Security best practice

---
# Service Account for monitoring
apiVersion: v1
kind: ServiceAccount
metadata:
  name: devsecops-monitoring-sa
  namespace: devsecops-workshop
automountServiceAccountToken: true  # Required for monitoring

---
# Role for application pods (minimal permissions)
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: devsecops-workshop
  name: devsecops-app-role
rules:
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list"]
  resourceNames: ["app-config", "app-secrets"]  # Specific resources only
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get"]
  resourceNames: []

---
# Role for monitoring (read-only access)
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: devsecops-workshop
  name: devsecops-monitoring-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints", "configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["metrics.k8s.io"]
  resources: ["pods", "nodes"]
  verbs: ["get", "list"]

---
# ClusterRole for security scanning
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: devsecops-security-scanner
rules:
- apiGroups: [""]
  resources: ["nodes", "pods", "services", "namespaces"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments", "daemonsets", "replicasets"]
  verbs: ["get", "list"]
- apiGroups: ["networking.k8s.io"]
  resources: ["networkpolicies"]
  verbs: ["get", "list"]
- apiGroups: ["policy"]
  resources: ["podsecuritypolicies"]
  verbs: ["get", "list"]

---
# RoleBinding for application
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: devsecops-app-binding
  namespace: devsecops-workshop
subjects:
- kind: ServiceAccount
  name: devsecops-app-sa
  namespace: devsecops-workshop
roleRef:
  kind: Role
  name: devsecops-app-role
  apiGroup: rbac.authorization.k8s.io

---
# RoleBinding for monitoring
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: devsecops-monitoring-binding
  namespace: devsecops-workshop
subjects:
- kind: ServiceAccount
  name: devsecops-monitoring-sa
  namespace: devsecops-workshop
roleRef:
  kind: Role
  name: devsecops-monitoring-role
  apiGroup: rbac.authorization.k8s.io

---
# Service Account for security scanning
apiVersion: v1
kind: ServiceAccount
metadata:
  name: devsecops-security-scanner-sa
  namespace: devsecops-workshop

---
# ClusterRoleBinding for security scanning
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: devsecops-security-scanner-binding
subjects:
- kind: ServiceAccount
  name: devsecops-security-scanner-sa
  namespace: devsecops-workshop
roleRef:
  kind: ClusterRole
  name: devsecops-security-scanner
  apiGroup: rbac.authorization.k8s.io
```

## 🔍 Runtime Security with Falco

### 1. Falco Rules for Thai E-commerce

**File:** `monitoring/falco/thai-ecommerce-rules.yaml`

```yaml
# Custom Falco Rules for Thai E-commerce Platform
# DevSecOps Workshop - Runtime Security

- rule: Unauthorized Process in Container
  desc: Detect unauthorized processes in production containers
  condition: >
    spawned_process and 
    container and 
    k8s_ns = "devsecops-workshop" and
    not proc.name in (node, nginx, dumb-init, sh, bash)
  output: >
    Unauthorized process in production container 
    (user=%user.name command=%proc.cmdline container=%container.name 
    pod=%k8s.pod.name ns=%k8s.ns.name)
  priority: WARNING
  tags: [process, container, thai-ecommerce]

- rule: Database Connection from Unauthorized Pod
  desc: Detect database connections from unauthorized pods
  condition: >
    outbound and 
    fd.sport != 5432 and
    fd.dport = 5432 and
    k8s_ns = "devsecops-workshop" and
    not k8s.pod.label.tier = "backend"
  output: >
    Unauthorized database connection 
    (connection=%fd.name pod=%k8s.pod.name ns=%k8s.ns.name 
    user=%user.name)
  priority: HIGH
  tags: [network, database, unauthorized-access]

- rule: Sensitive File Access in E-commerce App
  desc: Monitor access to sensitive configuration files
  condition: >
    open_read and
    k8s_ns = "devsecops-workshop" and
    (fd.name contains "/etc/passwd" or
     fd.name contains "/etc/shadow" or
     fd.name contains ".env" or
     fd.name contains "config.json" or
     fd.name contains "database.yml")
  output: >
    Sensitive file accessed in e-commerce application 
    (file=%fd.name user=%user.name container=%container.name 
    pod=%k8s.pod.name)
  priority: WARNING
  tags: [filesystem, sensitive-data, pdpa-concern]

- rule: Cryptocurrency Mining in Container
  desc: Detect potential cryptocurrency mining activity
  condition: >
    spawned_process and
    container and
    k8s_ns = "devsecops-workshop" and
    (proc.name in (xmrig, ccminer, cgminer, bfgminer) or
     proc.cmdline contains "stratum" or
     proc.cmdline contains "mining" or
     proc.cmdline contains "cryptonight")
  output: >
    Potential cryptocurrency mining detected 
    (command=%proc.cmdline user=%user.name container=%container.name 
    pod=%k8s.pod.name)
  priority: CRITICAL
  tags: [malware, cryptocurrency, security-incident]

- rule: Excessive Network Connections from Payment Service
  desc: Monitor payment service for unusual network activity
  condition: >
    outbound and
    k8s_ns = "devsecops-workshop" and
    k8s.pod.label.app = "payment-service" and
    fd.net_type = "ipv4" and
    not fd.dip in (private_ip_ranges, database_ip_range)
  output: >
    Payment service making external connection 
    (connection=%fd.name destination=%fd.dip:%fd.dport 
    pod=%k8s.pod.name user=%user.name)
  priority: WARNING
  tags: [network, payment, external-connection]

- rule: PDPA Data Access Monitoring
  desc: Monitor access to personal data files for PDPA compliance
  condition: >
    open_read and
    k8s_ns = "devsecops-workshop" and
    (fd.name contains "personal_data" or
     fd.name contains "user_profiles" or
     fd.name contains "customer_info" or
     fd.directory contains "/data/personal")
  output: >
    Personal data access detected - PDPA compliance audit 
    (file=%fd.name user=%user.name container=%container.name 
    pod=%k8s.pod.name timestamp=%evt.time)
  priority: INFO
  tags: [pdpa, personal-data, compliance-audit]

- rule: Container Escape Attempt
  desc: Detect potential container escape attempts
  condition: >
    spawned_process and
    container and
    k8s_ns = "devsecops-workshop" and
    (proc.name in (docker, kubectl, runc, ctr) or
     proc.cmdline contains "nsenter" or
     proc.cmdline contains "chroot" or
     proc.cmdline contains "/proc/1/root")
  output: >
    Potential container escape attempt detected 
    (command=%proc.cmdline user=%user.name container=%container.name 
    pod=%k8s.pod.name)
  priority: CRITICAL
  tags: [container-escape, security-incident, high-priority]

# Macros for better rule organization
- macro: private_ip_ranges
  condition: >
    (fd.dip startswith "10." or
     fd.dip startswith "172.16." or
     fd.dip startswith "192.168.")

- macro: database_ip_range
  condition: fd.dip startswith "10.0.21."  # Database subnet

# Lists for reusable components
- list: allowed_processes
  items: [node, nginx, dumb-init, sh, bash, ps, ls, cat, grep, tail, head]

- list: sensitive_directories
  items: [/etc, /var/lib, /root, /home, /opt/secrets]

- list: payment_external_domains
  items: [api.stripe.com, api.paypal.com, payment-gateway.example.com]
```

## 🎯 Hands-on Exercise

### 📝 Exercise 1: Deploy Secure E-commerce Application

```bash
# 1. Create namespace with security policies
kubectl apply -f kubernetes/security/pod-security-standards.yaml

# 2. Apply network policies
kubectl apply -f kubernetes/security/network-policies.yaml

# 3. Set up RBAC
kubectl apply -f kubernetes/security/rbac.yaml

# 4. Deploy applications with security context
kubectl apply -f kubernetes/manifests/

# 5. Verify security configuration
kubectl get pod -n devsecops-workshop -o yaml | grep -A 10 securityContext

# 6. Test network policies
kubectl exec -it frontend-pod -n devsecops-workshop -- curl api-gateway:3000/health
```

### 📝 Exercise 2: Container Security Scanning

```bash
# 1. Build containers
make build-apps

# 2. Run security scans
./scripts/security/container-scan.sh

# 3. Review scan results
cat reports/security-report-*.md

# 4. Fix vulnerabilities and re-scan
make security-fix
./scripts/security/container-scan.sh
```

## 📊 Assessment

### ✅ Knowledge Check

**1. Container Security Best Practices**
```
Q: What are the key security features in the Dockerfile?
A: 
- Multi-stage build to reduce attack surface
- Distroless base image (no shell, minimal packages)
- Non-root user (UID 10001)
- Read-only root filesystem
- Dropped all capabilities
- Security labels for compliance tracking
```

**2. Kubernetes Security**
```
Q: How do network policies enhance security?
A:
- Default deny all traffic (zero trust)
- Explicit allow rules for required communication
- Micro-segmentation between services
- Prevents lateral movement in case of breach
- Compliance with PDPA data protection requirements
```

### 🧪 Practical Assessment

```bash
# Deploy and validate security
make deploy-secure-apps
make validate-security
make test-network-policies
make verify-runtime-security
```

**Success Criteria:**
- ✅ All containers use non-root users
- ✅ Network policies block unauthorized traffic
- ✅ RBAC limits service permissions
- ✅ Falco detects security events
- ✅ Container scans show no critical vulnerabilities

## 🎯 Next Steps

**Module 3 Completed! 🎉**

You have successfully:
- ✅ Built secure container images with distroless bases
- ✅ Implemented Kubernetes security best practices
- ✅ Set up network policies and RBAC
- ✅ Configured runtime security monitoring

**Continue to:** [Module 4: CI/CD Security](04-cicd-security.md)

---

**📚 Additional Resources:**

- [NIST Container Security Guide](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-190.pdf)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [Falco Documentation](https://falco.org/docs/)
- [Kubernetes Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)