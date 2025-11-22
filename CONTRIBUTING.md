# Contributing to flutter_otel_sdk

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code:

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on what is best for the community
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include:

- **Clear title** describing the issue
- **Detailed description** of the problem
- **Steps to reproduce** the behavior
- **Expected behavior** vs actual behavior
- **Environment details** (Flutter version, OS, device)
- **Code samples** or minimal reproduction

### Suggesting Features

Feature suggestions are welcome! Please provide:

- **Clear use case** - What problem does this solve?
- **API proposal** - How should the API look?
- **Alternatives considered** - What other approaches did you think about?
- **Breaking changes** - Would this break existing code?

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Write tests** for any new functionality
3. **Update documentation** including README and code comments
4. **Follow the code style** (run `dart format .`)
5. **Run all tests** (`flutter test`)
6. **Add to CHANGELOG.md** under "Unreleased" section
7. **Submit the PR** with a clear description

## Development Setup

### Prerequisites

- Flutter SDK (3.0.0 or later)
- Dart SDK (3.0.0 or later)
- Git

### Getting Started

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/flutter_otel_sdk.git
cd flutter_otel_sdk

# Get dependencies
flutter pub get

# Run tests
flutter test

# Run example app
cd example
flutter run
```

## Code Style

We follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines:

### Formatting

```bash
# Format all Dart files
dart format .

# Check formatting
dart format --output=none --set-exit-if-changed .
```

### Linting

```bash
# Run static analysis
flutter analyze
```

### Naming Conventions

- **Classes/Enums**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `lowerCamelCase`
- **Files**: `snake_case.dart`

### Documentation

- All public APIs must have documentation comments
- Use `///` for doc comments
- Include code examples for complex APIs
- Explain **why**, not just **what**

Example:
```dart
/// Creates a new span for tracing operations.
///
/// The [name] parameter identifies the operation being traced.
/// Use [attributes] to add custom metadata to the span.
///
/// Example:
/// ```dart
/// final span = tracer.startSpan(
///   'process-order',
///   attributes: {'order.id': '12345'},
/// );
/// ```
void startSpan(String name, {Map<String, dynamic>? attributes}) {
  // Implementation
}
```

## Testing

### Unit Tests

- Test individual components in isolation
- Mock external dependencies
- Use descriptive test names
- Group related tests

```dart
group('OtelConfig', () {
  test('creates config with required parameters', () {
    // Test implementation
  });
  
  test('throws error for invalid sample rate', () {
    // Test implementation
  });
});
```

### Integration Tests

- Test component interactions
- Use real OpenTelemetry SDK when possible
- Verify end-to-end behavior

### Coverage

We aim for >80% code coverage:

```bash
# Generate coverage
flutter test --coverage

# View coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Project Structure

```
flutter_otel_sdk/
├── lib/
│   ├── flutter_otel_sdk.dart      # Main export file
│   └── src/
│       ├── otel_config.dart       # Configuration
│       ├── otel_tracer.dart       # Main tracer
│       ├── otel_span.dart         # Span wrapper
│       ├── otel_http_client.dart  # HTTP instrumentation
│       └── otel_error_handler.dart # Error tracking
├── test/
│   └── flutter_otel_sdk_test.dart # Tests
├── example/
│   └── lib/
│       └── main.dart              # Demo app
├── ARCHITECTURE.md                # Architecture docs
├── CHANGELOG.md                   # Version history
├── CONTRIBUTING.md                # This file
└── README.md                      # Main documentation
```

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add metrics support
fix: resolve memory leak in span processor
docs: update README with new examples
test: add integration tests for HTTP client
refactor: simplify span attribute handling
chore: update dependencies
```

## Release Process

Maintainers will:

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Create git tag: `git tag v0.2.0`
4. Push tag: `git push origin v0.2.0`
5. Publish to pub.dev: `flutter pub publish`

## Areas for Contribution

Priority areas where we'd love help:

### High Priority
- [ ] Dio HTTP client interceptor
- [ ] Database query instrumentation (sqflite)
- [ ] Better error messages
- [ ] Performance benchmarks

### Medium Priority
- [ ] Navigator/routing instrumentation
- [ ] Image loading instrumentation
- [ ] Memory profiling
- [ ] Additional exporters

### Nice to Have
- [ ] Metrics API
- [ ] Log correlation
- [ ] Custom sampling strategies
- [ ] VS Code extension

## Questions?

- Open a [GitHub Discussion](https://github.com/yourusername/flutter_otel_sdk/discussions)
- File an [Issue](https://github.com/yourusername/flutter_otel_sdk/issues)

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Celebrated in the community!

Thank you for contributing! 🎉
