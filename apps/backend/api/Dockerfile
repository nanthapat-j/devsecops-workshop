# Multi-stage Dockerfile for Node.js Backend API
# DevSecOps Workshop - Secure Container Build

# =============================================================================
# Build Stage
# =============================================================================
FROM node:18-alpine AS builder

# Security: Install security updates and required packages
RUN apk --no-cache add \
    dumb-init \
    ca-certificates && \
    apk --no-cache upgrade

# Security: Create non-root user
RUN addgroup -g 1001 -S nodeuser && \
    adduser -S nodeuser -u 1001 -G nodeuser

# Set working directory
WORKDIR /app

# Copy package files for dependency installation
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
    rm -rf src/ tests/ coverage/ .nyc_output/

# =============================================================================
# Production Stage - Distroless for Security
# =============================================================================
FROM gcr.io/distroless/nodejs18-debian11:nonroot

# Labels for compliance and traceability
LABEL maintainer="DevSecOps Workshop <workshop@example.com>" \
      version="1.0.0" \
      description="Secure Node.js Backend API for Thai E-commerce Platform" \
      compliance.pdpa="true" \
      compliance.framework="PDPA" \
      security.scan="trivy" \
      data.classification="Sensitive" \
      service.type="api-gateway"

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
    NODE_OPTIONS="--enable-source-maps" \
    NPM_CONFIG_FUND=false \
    NPM_CONFIG_UPDATE_NOTIFIER=false

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ["node", "-e", "require('http').get('http://localhost:3000/health', (res) => process.exit(res.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"]

# Expose port (non-privileged)
EXPOSE 3000

# Security: Use exec form for better signal handling
CMD ["node", "dist/server.js"]

# =============================================================================
# Alternative Alpine-based production build (for debugging)
# =============================================================================
# FROM node:18-alpine AS production
# 
# # Security: Install security updates
# RUN apk --no-cache add \
#     dumb-init \
#     ca-certificates && \
#     apk --no-cache upgrade
# 
# # Security: Create non-root user
# RUN addgroup -g 1001 -S nodeuser && \
#     adduser -S nodeuser -u 1001 -G nodeuser
# 
# # Set working directory
# WORKDIR /app
# 
# # Copy built application
# COPY --from=builder --chown=nodeuser:nodeuser /app/dist ./dist
# COPY --from=builder --chown=nodeuser:nodeuser /app/node_modules ./node_modules
# COPY --from=builder --chown=nodeuser:nodeuser /app/package.json ./
# 
# # Switch to non-root user
# USER nodeuser:nodeuser
# 
# # Health check
# HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
#     CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
# 
# # Expose port
# EXPOSE 3000
# 
# # Use dumb-init for proper signal handling
# ENTRYPOINT ["dumb-init", "--"]
# CMD ["node", "dist/server.js"]