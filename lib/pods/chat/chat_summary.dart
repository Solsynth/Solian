import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/models/chat.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/pods/chat/chat_subscribe.dart';

part 'chat_summary.g.dart';

@riverpod
class ChatSummary extends _$ChatSummary {
  @override
  Future<Map<String, SnChatSummary>> build() async {
    final client = ref.watch(apiClientProvider);
    final resp = await client.get('/sphere/chat/summary');

    final Map<String, dynamic> data = resp.data;
    final summaries = data.map(
      (key, value) => MapEntry(key, SnChatSummary.fromJson(value)),
    );

    final ws = ref.watch(websocketProvider);
    final subscription = ws.dataStream.listen((WebSocketPacket pkt) {
      if (!pkt.type.startsWith('messages')) return;
      if (pkt.type == 'messages.new') {
        final message = SnChatMessage.fromJson(pkt.data!);
        updateLastMessage(message.chatRoomId, message);
      } else if (pkt.type == 'messages.update') {
        final message = SnChatMessage.fromJson(pkt.data!);
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
