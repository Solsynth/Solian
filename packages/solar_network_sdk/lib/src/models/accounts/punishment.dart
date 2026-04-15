import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'punishment.freezed.dart';
part 'punishment.g.dart';

enum PunishmentType {
  permissionModification(0),
  blockLogin(1),
  disableAccount(2),
  strike(3);

  const PunishmentType(this.value);
  final int value;

  static PunishmentType fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }
}

class PunishmentTypeConverter implements JsonConverter<PunishmentType, int> {
  const PunishmentTypeConverter();

  @override
  PunishmentType fromJson(int json) => PunishmentType.fromValue(json);

  @override
  int toJson(PunishmentType object) => object.value;
}

@freezed
sealed class SnAccountPunishment with _$SnAccountPunishment {
  const factory SnAccountPunishment({
    required String id,
    required String reason,
    @JsonKey(name: 'expired_at') DateTime? expiredAt,
    @PunishmentTypeConverter() required PunishmentType type,
    @JsonKey(name: 'blocked_permissions') List<String>? blockedPermissions,
    @JsonKey(name: 'account_id') required String accountId,
    SnAccount? account,
    @JsonKey(name: 'creator_id') String? creatorId,
    SnAccount? creator,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _SnAccountPunishment;

  factory SnAccountPunishment.fromJson(Map<String, dynamic> json) =>
      _$SnAccountPunishmentFromJson(json);
}
