import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'SDK Example', home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = 'Enter the port of the main app';
  String? _challenge;
  String? _token;
  String? _error;

  final _portController = TextEditingController(text: '40000');
  final _client = WebAuthClient(
    baseUrl: 'http://127.0.0.1',
    port: 40000,
    webUrl: 'https://app.solian.fr',
  );

  Future<void> _requestAuth() async {
    final port = int.tryParse(_portController.text);
    if (port == null || port < 1 || port > 65535) {
      setState(() {
        _status = 'Invalid port number';
        _error = 'Please enter a valid port (1-65535)';
      });
      return;
    }

    setState(() {
      _status = 'Requesting auth from main app...';
      _error = null;
      _challenge = null;
      _token = null;
    });

    _client.setPort(port);

    try {
      final result = await _client.waitForAuth();

      if (result.status == WebAuthStatus.challenge &&
          result.challenge != null) {
        setState(() {
          _challenge = result.challenge;
          _status = 'Challenge received! Signing...';
        });

        await _signAndExchange(result.challenge!);
      } else if (result.status == WebAuthStatus.error) {
        setState(() {
          _status = 'Auth request failed';
          _error = result.error ?? 'Unknown error';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Connection failed';
        _error = e.toString();
      });
    }
  }

  Future<void> _signAndExchange(String challenge) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final signedChallenge = _signChallenge(challenge);

    setState(() {
      _status = 'Exchanging signed challenge for token...';
    });

    try {
      final result = await _client.exchangeToken(signedChallenge);

      if (result.status == WebAuthStatus.success && result.token != null) {
        setState(() {
          _token = result.token;
          _status = 'Authentication successful!';
        });
      } else {
        setState(() {
          _status = 'Token exchange failed';
          _error = result.error ?? 'Unknown error';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Exchange failed';
        _error = e.toString();
      });
    }
  }

  String _signChallenge(String challenge) {
    final random = Random.secure();
    final values = List<int>.generate(64, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  void _reset() {
    setState(() {
      _challenge = null;
      _token = null;
      _error = null;
      _status = 'Ready to authenticate';
    });
  }

  @override
  void dispose() {
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3rd Party App - Auth Client')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Main App Port:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _portController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter port (e.g., 40000)',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _requestAuth,
                            child: const Text('Connect'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_status, style: const TextStyle(fontSize: 16)),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (_challenge != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Challenge received:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SelectableText(
                          _challenge!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (_token != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Token received!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SelectableText(
                          _token!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_token != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _reset,
                  child: const Text('Reset / Auth Again'),
                ),
              ],
              const SizedBox(height: 20),
              const Divider(),
              const Text(
                'Auth Flow:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('1. Enter main app port (e.g., 40000)'),
              const Text('2. Tap Connect to request auth'),
              const Text('3. Main app shows confirmation dialog'),
              const Text('4. User approves in main app'),
              const Text('5. This app receives challenge'),
              const Text('6. App signs the challenge'),
              const Text('7. App exchanges for token'),
              const SizedBox(height: 20),
              const Divider(),
              const Text(
                'Note:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Text(
                'Make sure the main app (Island) is running\nand has the auth server started on this port.',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension WebAuthClientExtension on WebAuthClient {
  void setPort(int port) {}
}
