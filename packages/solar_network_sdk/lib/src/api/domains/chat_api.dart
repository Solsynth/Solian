import 'package:dio/dio.dart';
import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/chat/chat.dart';

/// API for chat/messaging endpoints (/messager).
///
/// Handles chat rooms, messages, members, and real-time communication.
class ChatApi extends BaseApi {
  ChatApi(super.dio);

  /// Base path for all messager endpoints.
  static const String _basePath = '/messager';

  // ==========================================
  // Room endpoints
  // ==========================================

  /// Gets all chat rooms for the current user.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnChatRoom>> getRooms({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/chat/rooms',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnChatRoom.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets a specific chat room by ID.
  ///
  /// [roomId] - The room ID.
  Future<SnChatRoom> getRoom(String roomId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/chat/rooms/$roomId',
    );
    return SnChatRoom.fromJson(response.data!);
  }

  /// Creates a new chat room.
  ///
  /// [name] - The room name.
  /// [type] - The room type (e.g., 'group', 'direct').
  /// [memberIds] - Initial member IDs.
  Future<SnChatRoom> createRoom({
    required String name,
    required String type,
    List<String>? memberIds,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/chat/rooms',
      data: {'name': name, 'type': type, 'member_ids': ?memberIds},
    );
    return SnChatRoom.fromJson(response.data!);
  }

  /// Updates a chat room.
  ///
  /// [roomId] - The room ID.
  /// [data] - The data to update.
  Future<SnChatRoom> updateRoom({
    required String roomId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/chat/rooms/$roomId',
      data: data,
    );
    return SnChatRoom.fromJson(response.data!);
  }

  /// Deletes a chat room.
  ///
  /// [roomId] - The room ID.
  Future<void> deleteRoom(String roomId) async {
    await delete('$_basePath/chat/rooms/$roomId');
  }

  /// Gets the chat summary.
  Future<SnChatSummary> getChatSummary() async {
    final response = await get<Map<String, dynamic>>('$_basePath/chat/summary');
    return SnChatSummary.fromJson(response.data!);
  }

  // ==========================================
  // Message endpoints
  // ==========================================

  /// Gets messages for a chat room.
  ///
  /// [roomId] - The room ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnChatMessage>> getMessages({
    required String roomId,
    int offset = 0,
    int take = 50,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/chat/rooms/$roomId/messages',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnChatMessage.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Sends a message to a chat room.
  ///
  /// [roomId] - The room ID.
  /// [content] - The message content.
  /// [attachments] - Optional attachments.
  Future<SnChatMessage> sendMessage({
    required String roomId,
    required String content,
    List<Map<String, dynamic>>? attachments,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/chat/rooms/$roomId/messages',
      data: {'content': content, 'attachments': ?attachments},
    );
    return SnChatMessage.fromJson(response.data!);
  }

  /// Edits a message.
  ///
  /// [roomId] - The room ID.
  /// [messageId] - The message ID.
  /// [content] - The new content.
  Future<SnChatMessage> editMessage({
    required String roomId,
    required String messageId,
    required String content,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/chat/rooms/$roomId/messages/$messageId',
      data: {'content': content},
    );
    return SnChatMessage.fromJson(response.data!);
  }

  /// Deletes a message.
  ///
  /// [roomId] - The room ID.
  /// [messageId] - The message ID.
  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  }) async {
    await delete('$_basePath/chat/rooms/$roomId/messages/$messageId');
  }

  /// Creates a placeholder message for streaming or uploading.
  ///
  /// [roomId] - The room ID.
  /// [kind] - "streaming" or "uploading".
  Future<SnChatMessage> createPlaceholder({
    required String roomId,
    required String kind,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/chat/rooms/$roomId/messages/placeholder',
      data: {'kind': kind},
    );
    return SnChatMessage.fromJson(response.data!);
  }

  /// Marks messages as read.
  ///
  /// [roomId] - The room ID.
  /// [messageId] - The last read message ID.
  Future<void> markAsRead({
    required String roomId,
    required String messageId,
  }) async {
    await post(
      '$_basePath/chat/rooms/$roomId/read',
      data: {'message_id': messageId},
    );
  }

  /// Redirects existing messages into a destination room.
  ///
  /// [roomId] - The destination room ID.
  /// [messageIds] - Source message IDs to redirect.
  Future<SnChatMessage> redirectMessages({
    required String roomId,
    required List<String> messageIds,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/chat/$roomId/messages/redirect',
      data: {'message_ids': messageIds},
    );
    return SnChatMessage.fromJson(response.data!);
  }

  // ==========================================
  // Member endpoints
  // ==========================================

  /// Gets members of a chat room.
  ///
  /// [roomId] - The room ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnChatMember>> getMembers({
    required String roomId,
    int offset = 0,
    int take = 50,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/chat/rooms/$roomId/members',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnChatMember.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Adds a member to a chat room.
  ///
  /// [roomId] - The room ID.
  /// [accountId] - The account ID to add.
  Future<void> addMember({
    required String roomId,
    required String accountId,
  }) async {
    await post(
      '$_basePath/chat/rooms/$roomId/members',
      data: {'account_id': accountId},
    );
  }

  /// Removes a member from a chat room.
  ///
  /// [roomId] - The room ID.
  /// [accountId] - The account ID to remove.
  Future<void> removeMember({
    required String roomId,
    required String accountId,
  }) async {
    await delete('$_basePath/chat/rooms/$roomId/members/$accountId');
  }

  /// Leaves a chat room.
  ///
  /// [roomId] - The room ID.
  Future<void> leaveRoom(String roomId) async {
    await delete('$_basePath/chat/rooms/$roomId/members/me');
  }

  /// Promotes a member to admin.
  ///
  /// [roomId] - The room ID.
  /// [accountId] - The account ID to promote.
  Future<void> promoteToAdmin({
    required String roomId,
    required String accountId,
  }) async {
    await post('$_basePath/chat/rooms/$roomId/members/$accountId/admin');
  }

  /// Demotes an admin to member.
  ///
  /// [roomId] - The room ID.
  /// [accountId] - The account ID to demote.
  Future<void> demoteFromAdmin({
    required String roomId,
    required String accountId,
  }) async {
    await delete('$_basePath/chat/rooms/$roomId/members/$accountId/admin');
  }

  // ==========================================
  // Reaction endpoints
  // ==========================================

  /// Adds a reaction to a message.
  ///
  /// [roomId] - The room ID.
  /// [messageId] - The message ID.
  /// [reactionType] - The reaction type (emoji).
  Future<void> addReaction({
    required String roomId,
    required String messageId,
    required String reactionType,
  }) async {
    await post(
      '$_basePath/chat/rooms/$roomId/messages/$messageId/reactions',
      data: {'type': reactionType},
    );
  }

  /// Removes a reaction from a message.
  ///
  /// [roomId] - The room ID.
  /// [messageId] - The message ID.
  Future<void> removeReaction({
    required String roomId,
    required String messageId,
  }) async {
    await delete('$_basePath/chat/rooms/$roomId/messages/$messageId/reactions');
  }

  // ==========================================
  // Direct chat endpoints
  // ==========================================

  /// Gets or creates a direct chat with another user.
  ///
  /// [accountId] - The other user's account ID.
  Future<SnChatRoom?> getDirectChat(String accountId) async {
    try {
      final response = await get<Map<String, dynamic>>(
        '$_basePath/chat/direct/$accountId',
      );
      return SnChatRoom.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// Creates a new direct chat with another user.
  ///
  /// [accountId] - The other user's account ID.
  Future<SnChatRoom> createDirectChat(String accountId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/chat/direct',
      data: {'related_user_id': accountId},
    );
    return SnChatRoom.fromJson(response.data!);
  }

  /// Gets or creates a direct chat with another user.
  ///
  /// [accountId] - The other user's account ID.
  Future<SnChatRoom> getOrCreateDirectChat(String accountId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/chat/direct/$accountId',
    );
    return SnChatRoom.fromJson(response.data!);
  }

  // ==========================================
  // Online status endpoints
  // ==========================================

  /// Gets online status for accounts.
  ///
  /// [accountIds] - List of account IDs to check.
  Future<List<SnChatOnlineStatus>> getOnlineStatus(
    List<String> accountIds,
  ) async {
    final response = await get<List<dynamic>>(
      '$_basePath/chat/online',
      queryParameters: {'account_ids': accountIds.join(',')},
    );
    return parseList(response, SnChatOnlineStatus.fromJson);
  }

  /// Updates the current user's online status.
  ///
  /// [status] - The online status (e.g., 'online', 'away', 'busy').
  Future<void> updateOnlineStatus(String status) async {
    await post('$_basePath/chat/online', data: {'status': status});
  }

  // ==========================================
  // Realm chat endpoints
  // ==========================================

  /// Gets chat rooms for a realm.
  ///
  /// [realmSlug] - The realm slug.
  Future<List<SnChatRoom>> getRealmChatRooms(String realmSlug) async {
    final response = await get<List<dynamic>>(
      '$_basePath/realms/$realmSlug/chat',
    );
    return parseList(response, SnChatRoom.fromJson);
  }

  // ==========================================
  // Group endpoints
  // ==========================================

  /// Gets chat groups for the current user.
  Future<List<SnChatGroup>> getGroups() async {
    final response = await get<List<dynamic>>('$_basePath/chat/groups');
    return parseList(response, SnChatGroup.fromJson);
  }

  /// Creates a chat group.
  Future<SnChatGroup> createGroup({
    required String name,
    String? color,
    String? icon,
    int? order,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/chat/groups',
      data: {'name': name, 'color': color, 'icon': icon, 'order': order}
        ..removeWhere((_, value) => value == null),
    );
    return SnChatGroup.fromJson(response.data!);
  }

  /// Updates a chat group.
  Future<SnChatGroup> updateGroup({
    required String groupId,
    String? name,
    String? color,
    String? icon,
    int? order,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/chat/groups/$groupId',
      data: {'name': name, 'color': color, 'icon': icon, 'order': order}
        ..removeWhere((_, value) => value == null),
    );
    return SnChatGroup.fromJson(response.data!);
  }

  /// Deletes a chat group.
  Future<void> deleteGroup(String groupId) async {
    await delete('$_basePath/chat/groups/$groupId');
  }

  /// Assigns a room to a group, or removes it from its group when [groupId] is null.
  Future<void> moveRoomToGroup({
    required String roomId,
    String? groupId,
  }) async {
    await patch(
      '$_basePath/chat/rooms/$roomId/group',
      data: {'group_id': groupId},
    );
  }

  // ==========================================
  // Call endpoints
  // ==========================================

  /// Initiates a call in a chat room.
  ///
  /// [roomId] - The room ID.
  /// [type] - The call type (e.g., 'audio', 'video').
  Future<SnRealtimeCall> initiateCall({
    required String roomId,
    required String type,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/chat/rooms/$roomId/calls',
      data: {'type': type},
    );
    return SnRealtimeCall.fromJson(response.data!);
  }

  /// Joins an active call.
  ///
  /// [roomId] - The room ID.
  /// [callId] - The call ID.
  Future<void> joinCall({
    required String roomId,
    required String callId,
  }) async {
    await post('$_basePath/chat/rooms/$roomId/calls/$callId/join');
  }

  /// Leaves an active call.
  ///
  /// [roomId] - The room ID.
  /// [callId] - The call ID.
  Future<void> leaveCall({
    required String roomId,
    required String callId,
  }) async {
    await post('$_basePath/chat/rooms/$roomId/calls/$callId/leave');
  }

  /// Ends an active call.
  ///
  /// [roomId] - The room ID.
  /// [callId] - The call ID.
  Future<void> endCall({required String roomId, required String callId}) async {
    await delete('$_basePath/chat/rooms/$roomId/calls/$callId');
  }
}
