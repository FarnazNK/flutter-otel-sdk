# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-01-XX

### Added
- Initial release of flutter_otel_sdk
- `OtelTracer` singleton for managing OpenTelemetry lifecycle
- `OtelConfig` for type-safe configuration
- `OtelSpan` wrapper for simplified span management
- `OtelHttpClient` for automatic HTTP request instrumentation
- `OtelErrorHandler` for automatic error tracking
- W3C trace context propagation support
- Comprehensive example app demonstrating all features
- Full API documentation

### Features
- Automatic HTTP request tracing with zero configuration
- Custom span creation with builder pattern
- Nested span support with proper context propagation
- Event logging with custom attributes
- Exception tracking with stack traces
- Configurable sampling rates
- Debug mode for development
- Type-safe attribute handling (String, int, double, bool, List)

### Developer Experience
- Minimal boilerplate (5-line setup)
- Clear, intuitive API
- Comprehensive error messages
- Example code for all use cases
- Architecture decision documentation

## [Unreleased]

### Planned
- Dio HTTP client interceptor
- Database query instrumentation (sqflite)
- Navigator/routing automatic instrumentation
- Performance metrics collection
- Memory usage tracking
- Custom exporter support
- Metrics API (in addition to traces)
- Log correlation
