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
  isPublic: json['isPublic'] as bool? ?? false,
  isCommunity: json['isCommunity'] as bool? ?? false,
  picture: json['picture'] == null
      ? null
      : SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
  background: json['background'] == null
      ? null
      : SnCloudFile.fromJson(json['background'] as Map<String, dynamic>),
  realmId: json['realmId'] as String?,
  accountId: json['accountId'] as String?,
  realm: json['realm'] == null
      ? null
      : SnRealm.fromJson(json['realm'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  members: (json['members'] as List<dynamic>?)
      ?.map((e) => SnChatMember.fromJson(e as Map<String, dynamic>))
      .toList(),
  isPinned: json['isPinned'] as bool? ?? false,
);

Map<String, dynamic> _$SnChatRoomToJson(_SnChatRoom instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'isPublic': instance.isPublic,
      'isCommunity': instance.isCommunity,
      'picture': instance.picture,
      'background': instance.background,
      'realmId': instance.realmId,
      'accountId': instance.accountId,
      'realm': instance.realm,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'members': instance.members,
      'isPinned': instance.isPinned,
    };

_SnChatMessage _$SnChatMessageFromJson(Map<String, dynamic> json) =>
    _SnChatMessage(
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      id: json['id'] as String,
      type: json['type'] as String? ?? 'text',
      content: json['content'] as String?,
      nonce: json['nonce'] as String?,
      meta: json['meta'] as Map<String, dynamic>? ?? const {},
      membersMentioned:
          (json['membersMentioned'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
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
      repliedMessageId: json['repliedMessageId'] as String?,
      forwardedMessageId: json['forwardedMessageId'] as String?,
      senderId: json['senderId'] as String,
      sender: SnChatMember.fromJson(json['sender'] as Map<String, dynamic>),
      chatRoomId: json['chatRoomId'] as String,
    );

Map<String, dynamic> _$SnChatMessageToJson(_SnChatMessage instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'id': instance.id,
      'type': instance.type,
      'content': instance.content,
      'nonce': instance.nonce,
      'meta': instance.meta,
      'membersMentioned': instance.membersMentioned,
      'editedAt': instance.editedAt?.toIso8601String(),
      'attachments': instance.attachments,
      'reactions': instance.reactions,
      'repliedMessageId': instance.repliedMessageId,
      'forwardedMessageId': instance.forwardedMessageId,
      'senderId': instance.senderId,
      'sender': instance.sender,
      'chatRoomId': instance.chatRoomId,
    };

_SnChatReaction _$SnChatReactionFromJson(Map<String, dynamic> json) =>
    _SnChatReaction(
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      id: json['id'] as String,
      messageId: json['messageId'] as String,
      senderId: json['senderId'] as String,
      sender: SnChatMember.fromJson(json['sender'] as Map<String, dynamic>),
      symbol: json['symbol'] as String,
      attitude: (json['attitude'] as num).toInt(),
    );

Map<String, dynamic> _$SnChatReactionToJson(_SnChatReaction instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'id': instance.id,
      'messageId': instance.messageId,
      'senderId': instance.senderId,
      'sender': instance.sender,
      'symbol': instance.symbol,
      'attitude': instance.attitude,
    };

_SnChatMember _$SnChatMemberFromJson(Map<String, dynamic> json) =>
    _SnChatMember(
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      id: json['id'] as String,
      chatRoomId: json['chatRoomId'] as String,
      chatRoom: json['chatRoom'] == null
          ? null
          : SnChatRoom.fromJson(json['chatRoom'] as Map<String, dynamic>),
      accountId: json['accountId'] as String,
      account: SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      nick: json['nick'] as String?,
      notify: (json['notify'] as num).toInt(),
      joinedAt: json['joinedAt'] == null
          ? null
          : DateTime.parse(json['joinedAt'] as String),
      breakUntil: json['breakUntil'] == null
          ? null
          : DateTime.parse(json['breakUntil'] as String),
      timeoutUntil: json['timeoutUntil'] == null
          ? null
          : DateTime.parse(json['timeoutUntil'] as String),
      status: json['status'] == null
          ? null
          : SnAccountStatus.fromJson(json['status'] as Map<String, dynamic>),
      lastTyped: json['lastTyped'] == null
          ? null
          : DateTime.parse(json['lastTyped'] as String),
    );

Map<String, dynamic> _$SnChatMemberToJson(_SnChatMember instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'id': instance.id,
      'chatRoomId': instance.chatRoomId,
      'chatRoom': instance.chatRoom,
      'accountId': instance.accountId,
      'account': instance.account,
      'nick': instance.nick,
      'notify': instance.notify,
      'joinedAt': instance.joinedAt?.toIso8601String(),
      'breakUntil': instance.breakUntil?.toIso8601String(),
      'timeoutUntil': instance.timeoutUntil?.toIso8601String(),
      'status': instance.status,
      'lastTyped': instance.lastTyped?.toIso8601String(),
    };

_SnChatSummary _$SnChatSummaryFromJson(Map<String, dynamic> json) =>
    _SnChatSummary(
      unreadCount: (json['unreadCount'] as num).toInt(),
      lastMessage: json['lastMessage'] == null
          ? null
          : SnChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SnChatSummaryToJson(_SnChatSummary instance) =>
    <String, dynamic>{
      'unreadCount': instance.unreadCount,
      'lastMessage': instance.lastMessage,
    };

_MessageSyncResponse _$MessageSyncResponseFromJson(Map<String, dynamic> json) =>
    _MessageSyncResponse(
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => SnChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentTimestamp: DateTime.parse(json['currentTimestamp'] as String),
    );

Map<String, dynamic> _$MessageSyncResponseToJson(
  _MessageSyncResponse instance,
) => <String, dynamic>{
  'messages': instance.messages,
  'currentTimestamp': instance.currentTimestamp.toIso8601String(),
};

_ChatRealtimeJoinResponse _$ChatRealtimeJoinResponseFromJson(
  Map<String, dynamic> json,
) => _ChatRealtimeJoinResponse(
  provider: json['provider'] as String,
  endpoint: json['endpoint'] as String,
  token: json['token'] as String,
  callId: json['callId'] as String,
  roomName: json['roomName'] as String,
  isAdmin: json['isAdmin'] as bool,
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
  'callId': instance.callId,
  'roomName': instance.roomName,
  'isAdmin': instance.isAdmin,
  'participants': instance.participants,
};

_CallParticipant _$CallParticipantFromJson(Map<String, dynamic> json) =>
    _CallParticipant(
      identity: json['identity'] as String,
      name: json['name'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$CallParticipantToJson(_CallParticipant instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'name': instance.name,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };

_SnRealtimeCall _$SnRealtimeCallFromJson(Map<String, dynamic> json) =>
    _SnRealtimeCall(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      senderId: json['senderId'] as String,
      sender: SnChatMember.fromJson(json['sender'] as Map<String, dynamic>),
      roomId: json['roomId'] as String,
      room: SnChatRoom.fromJson(json['room'] as Map<String, dynamic>),
      upstreamConfig: json['upstreamConfig'] as Map<String, dynamic>,
      providerName: json['providerName'] as String?,
      sessionId: json['sessionId'] as String?,
    );

Map<String, dynamic> _$SnRealtimeCallToJson(_SnRealtimeCall instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'senderId': instance.senderId,
      'sender': instance.sender,
      'roomId': instance.roomId,
      'room': instance.room,
      'upstreamConfig': instance.upstreamConfig,
      'providerName': instance.providerName,
      'sessionId': instance.sessionId,
    };
