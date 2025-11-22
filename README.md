# Flutter OpenTelemetry SDK

A simplified, production-ready Flutter wrapper for OpenTelemetry that makes observability easy for mobile and cross-platform applications.

## Features

- 🚀 **Automatic HTTP instrumentation** - Trace all HTTP requests with zero code changes
- 📊 **Custom span creation** - Full control over manual instrumentation
- 🔥 **Error tracking** - Automatic exception capture and reporting
- 🌐 **Distributed tracing** - W3C trace context propagation
- 🎯 **Type-safe API** - Strongly typed configuration and attributes
- 📱 **Flutter-optimized** - Built specifically for Flutter/Dart ecosystem
- 🔧 **Developer-friendly** - Minimal boilerplate, maximum clarity

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_otel_sdk: ^0.1.0
```

## Quick Start

### 1. Initialize the SDK

```dart
import 'package:flutter_otel_sdk/flutter_otel_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OpenTelemetry
  await OtelTracer.instance.initialize(
    OtelConfig(
      serviceName: 'my-flutter-app',
      endpoint: 'https://api.your-backend.com/v1/traces',
      headers: {
        'x-api-key': 'your-api-key',
      },
      environment: 'production',
      version: '1.0.0',
      sampleRate: 1.0, // Sample 100% of traces
      debug: false,
    ),
  );

  // Optional: Initialize error tracking
  OtelErrorHandler.instance.initialize();

  runApp(MyApp());
}
```

### 2. Automatic HTTP Instrumentation

Replace your HTTP client with `OtelHttpClient` for automatic tracing:

```dart
final client = OtelHttpClient();

// Every HTTP call is automatically traced
final response = await client.get(
  Uri.parse('https://api.example.com/users'),
);

// Trace context is automatically propagated via W3C headers
```

### 3. Manual Span Creation

Create custom spans for business logic:

```dart
await OtelTracer.instance.withSpan(
  'process-checkout',
  (span) async {
    // Add custom attributes
    span.setAttribute('user.id', userId);
    span.setAttribute('cart.total', 99.99);
    span.setAttribute('items.count', 3);

    // Your business logic here
    final order = await processOrder();

    // Add events
    span.addEvent('payment-processed', attributes: {
      'payment.method': 'credit_card',
      'transaction.id': order.transactionId,
    });

    return order;
  },
);
```

## API Reference

### Configuration

```dart
OtelConfig(
  serviceName: 'my-service',        // Required: Your service name
  endpoint: 'https://...',          // Required: OTLP endpoint
  headers: {},                      // Optional: Auth headers
  environment: 'production',        // Optional: Environment name
  version: '1.0.0',                 // Optional: App version
  sampleRate: 1.0,                  // Optional: 0.0 to 1.0
  debug: false,                     // Optional: Enable debug logs
)
```

### Creating Spans

#### With error handling

```dart
await OtelTracer.instance.withSpan(
  'operation-name',
  (span) async {
    // Your code here
    // Errors are automatically captured
  },
  kind: SpanKind.internal,
  attributes: {'key': 'value'},
);
```

#### Manual span management

```dart
final span = OtelTracer.instance.startSpan(
  'manual-operation',
  attributes: {'custom.attribute': 'value'},
);

try {
  // Your code here
  span.setStatus(StatusCode.ok);
} catch (e, stackTrace) {
  span.recordException(e, stackTrace: stackTrace);
  span.setStatus(StatusCode.error);
} finally {
  span.end();
}
```

### Adding Attributes

```dart
span.setAttribute('string.value', 'hello');
span.setAttribute('int.value', 42);
span.setAttribute('double.value', 3.14);
span.setAttribute('bool.value', true);

// Or add multiple at once
span.setAttributes({
  'user.id': '12345',
  'user.premium': true,
  'session.duration': 300,
});
```

### Adding Events

```dart
span.addEvent('cache-hit', attributes: {
  'cache.key': 'user:12345',
  'cache.ttl': 3600,
});

span.addEvent('validation-failed', attributes: {
  'field': 'email',
  'reason': 'invalid format',
});
```

### Error Tracking

#### Automatic error tracking

```dart
// Initialize once in main()
OtelErrorHandler.instance.initialize();

// All uncaught errors are automatically tracked
```

#### Manual error recording

```dart
try {
  throw Exception('Something went wrong');
} catch (e, stackTrace) {
  OtelErrorHandler.instance.recordError(
    e,
    stackTrace: stackTrace,
    attributes: {'context': 'user-action'},
  );
}
```

### HTTP Client

```dart
final client = OtelHttpClient();

// GET request
final response = await client.get(
  Uri.parse('https://api.example.com/data'),
  headers: {'Authorization': 'Bearer token'},
);

// POST request
await client.post(
  Uri.parse('https://api.example.com/data'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'key': 'value'}),
);

// Other methods: PUT, DELETE, etc.
```

## Architecture Decisions

### Why this design?

1. **Singleton pattern for tracer**: Ensures consistent configuration across the app
2. **Wrapper classes**: Simplified API without losing OpenTelemetry flexibility
3. **Automatic instrumentation**: Reduces boilerplate for common operations
4. **Type-safe attributes**: Prevents runtime errors from incorrect attribute types
5. **Error-first design**: Automatic error capture without try-catch boilerplate

### Performance Considerations

- **Sampling**: Use `sampleRate < 1.0` in production to reduce overhead
- **Batch export**: Spans are batched before sending to reduce network calls
- **Async operations**: All span exports are asynchronous and non-blocking
- **Memory efficient**: Spans are immediately flushed after ending

## Examples

Check out the `/example` directory for a complete Flutter app demonstrating:

- Automatic HTTP tracing
- Custom span creation
- Nested spans
- Error tracking
- Multiple concurrent operations
- Event logging

## Comparison with OpenTelemetry Dart

| Feature | flutter_otel_sdk | opentelemetry-dart |
|---------|------------------|-------------------|
| Setup complexity | 5 lines | 30+ lines |
| HTTP auto-instrumentation | ✅ Built-in | ❌ Manual |
| Error tracking | ✅ Built-in | ❌ Manual |
| Type-safe attributes | ✅ Yes | ⚠️ Partial |
| Flutter-specific | ✅ Yes | ❌ General Dart |
| Learning curve | Low | High |

## Contributing

Contributions welcome! Areas for improvement:

- [ ] Additional HTTP client support (Dio, etc.)
- [ ] Database query instrumentation
- [ ] Navigation/routing instrumentation
- [ ] Performance metrics
- [ ] Custom exporters

## Testing

```bash
# Run tests
flutter test

# Run example app
cd example
flutter run
```

## License

MIT License - see LICENSE file for details

## Acknowledgments

Built on top of the excellent [opentelemetry-dart](https://pub.dev/packages/opentelemetry) package.

## Support

- 📖 [Documentation](https://github.com/yourusername/flutter_otel_sdk)
- 🐛 [Issue Tracker](https://github.com/yourusername/flutter_otel_sdk/issues)
- 💬 [Discussions](https://github.com/yourusername/flutter_otel_sdk/discussions)

---

Made with ❤️ for the Flutter and OpenTelemetry communities
