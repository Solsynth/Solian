import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'realm_overview.freezed.dart';
part 'realm_overview.g.dart';

@freezed
sealed class RealmBoostStatus with _$RealmBoostStatus {
  const factory RealmBoostStatus({
    required int boostPoints,
    required int boostLevel,
    required int labelCap,
    required int expiresAfterDays,
    required List<String> supportedCurrencies,
    required String defaultCurrency,
  }) = _RealmBoostStatus;

  factory RealmBoostStatus.fromJson(Map<String, dynamic> json) =>
      _$RealmBoostStatusFromJson(json);
}

@freezed
sealed class RealmBoostLeaderboardEntry with _$RealmBoostLeaderboardEntry {
  const factory RealmBoostLeaderboardEntry({
    required String accountId,
    required SnAccount? account,
    required double amountGolds,
    required double amountPoints,
    required double shares,
    required int boosts,
    required DateTime? lastBoostedAt,
  }) = _RealmBoostLeaderboardEntry;

  factory RealmBoostLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$RealmBoostLeaderboardEntryFromJson(json);
}

@freezed
sealed class RealmLabel with _$RealmLabel {
  const factory RealmLabel({
    required String id,
    required String realmId,
    required String name,
    required String? description,
    required String? color,
    required String? icon,
    required String createdByAccountId,
  }) = _RealmLabel;

  factory RealmLabel.fromJson(Map<String, dynamic> json) =>
      _$RealmLabelFromJson(json);
}
