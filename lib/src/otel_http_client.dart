import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:opentelemetry/api.dart';
import 'otel_tracer.dart';
import 'otel_span.dart';

/// HTTP Client with automatic OpenTelemetry instrumentation
class OtelHttpClient extends http.BaseClient {
  final http.Client _inner;
  final OtelTracer _tracer;

  OtelHttpClient({http.Client? client})
      : _inner = client ?? http.Client(),
        _tracer = OtelTracer.instance;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!_tracer.isInitialized) {
      return _inner.send(request);
    }

    final span = _tracer.startSpan(
      'HTTP ${request.method}',
      kind: SpanKind.client,
      attributes: {
        'http.method': request.method,
        'http.url': request.url.toString(),
        'http.scheme': request.url.scheme,
        'http.host': request.url.host,
        'http.target': request.url.path,
      },
    );

    try {
      // Add trace context to headers for distributed tracing
      _injectTraceContext(request, span);

      final response = await _inner.send(request);

      // Add response attributes
      span.setAttribute('http.status_code', response.statusCode);
      
      if (response.statusCode >= 400) {
        span.setStatus(
          StatusCode.error,
          description: 'HTTP ${response.statusCode}',
        );
      } else {
        span.setStatus(StatusCode.ok);
      }

      return response;
    } catch (e, stackTrace) {
      span.recordException(e, stackTrace: stackTrace);
      span.setStatus(StatusCode.error, description: e.toString());
      rethrow;
    } finally {
      span.end();
    }
  }

  void _injectTraceContext(http.BaseRequest request, OtelSpan span) {
    // Inject W3C trace context headers
    final context = span.context;
    
    request.headers['traceparent'] = 
        '00-${context.traceId.toString()}-${context.spanId.toString()}-${context.traceFlags.toString().padLeft(2, '0')}';
    
    if (context.traceState != null && context.traceState!.isNotEmpty) {
      request.headers['tracestate'] = context.traceState!;
    }
  }

  @override
  void close() {
    _inner.close();
  }
}

/// Convenience extension methods for common HTTP operations
extension OtelHttpExtensions on OtelHttpClient {
  /// Make a GET request with automatic tracing
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final request = http.Request('GET', url);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    final streamedResponse = await send(request);
    return http.Response.fromStream(streamedResponse);
  }

  /// Make a POST request with automatic tracing
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final request = http.Request('POST', url);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else {
        throw ArgumentError('Invalid body type');
      }
    }
    final streamedResponse = await send(request);
    return http.Response.fromStream(streamedResponse);
  }

  /// Make a PUT request with automatic tracing
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final request = http.Request('PUT', url);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else {
        throw ArgumentError('Invalid body type');
      }
    }
    final streamedResponse = await send(request);
    return http.Response.fromStream(streamedResponse);
  }

  /// Make a DELETE request with automatic tracing
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final request = http.Request('DELETE', url);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    final streamedResponse = await send(request);
    return http.Response.fromStream(streamedResponse);
  }
}
