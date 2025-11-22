import 'package:flutter/material.dart';
import 'package:flutter_otel_sdk/flutter_otel_sdk.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OpenTelemetry
  await OtelTracer.instance.initialize(
    OtelConfig(
      serviceName: 'flutter-demo-app',
      endpoint: 'http://localhost:4318', // Your OTLP endpoint
      environment: 'development',
      version: '1.0.0',
      sampleRate: 1.0,
      debug: true,
    ),
  );

  // Initialize error tracking
  OtelErrorHandler.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenTelemetry Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _httpClient = OtelHttpClient();
  String _result = 'Tap a button to see instrumentation in action';
  bool _loading = false;

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  Future<void> _makeApiCall() async {
    setState(() {
      _loading = true;
      _result = 'Making API call...';
    });

    try {
      // Automatic HTTP instrumentation
      final response = await _httpClient.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
      );

      final data = json.decode(response.body);

      setState(() {
        _result = 'Success! Title: ${data['title']}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _customSpanExample() async {
    setState(() {
      _loading = true;
      _result = 'Running custom span...';
    });

    try {
      // Manual span creation with custom attributes
      await OtelTracer.instance.withSpan(
        'process-user-data',
        (span) async {
          span.setAttribute('user.id', '12345');
          span.setAttribute('operation.type', 'data-processing');

          // Simulate processing
          await Future.delayed(const Duration(milliseconds: 500));

          span.addEvent('data-validated', attributes: {
            'records.count': 100,
            'validation.passed': true,
          });

          // Simulate more work
          await Future.delayed(const Duration(milliseconds: 300));

          span.addEvent('data-transformed', attributes: {
            'transformation.type': 'normalize',
          });

          setState(() {
            _result = 'Custom span completed successfully!';
            _loading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _nestedSpansExample() async {
    setState(() {
      _loading = true;
      _result = 'Running nested spans...';
    });

    try {
      await OtelTracer.instance.withSpan(
        'parent-operation',
        (parentSpan) async {
          parentSpan.setAttribute('operation.level', 'parent');

          // First child operation
          await OtelTracer.instance.withSpan(
            'child-operation-1',
            (childSpan) async {
              childSpan.setAttribute('child.index', 1);
              await Future.delayed(const Duration(milliseconds: 200));
              childSpan.addEvent('child-1-complete');
            },
          );

          // Second child operation
          await OtelTracer.instance.withSpan(
            'child-operation-2',
            (childSpan) async {
              childSpan.setAttribute('child.index', 2);
              await Future.delayed(const Duration(milliseconds: 300));
              childSpan.addEvent('child-2-complete');
            },
          );

          parentSpan.addEvent('all-children-complete');

          setState(() {
            _result = 'Nested spans completed successfully!';
            _loading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _errorTrackingExample() async {
    setState(() {
      _loading = true;
      _result = 'Triggering error...';
    });

    try {
      await OtelTracer.instance.withSpan(
        'operation-with-error',
        (span) async {
          span.setAttribute('will.fail', true);

          await Future.delayed(const Duration(milliseconds: 200));

          // Simulate an error
          throw Exception('Intentional error for demonstration');
        },
      );
    } catch (e) {
      setState(() {
        _result = 'Error tracked successfully: $e';
        _loading = false;
      });
    }
  }

  Future<void> _multipleApiCallsExample() async {
    setState(() {
      _loading = true;
      _result = 'Making multiple API calls...';
    });

    try {
      await OtelTracer.instance.withSpan(
        'fetch-multiple-posts',
        (span) async {
          span.setAttribute('posts.count', 3);

          final futures = [
            _httpClient.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1')),
            _httpClient.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/2')),
            _httpClient.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/3')),
          ];

          final responses = await Future.wait(futures);

          span.addEvent('all-posts-fetched', attributes: {
            'successful.count': responses.length,
          });

          setState(() {
            _result = 'Successfully fetched ${responses.length} posts!';
            _loading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('OpenTelemetry Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.analytics, size: 48, color: Colors.deepPurple),
                      const SizedBox(height: 16),
                      Text(
                        _result,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (_loading) ...[
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _makeApiCall,
                    icon: const Icon(Icons.api),
                    label: const Text('HTTP Call'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _customSpanExample,
                    icon: const Icon(Icons.timeline),
                    label: const Text('Custom Span'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _nestedSpansExample,
                    icon: const Icon(Icons.account_tree),
                    label: const Text('Nested Spans'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _errorTrackingExample,
                    icon: const Icon(Icons.error),
                    label: const Text('Error Tracking'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _multipleApiCallsExample,
                    icon: const Icon(Icons.cloud_queue),
                    label: const Text('Multiple Calls'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Check your console for OpenTelemetry traces',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
