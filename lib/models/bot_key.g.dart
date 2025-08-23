// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnAccountApiKey _$SnAccountApiKeyFromJson(Map<String, dynamic> json) =>
    _SnAccountApiKey(
      id: json['id'] as String,
      label: json['label'] as String,
      accountId: json['account_id'] as String,
      sessionId: json['session_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      key: json['key'] as String?,
    );

Map<String, dynamic> _$SnAccountApiKeyToJson(_SnAccountApiKey instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'account_id': instance.accountId,
      'session_id': instance.sessionId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'key': instance.key,
    };
