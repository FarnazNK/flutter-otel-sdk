import 'package:opentelemetry/api.dart';
import 'package:opentelemetry/sdk.dart' as sdk;
import 'otel_config.dart';
import 'otel_span.dart';

/// Main class for managing OpenTelemetry tracing
class OtelTracer {
  static OtelTracer? _instance;
  late final Tracer _tracer;
  late final OtelConfig _config;
  bool _initialized = false;

  OtelTracer._();

  /// Get singleton instance
  static OtelTracer get instance {
    _instance ??= OtelTracer._();
    return _instance!;
  }

  /// Initialize the OpenTelemetry SDK
  Future<void> initialize(OtelConfig config) async {
    if (_initialized) {
      throw StateError('OtelTracer already initialized');
    }

    _config = config;

    // Create OTLP exporter
    final exporter = sdk.ConsoleExporter();
    
    // In production, you'd use:
    // final exporter = sdk.OtlpGrpcSpanExporter(
    //   endpoint: config.endpoint,
    //   headers: config.headers ?? {},
    // );

    // Create span processor
    final processor = sdk.BatchSpanProcessor(exporter);

    // Create tracer provider with sampling
    final tracerProvider = sdk.TracerProviderBase(
      processors: [processor],
      resource: config.toResource(),
      sampler: sdk.TraceIdRatioBasedSampler(config.sampleRate),
    );

    // Register global tracer provider
    registerGlobalTracerProvider(tracerProvider);

    // Get tracer instance
    _tracer = tracerProvider.getTracer(
      config.serviceName,
      version: config.version,
    );

    _initialized = true;

    if (config.debug) {
      print('[OtelTracer] Initialized with service: ${config.serviceName}');
    }
  }

  /// Check if tracer is initialized
  bool get isInitialized => _initialized;

  /// Get the underlying tracer
  Tracer get tracer {
    _ensureInitialized();
    return _tracer;
  }

  /// Get current configuration
  OtelConfig get config {
    _ensureInitialized();
    return _config;
  }

  /// Start a new span with simplified API
  OtelSpan startSpan(
    String name, {
    SpanKind kind = SpanKind.internal,
    Map<String, dynamic>? attributes,
    Context? context,
  }) {
    _ensureInitialized();

    final span = _tracer.startSpan(
      name,
      kind: kind,
      context: context,
    );

    // Add custom attributes
    if (attributes != null) {
      for (final entry in attributes.entries) {
        _addAttribute(span, entry.key, entry.value);
      }
    }

    return OtelSpan(span);
  }

  /// Execute a function within a span context
  Future<T> withSpan<T>(
    String name,
    Future<T> Function(OtelSpan span) fn, {
    SpanKind kind = SpanKind.internal,
    Map<String, dynamic>? attributes,
  }) async {
    final span = startSpan(name, kind: kind, attributes: attributes);

    try {
      final result = await fn(span);
      span.setStatus(StatusCode.ok);
      return result;
    } catch (e, stackTrace) {
      span.recordException(e, stackTrace: stackTrace);
      span.setStatus(StatusCode.error, description: e.toString());
      rethrow;
    } finally {
      span.end();
    }
  }

  /// Execute a synchronous function within a span context
  T withSpanSync<T>(
    String name,
    T Function(OtelSpan span) fn, {
    SpanKind kind = SpanKind.internal,
    Map<String, dynamic>? attributes,
  }) {
    final span = startSpan(name, kind: kind, attributes: attributes);

    try {
      final result = fn(span);
      span.setStatus(StatusCode.ok);
      return result;
    } catch (e, stackTrace) {
      span.recordException(e, stackTrace: stackTrace);
      span.setStatus(StatusCode.error, description: e.toString());
      rethrow;
    } finally {
      span.end();
    }
  }

  /// Flush all pending spans
  Future<void> flush() async {
    _ensureInitialized();
    // Implementation depends on the exporter
    // Most exporters support forceFlush()
  }

  /// Shutdown the tracer provider
  Future<void> shutdown() async {
    if (!_initialized) return;
    
    // Flush pending spans
    await flush();
    
    _initialized = false;
    
    if (_config.debug) {
      print('[OtelTracer] Shutdown complete');
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'OtelTracer not initialized. Call initialize() first.',
      );
    }
  }

  void _addAttribute(Span span, String key, dynamic value) {
    if (value is String) {
      span.setAttribute(Attribute.fromString(key, value));
    } else if (value is int) {
      span.setAttribute(Attribute.fromInt(key, value));
    } else if (value is double) {
      span.setAttribute(Attribute.fromDouble(key, value));
    } else if (value is bool) {
      span.setAttribute(Attribute.fromBoolean(key, value));
    } else if (value is List<String>) {
      span.setAttribute(Attribute.fromStringList(key, value));
    } else if (value is List<int>) {
      span.setAttribute(Attribute.fromIntList(key, value));
    } else if (value is List<double>) {
      span.setAttribute(Attribute.fromDoubleList(key, value));
    } else if (value is List<bool>) {
      span.setAttribute(Attribute.fromBooleanList(key, value));
    } else {
      // Fallback to string representation
      span.setAttribute(Attribute.fromString(key, value.toString()));
    }
  }
}
