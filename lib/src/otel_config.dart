import 'package:opentelemetry/api.dart';

/// Configuration for OpenTelemetry SDK initialization
class OtelConfig {
  /// Service name to identify your application
  final String serviceName;

  /// OpenTelemetry endpoint URL
  final String endpoint;

  /// API key or authentication headers
  final Map<String, String>? headers;

  /// Environment (production, staging, development)
  final String environment;

  /// Application version
  final String? version;

  /// Sample rate (0.0 to 1.0)
  final double sampleRate;

  /// Enable debug logging
  final bool debug;

  const OtelConfig({
    required this.serviceName,
    required this.endpoint,
    this.headers,
    this.environment = 'production',
    this.version,
    this.sampleRate = 1.0,
    this.debug = false,
  });

  /// Create a Resource with service metadata
  Resource toResource() {
    final attributes = <Attribute>[
      Attribute.fromString('service.name', serviceName),
      Attribute.fromString('deployment.environment', environment),
    ];

    if (version != null) {
      attributes.add(Attribute.fromString('service.version', version!));
    }

    return Resource(attributes);
  }

  OtelConfig copyWith({
    String? serviceName,
    String? endpoint,
    Map<String, String>? headers,
    String? environment,
    String? version,
    double? sampleRate,
    bool? debug,
  }) {
    return OtelConfig(
      serviceName: serviceName ?? this.serviceName,
      endpoint: endpoint ?? this.endpoint,
      headers: headers ?? this.headers,
      environment: environment ?? this.environment,
      version: version ?? this.version,
      sampleRate: sampleRate ?? this.sampleRate,
      debug: debug ?? this.debug,
    );
  }
}
