# Quick Start Guide

Get up and running with flutter_otel_sdk in 5 minutes.

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_otel_sdk: ^0.1.0
```

## Setup (3 steps)

### Step 1: Initialize

In your `main.dart`:

```dart
import 'package:flutter_otel_sdk/flutter_otel_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await OtelTracer.instance.initialize(
    OtelConfig(
      serviceName: 'my-app',
      endpoint: 'http://your-otlp-endpoint:4318',
    ),
  );
  
  runApp(MyApp());
}
```

### Step 2: Use HTTP Client

Replace your HTTP client:

```dart
// Before
final client = http.Client();

// After
final client = OtelHttpClient();
```

### Step 3: Add Custom Spans (Optional)

Wrap important operations:

```dart
await OtelTracer.instance.withSpan(
  'process-order',
  (span) async {
    span.setAttribute('order.id', orderId);
    return await processOrder();
  },
);
```

## That's It!

You're now tracking:
- ✅ All HTTP requests
- ✅ Custom business operations
- ✅ Errors and exceptions

## Next Steps

- **View traces**: Check your observability backend
- **Add attributes**: Enrich spans with business context
- **Learn more**: Read the [full README](README.md)

## Common Patterns

### Database Queries

```dart
await OtelTracer.instance.withSpan(
  'db.query',
  (span) async {
    span.setAttribute('db.statement', 'SELECT * FROM users');
    return await database.query('users');
  },
);
```

### User Actions

```dart
void onButtonPressed() async {
  await OtelTracer.instance.withSpan(
    'user.checkout',
    (span) async {
      span.setAttribute('user.id', currentUser.id);
      await performCheckout();
    },
  );
}
```

### Background Tasks

```dart
Future<void> syncData() async {
  await OtelTracer.instance.withSpan(
    'background.sync',
    (span) async {
      span.setAttribute('sync.type', 'full');
      await syncAllData();
    },
  );
}
```

## Need Help?

- 📖 [Full Documentation](README.md)
- 💬 [GitHub Discussions](https://github.com/yourusername/flutter_otel_sdk/discussions)
- 🐛 [Report Issues](https://github.com/yourusername/flutter_otel_sdk/issues)
