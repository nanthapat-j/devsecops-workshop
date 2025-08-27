# DevSecOps Workshop - Secure Multi-stage Dockerfile
# Frontend React.js Application with Security Hardening

# ================================
# Stage 1: Build Stage
# ================================
FROM node:18-alpine AS builder

# Add security labels
LABEL maintainer="DevSecOps Workshop <devsecops@workshop.com>"
LABEL version="1.0.0"
LABEL description="Secure React.js frontend for DevSecOps e-commerce workshop"
LABEL security.scan="trivy"

# Install security updates
RUN apk update && apk upgrade && apk add --no-cache \
    dumb-init \
    && rm -rf /var/cache/apk/*

# Create app directory with restricted permissions
WORKDIR /app

# Create non-root user for build process
RUN addgroup -g 1001 -S nodejs && \
    adduser -S reactjs -u 1001 -G nodejs

# Copy package files with proper ownership
COPY --chown=reactjs:nodejs package*.json ./

# Switch to non-root user for npm install
USER reactjs

# Install dependencies with security audit
RUN npm ci --only=production --audit-level moderate && \
    npm cache clean --force

# Copy source code
COPY --chown=reactjs:nodejs . .

# Build the application
RUN npm run build

# ================================
# Stage 2: Security Scanning Stage (Optional for CI/CD)
# ================================
FROM aquasec/trivy:latest AS security-scan
COPY --from=builder /app /scan
RUN trivy fs --exit-code 1 --no-progress --severity HIGH,CRITICAL /scan

# ================================
# Stage 3: Production Stage
# ================================
FROM nginx:1.25-alpine AS production

# Security hardening for nginx
RUN apk update && apk upgrade && apk add --no-cache \
    dumb-init \
    && rm -rf /var/cache/apk/* \
    && rm -rf /usr/share/nginx/html/*

# Create non-root user
RUN addgroup -g 1001 -S nginx-app && \
    adduser -S nginx-app -u 1001 -G nginx-app

# Copy custom nginx configuration for security
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/security-headers.conf /etc/nginx/conf.d/security-headers.conf

# Copy built application from builder stage
COPY --from=builder --chown=nginx-app:nginx-app /app/build /usr/share/nginx/html

# Set proper permissions
RUN chown -R nginx-app:nginx-app /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Create nginx directories with proper permissions
RUN mkdir -p /var/cache/nginx/client_temp \
    /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp \
    /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp && \
    chown -R nginx-app:nginx-app /var/cache/nginx && \
    chmod -R 755 /var/cache/nginx

# Create log directories
RUN mkdir -p /var/log/nginx && \
    chown -R nginx-app:nginx-app /var/log/nginx && \
    chmod -R 755 /var/log/nginx

# Create pid directory
RUN mkdir -p /var/run && \
    chown -R nginx-app:nginx-app /var/run

# Switch to non-root user
USER nginx-app

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Expose port (non-privileged port)
EXPOSE 8080

# Use dumb-init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

# ================================
# Security Metadata
# ================================
LABEL security.non-root="true"
LABEL security.readonly-rootfs="true"
LABEL security.no-new-privileges="true"
LABEL security.capabilities="drop:ALL"
LABEL security.scan-date="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Build arguments for tracking
ARG BUILD_DATE
ARG VERSION
ARG VCS_REF

LABEL build-date=$BUILD_DATE
LABEL version=$VERSION
LABEL vcs-ref=$VCS_REF