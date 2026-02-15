import "dart:async";
import "package:dio/dio.dart";
import "package:drift/drift.dart" show Variable;
import "package:easy_localization/easy_localization.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/chat/pods/chat_room.dart";
import "package:island/data/drift_db.dart";
import "package:island/data/message.dart";
import "package:island/core/database.dart";
import "package:island/core/network.dart";
import "package:island/drive/drive_service.dart";
import "package:island/talker.dart";
import "package:island/shared/widgets/alert.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:uuid/uuid.dart";
import "package:island/accounts/screens/profile.dart";
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'messages_notifier.g.dart';

const Set<String> kSilentMessageTypes = {'messages.update.links'};

@riverpod
class MessagesNotifier extends _$MessagesNotifier {
  late Dio _apiClient;
  late AppDatabase _database;
  late SnChatMember _identity;

  final Map<String, LocalChatMessage> _pendingMessages = {};
  final Map<String, Map<int, double?>> _fileUploadProgress = {};
  int? _totalCount;
  String? _searchQuery;
  bool? _withLinks;
  bool? _withAttachments;

  static const int _pageSize = 20;
  bool _hasMore = true;
  bool _isSyncing = false;
  bool _isJumping = false;
  bool _isUpdatingState = false;
  bool _isLoadingInitial = false;
  bool _allRemoteMessagesFetched = false;

  late Future<SnAccount?> Function(String) _fetchAccount;

  @override
  FutureOr<List<LocalChatMessage>> build(String roomId) async {
    _apiClient = ref.watch(apiClientProvider);
    _database = ref.watch(databaseProvider);
    final room = await ref.watch(chatRoomProvider(roomId).future);
    final identity = await ref.watch(chatRoomIdentityProvider(roomId).future);

    // Initialize fetch account method for corrupted data recovery
    _fetchAccount = (String accountId) async {
      try {
        return await ref.watch(accountProvider(accountId).future);
      } catch (_) {
        return null;
      }
    };

    if (room == null) {
      throw Exception('Room not found');
    }

    // Allow building even if identity is null for public rooms
    if (identity != null) {
      _identity = identity;
    }

    talker.log('MessagesNotifier built for room $roomId');

    return _loadInitialMessages(forceRemoteRefresh: false);
  }

  List<LocalChatMessage> _sortMessages(List<LocalChatMessage> messages) {
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return messages;
  }

  Future<void> _updateStateSafely(List<LocalChatMessage> messages) async {
    if (_isUpdatingState) {
      talker.log('State update already in progress, skipping');
      return;
    }
    _isUpdatingState = true;
    try {
      // Ensure messages are properly sorted and deduplicated
      final sortedMessages = _sortMessages(messages);
      final uniqueMessages = <LocalChatMessage>[];
      final seenIds = <String>{};
      for (final message in sortedMessages) {
        if (seenIds.add(message.id)) {
          uniqueMessages.add(message);
        }
      }
      if (ref.mounted) state = AsyncValue.data(uniqueMessages);
    } finally {
      _isUpdatingState = false;
    }
  }

  Future<List<LocalChatMessage>> _getCachedMessages({
    int offset = 0,
    int take = 20,
    String? searchQuery,
    bool? withLinks,
    bool? withAttachments,
  }) async {
    talker.log('Getting cached messages from offset $offset, take $take');
    final List<LocalChatMessage> dbMessages;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      dbMessages = await _database.searchMessages(
        roomId,
        searchQuery,
        withAttachments: withAttachments,
        fetchAccount: _fetchAccount,
      );
    } else {
      final chatMessagesFromDb = await _database.getMessagesForRoom(
        roomId,
        offset: offset,
        limit: take,
      );
      dbMessages = await Future.wait(
        chatMessagesFromDb
            .map(
              (msg) => _database.companionToMessage(
                msg,
                fetchAccount: _fetchAccount,
              ),
            )
            .toList(),
      );
    }

    List<LocalChatMessage> filteredMessages = dbMessages;

    if (withLinks == true) {
      filteredMessages = filteredMessages
          .where((msg) => _hasLink(msg))
          .toList();
    }

    if (withAttachments == true) {
      filteredMessages = filteredMessages
          .where((msg) => msg.toRemoteMessage().attachments.isNotEmpty)
          .toList();
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
      final pendingForRoom = _pendingMessages.values
          .where((msg) => msg.roomId == roomId)
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

  /// Get all messages without search filters for jump operations
  Future<List<LocalChatMessage>> _getAllMessagesForJump({
    int offset = 0,
    int take = 20,
  }) async {
    talker.log('Getting all messages for jump from offset $offset, take $take');
    final chatMessagesFromDb = await _database.getMessagesForRoom(
      roomId,
      offset: offset,
      limit: take,
    );
    final dbMessages = await Future.wait(
      chatMessagesFromDb
          .map(
            (msg) =>
                _database.companionToMessage(msg, fetchAccount: _fetchAccount),
          )
          .toList(),
    );

    // Always ensure unique messages to prevent duplicate keys
    final uniqueMessages = <LocalChatMessage>[];
    final seenIds = <String>{};
    for (final message in dbMessages) {
      if (seenIds.add(message.id)) {
        uniqueMessages.add(message);
      }
    }

    if (offset == 0) {
      final pendingForRoom = _pendingMessages.values
          .where((msg) => msg.roomId == roomId)
          .toList();

      final allMessages = [...pendingForRoom, ...uniqueMessages];
      _sortMessages(allMessages);

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
    talker.log('Fetching messages from API, offset $offset, take $take');
    if (_totalCount == null) {
      final response = await _apiClient.get(
        '/messager/chat/$roomId/messages',
        queryParameters: {'offset': 0, 'take': 1},
      );
      _totalCount = int.parse(response.headers['x-total']?.firstOrNull ?? '0');
    }

    if (offset >= _totalCount!) {
      _allRemoteMessagesFetched = true;
      return [];
    }

    final response = await _apiClient.get(
      '/messager/chat/$roomId/messages',
      queryParameters: {'offset': offset, 'take': take},
    );

    final List<dynamic> data = response.data;
    _totalCount = int.parse(response.headers['x-total']?.firstOrNull ?? '0');

    final messages = data.map((json) {
      final remoteMessage = SnChatMessage.fromJson(json);
      return LocalChatMessage.fromRemoteMessage(
        remoteMessage,
        MessageStatus.sent,
      );
    }).toList();

    for (final message in messages) {
      await _database.saveMessageWithSender(message);
      if (message.nonce != null) {
        _pendingMessages.removeWhere(
          (_, pendingMsg) => pendingMsg.nonce == message.nonce,
        );
      }
    }

    // Check if we've fetched all remote messages
    if (offset + messages.length >= _totalCount!) {
      _allRemoteMessagesFetched = true;
    }

    return messages;
  }

  Future<void> syncMessages() async {
    if (_isSyncing) {
      talker.log('Sync already in progress, skipping.');
      return;
    }
    _isSyncing = true;
    _allRemoteMessagesFetched = false;

    talker.log('Starting message sync via global sync');

    try {
      // Use the global sync notifier to sync all messages
      await ref.read(chatGlobalSyncProvider.notifier).syncAllMessages();
    } catch (err, stackTrace) {
      talker.log(
        'Error syncing messages',
        exception: err,
        stackTrace: stackTrace,
      );
      showErrorAlert(err);
    } finally {
      talker.log('Finished message sync');
      _isSyncing = false;
    }
  }

  Future<List<LocalChatMessage>> listMessages({
    int offset = 0,
    int take = 20,
    bool synced = false,
  }) async {
    try {
      final localMessages = await _getCachedMessages(
        offset: offset,
        take: take,
        searchQuery: _searchQuery,
        withLinks: _withLinks,
        withAttachments: _withAttachments,
      );

      // If local returned full page, return local - no need to fetch remote
      if (localMessages.length >= take) {
        return localMessages;
      }

      // If local has some messages but less than requested, check if we've
      // already fetched all remote data. If so, return local.
      if (localMessages.isNotEmpty && _allRemoteMessagesFetched) {
        return localMessages;
      }

      // If we haven't fetched all remote messages, check remote even if we have local
      // OR if we have no local messages at all
      if (_searchQuery == null || _searchQuery!.isEmpty) {
        final remoteMessages = await _fetchAndCacheMessages(
          offset: offset,
          take: take,
        );

        // If we got remote messages, re-fetch from cache to get merged result
        if (remoteMessages.isNotEmpty) {
          return await _getCachedMessages(
            offset: offset,
            take: take,
            searchQuery: _searchQuery,
            withLinks: _withLinks,
            withAttachments: _withAttachments,
          );
        }

        // No remote messages, return local (if any)
        return localMessages;
      } else {
        // For search queries, return local only
        return localMessages;
      }
    } catch (e) {
      final localMessages = await _getCachedMessages(
        offset: offset,
        take: take,
        searchQuery: _searchQuery,
        withLinks: _withLinks,
        withAttachments: _withAttachments,
      );

      if (localMessages.isNotEmpty) {
        return localMessages;
      }
      rethrow;
    }
  }

  Future<List<LocalChatMessage>> _loadInitialMessages({
    bool forceRemoteRefresh = true,
  }) async {
    _allRemoteMessagesFetched = false;

    final cachedMessages = await _getCachedMessages(
      offset: 0,
      take: _pageSize,
      searchQuery: _searchQuery,
      withLinks: _withLinks,
      withAttachments: _withAttachments,
    );

    final canFetchRemote =
        (_searchQuery == null || _searchQuery!.isEmpty) &&
        _withLinks != true &&
        _withAttachments != true;
    final shouldRefreshRemote =
        canFetchRemote && (forceRemoteRefresh || cachedMessages.isEmpty);

    if (!shouldRefreshRemote) {
      _hasMore = cachedMessages.length == _pageSize;
      return cachedMessages;
    }

    try {
      // Reset total count so resumed sessions and long-lived notifiers do not
      // keep stale pagination metadata.
      _totalCount = null;
      await _fetchAndCacheMessages(offset: 0, take: _pageSize);
      final refreshedMessages = await _getCachedMessages(
        offset: 0,
        take: _pageSize,
        searchQuery: _searchQuery,
        withLinks: _withLinks,
        withAttachments: _withAttachments,
      );
      _hasMore = refreshedMessages.length == _pageSize || !_allRemoteMessagesFetched;
      return refreshedMessages;
    } catch (err, stackTrace) {
      talker.log(
        'Error refreshing initial messages from remote, falling back to cache',
        exception: err,
        stackTrace: stackTrace,
      );
      _hasMore = cachedMessages.length == _pageSize;
      return cachedMessages;
    }
  }

  Future<void> loadInitial({bool forceRemoteRefresh = true}) async {
    if (_isLoadingInitial) {
      talker.log('Initial load already in progress, skipping.');
      return;
    }

    talker.log('Loading initial messages');
    _isLoadingInitial = true;

    try {
      final messages = await _loadInitialMessages(
        forceRemoteRefresh: forceRemoteRefresh,
      );
      if (ref.mounted) state = AsyncValue.data(messages);
    } finally {
      _isLoadingInitial = false;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state is AsyncLoading) {
      talker.log(
        'Skipping loadMore (hasMore=$_hasMore, isAsyncLoading=${state is AsyncLoading})',
      );
      return;
    }
    final currentMessages = (ref.mounted ? state.value : null) ?? [];
    final offset = currentMessages.length;
    talker.log('Loading more messages (offset=$offset, take=$_pageSize)');

    if (ref.mounted) {
      Future.microtask(() => ref.read(chatSyncingProvider.notifier).set(true));
    }

    try {
      final newMessages = await listMessages(offset: offset, take: _pageSize);

      if (newMessages.isEmpty || newMessages.length < _pageSize) {
        _hasMore = false;
      }

      if (ref.mounted) {
        state = AsyncValue.data(
          _sortMessages([...currentMessages, ...newMessages]),
        );
      }
      talker.log(
        'loadMore complete (fetched=${newMessages.length}, hasMore=$_hasMore)',
      );
    } catch (err, stackTrace) {
      talker.log(
        'Error loading more messages',

        exception: err,
        stackTrace: stackTrace,
      );
      showErrorAlert(err);
    } finally {
      // Always reset global syncing state, regardless of disposal
      Future.microtask(() {
        if (ref.mounted) ref.read(chatSyncingProvider.notifier).set(false);
      });
    }
  }

  Future<void> sendMessage(
    WidgetRef outerRef,
    String content,
    List<UniversalFile> attachments, {
    SnPoll? poll,
    SnWalletFund? fund,
    SnChatMessage? editingTo,
    SnChatMessage? forwardingTo,
    SnChatMessage? replyingTo,
    Function(String, Map<int, double?>)? onProgress,
  }) async {
    final nonce = const Uuid().v4();
    talker.log('Sending message with nonce $nonce');

    final mockMessage = SnChatMessage(
      id: 'pending_$nonce',
      chatRoomId: roomId,
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
    await _database.saveMessageWithSender(localMessage);

    final currentMessages = (ref.mounted ? state.value : null) ?? [];
    state = AsyncValue.data([localMessage, ...currentMessages]);

    try {
      var cloudAttachments = List.empty(growable: true);
      for (var idx = 0; idx < attachments.length; idx++) {
        final cloudFile = await ref
            .read(driveFileUploaderProvider)
            .createCloudFile(
              fileData: attachments[idx],
              onProgress: (progress, _) {
                _fileUploadProgress[localMessage.id]?[idx] = progress ?? 0.0;
                onProgress?.call(
                  localMessage.id,
                  _fileUploadProgress[localMessage.id] ?? {},
                );
              },
            )
            .future;
        if (cloudFile == null) {
          throw ArgumentError('Failed to upload the file...');
        }
        cloudAttachments.add(cloudFile);
      }

      final response = await _apiClient.request(
        editingTo == null
            ? '/messager/chat/$roomId/messages'
            : '/messager/chat/$roomId/messages/${editingTo.id}',
        data: {
          'content': content,
          'attachments_id': cloudAttachments.map((e) => e.id).toList(),
          'replied_message_id': replyingTo?.id,
          'forwarded_message_id': forwardingTo?.id,
          'poll_id': poll?.id,
          'fund_id': fund?.id,
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
      await _database.saveMessageWithSender(updatedMessage);

      if (ref.mounted) {
        final currentMessages = state.value ?? [];
        if (editingTo != null) {
          final newMessages = currentMessages
              .where((m) => m.id != localMessage.id) // remove pending message
              .map(
                (m) => m.id == editingTo.id ? updatedMessage : m,
              ) // update original message
              .toList();
          state = AsyncValue.data(newMessages);
        } else {
          final newMessages = currentMessages.map((m) {
            if (m.id == localMessage.id) {
              return updatedMessage;
            }
            return m;
          }).toList();
          state = AsyncValue.data(newMessages);
        }
      }

      talker.log('Message with nonce $nonce sent successfully');
    } catch (e, stackTrace) {
      talker.log(
        'Failed to send message with nonce $nonce',

        exception: e,
        stackTrace: stackTrace,
      );
      localMessage.status = MessageStatus.failed;
      _pendingMessages[localMessage.id] = localMessage;
      await _database.updateMessageStatus(
        localMessage.id,
        MessageStatus.failed,
      );
      if (ref.mounted) {
        final newMessages = (state.value ?? []).map((m) {
          if (m.id == localMessage.id) {
            return m..status = MessageStatus.failed;
          }
          return m;
        }).toList();
        state = AsyncValue.data(newMessages);
      }
      showErrorAlert(e);
    }
  }

  Future<void> retryMessage(String pendingMessageId) async {
    talker.log('Retrying message $pendingMessageId');
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
        '/messager/chat/${message.roomId}/messages',
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
      await _database.saveMessageWithSender(updatedMessage);

      if (ref.mounted) {
        final newMessages = (state.value ?? []).map((m) {
          if (m.id == pendingMessageId) {
            return updatedMessage;
          }
          return m;
        }).toList();
        state = AsyncValue.data(newMessages);
      }
    } catch (e, stackTrace) {
      talker.log(
        'Failed to retry message $pendingMessageId',

        exception: e,
        stackTrace: stackTrace,
      );
      message.status = MessageStatus.failed;
      _pendingMessages[pendingMessageId] = message;
      await _database.updateMessageStatus(
        pendingMessageId,
        MessageStatus.failed,
      );
      if (ref.mounted) {
        final newMessages = (state.value ?? []).map((m) {
          if (m.id == pendingMessageId) {
            return m..status = MessageStatus.failed;
          }
          return m;
        }).toList();
        state = AsyncValue.data(_sortMessages(newMessages));
      }
      showErrorAlert(e);
    }
  }

  Future<void> receiveMessage(SnChatMessage remoteMessage) async {
    if (remoteMessage.chatRoomId != roomId) return;

    // Block message receiving during jumps to prevent list resets
    if (_isJumping) {
      talker.log('Blocking message receive during jump operation');
      return;
    }

    talker.log('Received new message ${remoteMessage.id}');

    final isSilentMessage = kSilentMessageTypes.contains(remoteMessage.type);

    final localMessage = LocalChatMessage.fromRemoteMessage(
      remoteMessage,
      MessageStatus.sent,
    );

    if (remoteMessage.nonce != null) {
      _pendingMessages.removeWhere(
        (_, pendingMsg) => pendingMsg.nonce == remoteMessage.nonce,
      );
    }

    if (!isSilentMessage) {
      await _database.saveMessageWithSender(localMessage);

      final currentMessages = (ref.mounted ? state.value : null) ?? [];
      final existingIndex = currentMessages.indexWhere(
        (m) =>
            m.id == localMessage.id ||
            (localMessage.nonce != null && m.nonce == localMessage.nonce),
      );

      if (ref.mounted) {
        if (existingIndex >= 0) {
          final newList = [...currentMessages];
          newList[existingIndex] = localMessage;
          state = AsyncValue.data(_sortMessages(newList));
        } else {
          state = AsyncValue.data(
            _sortMessages([localMessage, ...currentMessages]),
          );
        }
      }
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
    if (remoteMessage.chatRoomId != roomId) return;

    // Block message updates during jumps to prevent list resets
    if (_isJumping) {
      talker.log('Blocking message update during jump operation');
      return;
    }

    talker.log('Received message update ${remoteMessage.id}');

    final targetId = remoteMessage.meta['message_id'] ?? remoteMessage.id;

    LocalChatMessage updatedMessage;

    if (remoteMessage.type == 'messages.update.links') {
      // For link updates, merge meta with existing message instead of creating new one
      final existingMessage = await fetchMessageById(targetId);
      if (existingMessage == null) {
        talker.log('Cannot update links for non-existent message $targetId');
        return;
      }

      final existingRemote = existingMessage.toRemoteMessage();
      final mergedMeta = Map<String, dynamic>.of(existingRemote.meta);
      mergedMeta.addAll(remoteMessage.meta);
      mergedMeta.remove('message_id'); // Remove the target message ID from meta

      final updatedRemote = existingRemote.copyWith(
        meta: mergedMeta,
        editedAt: remoteMessage.createdAt,
      );

      updatedMessage = LocalChatMessage.fromRemoteMessage(
        updatedRemote,
        existingMessage.status,
      );
    } else {
      // For regular updates, create new message as before
      updatedMessage = LocalChatMessage.fromRemoteMessage(
        remoteMessage.copyWith(
          id: targetId,
          meta: Map.of(remoteMessage.meta)..remove('message_id'),
          type: 'text',
          editedAt: remoteMessage.createdAt,
        ),
        MessageStatus.sent,
      );
    }

    await _database.updateMessage(_database.messageToCompanion(updatedMessage));

    final currentMessages = (ref.mounted ? state.value : null) ?? [];
    final index = currentMessages.indexWhere((m) => m.id == updatedMessage.id);

    if (ref.mounted) {
      if (index >= 0) {
        final newList = [...currentMessages];
        newList[index] = updatedMessage;
        state = AsyncValue.data(_sortMessages(newList));
      }
    }
  }

  Future<void> receiveMessageDeletion(String messageId) async {
    // Block message deletions during jumps to prevent list resets
    if (_isJumping) {
      talker.log('Blocking message deletion during jump operation');
      return;
    }

    talker.log('Received message deletion $messageId');
    _pendingMessages.remove(messageId);

    final currentMessages = (ref.mounted ? state.value : null) ?? [];
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

    await _database.saveMessageWithSender(deletedMessage);

    if (ref.mounted) {
      if (messageIndex != -1) {
        final newList = [...currentMessages];
        newList[messageIndex] = deletedMessage;
        state = AsyncValue.data(newList);
      }
    }
  }

  Future<void> deleteMessage(String messageId) async {
    talker.log('Deleting message $messageId');

    // Fetch message to check its status before attempting server delete
    final message = await fetchMessageById(messageId);
    if (message == null) {
      talker.log('Message $messageId not found for deletion');
      return;
    }

    // Skip server delete for failed messages (never successfully sent)
    if (message.status == MessageStatus.failed) {
      talker.log('Skipping server delete for failed message $messageId');
      // For failed messages, remove them completely from the active list
      _pendingMessages.remove(messageId);
      await _database.deleteMessage(messageId);

      final currentMessages = (ref.mounted ? state.value : null) ?? [];
      final newMessages = currentMessages
          .where((m) => m.id != messageId)
          .toList();
      state = AsyncValue.data(newMessages);
      return;
    }

    try {
      await _apiClient.delete('/messager/chat/$roomId/messages/$messageId');
      await receiveMessageDeletion(messageId);
    } catch (err, stackTrace) {
      talker.log(
        'Error deleting message $messageId',
        exception: err,
        stackTrace: stackTrace,
      );
      showErrorAlert(err);
    }
  }

  /// Get search results without updating shared state
  Future<List<LocalChatMessage>> getSearchResults(
    String query, {
    bool? withLinks,
    bool? withAttachments,
  }) async {
    final trimmedQuery = query.trim();
    final hasFilters = [withLinks, withAttachments].any((e) => e == true);

    if (trimmedQuery.isEmpty && !hasFilters) {
      return [];
    }

    talker.log(
      'Getting search results for query: $trimmedQuery, filters: links=$withLinks, attachments=$withAttachments',
    );

    try {
      // When filtering without query, get more messages to ensure we find all matches
      final take = (trimmedQuery.isEmpty && hasFilters) ? 1000 : 50;
      final messages = await _getCachedMessages(
        offset: 0,
        take: take,
        searchQuery: trimmedQuery.isNotEmpty ? trimmedQuery : null,
        withLinks: withLinks,
        withAttachments: withAttachments,
      ); // Limit initial search results
      return messages;
    } catch (e, stackTrace) {
      talker.log(
        'Error getting search results',
        exception: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> searchMessages(
    String query, {
    bool? withLinks,
    bool? withAttachments,
  }) async {
    _searchQuery = query.trim();
    _withLinks = withLinks;
    _withAttachments = withAttachments;

    if (_searchQuery!.isEmpty) {
      state = AsyncValue.data([]);
      return;
    }

    talker.log('Searching messages with query: $_searchQuery');
    state = const AsyncValue.loading();

    try {
      final messages = await _getCachedMessages(
        offset: 0,
        take: 50,
        searchQuery: _searchQuery,
        withLinks: _withLinks,
        withAttachments: _withAttachments,
      ); // Limit initial search results
      state = AsyncValue.data(messages);
    } catch (e, stackTrace) {
      talker.log(
        'Error searching messages',
        exception: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearSearch() {
    _searchQuery = null;
    _withLinks = null;
    _withAttachments = null;
    _allRemoteMessagesFetched = false;
    loadInitial();
  }

  Future<LocalChatMessage?> fetchMessageById(String messageId) async {
    talker.log('Fetching message by id $messageId');
    try {
      final localMessage = await (_database.select(
        _database.chatMessages,
      )..where((tbl) => tbl.id.equals(messageId))).getSingleOrNull();
      if (localMessage != null) {
        return _database.companionToMessage(
          localMessage,
          fetchAccount: _fetchAccount,
        );
      }

      final response = await _apiClient.get(
        '/messager/chat/$roomId/messages/$messageId',
      );
      final remoteMessage = SnChatMessage.fromJson(response.data);
      final message = LocalChatMessage.fromRemoteMessage(
        remoteMessage,
        MessageStatus.sent,
      );

      await _database.saveMessageWithSender(message);
      return message;
    } catch (e) {
      if (e is DioException) return null;
      rethrow;
    }
  }

  Future<int> jumpToMessage(String messageId) async {
    talker.log('Starting jump to message $messageId');
    if (_isJumping) {
      talker.log('Jump already in progress, skipping');
      return -1;
    }
    _isJumping = true;

    // Clear flashing messages when starting a new jump
    if (!!ref.mounted) {
      ref.read(flashingMessagesProvider.notifier).state = {};
    }

    try {
      talker.log('Fetching message $messageId');
      final message = await fetchMessageById(messageId);
      if (message == null) {
        talker.log('Message $messageId not found');
        showSnackBar('messageNotFound'.tr());
        return -1;
      }

      // Check if message is already in current state to avoid duplicate loading
      final currentMessages = (ref.mounted ? state.value : null) ?? [];
      final existingIndex = currentMessages.indexWhere(
        (m) => m.id == messageId,
      );
      if (existingIndex >= 0) {
        talker.log(
          'Message $messageId already in current state at index $existingIndex, jumping directly',
        );
        return existingIndex;
      }

      talker.log(
        'Message $messageId not in current state, calculating position and loading messages around it',
      );

      // Count messages newer than the target message to calculate optimal offset
      // Use full message list (not filtered by search) for accurate position calculation
      final query = _database.customSelect(
        'SELECT COUNT(*) as count FROM chat_messages WHERE room_id = ? AND created_at > ?',
        variables: [
          Variable.withString(roomId),
          Variable.withDateTime(message.createdAt),
        ],
        readsFrom: {_database.chatMessages},
      );
      final result = await query.getSingle();
      final newerCount = result.read<int>('count');

      // Calculate offset to position target message in the middle of the loaded chunk
      const chunkSize = 100; // Load 100 messages around the target
      final offset = (newerCount - chunkSize ~/ 2)
          .clamp(0, double.infinity)
          .toInt();
      talker.log(
        'Calculated offset $offset for target message (newer: $newerCount, chunk: $chunkSize)',
      );
      // Use full message list (not filtered by search) for jump operations
      final loadedMessages = await _getAllMessagesForJump(
        offset: offset,
        take: chunkSize,
      );

      // Check if loaded messages are already in current state
      final currentIds = currentMessages.map((m) => m.id).toSet();
      final newMessages = loadedMessages
          .where((m) => !currentIds.contains(m.id))
          .toList();
      talker.log(
        'Loaded ${loadedMessages.length} messages, ${newMessages.length} are new',
      );

      if (newMessages.isNotEmpty) {
        // Merge with current messages more safely
        final allMessages = [...currentMessages, ...newMessages];
        final uniqueMessages = <LocalChatMessage>[];
        final seenIds = <String>{};
        for (final message in allMessages) {
          if (seenIds.add(message.id)) {
            uniqueMessages.add(message);
          }
        }
        await _updateStateSafely(uniqueMessages);
        talker.log(
          'Updated state with ${uniqueMessages.length} total messages',
        );
      }

      // Wait a bit for the UI to rebuild with new messages
      await Future.delayed(const Duration(milliseconds: 100));

      final finalIndex = (state.value ?? []).indexWhere(
        (m) => m.id == messageId,
      );
      talker.log('Final index for message $messageId is $finalIndex');

      // Verify the message is actually in the list before returning
      if (finalIndex == -1) {
        talker.log(
          'Message $messageId still not found after loading, trying direct fetch',
        );
        // Try to fetch and add the specific message if it's still not found
        final directMessage = await fetchMessageById(messageId);
        if (directMessage != null) {
          final currentList = state.value ?? [];
          final updatedList = [...currentList, directMessage];
          await _updateStateSafely(updatedList);
          final newIndex = updatedList.indexWhere((m) => m.id == messageId);
          talker.log('Added message directly, new index: $newIndex');
          return newIndex;
        }
      }

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
