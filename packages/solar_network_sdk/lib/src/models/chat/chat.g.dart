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
  encryptionMode: (json['encryption_mode'] as num?)?.toInt() ?? 0,
  isPublic: json['is_public'] as bool? ?? false,
  isCommunity: json['is_community'] as bool? ?? false,
  picture: json['picture'] == null
      ? null
      : SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
  background: json['background'] == null
      ? null
      : SnCloudFile.fromJson(json['background'] as Map<String, dynamic>),
  realmId: json['realm_id'] as String?,
  accountId: json['account_id'] as String?,
  realm: json['realm'] == null
      ? null
      : SnRealm.fromJson(json['realm'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  members: (json['members'] as List<dynamic>?)
      ?.map((e) => SnChatMember.fromJson(e as Map<String, dynamic>))
      .toList(),
  isPinned: json['is_pinned'] as bool? ?? false,
);

Map<String, dynamic> _$SnChatRoomToJson(_SnChatRoom instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'encryption_mode': instance.encryptionMode,
      'is_public': instance.isPublic,
      'is_community': instance.isCommunity,
      'picture': instance.picture?.toJson(),
      'background': instance.background?.toJson(),
      'realm_id': instance.realmId,
      'account_id': instance.accountId,
      'realm': instance.realm?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'members': instance.members?.map((e) => e.toJson()).toList(),
      'is_pinned': instance.isPinned,
    };

_SnChatMessage _$SnChatMessageFromJson(Map<String, dynamic> json) =>
    _SnChatMessage(
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      id: json['id'] as String,
      type: json['type'] as String? ?? 'text',
      content: json['content'] as String?,
      clientMessageId: json['client_message_id'] as String?,
      nonce: json['nonce'] as String?,
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
      membersMentioned:
          (json['members_mentioned'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      editedAt: json['edited_at'] == null
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
      'client_message_id': instance.clientMessageId,
      'nonce': instance.nonce,
      'meta': instance.meta,
      'members_mentioned': instance.membersMentioned,
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
      deletedAt: json['deleted_at'] == null
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
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      id: json['id'] as String,
      chatRoomId: json['chat_room_id'] as String,
      chatRoom: json['chat_room'] == null
          ? null
          : SnChatRoom.fromJson(json['chat_room'] as Map<String, dynamic>),
      accountId: json['account_id'] as String,
      account: SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      nick: json['nick'] as String?,
      notify: (json['notify'] as num).toInt(),
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
      breakUntil: json['break_until'] == null
          ? null
          : DateTime.parse(json['break_until'] as String),
      timeoutUntil: json['timeout_until'] == null
          ? null
          : DateTime.parse(json['timeout_until'] as String),
      status: json['status'] == null
          ? null
          : SnAccountStatus.fromJson(json['status'] as Map<String, dynamic>),
      realmNick: json['realm_nick'] as String?,
      realmBio: json['realm_bio'] as String?,
      realmExperience: (json['realm_experience'] as num?)?.toInt(),
      realmLevel: (json['realm_level'] as num?)?.toInt(),
      realmLevelingProgress: (json['realm_leveling_progress'] as num?)
          ?.toDouble(),
      realmLabel: json['realm_label'] == null
          ? null
          : SnRealmLabel.fromJson(json['realm_label'] as Map<String, dynamic>),
      lastTyped: json['last_typed'] == null
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
      'notify': instance.notify,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'break_until': instance.breakUntil?.toIso8601String(),
      'timeout_until': instance.timeoutUntil?.toIso8601String(),
      'status': instance.status?.toJson(),
      'realm_nick': instance.realmNick,
      'realm_bio': instance.realmBio,
      'realm_experience': instance.realmExperience,
      'realm_level': instance.realmLevel,
      'realm_leveling_progress': instance.realmLevelingProgress,
      'realm_label': instance.realmLabel?.toJson(),
      'last_typed': instance.lastTyped?.toIso8601String(),
    };

_SnChatSummary _$SnChatSummaryFromJson(Map<String, dynamic> json) =>
    _SnChatSummary(
      unreadCount: (json['unread_count'] as num).toInt(),
      lastMessage: json['last_message'] == null
          ? null
          : SnChatMessage.fromJson(
              json['last_message'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SnChatSummaryToJson(_SnChatSummary instance) =>
    <String, dynamic>{
      'unread_count': instance.unreadCount,
      'last_message': instance.lastMessage?.toJson(),
    };

_SnChatOnlineAccount _$SnChatOnlineAccountFromJson(Map<String, dynamic> json) =>
    _SnChatOnlineAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      nick: json['nick'] as String,
    );

Map<String, dynamic> _$SnChatOnlineAccountToJson(
  _SnChatOnlineAccount instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nick': instance.nick,
};

_SnChatOnlineStatus _$SnChatOnlineStatusFromJson(Map<String, dynamic> json) =>
    _SnChatOnlineStatus(
      onlineCount: (json['online_count'] as num).toInt(),
      directMessageStatus: json['direct_message_status'] == null
          ? null
          : SnAccountStatus.fromJson(
              json['direct_message_status'] as Map<String, dynamic>,
            ),
      onlineUserNames:
          (json['online_user_names'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      onlineAccounts:
          (json['online_accounts'] as List<dynamic>?)
              ?.map(
                (e) => SnChatOnlineAccount.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SnChatOnlineStatusToJson(
  _SnChatOnlineStatus instance,
) => <String, dynamic>{
  'online_count': instance.onlineCount,
  'direct_message_status': instance.directMessageStatus?.toJson(),
  'online_user_names': instance.onlineUserNames,
  'online_accounts': instance.onlineAccounts.map((e) => e.toJson()).toList(),
};

_MessageSyncResponse _$MessageSyncResponseFromJson(Map<String, dynamic> json) =>
    _MessageSyncResponse(
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => SnChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      currentTimestamp: DateTime.parse(json['current_timestamp'] as String),
    );

Map<String, dynamic> _$MessageSyncResponseToJson(
  _MessageSyncResponse instance,
) => <String, dynamic>{
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'total_count': instance.totalCount,
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
  participants: (json['participants'] as List<dynamic>)
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
    );

Map<String, dynamic> _$CallParticipantToJson(_CallParticipant instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'name': instance.name,
      'joined_at': instance.joinedAt.toIso8601String(),
    };

_SnRealtimeCall _$SnRealtimeCallFromJson(Map<String, dynamic> json) =>
    _SnRealtimeCall(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      endedAt: json['ended_at'] == null
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
