// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bot _$BotFromJson(Map<String, dynamic> json) => _Bot(
  id: json['id'] as String,
  slug: json['slug'] as String,
  isActive: json['is_active'] as bool,
  projectId: json['project_id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  account: SnAccount.fromJson(json['account'] as Map<String, dynamic>),
  developer: json['developer'] == null
      ? null
      : SnDeveloper.fromJson(json['developer'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BotToJson(_Bot instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'is_active': instance.isActive,
  'project_id': instance.projectId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'account': instance.account.toJson(),
  'developer': instance.developer?.toJson(),
};

_BotConfig _$BotConfigFromJson(Map<String, dynamic> json) => _BotConfig(
  isPublic: json['is_public'] as bool? ?? false,
  isInteractive: json['is_interactive'] as bool? ?? false,
  allowedRealms:
      (json['allowed_realms'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  allowedChatTypes:
      (json['allowed_chat_types'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$BotConfigToJson(_BotConfig instance) =>
    <String, dynamic>{
      'is_public': instance.isPublic,
      'is_interactive': instance.isInteractive,
      'allowed_realms': instance.allowedRealms,
      'allowed_chat_types': instance.allowedChatTypes,
      'metadata': instance.metadata,
    };

_BotLinks _$BotLinksFromJson(Map<String, dynamic> json) => _BotLinks(
  website: json['website'] as String?,
  documentation: json['documentation'] as String?,
  privacyPolicy: json['privacy_policy'] as String?,
  termsOfService: json['terms_of_service'] as String?,
);

Map<String, dynamic> _$BotLinksToJson(_BotLinks instance) => <String, dynamic>{
  'website': instance.website,
  'documentation': instance.documentation,
  'privacy_policy': instance.privacyPolicy,
  'terms_of_service': instance.termsOfService,
};

_BotSecret _$BotSecretFromJson(Map<String, dynamic> json) => _BotSecret(
  id: json['id'] as String? ?? '',
  secret: json['secret'] as String? ?? '',
  description: json['description'] as String?,
  expiredAt: json['expired_at'] == null
      ? null
      : DateTime.parse(json['expired_at'] as String),
  botId: json['bot_id'] as String? ?? '',
);

Map<String, dynamic> _$BotSecretToJson(_BotSecret instance) =>
    <String, dynamic>{
      'id': instance.id,
      'secret': instance.secret,
      'description': instance.description,
      'expired_at': instance.expiredAt?.toIso8601String(),
      'bot_id': instance.botId,
    };
