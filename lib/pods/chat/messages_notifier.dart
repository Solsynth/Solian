import "dart:async";
import "dart:developer" as developer;
import "package:dio/dio.dart";
import "package:drift/drift.dart" show Variable;
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:island/database/drift_db.dart";
import "package:island/database/message.dart";
import "package:island/models/chat.dart";
import "package:island/models/file.dart";
import "package:island/pods/config.dart";
import "package:island/pods/database.dart";
import "package:island/pods/lifecycle.dart";
import "package:island/pods/network.dart";
import "package:island/services/file.dart";
import "package:island/widgets/alert.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:uuid/uuid.dart";
import "package:island/screens/chat/chat.dart";
import "package:island/pods/chat/chat_rooms.dart";

part 'messages_notifier.g.dart';

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
  static const int _pageSize = 20;
  bool _hasMore = true;
  bool _isSyncing = false;
  bool _isJumping = false;
  DateTime? _lastPauseTime;

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
        next.whenData((state) {
          if (state == AppLifecycleState.paused) {
            _lastPauseTime = DateTime.now();
            developer.log(
              'App paused, recording time',
              name: 'MessagesNotifier',
            );
          } else if (state == AppLifecycleState.resumed) {
            if (_lastPauseTime != null) {
              final diff = DateTime.now().difference(_lastPauseTime!);
              if (diff > const Duration(minutes: 1)) {
                developer.log(
                  'App resumed after >1 min, syncing messages',
                  name: 'MessagesNotifier',
                );
                syncMessages();
              } else {
                developer.log(
                  'App resumed within 1 min, skipping sync',
                  name: 'MessagesNotifier',
                );
              }
            }
          }
        });
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
      dbMessages = await _database.searchMessages(
        _roomId,
        _searchQuery ?? '',
        withAttachments: _withAttachments,
      );
    } else {
      final chatMessagesFromDb = await _database.getMessagesForRoom(
        _roomId,
        offset: offset,
        limit: take,
      );
      dbMessages =
          chatMessagesFromDb.map(_database.companionToMessage).toList();
    }

    List<LocalChatMessage> filteredMessages = dbMessages;

    if (_withLinks == true) {
      filteredMessages =
          filteredMessages.where((msg) => _hasLink(msg)).toList();
    }

    final dbLocalMessages = filteredMessages;

    // Always ensure unique messages to prevent duplicate keys
    final uniqueMessages = <LocalChatMessage>[];
    final seenIds = <String>{};
    for (final message in dbLocalMessages) {
      if (seenIds.add(message.id)) {
        uniqueMessages.add(message);
      }
    }

    if (offset == 0) {
      final pendingForRoom =
          _pendingMessages.values
              .where((msg) => msg.roomId == _roomId)
              .toList();

      final allMessages = [...pendingForRoom, ...uniqueMessages];
      _sortMessages(allMessages); // Use the helper function

      final finalUniqueMessages = <LocalChatMessage>[];
      final finalSeenIds = <String>{};
      for (final message in allMessages) {
        if (finalSeenIds.add(message.id)) {
          finalUniqueMessages.add(message);
        }
      }
      return finalUniqueMessages;
    }

    return uniqueMessages;
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
        'Sync response: ${response.messages.length} changes',
        name: 'MessagesNotifier',
      );
      for (final message in response.messages) {
        switch (message.type) {
          case "messages.update":
          case "messages.update.links":
            await receiveMessageUpdate(message);
            break;
          case "messages.delete":
            await receiveMessageDeletion(message.id.toString());
            break;
        }
        // Still need receive the message to show the history actions
        await receiveMessage(message);
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
      Future.microtask(
        () => ref.read(isSyncingProvider.notifier).state = false,
      );
      _isSyncing = false;
    }
  }

  Future<List<LocalChatMessage>> listMessages({
    int offset = 0,
    int take = 20,
    bool synced = false,
  }) async {
    try {
      if (offset == 0 &&
          !synced &&
          (_searchQuery == null || _searchQuery!.isEmpty)) {
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

    final messages = await _getCachedMessages(offset: 0, take: _pageSize);

    _hasMore = messages.length == _pageSize;

    state = AsyncValue.data(messages);
  }

  Future<void> loadMore() async {
    if (!_hasMore || state is AsyncLoading) return;
    developer.log('Loading more messages', name: 'MessagesNotifier');

    try {
      final currentMessages = state.value ?? [];
      final offset = currentMessages.length;

      final newMessages = await listMessages(offset: offset, take: _pageSize);

      if (newMessages.isEmpty || newMessages.length < _pageSize) {
        _hasMore = false;
      }

      state = AsyncValue.data(
        _sortMessages([...currentMessages, ...newMessages]),
      );
    } catch (err, stackTrace) {
      developer.log(
        'Error loading more messages',
        name: 'MessagesNotifier',
        error: err,
        stackTrace: stackTrace,
      );
      showErrorAlert(err);
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
            await putFileToCloud(
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
      state = AsyncValue.data(_sortMessages(newList));
    } else {
      state = AsyncValue.data(
        _sortMessages([localMessage, ...currentMessages]),
      );
    }

    switch (remoteMessage.type) {
      case "messages.delete":
        await receiveMessageDeletion(
          remoteMessage.meta['message_id'] ?? remoteMessage.id,
        );
      case "messages.update":
      case "messages.update.links":
        await receiveMessageUpdate(remoteMessage);
    }
  }

  Future<void> receiveMessageUpdate(SnChatMessage remoteMessage) async {
    if (remoteMessage.chatRoomId != _roomId) return;
    developer.log(
      'Received message update ${remoteMessage.id}',
      name: 'MessagesNotifier',
    );

    final targetId = remoteMessage.meta['message_id'] ?? remoteMessage.id;
    final updatedMessage = LocalChatMessage.fromRemoteMessage(
      remoteMessage.copyWith(
        id: targetId,
        meta: Map.of(remoteMessage.meta)..remove('message_id'),
      ),
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
      deletedAt: DateTime.now(),
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

  Future<int> jumpToMessage(String messageId) async {
    developer.log(
      'Starting jump to message $messageId',
      name: 'MessagesNotifier',
    );
    if (_isJumping) {
      developer.log(
        'Jump already in progress, skipping',
        name: 'MessagesNotifier',
      );
      return -1;
    }
    _isJumping = true;

    try {
      developer.log('Fetching message $messageId', name: 'MessagesNotifier');
      final message = await fetchMessageById(messageId);
      if (message == null) {
        developer.log('Message $messageId not found', name: 'MessagesNotifier');
        showSnackBar('messageNotFound'.tr());
        return -1;
      }

      // Check if message is already in current state to avoid duplicate loading
      final currentMessages = state.value ?? [];
      final existingIndex = currentMessages.indexWhere(
        (m) => m.id == messageId,
      );
      if (existingIndex >= 0) {
        developer.log(
          'Message $messageId already in current state at index $existingIndex, jumping directly',
          name: 'MessagesNotifier',
        );
        return existingIndex;
      }

      developer.log(
        'Message $messageId not in current state, loading messages around it',
        name: 'MessagesNotifier',
      );

      // Count messages newer than this one
      final query = _database.customSelect(
        'SELECT COUNT(*) as count FROM chat_messages WHERE room_id = ? AND created_at > ?',
        variables: [
          Variable.withString(_roomId),
          Variable.withDateTime(message.createdAt),
        ],
        readsFrom: {_database.chatMessages},
      );
      final result = await query.getSingle();
      final newerCount = result.read<int>('count');

      // Load messages around this position
      final offset =
          (newerCount - _pageSize ~/ 2).clamp(0, double.infinity).toInt();
      developer.log(
        'Loading messages with offset $offset, take $_pageSize',
        name: 'MessagesNotifier',
      );
      final loadedMessages = await _getCachedMessages(
        offset: offset,
        take: _pageSize,
      );

      // Check if loaded messages are already in current state
      final currentIds = currentMessages.map((m) => m.id).toSet();
      final newMessages =
          loadedMessages.where((m) => !currentIds.contains(m.id)).toList();
      developer.log(
        'Loaded ${loadedMessages.length} messages, ${newMessages.length} are new',
        name: 'MessagesNotifier',
      );

      if (newMessages.isNotEmpty) {
        // Merge with current messages
        final allMessages = [...currentMessages, ...newMessages];
        final uniqueMessages = <LocalChatMessage>[];
        final seenIds = <String>{};
        for (final message in allMessages) {
          if (seenIds.add(message.id)) {
            uniqueMessages.add(message);
          }
        }
        _sortMessages(uniqueMessages);
        state = AsyncValue.data(uniqueMessages);
        developer.log(
          'Updated state with ${uniqueMessages.length} total messages',
          name: 'MessagesNotifier',
        );
      }

      final finalIndex = (state.value ?? []).indexWhere(
        (m) => m.id == messageId,
      );
      developer.log(
        'Final index for message $messageId is $finalIndex',
        name: 'MessagesNotifier',
      );
      return finalIndex;
    } finally {
      _isJumping = false;
    }
  }

  bool _hasLink(LocalChatMessage message) {
    final content = message.toRemoteMessage().content;
    if (content == null) return false;
    final urlRegex = RegExp(r'https?://[^\s/$.?#].[^\s]*');
    return urlRegex.hasMatch(content);
  }
}
