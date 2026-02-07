import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/udid.dart';
import 'package:island/talker.dart';

class WebAuthServer {
  final Ref _ref;
  HttpServer? _server;
  String? _challenge;
  DateTime? _challengeTimestamp;

  final _challengeTtl = const Duration(seconds: 30);

  WebAuthServer(this._ref);

  Future<int> start() async {
    if (_server != null) {
      talker.warning('Web auth server already running.');
      return _server!.port;
    }

    final port = await _findUnusedPort(40000, 41000);
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    talker.info('Web auth server started on http://127.0.0.1:$port');

    _server!.listen(_handleRequest);
    return port;
  }

  void stop() {
    _server?.close(force: true);
    _server = null;
    talker.info('Web auth server stopped.');
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
      } catch (e) {
        // Port is in use, try next
      }
    }
    throw Exception('No unused port found in range $start-$end');
  }

  String _generateChallenge() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  void _addCorsHeaders(HttpResponse response) {
    const webUrl = 'https://app.solian.fr';

    response.headers.add('Access-Control-Allow-Origin', webUrl);
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

      talker.info('Web auth request: ${request.method} ${request.uri.path}');

      if (request.method == 'GET' && request.uri.path == '/alive') {
        await _handleAlive(request);
      } else if (request.method == 'POST' && request.uri.path == '/exchange') {
        await _handleExchange(request);
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write(jsonEncode({'error': 'Not Found'}));
        await request.response.close();
      }
    } catch (e, st) {
      talker.handle(e, st, 'Error handling web auth request');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.write(jsonEncode({'error': 'Internal Server Error'}));
        await request.response.close();
      } catch (e2) {
        talker.error('Failed to send error response: $e2');
      }
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
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(requestBody);
    } catch (e) {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write(jsonEncode({'error': 'Invalid JSON body'}));
      await request.response.close();
      return;
    }

    final String? signedChallenge = data['signed_challenge'];

    if (signedChallenge == null) {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write(jsonEncode({'error': 'Missing signedChallenge'}));
      await request.response.close();
      return;
    }

    _challenge = null;
    _challengeTimestamp = null;

    try {
      final dio = _ref.read(apiClientProvider);

      // Call the remote API to generate a new session belongs to the current session
      final response = await dio.post(
        '/pass/auth/login/session',
        data: {
          'device_id': await getUdid(),
          'device_name': await getDeviceName(),
          'platform': kIsWeb
              ? 1
              : switch (defaultTargetPlatform) {
                  TargetPlatform.iOS => 2,
                  TargetPlatform.android => 3,
                  TargetPlatform.macOS => 4,
                  TargetPlatform.windows => 5,
                  TargetPlatform.linux => 6,
                  _ => 0,
                },
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final webToken = response.data['token'];
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'token': webToken}));
      } else {
        throw Exception(
          'Backend exchange failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      talker.error('Backend exchange failed: ${e.response?.data}');
      request.response.statusCode =
          e.response?.statusCode ?? HttpStatus.internalServerError;
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode(
          e.response?.data ?? {'error': 'Backend communication failed'},
        ),
      );
    } catch (e, st) {
      talker.handle(e, st, 'Error during backend exchange');
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({'error': 'An unexpected error occurred'}),
      );
    } finally {
      await request.response.close();
    }
  }
}

class WebAuthServerState {
  final bool isRunning;
  final int? port;
  final Object? error;

  WebAuthServerState({this.isRunning = false, this.port, this.error});

  WebAuthServerState copyWith({
    bool? isRunning,
    int? port,
    Object? error,
    bool clearError = false,
  }) {
    return WebAuthServerState(
      isRunning: isRunning ?? this.isRunning,
      port: port ?? this.port,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class WebAuthServerNotifier extends Notifier<WebAuthServerState> {
  late final WebAuthServer _server;

  @override
  WebAuthServerState build() {
    _server = ref.watch(webAuthServerProvider);
    return WebAuthServerState();
  }

  Future<void> start() async {
    try {
      final port = await _server.start();
      state = state.copyWith(isRunning: true, port: port, clearError: true);
    } catch (e) {
      state = state.copyWith(isRunning: false, error: e);
    }
  }

  void stop() {
    _server.stop();
    state = state.copyWith(isRunning: false, port: null);
  }
}

final webAuthServerProvider = Provider<WebAuthServer>((ref) {
  return WebAuthServer(ref);
});

final webAuthServerStateProvider =
    NotifierProvider<WebAuthServerNotifier, WebAuthServerState>(
      WebAuthServerNotifier.new,
    );
