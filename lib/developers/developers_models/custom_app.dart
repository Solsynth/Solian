import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/drive/drive_models/file.dart';
import 'package:island/accounts/accounts_models/account.dart';

part 'custom_app.freezed.dart';
part 'custom_app.g.dart';

@freezed
sealed class CustomApp with _$CustomApp {
  const factory CustomApp({
    @Default('') String id,
    @Default('') String slug,
    @Default('') String name,
    String? description,
    @Default(0) int status,
    SnCloudFile? picture,
    SnCloudFile? background,
    SnVerificationMark? verification,
    CustomAppOauthConfig? oauthConfig,
    CustomAppLinks? links,
    @Default([]) List<CustomAppSecret> secrets,
    @Default('') String publisherId,
  }) = _CustomApp;

  factory CustomApp.fromJson(Map<String, dynamic> json) =>
      _$CustomAppFromJson(json);
}

@freezed
sealed class CustomAppLinks with _$CustomAppLinks {
  const factory CustomAppLinks({
    String? homePage,
    String? privacyPolicy,
    String? termsOfService,
  }) = _CustomAppLinks;

  factory CustomAppLinks.fromJson(Map<String, dynamic> json) =>
      _$CustomAppLinksFromJson(json);
}

@freezed
sealed class CustomAppOauthConfig with _$CustomAppOauthConfig {
  const factory CustomAppOauthConfig({
    String? clientUri,
    @Default([]) List<String> redirectUris,
    List<String>? postLogoutRedirectUris,
    @Default(['openid', 'profile', 'email']) List<String> allowedScopes,
    @Default(['authorization_code', 'refresh_token'])
    List<String> allowedGrantTypes,
    @Default(true) bool requirePkce,
    @Default(false) bool allowOfflineAccess,
  }) = _CustomAppOauthConfig;

  factory CustomAppOauthConfig.fromJson(Map<String, dynamic> json) =>
      _$CustomAppOauthConfigFromJson(json);
}

@freezed
sealed class CustomAppSecret with _$CustomAppSecret {
  const factory CustomAppSecret({
    @Default('') String id,
    @Default('') String secret,
    String? description,
    DateTime? expiredAt,
    @Default(false) bool isOidc,
    @Default('') String appId,
  }) = _CustomAppSecret;

  factory CustomAppSecret.fromJson(Map<String, dynamic> json) =>
      _$CustomAppSecretFromJson(json);
}
