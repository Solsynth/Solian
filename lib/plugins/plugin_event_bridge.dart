import 'dart:async';

import 'package:island/core/services/event_bus.dart' as app;
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:logging/logging.dart';

final _log = Logger('PluginEventBridge');

/// Bridges the app's event bus to the plugin system.
///
/// Host-specific: depends on Island's [app.eventBus] event types.
class PluginEventBridge {
  static final PluginEventBridge _instance = PluginEventBridge._();
  factory PluginEventBridge() => _instance;
  PluginEventBridge._();

  final List<StreamSubscription> _subscriptions = [];
  bool _active = false;

  /// Start listening to app events and forwarding to plugins.
  void activate() {
    if (_active) return;
    _active = true;

    final bus = app.eventBus;

    _subscriptions.add(
      bus.on<app.PostCreatedEvent>().listen((_) {
        _dispatch('post.created');
      }),
    );

    _subscriptions.add(
      bus.on<app.PostUpdateEvent>().listen((_) {
        _dispatch('post.updated');
      }),
    );

    _subscriptions.add(
      bus.on<app.PostDeleteEvent>().listen((event) {
        _dispatch('post.deleted', {'postId': event.postId});
      }),
    );

    _subscriptions.add(
      bus.on<app.ChatMessageNewEvent>().listen((event) {
        _dispatch('message.received', {
          'messageId': event.message.id,
          'roomId': event.message.chatRoomId,
        });
      }),
    );

    _subscriptions.add(
      bus.on<app.ChatMessageUpdateEvent>().listen((event) {
        _dispatch('message.updated', {'messageId': event.message.id});
      }),
    );

    _subscriptions.add(
      bus.on<app.ChatMessageDeleteEvent>().listen((event) {
        _dispatch('message.deleted', {
          'messageId': event.messageId,
          'roomId': event.roomId,
        });
      }),
    );

    _subscriptions.add(
      bus.on<app.ChatTypingEvent>().listen((event) {
        _dispatch('chat.typing', {
          'roomId': event.roomId,
          'isTyping': event.isTyping,
        });
      }),
    );

    _log.info(
      'Plugin event bridge activated with ${_subscriptions.length} listeners',
    );
  }

  void _dispatch(String eventName, [Map<String, dynamic>? data]) {
    final manager = PluginManager();
    final hasActive = manager.plugins.values.any(
      (p) => p.state == PluginState.active,
    );

    if (!hasActive) return;

    manager.fireEvent(eventName, data);
  }

  /// Deactivate and remove all listeners.
  void deactivate() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _active = false;
    _log.info('Plugin event bridge deactivated');
  }

  bool get isActive => _active;
}
