import 'package:freezed_annotation/freezed_annotation.dart';

part 'realm_quota_info.g.dart';
part 'realm_quota_info.freezed.dart';

@freezed
sealed class RealmQuotaInfo with _$RealmQuotaInfo {
  const factory RealmQuotaInfo({
    required int total,
    required int used,
    required int remaining,
    required int level,
    required int perkLevel,
    required List<dynamic> records,
  }) = _RealmQuotaInfo;

  factory RealmQuotaInfo.fromJson(Map<String, Object?> json) =>
      _$RealmQuotaInfoFromJson(json);
}
