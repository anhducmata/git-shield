# Contributing to git-shield

Thank you for your interest in contributing to git-shield! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Issues

1. Check if the issue has already been reported
2. Use the issue template and provide as much detail as possible
3. Include steps to reproduce the issue
4. Mention your operating system and git version

### Suggesting Features

1. Check if the feature has already been requested
2. Describe the feature and why it would be useful
3. Provide examples of how it would work

### Submitting Code Changes

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test your changes thoroughly
5. Commit your changes with a descriptive commit message
6. Push to your fork and submit a pull request

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/anhducmata/git-shield.git
   cd git-shield
   ```

2. Install git-shield locally:
   ```bash
   bash install.sh
   ```

3. Test your changes:
   ```bash
   bash test.sh
   ```

## Code Style Guidelines

- Use bash scripting best practices
- Add comments to explain complex logic
- Follow the existing code style
- Make sure all scripts are executable (`chmod +x script.sh`)

## Testing

Before submitting a pull request, please:

1. Run the test script: `bash test.sh`
2. Test the installation and uninstallation process
3. Test with various secret patterns
4. Test on different operating systems if possible

## Security Considerations

When adding new secret patterns:

1. Make sure the pattern is specific enough to avoid false positives
2. Test the pattern thoroughly
3. Consider the impact on performance
4. Document the pattern in the README

## Questions?

If you have questions about contributing, feel free to open an issue or reach out to the maintainers.

Thank you for contributing to git-shield! 🛡️ 