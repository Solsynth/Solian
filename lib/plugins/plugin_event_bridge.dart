import 'dart:async';
import 'package:logging/logging.dart';
import 'package:island/core/services/event_bus.dart' as app;
import 'package:island/plugins/plugin_manager.dart';
import 'package:island/plugins/models/plugin_manifest.dart';

final _log = Logger('PluginEventBridge');

/// Bridges the app's event bus to the plugin system.
///
/// Listens to app events and forwards them to plugins that have subscribed.
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

  /// Forward an event to all subscribed plugins.
  void _dispatch(String eventName, [Map<String, dynamic>? data]) {
    final manager = PluginManager();
    final hasActive = manager.plugins.values
        .any((p) => p.state == PluginState.active);

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

  /// Whether the bridge is currently active.
  bool get isActive => _active;
}
