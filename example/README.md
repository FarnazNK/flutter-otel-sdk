# Example App - flutter_otel_sdk

This example demonstrates all features of the flutter_otel_sdk package.

## What's Demonstrated

### 1. Automatic HTTP Tracing
- HTTP requests are automatically instrumented
- Trace context is propagated via W3C headers
- Response status codes are captured

### 2. Custom Span Creation
- Manual span creation with custom attributes
- Event logging within spans
- Proper span lifecycle management

### 3. Nested Spans
- Parent-child span relationships
- Context propagation between spans
- Hierarchical operation tracking

### 4. Error Tracking
- Automatic exception capture
- Stack trace recording
- Error context attributes

### 5. Multiple Concurrent Operations
- Parallel HTTP requests
- Span correlation across async operations
- Batch operation tracking

## Running the Example

### Prerequisites

1. Flutter SDK 3.0.0 or later
2. An OpenTelemetry backend (optional)

### Quick Start

```bash
# Navigate to example directory
cd example

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run
```

### With Backend (Optional)

To send traces to a real backend:

1. **Set up a local collector** (using Docker):

```bash
docker run -d --name otel-collector \
  -p 4318:4318 \
  otel/opentelemetry-collector:latest
```

2. **Update endpoint in `main.dart`**:

```dart
await OtelTracer.instance.initialize(
  OtelConfig(
    serviceName: 'flutter-demo-app',
    endpoint: 'http://localhost:4318/v1/traces', // Your collector
    // ... other config
  ),
);
```

3. **Run the app and interact** - traces will be sent to your collector

## Code Examples

### Basic HTTP Call

```dart
final client = OtelHttpClient();
final response = await client.get(
  Uri.parse('https://api.example.com/data'),
);
// Automatically traced!
```

### Custom Span

```dart
await OtelTracer.instance.withSpan(
  'process-data',
  (span) async {
    span.setAttribute('record.count', 100);
    
    // Your logic here
    await processData();
    
    span.addEvent('processing-complete');
  },
);
```

### Error Handling

```dart
try {
  await riskyOperation();
} catch (e, stackTrace) {
  OtelErrorHandler.instance.recordError(
    e,
    stackTrace: stackTrace,
    attributes: {'operation': 'risky'},
  );
}
```

## Viewing Traces

### Console Output (Default)

The example uses `ConsoleExporter` by default, so traces will appear in your terminal:

```
Span: HTTP GET
  Attributes:
    - http.method: GET
    - http.url: https://api.example.com/data
    - http.status_code: 200
  Duration: 234ms
```

### With Jaeger

1. **Start Jaeger**:
```bash
docker run -d --name jaeger \
  -p 16686:16686 \
  -p 4318:4318 \
  jaegertracing/all-in-one:latest
```

2. **Update config to use OTLP exporter**

3. **View traces**: http://localhost:16686

### With Honeycomb

1. **Get API key** from honeycomb.io

2. **Update config**:
```dart
OtelConfig(
  serviceName: 'flutter-demo-app',
  endpoint: 'https://api.honeycomb.io/v1/traces',
  headers: {
    'x-honeycomb-team': 'YOUR_API_KEY',
    'x-honeycomb-dataset': 'flutter-demo',
  },
)
```

## Customization

### Change Service Name

Edit `main.dart`:
```dart
OtelConfig(
  serviceName: 'my-custom-app-name',
  // ...
)
```

### Adjust Sample Rate

For production, reduce sampling:
```dart
OtelConfig(
  sampleRate: 0.1, // Sample 10% of traces
  // ...
)
```

### Add Custom Attributes

Add app-wide attributes:
```dart
final config = OtelConfig(
  serviceName: 'my-app',
  // ...
);

// All spans will include this attribute
```

## Troubleshooting

### Traces Not Appearing

1. **Check endpoint**: Ensure OTLP endpoint is correct
2. **Network access**: Verify app can reach the endpoint
3. **Enable debug**: Set `debug: true` in config
4. **Check console**: Look for error messages

### Performance Issues

1. **Reduce sample rate**: Lower from 1.0 to 0.1 or less
2. **Batch size**: Tune batch processor settings
3. **Async operations**: Ensure spans are ended promptly

### Memory Leaks

1. **End spans**: Always call `span.end()`
2. **Use `withSpan`**: Automatic span lifecycle
3. **Close HTTP client**: Call `client.close()` on dispose

## Next Steps

- Read the [main README](../README.md)
- Check [ARCHITECTURE.md](../ARCHITECTURE.md) for design details
- See [CONTRIBUTING.md](../CONTRIBUTING.md) to contribute
- Review [OpenTelemetry docs](https://opentelemetry.io/docs/)

## Questions?

Open an issue on GitHub or start a discussion!
