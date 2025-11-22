import 'dart:async';
import 'package:flutter/foundation.dart';
import 'otel_tracer.dart';

/// Global error handler with OpenTelemetry integration
class OtelErrorHandler {
  static final OtelErrorHandler _instance = OtelErrorHandler._();
  static OtelErrorHandler get instance => _instance;

  OtelErrorHandler._();

  /// Initialize error tracking
  void initialize() {
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Catch async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    final tracer = OtelTracer.instance;
    
    if (!tracer.isInitialized) {
      // Fallback to default handler
      FlutterError.presentError(details);
      return;
    }

    final span = tracer.startSpan('flutter.error');
    
    span.setAttributes({
      'error.type': 'FlutterError',
      'error.library': details.library ?? 'unknown',
      'error.context': details.context?.toString() ?? 'none',
    });

    span.recordException(
      details.exception,
      stackTrace: details.stack,
      attributes: {
        'error.informationCollector': details.informationCollector?.toString(),
      },
    );

    span.setStatus(StatusCode.error, description: details.exceptionAsString());
    span.end();

    // Still present error in debug mode
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  void _handlePlatformError(Object error, StackTrace stack) {
    final tracer = OtelTracer.instance;
    
    if (!tracer.isInitialized) {
      return;
    }

    final span = tracer.startSpan('platform.error');
    
    span.setAttributes({
      'error.type': 'PlatformError',
      'error.runtime': 'dart',
    });

    span.recordException(error, stackTrace: stack);
    span.setStatus(StatusCode.error, description: error.toString());
    span.end();
  }

  /// Manually record an error
  void recordError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? attributes,
    String? spanName,
  }) {
    final tracer = OtelTracer.instance;
    
    if (!tracer.isInitialized) {
      return;
    }

    final span = tracer.startSpan(spanName ?? 'error');
    
    if (attributes != null) {
      span.setAttributes(attributes);
    }

    span.recordException(error, stackTrace: stackTrace);
    span.setStatus(StatusCode.error, description: error.toString());
    span.end();
  }

  /// Wrap a function with error tracking
  Future<T> track<T>(
    Future<T> Function() fn, {
    String? spanName,
    Map<String, dynamic>? attributes,
  }) async {
    try {
      return await fn();
    } catch (e, stackTrace) {
      recordError(
        e,
        stackTrace: stackTrace,
        attributes: attributes,
        spanName: spanName ?? 'tracked.error',
      );
      rethrow;
    }
  }
}
