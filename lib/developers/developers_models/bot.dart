import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/developers/developers_models/developer.dart';

part 'bot.freezed.dart';
part 'bot.g.dart';

@freezed
sealed class Bot with _$Bot {
  const factory Bot({
    required String id,
    required String slug,
    required bool isActive,
    required String projectId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required SnAccount account,
    SnDeveloper? developer,
  }) = _Bot;

  factory Bot.fromJson(Map<String, dynamic> json) => _$BotFromJson(json);
}

@freezed
sealed class BotConfig with _$BotConfig {
  const factory BotConfig({
    @Default(false) bool isPublic,
    @Default(false) bool isInteractive,
    @Default([]) List<String> allowedRealms,
    @Default([]) List<String> allowedChatTypes,
    @Default({}) Map<String, dynamic> metadata,
  }) = _BotConfig;

  factory BotConfig.fromJson(Map<String, dynamic> json) =>
      _$BotConfigFromJson(json);
}

@freezed
sealed class BotLinks with _$BotLinks {
  const factory BotLinks({
    String? website,
    String? documentation,
    String? privacyPolicy,
    String? termsOfService,
  }) = _BotLinks;

  factory BotLinks.fromJson(Map<String, dynamic> json) =>
      _$BotLinksFromJson(json);
}

@freezed
sealed class BotSecret with _$BotSecret {
  const factory BotSecret({
    @Default('') String id,
    @Default('') String secret,
    String? description,
    DateTime? expiredAt,
    @Default('') String botId,
  }) = _BotSecret;

  factory BotSecret.fromJson(Map<String, dynamic> json) =>
      _$BotSecretFromJson(json);
}
