import "dart:async";
import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter_cache_manager/flutter_cache_manager.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/chat/pods/chat_room.dart";
import "package:island/chat/data/message_cache.dart";
import "package:island/chat/data/message_repository.dart";
import "package:island/chat/models/chat_view_state.dart";
import "package:island/chat/realtime/message_handler.dart";
import "package:island/chat/send/message_sender.dart";
import "package:island/chat/sync/message_sync_service.dart";
import "package:island/data/database.dart";
import "package:island/data/message.dart";
import "package:island/core/config.dart";
import "package:island/core/database.dart";
import "package:island/core/network.dart";
import "package:island/core/services/event_bus.dart";
import "package:island/chat/e2ee_message_service.dart";
import "package:island/e2ee/e2ee.dart";
import "package:logging/logging.dart";
import "package:island/shared/widgets/alert.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:uuid/uuid.dart";
import "package:island/accounts/screens/profile.dart";
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'messages_notifier.g.dart';

enum E2eeRecoveryState { idle, reconnecting, failed }

@riverpod
class MessagesNotifier extends _$MessagesNotifier {
  late Dio _apiClient;
  late AppDatabase _database;
  late SnChatMember _identity;
  int _roomEncryptionMode = 0;
  String? _mlsGroupId;

  final Map<String, LocalChatMessage> _pendingMessages = {};
  String? _searchQuery;
  bool? _withLinks;
  bool? _withAttachments;

  static const int _pageSize = 20;
  bool _hasMore = true;
  bool _isSyncing = false;
  bool _isJumping = false;
  bool _hasPendingRealtimeRefresh = false;
  bool _isUpdatingState = false;
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  bool _allRemoteMessagesFetched = false;

  /// Track the last offset fetched from API to prevent overlapping fetches
  /// This is separate from DB offset since we fetch in larger batches (_fetchBatchSize)
  /// than we display (_pageSize)
  int _lastApiFetchOffset = 0;

  final Set<String> _prefetchedVoiceUrls = <String>{};

  late Future<SnAccount?> Function(String) _fetchAccount;

  E2eeRecoveryState _e2eeRecoveryState = E2eeRecoveryState.idle;

  /// Request deduplication futures
  Future<void>? _syncOperation;
  Future<void>? _loadInitialOperation;
  bool _isInitializing = false;

  Future<void> _runDeduped({
    required Future<void>? operation,
    required void Function(Future<void>?) setOperation,
    required Future<void> Function() task,
    required String logLabel,
  }) async {
    if (operation != null) {
      Logger.root.info('$logLabel already in progress, joining existing task');
      return operation;
    }

    final created = task();
    setOperation(created);
    try {
      await created;
    } finally {
      setOperation(null);
    }
  }

  late final MessageCache _messageCache;
  late final PendingMessageCache _pendingCache;
  late final MessageRepository _repository;
  late final MessageSyncService _syncService;
  late final MessageSender _sender;
  late final RealtimeMessageHandler _realtime;

  MessageFilter get _activeFilter => MessageFilter(
    searchQuery: _searchQuery,
    withLinks: _withLinks,
    withAttachments: _withAttachments,
  );

  E2eeRecoveryState get e2eeRecoveryState => _e2eeRecoveryState;

  bool get isLoadingMore => _isLoadingMore;

  bool get _isE2eeRoom => _roomEncryptionMode == 3;

  String? get _fileEncryptKey =>
      _isE2eeRoom ? deriveE2eeFileEncryptKey(roomId) : null;

  Options? _mlsWriteOptions() {
    if (!_isE2eeRoom) return null;
    return Options(headers: {'X-Client-Ability': 'chat.mls.v2'});
  }

  E2eeMessageService get _e2eeService => E2eeMessageService(
    ref: ref,
    mlsGroupId: _mlsGroupId,
    isE2eeRoom: _isE2eeRoom,
  );

  bool _isSystemEventType(String type) {
    if (type.startsWith('system.')) return true;
    switch (type) {
      case 'messages.update':
      case 'messages.update.links':
      case 'messages.delete':
      case 'messages.reaction.added':
      case 'messages.reaction.removed':
        return true;
      default:
        return false;
    }
  }

  bool _isImportantEventType(String type) {
    if (type == 'call.start' || type == 'call.ended') return true;
    if (type == 'messages.update' ||
        type == 'messages.update.links' ||
        type == 'messages.delete') {
      return true;
    }
    if (type == 'system.e2ee.enabled') {
      return true;
    }
    return type == 'system.call.member.joined' ||
        type == 'system.call.member.left';
  }

  bool _shouldIncludeInActiveList(LocalChatMessage message) {
    final mode = ref.read(appSettingsProvider).chatEventMessageMode;
    if (mode == kChatEventMessageModeVerbose) return true;
    if (mode == kChatEventMessageModeNone) {
      return !_isSystemEventType(message.type);
    }
    if (_isSystemEventType(message.type)) {
      return _isImportantEventType(message.type);
    }
    return true;
  }

  List<LocalChatMessage> _filterActiveMessages(
    List<LocalChatMessage> messages,
  ) {
    final mode = ref.read(appSettingsProvider).chatEventMessageMode;
    if (mode == kChatEventMessageModeVerbose) return messages;
    return messages.where(_shouldIncludeInActiveList).toList();
  }

  String? _resolveVoiceMediaUrlFromMeta(Map<String, dynamic> meta) {
    final rawUrl = meta['voice_url']?.toString();
    if (rawUrl == null || rawUrl.isEmpty) return null;
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }
    final serverUrl = ref.read(serverUrlProvider);
    return '$serverUrl$rawUrl';
  }

  Future<void> _prefetchVoiceUrl(String? mediaUrl) async {
    if (mediaUrl == null || mediaUrl.isEmpty) return;
    if (!_prefetchedVoiceUrls.add(mediaUrl)) return;

    final token = ref.read(tokenProvider);
    final headers = token == null
        ? null
        : <String, String>{'Authorization': 'Bearer ${token.token}'};

    final cache = DefaultCacheManager();
    try {
      final cached = await cache.getFileFromCache(mediaUrl);
      if (cached != null) return;
      unawaited(cache.downloadFile(mediaUrl, authHeaders: headers));
    } catch (err, stackTrace) {
      _prefetchedVoiceUrls.remove(mediaUrl);
      Logger.root.info(
        'Failed to prefetch voice media $mediaUrl',
        err,
        stackTrace,
      );
    }
  }

  Future<void> _prefetchVoiceForRemoteMessage(SnChatMessage message) async {
    if (message.type != 'voice') return;
    await _prefetchVoiceUrl(_resolveVoiceMediaUrlFromMeta(message.meta));
  }

  Map<String, dynamic> _sanitizeChatMessageJson(Map<String, dynamic> input) =>
      E2eeMessageService.sanitizeChatMessageJson(input);

  SnChatMessage? _tryParseChatMessage(dynamic data, {String? context}) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return SnChatMessage.fromJson(_sanitizeChatMessageJson(data));
    } catch (e) {
      Logger.root.info(
        'Skipping invalid chat message${context != null ? ' ($context)' : ''}: $e',
      );
      return null;
    }
  }

  /// Decrypts an E2EE message, applying decrypted content to the message.
  /// Returns null if:
  /// - Decryption is skipped for own message (no plaintext available)
  /// - Decryption fundamentally fails
  /// - E2EE recovery has already failed (no retries within same session)
  /// Skips decryption for messages sent by current device (identified by device ID in header)
  /// since MLS forward secrecy prevents self-decryption - plaintext is preserved from pending.
  @override
  FutureOr<List<LocalChatMessage>> build(String roomId) async {
    _apiClient = ref.read(apiClientProvider);
    _database = ref.read(databaseProvider);
    _messageCache = MessageCache(maxSize: PaginationConfig.maxCacheSize);
    _pendingCache = PendingMessageCache();
    _repository = MessageRepository(ref, roomId, _messageCache);
    _syncService = MessageSyncService(
      ref,
      roomId,
      _repository,
      _messageCache,
      _pendingCache,
      e2eeService: _e2eeService,
    );
    _sender = MessageSender(
      ref,
      roomId,
      _repository,
      _pendingCache,
      e2eeService: _e2eeService,
      fileEncryptKey: _fileEncryptKey,
    );
    _realtime = RealtimeMessageHandler(
      ref,
      roomId,
      _repository,
      _syncService,
      _pendingCache,
      _messageCache,
      e2eeService: _e2eeService,
      onNewMessage: (message) {
        _upsertReceivedMessageInState(message);
      },
      onMessageUpdate: (message) {
        final list = [..._currentMessages];
        final index = list.indexWhere((m) => m.id == message.id);
        if (index >= 0) {
          list[index] = message;
        } else {
          list.add(message);
        }
        _emitMessages(list);
      },
      onMessageDelete: (message) {
        final list = [..._currentMessages];
        final index = list.indexWhere((m) => m.id == message.id);
        if (index >= 0) {
          list[index] = message;
        } else {
          list.add(message);
        }
        _emitMessages(list);
      },
      onReconnectionNeeded: () {
        unawaited(loadInitial(forceRemoteRefresh: false));
      },
    );
    final room = await ref.read(chatRoomProvider(roomId).future);
    final identity = await ref.read(chatRoomIdentityProvider(roomId).future);

    // Initialize fetch account method for corrupted data recovery
    _fetchAccount = (String accountId) async {
      try {
        return await ref.read(accountProvider(accountId).future);
      } catch (_) {
        return null;
      }
    };

    if (room == null) {
      throw Exception('Room not found');
    }
    _roomEncryptionMode = room.encryptionMode;
    _mlsGroupId = room.mlsGroupId;

    var disposed = false;

    // Defer heavy MLS operations to post-frame callback to not block initial build
    Future.microtask(() async {
      if (disposed || !ref.mounted) return;

      // Set account ID for MLS operations
      if (identity != null) {
        final mlsClient = ref.read(mlsClientProvider);
        await mlsClient.setCurrentAccountId(identity.accountId);
        if (disposed || !ref.mounted) return;
        // Fetch pending E2EE envelopes (Welcome, Commit, Proposal)
        await mlsClient.fetchAndProcessPendingEnvelopes();
      }

      if (disposed || !ref.mounted) return;

      // Ensure MLS group is bootstrapped for E2EE rooms
      if (_isE2eeRoom) {
        if (room.mlsGroupId == null) {
          Logger.root.info(
            'Room $roomId has encryption mode 3 but no mlsGroupId - skipping MLS bootstrap',
          );
        } else {
          try {
            if (disposed || !ref.mounted) return;
            final mlsClient = ref.read(mlsClientProvider);

            // Check current epoch for logging purposes
            final currentEpoch = await mlsClient.getCurrentEpoch(
              room.mlsGroupId!,
            );
            if (disposed || !ref.mounted) return;
            Logger.root.fine(
              'Current MLS epoch for room $roomId (group: ${room.mlsGroupId}): $currentEpoch',
            );

            // Note: epoch=0 is NORMAL for newly created MLS groups.
            // Epoch only increases after a commit (adding/removing members).
            // We should NOT force re-bootstrap based on epoch alone.
            // Instead, let bootstrapGroup decide if a group needs to be created.
            await mlsClient.bootstrapGroup(
              room.mlsGroupId!,
              roomId: roomId,
              force: false,
            );
          } catch (e) {
            Logger.root.severe(
              'Failed to bootstrap MLS group for room $roomId: $e',
            );
          }
        }
      }
    });

    // Allow building even if identity is null for public rooms
    if (identity != null) {
      _identity = identity;
    }

    Logger.root.info('MessagesNotifier built for room $roomId');

    _realtime.startListening();

    StreamSubscription<MlsExternalJoinStartedEvent>? e2eeStartSub;
    StreamSubscription<MlsExternalJoinCompletedEvent>? e2eeCompleteSub;
    StreamSubscription<MlsRecoveryFailedEvent>? e2eeFailedSub;

    e2eeStartSub = eventBus.on<MlsExternalJoinStartedEvent>().listen((event) {
      if (event.mlsGroupId != _mlsGroupId) return;
      _e2eeRecoveryState = E2eeRecoveryState.reconnecting;
    });

    e2eeCompleteSub = eventBus.on<MlsExternalJoinCompletedEvent>().listen((
      event,
    ) {
      if (event.mlsGroupId != _mlsGroupId) return;
      if (event.success) {
        _e2eeRecoveryState = E2eeRecoveryState.idle;
      }
    });

    e2eeFailedSub = eventBus.on<MlsRecoveryFailedEvent>().listen((event) async {
      if (event.mlsGroupId != _mlsGroupId) return;
      _e2eeRecoveryState = E2eeRecoveryState.failed;

      final chatRoomId = roomId;
      await _database.deleteMessagesForRoom(chatRoomId);
      Logger.root.info(
        'Cleared message history for room $chatRoomId after failed epoch recovery',
      );

      final now = DateTime.now();
      final systemMessage = LocalChatMessage(
        id: const Uuid().v4(),
        roomId: chatRoomId,
        senderId: 'system',
        sender: null,
        data: {
          'id': const Uuid().v4(),
          'chat_room_id': chatRoomId,
          'sender_id': 'system',
          'type': 'system.e2ee.history_unavailable',
          'content':
              'Message history is no longer available due to an encryption key change',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'deleted_at': null,
          'client_message_id': null,
          'nonce': null,
          'meta': <String, dynamic>{},
          'members_mentioned': <String>[],
          'attachments': <Map<String, dynamic>>[],
          'reactions': <Map<String, dynamic>>[],
          'sender': <String, dynamic>{
            'id': 'system',
            'chat_room_id': chatRoomId,
            'account_id': 'system',
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
            'deleted_at': null,
            'nick': null,
            'notify': 0,
            'joined_at': now.toIso8601String(),
            'break_until': null,
            'timeout_until': null,
            'last_read_at': null,
            'status': null,
            'realm_nick': null,
            'realm_bio': null,
            'realm_experience': null,
            'realm_level': null,
            'realm_leveling_progress': null,
            'realm_label': null,
          },
          'replied_message_id': null,
          'forwarded_message_id': null,
        },
        createdAt: now,
        clientMessageId: null,
        status: MessageStatus.sent,
        type: 'system.e2ee.history_unavailable',
        meta: {},
        membersMentioned: [],
        attachments: [],
        reactions: [],
      );
      await _database.saveMessageWithSender(systemMessage);
      Logger.root.info(
        'Inserted system message for history unavailable in room $chatRoomId',
      );
    });

    ref.listen<String>(
      appSettingsProvider.select((settings) => settings.chatEventMessageMode),
      (previous, next) {
        if (previous == next) return;
        if (_isJumping || _isLoadingInitial || !ref.mounted) return;
        unawaited(loadInitial(forceRemoteRefresh: false));
      },
    );

    ref.onDispose(() {
      disposed = true;
      _realtime.stopListening();
      e2eeStartSub?.cancel();
      e2eeCompleteSub?.cancel();
      e2eeFailedSub?.cancel();
      _messageCache.clear();
      _messageCache.clearPendingFetches();
      _pendingCache.clear();
    });

    return _loadInitialMessages(forceRemoteRefresh: false);
  }

  List<LocalChatMessage> _sortMessages(List<LocalChatMessage> messages) {
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return messages;
  }

  Future<void> _updateStateSafely(List<LocalChatMessage> messages) async {
    if (_isUpdatingState) {
      Logger.root.info('State update already in progress, skipping');
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
      if (ref.mounted) {
        state = AsyncValue.data(_filterActiveMessages(uniqueMessages));
      }
    } finally {
      _isUpdatingState = false;
    }
  }

  List<LocalChatMessage> get _currentMessages =>
      (ref.mounted ? state.value : null) ?? [];

  void _setGlobalSyncing(bool value) {
    if (!ref.mounted) return;
    Future.microtask(() => ref.read(chatSyncingProvider.notifier).set(value));
  }

  void _emitMessages(List<LocalChatMessage> messages) {
    if (!ref.mounted) return;
    state = AsyncValue.data(_filterActiveMessages(_sortMessages(messages)));
  }

  Future<List<LocalChatMessage>> _getCachedMessages({
    int offset = 0,
    int take = 20,
    String? searchQuery,
    bool? withLinks,
    bool? withAttachments,
  }) async {
    Logger.root.info('Getting cached messages from offset $offset, take $take');
    final List<LocalChatMessage> dbMessages;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      dbMessages = await _database.searchMessages(
        roomId,
        searchQuery,
        withAttachments: withAttachments,
        fetchAccount: _fetchAccount,
      );
    } else {
      dbMessages = await _database.getMessagesForRoom(
        roomId,
        offset: offset,
        limit: take,
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

    // Defer voice prefetching - only prefetch for visible messages
    // Voice prefetching is now handled lazily when messages become visible
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
      return _filterActiveMessages(finalUniqueMessages);
    }

    return _filterActiveMessages(uniqueMessages);
  }

  /// Consolidated initialization that handles pagination reset, sync, and initial load
  /// with debouncing to prevent redundant calls
  Future<void> initialize({bool forceRemoteRefresh = false}) async {
    if (_isInitializing) {
      Logger.root.info('Initialization already in progress, skipping.');
      return;
    }
    _isInitializing = true;
    Logger.root.info('Starting consolidated initialization');
    try {
      resetPaginationState();
      await syncMessages();
      await loadInitial(forceRemoteRefresh: forceRemoteRefresh);
    } finally {
      _isInitializing = false;
      Logger.root.info('Consolidated initialization complete');
    }
  }

  Future<void> syncMessages() async {
    if (_isSyncing) {
      Logger.root.info('Sync already in progress, skipping.');
      return;
    }

    await _runDeduped(
      operation: _syncOperation,
      setOperation: (op) => _syncOperation = op,
      task: _syncMessagesImpl,
      logLabel: 'Sync operation',
    );
  }

  Future<void> _syncMessagesImpl() async {
    _isSyncing = true;
    _allRemoteMessagesFetched = false;

    Logger.root.info('Starting message sync via global sync');

    try {
      // Use the global sync notifier to sync all messages
      await ref.read(chatGlobalSyncProvider.notifier).syncAllMessages();
    } catch (err, stackTrace) {
      Logger.root.info('Error syncing messages', err, stackTrace);
      showErrorAlert(err);
    } finally {
      Logger.root.info('Finished message sync');
      _isSyncing = false;
    }
  }

  Future<List<LocalChatMessage>> listMessages({
    int offset = 0,
    int take = 20,
    bool synced = false,
  }) async {
    final currentCount = _currentMessages.length;
    return _syncService.loadMore(
      currentCount: offset > 0 ? offset : currentCount,
      take: take,
      filter: _activeFilter,
    );
  }

  Future<List<LocalChatMessage>> _loadInitialMessages({
    bool forceRemoteRefresh = true,
  }) async {
    _setGlobalSyncing(true);
    try {
      final initial = await _syncService.loadInitial(
        forceRemote: forceRemoteRefresh,
        filter: _activeFilter,
      );
      final prefetched = await _syncService.eagerPrefetchIfNeeded(
        initial,
        filter: _activeFilter,
      );
      _allRemoteMessagesFetched = _syncService.allRemoteFetched;
      _lastApiFetchOffset = _syncService.lastApiOffset;
      _hasMore = !_allRemoteMessagesFetched;
      return prefetched;
    } finally {
      _setGlobalSyncing(false);
    }
  }

  Future<void> loadInitial({bool forceRemoteRefresh = true}) async {
    if (_isLoadingInitial) {
      Logger.root.info('Initial load already in progress, skipping.');
      return;
    }

    await _runDeduped(
      operation: _loadInitialOperation,
      setOperation: (op) => _loadInitialOperation = op,
      task: () => _loadInitialImpl(forceRemoteRefresh: forceRemoteRefresh),
      logLabel: 'LoadInitial operation',
    );
  }

  Future<void> _loadInitialImpl({bool forceRemoteRefresh = true}) async {
    Logger.root.info('Loading initial messages');
    _isLoadingInitial = true;

    try {
      final previous = _currentMessages;
      final messages = await _loadInitialMessages(
        forceRemoteRefresh: forceRemoteRefresh,
      );
      if (ref.mounted) {
        if (messages.isEmpty && previous.isNotEmpty && !forceRemoteRefresh) {
          Logger.root.info(
            'Initial reload returned empty; preserving existing in-memory messages',
          );
          _emitMessages(previous);
          Future.delayed(const Duration(milliseconds: 600), () {
            if (ref.mounted) {
              unawaited(loadInitial(forceRemoteRefresh: true));
            }
          });
        } else {
          _emitMessages(messages);
        }
      }
    } finally {
      _isLoadingInitial = false;
    }
  }

  void resetPaginationState() {
    _hasMore = true;
    _allRemoteMessagesFetched = false;
    _lastApiFetchOffset = 0;
  }

  Future<void> loadMore() async {
    if (!_hasMore || state is AsyncLoading || _isLoadingMore) {
      Logger.root.info(
        'Skipping loadMore (hasMore=$_hasMore, isAsyncLoading=${state is AsyncLoading}, isLoadingMore=$_isLoadingMore)',
      );
      return;
    }
    _isLoadingMore = true;
    // Use the current displayed message count as offset for UI pagination
    // This is different from _lastApiFetchOffset which tracks API fetch progress
    final offset = _currentMessages.length;
    Logger.root.info(
      'Loading more messages (displayOffset=$offset, take=$_pageSize, lastApiOffset=$_lastApiFetchOffset)',
    );

    _setGlobalSyncing(true);

    try {
      final newMessages = await listMessages(offset: offset, take: _pageSize);

      _allRemoteMessagesFetched = _syncService.allRemoteFetched;
      _lastApiFetchOffset = _syncService.lastApiOffset;
      _hasMore = !_allRemoteMessagesFetched;

      if (ref.mounted) {
        _emitMessages([..._currentMessages, ...newMessages]);
      }
      Logger.root.info(
        'loadMore complete (fetched=${newMessages.length}, hasMore=$_hasMore, allRemoteFetched=$_allRemoteMessagesFetched)',
      );
    } catch (err, stackTrace) {
      Logger.root.info('Error loading more messages', err, stackTrace);
      showErrorAlert(err);
    } finally {
      _isLoadingMore = false;
      // Always reset global syncing state, regardless of disposal
      _setGlobalSyncing(false);
    }
  }

  void _upsertReceivedMessageInState(LocalChatMessage localMessage) {
    final isMessageUpdate =
        localMessage.type == 'messages.update' ||
        localMessage.type == 'messages.update.links';
    final chatMode = ref.read(appSettingsProvider).chatEventMessageMode;
    final shouldShowMessage = _shouldIncludeInActiveList(localMessage);
    final shouldShowEditTrail =
        chatMode != kChatEventMessageModeNone && isMessageUpdate;

    final currentMessages = (ref.mounted ? state.value : null) ?? [];
    final existingIndex = currentMessages.indexWhere(
      (m) =>
          m.id == localMessage.id ||
          (localMessage.clientMessageId != null &&
              m.clientMessageId == localMessage.clientMessageId),
    );

    if (!ref.mounted) return;

    // System events (like messages.update) should never replace or remove
    // existing messages in the list. They reference target messages via
    // meta['message_id'], not by sharing the same ID. The actual content
    // update is handled by receiveMessageUpdate(). Here we only add the
    // event to the timeline if it should be shown.
    if (_isSystemEventType(localMessage.type)) {
      if (shouldShowMessage || shouldShowEditTrail) {
        // Only add if not already in the list (avoid duplicates)
        if (existingIndex < 0) {
          _emitMessages([localMessage, ...currentMessages]);
        }
      }
      return;
    }

    if (existingIndex >= 0) {
      final newList = [...currentMessages];
      if (shouldShowMessage || shouldShowEditTrail) {
        newList[existingIndex] = localMessage;
      } else {
        newList.removeAt(existingIndex);
      }
      _emitMessages(newList);
    } else if (shouldShowMessage || shouldShowEditTrail) {
      _emitMessages([localMessage, ...currentMessages]);
    }
  }

  Future<void> _processMessageSideEffects(SnChatMessage remoteMessage) async {
    switch (remoteMessage.type) {
      case "messages.delete":
        await receiveMessageDeletion(
          remoteMessage.meta['message_id'] ?? remoteMessage.id,
        );
      case "messages.update":
      case "messages.update.links":
        await receiveMessageUpdate(remoteMessage);
      case "messages.reaction.added":
        await receiveReactionAdded(remoteMessage);
      case "messages.reaction.removed":
        await receiveReactionRemoved(remoteMessage);
    }
  }

  // ── Public send methods ────────────────────────────────────────────

  Future<void> sendMessage(
    String content,
    List<UniversalFile> attachments, {
    SnPoll? poll,
    SnWalletFund? fund,
    SnChatMessage? editingTo,
    SnChatMessage? forwardingTo,
    SnChatMessage? replyingTo,
    Function(String, Map<int, double?>)? onProgress,
  }) async {
    if (content.trim().isEmpty && attachments.isEmpty) return;

    final result = await _sender.sendTextMessage(
      content: content,
      attachments: attachments,
      sender: _identity,
      editingTo: editingTo,
      replyingTo: replyingTo,
      forwardingTo: forwardingTo,
      poll: poll,
      fund: fund,
      onProgress: onProgress,
    );

    if (!result.success || result.message == null) {
      showErrorAlert(result.error ?? 'Failed to send message');
      return;
    }

    _emitMessages([result.message!, ..._currentMessages]);
  }

  Future<void> sendVoiceMessage(
    String filePath, {
    int? durationMs,
    SnChatMessage? forwardingTo,
    SnChatMessage? replyingTo,
  }) async {
    final result = await _sender.sendVoiceMessage(
      filePath: filePath,
      sender: _identity,
      durationMs: durationMs,
      forwardingTo: forwardingTo,
      replyingTo: replyingTo,
    );

    if (!result.success || result.message == null) {
      showErrorAlert(result.error ?? 'Failed to send voice message');
      return;
    }

    _emitMessages([result.message!, ..._currentMessages]);
  }

  Future<void> retryMessage(String pendingMessageId) async {
    final result = await _sender.retryMessage(
      pendingMessageId,
      sender: _identity,
    );

    if (!result.success || result.message == null) {
      showErrorAlert(result.error ?? 'Failed to retry message');
      return;
    }

    final updated = _currentMessages.map((m) {
      if (m.id == pendingMessageId) return result.message!;
      return m;
    }).toList();
    _emitMessages(updated);
  }

  Future<void> receiveMessage(
    SnChatMessage remoteMessage, {
    bool applySideEffects = true,
  }) async {
    await _realtime.processNewMessage(remoteMessage);
    if (applySideEffects) await _processMessageSideEffects(remoteMessage);
  }

  Future<void> receiveMessageUpdate(SnChatMessage remoteMessage) async {
    await _realtime.processMessageUpdate(remoteMessage);
  }

  Future<void> receiveMessageDeletion(String messageId) async {
    await _realtime.processMessageDeletion(messageId);
  }

  Future<void> deleteMessage(String messageId) async {
    Logger.root.info('Deleting message $messageId');

    // Fetch message to check its status before attempting server delete
    final message = await fetchMessageById(messageId);
    if (message == null) {
      Logger.root.info('Message $messageId not found for deletion');
      return;
    }

    // Skip server delete for failed messages (never successfully sent)
    if (message.status == MessageStatus.failed) {
      Logger.root.info('Skipping server delete for failed message $messageId');
      // For failed messages, remove them completely from the active list
      _pendingMessages.remove(messageId);
      await _repository.deleteMessage(messageId);

      final currentMessages = (ref.mounted ? state.value : null) ?? [];
      final newMessages = currentMessages
          .where((m) => m.id != messageId)
          .toList();
      _emitMessages(newMessages);
      return;
    }

    try {
      final response = await _apiClient.delete(
        '/messager/chat/$roomId/messages/$messageId',
        options: _mlsWriteOptions(),
      );
      final deleteEvent = _tryParseChatMessage(
        response.data,
        context: 'delete response',
      );
      if (deleteEvent != null) {
        await receiveMessage(deleteEvent);
      } else {
        await receiveMessageDeletion(messageId);
      }
    } catch (err, stackTrace) {
      Logger.root.info('Error deleting message $messageId', err, stackTrace);
      showErrorAlert(err);
    }
  }

  Future<void> reactToMessage(
    String messageId, {
    required String symbol,
    required int attitude,
  }) async {
    try {
      await _apiClient.post(
        '/messager/chat/$roomId/messages/$messageId/reactions',
        data: {'symbol': symbol, 'attitude': attitude},
      );
      // Do not optimistically mutate local reaction counts here.
      // Reactions are applied via websocket/sync events to avoid double
      // increments (local apply + incoming reaction event).
    } catch (err, stackTrace) {
      Logger.root.info(
        'Failed to react to message $messageId',
        err,
        stackTrace,
      );
      showErrorAlert(err);
    }
  }

  Future<void> receiveReactionAdded(SnChatMessage remoteMessage) async {
    await _realtime.processReactionAdded(remoteMessage);
  }

  Future<void> receiveReactionRemoved(SnChatMessage remoteMessage) async {
    await _realtime.processReactionRemoved(remoteMessage);
  }

  /// Get search results without updating shared state
  /// Supports pagination with offset and take parameters
  Future<List<LocalChatMessage>> getSearchResults(
    String query, {
    bool? withLinks,
    bool? withAttachments,
    int offset = 0,
    int take = 50, // Reduced default from 1000/50 to consistent 50
  }) async {
    final trimmedQuery = query.trim();
    final hasFilters = [withLinks, withAttachments].any((e) => e == true);

    if (trimmedQuery.isEmpty && !hasFilters) {
      return [];
    }

    Logger.root.info(
      'Getting search results for query: $trimmedQuery, filters: links=$withLinks, attachments=$withAttachments, offset=$offset, take=$take',
    );

    try {
      // Use consistent pagination instead of fetching large batches
      // Database search is efficient, no need for excessive batch sizes
      final messages = await _getCachedMessages(
        offset: offset,
        take: take,
        searchQuery: trimmedQuery.isNotEmpty ? trimmedQuery : null,
        withLinks: withLinks,
        withAttachments: withAttachments,
      );
      return messages;
    } catch (e, stackTrace) {
      Logger.root.info('Error getting search results', e, stackTrace);
      rethrow;
    }
  }

  Future<void> searchMessages(
    String query, {
    bool? withLinks,
    bool? withAttachments,
    int offset = 0,
    int take = 50, // Consistent pagination
  }) async {
    _searchQuery = query.trim();
    _withLinks = withLinks;
    _withAttachments = withAttachments;

    if (_searchQuery!.isEmpty) {
      state = AsyncValue.data([]);
      return;
    }

    Logger.root.info('Searching messages with query: $_searchQuery');
    state = const AsyncValue.loading();

    try {
      final messages = await _getCachedMessages(
        offset: offset,
        take: take,
        searchQuery: _searchQuery,
        withLinks: _withLinks,
        withAttachments: _withAttachments,
      );
      _emitMessages(messages);
    } catch (e, stackTrace) {
      Logger.root.info('Error searching messages', e, stackTrace);
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
    final cached = _messageCache.get(messageId);
    if (cached != null) return cached;

    if (_messageCache.hasPendingFetch(messageId)) {
      return _messageCache.getPendingFetch(messageId)!;
    }

    final fetchFuture = _fetchMessageByIdInternal(messageId);
    _messageCache.registerPendingFetch(messageId, fetchFuture);
    return fetchFuture;
  }

  Future<LocalChatMessage?> _fetchMessageByIdInternal(String messageId) async {
    Logger.root.info('Fetching message by id $messageId from DB/API');
    try {
      final localMessage = await _repository.getLocalMessage(messageId);
      if (localMessage != null) return localMessage;

      final remoteMessage = await _repository.fetchRemoteMessage(messageId);
      if (remoteMessage == null) return null;
      final message = LocalChatMessage.fromRemoteMessage(
        remoteMessage,
        MessageStatus.sent,
      );

      await _repository.saveMessage(message);

      // Defer voice prefetching
      if (remoteMessage.type == 'voice') {
        _prefetchVoiceForRemoteMessage(remoteMessage);
      }
      return message;
    } catch (e) {
      if (e is DioException) return null;
      rethrow;
    }
  }

  Future<int> jumpToMessage(String messageId) async {
    Logger.root.info('Starting jump to message $messageId');
    if (_isJumping) {
      Logger.root.info('Jump already in progress, skipping');
      return -1;
    }
    _isJumping = true;

    // Clear flashing messages when starting a new jump
    if (!!ref.mounted) {
      ref.read(flashingMessagesProvider.notifier).state = {};
    }

    try {
      final jump = await _syncService.loadAroundMessage(
        messageId,
        chunkSize: 100,
      );
      if (!jump.found || jump.targetMessage == null) {
        Logger.root.info('Message $messageId not found');
        showSnackBar('messageNotFound'.tr());
        return -1;
      }

      // Check if message is already in current state to avoid duplicate loading
      final currentMessages = (ref.mounted ? state.value : null) ?? [];
      final existingIndex = currentMessages.indexWhere(
        (m) => m.id == messageId,
      );
      if (existingIndex >= 0) {
        Logger.root.info(
          'Message $messageId already in current state at index $existingIndex, jumping directly',
        );
        return existingIndex;
      }

      Logger.root.info(
        'Message $messageId not in current state, calculating position and loading messages around it',
      );

      final loadedMessages = jump.messages;

      // Check if loaded messages are already in current state
      final currentIds = currentMessages.map((m) => m.id).toSet();
      final newMessages = loadedMessages
          .where((m) => !currentIds.contains(m.id))
          .toList();
      Logger.root.info(
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
        Logger.root.info(
          'Updated state with ${uniqueMessages.length} total messages',
        );
      }

      // Wait a bit for the UI to rebuild with new messages
      await Future.delayed(const Duration(milliseconds: 100));

      final finalIndex = _currentMessages.indexWhere((m) => m.id == messageId);
      Logger.root.info('Final index for message $messageId is $finalIndex');

      // Verify the message is actually in the list before returning
      if (finalIndex == -1) {
        Logger.root.info(
          'Message $messageId still not found after loading, trying direct fetch',
        );
        // Try to fetch and add the specific message if it's still not found
        final directMessage = await fetchMessageById(messageId);
        if (directMessage != null) {
          final currentList = _currentMessages;
          final updatedList = [...currentList, directMessage];
          await _updateStateSafely(updatedList);
          final newIndex = updatedList.indexWhere((m) => m.id == messageId);
          Logger.root.info('Added message directly, new index: $newIndex');
          return newIndex;
        }
      }

      return finalIndex;
    } finally {
      _isJumping = false;
      if (_hasPendingRealtimeRefresh && ref.mounted) {
        _hasPendingRealtimeRefresh = false;
        Logger.root.info(
          'Applying queued post-jump refresh for room $roomId after realtime events',
        );
        unawaited(loadInitial(forceRemoteRefresh: false));
      }
    }
  }

  bool _hasLink(LocalChatMessage message) {
    final content = message.toRemoteMessage().content;
    if (content == null) return false;
    final urlRegex = RegExp(r'https?://[^\s/$.?#].[^\s]*');
    return urlRegex.hasMatch(content);
  }
}
