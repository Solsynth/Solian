import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/database/message.dart';
import 'package:island/database/message_repository.dart';
import 'package:island/pods/message.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'chat.dart';

final messageRepositoryProvider = FutureProvider.family<MessageRepository, int>(
  (ref, roomId) async {
    final room = ref.watch(chatroomProvider(roomId)).value;
    final apiClient = ref.watch(apiClientProvider);
    final database = ref.watch(databaseProvider);
    return MessageRepository(room!, apiClient, database);
  },
);

// Provider for messages with pagination
final messagesProvider = StateNotifierProvider.family<
  MessagesNotifier,
  AsyncValue<List<LocalChatMessage>>,
  int
>((ref, roomId) => MessagesNotifier(ref, roomId));

class MessagesNotifier
    extends StateNotifier<AsyncValue<List<LocalChatMessage>>> {
  final Ref _ref;
  final int _roomId;
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasMore = true;

  MessagesNotifier(this._ref, this._roomId)
    : super(const AsyncValue.loading()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    try {
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );
      final messages = await repository.listMessages(
        offset: 0,
        take: _pageSize,
      );
      state = AsyncValue.data(messages);
      _currentPage = 0;
      _hasMore = messages.length == _pageSize;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state is AsyncLoading) return;

    try {
      final currentMessages = state.value ?? [];
      _currentPage++;
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );
      final newMessages = await repository.listMessages(
        offset: _currentPage * _pageSize,
        take: _pageSize,
      );

      if (newMessages.isEmpty || newMessages.length < _pageSize) {
        _hasMore = false;
      }

      state = AsyncValue.data([...currentMessages, ...newMessages]);
    } catch (err) {
      showErrorAlert(err);
      _currentPage--;
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );
      final message = await repository.sendMessage(_roomId, content);

      // Add the new message to the list
      final currentMessages = state.value ?? [];
      state = AsyncValue.data([message, ...currentMessages]);
    } catch (err) {
      showErrorAlert(err);
    }
  }

  Future<void> retryMessage(String pendingMessageId) async {
    try {
      final repository = await _ref.read(
        messageRepositoryProvider(_roomId).future,
      );
      final updatedMessage = await repository.retryMessage(pendingMessageId);

      // Update the message in the list
      final currentMessages = state.value ?? [];
      final index = currentMessages.indexWhere((m) => m.id == pendingMessageId);
      if (index >= 0) {
        final newList = [...currentMessages];
        newList[index] = updatedMessage;
        state = AsyncValue.data(newList);
      }
    } catch (err) {
      showErrorAlert(err);
    }
  }
}

@RoutePage()
class ChatRoomScreen extends HookConsumerWidget {
  final int id;
  const ChatRoomScreen({super.key, @PathParam("id") required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoom = ref.watch(chatroomProvider(id));
    final messages = ref.watch(messagesProvider(id));
    final messagesNotifier = ref.read(messagesProvider(id).notifier);

    final messageController = useTextEditingController();
    final scrollController = useScrollController();

    // Add scroll listener for pagination
    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          messagesNotifier.loadMore();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return Scaffold(
      appBar: AppBar(
        title: chatRoom.when(
          data:
              (room) => Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 26,
                    width: 26,
                    child:
                        room?.picture != null
                            ? ProfilePictureWidget(
                              item: room?.picture,
                              fallbackIcon: Symbols.chat,
                            )
                            : CircleAvatar(
                              child: Text(
                                room?.name[0].toUpperCase() ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                  ),
                  Text(room?.name ?? 'unknown').fontSize(19).tr(),
                ],
              ),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          const Gap(8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data:
                  (messageList) =>
                      messageList.isEmpty
                          ? Center(child: Text('No messages yet'.tr()))
                          : ListView.builder(
                            controller: scrollController,
                            reverse: true, // Show newest messages at the bottom
                            itemCount: messageList.length,
                            itemBuilder: (context, index) {
                              final message = messageList[index];
                              return MessageBubble(message: message);
                            },
                          ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Error: $error'),
                        ElevatedButton(
                          onPressed: () => messagesNotifier.loadInitial(),
                          child: Text('Retry'.tr()),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
          Material(
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'chatMessageHint'.tr(
                          args: [chatRoom.value?.name ?? 'unknown'.tr()],
                        ),
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      onTapOutside:
                          (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ),
                  const Gap(8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      if (messageController.text.trim().isNotEmpty) {
                        messagesNotifier.sendMessage(
                          messageController.text.trim(),
                        );
                        messageController.clear();
                      }
                    },
                  ),
                ],
              ).padding(bottom: MediaQuery.of(context).padding.bottom),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final LocalChatMessage message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser =
        message.senderId == 'current_user_id'; // Replace with actual check

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              radius: 16,
              child: Text(message.senderId[0].toUpperCase()),
            ),
          const Gap(8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isCurrentUser
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                        : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.toRemoteMessage().content ?? '',
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black,
                    ),
                  ),
                  const Gap(4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.Hm().format(message.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              isCurrentUser ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const Gap(4),
                      if (isCurrentUser)
                        _buildStatusIcon(context, message.status),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Gap(8),
          if (isCurrentUser)
            const SizedBox(width: 32), // Balance with avatar on the other side
        ],
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, MessageStatus status) {
    switch (status) {
      case MessageStatus.pending:
        return const Icon(Icons.access_time, size: 12, color: Colors.white70);
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 12, color: Colors.white70);
      case MessageStatus.failed:
        return Consumer(
          builder:
              (context, ref, _) => GestureDetector(
                onTap: () {
                  ref
                      .read(messagesProvider(message.roomId).notifier)
                      .retryMessage(message.id);
                },
                child: const Icon(
                  Icons.error_outline,
                  size: 12,
                  color: Colors.red,
                ),
              ),
        );
    }
  }
}
