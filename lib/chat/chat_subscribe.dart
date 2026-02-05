import "dart:async";
import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:island/chat/chat_widgets/call_button.dart";
import "package:island/chat/messages_notifier.dart";
import "package:just_audio/just_audio.dart";
import "package:island/core/config.dart";
import "package:island/chat/chat_models/chat.dart";
import "package:island/chat/chat_pod/chat_room.dart";
import "package:island/core/lifecycle.dart";
import "package:island/core/websocket.dart";
import "package:island/talker.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

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
  late SnChatRoom _chatRoom;
  late SnChatMember _chatIdentity;
  late MessagesNotifier _messagesNotifier;

  final List<SnChatMember> _typingStatuses = [];
  Timer? _typingCleanupTimer;
  Timer? _typingCooldownTimer;
  Timer? _periodicSubscribeTimer;
  StreamSubscription? _wsSubscription;
  Function? _sendMessage;

  void _cleanupResources() {
    if (_wsSubscription != null) {
      _wsSubscription!.cancel();
      _wsSubscription = null;
    }
    if (_typingCleanupTimer != null) {
      _typingCleanupTimer!.cancel();
      _typingCleanupTimer = null;
    }
    if (_periodicSubscribeTimer != null) {
      _periodicSubscribeTimer!.cancel();
      _periodicSubscribeTimer = null;
    }
  }

  @override
  List<SnChatMember> build(String roomId) {
    final ws = ref.watch(websocketProvider);
    final chatRoomAsync = ref.watch(chatRoomProvider(roomId));
    final chatIdentityAsync = ref.watch(chatRoomIdentityProvider(roomId));
    _messagesNotifier = ref.watch(messagesProvider(roomId).notifier);

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
    talker.info('[MessageSubscriber] Subscribing room $roomId');
    _sendMessage!(
      jsonEncode(
        WebSocketPacket(
          type: 'messages.subscribe',
          data: {'chat_room_id': roomId},
          endpoint: 'messager',
        ),
      ),
    );

    Future.microtask(
      () => ref.read(currentSubscribedChatIdProvider.notifier).set(roomId),
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
      _sendMessage!(
        jsonEncode(
          WebSocketPacket(
            type: 'messages.subscribe',
            data: {'chat_room_id': roomId},
            endpoint: 'messager',
          ),
        ),
      );
    });

    ref.listen(appLifecycleStateProvider, (previous, next) {
      final lifecycleState = next.value;
      if (lifecycleState == AppLifecycleState.paused ||
          lifecycleState == AppLifecycleState.inactive) {
        // Unsubscribe when app goes to background
        talker.info('[MessageSubscriber] Unsubscribing room $roomId');
        _sendMessage!(
          jsonEncode(
            WebSocketPacket(
              type: 'messages.unsubscribe',
              data: {'chat_room_id': roomId},
              endpoint: 'messager',
            ),
          ),
        );
      } else if (lifecycleState == AppLifecycleState.resumed) {
        // Resubscribe when app comes back to foreground
        talker.info('[MessageSubscriber] Subscribing room $roomId');
        _sendMessage!(
          jsonEncode(
            WebSocketPacket(
              type: 'messages.subscribe',
              data: {'chat_room_id': roomId},
              endpoint: 'messager',
            ),
          ),
        );
      }
    });

    final subscribedNotifier = ref.watch(
      currentSubscribedChatIdProvider.notifier,
    );

    ref.onCancel(() {
      talker.info('[MessageSubscriber] Unsubscribing room $roomId');
      subscribedNotifier.set(null);
      try {
        _sendMessage!(
          jsonEncode(
            WebSocketPacket(
              type: 'messages.unsubscribe',
              data: {'chat_room_id': roomId},
              endpoint: 'messager',
            ),
          ),
        );
      } catch (e, stackTrace) {
        talker.error(
          '[MessageSubscriber] Error sending unsubscribe message for room $roomId: $e\n$stackTrace',
        );
      }
      try {
        _cleanupResources();
      } catch (e, stackTrace) {
        talker.error(
          '[MessageSubscriber] Error during cleanup for room $roomId: $e\n$stackTrace',
        );
      }
      try {
        if (_typingCooldownTimer != null) {
          _typingCooldownTimer!.cancel();
        }
      } catch (e, stackTrace) {
        talker.error(
          '[MessageSubscriber] Error cancelling typing cooldown timer for room $roomId: $e\n$stackTrace',
        );
      }
    });

    return _typingStatuses;
  }

  Future<void> onMessage(WebSocketPacket pkt) async {
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
      if (ref.mounted) state = List.of(_typingStatuses);
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
        // Play sound for new messages when app is unfocused
        if (pkt.type == 'messages.new' &&
            message.senderId != _chatIdentity.id &&
            ref.read(appLifecycleStateProvider).value !=
                AppLifecycleState.resumed &&
            ref.read(appSettingsProvider).soundEffects) {
          final player = AudioPlayer();
          await player.setVolume(0.75);
          await player.setAudioSource(
            AudioSource.asset('assets/audio/messages.mp3'),
          );
          await player.play();
          player.dispose();
        }
    }
  }

  void sendReadReceipt() {
    // Send websocket packet
    if (_sendMessage == null) return;
    _sendMessage!(
      jsonEncode(
        WebSocketPacket(
          type: 'messages.read',
          data: {'chat_room_id': roomId},
          endpoint: 'messager',
        ),
      ),
    );
  }

  void sendTypingStatus() {
    // Don't send if we're already in a cooldown period
    if (_typingCooldownTimer != null) return;

    // Send typing status immediately
    if (_sendMessage == null) return;
    _sendMessage!(
      jsonEncode(
        WebSocketPacket(
          type: 'messages.typing',
          data: {'chat_room_id': roomId},
          endpoint: 'messager',
        ),
      ),
    );

    _typingCooldownTimer = Timer(const Duration(milliseconds: 850), () {
      _typingCooldownTimer = null;
    });
  }
}
