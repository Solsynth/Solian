// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_app_secret.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomAppSecret _$CustomAppSecretFromJson(Map<String, dynamic> json) =>
    _CustomAppSecret(
      id: json['id'] as String,
      secret: json['secret'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$CustomAppSecretToJson(_CustomAppSecret instance) =>
    <String, dynamic>{
      'id': instance.id,
      'secret': instance.secret,
      'created_at': instance.createdAt.toIso8601String(),
      'description': instance.description,
    };
