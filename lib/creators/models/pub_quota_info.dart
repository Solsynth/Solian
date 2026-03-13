import 'package:freezed_annotation/freezed_annotation.dart';

part 'pub_quota_info.g.dart';
part 'pub_quota_info.freezed.dart';

@freezed
sealed class PublisherQuotaInfo with _$PublisherQuotaInfo {
  const factory PublisherQuotaInfo({
    required int total,
    required int used,
    required int remaining,
    required int level,
    required int perkLevel,
    required List<dynamic> records,
  }) = _PublisherQuotaInfo;

  factory PublisherQuotaInfo.fromJson(Map<String, Object?> json) =>
      _$PublisherQuotaInfoFromJson(json);
}
