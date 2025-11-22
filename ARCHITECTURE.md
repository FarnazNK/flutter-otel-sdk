# Architecture Documentation

## Overview

This document explains the architectural decisions behind flutter_otel_sdk and provides guidance for contributors.

## Design Principles

### 1. Developer Experience First

The primary goal is to make OpenTelemetry adoption trivial for Flutter developers:

- **Minimal setup**: 5 lines to get started
- **Sensible defaults**: Works out-of-the-box for 80% of use cases
- **Progressive disclosure**: Simple API with escape hatches for advanced usage

### 2. Type Safety

Leverage Dart's type system to prevent runtime errors:

- Strongly typed configuration
- Attribute type validation at compile time
- Clear error messages when misused

### 3. Zero-overhead Abstraction

Wrapper classes should add negligible performance cost:

- Direct delegation to underlying OpenTelemetry SDK
- No unnecessary object creation in hot paths
- Lazy initialization where possible

## Core Components

### OtelTracer (Singleton)

**Why singleton?**
- Ensures consistent configuration across app
- Simplifies API (no need to pass tracer instances)
- Matches OpenTelemetry's global tracer provider pattern

**Key methods:**
```dart
initialize()  // Setup tracer provider
startSpan()   // Create a span
withSpan()    // Automatic span lifecycle
shutdown()    // Cleanup resources
```

**Thread safety:**
- Singleton is thread-safe via lazy initialization
- Underlying OpenTelemetry SDK handles concurrency

### OtelConfig (Value Object)

**Why immutable?**
- Configuration shouldn't change after initialization
- Enables safe sharing across isolates
- Prevents accidental misconfiguration

**Design pattern:**
- Builder-like constructor with named parameters
- `copyWith()` for creating variations
- `toResource()` for OpenTelemetry resource conversion

### OtelSpan (Wrapper)

**Why wrap Span?**
- Simplify attribute addition (auto-type detection)
- Provide convenience methods (`markSuccess()`, `markError()`)
- Hide OpenTelemetry complexity for common operations

**Delegation pattern:**
- Holds reference to underlying `Span`
- Exposes `span` property for advanced usage
- Methods delegate to wrapped span

### OtelHttpClient (Decorator)

**Why BaseClient?**
- Compatible with existing `http.Client` code
- Intercepts all HTTP methods automatically
- Enables drop-in replacement

**Implementation:**
```dart
class OtelHttpClient extends http.BaseClient {
  final http.Client _inner;
  
  Future<http.StreamedResponse> send(request) {
    // 1. Start span
    // 2. Inject trace context
    // 3. Execute request
    // 4. Record response
    // 5. End span
  }
}
```

**Context propagation:**
- Automatically injects W3C `traceparent` header
- Preserves `tracestate` for multi-vendor support
- Enables distributed tracing across services

### OtelErrorHandler (Global Hook)

**Why global?**
- Catches uncaught Flutter errors automatically
- No need to wrap every function
- Single point of configuration

**Integration points:**
1. `FlutterError.onError` - Framework errors
2. `PlatformDispatcher.instance.onError` - Async errors

**Best practices:**
- Still report errors in debug mode
- Include relevant context attributes
- Don't suppress original error handling

## Data Flow

### Span Lifecycle

```
User Code
   ↓
startSpan()
   ↓
OpenTelemetry Tracer
   ↓
Span Created
   ↓
[User adds attributes/events]
   ↓
span.end()
   ↓
Span Processor (Batch)
   ↓
Exporter
   ↓
Backend (OTLP endpoint)
```

### HTTP Request Tracing

```
client.get(url)
   ↓
OtelHttpClient.send()
   ↓
startSpan('HTTP GET')
   ↓
Add HTTP attributes
   ↓
Inject trace context
   ↓
Execute request
   ↓
Record response
   ↓
span.end()
   ↓
Return response
```

## Performance Considerations

### Sampling Strategy

**Default: 100% sampling**
- Simple and predictable
- Suitable for development and low-traffic apps

**Production recommendation:**
```dart
OtelConfig(
  sampleRate: 0.1,  // Sample 10% of traces
)
```

### Batch Processing

Spans are batched before export to reduce:
- Network calls
- Battery usage
- Data transfer costs

**Configuration:**
```dart
BatchSpanProcessor(
  exporter,
  maxQueueSize: 2048,
  scheduledDelayMillis: 5000,
  maxExportBatchSize: 512,
)
```

### Memory Management

**Span lifecycle:**
1. Span created (allocated)
2. User adds attributes (small allocations)
3. Span ended
4. Span added to batch queue
5. Batch exported
6. Span garbage collected

**Best practices:**
- End spans promptly
- Avoid long-running spans
- Limit attribute count per span

## Testing Strategy

### Unit Tests

Test individual components in isolation:
- Configuration validation
- Span attribute handling
- Error recording logic

### Integration Tests

Test component interactions:
- HTTP client + tracer
- Error handler + tracer
- Nested span context

### Example App

The example app serves as both:
- Documentation by example
- Manual testing tool
- Demonstration of best practices

## Extension Points

### Custom Exporters

Users can provide custom exporters:

```dart
final myExporter = MyCustomExporter();
final processor = BatchSpanProcessor(myExporter);

// Use with custom tracer provider
```

### Custom Attributes

All attribute methods accept `dynamic` values:

```dart
span.setAttribute('custom', myCustomObject);
// Falls back to toString()
```

### Custom HTTP Clients

Wrap any HTTP client:

```dart
class MyCustomHttpClient extends OtelHttpClient {
  MyCustomHttpClient() : super(
    client: MySpecialClient(),
  );
}
```

## Future Enhancements

### Metrics Support

Add metrics alongside traces:
```dart
OtelMetrics.instance.recordCounter('requests.count');
OtelMetrics.instance.recordHistogram('request.duration', ms);
```

### Logs Correlation

Link logs to traces:
```dart
logger.info('Processing started', traceId: span.traceId);
```

### Automatic Instrumentation

Auto-instrument common Flutter operations:
- Navigator route changes
- Database queries (sqflite)
- Image loading
- Network state changes

## Contributing Guidelines

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Maximum line length: 80 characters
- Use descriptive variable names
- Document public APIs

### Adding Features

1. Open an issue discussing the feature
2. Write tests first (TDD)
3. Implement feature
4. Update documentation
5. Add example to demo app
6. Submit PR

### Breaking Changes

Avoid breaking changes in minor versions:
- Use `@Deprecated` annotations
- Provide migration guide
- Keep old API for one major version

## References

- [OpenTelemetry Specification](https://opentelemetry.io/docs/specs/otel/)
- [W3C Trace Context](https://www.w3.org/TR/trace-context/)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
