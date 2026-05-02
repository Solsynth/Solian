import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_quota.freezed.dart';
part 'tag_quota.g.dart';

/// Represents a protected tag in the quota response.
@freezed
sealed class SnProtectedTagRecord with _$SnProtectedTagRecord {
  const factory SnProtectedTagRecord({
    required String id,
    required String slug,
    String? name,
  }) = _SnProtectedTagRecord;

  factory SnProtectedTagRecord.fromJson(Map<String, dynamic> json) =>
      _$SnProtectedTagRecordFromJson(json);
}

/// Represents the protected tag quota for a publisher.
@freezed
sealed class SnTagQuota with _$SnTagQuota {
  const factory SnTagQuota({
    required int total,
    required int used,
    required int remaining,
    required int level,
    @JsonKey(name: 'perk_level') required int perkLevel,
    required List<SnProtectedTagRecord> records,
  }) = _SnTagQuota;

  factory SnTagQuota.fromJson(Map<String, dynamic> json) =>
      _$SnTagQuotaFromJson(json);
}
