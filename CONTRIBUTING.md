# Contributing to OIDC Tester

Thank you for your interest in contributing to OIDC Tester! This document provides guidelines and information for contributors.

## Getting Started

### Prerequisites

- **macOS**: 10.15 (Catalina) or later
- **Xcode**: 14.0 or later
- **Swift**: 5.7 or later
- **Git**: For version control

### Development Setup

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/oidc-tester.git
   cd oidc-tester
   ```
3. **Open the project** in Xcode:
   ```bash
   open "OIDC Tester.xcodeproj"
   ```
4. **Build and run** to ensure everything works
5. **Create a branch** for your contribution:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Types of Contributions

We welcome several types of contributions:

### 🐛 **Bug Reports**
- Use the GitHub issue tracker
- Include steps to reproduce
- Provide system information (macOS version, Xcode version)
- Include relevant logs from the app's Logs tab

### 💡 **Feature Requests**
- Check existing issues first
- Describe the use case and benefits
- Consider implementation complexity
- Provide mockups or examples if helpful

### 🔧 **Code Contributions**
- Bug fixes
- New features
- Performance improvements
- Code refactoring
- Documentation improvements

### 📚 **Documentation**
- README improvements
- Code comments
- Wiki content
- Tutorial creation

## Development Guidelines

### Code Style

- **Swift Style**: Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- **Formatting**: Use Xcode's default formatting
- **Naming**: Use descriptive, self-documenting names
- **Comments**: Document complex logic and public APIs

### SwiftUI Best Practices

- **State Management**: Use `@State`, `@Binding`, and `@ObservableObject` appropriately
- **View Composition**: Break down complex views into smaller components
- **Performance**: Avoid unnecessary view updates
- **Accessibility**: Include accessibility labels and hints

### Architecture

- **MVVM Pattern**: Separate business logic from views
- **Single Responsibility**: Each class/struct should have one clear purpose
- **Dependency Injection**: Make dependencies explicit
- **Error Handling**: Use proper error types and handling

### Security Considerations

- **Sensitive Data**: Never log or store sensitive information
- **Sandbox Compliance**: Ensure all code works within macOS sandbox
- **Secure Defaults**: Default to secure configurations
- **Input Validation**: Validate all user inputs

## Testing

### Manual Testing

Before submitting your contribution:

1. **Build and run** the application
2. **Test your changes** thoroughly
3. **Test existing functionality** to ensure no regressions
4. **Test on different macOS versions** if possible
5. **Verify UI on different screen sizes**

### Test Cases to Cover

- **Basic OIDC Flow**: Test with a real OIDC provider
- **Error Handling**: Test with invalid configurations
- **Edge Cases**: Empty fields, special characters, long URLs
- **UI Responsiveness**: Test with different window sizes
- **State Management**: Test tab switching and data persistence

## Submission Process

### Pull Request Guidelines

1. **Create a focused PR**: One feature or fix per PR
2. **Write a clear title**: Describe what the PR does
3. **Provide a description**: Explain the changes and why they're needed
4. **Reference issues**: Link to related GitHub issues
5. **Include screenshots**: For UI changes, show before/after

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested manually
- [ ] No regressions found
- [ ] Screenshots attached (for UI changes)

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No sensitive data exposed
```

### Review Process

1. **Automated checks**: Ensure the project builds successfully
2. **Code review**: Maintainers will review your changes
3. **Feedback**: Address any requested changes
4. **Approval**: Once approved, your PR will be merged

## Specific Areas for Contribution

### High Priority

- **Additional OIDC Providers**: Test and document compatibility
- **Error Handling**: Improve user-friendly error messages
- **Performance**: Optimize UI responsiveness
- **Accessibility**: Improve VoiceOver support

### Medium Priority

- **Export Features**: Add export capabilities for logs and tokens
- **Theme Support**: Dark/light theme improvements
- **Keyboard Shortcuts**: Add common keyboard shortcuts
- **Preferences**: Add user preference settings

### Lower Priority

- **Localization**: Support for additional languages
- **Advanced Features**: OIDC extensions and advanced flows
- **Integration**: Support for additional authentication methods

## Resources

### Learning Resources

- [Swift Documentation](https://docs.swift.org/swift-book/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [OIDC Specification](https://openid.net/connect/)
- [ASWebAuthenticationSession](https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession)

### Project Structure

```
OIDC Tester/
├── ContentView.swift           # Main app interface
├── OIDC_TesterApp.swift       # App entry point
└── Assets.xcassets/           # App icons and assets
    └── AppIcon.appiconset/    # Custom app icon
```

### Key Components

- **ContentView**: Main SwiftUI view with tab interface
- **Authentication Logic**: OIDC flow implementation
- **Token Parsing**: JWT decoding and display
- **Logging System**: Activity logging and error tracking

## Recognition

Contributors will be recognized in:

- **README**: Contributors section
- **Release Notes**: Attribution for significant contributions
- **GitHub**: Contributor badges and statistics

## Questions?

- **GitHub Discussions**: For general questions and ideas
- **GitHub Issues**: For specific bugs or feature requests
- **Code Review**: Ask questions during the PR process

Thank you for contributing to OIDC Tester! Your contributions help make OIDC testing more accessible for everyone.
