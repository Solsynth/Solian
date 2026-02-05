import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'web_auth_server.dart';

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
