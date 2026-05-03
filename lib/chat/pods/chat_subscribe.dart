import "dart:async";
import "dart:convert";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:island/chat/messages_notifier.dart";
import "package:island/chat/pods/chat_room.dart";
import "package:island/core/lifecycle.dart";
import "package:island/core/services/event_bus.dart";
import "package:island/core/websocket.dart";
import "package:logging/logging.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'chat_subscribe.g.dart';

final currentSubscribedChatIdProvider =
    NotifierProvider<CurrentSubscribedChatIdNotifier, String?>(
      CurrentSubscribedChatIdNotifier.new,
    );

class CurrentSubscribedChatIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

@riverpod
class ChatSubscribeNotifier extends _$ChatSubscribeNotifier {
  static const Duration _subscribeRefreshInterval = Duration(minutes: 4);
  late SnChatRoom _chatRoom;
  late SnChatMember _chatIdentity;

  final List<SnChatMember> _typingStatuses = [];
  Timer? _typingCleanupTimer;
  Timer? _typingCooldownTimer;
  Timer? _periodicSubscribeTimer;
  Function? _sendMessage;

  StreamSubscription<ChatTypingEvent>? _typingSub;

  bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  bool _isWebSocketConnected() => ref
      .read(websocketStateProvider)
      .maybeWhen(connected: () => true, orElse: () => false);

  bool _shouldKeepSubscriptionAlive() {
    if (_isDesktop) return true;
    final lifecycleState = ref.read(appLifecycleStateProvider).value;
    return lifecycleState == null ||
        lifecycleState == AppLifecycleState.resumed;
  }

  void _sendPacket(WebSocketPacket packet, {required String context}) {
    if (_sendMessage == null || !_isWebSocketConnected()) return;
    try {
      _sendMessage!(jsonEncode(packet));
    } catch (e, stackTrace) {
      Logger.root.severe(
        '[MessageSubscriber] Failed to send $context for room $roomId',
        e,
        stackTrace,
      );
    }
  }

  void _sendSubscribe({required String reason}) {
    if (!_shouldKeepSubscriptionAlive()) return;
    Logger.root.info('[MessageSubscriber] Subscribing room $roomId ($reason)');
    _sendPacket(
      WebSocketPacket(
        type: 'messages.subscribe',
        data: {'chat_room_id': roomId},
        endpoint: 'messager',
      ),
      context: 'subscribe ($reason)',
    );
  }

  void _sendUnsubscribe({required String reason}) {
    Logger.root.info(
      '[MessageSubscriber] Unsubscribing room $roomId ($reason)',
    );
    _sendPacket(
      WebSocketPacket(
        type: 'messages.unsubscribe',
        data: {'chat_room_id': roomId},
        endpoint: 'messager',
      ),
      context: 'unsubscribe ($reason)',
    );
  }

  void _cleanupResources() {
    if (_typingCleanupTimer != null) {
      _typingCleanupTimer!.cancel();
      _typingCleanupTimer = null;
    }
    if (_periodicSubscribeTimer != null) {
      _periodicSubscribeTimer!.cancel();
      _periodicSubscribeTimer = null;
    }
    _typingSub?.cancel();
  }

  @override
  List<SnChatMember> build(String roomId) {
    final chatRoomAsync = ref.watch(chatRoomProvider(roomId));
    final chatIdentityAsync = ref.watch(chatRoomIdentityProvider(roomId));
    ref.watch(messagesProvider(roomId));

    _cleanupResources();

    if (chatRoomAsync.isLoading || chatIdentityAsync.isLoading) {
      return [];
    }

    if (chatRoomAsync.value == null || chatIdentityAsync.value == null) {
      return [];
    }

    _chatRoom = chatRoomAsync.value!;
    _chatIdentity = chatIdentityAsync.value!;

    // Subscribe to messages
    final wsState = ref.read(websocketStateProvider.notifier);
    _sendMessage = wsState.sendMessage;
    _sendSubscribe(reason: 'initial');

    Future.microtask(
      () => ref.read(currentSubscribedChatIdProvider.notifier).set(roomId),
    );

    // Send initial read receipt
    sendReadReceipt();

    // Real-time message events are handled directly by MessagesNotifier
    // through RealtimeMessageHandler to avoid duplicate event processing.

    // Listen for typing events via Event Bus
    _typingSub = eventBus.on<ChatTypingEvent>().listen((event) {
      if (event.roomId != _chatRoom.id) return;
      if (event.sender.id == _chatIdentity.id) return;

      // Check if the sender is already in the typing list
      final existingIndex = _typingStatuses.indexWhere(
        (member) => member.id == event.sender.id,
      );
      if (existingIndex >= 0) {
        // Update the existing entry with new timestamp
        _typingStatuses[existingIndex] = event.sender.copyWith(
          lastTyped: DateTime.now(),
        );
      } else {
        // Add new typing status
        _typingStatuses.add(event.sender.copyWith(lastTyped: DateTime.now()));
      }
      if (ref.mounted) state = List.of(_typingStatuses);
    });

    // Set up typing status cleanup timer
    _typingCleanupTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_typingStatuses.isNotEmpty) {
        // Remove typing statuses older than 5 seconds
        final now = DateTime.now();
        _typingStatuses.removeWhere((member) {
          final lastTyped =
              member.lastTyped ??
              DateTime.now().subtract(const Duration(milliseconds: 1350));
          return now.difference(lastTyped).inSeconds > 5;
        });
        if (ref.mounted) state = List.of(_typingStatuses);
      }
    });

    // Keep subscription alive before the backend expiry window.
    _periodicSubscribeTimer = Timer.periodic(_subscribeRefreshInterval, (_) {
      if (ref.mounted) _sendSubscribe(reason: 'periodic-refresh');
    });

    ref.listen(appLifecycleStateProvider, (previous, next) {
      if (_isDesktop) return;
      final lifecycleState = next.value;
      if (lifecycleState == AppLifecycleState.paused ||
          lifecycleState == AppLifecycleState.inactive) {
        // Unsubscribe when app goes to background
        _sendUnsubscribe(reason: 'app-background');
      } else if (lifecycleState == AppLifecycleState.resumed) {
        // Resubscribe when app comes back to foreground
        _sendSubscribe(reason: 'app-resumed');
      }
    });

    ref.listen(websocketStateProvider, (previous, next) {
      final wasConnected =
          previous?.maybeWhen(connected: () => true, orElse: () => false) ??
          false;
      final isConnected = next.maybeWhen(
        connected: () => true,
        orElse: () => false,
      );
      if (!wasConnected && isConnected) {
        _sendSubscribe(reason: 'ws-reconnected');
      }
    });

    final subscribedNotifier = ref.watch(
      currentSubscribedChatIdProvider.notifier,
    );

    ref.onCancel(() {
      Future.microtask(() {
        if (!ref.mounted) return;
        final current = ref.read(currentSubscribedChatIdProvider);
        if (current == roomId) {
          subscribedNotifier.set(null);
        }
      });
      // Defer to avoid ref.read() inside lifecycle callback
      Future.microtask(() {
        if (!ref.mounted) return;
        _sendUnsubscribe(reason: 'provider-cancel');
      });
      try {
        _cleanupResources();
      } catch (e, stackTrace) {
        Logger.root.severe(
          '[MessageSubscriber] Error during cleanup for room $roomId',
          e,
          stackTrace,
        );
      }
      try {
        if (_typingCooldownTimer != null) {
          _typingCooldownTimer!.cancel();
        }
      } catch (e, stackTrace) {
        Logger.root.severe(
          '[MessageSubscriber] Error cancelling typing cooldown timer for room $roomId',
          e,
          stackTrace,
        );
      }
    });

    return _typingStatuses;
  }

  void sendReadReceipt() {
    if (!ref.mounted) return;
    _sendPacket(
      WebSocketPacket(
        type: 'messages.read',
        data: {'chat_room_id': roomId},
        endpoint: 'messager',
      ),
      context: 'read-receipt',
    );
  }

  void sendTypingStatus() {
    // Don't send if we're already in a cooldown period
    if (_typingCooldownTimer != null) return;

    _sendPacket(
      WebSocketPacket(
        type: 'messages.typing',
        data: {'chat_room_id': roomId},
        endpoint: 'messager',
      ),
      context: 'typing-status',
    );

    _typingCooldownTimer = Timer(const Duration(milliseconds: 850), () {
      _typingCooldownTimer = null;
    });
  }
}
