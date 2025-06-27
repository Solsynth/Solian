import 'package:dio/dio.dart';
import 'package:island/database/drift_db.dart';
import 'package:island/database/message.dart';
import 'package:island/models/chat.dart';
import 'package:island/models/file.dart';
import 'package:island/services/file.dart';
import 'package:island/widgets/alert.dart';
import 'package:uuid/uuid.dart';

class MessageRepository {
  final SnChatRoom room;
  final SnChatMember identity;
  final Dio _apiClient;
  final AppDatabase _database;

  final Map<String, LocalChatMessage> pendingMessages = {};
  final Map<String, Map<int, double>> fileUploadProgress = {};
  int? _totalCount;

  MessageRepository(this.room, this.identity, this._apiClient, this._database);

  Future<LocalChatMessage?> getLastMessages() async {
    final dbMessages = await _database.getMessagesForRoom(
      room.id,
      offset: 0,
      limit: 1,
    );

    if (dbMessages.isEmpty) {
      return null;
    }

    return _database.companionToMessage(dbMessages.first);
  }

  Future<bool> syncMessages() async {
    final lastMessage = await getLastMessages();
    if (lastMessage == null) return false;
    try {
      final resp = await _apiClient.post(
        '/chat/${room.id}/sync',
        data: {
          'last_sync_timestamp':
              lastMessage.toRemoteMessage().updatedAt.millisecondsSinceEpoch,
        },
      );

      final response = MessageSyncResponse.fromJson(resp.data);
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
    } catch (err) {
      showErrorAlert(err);
    }
    return true;
  }

  Future<List<LocalChatMessage>> listMessages({
    int offset = 0,
    int take = 20,
    bool synced = false,
  }) async {
    try {
      // For initial load, fetch latest messages in the background to sync.
      if (offset == 0 && !synced) {
        // Not awaiting this is intentional, for a quicker UI response.
        // The UI should rely on a stream from the database to get updates.
        _fetchAndCacheMessages(room.id, offset: 0, take: take).catchError((_) {
          // Best effort, errors will be handled by later fetches.
          return <LocalChatMessage>[];
        });
      }

      final localMessages = await _getCachedMessages(
        room.id,
        offset: offset,
        take: take,
      );

      // If local cache has messages, return them. This is the common case for scrolling up.
      if (localMessages.isNotEmpty) {
        return localMessages;
      }

      // If local cache is empty, we've probably reached the end of cached history.
      // Fetch from remote. This will also be hit on first load if cache is empty.
      return await _fetchAndCacheMessages(room.id, offset: offset, take: take);
    } catch (e) {
      // Final fallback to cache in case of network errors during fetch.
      final localMessages = await _getCachedMessages(
        room.id,
        offset: offset,
        take: take,
      );

      if (localMessages.isNotEmpty) {
        return localMessages;
      }
      rethrow;
    }
  }

  Future<List<LocalChatMessage>> _getCachedMessages(
    String roomId, {
    int offset = 0,
    int take = 20,
  }) async {
    // Get messages from local database
    final dbMessages = await _database.getMessagesForRoom(
      roomId,
      offset: offset,
      limit: take,
    );
    final dbLocalMessages =
        dbMessages.map(_database.companionToMessage).toList();

    // Combine with pending messages for the first page
    if (offset == 0) {
      final pendingForRoom =
          pendingMessages.values.where((msg) => msg.roomId == roomId).toList();

      final allMessages = [...pendingForRoom, ...dbLocalMessages];
      allMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Remove duplicates by ID, preserving the order
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

  Future<List<LocalChatMessage>> _fetchAndCacheMessages(
    String roomId, {
    int offset = 0,
    int take = 20,
  }) async {
    // Use cached total count if available, otherwise fetch it
    if (_totalCount == null) {
      final response = await _apiClient.get(
        '/chat/$roomId/messages',
        queryParameters: {'offset': 0, 'take': 1},
      );
      _totalCount = int.parse(response.headers['x-total']?.firstOrNull ?? '0');
    }

    if (offset >= _totalCount!) {
      return [];
    }

    final response = await _apiClient.get(
      '/chat/$roomId/messages',
      queryParameters: {'offset': offset, 'take': take},
    );

    final List<dynamic> data = response.data;
    // Update total count from response headers
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
        pendingMessages.removeWhere(
          (_, pendingMsg) => pendingMsg.nonce == message.nonce,
        );
      }
    }

    return messages;
  }

  Future<LocalChatMessage> sendMessage(
    String token,
    String baseUrl,
    String roomId,
    String content,
    String nonce, {
    required List<UniversalFile> attachments,
    Map<String, dynamic>? meta,
    SnChatMessage? replyingTo,
    SnChatMessage? forwardingTo,
    SnChatMessage? editingTo,
    Function(LocalChatMessage)? onPending,
    Function(String, Map<int, double>)? onProgress,
  }) async {
    // Generate a unique nonce for this message
    final nonce = const Uuid().v4();

    // Create a local message with pending status
    final mockMessage = SnChatMessage(
      id: 'pending_$nonce',
      chatRoomId: roomId,
      senderId: identity.id,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nonce: nonce,
      sender: identity,
    );

    final localMessage = LocalChatMessage.fromRemoteMessage(
      mockMessage,
      MessageStatus.pending,
    );

    // Store in memory and database
    pendingMessages[localMessage.id] = localMessage;
    fileUploadProgress[localMessage.id] = {};
    await _database.saveMessage(_database.messageToCompanion(localMessage));
    onPending?.call(localMessage);

    try {
      var cloudAttachments = List.empty(growable: true);
      // Upload files
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
                fileUploadProgress[localMessage.id]?[idx] = progress;
                onProgress?.call(
                  localMessage.id,
                  fileUploadProgress[localMessage.id] ?? {},
                );
              },
            ).future;
        if (cloudFile == null) {
          throw ArgumentError('Failed to upload the file...');
        }
        cloudAttachments.add(cloudFile);
      }

      // Send to server
      final response = await _apiClient.request(
        editingTo == null
            ? '/chat/$roomId/messages'
            : '/chat/$roomId/messages/${editingTo.id}',
        data: {
          'content': content,
          'attachments_id': cloudAttachments.map((e) => e.id).toList(),
          'replied_message_id': replyingTo?.id,
          'forwarded_message_id': forwardingTo?.id,
          'meta': meta,
          'nonce': nonce,
        },
        options: Options(method: editingTo == null ? 'POST' : 'PATCH'),
      );

      // Update with server response
      final remoteMessage = SnChatMessage.fromJson(response.data);
      final updatedMessage = LocalChatMessage.fromRemoteMessage(
        remoteMessage,
        MessageStatus.sent,
      );

      // Remove from pending and update in database
      pendingMessages.remove(localMessage.id);
      await _database.deleteMessage(localMessage.id);
      await _database.saveMessage(_database.messageToCompanion(updatedMessage));

      return updatedMessage;
    } catch (e) {
      // Update status to failed
      localMessage.status = MessageStatus.failed;
      pendingMessages[localMessage.id] = localMessage;
      await _database.updateMessageStatus(
        localMessage.id,
        MessageStatus.failed,
      );
      rethrow;
    }
  }

  Future<LocalChatMessage> retryMessage(String pendingMessageId) async {
    final message = await getMessageById(pendingMessageId);
    if (message == null) {
      throw Exception('Message not found');
    }

    // Update status back to pending
    message.status = MessageStatus.pending;
    pendingMessages[pendingMessageId] = message;
    await _database.updateMessageStatus(
      pendingMessageId,
      MessageStatus.pending,
    );

    try {
      // Send to server
      var remoteMessage = message.toRemoteMessage();
      final response = await _apiClient.post(
        '/chat/${message.roomId}/messages',
        data: {
          'content': remoteMessage.content,
          'attachments_id': remoteMessage.attachments,
          'meta': remoteMessage.meta,
          'nonce': message.nonce,
        },
      );

      // Update with server response
      remoteMessage = SnChatMessage.fromJson(response.data);
      final updatedMessage = LocalChatMessage.fromRemoteMessage(
        remoteMessage,
        MessageStatus.sent,
      );

      // Remove from pending and update in database
      pendingMessages.remove(pendingMessageId);
      await _database.deleteMessage(pendingMessageId);
      await _database.saveMessage(_database.messageToCompanion(updatedMessage));

      return updatedMessage;
    } catch (e) {
      // Update status to failed
      message.status = MessageStatus.failed;
      pendingMessages[pendingMessageId] = message;
      await _database.updateMessageStatus(
        pendingMessageId,
        MessageStatus.failed,
      );
      rethrow;
    }
  }

  Future<LocalChatMessage> receiveMessage(SnChatMessage remoteMessage) async {
    final localMessage = LocalChatMessage.fromRemoteMessage(
      remoteMessage,
      MessageStatus.sent,
    );

    if (remoteMessage.nonce != null) {
      pendingMessages.removeWhere(
        (_, pendingMsg) => pendingMsg.nonce == remoteMessage.nonce,
      );
    }

    await _database.saveMessage(_database.messageToCompanion(localMessage));
    return localMessage;
  }

  Future<LocalChatMessage> receiveMessageUpdate(
    SnChatMessage remoteMessage,
  ) async {
    final localMessage = LocalChatMessage.fromRemoteMessage(
      remoteMessage,
      MessageStatus.sent,
    );

    await _database.updateMessage(_database.messageToCompanion(localMessage));
    return localMessage;
  }

  Future<void> receiveMessageDeletion(String messageId) async {
    // Remove from pending messages if exists
    pendingMessages.remove(messageId);

    // Delete from local database
    await _database.deleteMessage(messageId);
  }

  Future<LocalChatMessage> updateMessage(
    String messageId,
    String content, {
    List<SnCloudFile>? attachments,
    Map<String, dynamic>? meta,
  }) async {
    final message = pendingMessages[messageId];
    if (message != null) {
      // Update pending message
      final rmMessage = message.toRemoteMessage();
      final updatedRemoteMessage = rmMessage.copyWith(
        content: content,
        meta: meta ?? rmMessage.meta,
      );
      final updatedLocalMessage = LocalChatMessage.fromRemoteMessage(
        updatedRemoteMessage,
        MessageStatus.pending,
      );
      pendingMessages[messageId] = updatedLocalMessage;
      await _database.updateMessage(
        _database.messageToCompanion(updatedLocalMessage),
      );
      return message;
    }

    try {
      // Update on server
      final response = await _apiClient.put(
        '/chat/${room.id}/messages/$messageId',
        data: {'content': content, 'attachments': attachments, 'meta': meta},
      );

      // Update local copy
      final remoteMessage = SnChatMessage.fromJson(response.data);
      final updatedMessage = LocalChatMessage.fromRemoteMessage(
        remoteMessage,
        MessageStatus.sent,
      );
      await _database.updateMessage(
        _database.messageToCompanion(updatedMessage),
      );
      return updatedMessage;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _apiClient.delete('/chat/${room.id}/messages/$messageId');
      pendingMessages.remove(messageId);
      await _database.deleteMessage(messageId);
    } catch (e) {
      rethrow;
    }
  }

  Future<LocalChatMessage?> getMessageById(String messageId) async {
    try {
      // Attempt to get the message from the local database
      final localMessage =
          await (_database.select(_database.chatMessages)
            ..where((tbl) => tbl.id.equals(messageId))).getSingleOrNull();
      if (localMessage != null) {
        return _database.companionToMessage(localMessage);
      }

      // If not found locally, fetch from the server
      final response = await _apiClient.get(
        '/chat/${room.id}/messages/$messageId',
      );
      final remoteMessage = SnChatMessage.fromJson(response.data);
      final message = LocalChatMessage.fromRemoteMessage(
        remoteMessage,
        MessageStatus.sent,
      );

      // Save the fetched message to the local database
      await _database.saveMessage(_database.messageToCompanion(message));
      return message;
    } catch (e) {
      if (e is DioException) return null;
      // Handle errors
      rethrow;
    }
  }
}
