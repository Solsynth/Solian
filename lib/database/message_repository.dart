import 'package:dio/dio.dart';
import 'package:island/database/drift_db.dart';
import 'package:island/database/message.dart';
import 'package:island/models/chat.dart';
import 'package:island/models/file.dart';
import 'package:uuid/uuid.dart';

class MessageRepository {
  final SnChat room;
  final Dio _apiClient;
  final AppDatabase _database;

  SnChatMember? _identity;

  final Map<String, LocalChatMessage> _pendingMessages = {};

  MessageRepository(this.room, this._apiClient, this._database) {
    initialize();
  }

  bool initialized = false;

  Future<void> initialize() async {
    if (initialized) return;

    try {
      final response = await _apiClient.get('/chat/${room.id}/members/me');
      _identity = SnChatMember.fromJson(response.data);
      initialized = true;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LocalChatMessage>> listMessages({
    int offset = 0,
    int take = 20,
  }) async {
    try {
      final localMessages = await _getCachedMessages(
        room.id,
        offset: offset,
        take: take,
      );

      if (offset == 0) {
        // Always fetch latest messages in background if we're loading the first page
        _fetchAndCacheMessages(room.id, offset: offset, take: take);

        if (localMessages.isNotEmpty) {
          return localMessages;
        }
      }

      return await _fetchAndCacheMessages(room.id, offset: offset, take: take);
    } catch (e) {
      // If API fails but we have local messages, return them
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
    int roomId, {
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

    // Combine with pending messages
    final pendingForRoom =
        _pendingMessages.values.where((msg) => msg.roomId == roomId).toList();

    // Sort by timestamp descending (newest first)
    final allMessages = [...pendingForRoom, ...dbLocalMessages];
    allMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply pagination
    if (offset >= allMessages.length) {
      return [];
    }

    final end =
        (offset + take) > allMessages.length
            ? allMessages.length
            : (offset + take);
    return allMessages.sublist(offset, end);
  }

  Future<List<LocalChatMessage>> _fetchAndCacheMessages(
    int roomId, {
    int offset = 0,
    int take = 20,
  }) async {
    final response = await _apiClient.get(
      '/chat/$roomId/messages',
      queryParameters: {'offset': offset, 'take': take},
    );

    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;

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

  Future<LocalChatMessage> sendMessage(
    int roomId,
    String content, {
    List<SnCloudFile>? attachments,
    Map<String, dynamic>? meta,
  }) async {
    if (!initialized) {
      throw UnsupportedError(
        "The message repository is not ready for send message.",
      );
    }

    // Generate a unique nonce for this message
    final nonce = const Uuid().v4();

    // Create a local message with pending status
    final mockMessage = SnChatMessage(
      id: 'pending_$nonce',
      chatRoomId: roomId,
      senderId: _identity!.id,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nonce: nonce,
      sender: _identity!,
    );

    final localMessage = LocalChatMessage.fromRemoteMessage(
      mockMessage,
      MessageStatus.pending,
    );

    // Store in memory and database
    _pendingMessages[localMessage.id] = localMessage;
    await _database.saveMessage(_database.messageToCompanion(localMessage));

    try {
      // Send to server
      final response = await _apiClient.post(
        '/chat/$roomId/messages',
        data: {
          'content': content,
          'attachments_id': attachments,
          'meta': meta,
          'nonce': nonce,
        },
      );

      // Update with server response
      final remoteMessage = SnChatMessage.fromJson(response.data);
      final updatedMessage = LocalChatMessage.fromRemoteMessage(
        remoteMessage,
        MessageStatus.sent,
      );

      // Remove from pending and update in database
      _pendingMessages.remove(localMessage.id);
      await _database.deleteMessage(localMessage.id);
      await _database.saveMessage(_database.messageToCompanion(updatedMessage));

      return updatedMessage;
    } catch (e) {
      // Update status to failed
      localMessage.status = MessageStatus.failed;
      _pendingMessages[localMessage.id] = localMessage;
      await _database.updateMessageStatus(
        localMessage.id,
        MessageStatus.failed,
      );
      rethrow;
    }
  }

  Future<LocalChatMessage> retryMessage(String pendingMessageId) async {
    final message = _pendingMessages[pendingMessageId];
    if (message == null) {
      throw Exception('Message not found');
    }

    // Update status back to pending
    message.status = MessageStatus.pending;
    _pendingMessages[pendingMessageId] = message;
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
      _pendingMessages.remove(pendingMessageId);
      await _database.deleteMessage(pendingMessageId);
      await _database.saveMessage(_database.messageToCompanion(updatedMessage));

      return updatedMessage;
    } catch (e) {
      // Update status to failed
      message.status = MessageStatus.failed;
      _pendingMessages[pendingMessageId] = message;
      await _database.updateMessageStatus(
        pendingMessageId,
        MessageStatus.failed,
      );
      rethrow;
    }
  }
}
