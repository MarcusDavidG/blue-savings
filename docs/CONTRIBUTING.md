# Contributing to BlueSavings

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Code of Conduct

Please read and follow our [Code of Conduct](../.github/CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs

Use the bug report template when creating issues.

### Suggesting Features

Use the feature request template for new ideas.

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`forge test`)
5. Commit with conventional commits (`feat:`, `fix:`, `docs:`, etc.)
6. Push to your branch
7. Open a Pull Request

## Development Setup

```bash
# Clone repository
git clone https://github.com/MarcusDavidG/blue-savings
cd blue-savings

# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install dependencies
forge install

# Run tests
forge test
```

## Coding Standards

- Follow Solidity style guide
- Write comprehensive tests
- Add NatSpec documentation
- Run formatter: `forge fmt`
- Run linter: `npm run lint`

## Commit Guidelines

Use conventional commits:
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation
- `test:` - Tests
- `chore:` - Maintenance
- `refactor:` - Code refactoring
- `style:` - Formatting
- `perf:` - Performance

## Testing

All PRs must pass:
- Unit tests
- Integration tests
- Fuzz tests
- Gas benchmarks
- Linting

## Questions?

Feel free to open a discussion or reach out!
