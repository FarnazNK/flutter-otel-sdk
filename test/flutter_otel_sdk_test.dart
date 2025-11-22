import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_otel_sdk/flutter_otel_sdk.dart';
import 'package:opentelemetry/api.dart';

void main() {
  group('OtelConfig', () {
    test('creates config with required parameters', () {
      final config = OtelConfig(
        serviceName: 'test-service',
        endpoint: 'http://localhost:4318',
      );

      expect(config.serviceName, 'test-service');
      expect(config.endpoint, 'http://localhost:4318');
      expect(config.environment, 'production'); // default
      expect(config.sampleRate, 1.0); // default
      expect(config.debug, false); // default
    });

    test('creates config with all parameters', () {
      final config = OtelConfig(
        serviceName: 'test-service',
        endpoint: 'http://localhost:4318',
        headers: {'x-api-key': 'secret'},
        environment: 'staging',
        version: '1.0.0',
        sampleRate: 0.5,
        debug: true,
      );

      expect(config.serviceName, 'test-service');
      expect(config.endpoint, 'http://localhost:4318');
      expect(config.headers, {'x-api-key': 'secret'});
      expect(config.environment, 'staging');
      expect(config.version, '1.0.0');
      expect(config.sampleRate, 0.5);
      expect(config.debug, true);
    });

    test('copyWith creates new config with updated values', () {
      final original = OtelConfig(
        serviceName: 'test-service',
        endpoint: 'http://localhost:4318',
        environment: 'production',
      );

      final updated = original.copyWith(
        environment: 'staging',
        debug: true,
      );

      expect(updated.serviceName, 'test-service');
      expect(updated.endpoint, 'http://localhost:4318');
      expect(updated.environment, 'staging');
      expect(updated.debug, true);
    });

    test('toResource creates OpenTelemetry resource', () {
      final config = OtelConfig(
        serviceName: 'test-service',
        endpoint: 'http://localhost:4318',
        environment: 'production',
        version: '1.0.0',
      );

      final resource = config.toResource();

      expect(resource.attributes.length, greaterThan(0));
      
      final serviceNameAttr = resource.attributes.firstWhere(
        (attr) => attr.key == 'service.name',
      );
      expect(serviceNameAttr.value, 'test-service');
    });
  });

  group('OtelSpan', () {
    late Span mockSpan;
    late OtelSpan otelSpan;

    setUp(() {
      // Create a real span for testing (requires tracer initialization)
      // In a real test, you'd use a mock
      mockSpan = _MockSpan();
      otelSpan = OtelSpan(mockSpan);
    });

    test('setAttribute handles different types', () {
      // These would normally be verified with mock expectations
      expect(() => otelSpan.setAttribute('string', 'value'), returnsNormally);
      expect(() => otelSpan.setAttribute('int', 42), returnsNormally);
      expect(() => otelSpan.setAttribute('double', 3.14), returnsNormally);
      expect(() => otelSpan.setAttribute('bool', true), returnsNormally);
    });

    test('setAttributes handles map of attributes', () {
      final attributes = {
        'user.id': '123',
        'user.age': 25,
        'user.premium': true,
      };

      expect(() => otelSpan.setAttributes(attributes), returnsNormally);
    });

    test('addEvent creates span event', () {
      expect(() => otelSpan.addEvent('test-event'), returnsNormally);
      
      expect(
        () => otelSpan.addEvent('event-with-attrs', attributes: {
          'key': 'value',
          'count': 42,
        }),
        returnsNormally,
      );
    });

    test('recordException captures error info', () {
      final exception = Exception('Test error');
      final stackTrace = StackTrace.current;

      expect(
        () => otelSpan.recordException(exception, stackTrace: stackTrace),
        returnsNormally,
      );
    });

    test('convenience methods work', () {
      expect(() => otelSpan.markSuccess(), returnsNormally);
      expect(() => otelSpan.markError('test error'), returnsNormally);
    });
  });

  group('OtelTracer', () {
    test('throws error when not initialized', () {
      // Reset singleton for testing
      // Note: In production code, you'd need dependency injection
      // to make this properly testable
      
      expect(
        () => OtelTracer.instance.tracer,
        throwsStateError,
      );
    });

    test('singleton returns same instance', () {
      final instance1 = OtelTracer.instance;
      final instance2 = OtelTracer.instance;

      expect(identical(instance1, instance2), true);
    });
  });

  group('OtelHttpClient', () {
    test('can be instantiated', () {
      expect(() => OtelHttpClient(), returnsNormally);
    });

    // Integration tests would verify:
    // - Span creation on HTTP requests
    // - Header injection
    // - Error handling
    // - Response status recording
  });

  group('OtelErrorHandler', () {
    test('singleton returns same instance', () {
      final instance1 = OtelErrorHandler.instance;
      final instance2 = OtelErrorHandler.instance;

      expect(identical(instance1, instance2), true);
    });

    test('can be initialized', () {
      expect(() => OtelErrorHandler.instance.initialize(), returnsNormally);
    });

    test('recordError handles exceptions', () {
      final error = Exception('Test error');
      
      // This will no-op if tracer not initialized
      expect(
        () => OtelErrorHandler.instance.recordError(error),
        returnsNormally,
      );
    });
  });
}

// Mock span for testing
class _MockSpan implements Span {
  @override
  void addEvent(String name, {List<Attribute>? attributes, DateTime? timestamp}) {}

  @override
  void end({DateTime? endTime}) {}

  @override
  bool get isRecording => true;

  @override
  void recordException(dynamic exception, {StackTrace? stackTrace, List<Attribute>? attributes}) {}

  @override
  void setAttribute(Attribute attribute) {}

  @override
  void setAttributes(List<Attribute> attributes) {}

  @override
  void setStatus(StatusCode code, {String? description}) {}

  @override
  SpanContext get spanContext => _MockSpanContext();

  @override
  void updateName(String name) {}
}

class _MockSpanContext implements SpanContext {
  @override
  bool get isRemote => false;

  @override
  bool get isValid => true;

  @override
  SpanId get spanId => SpanId([0, 0, 0, 0, 0, 0, 0, 1]);

  @override
  int get traceFlags => 1;

  @override
  TraceId get traceId => TraceId([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]);

  @override
  String? get traceState => null;
}
