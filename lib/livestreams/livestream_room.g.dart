// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livestream_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String? ?? '',
  senderId: json['sender_id'] as String? ?? '',
  sender: json['sender_name'] as String? ?? 'Unknown',
  senderIdentity: json['sender_identity'] as String?,
  message: json['content'] as String? ?? '',
  isMine: json['is_mine'] as bool? ?? false,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  messageType:
      $enumDecodeNullable(_$ChatMessageTypeEnumMap, json['message_type']) ??
      ChatMessageType.chat,
  metadata: json['metadata'] as Map<String, dynamic>?,
  senderAccount: json['sender'] == null
      ? null
      : SnAccount.fromJson(json['sender'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender_id': instance.senderId,
      'sender_name': instance.sender,
      'sender_identity': instance.senderIdentity,
      'content': instance.message,
      'is_mine': instance.isMine,
      'created_at': instance.createdAt?.toIso8601String(),
      'message_type': _$ChatMessageTypeEnumMap[instance.messageType]!,
      'metadata': instance.metadata,
      'sender': instance.senderAccount?.toJson(),
    };

const _$ChatMessageTypeEnumMap = {
  ChatMessageType.chat: 'chat',
  ChatMessageType.systemAward: 'systemAward',
  ChatMessageType.systemJoin: 'systemJoin',
  ChatMessageType.systemLeave: 'systemLeave',
};
