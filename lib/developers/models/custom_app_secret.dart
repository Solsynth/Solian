import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_app_secret.freezed.dart';
part 'custom_app_secret.g.dart';

@freezed
sealed class CustomAppSecret with _$CustomAppSecret {
  const factory CustomAppSecret({
    @Default('') String id,
    String? secret,
    DateTime? createdAt,
    String? description,
    int? expiresIn,
    @Default(false) bool isOidc,
  }) = _CustomAppSecret;

  factory CustomAppSecret.fromJson(Map<String, dynamic> json) =>
      _$CustomAppSecretFromJson(json);
}
