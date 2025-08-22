// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bot _$BotFromJson(Map<String, dynamic> json) => _Bot(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  slug: json['slug'] as String? ?? '',
  description: json['description'] as String?,
  status: (json['status'] as num?)?.toInt() ?? 0,
  picture:
      json['picture'] == null
          ? null
          : SnCloudFile.fromJson(json['picture'] as Map<String, dynamic>),
  background:
      json['background'] == null
          ? null
          : SnCloudFile.fromJson(json['background'] as Map<String, dynamic>),
  verification:
      json['verification'] == null
          ? null
          : SnVerificationMark.fromJson(
            json['verification'] as Map<String, dynamic>,
          ),
  config:
      json['config'] == null
          ? null
          : BotConfig.fromJson(json['config'] as Map<String, dynamic>),
  links:
      json['links'] == null
          ? null
          : BotLinks.fromJson(json['links'] as Map<String, dynamic>),
  publisherId: json['publisher_id'] as String? ?? '',
  appId: json['app_id'] as String? ?? '',
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$BotToJson(_Bot instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'status': instance.status,
  'picture': instance.picture?.toJson(),
  'background': instance.background?.toJson(),
  'verification': instance.verification?.toJson(),
  'config': instance.config?.toJson(),
  'links': instance.links?.toJson(),
  'publisher_id': instance.publisherId,
  'app_id': instance.appId,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
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
  expiredAt:
      json['expired_at'] == null
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
