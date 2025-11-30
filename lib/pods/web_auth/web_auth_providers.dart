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

class WebAuthServerNotifier extends StateNotifier<WebAuthServerState> {
  final WebAuthServer _server;

  WebAuthServerNotifier(this._server) : super(WebAuthServerState());

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
    StateNotifierProvider<WebAuthServerNotifier, WebAuthServerState>((ref) {
  final server = ref.watch(webAuthServerProvider);
  return WebAuthServerNotifier(server);
});
