import 'package:freezed_annotation/freezed_annotation.dart';

part 'publisher_rating_record.freezed.dart';
part 'publisher_rating_record.g.dart';

enum SnPublisherRatingStatus {
  @JsonValue(0)
  active,
  @JsonValue(1)
  expired,
}

@freezed
sealed class SnPublisherRatingRecord with _$SnPublisherRatingRecord {
  const factory SnPublisherRatingRecord({
    required String id,
    @JsonKey(name: 'reason_type') required String reasonType,
    required String reason,
    required double delta,
    required SnPublisherRatingStatus status,
    @JsonKey(name: 'expired_at') DateTime? expiredAt,
    @JsonKey(name: 'publisher_id') required String publisherId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _SnPublisherRatingRecord;

  factory SnPublisherRatingRecord.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherRatingRecordFromJson(json);
}
