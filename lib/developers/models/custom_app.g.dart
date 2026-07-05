// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_app.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomApp _$CustomAppFromJson(Map<String, dynamic> json) => _CustomApp(
  id: json['id'] as String? ?? '',
  slug: json['slug'] as String? ?? '',
  name: json['name'] as String? ?? '',
  description: json['description'] as String?,
  status: (json['status'] as num?)?.toInt() ?? 0,
  picture: json['picture'] == null
      ? null
      : SnCloudFileReference.fromJson(json['picture'] as Map<String, dynamic>),
  background: json['background'] == null
      ? null
      : SnCloudFileReference.fromJson(
          json['background'] as Map<String, dynamic>,
        ),
  verification: json['verification'] == null
      ? null
      : SnVerificationMark.fromJson(
          json['verification'] as Map<String, dynamic>,
        ),
  oauthConfig: json['oauth_config'] == null
      ? null
      : CustomAppOauthConfig.fromJson(
          json['oauth_config'] as Map<String, dynamic>,
        ),
  links: json['links'] == null
      ? null
      : CustomAppLinks.fromJson(json['links'] as Map<String, dynamic>),
  secrets:
      (json['secrets'] as List<dynamic>?)
          ?.map((e) => CustomAppSecret.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  publisherId: json['publisher_id'] as String? ?? '',
  paymentWalletId: json['payment_wallet_id'] as String?,
);

Map<String, dynamic> _$CustomAppToJson(_CustomApp instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'picture': instance.picture?.toJson(),
      'background': instance.background?.toJson(),
      'verification': instance.verification?.toJson(),
      'oauth_config': instance.oauthConfig?.toJson(),
      'links': instance.links?.toJson(),
      'secrets': instance.secrets.map((e) => e.toJson()).toList(),
      'publisher_id': instance.publisherId,
      'payment_wallet_id': instance.paymentWalletId,
    };

_CustomAppLinks _$CustomAppLinksFromJson(Map<String, dynamic> json) =>
    _CustomAppLinks(
      homePage: json['home_page'] as String?,
      privacyPolicy: json['privacy_policy'] as String?,
      termsOfService: json['terms_of_service'] as String?,
    );

Map<String, dynamic> _$CustomAppLinksToJson(_CustomAppLinks instance) =>
    <String, dynamic>{
      'home_page': instance.homePage,
      'privacy_policy': instance.privacyPolicy,
      'terms_of_service': instance.termsOfService,
    };

_CustomAppOauthConfig _$CustomAppOauthConfigFromJson(
  Map<String, dynamic> json,
) => _CustomAppOauthConfig(
  clientUri: json['client_uri'] as String?,
  redirectUris:
      (json['redirect_uris'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  postLogoutRedirectUris: (json['post_logout_redirect_uris'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  allowedScopes:
      (json['allowed_scopes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['openid', 'profile', 'email'],
  allowedGrantTypes:
      (json['allowed_grant_types'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const ['authorization_code', 'refresh_token'],
  requirePkce: json['require_pkce'] as bool? ?? true,
  allowOfflineAccess: json['allow_offline_access'] as bool? ?? false,
  isPublicClient: json['is_public_client'] as bool? ?? false,
);

Map<String, dynamic> _$CustomAppOauthConfigToJson(
  _CustomAppOauthConfig instance,
) => <String, dynamic>{
  'client_uri': instance.clientUri,
  'redirect_uris': instance.redirectUris,
  'post_logout_redirect_uris': instance.postLogoutRedirectUris,
  'allowed_scopes': instance.allowedScopes,
  'allowed_grant_types': instance.allowedGrantTypes,
  'require_pkce': instance.requirePkce,
  'allow_offline_access': instance.allowOfflineAccess,
  'is_public_client': instance.isPublicClient,
};

_CustomAppSecret _$CustomAppSecretFromJson(Map<String, dynamic> json) =>
    _CustomAppSecret(
      id: json['id'] as String? ?? '',
      secret: json['secret'] as String?,
      description: json['description'] as String?,
      expiredAt: json['expired_at'] == null
          ? null
          : DateTime.parse(json['expired_at'] as String),
      isOidc: json['is_oidc'] as bool? ?? false,
      appId: json['app_id'] as String? ?? '',
    );

Map<String, dynamic> _$CustomAppSecretToJson(_CustomAppSecret instance) =>
    <String, dynamic>{
      'id': instance.id,
      'secret': instance.secret,
      'description': instance.description,
      'expired_at': instance.expiredAt?.toIso8601String(),
      'is_oidc': instance.isOidc,
      'app_id': instance.appId,
    };
