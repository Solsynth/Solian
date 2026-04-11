import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

class LocalHttpServer {
  static const List<int> defaultPortRange = [50000, 60000];
  static const String kLogPrefix = 'local.http';

  HttpServer? _httpServer;
  Handler? _handler;

  int? get port => _httpServer?.port;
  bool get isRunning => _httpServer != null;

  Future<void> start({List<int>? portRange, required Handler handler}) async {
    if (_httpServer != null) {
      Logger.root.info('[$kLogPrefix] Server already running on port $port');
      return;
    }

    final range = portRange ?? defaultPortRange;
    int currentPort = range[0];

    while (currentPort <= range[1]) {
      try {
        Logger.root.info(
          '[$kLogPrefix] Attempting to bind to port $currentPort',
        );
        _httpServer = await HttpServer.bind(
          InternetAddress.loopbackIPv4,
          currentPort,
        );
        _handler = handler;
        Logger.root.info('[$kLogPrefix] Listening on port $currentPort');

        shelf_io.serveRequests(_httpServer!, handler);
        return;
      } on SocketException catch (e) {
        if (e.osError?.errorCode == 98) {
          Logger.root.info(
            '[$kLogPrefix] Port $currentPort in use, trying next...',
          );
        } else {
          Logger.root.info(
            '[$kLogPrefix] Socket error on port $currentPort: $e',
          );
        }
        currentPort++;
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        Logger.root.info(
          '[$kLogPrefix] Error binding to port $currentPort: $e',
        );
        currentPort++;
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    throw Exception(
      'Failed to bind to any port in range ${range[0]}–${range[1]}',
    );
  }

  Future<void> stop() async {
    if (_httpServer != null) {
      await _httpServer!.close(force: true);
      _httpServer = null;
      _handler = null;
      Logger.root.info('[$kLogPrefix] Server stopped');
    }
  }

  Future<Response> handleRequest(Request request) async {
    if (_handler == null) {
      return Response.notFound('Server not configured');
    }
    return _handler!(request);
  }
}
