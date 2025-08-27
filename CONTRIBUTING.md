# Contributing to DevSecOps Workshop

We welcome contributions from the community! This workshop aims to provide comprehensive, hands-on DevSecOps training for the Thai market.

## 🌟 How to Contribute

### 🐛 Bug Reports
- Use GitHub Issues to report bugs
- Include detailed reproduction steps
- Specify the module and environment where the issue occurs
- Attach error logs and screenshots when applicable

### 💡 Feature Requests
- Propose new features through GitHub Issues
- Explain the use case and benefits
- Consider Thai market requirements and compliance needs
- Provide implementation suggestions if possible

### 📝 Documentation Improvements
- Fix typos and improve clarity
- Add missing explanations or examples
- Translate content to Thai where appropriate
- Update outdated information

### 🔧 Code Contributions
- Fork the repository
- Create a feature branch from `main`
- Make your changes following our coding standards
- Add or update tests as needed
- Update documentation
- Submit a pull request

## 🛠️ Development Setup

### Prerequisites
- AWS CLI configured
- Docker Desktop
- Node.js 18+
- Terraform 1.5+
- kubectl
- Helm 3+

### Local Development
```bash
# Clone the repository
git clone https://github.com/nanthapat-j/devsecops-workshop.git
cd devsecops-workshop

# Check prerequisites
./scripts/setup/check-prerequisites.sh

# Install development tools
./scripts/setup/install-tools.sh

# Start local development environment
make start

# Run tests
make test
```

## 📋 Coding Standards

### Security First
- Follow OWASP security guidelines
- Implement least privilege principles
- Encrypt sensitive data
- Validate all inputs
- Use secure coding practices

### Infrastructure as Code
- Use Terraform for all AWS resources
- Follow HashiCorp Configuration Language best practices
- Include comprehensive variable descriptions
- Add meaningful resource tags
- Implement proper state management

### Container Security
- Use multi-stage Dockerfiles
- Run containers as non-root users
- Implement health checks
- Scan images for vulnerabilities
- Keep base images updated

### Documentation
- Write clear, concise documentation
- Include code examples
- Add troubleshooting sections
- Support both English and Thai languages
- Follow markdown standards

## 🔍 Review Process

### Pull Request Guidelines
1. **Clear Description**: Explain what changes you made and why
2. **Small Changes**: Keep PRs focused and manageable
3. **Tests**: Include tests for new functionality
4. **Documentation**: Update docs for any new features
5. **Security**: Ensure changes don't introduce vulnerabilities

### Review Criteria
- ✅ Code quality and security
- ✅ Test coverage
- ✅ Documentation completeness
- ✅ Thai market relevance
- ✅ Compatibility with existing modules

## 🇹🇭 Thai Market Focus

When contributing, please consider:
- **PDPA Compliance**: Personal data protection requirements
- **Banking Regulations**: BOT IT risk management guidelines
- **Local Practices**: Thai development community preferences
- **Language Support**: Thai language documentation and comments
- **Regional Services**: AWS ap-southeast-1 region considerations

## 📚 Module Structure

When adding new modules or exercises:

```
modules/
├── 0X-module-name/
│   ├── docs/
│   │   └── README.md          # Module documentation
│   ├── exercises/
│   │   ├── 01-exercise.md     # Hands-on exercises
│   │   └── 02-exercise.md
│   ├── solutions/
│   │   ├── terraform/         # Infrastructure solutions
│   │   ├── kubernetes/        # K8s manifests
│   │   └── scripts/          # Automation scripts
│   └── scripts/
│       ├── setup.sh          # Module setup
│       └── cleanup.sh        # Module cleanup
```

## 🎯 Learning Objectives

Each contribution should support these objectives:
- **Hands-on Learning**: Practical, actionable exercises
- **Real-world Scenarios**: Based on actual industry challenges
- **Career Development**: Portfolio-ready projects
- **Thai Market Preparation**: Local compliance and practices
- **Security Focus**: Security-first approach to DevOps

## 🔐 Security Guidelines

### Sensitive Information
- Never commit secrets, API keys, or passwords
- Use placeholder values in examples
- Document where real values should be placed
- Use AWS IAM roles instead of access keys when possible

### Security Testing
- Include security test cases
- Run vulnerability scans on containers
- Validate compliance requirements
- Test access controls and permissions

## 🚀 Release Process

### Version Management
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Tag releases with detailed changelog
- Update documentation with each release
- Test all modules before release

### Quality Assurance
- All tests must pass
- Security scans must be clean
- Documentation must be up-to-date
- Thai translations must be accurate

## 📞 Community Support

### Communication Channels
- **GitHub Discussions**: General questions and ideas
- **Issues**: Bug reports and feature requests
- **Slack**: #devsecops-thailand (for contributors)
- **LinkedIn**: DevSecOps Thailand group

### Getting Help
- Check existing documentation first
- Search GitHub Issues for similar problems
- Join community discussions
- Ask specific, detailed questions

## 🙏 Recognition

Contributors will be:
- Listed in the project README
- Acknowledged in release notes
- Invited to community events
- Featured in case studies (with permission)

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

---

Thank you for helping make DevSecOps education accessible to the Thai developer community! 🇹🇭

Together, we're building a more secure digital future for Thailand. 🚀