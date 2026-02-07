import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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
  late final Dio _dio;
  late final SharedPreferencesTokenStorage _tokenStorage;
  late final WebAuthServer _webAuthServer;
  int? _serverPort;
  String _status = 'Not started';

  @override
  void initState() {
    super.initState();
    _dio = Dio(BaseOptions(baseUrl: 'https://api.solian.app'));
    _tokenStorage = SharedPreferencesTokenStorage(key: 'solar_token');
    _webAuthServer = WebAuthServer(
      webUrl: 'https://app.solian.fr',
      getDio: () => _dio,
    );
  }

  Future<void> _startAuthServer() async {
    try {
      final port = await _webAuthServer.start();
      setState(() {
        _serverPort = port;
        _status = 'Running on port $port';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  void _stopAuthServer() {
    _webAuthServer.stop();
    setState(() {
      _serverPort = null;
      _status = 'Stopped';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solar Network SDK Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Status: $_status'),
            const SizedBox(height: 20),
            if (_serverPort == null)
              ElevatedButton(
                onPressed: _startAuthServer,
                child: const Text('Start Auth Server'),
              )
            else
              ElevatedButton(
                onPressed: _stopAuthServer,
                child: const Text('Stop Auth Server'),
              ),
          ],
        ),
      ),
    );
  }
}
