import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';

class WebAuthServer {
  final String _webUrl;
  final Dio Function() _getDio;

  HttpServer? _server;
  String? _challenge;
  DateTime? _challengeTimestamp;
  final _challengeTtl = const Duration(seconds: 30);
  final int _portStart;

  WebAuthServer({
    required String webUrl,
    required Dio Function() getDio,
    int portStart = 40000,
  }) : _webUrl = webUrl,
       _getDio = getDio,
       _portStart = portStart;

  Future<int> start() async {
    if (_server != null) {
      return _server!.port;
    }

    final port = await _findUnusedPort(_portStart, _portStart + 1000);
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server!.listen(_handleRequest);
    return port;
  }

  void stop() {
    _server?.close(force: true);
    _server = null;
  }

  Future<int> _findUnusedPort(int start, int end) async {
    for (var port = start; port <= end; port++) {
      try {
        var socket = await ServerSocket.bind(
          InternetAddress.loopbackIPv4,
          port,
        );
        await socket.close();
        return port;
      } catch (_) {}
    }
    throw Exception('No unused port found in range $start-$end');
  }

  String _generateChallenge() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  void _addCorsHeaders(HttpResponse response) {
    response.headers.add('Access-Control-Allow-Origin', _webUrl);
    response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    response.headers.add('Access-Control-Allow-Headers', '*');
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      _addCorsHeaders(request.response);

      if (request.method == 'OPTIONS') {
        request.response.statusCode = HttpStatus.noContent;
        await request.response.close();
        return;
      }

      if (request.method == 'GET' && request.uri.path == '/alive') {
        await _handleAlive(request);
      } else if (request.method == 'POST' && request.uri.path == '/exchange') {
        await _handleExchange(request);
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write(jsonEncode({'error': 'Not Found'}));
        await request.response.close();
      }
    } catch (e) {
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write(jsonEncode({'error': 'Internal Server Error'}));
      await request.response.close();
    }
  }

  Future<void> _handleAlive(HttpRequest request) async {
    _challenge = _generateChallenge();
    _challengeTimestamp = DateTime.now();

    final response = {'status': 'ok', 'challenge': _challenge};

    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(response));
    await request.response.close();
  }

  Future<void> _handleExchange(HttpRequest request) async {
    if (_challenge == null ||
        _challengeTimestamp == null ||
        DateTime.now().difference(_challengeTimestamp!) > _challengeTtl) {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write(
        jsonEncode({
          'error': 'Invalid or expired challenge. Please call /alive first.',
        }),
      );
      await request.response.close();
      return;
    }

    final requestBody = await utf8.decodeStream(request);
    Map<String, dynamic> data;
    try {
      data = jsonDecode(requestBody);
    } catch (e) {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write(jsonEncode({'error': 'Invalid JSON body'}));
      await request.response.close();
      return;
    }

    final String? signedChallenge = data['signedChallenge'];
    final Map<String, dynamic>? deviceInfo = data['deviceInfo'];

    if (signedChallenge == null) {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write(jsonEncode({'error': 'Missing signedChallenge'}));
      await request.response.close();
      return;
    }

    final currentChallenge = _challenge!;
    _challenge = null;
    _challengeTimestamp = null;

    try {
      final dio = _getDio();

      final response = await dio.post(
        '/pass/auth/login/session',
        data: {
          'signedChallenge': signedChallenge,
          'challenge': currentChallenge,
          ...?deviceInfo,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final webToken = response.data['token'];
        request.response.statusCode = HttpStatus.ok;
        request.response.write(jsonEncode({'token': webToken}));
      } else {
        throw Exception(
          'Backend exchange failed with status ${response.statusCode}',
        );
      }
    } catch (e) {
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write(jsonEncode({'error': e.toString()}));
    } finally {
      await request.response.close();
    }
  }
}
