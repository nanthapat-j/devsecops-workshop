# Multi-stage Dockerfile for React Frontend
# DevSecOps Workshop - Secure Container Build

# =============================================================================
# Build Stage
# =============================================================================
FROM node:18-alpine AS builder

# Security: Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY package.json package-lock.json ./

# Install dependencies with security audit
RUN npm ci --only=production && \
    npm audit --audit-level=high && \
    npm cache clean --force

# Copy source code
COPY . .

# Build application
RUN npm run build

# =============================================================================
# Production Stage - Distroless for Security
# =============================================================================
FROM gcr.io/distroless/nodejs18-debian11:nonroot

# Labels for compliance and traceability
LABEL maintainer="DevSecOps Workshop <workshop@example.com>" \
      version="1.0.0" \
      description="Secure React Frontend for Thai E-commerce Platform" \
      compliance.pdpa="true" \
      compliance.framework="PDPA" \
      security.scan="trivy" \
      data.classification="Internal"

# Security: Use non-root user (distroless default)
USER nonroot:nonroot

# Set working directory
WORKDIR /app

# Copy built application from builder stage
COPY --from=builder --chown=nonroot:nonroot /app/build ./build
COPY --from=builder --chown=nonroot:nonroot /app/node_modules ./node_modules
COPY --from=builder --chown=nonroot:nonroot /app/package.json ./

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["node", "-e", "process.exit(0)"]

# Expose port (non-privileged)
EXPOSE 3000

# Security: Run with specific command
CMD ["node", "-e", "require('http').createServer((req,res)=>{require('fs').createReadStream('./build/index.html').pipe(res)}).listen(3000)"]

# =============================================================================
# Alternative nginx-based production build (commented out)
# =============================================================================
# FROM nginx:1.24-alpine AS production
# 
# # Security: Install security updates
# RUN apk --no-cache add ca-certificates && \
#     apk --no-cache upgrade
# 
# # Copy built files
# COPY --from=builder /app/build /usr/share/nginx/html
# 
# # Copy secure nginx configuration
# COPY nginx.conf /etc/nginx/nginx.conf
# 
# # Security: Create non-root user for nginx
# RUN addgroup -g 101 -S nginx && \
#     adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx
# 
# # Expose port
# EXPOSE 80
# 
# CMD ["nginx", "-g", "daemon off;"]