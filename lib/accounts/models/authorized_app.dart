import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'authorized_app.freezed.dart';
part 'authorized_app.g.dart';

@freezed
sealed class AuthorizedApp with _$AuthorizedApp {
  const factory AuthorizedApp({
    required String id,
    @Default(0) int type,
    @JsonKey(name: 'app_id') required String appId,
    @JsonKey(name: 'app_slug') String? appSlug,
    @JsonKey(name: 'app_name') String? appName,
    @JsonKey(name: 'app_description') String? appDescription,
    required SnCloudFileReference? picture,
    required SnCloudFileReference? background,
    @Default([]) List<String> scopes,
    @JsonKey(name: 'last_authorized_at') String? lastAuthorizedAt,
    @JsonKey(name: 'last_used_at') String? lastUsedAt,
  }) = _AuthorizedApp;

  factory AuthorizedApp.fromJson(Map<String, dynamic> json) =>
      _$AuthorizedAppFromJson(json);
}
