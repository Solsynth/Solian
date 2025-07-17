import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/models/chat.dart';
import 'package:island/pods/network.dart';

part 'chat_summary.g.dart';

@riverpod
class ChatSummary extends _$ChatSummary {
  @override
  Future<Map<String, SnChatSummary>> build() async {
    final client = ref.watch(apiClientProvider);
    final resp = await client.get('/sphere/chat/summary');

    final Map<String, dynamic> data = resp.data;
    return data.map(
      (key, value) => MapEntry(key, SnChatSummary.fromJson(value)),
    );
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
        state = AsyncData({
          ...summaries,
          chatId: SnChatSummary(
            unreadCount: summary.unreadCount + 1,
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
}
