// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tickets.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnTicket _$SnTicketFromJson(Map<String, dynamic> json) => _SnTicket(
  id: json['id'] as String,
  title: json['title'] as String,
  content: json['content'] as String?,
  type: (json['type'] as num).toInt(),
  status: (json['status'] as num).toInt(),
  priority: (json['priority'] as num).toInt(),
  creatorId: json['creator_id'] as String,
  creator: SnAccount.fromJson(json['creator'] as Map<String, dynamic>),
  assigneeId: json['assignee_id'] as String?,
  assignee: json['assignee'] == null
      ? null
      : SnAccount.fromJson(json['assignee'] as Map<String, dynamic>),
  resolvedAt: json['resolved_at'] == null
      ? null
      : DateTime.parse(json['resolved_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => SnTicketMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  fileIds:
      (json['file_ids'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$SnTicketToJson(_SnTicket instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'type': instance.type,
  'status': instance.status,
  'priority': instance.priority,
  'creator_id': instance.creatorId,
  'creator': instance.creator.toJson(),
  'assignee_id': instance.assigneeId,
  'assignee': instance.assignee?.toJson(),
  'resolved_at': instance.resolvedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'file_ids': instance.fileIds,
};

_SnTicketMessage _$SnTicketMessageFromJson(Map<String, dynamic> json) =>
    _SnTicketMessage(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      senderId: json['sender_id'] as String,
      sender: SnAccount.fromJson(json['sender'] as Map<String, dynamic>),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      files: (json['files'] as List<dynamic>)
          .map((e) => SnCloudFileReference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SnTicketMessageToJson(_SnTicketMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticket_id': instance.ticketId,
      'sender_id': instance.senderId,
      'sender': instance.sender.toJson(),
      'content': instance.content,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'files': instance.files.map((e) => e.toJson()).toList(),
    };
