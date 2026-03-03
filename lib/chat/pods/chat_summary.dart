import 'dart:async';
import 'dart:math' as math;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/chat/pods/chat_subscribe.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'chat_summary.g.dart';

@riverpod
class ChatUnreadCountNotifier extends _$ChatUnreadCountNotifier {
  StreamSubscription<WebSocketPacket>? _subscription;

  @override
  Future<int> build() async {
    // Subscribe to websocket events when this provider is built
    _subscribeToWebSocket();

    // Dispose the subscription when this provider is disposed
    ref.onDispose(() {
      _subscription?.cancel();
    });

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('/messager/chat/unread');
      return (response.data as num).toInt();
    } catch (_) {
      return 0;
    }
  }

  void _subscribeToWebSocket() {
    final webSocketService = ref.read(websocketProvider);
    _subscription = webSocketService.dataStream.listen((packet) {
      if (packet.type == 'messages.new' && packet.data != null) {
        final message = SnChatMessage.fromJson(packet.data!);
        final currentSubscribed = ref.read(currentSubscribedChatIdProvider);
        // Only increment if the message is not from the currently subscribed chat
        if (message.chatRoomId != currentSubscribed) {
          _incrementCounter();
        }
      }
    });
  }

  Future<void> _incrementCounter() async {
    final current = await future;
    state = AsyncData(current + 1);
  }

  Future<void> decrement(int count) async {
    final current = await future;
    state = AsyncData(math.max(current - count, 0));
  }

  void clear() async {
    state = AsyncData(0);
  }
}

@Riverpod(keepAlive: true)
class ChatSummary extends _$ChatSummary {
  String? _normalizeEncryptionMessageType(
    dynamic value, {
    dynamic messageType,
  }) {
    final raw = value?.toString();
    switch (raw) {
      case 'content.new':
      case 'text':
        return 'text';
      case 'content.edit':
      case 'messages.update':
        return 'messages.update';
      case 'content.delete':
      case 'messages.delete':
        return 'messages.delete';
    }
    final fallback = messageType?.toString();
    if (fallback == 'text' ||
        fallback == 'messages.update' ||
        fallback == 'messages.delete') {
      return fallback;
    }
    return raw;
  }

  Map<String, dynamic> _sanitizeChatMessageJson(Map<String, dynamic> input) {
    final data = Map<String, dynamic>.from(input);
    final meta = data['meta'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['meta'] as Map<String, dynamic>)
        : <String, dynamic>{};
    if (data['is_encrypted'] == true) {
      meta['e2ee_is_encrypted'] = true;
      meta['e2ee_ciphertext'] = data['ciphertext'];
      meta['e2ee_header'] = data['encryption_header'];
      meta['e2ee_signature'] = data['encryption_signature'];
      meta['e2ee_scheme'] = data['encryption_scheme'];
      meta['e2ee_epoch'] = data['encryption_epoch'];
      final normalizedType = _normalizeEncryptionMessageType(
        data['encryption_message_type'],
        messageType: data['type'],
      );
      if (normalizedType != null) {
        meta['e2ee_message_type'] = normalizedType;
      }
      meta['e2ee_client_message_id'] = data['client_message_id'];
    }
    data['meta'] = meta;
    return data;
  }

  SnChatMessage? _tryParseChatMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return SnChatMessage.fromJson(_sanitizeChatMessageJson(data));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, SnChatSummary>> build() async {
    final client = ref.watch(apiClientProvider);
    final resp = await client.get('/messager/chat/summary');

    final Map<String, dynamic> data = resp.data;
    final summaries = data.map((key, value) {
      final json = value is Map<String, dynamic>
          ? Map<String, dynamic>.from(value)
          : <String, dynamic>{};
      final last = _tryParseChatMessage(json['last_message']);
      if (last != null) {
        json['last_message'] = last.toJson();
      }
      return MapEntry(key, SnChatSummary.fromJson(json));
    });

    final ws = ref.watch(websocketProvider);
    final subscription = ws.dataStream.listen((WebSocketPacket pkt) {
      if (!pkt.type.startsWith('messages')) return;
      if (pkt.type == 'messages.new') {
        final message = _tryParseChatMessage(pkt.data);
        if (message == null) return;
        updateLastMessage(message.chatRoomId, message);
      } else if (pkt.type == 'messages.update') {
        final message = _tryParseChatMessage(pkt.data);
        if (message == null) return;
        updateMessageContent(message.chatRoomId, message);
      }
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return summaries;
  }

  Future<void> clearUnreadCount(String chatId) async {
    state.whenData((summaries) {
      final summary = summaries[chatId];
      if (summary != null) {
        // Decrement global unread count
        final unreadToDecrement = summary.unreadCount;
        if (unreadToDecrement > 0) {
          ref
              .read(chatUnreadCountProvider.notifier)
              .decrement(unreadToDecrement);
        }

        state = AsyncData({
          ...summaries,
          chatId: SnChatSummary(
            unreadCount: 0,
            lastMessage: summary.lastMessage,
          ),
        });
      }
    });
  }

  void updateLastMessage(String chatId, SnChatMessage message) {
    state.whenData((summaries) {
      final summary = summaries[chatId];
      if (summary != null) {
        final currentSubscribed = ref.read(currentSubscribedChatIdProvider);
        final increment = (chatId != currentSubscribed) ? 1 : 0;
        state = AsyncData({
          ...summaries,
          chatId: SnChatSummary(
            unreadCount: summary.unreadCount + increment,
            lastMessage: message,
          ),
        });
      }
    });
  }

  void incrementUnreadCount(String chatId) {
    state.whenData((summaries) {
      final summary = summaries[chatId];
      if (summary != null) {
        state = AsyncData({
          ...summaries,
          chatId: SnChatSummary(
            unreadCount: summary.unreadCount + 1,
            lastMessage: summary.lastMessage,
          ),
        });
      }
    });
  }

  void updateMessageContent(String chatId, SnChatMessage message) {
    state.whenData((summaries) {
      final summary = summaries[chatId];
      if (summary != null && summary.lastMessage?.id == message.id) {
        state = AsyncData({
          ...summaries,
          chatId: SnChatSummary(
            unreadCount: summary.unreadCount,
            lastMessage: message,
          ),
        });
      }
    });
  }
}
