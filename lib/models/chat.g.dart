// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnChat _$SnChatFromJson(Map<String, dynamic> json) => _SnChat(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  type: (json['type'] as num).toInt(),
  isPublic: json['is_public'] as bool,
  picture:
      json['picture'] == null
          ? null
          : SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
  background:
      json['background'] == null
          ? null
          : SnCloudFile.fromJson(json['background'] as Map<String, dynamic>),
  realmId: (json['realm_id'] as num?)?.toInt(),
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
);

Map<String, dynamic> _$SnChatToJson(_SnChat instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': instance.type,
  'is_public': instance.isPublic,
  'picture': instance.picture?.toJson(),
  'background': instance.background?.toJson(),
  'realm_id': instance.realmId,
  'realm': instance.realm?.toJson(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
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
      repliedMessage:
          json['replied_message'] == null
              ? null
              : SnChatMessage.fromJson(
                json['replied_message'] as Map<String, dynamic>,
              ),
      forwardedMessageId: json['forwarded_message_id'] as String?,
      forwardedMessage:
          json['forwarded_message'] == null
              ? null
              : SnChatMessage.fromJson(
                json['forwarded_message'] as Map<String, dynamic>,
              ),
      senderId: json['sender_id'] as String,
      sender: SnChatMember.fromJson(json['sender'] as Map<String, dynamic>),
      chatRoomId: (json['chat_room_id'] as num).toInt(),
    );

Map<String, dynamic> _$SnChatMessageToJson(_SnChatMessage instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'id': instance.id,
      'content': instance.content,
      'nonce': instance.nonce,
      'meta': instance.meta,
      'members_metioned': instance.membersMetioned,
      'edited_at': instance.editedAt?.toIso8601String(),
      'attachments': instance.attachments.map((e) => e.toJson()).toList(),
      'reactions': instance.reactions.map((e) => e.toJson()).toList(),
      'replied_message_id': instance.repliedMessageId,
      'replied_message': instance.repliedMessage?.toJson(),
      'forwarded_message_id': instance.forwardedMessageId,
      'forwarded_message': instance.forwardedMessage?.toJson(),
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
      chatRoomId: (json['chat_room_id'] as num).toInt(),
      accountId: (json['account_id'] as num).toInt(),
      nick: json['nick'] as String?,
      role: (json['role'] as num).toInt(),
      notify: (json['notify'] as num).toInt(),
      joinedAt:
          json['joined_at'] == null
              ? null
              : DateTime.parse(json['joined_at'] as String),
      isBot: json['is_bot'] as bool,
    );

Map<String, dynamic> _$SnChatMemberToJson(_SnChatMember instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'id': instance.id,
      'chat_room_id': instance.chatRoomId,
      'account_id': instance.accountId,
      'nick': instance.nick,
      'role': instance.role,
      'notify': instance.notify,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'is_bot': instance.isBot,
    };
