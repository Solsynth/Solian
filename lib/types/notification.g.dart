// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnNotification _$SnNotificationFromJson(Map<String, dynamic> json) =>
    _SnNotification(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      topic: json['topic'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      body: json['body'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      priority: (json['priority'] as num).toInt(),
      senderId: (json['sender_id'] as num?)?.toInt(),
      accountId: (json['account_id'] as num).toInt(),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
    );

Map<String, dynamic> _$SnNotificationToJson(_SnNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'topic': instance.topic,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'body': instance.body,
      'metadata': instance.metadata,
      'priority': instance.priority,
      'sender_id': instance.senderId,
      'account_id': instance.accountId,
      'read_at': instance.readAt?.toIso8601String(),
    };
