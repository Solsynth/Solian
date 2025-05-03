import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/database/drift_db.dart';
import 'package:island/database/message.dart';
import 'package:island/database/message_repository.dart';
import 'package:island/models/chat.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';

// Global database instance
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final messageRepositoryProvider =
    FutureProvider.family<MessageRepository, SnChat>((ref, chat) async {
      final apiClient = ref.watch(apiClientProvider);
      final database = ref.watch(databaseProvider);
      return MessageRepository(chat, apiClient, database);
    });

final chatMessagesProvider =
    FutureProvider.family<List<LocalChatMessage>, SnChat>((ref, room) async {
      final repository = await ref.watch(
        messageRepositoryProvider(room).future,
      );
      return repository.listMessages();
    });

class ChatMessageNotifier
    extends StateNotifier<AsyncValue<List<LocalChatMessage>>> {
  final MessageRepository _repository;
  final int roomId;
  int _currentOffset = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  ChatMessageNotifier(this._repository, this.roomId)
    : super(const AsyncValue.loading()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    try {
      final messages = await _repository.listMessages(
        offset: 0,
        take: _pageSize,
      );
      _currentOffset = messages.length;
      _hasMore = messages.length >= _pageSize;
      state = AsyncValue.data(messages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;

    try {
      final newMessages = await _repository.listMessages(
        offset: _currentOffset,
        take: _pageSize,
      );

      if (newMessages.isEmpty) {
        _hasMore = false;
        return;
      }

      _currentOffset += newMessages.length;
      _hasMore = newMessages.length >= _pageSize;

      state = AsyncValue.data([...state.value ?? [], ...newMessages]);
    } catch (err) {
      showErrorAlert(err);
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      final message = await _repository.sendMessage(roomId, content);

      final currentMessages = state.value ?? [];
      state = AsyncValue.data([message, ...currentMessages]);
    } catch (err) {
      showErrorAlert(err);
    }
  }

  bool get hasMore => _hasMore;
}

final chatMessageNotifierProvider = StateNotifierProvider.family<
  ChatMessageNotifier,
  AsyncValue<List<LocalChatMessage>>,
  MessageRepository
>((ref, repository) => ChatMessageNotifier(repository, repository.room.id));
