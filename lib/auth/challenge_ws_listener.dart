import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/websocket.dart';
import 'package:logging/logging.dart';

final challengeWsListenerProvider = Provider<ChallengeWsListener>((ref) {
  final listener = ChallengeWsListener(ref);
  ref.onDispose(() => listener.dispose());
  return listener;
});

class ChallengeWsListener {
  static const _pendingType = 'auth.challenge.pending';

  final _logger = Logger('ChallengeWsListener');
  final Ref _ref;
  StreamSubscription<WebSocketPacket>? _subscription;

  ChallengeWsListener(this._ref);

  void start() {
    _subscription?.cancel();
    final ws = _ref.read(websocketProvider);
    _subscription = ws.dataStream.listen(_handlePacket);
    _logger.info('Started listening for challenge WebSocket packets');
  }

  void _handlePacket(WebSocketPacket packet) {
    if (packet.type != _pendingType) return;
    if (packet.data == null) return;

    _logger.info('Received challenge pending packet');
    eventBus.fire(ChallengePendingEvent(packet.data!));
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
