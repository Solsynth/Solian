import "dart:async";
import "dart:convert";
import "dart:developer" as developer;
import "dart:io";
import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:flutter/services.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:image_picker/image_picker.dart";
import "package:island/database/drift_db.dart";
import "package:island/database/message.dart";
import "package:island/models/chat.dart";
import "package:island/models/file.dart";
import "package:island/pods/config.dart";
import "package:island/pods/database.dart";
import "package:island/pods/network.dart";
import "package:island/pods/websocket.dart";
import "package:island/services/file.dart";
import "package:island/services/responsive.dart";
import "package:island/widgets/alert.dart";
import "package:island/widgets/app_scaffold.dart";
import "package:island/widgets/chat/call_overlay.dart";
import "package:island/widgets/chat/message_item.dart";
import "package:island/widgets/content/attachment_preview.dart";
import "package:island/widgets/content/cloud_files.dart";
import "package:island/widgets/response.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:pasteboard/pasteboard.dart";
import "package:styled_widget/styled_widget.dart";
import "package:super_sliver_list/super_sliver_list.dart";

import "package:uuid/uuid.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "chat.dart";
import "package:island/widgets/chat/call_button.dart";
import "package:island/widgets/stickers/picker.dart";

part 'room.g.dart';

final isSyncingProvider = StateProvider.autoDispose<bool>((ref) => false);

final appLifecycleStateProvider = StreamProvider<AppLifecycleState>((ref) {
  final controller = StreamController<AppLifecycleState>();

  final observer = _AppLifecycleObserver((state) {
    if (controller.isClosed) return;
    controller.add(state);
  });
  WidgetsBinding.instance.addObserver(observer);

  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
    controller.close();
  });

  return controller.stream;
});

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final ValueChanged<AppLifecycleState> onChange;
  _AppLifecycleObserver(this.onChange);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onChange(state);
  }
}

class _PublicRoomPreview extends HookConsumerWidget {
  final String id;
  final SnChatRoom room;

  const _PublicRoomPreview({required this.id, required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesNotifierProvider(id));
    final messagesNotifier = ref.read(messagesNotifierProvider(id).notifier);
    final scrollController = useScrollController();

    final listController = useMemoized(() => ListController(), []);

    var isLoading = false;

    // Add scroll listener for pagination
    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          if (isLoading) return;
          isLoading = true;
          messagesNotifier.loadMore().then((_) => isLoading = false);
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    Widget chatMessageListWidget(List<LocalChatMessage> messageList) =>
        SuperListView.builder(
          listController: listController,
          padding: EdgeInsets.symmetric(vertical: 16),
          controller: scrollController,
          reverse: true, // Show newest messages at the bottom
          itemCount: messageList.length,
          findChildIndexCallback: (key) {
            final valueKey = key as ValueKey;
            final messageId = valueKey.value as String;
            return messageList.indexWhere((m) => m.id == messageId);
          },
          extentEstimation: (_, _) => 40,
          itemBuilder: (context, index) {
            final message = messageList[index];
            final nextMessage =
                index < messageList.length - 1 ? messageList[index + 1] : null;
            final isLastInGroup =
                nextMessage == null ||
                nextMessage.senderId != message.senderId ||
                nextMessage.createdAt
                        .difference(message.createdAt)
                        .inMinutes
                        .abs() >
                    3;

            return MessageItem(
              message: message,
              isCurrentUser: false, // User is not a member, so not current user
              onAction: null, // No actions allowed in preview mode
              onJump: (_) {}, // No jump functionality in preview
              progress: null,
              showAvatar: isLastInGroup,
            );
          },
        );

    final compactHeader = isWideScreen(context);

    Widget comfortHeaderWidget() => Column(
      spacing: 4,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 26,
          width: 26,
          child:
              (room.type == 1 && room.picture?.id == null)
                  ? SplitAvatarWidget(
                    filesId:
                        room.members!
                            .map((e) => e.account.profile.picture?.id)
                            .toList(),
                  )
                  : room.picture?.id != null
                  ? ProfilePictureWidget(
                    fileId: room.picture?.id,
                    fallbackIcon: Symbols.chat,
                  )
                  : CircleAvatar(
                    child: Text(
                      room.name![0].toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
        ),
        Text(
          (room.type == 1 && room.name == null)
              ? room.members!.map((e) => e.account.nick).join(', ')
              : room.name!,
        ).fontSize(15),
      ],
    );

    Widget compactHeaderWidget() => Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 26,
          width: 26,
          child:
              (room.type == 1 && room.picture?.id == null)
                  ? SplitAvatarWidget(
                    filesId:
                        room.members!
                            .map((e) => e.account.profile.picture?.id)
                            .toList(),
                  )
                  : room.picture?.id != null
                  ? ProfilePictureWidget(
                    fileId: room.picture?.id,
                    fallbackIcon: Symbols.chat,
                  )
                  : CircleAvatar(
                    child: Text(
                      room.name![0].toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
        ),
        Text(
          (room.type == 1 && room.name == null)
              ? room.members!.map((e) => e.account.nick).join(', ')
              : room.name!,
        ).fontSize(19),
      ],
    );

    return AppScaffold(
      appBar: AppBar(
        leading: !compactHeader ? const Center(child: PageBackButton()) : null,
        automaticallyImplyLeading: false,
        toolbarHeight: compactHeader ? null : 64,
        title: compactHeader ? compactHeaderWidget() : comfortHeaderWidget(),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              context.pushNamed('chatDetail', pathParameters: {'id': id});
            },
          ),
          const Gap(8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: messages.when(
              data:
                  (messageList) =>
                      messageList.isEmpty
                          ? Center(child: Text('No messages yet'.tr()))
                          : chatMessageListWidget(messageList),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, _) => ResponseErrorWidget(
                    error: error,
                    onRetry: () => messagesNotifier.loadInitial(),
                  ),
            ),
          ),
          // Join button at the bottom for public rooms
          Container(
            padding: const EdgeInsets.all(16),
            child: FilledButton.tonalIcon(
              onPressed: () async {
                try {
                  showLoadingModal(context);
                  final apiClient = ref.read(apiClientProvider);
                  await apiClient.post('/sphere/chat/${room.id}/members/me');
                  ref.invalidate(chatroomIdentityProvider(id));
                } catch (err) {
                  showErrorAlert(err);
                } finally {
                  if (context.mounted) hideLoadingModal(context);
                }
              },
              label: Text('chatJoin').tr(),
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

@riverpod
class MessagesNotifier extends _$MessagesNotifier {
  late final Dio _apiClient;
  late final AppDatabase _database;
  late final SnChatRoom _room;
  late final SnChatMember _identity;

  final Map<String, LocalChatMessage> _pendingMessages = {};
  final Map<String, Map<int, double>> _fileUploadProgress = {};
  int? _totalCount;
  String? _searchQuery;
  bool? _withLinks;
  bool? _withAttachments;

  late final String _roomId;
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasMore = true;
  bool _isSyncing = false;

  @override
  FutureOr<List<LocalChatMessage>> build(String roomId) async {
    _roomId = roomId;
    _apiClient = ref.watch(apiClientProvider);
    _database = ref.watch(databaseProvider);
    final room = await ref.watch(chatroomProvider(roomId).future);
    final identity = await ref.watch(chatroomIdentityProvider(roomId).future);

    if (room == null) {
      throw Exception('Room not found');
    }
    _room = room;

    // Allow building even if identity is null for public rooms
    if (identity != null) {
      _identity = identity;
    }

    developer.log(
      'MessagesNotifier built for room $roomId',
      name: 'MessagesNotifier',
    );

    // Only setup sync and lifecycle listeners if user is a member
    if (identity != null) {
      ref.listen(appLifecycleStateProvider, (_, next) {
        if (next.hasValue && next.value == AppLifecycleState.resumed) {
          developer.log(
            'App resumed, syncing messages',
            name: 'MessagesNotifier',
          );
          syncMessages();
        }
      });
    }

    loadInitial();
    return [];
  }

  List<LocalChatMessage> _sortMessages(List<LocalChatMessage> messages) {
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return messages;
  }

  Future<List<LocalChatMessage>> _getCachedMessages({
    int offset = 0,
    int take = 20,
  }) async {
    developer.log(
      'Getting cached messages from offset $offset, take $take',
      name: 'MessagesNotifier',
    );
    final List<LocalChatMessage> dbMessages;
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      dbMessages = await _database.searchMessages(_roomId, _searchQuery ?? '');
    } else {
      final chatMessagesFromDb = await _database.getMessagesForRoom(
        _roomId,
        offset: offset,
        limit: take,
      );
      dbMessages = chatMessagesFromDb.map(_database.companionToMessage).toList();
    }

    List<LocalChatMessage> filteredMessages = dbMessages;

    if (_withLinks == true) {
      filteredMessages = filteredMessages.where((msg) => _hasLink(msg)).toList();
    }

    if (_withAttachments == true) {
      filteredMessages = filteredMessages.where((msg) => _hasAttachment(msg)).toList();
    }

    final dbLocalMessages = filteredMessages;

    if (offset == 0) {
      final pendingForRoom =
          _pendingMessages.values
              .where((msg) => msg.roomId == _roomId)
              .toList();

      final allMessages = [...pendingForRoom, ...dbLocalMessages];
      _sortMessages(allMessages); // Use the helper function

      final uniqueMessages = <LocalChatMessage>[];
      final seenIds = <String>{};
      for (final message in allMessages) {
        if (seenIds.add(message.id)) {
          uniqueMessages.add(message);
        }
      }
      return uniqueMessages;
    }

    return dbLocalMessages;
  }

  Future<List<LocalChatMessage>> _fetchAndCacheMessages({
    int offset = 0,
    int take = 20,
  }) async {
    developer.log(
      'Fetching messages from API, offset $offset, take $take',
      name: 'MessagesNotifier',
    );
    if (_totalCount == null) {
      final response = await _apiClient.get(
        '/sphere/chat/$_roomId/messages',
        queryParameters: {'offset': 0, 'take': 1},
      );
      _totalCount = int.parse(response.headers['x-total']?.firstOrNull ?? '0');
    }

    if (offset >= _totalCount!) {
      return [];
    }

    final response = await _apiClient.get(
      '/sphere/chat/$_roomId/messages',
      queryParameters: {'offset': offset, 'take': take},
    );

    final List<dynamic> data = response.data;
    _totalCount = int.parse(response.headers['x-total']?.firstOrNull ?? '0');

    final messages =
        data.map((json) {
          final remoteMessage = SnChatMessage.fromJson(json);
          return LocalChatMessage.fromRemoteMessage(
            remoteMessage,
            MessageStatus.sent,
          );
        }).toList();

    for (final message in messages) {
      await _database.saveMessage(_database.messageToCompanion(message));
      if (message.nonce != null) {
        _pendingMessages.removeWhere(
          (_, pendingMsg) => pendingMsg.nonce == message.nonce,
        );
      }
    }

    return messages;
  }

  Future<void> syncMessages() async {
    if (_isSyncing) {
      developer.log(
        'Sync already in progress, skipping.',
        name: 'MessagesNotifier',
      );
      return;
    }
    _isSyncing = true;

    developer.log('Starting message sync', name: 'MessagesNotifier');
    Future.microtask(() => ref.read(isSyncingProvider.notifier).state = true);
    try {
      final dbMessages = await _database.getMessagesForRoom(
        _room.id,
        offset: 0,
        limit: 1,
      );
      final lastMessage =
          dbMessages.isEmpty
              ? null
              : _database.companionToMessage(dbMessages.first);

      if (lastMessage == null) {
        developer.log(
          'No local messages, fetching from network',
          name: 'MessagesNotifier',
        );
        final newMessages = await _fetchAndCacheMessages(
          offset: 0,
          take: _pageSize,
        );
        state = AsyncValue.data(newMessages);
        return;
      }

      final resp = await _apiClient.post(
        '/sphere/chat/${_room.id}/sync',
        data: {
          'last_sync_timestamp':
              lastMessage.toRemoteMessage().updatedAt.millisecondsSinceEpoch,
        },
      );

      final response = MessageSyncResponse.fromJson(resp.data);
      developer.log(
        'Sync response: ${response.changes.length} changes',
        name: 'MessagesNotifier',
      );
      for (final change in response.changes) {
        switch (change.action) {
          case MessageChangeAction.create:
            await receiveMessage(change.message!);
            break;
          case MessageChangeAction.update:
            await receiveMessageUpdate(change.message!);
            break;
          case MessageChangeAction.delete:
            await receiveMessageDeletion(change.messageId.toString());
            break;
        }
      }
    } catch (err, stackTrace) {
      developer.log(
        'Error syncing messages',
        name: 'MessagesNotifier',
        error: err,
        stackTrace: stackTrace,
      );
      showErrorAlert(err);
    } finally {
      developer.log('Finished message sync', name: 'MessagesNotifier');
      Future.microtask(() => ref.read(isSyncingProvider.notifier).state = false);
      _isSyncing = false;
    }
  }

  Future<List<LocalChatMessage>> listMessages({
    int offset = 0,
    int take = 20,
    bool synced = false,
  }) async {
    try {
      if (offset == 0 && !synced && (_searchQuery == null || _searchQuery!.isEmpty)) {
        _fetchAndCacheMessages(offset: 0, take: take).catchError((_) {
          return <LocalChatMessage>[];
        });
      }

      final localMessages = await _getCachedMessages(
        offset: offset,
        take: take,
      );

      if (localMessages.isNotEmpty) {
        return localMessages;
      }

      if (_searchQuery == null || _searchQuery!.isEmpty) {
        return await _fetchAndCacheMessages(offset: offset, take: take);
      } else {
        return []; // If searching, and no local messages, don't fetch from network
      }
    } catch (e) {
      final localMessages = await _getCachedMessages(
        offset: offset,
        take: take,
      );

      if (localMessages.isNotEmpty) {
        return localMessages;
      }
      rethrow;
    }
  }

  Future<void> loadInitial() async {
    developer.log('Loading initial messages', name: 'MessagesNotifier');
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      syncMessages();
    }
    final messages = await _getCachedMessages(offset: 0, take: 100);
    _currentPage = 0;
    _hasMore = messages.length == _pageSize;
    state = AsyncValue.data(messages);
  }

  Future<void> loadMore() async {
    if (!_hasMore || state is AsyncLoading) return;
    developer.log('Loading more messages', name: 'MessagesNotifier');

    try {
      final currentMessages = state.value ?? [];
      _currentPage++;
      final newMessages = await listMessages(
        offset: _currentPage * _pageSize,
        take: _pageSize,
      );

      if (newMessages.isEmpty || newMessages.length < _pageSize) {
        _hasMore = false;
      }

      state = AsyncValue.data(_sortMessages([...currentMessages, ...newMessages]));
    } catch (err, stackTrace) {
      developer.log(
        'Error loading more messages',
        name: 'MessagesNotifier',
        error: err,
        stackTrace: stackTrace,
      );
      showErrorAlert(err);
      _currentPage--;
    }
  }

  Future<void> sendMessage(
    String content,
    List<UniversalFile> attachments, {
    SnChatMessage? editingTo,
    SnChatMessage? forwardingTo,
    SnChatMessage? replyingTo,
    Function(String, Map<int, double>)? onProgress,
  }) async {
    final nonce = const Uuid().v4();
    developer.log(
      'Sending message with nonce $nonce',
      name: 'MessagesNotifier',
    );
    final baseUrl = ref.read(serverUrlProvider);
    final token = await getToken(ref.watch(tokenProvider));
    if (token == null) throw ArgumentError('Access token is null');

    final mockMessage = SnChatMessage(
      id: 'pending_$nonce',
      chatRoomId: _roomId,
      senderId: _identity.id,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nonce: nonce,
      sender: _identity,
    );

    final localMessage = LocalChatMessage.fromRemoteMessage(
      mockMessage,
      MessageStatus.pending,
    );

    _pendingMessages[localMessage.id] = localMessage;
    _fileUploadProgress[localMessage.id] = {};
    await _database.saveMessage(_database.messageToCompanion(localMessage));

    final currentMessages = state.value ?? [];
    state = AsyncValue.data([localMessage, ...currentMessages]);

    try {
      var cloudAttachments = List.empty(growable: true);
      for (var idx = 0; idx < attachments.length; idx++) {
        final cloudFile =
            await putMediaToCloud(
              fileData: attachments[idx],
              atk: token,
              baseUrl: baseUrl,
              filename: attachments[idx].data.name ?? 'Post media',
              mimetype:
                  attachments[idx].data.mimeType ??
                  switch (attachments[idx].type) {
                    UniversalFileType.image => 'image/unknown',
                    UniversalFileType.video => 'video/unknown',
                    UniversalFileType.audio => 'audio/unknown',
                    UniversalFileType.file => 'application/octet-stream',
                  },
              onProgress: (progress, _) {
                _fileUploadProgress[localMessage.id]?[idx] = progress;
                onProgress?.call(
                  localMessage.id,
                  _fileUploadProgress[localMessage.id] ?? {},
                );
              },
            ).future;
        if (cloudFile == null) {
          throw ArgumentError('Failed to upload the file...');
        }
        cloudAttachments.add(cloudFile);
      }

      final response = await _apiClient.request(
        editingTo == null
            ? '/sphere/chat/$_roomId/messages'
            : '/sphere/chat/$_roomId/messages/${editingTo.id}',
        data: {
          'content': content,
          'attachments_id': cloudAttachments.map((e) => e.id).toList(),
          'replied_message_id': replyingTo?.id,
          'forwarded_message_id': forwardingTo?.id,
          'meta': {},
          'nonce': nonce,
        },
        options: Options(method: editingTo == null ? 'POST' : 'PATCH'),
      );

      final remoteMessage = SnChatMessage.fromJson(response.data);
      final updatedMessage = LocalChatMessage.fromRemoteMessage(
        remoteMessage,
        MessageStatus.sent,
      );

      _pendingMessages.remove(localMessage.id);
      await _database.deleteMessage(localMessage.id);
      await _database.saveMessage(_database.messageToCompanion(updatedMessage));

      final currentMessages = state.value ?? [];
      if (editingTo != null) {
        final newMessages =
            currentMessages
                .where((m) => m.id != localMessage.id) // remove pending message
                .map(
                  (m) => m.id == editingTo.id ? updatedMessage : m,
                ) // update original message
                .toList();
        state = AsyncValue.data(newMessages);
      } else {
        final newMessages =
            currentMessages.map((m) {
              if (m.id == localMessage.id) {
                return updatedMessage;
              }
              return m;
            }).toList();
        state = AsyncValue.data(newMessages);
      }
      developer.log(
        'Message with nonce $nonce sent successfully',
        name: 'MessagesNotifier',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to send message with nonce $nonce',
        name: 'MessagesNotifier',
        error: e,
        stackTrace: stackTrace,
      );
      localMessage.status = MessageStatus.failed;
      _pendingMessages[localMessage.id] = localMessage;
      await _database.updateMessageStatus(
        localMessage.id,
        MessageStatus.failed,
      );
      final newMessages =
          (state.value ?? []).map((m) {
            if (m.id == localMessage.id) {
              return m..status = MessageStatus.failed;
            }
            return m;
          }).toList();
      state = AsyncValue.data(newMessages);
      showErrorAlert(e);
    }
  }

  Future<void> retryMessage(String pendingMessageId) async {
    developer.log(
      'Retrying message $pendingMessageId',
      name: 'MessagesNotifier',
    );
    final message = await fetchMessageById(pendingMessageId);
    if (message == null) {
      throw Exception('Message not found');
    }

    message.status = MessageStatus.pending;
    _pendingMessages[pendingMessageId] = message;
    await _database.updateMessageStatus(
      pendingMessageId,
      MessageStatus.pending,
    );

    try {
      var remoteMessage = message.toRemoteMessage();
      final response = await _apiClient.post(
        '/sphere/chat/${message.roomId}/messages',
        data: {
          'content': remoteMessage.content,
          'attachments_id': remoteMessage.attachments,
          'meta': remoteMessage.meta,
          'nonce': message.nonce,
        },
      );

      remoteMessage = SnChatMessage.fromJson(response.data);
      final updatedMessage = LocalChatMessage.fromRemoteMessage(
        remoteMessage,
        MessageStatus.sent,
      );

      _pendingMessages.remove(pendingMessageId);
      await _database.deleteMessage(pendingMessageId);
      await _database.saveMessage(_database.messageToCompanion(updatedMessage));

      final newMessages =
          (state.value ?? []).map((m) {
            if (m.id == pendingMessageId) {
              return updatedMessage;
            }
            return m;
          }).toList();
      state = AsyncValue.data(newMessages);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to retry message $pendingMessageId',
        name: 'MessagesNotifier',
        error: e,
        stackTrace: stackTrace,
      );
      message.status = MessageStatus.failed;
      _pendingMessages[pendingMessageId] = message;
      await _database.updateMessageStatus(
        pendingMessageId,
        MessageStatus.failed,
      );
      final newMessages =
          (state.value ?? []).map((m) {
            if (m.id == pendingMessageId) {
              return m..status = MessageStatus.failed;
            }
            return m;
          }).toList();
      state = AsyncValue.data(_sortMessages(newMessages));
      showErrorAlert(e);
    }
  }

  Future<void> receiveMessage(SnChatMessage remoteMessage) async {
    if (remoteMessage.chatRoomId != _roomId) return;
    developer.log(
      'Received new message ${remoteMessage.id}',
      name: 'MessagesNotifier',
    );

    final localMessage = LocalChatMessage.fromRemoteMessage(
      remoteMessage,
      MessageStatus.sent,
    );

    if (remoteMessage.nonce != null) {
      _pendingMessages.removeWhere(
        (_, pendingMsg) => pendingMsg.nonce == remoteMessage.nonce,
      );
    }

    await _database.saveMessage(_database.messageToCompanion(localMessage));

    final currentMessages = state.value ?? [];
    final existingIndex = currentMessages.indexWhere(
      (m) =>
          m.id == localMessage.id ||
          (localMessage.nonce != null && m.nonce == localMessage.nonce),
    );

    if (existingIndex >= 0) {
      final newList = [...currentMessages];
      newList[existingIndex] = localMessage;
      state = AsyncValue.data(newList);
    } else {
      state = AsyncValue.data([localMessage, ...currentMessages]);
    }
  }

  Future<void> receiveMessageUpdate(SnChatMessage remoteMessage) async {
    if (remoteMessage.chatRoomId != _roomId) return;
    developer.log(
      'Received message update ${remoteMessage.id}',
      name: 'MessagesNotifier',
    );

    final updatedMessage = LocalChatMessage.fromRemoteMessage(
      remoteMessage,
      MessageStatus.sent,
    );
    await _database.updateMessage(_database.messageToCompanion(updatedMessage));

    final currentMessages = state.value ?? [];
    final index = currentMessages.indexWhere((m) => m.id == updatedMessage.id);

    if (index >= 0) {
      final newList = [...currentMessages];
      newList[index] = updatedMessage;
      state = AsyncValue.data(_sortMessages(newList));
    }
  }

  Future<void> receiveMessageDeletion(String messageId) async {
    developer.log(
      'Received message deletion $messageId',
      name: 'MessagesNotifier',
    );
    _pendingMessages.remove(messageId);

    final currentMessages = state.value ?? [];
    final messageIndex = currentMessages.indexWhere((m) => m.id == messageId);

    LocalChatMessage? messageToUpdate;
    if (messageIndex != -1) {
      messageToUpdate = currentMessages[messageIndex];
    } else {
      messageToUpdate = await fetchMessageById(messageId);
    }

    if (messageToUpdate == null) return;

    final remote = messageToUpdate.toRemoteMessage();
    final updatedRemote = remote.copyWith(
      content: 'This message was deleted',
      type: 'deleted',
      attachments: [],
    );

    final deletedMessage = LocalChatMessage.fromRemoteMessage(
      updatedRemote,
      messageToUpdate.status,
    );

    await _database.saveMessage(_database.messageToCompanion(deletedMessage));

    if (messageIndex != -1) {
      final newList = [...currentMessages];
      newList[messageIndex] = deletedMessage;
      state = AsyncValue.data(newList);
    }
  }

  Future<void> deleteMessage(String messageId) async {
    developer.log('Deleting message $messageId', name: 'MessagesNotifier');
    try {
      await _apiClient.delete('/sphere/chat/$_roomId/messages/$messageId');
      await receiveMessageDeletion(messageId);
    } catch (err, stackTrace) {
      developer.log(
        'Error deleting message $messageId',
        name: 'MessagesNotifier',
        error: err,
        stackTrace: stackTrace,
      );
      showErrorAlert(err);
    }
  }

  void searchMessages(String query, {bool? withLinks, bool? withAttachments}) {
    _searchQuery = query.trim();
    _withLinks = withLinks;
    _withAttachments = withAttachments;
    loadInitial();
  }

  void clearSearch() {
    _searchQuery = null;
    _withLinks = null;
    _withAttachments = null;
    loadInitial();
  }

  Future<LocalChatMessage?> fetchMessageById(String messageId) async {
    developer.log(
      'Fetching message by id $messageId',
      name: 'MessagesNotifier',
    );
    try {
      final localMessage =
          await (_database.select(_database.chatMessages)
            ..where((tbl) => tbl.id.equals(messageId))).getSingleOrNull();
      if (localMessage != null) {
        return _database.companionToMessage(localMessage);
      }

      final response = await _apiClient.get(
        '/sphere/chat/$_roomId/messages/$messageId',
      );
      final remoteMessage = SnChatMessage.fromJson(response.data);
      final message = LocalChatMessage.fromRemoteMessage(
        remoteMessage,
        MessageStatus.sent,
      );

      await _database.saveMessage(_database.messageToCompanion(message));
      return message;
    } catch (e) {
      if (e is DioException) return null;
      rethrow;
    }
  }

  bool _hasLink(LocalChatMessage message) {
    final content = message.toRemoteMessage().content;
    if (content == null) return false;
    final urlRegex = RegExp(r'https?://[^\s/$.?#].[^\s]*');
    return urlRegex.hasMatch(content);
  }

  bool _hasAttachment(LocalChatMessage message) {
    final remoteMessage = message.toRemoteMessage();
    return remoteMessage.attachments.isNotEmpty;
  }
}

class ChatRoomScreen extends HookConsumerWidget {
  final String id;
  const ChatRoomScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoom = ref.watch(chatroomProvider(id));
    final chatIdentity = ref.watch(chatroomIdentityProvider(id));
    final isSyncing = ref.watch(isSyncingProvider);

    if (chatIdentity.isLoading || chatRoom.isLoading) {
      return AppScaffold(
        appBar: AppBar(leading: const PageBackButton()),
        body: CircularProgressIndicator().center(),
      );
    } else if (chatIdentity.value == null) {
      // Identity was not found, user was not joined
      return chatRoom.when(
        data: (room) {
          if (room!.isPublic) {
            // Show public room preview with messages but no input
            return _PublicRoomPreview(id: id, room: room);
          } else {
            // Show regular "not joined" screen for private rooms
            return AppScaffold(
              appBar: AppBar(leading: const PageBackButton()),
              body: Center(
                child:
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            room.isCommunity == true
                                ? Symbols.person_add
                                : Symbols.person_remove,
                            size: 36,
                            fill: 1,
                          ).padding(bottom: 4),
                          Text('chatNotJoined').tr(),
                          if (room.isCommunity != true)
                            Text(
                              'chatUnableJoin',
                              textAlign: TextAlign.center,
                            ).tr().bold()
                          else
                            FilledButton.tonalIcon(
                              onPressed: () async {
                                try {
                                  showLoadingModal(context);
                                  final apiClient = ref.read(apiClientProvider);
                                  await apiClient.post(
                                    '/sphere/chat/${room.id}/members/me',
                                  );
                                  ref.invalidate(chatroomIdentityProvider(id));
                                } catch (err) {
                                  showErrorAlert(err);
                                } finally {
                                  if (context.mounted) {
                                    hideLoadingModal(context);
                                  }
                                }
                              },
                              label: Text('chatJoin').tr(),
                              icon: const Icon(Icons.add),
                            ).padding(top: 8),
                        ],
                      ),
                    ).center(),
              ),
            );
          }
        },
        loading:
            () => AppScaffold(
              appBar: AppBar(leading: const PageBackButton()),
              body: CircularProgressIndicator().center(),
            ),
        error:
            (error, _) => AppScaffold(
              appBar: AppBar(leading: const PageBackButton()),
              body: ResponseErrorWidget(
                error: error,
                onRetry: () => ref.refresh(chatroomProvider(id)),
              ),
            ),
      );
    }

    final messages = ref.watch(messagesNotifierProvider(id));
    final messagesNotifier = ref.read(messagesNotifierProvider(id).notifier);
    final ws = ref.watch(websocketProvider);

    final messageController = useTextEditingController();
    final scrollController = useScrollController();

    final messageReplyingTo = useState<SnChatMessage?>(null);
    final messageForwardingTo = useState<SnChatMessage?>(null);
    final messageEditingTo = useState<SnChatMessage?>(null);
    final attachments = useState<List<UniversalFile>>([]);
    final attachmentProgress = useState<Map<String, Map<int, double>>>({});

    // Function to send read receipt
    void sendReadReceipt() async {
      // Send websocket packet
      final wsState = ref.read(websocketStateProvider.notifier);
      wsState.sendMessage(
        jsonEncode(
          WebSocketPacket(
            type: 'messages.read',
            data: {'chat_room_id': id},
            endpoint: 'DysonNetwork.Sphere',
          ),
        ),
      );
    }

    // Members who are typing
    final typingStatuses = useState<List<SnChatMember>>([]);
    final typingDebouncer = useState<Timer?>(null);

    void sendTypingStatus() {
      // Don't send if we're already in a cooldown period
      if (typingDebouncer.value != null) return;

      // Send typing status immediately
      final wsState = ref.read(websocketStateProvider.notifier);
      wsState.sendMessage(
        jsonEncode(
          WebSocketPacket(
            type: 'messages.typing',
            data: {'chat_room_id': id},
            endpoint: 'DysonNetwork.Sphere',
          ),
        ),
      );

      typingDebouncer.value = Timer(const Duration(milliseconds: 850), () {
        typingDebouncer.value = null;
      });
    }

    // Add timer to remove typing status after inactivity
    useEffect(() {
      final removeTypingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (typingStatuses.value.isNotEmpty) {
          // Remove typing statuses older than 5 seconds
          final now = DateTime.now();
          typingStatuses.value =
              typingStatuses.value.where((member) {
                final lastTyped =
                    member.lastTyped ??
                    DateTime.now().subtract(const Duration(milliseconds: 1350));
                return now.difference(lastTyped).inSeconds < 5;
              }).toList();
        }
      });

      return () => removeTypingTimer.cancel();
    }, []);

    var isLoading = false;

    // Add scroll listener for pagination
    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          if (isLoading) return;
          isLoading = true;
          messagesNotifier.loadMore().then((_) => isLoading = false);
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    // Add websocket listener for new messages
    useEffect(() {
      void onMessage(WebSocketPacket pkt) {
        if (!pkt.type.startsWith('messages')) return;
        if (['messages.read'].contains(pkt.type)) return;

        if (pkt.type == 'messages.typing' && pkt.data?['sender'] != null) {
          if (pkt.data?['room_id'] != chatRoom.value?.id) return;
          if (pkt.data?['sender_id'] == chatIdentity.value?.id) return;

          final sender = SnChatMember.fromJson(
            pkt.data?['sender'],
          ).copyWith(lastTyped: DateTime.now());

          // Check if the sender is already in the typing list
          final existingIndex = typingStatuses.value.indexWhere(
            (member) => member.id == sender.id,
          );
          if (existingIndex >= 0) {
            // Update the existing entry with new timestamp
            final updatedList = [...typingStatuses.value];
            updatedList[existingIndex] = sender;
            typingStatuses.value = updatedList;
          } else {
            // Add new typing status
            typingStatuses.value = [...typingStatuses.value, sender];
          }
          return;
        }

        final message = SnChatMessage.fromJson(pkt.data!);
        if (message.chatRoomId != chatRoom.value?.id) return;
        switch (pkt.type) {
          case 'messages.new':
            if (message.type.startsWith('call')) {
              // Handle the ongoing call.
              ref.invalidate(ongoingCallProvider(message.chatRoomId));
            }
            messagesNotifier.receiveMessage(message);
            // Send read receipt for new message
            sendReadReceipt();
          case 'messages.update':
            messagesNotifier.receiveMessageUpdate(message);
          case 'messages.delete':
            messagesNotifier.receiveMessageDeletion(message.id);
        }
      }

      sendReadReceipt();
      final subscription = ws.dataStream.listen(onMessage);
      return () => subscription.cancel();
    }, [ws, chatRoom]);

    useEffect(() {
      final wsState = ref.read(websocketStateProvider.notifier);
      wsState.sendMessage(
        jsonEncode(
          WebSocketPacket(
            type: 'messages.subscribe',
            data: {'chat_room_id': id},
          ),
        ),
      );
      return () {
        wsState.sendMessage(
          jsonEncode(
            WebSocketPacket(
              type: 'messages.unsubscribe',
              data: {'chat_room_id': id},
            ),
          ),
        );
      };
    }, [id]);

    Future<void> pickPhotoMedia() async {
      final result = await ref
          .watch(imagePickerProvider)
          .pickMultiImage(requestFullMetadata: true);
      if (result.isEmpty) return;
      attachments.value = [
        ...attachments.value,
        ...result.map(
          (e) => UniversalFile(data: e, type: UniversalFileType.image),
        ),
      ];
    }

    Future<void> pickVideoMedia() async {
      final result = await ref
          .watch(imagePickerProvider)
          .pickVideo(source: ImageSource.gallery);
      if (result == null) return;
      attachments.value = [
        ...attachments.value,
        UniversalFile(data: result, type: UniversalFileType.video),
      ];
    }

    void sendMessage() {
      if (messageController.text.trim().isNotEmpty ||
          attachments.value.isNotEmpty) {
        messagesNotifier
            .sendMessage(
              messageController.text.trim(),
              attachments.value,
              editingTo: messageEditingTo.value,
              forwardingTo: messageForwardingTo.value,
              replyingTo: messageReplyingTo.value,
              onProgress: (messageId, progress) {
                attachmentProgress.value = {
                  ...attachmentProgress.value,
                  messageId: progress,
                };
              },
            )
            .then((_) => sendReadReceipt());
        messageController.clear();
        messageEditingTo.value = null;
        messageReplyingTo.value = null;
        messageForwardingTo.value = null;
        attachments.value = [];
      }
    }

    // Add listener to message controller for typing status
    useEffect(() {
      void onTextChange() {
        if (messageController.text.isNotEmpty) {
          sendTypingStatus();
        }
      }

      messageController.addListener(onTextChange);
      return () => messageController.removeListener(onTextChange);
    }, [messageController]);

    final compactHeader = isWideScreen(context);

    final listController = useMemoized(() => ListController(), []);

    Widget comfortHeaderWidget(SnChatRoom? room) => Column(
      spacing: 4,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 26,
          width: 26,
          child:
              (room!.type == 1 && room.picture?.id == null)
                  ? SplitAvatarWidget(
                    filesId:
                        room.members!
                            .map((e) => e.account.profile.picture?.id)
                            .toList(),
                  )
                  : room.picture?.id != null
                  ? ProfilePictureWidget(
                    fileId: room.picture?.id,
                    fallbackIcon: Symbols.chat,
                  )
                  : CircleAvatar(
                    child: Text(
                      room.name![0].toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
        ),
        Text(
          (room.type == 1 && room.name == null)
              ? room.members!.map((e) => e.account.nick).join(', ')
              : room.name!,
        ).fontSize(15),
      ],
    );

    Widget compactHeaderWidget(SnChatRoom? room) => Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 26,
          width: 26,
          child:
              (room!.type == 1 && room.picture?.id == null)
                  ? SplitAvatarWidget(
                    filesId:
                        room.members!
                            .map((e) => e.account.profile.picture?.id)
                            .toList(),
                  )
                  : room.picture?.id != null
                  ? ProfilePictureWidget(
                    fileId: room.picture?.id,
                    fallbackIcon: Symbols.chat,
                  )
                  : CircleAvatar(
                    child: Text(
                      room.name![0].toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
        ),
        Text(
          (room.type == 1 && room.name == null)
              ? room.members!.map((e) => e.account.nick).join(', ')
              : room.name!,
        ).fontSize(19),
      ],
    );

    Widget chatMessageListWidget(List<LocalChatMessage> messageList) =>
        SuperListView.builder(
          listController: listController,
          padding: EdgeInsets.symmetric(vertical: 16),
          controller: scrollController,
          reverse: true, // Show newest messages at the bottom
          itemCount: messageList.length,
          findChildIndexCallback: (key) {
            final valueKey = key as ValueKey;
            final messageId = valueKey.value as String;
            return messageList.indexWhere((m) => m.id == messageId);
          },
          extentEstimation: (_, _) => 40,
          itemBuilder: (context, index) {
            final message = messageList[index];
            final nextMessage =
                index < messageList.length - 1 ? messageList[index + 1] : null;
            final isLastInGroup =
                nextMessage == null ||
                nextMessage.senderId != message.senderId ||
                nextMessage.createdAt
                        .difference(message.createdAt)
                        .inMinutes
                        .abs() >
                    3;

            return chatIdentity.when(
              skipError: true,
              data:
                  (identity) => MessageItem(
                    message: message,
                    isCurrentUser: identity?.id == message.senderId,
                    onAction: (action) {
                      switch (action) {
                        case MessageItemAction.delete:
                          messagesNotifier.deleteMessage(message.id);
                        case MessageItemAction.edit:
                          messageEditingTo.value = message.toRemoteMessage();
                          messageController.text =
                              messageEditingTo.value?.content ?? '';
                          attachments.value =
                              messageEditingTo.value!.attachments
                                  .map((e) => UniversalFile.fromAttachment(e))
                                  .toList();
                        case MessageItemAction.forward:
                          messageForwardingTo.value = message.toRemoteMessage();
                        case MessageItemAction.reply:
                          messageReplyingTo.value = message.toRemoteMessage();
                      }
                    },
                    onJump: (messageId) {
                      final messageIndex = messageList.indexWhere(
                        (m) => m.id == messageId,
                      );
                      if (messageIndex == -1) {
                        showSnackBar('messageJumpNotLoaded'.tr());
                        return;
                      }
                      listController.animateToItem(
                        index: messageIndex,
                        scrollController: scrollController,
                        alignment: 0.5,
                        duration:
                            (estimatedDistance) => Duration(milliseconds: 250),
                        curve: (estimatedDistance) => Curves.easeInOut,
                      );
                    },
                    progress: attachmentProgress.value[message.id],
                    showAvatar: isLastInGroup,
                  ),
              loading:
                  () => MessageItem(
                    message: message,
                    isCurrentUser: false,
                    onAction: null,
                    progress: null,
                    showAvatar: false,
                    onJump: (_) {},
                  ),
              error: (_, _) => const SizedBox.shrink(),
            );
          },
        );

    return AppScaffold(
      appBar: AppBar(
        leading: !compactHeader ? const Center(child: PageBackButton()) : null,
        automaticallyImplyLeading: false,
        toolbarHeight: compactHeader ? null : 64,
        title: chatRoom.when(
          data:
              (room) =>
                  compactHeader
                      ? compactHeaderWidget(room)
                      : comfortHeaderWidget(room),
          loading: () => const Text('Loading...'),
          error:
              (err, _) => ResponseErrorWidget(
                error: err,
                onRetry: () => messagesNotifier.loadInitial(),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.pushNamed('searchMessages', pathParameters: {'id': id});
            },
          ),
          AudioCallButton(roomId: id),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              context.pushNamed('chatDetail', pathParameters: {'id': id});
            },
          ),
          const Gap(8),
        ],
        bottom: isSyncing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.zero,
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: messages.when(
                  data:
                      (messageList) =>
                          messageList.isEmpty
                              ? Center(child: Text('No messages yet'.tr()))
                              : chatMessageListWidget(messageList),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, _) => ResponseErrorWidget(
                        error: error,
                        onRetry: () => messagesNotifier.loadInitial(),
                      ),
                ),
              ),
              chatRoom.when(
                data:
                    (room) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          switchInCurve: Curves.fastEaseInToSlowEaseOut,
                          switchOutCurve: Curves.fastEaseInToSlowEaseOut,
                          transitionBuilder: (
                            Widget child,
                            Animation<double> animation,
                          ) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.3),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                              child: SizeTransition(
                                sizeFactor: animation,
                                axisAlignment: -1.0,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child:
                              typingStatuses.value.isNotEmpty
                                  ? Container(
                                    key: const ValueKey('typing-indicator'),
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Symbols.more_horiz,
                                          size: 16,
                                        ).padding(horizontal: 8),
                                        const Gap(8),
                                        Expanded(
                                          child: Text(
                                            'typingHint'.plural(
                                              typingStatuses.value.length,
                                              args: [
                                                typingStatuses.value
                                                    .map(
                                                      (x) =>
                                                          x.nick ??
                                                          x.account.nick,
                                                    )
                                                    .join(', '),
                                              ],
                                            ),
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : const SizedBox.shrink(
                                    key: ValueKey('typing-indicator-none'),
                                  ),
                        ),
                        _ChatInput(
                          messageController: messageController,
                          chatRoom: room!,
                          onSend: sendMessage,
                          onClear: () {
                            if (messageEditingTo.value != null) {
                              attachments.value.clear();
                              messageController.clear();
                            }
                            messageEditingTo.value = null;
                            messageReplyingTo.value = null;
                            messageForwardingTo.value = null;
                          },
                          messageEditingTo: messageEditingTo.value,
                          messageReplyingTo: messageReplyingTo.value,
                          messageForwardingTo: messageForwardingTo.value,
                          onPickFile: (bool isPhoto) {
                            if (isPhoto) {
                              pickPhotoMedia();
                            } else {
                              pickVideoMedia();
                            }
                          },
                          attachments: attachments.value,
                          onUploadAttachment: (_) {
                            // not going to do anything, only upload when send the message
                          },
                          onDeleteAttachment: (index) async {
                            final attachment = attachments.value[index];
                            if (attachment.isOnCloud) {
                              final client = ref.watch(apiClientProvider);
                              await client.delete(
                                '/drive/files/${attachment.data.id}',
                              );
                            }
                            final clone = List.of(attachments.value);
                            clone.removeAt(index);
                            attachments.value = clone;
                          },
                          onMoveAttachment: (idx, delta) {
                            if (idx + delta < 0 ||
                                idx + delta >= attachments.value.length) {
                              return;
                            }
                            final clone = List.of(attachments.value);
                            clone.insert(idx + delta, clone.removeAt(idx));
                            attachments.value = clone;
                          },
                          onAttachmentsChanged: (newAttachments) {
                            attachments.value = newAttachments;
                          },
                        ),
                      ],
                    ),
                error: (_, _) => const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: CallOverlayBar().padding(horizontal: 8, top: 12),
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends HookConsumerWidget {
  final TextEditingController messageController;
  final SnChatRoom chatRoom;
  final VoidCallback onSend;
  final VoidCallback onClear;
  final Function(bool isPhoto) onPickFile;
  final SnChatMessage? messageReplyingTo;
  final SnChatMessage? messageForwardingTo;
  final SnChatMessage? messageEditingTo;
  final List<UniversalFile> attachments;
  final Function(int) onUploadAttachment;
  final Function(int) onDeleteAttachment;
  final Function(int, int) onMoveAttachment;
  final Function(List<UniversalFile>) onAttachmentsChanged;

  const _ChatInput({
    required this.messageController,
    required this.chatRoom,
    required this.onSend,
    required this.onClear,
    required this.onPickFile,
    required this.messageReplyingTo,
    required this.messageForwardingTo,
    required this.messageEditingTo,
    required this.attachments,
    required this.onUploadAttachment,
    required this.onDeleteAttachment,
    required this.onMoveAttachment,
    required this.onAttachmentsChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputFocusNode = useFocusNode();

    final enterToSend = ref.watch(appSettingsNotifierProvider).enterToSend;

    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    void send() {
      onSend.call();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        inputFocusNode.requestFocus();
      });
    }

    Future<void> handlePaste() async {
      final clipboard = await Pasteboard.image;
      if (clipboard == null) return;

      onAttachmentsChanged([
        ...attachments,
        UniversalFile(
          data: XFile.fromData(clipboard, mimeType: "image/jpeg"),
          type: UniversalFileType.image,
        ),
      ]);
    }

    void handleKeyPress(
      BuildContext context,
      WidgetRef ref,
      RawKeyEvent event,
    ) {
      if (event is! RawKeyDownEvent) return;

      final isPaste = event.logicalKey == LogicalKeyboardKey.keyV;
      final isModifierPressed = event.isMetaPressed || event.isControlPressed;

      if (isPaste && isModifierPressed) {
        handlePaste();
        return;
      }

      final enterToSend = ref.read(appSettingsNotifierProvider).enterToSend;
      final isEnter = event.logicalKey == LogicalKeyboardKey.enter;

      if (isEnter) {
        if (enterToSend && !isModifierPressed) {
          send();
        } else if (!enterToSend && isModifierPressed) {
          send();
        }
      }
    }

    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          if (attachments.isNotEmpty)
            SizedBox(
              height: 280,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: attachments.length,
                itemBuilder: (context, idx) {
                  return SizedBox(
                    height: 280,
                    width: 280,
                    child: AttachmentPreview(
                      item: attachments[idx],
                      onRequestUpload: () => onUploadAttachment(idx),
                      onDelete: () => onDeleteAttachment(idx),
                      onUpdate: (value) {
                        attachments[idx] = value;
                        onAttachmentsChanged(attachments);
                      },
                      onMove: (delta) => onMoveAttachment(idx, delta),
                    ),
                  );
                },
                separatorBuilder: (_, _) => const Gap(8),
              ),
            ).padding(top: 12),
          if (messageReplyingTo != null ||
              messageForwardingTo != null ||
              messageEditingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: Row(
                children: [
                  Icon(
                    messageReplyingTo != null
                        ? Symbols.reply
                        : messageForwardingTo != null
                        ? Symbols.forward
                        : Symbols.edit,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      messageReplyingTo != null
                          ? 'Replying to ${messageReplyingTo?.sender.account.nick}'
                          : messageForwardingTo != null
                          ? 'Forwarding message'
                          : 'Editing message',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onClear,
                    padding: EdgeInsets.zero,
                    style: ButtonStyle(
                      minimumSize: WidgetStatePropertyAll(Size(28, 28)),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'stickers'.tr(),
                      icon: const Icon(Symbols.add_reaction),
                      onPressed: () {
                        final size = MediaQuery.of(context).size;
                        showStickerPickerPopover(
                          context,
                          Offset(
                            20,
                            size.height -
                                480 -
                                MediaQuery.of(context).padding.bottom,
                          ),
                          onPick: (placeholder) {
                            // Insert placeholder at current cursor position
                            final text = messageController.text;
                            final selection = messageController.selection;
                            final start =
                                selection.start >= 0
                                    ? selection.start
                                    : text.length;
                            final end =
                                selection.end >= 0
                                    ? selection.end
                                    : text.length;
                            final newText = text.replaceRange(
                              start,
                              end,
                              placeholder,
                            );
                            messageController.value = TextEditingValue(
                              text: newText,
                              selection: TextSelection.collapsed(
                                offset: start + placeholder.length,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    PopupMenuButton(
                      icon: const Icon(Symbols.photo_library),
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              onTap: () => onPickFile(true),
                              child: Row(
                                spacing: 12,
                                children: [
                                  const Icon(Symbols.photo),
                                  Text('addPhoto').tr(),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () => onPickFile(false),
                              child: Row(
                                spacing: 12,
                                children: [
                                  const Icon(Symbols.video_call),
                                  Text('addVideo').tr(),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
                Expanded(
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (event) => handleKeyPress(context, ref, event),
                    child: TextField(
                      focusNode: inputFocusNode,
                      controller: messageController,
                      onSubmitted:
                          (enterToSend && isMobile)
                              ? (_) {
                                send();
                              }
                              : null,
                      keyboardType:
                          (enterToSend && isMobile)
                              ? TextInputType.text
                              : TextInputType.multiline,
                      textInputAction: TextInputAction.send,
                      inputFormatters: [
                        if (enterToSend && !isMobile)
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            if (newValue.text.endsWith('\n')) {
                              return oldValue;
                            }
                            return newValue;
                          }),
                      ],
                      decoration: InputDecoration(
                        hintText:
                            (chatRoom.type == 1 && chatRoom.name == null)
                                ? 'chatDirectMessageHint'.tr(
                                  args: [
                                    chatRoom.members!
                                        .map((e) => e.account.nick)
                                        .join(', '),
                                  ],
                                )
                                : 'chatMessageHint'.tr(args: [chatRoom.name!]),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        counterText:
                            messageController.text.length > 1024
                                ? '${messageController.text.length}/4096'
                                : null,
                      ),
                      maxLines: 3,
                      minLines: 1,
                      onTapOutside:
                          (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: send,
                ),
              ],
            ).padding(bottom: MediaQuery.of(context).padding.bottom),
          ),
        ],
      ),
    );
  }
}
