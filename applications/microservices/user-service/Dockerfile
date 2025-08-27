# DevSecOps Workshop - Secure Multi-stage Dockerfile
# User Authentication Service with Security Hardening

# ================================
# Stage 1: Dependencies
# ================================
FROM node:18-alpine AS dependencies

# Add security labels
LABEL maintainer="DevSecOps Workshop <devsecops@workshop.com>"
LABEL version="1.0.0"
LABEL description="Secure User Authentication Service"

# Install security updates and tools
RUN apk update && apk upgrade && apk add --no-cache \
    dumb-init \
    curl \
    && rm -rf /var/cache/apk/*

# Create app directory
WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001 -G nodejs

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production --audit-level moderate && \
    npm cache clean --force

# ================================
# Stage 2: Build Stage
# ================================
FROM node:18-alpine AS builder

WORKDIR /app

# Copy dependencies
COPY --from=dependencies /app/node_modules ./node_modules
COPY package*.json ./

# Copy source code
COPY src/ ./src/

# Run tests and security checks
RUN npm install --only=dev && \
    npm run lint && \
    npm run test && \
    npm run security-audit

# ================================
# Stage 3: Security Scanning (Optional)
# ================================
FROM aquasec/trivy:latest AS security-scan
COPY --from=builder /app /scan
RUN trivy fs --exit-code 1 --no-progress --severity HIGH,CRITICAL /scan

# ================================
# Stage 4: Production Stage
# ================================
FROM node:18-alpine AS production

# Security hardening
RUN apk update && apk upgrade && apk add --no-cache \
    dumb-init \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodeuser -u 1001 -G nodejs

# Set working directory
WORKDIR /app

# Copy dependencies from dependencies stage
COPY --from=dependencies --chown=nodeuser:nodejs /app/node_modules ./node_modules

# Copy package.json
COPY --chown=nodeuser:nodejs package*.json ./

# Copy application code
COPY --from=builder --chown=nodeuser:nodejs /app/src ./src

# Set proper permissions
RUN chmod -R 755 /app && \
    chown -R nodeuser:nodejs /app

# Switch to non-root user
USER nodeuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Expose port
EXPOSE 3000

# Use dumb-init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Start the application
CMD ["node", "src/index.js"]

# ================================
# Security Metadata
# ================================
LABEL security.non-root="true"
LABEL security.readonly-rootfs="false"
LABEL security.no-new-privileges="true"
LABEL security.capabilities="drop:ALL"

# Build arguments for tracking
ARG BUILD_DATE
ARG VERSION
ARG VCS_REF

LABEL build-date=$BUILD_DATE
LABEL version=$VERSION
LABEL vcs-ref=$VCS_REF