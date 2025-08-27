# DevSecOps E-commerce Frontend

## 🛍️ Secure React.js E-commerce Application

This is a secure e-commerce frontend application built with React.js and TypeScript, designed to demonstrate security best practices in modern web applications.

## 🔐 Security Features

- **Content Security Policy (CSP)** headers
- **Input validation** and sanitization
- **HTTPS enforcement** in production
- **Secure authentication** with JWT tokens
- **XSS protection** through proper escaping
- **CSRF protection** with secure tokens
- **Dependency scanning** with npm audit
- **Security linting** with eslint-plugin-security

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Start development server (ใช้งานร่วมกับ docker-compose)
npm start

# Build for production
npm run build

# Run security audit
npm run security-audit

# Run linting with security checks
npm run lint
```

## 🏗️ Architecture

```
src/
├── components/           # Reusable UI components
│   ├── common/          # Common components (Header, Footer)
│   ├── product/         # Product-related components
│   ├── cart/            # Shopping cart components
│   └── auth/            # Authentication components
├── pages/               # Page components
│   ├── Home/
│   ├── Products/
│   ├── Cart/
│   └── Checkout/
├── services/            # API services and security utilities
│   ├── api.ts           # Secure API client
│   ├── auth.ts          # Authentication service
│   └── security.ts      # Security utilities
├── hooks/               # Custom React hooks
├── types/               # TypeScript type definitions
├── utils/               # Utility functions
└── __tests__/           # Test files
```

## 🛡️ Security Implementation

### 1. **Input Validation**
```typescript
// Example: Secure input validation
const validateEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email) && email.length <= 254;
};
```

### 2. **XSS Protection**
```typescript
// Example: Safe HTML rendering
const sanitizeHtml = (html: string): string => {
  return DOMPurify.sanitize(html);
};
```

### 3. **Secure API Communication**
```typescript
// Example: Secure API client with CSRF protection
const apiClient = axios.create({
  baseURL: process.env.REACT_APP_API_URL,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json',
    'X-Requested-With': 'XMLHttpRequest'
  }
});
```

## 🔍 Security Testing

### **Automated Security Checks**
```bash
# Dependency vulnerability scanning
npm audit --audit-level moderate

# Security linting
npm run lint

# Run security-focused tests
npm test -- --testNamePattern="security"
```

### **Manual Security Testing**
1. **SQL Injection**: Test all input fields
2. **XSS**: Test user-generated content
3. **CSRF**: Verify token implementation
4. **Authentication**: Test session management

## 🌍 Environment Configuration

### **Development (.env.development)**
```env
REACT_APP_API_URL=http://localhost:8080/api
REACT_APP_ENVIRONMENT=development
REACT_APP_ENABLE_SECURITY_HEADERS=true
```

### **Production (.env.production)**
```env
REACT_APP_API_URL=https://api.yourdomain.com
REACT_APP_ENVIRONMENT=production
REACT_APP_ENABLE_SECURITY_HEADERS=true
REACT_APP_SENTRY_DSN=your-sentry-dsn
```

## 🐳 Docker Configuration

See `Dockerfile` for secure containerization setup including:
- Multi-stage build for minimal image size
- Non-root user execution
- Security scanning integration
- Distroless final image

## 📊 Performance & Security Monitoring

- **Web Vitals** tracking for performance
- **Error boundary** for graceful error handling
- **Content Security Policy** reporting
- **Security header** validation

## 🇹🇭 Thai Market Features

- **Thai language** support (i18n ready)
- **Thai payment methods** integration placeholder
- **PDPA compliance** user consent management
- **Local currency** (THB) formatting

## 🔗 Integration with Backend Services

This frontend integrates with:
- **User Service**: Authentication and profile management
- **Product Service**: Product catalog and search
- **Order Service**: Shopping cart and checkout
- **Payment Gateway**: Secure payment processing

## 📚 Development Guidelines

### **Code Security Standards**
1. Always validate user inputs
2. Use TypeScript for type safety
3. Implement proper error handling
4. Follow OWASP security guidelines
5. Regular dependency updates

### **Testing Requirements**
- Unit tests for all components
- Integration tests for user flows
- Security tests for vulnerable areas
- Performance tests for critical paths

## 🚀 Deployment

This application is designed to be deployed with:
- **AWS Amplify** for static hosting
- **CloudFront** for CDN and security headers
- **WAF** for additional protection
- **Route 53** for DNS management

## 📖 Learning Objectives

By working with this frontend:
1. Understand **secure coding practices** in React
2. Learn **client-side security** implementation
3. Practice **security testing** methodologies
4. Experience **secure deployment** processes

Ready to build secure frontend applications? Let's code! 🚀