import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/src/models/posts/post.dart';
import 'package:solar_network_sdk/src/models/posts/publisher.dart';

part 'post_tag.freezed.dart';
part 'post_tag.g.dart';

/// Represents a post tag with ownership, protection, and event lifecycle.
@freezed
sealed class SnPostTag with _$SnPostTag {
  const SnPostTag._();

  const factory SnPostTag({
    required String id,
    required String slug,
    String? name,
    String? description,
    @JsonKey(name: 'owner_publisher_id') String? ownerPublisherId,
    @JsonKey(name: 'owner_publisher') SnPublisher? ownerPublisher,
    @JsonKey(name: 'is_protected') @Default(false) bool isProtected,
    @JsonKey(name: 'is_event') @Default(false) bool isEvent,
    @JsonKey(name: 'event_ends_at') DateTime? eventEndsAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @Default([]) List<SnPost> posts,
    @Default(0) int usage,
  }) = _SnPostTag;

  factory SnPostTag.fromJson(Map<String, dynamic> json) =>
      _$SnPostTagFromJson(json);

  /// Whether this tag has no owner and can be claimed.
  bool get isUnclaimed => ownerPublisherId == null;

  /// Whether the event tag has already expired.
  bool get isEventExpired =>
      isEvent &&
      eventEndsAt != null &&
      !eventEndsAt!.isAfter(DateTime.now().toUtc());

  /// Display label preferring name, then slug with hash.
  String get displayName => name?.isNotEmpty == true ? name! : '#$slug';
}
