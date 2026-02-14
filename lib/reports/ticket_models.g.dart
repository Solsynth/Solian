// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnTicket _$SnTicketFromJson(Map<String, dynamic> json) => _SnTicket(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  type: (json['type'] as num).toInt(),
  status: (json['status'] as num).toInt(),
  priority: (json['priority'] as num).toInt(),
  creatorId: json['creator_id'] as String,
  assigneeId: json['assignee_id'] as String?,
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
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => SnTicketFile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SnTicketToJson(_SnTicket instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'type': instance.type,
  'status': instance.status,
  'priority': instance.priority,
  'creator_id': instance.creatorId,
  'assignee_id': instance.assigneeId,
  'resolved_at': instance.resolvedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'files': instance.files.map((e) => e.toJson()).toList(),
};

_SnTicketMessage _$SnTicketMessageFromJson(Map<String, dynamic> json) =>
    _SnTicketMessage(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnTicketMessageToJson(_SnTicketMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticket_id': instance.ticketId,
      'sender_id': instance.senderId,
      'content': instance.content,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnTicketFile _$SnTicketFileFromJson(Map<String, dynamic> json) =>
    _SnTicketFile(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      fileId: json['file_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnTicketFileToJson(_SnTicketFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticket_id': instance.ticketId,
      'file_id': instance.fileId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
