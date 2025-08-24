import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_app_secret.freezed.dart';
part 'custom_app_secret.g.dart';

@freezed
sealed class CustomAppSecret with _$CustomAppSecret {
  const factory CustomAppSecret({
    required String id,
    required String? secret,
    required DateTime createdAt,
    String? description,
    int? expiresIn,
    bool? isOidc,
  }) = _CustomAppSecret;

  factory CustomAppSecret.fromJson(Map<String, dynamic> json) =>
      _$CustomAppSecretFromJson(json);
}
