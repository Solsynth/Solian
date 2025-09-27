import "dart:async";
import "dart:convert";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/models/chat.dart";
import "package:island/pods/lifecycle.dart";
import "package:island/pods/chat/messages_notifier.dart";
import "package:island/pods/websocket.dart";
import "package:island/screens/chat/chat.dart";
import "package:island/widgets/chat/call_button.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

part 'chat_subscribe.g.dart';

@riverpod
class ChatSubscribeNotifier extends _$ChatSubscribeNotifier {
  late final String _roomId;
  late final SnChatRoom _chatRoom;
  late final SnChatMember _chatIdentity;
  late final MessagesNotifier _messagesNotifier;

  final List<SnChatMember> _typingStatuses = [];
  Timer? _typingCleanupTimer;
  Timer? _typingCooldownTimer;
  Timer? _periodicSubscribeTimer;
  StreamSubscription? _wsSubscription;

  @override
  List<SnChatMember> build(String roomId) {
    _roomId = roomId;
    final ws = ref.watch(websocketProvider);
    final chatRoomAsync = ref.watch(chatroomProvider(roomId));
    final chatIdentityAsync = ref.watch(chatroomIdentityProvider(roomId));
    _messagesNotifier = ref.watch(messagesNotifierProvider(roomId).notifier);

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
    wsState.sendMessage(
      jsonEncode(
        WebSocketPacket(
          type: 'messages.subscribe',
          data: {'chat_room_id': roomId},
          endpoint: 'sphere',
        ),
      ),
    );

    // Send initial read receipt
    sendReadReceipt();

    // Set up WebSocket listener
    _wsSubscription = ws.dataStream.listen(onMessage);

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
        state = List.of(_typingStatuses);
      }
    });

    // Set up periodic subscribe timer (every 5 minutes)
    _periodicSubscribeTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      final wsState = ref.read(websocketStateProvider.notifier);
      wsState.sendMessage(
        jsonEncode(
          WebSocketPacket(
            type: 'messages.subscribe',
            data: {'chat_room_id': roomId},
            endpoint: 'sphere',
          ),
        ),
      );
    });

    // Listen to app lifecycle changes
    ref.listen(appLifecycleStateProvider, (previous, next) {
      final lifecycleState = next.value;
      if (lifecycleState == AppLifecycleState.paused ||
          lifecycleState == AppLifecycleState.inactive) {
        // Unsubscribe when app goes to background
        final wsState = ref.read(websocketStateProvider.notifier);
        wsState.sendMessage(
          jsonEncode(
            WebSocketPacket(
              type: 'messages.unsubscribe',
              data: {'chat_room_id': roomId},
            ),
          ),
        );
      } else if (lifecycleState == AppLifecycleState.resumed) {
        // Resubscribe when app comes back to foreground
        final wsState = ref.read(websocketStateProvider.notifier);
        wsState.sendMessage(
          jsonEncode(
            WebSocketPacket(
              type: 'messages.subscribe',
              data: {'chat_room_id': roomId},
            ),
          ),
        );
      }
    });

    // Cleanup on dispose
    ref.onDispose(() {
      wsState.sendMessage(
        jsonEncode(
          WebSocketPacket(
            type: 'messages.unsubscribe',
            data: {'chat_room_id': roomId},
          ),
        ),
      );
      _wsSubscription?.cancel();
      _typingCleanupTimer?.cancel();
      _typingCooldownTimer?.cancel();
      _periodicSubscribeTimer?.cancel();
    });

    return _typingStatuses;
  }

  void onMessage(WebSocketPacket pkt) {
    if (!pkt.type.startsWith('messages')) return;
    if (['messages.read'].contains(pkt.type)) return;

    if (pkt.type == 'messages.typing' && pkt.data?['sender'] != null) {
      if (pkt.data?['room_id'] != _chatRoom.id) return;
      if (pkt.data?['sender_id'] == _chatIdentity.id) return;

      final sender = SnChatMember.fromJson(
        pkt.data?['sender'],
      ).copyWith(lastTyped: DateTime.now());

      // Check if the sender is already in the typing list
      final existingIndex = _typingStatuses.indexWhere(
        (member) => member.id == sender.id,
      );
      if (existingIndex >= 0) {
        // Update the existing entry with new timestamp
        _typingStatuses[existingIndex] = sender;
      } else {
        // Add new typing status
        _typingStatuses.add(sender);
      }
      state = List.of(_typingStatuses);
      return;
    }

    final message = SnChatMessage.fromJson(pkt.data!);
    if (message.chatRoomId != _chatRoom.id) return;
    switch (pkt.type) {
      case 'messages.new':
      case 'messages.update':
      case 'messages.delete':
        if (message.type.startsWith('call')) {
          // Handle the ongoing call.
          ref.invalidate(ongoingCallProvider(message.chatRoomId));
        }
        _messagesNotifier.receiveMessage(message);
        // Send read receipt for new message
        sendReadReceipt();
    }
  }

  void sendReadReceipt() {
    // Send websocket packet
    final wsState = ref.read(websocketStateProvider.notifier);
    wsState.sendMessage(
      jsonEncode(
        WebSocketPacket(
          type: 'messages.read',
          data: {'chat_room_id': _roomId},
          endpoint: 'sphere',
        ),
      ),
    );
  }

  void sendTypingStatus() {
    // Don't send if we're already in a cooldown period
    if (_typingCooldownTimer != null) return;

    // Send typing status immediately
    final wsState = ref.read(websocketStateProvider.notifier);
    wsState.sendMessage(
      jsonEncode(
        WebSocketPacket(
          type: 'messages.typing',
          data: {'chat_room_id': _roomId},
          endpoint: 'sphere',
        ),
      ),
    );

    _typingCooldownTimer = Timer(const Duration(milliseconds: 850), () {
      _typingCooldownTimer = null;
    });
  }
}
