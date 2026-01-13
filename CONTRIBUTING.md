# Contributing to BlueSavings

Thank you for considering contributing to BlueSavings!

## How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`forge test`)
5. Commit your changes (`git commit -m 'feat: add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/blue-savings.git
cd blue-savings

# Install dependencies
forge install

# Run tests
forge test -vv
```

## Dependency Management

This project uses **manual dependency management**. Automated bots (Dependabot, auto-merge) are disabled to maintain strict quality control. When updating dependencies:

1. Test thoroughly in a separate branch
2. Review changelogs and breaking changes
3. Update lockfiles and check for conflicts
4. Run full test suite before submitting PR
5. Document dependency changes in PR description

## Code Style

- Follow Solidity style guide
- Add NatSpec comments for all public functions
- Write tests for new features
- Keep commits atomic and well-described

## Pull Request Process

1. Update documentation if needed
2. Add tests for new functionality
3. Ensure all tests pass
4. Update CHANGELOG.md
5. Request review from maintainers

## Reporting Bugs

Use GitHub Issues and include:
- Clear description
- Steps to reproduce
- Expected vs actual behavior
- Environment details

Thank you!
