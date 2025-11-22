import 'package:opentelemetry/api.dart';

/// Wrapper class for OpenTelemetry Span with simplified API
class OtelSpan {
  final Span _span;

  OtelSpan(this._span);

  /// Get the underlying span
  Span get span => _span;

  /// Add a string attribute
  void setAttribute(String key, dynamic value) {
    if (value is String) {
      _span.setAttribute(Attribute.fromString(key, value));
    } else if (value is int) {
      _span.setAttribute(Attribute.fromInt(key, value));
    } else if (value is double) {
      _span.setAttribute(Attribute.fromDouble(key, value));
    } else if (value is bool) {
      _span.setAttribute(Attribute.fromBoolean(key, value));
    } else {
      _span.setAttribute(Attribute.fromString(key, value.toString()));
    }
  }

  /// Add multiple attributes at once
  void setAttributes(Map<String, dynamic> attributes) {
    for (final entry in attributes.entries) {
      setAttribute(entry.key, entry.value);
    }
  }

  /// Add an event to the span
  void addEvent(String name, {Map<String, dynamic>? attributes}) {
    final eventAttributes = <Attribute>[];
    
    if (attributes != null) {
      for (final entry in attributes.entries) {
        if (entry.value is String) {
          eventAttributes.add(Attribute.fromString(entry.key, entry.value));
        } else if (entry.value is int) {
          eventAttributes.add(Attribute.fromInt(entry.key, entry.value));
        } else if (entry.value is double) {
          eventAttributes.add(Attribute.fromDouble(entry.key, entry.value));
        } else if (entry.value is bool) {
          eventAttributes.add(Attribute.fromBoolean(entry.key, entry.value));
        } else {
          eventAttributes.add(Attribute.fromString(entry.key, entry.value.toString()));
        }
      }
    }

    _span.addEvent(name, attributes: eventAttributes);
  }

  /// Record an exception
  void recordException(
    dynamic exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? attributes,
  }) {
    final exceptionAttributes = <Attribute>[
      Attribute.fromString('exception.type', exception.runtimeType.toString()),
      Attribute.fromString('exception.message', exception.toString()),
    ];

    if (stackTrace != null) {
      exceptionAttributes.add(
        Attribute.fromString('exception.stacktrace', stackTrace.toString()),
      );
    }

    if (attributes != null) {
      for (final entry in attributes.entries) {
        if (entry.value is String) {
          exceptionAttributes.add(Attribute.fromString(entry.key, entry.value));
        } else {
          exceptionAttributes.add(Attribute.fromString(entry.key, entry.value.toString()));
        }
      }
    }

    _span.addEvent('exception', attributes: exceptionAttributes);
  }

  /// Set span status
  void setStatus(StatusCode code, {String? description}) {
    _span.setStatus(code, description: description);
  }

  /// Mark span as successful
  void markSuccess() {
    setStatus(StatusCode.ok);
  }

  /// Mark span as failed
  void markError(String message) {
    setStatus(StatusCode.error, description: message);
  }

  /// End the span
  void end() {
    _span.end();
  }

  /// Get span context for propagation
  SpanContext get context => _span.spanContext;
}
