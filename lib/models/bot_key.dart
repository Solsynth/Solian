import 'package:freezed_annotation/freezed_annotation.dart';

part 'bot_key.freezed.dart';
part 'bot_key.g.dart';

@freezed
sealed class SnAccountApiKey with _$SnAccountApiKey {
  const factory SnAccountApiKey({
    required String id,
    required String label,
    required String accountId,
    required String sessionId,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? key,
  }) = _SnAccountApiKey;

  factory SnAccountApiKey.fromJson(Map<String, dynamic> json) =>
      _$SnAccountApiKeyFromJson(json);
}
