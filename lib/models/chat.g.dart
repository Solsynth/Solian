// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnChatRoom _$SnChatRoomFromJson(Map<String, dynamic> json) => _SnChatRoom(
  id: json['id'] as String,
  name: json['name'] as String?,
  description: json['description'] as String?,
  type: (json['type'] as num).toInt(),
  isPublic: json['is_public'] as bool? ?? false,
  isCommunity: json['is_community'] as bool? ?? false,
  picture:
      json['picture'] == null
          ? null
          : SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
  background:
      json['background'] == null
          ? null
          : SnCloudFile.fromJson(json['background'] as Map<String, dynamic>),
  realmId: json['realm_id'] as String?,
  realm:
      json['realm'] == null
          ? null
          : SnRealm.fromJson(json['realm'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
  members:
      (json['members'] as List<dynamic>?)
          ?.map((e) => SnChatMember.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$SnChatRoomToJson(_SnChatRoom instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'is_public': instance.isPublic,
      'is_community': instance.isCommunity,
      'picture': instance.picture?.toJson(),
      'background': instance.background?.toJson(),
      'realm_id': instance.realmId,
      'realm': instance.realm?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'members': instance.members?.map((e) => e.toJson()).toList(),
    };

_SnChatMessage _$SnChatMessageFromJson(Map<String, dynamic> json) =>
    _SnChatMessage(
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
      id: json['id'] as String,
      type: json['type'] as String? ?? 'text',
      content: json['content'] as String?,
      nonce: json['nonce'] as String?,
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
      membersMetioned:
          (json['members_metioned'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      editedAt:
          json['edited_at'] == null
              ? null
              : DateTime.parse(json['edited_at'] as String),
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => SnCloudFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reactions:
          (json['reactions'] as List<dynamic>?)
              ?.map((e) => SnChatReaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      repliedMessageId: json['replied_message_id'] as String?,
      forwardedMessageId: json['forwarded_message_id'] as String?,
      senderId: json['sender_id'] as String,
      sender: SnChatMember.fromJson(json['sender'] as Map<String, dynamic>),
      chatRoomId: json['chat_room_id'] as String,
    );

Map<String, dynamic> _$SnChatMessageToJson(_SnChatMessage instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'id': instance.id,
      'type': instance.type,
      'content': instance.content,
      'nonce': instance.nonce,
      'meta': instance.meta,
      'members_metioned': instance.membersMetioned,
      'edited_at': instance.editedAt?.toIso8601String(),
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'replied_message_id': instance.repliedMessageId,
      'forwarded_message_id': instance.forwardedMessageId,
      'sender_id': instance.senderId,
      'sender': instance.sender.toJson(),
      'chat_room_id': instance.chatRoomId,
    };

_SnChatReaction _$SnChatReactionFromJson(Map<String, dynamic> json) =>
    _SnChatReaction(
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
      id: json['id'] as String,
      messageId: json['message_id'] as String,
      senderId: json['sender_id'] as String,
      sender: SnChatMember.fromJson(json['sender'] as Map<String, dynamic>),
      symbol: json['symbol'] as String,
      attitude: (json['attitude'] as num).toInt(),
    );

Map<String, dynamic> _$SnChatReactionToJson(_SnChatReaction instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'id': instance.id,
      'message_id': instance.messageId,
      'sender_id': instance.senderId,
      'sender': instance.sender.toJson(),
      'symbol': instance.symbol,
      'attitude': instance.attitude,
    };

_SnChatMember _$SnChatMemberFromJson(Map<String, dynamic> json) =>
    _SnChatMember(
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
      id: json['id'] as String,
      chatRoomId: json['chat_room_id'] as String,
      chatRoom:
          json['chat_room'] == null
              ? null
              : SnChatRoom.fromJson(json['chat_room'] as Map<String, dynamic>),
      accountId: json['account_id'] as String,
      account: SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      nick: json['nick'] as String?,
      role: (json['role'] as num).toInt(),
      notify: (json['notify'] as num).toInt(),
      joinedAt:
          json['joined_at'] == null
              ? null
              : DateTime.parse(json['joined_at'] as String),
      breakUntil:
          json['break_until'] == null
              ? null
              : DateTime.parse(json['break_until'] as String),
      timeoutUntil:
          json['timeout_until'] == null
              ? null
              : DateTime.parse(json['timeout_until'] as String),
      isBot: json['is_bot'] as bool,
      lastTyped:
          json['last_typed'] == null
              ? null
              : DateTime.parse(json['last_typed'] as String),
    );

Map<String, dynamic> _$SnChatMemberToJson(_SnChatMember instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'id': instance.id,
      'chat_room_id': instance.chatRoomId,
      'chat_room': instance.chatRoom?.toJson(),
      'account_id': instance.accountId,
      'account': instance.account.toJson(),
      'nick': instance.nick,
      'role': instance.role,
      'notify': instance.notify,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'break_until': instance.breakUntil?.toIso8601String(),
      'timeout_until': instance.timeoutUntil?.toIso8601String(),
      'is_bot': instance.isBot,
      'last_typed': instance.lastTyped?.toIso8601String(),
    };

_SnChatSummary _$SnChatSummaryFromJson(Map<String, dynamic> json) =>
    _SnChatSummary(
      unreadCount: (json['unread_count'] as num).toInt(),
      lastMessage: SnChatMessage.fromJson(
        json['last_message'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SnChatSummaryToJson(_SnChatSummary instance) =>
    <String, dynamic>{
      'unread_count': instance.unreadCount,
      'last_message': instance.lastMessage.toJson(),
    };

_MessageChange _$MessageChangeFromJson(Map<String, dynamic> json) =>
    _MessageChange(
      messageId: json['message_id'] as String,
      action: json['action'] as String,
      message:
          json['message'] == null
              ? null
              : SnChatMessage.fromJson(json['message'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$MessageChangeToJson(_MessageChange instance) =>
    <String, dynamic>{
      'message_id': instance.messageId,
      'action': instance.action,
      'message': instance.message?.toJson(),
      'timestamp': instance.timestamp.toIso8601String(),
    };

_MessageSyncResponse _$MessageSyncResponseFromJson(Map<String, dynamic> json) =>
    _MessageSyncResponse(
      changes:
          (json['changes'] as List<dynamic>?)
              ?.map((e) => MessageChange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentTimestamp: DateTime.parse(json['current_timestamp'] as String),
    );

Map<String, dynamic> _$MessageSyncResponseToJson(
  _MessageSyncResponse instance,
) => <String, dynamic>{
  'changes': instance.changes.map((e) => e.toJson()).toList(),
  'current_timestamp': instance.currentTimestamp.toIso8601String(),
};

_ChatRealtimeJoinResponse _$ChatRealtimeJoinResponseFromJson(
  Map<String, dynamic> json,
) => _ChatRealtimeJoinResponse(
  provider: json['provider'] as String,
  endpoint: json['endpoint'] as String,
  token: json['token'] as String,
  callId: json['call_id'] as String,
  roomName: json['room_name'] as String,
  isAdmin: json['is_admin'] as bool,
  participants:
      (json['participants'] as List<dynamic>)
          .map((e) => CallParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ChatRealtimeJoinResponseToJson(
  _ChatRealtimeJoinResponse instance,
) => <String, dynamic>{
  'provider': instance.provider,
  'endpoint': instance.endpoint,
  'token': instance.token,
  'call_id': instance.callId,
  'room_name': instance.roomName,
  'is_admin': instance.isAdmin,
  'participants': instance.participants.map((e) => e.toJson()).toList(),
};

_CallParticipant _$CallParticipantFromJson(Map<String, dynamic> json) =>
    _CallParticipant(
      identity: json['identity'] as String,
      name: json['name'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      accountId: json['account_id'] as String?,
      profile:
          json['profile'] == null
              ? null
              : SnChatMember.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CallParticipantToJson(_CallParticipant instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'name': instance.name,
      'joined_at': instance.joinedAt.toIso8601String(),
      'account_id': instance.accountId,
      'profile': instance.profile?.toJson(),
    };

_SnRealtimeCall _$SnRealtimeCallFromJson(Map<String, dynamic> json) =>
    _SnRealtimeCall(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] == null
              ? null
              : DateTime.parse(json['deleted_at'] as String),
      endedAt:
          json['ended_at'] == null
              ? null
              : DateTime.parse(json['ended_at'] as String),
      senderId: json['sender_id'] as String,
      sender: SnChatMember.fromJson(json['sender'] as Map<String, dynamic>),
      roomId: json['room_id'] as String,
      room: SnChatRoom.fromJson(json['room'] as Map<String, dynamic>),
      upstreamConfig: json['upstream_config'] as Map<String, dynamic>,
      providerName: json['provider_name'] as String?,
      sessionId: json['session_id'] as String?,
    );

Map<String, dynamic> _$SnRealtimeCallToJson(_SnRealtimeCall instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'ended_at': instance.endedAt?.toIso8601String(),
      'sender_id': instance.senderId,
      'sender': instance.sender.toJson(),
      'room_id': instance.roomId,
      'room': instance.room.toJson(),
      'upstream_config': instance.upstreamConfig,
      'provider_name': instance.providerName,
      'session_id': instance.sessionId,
    };
