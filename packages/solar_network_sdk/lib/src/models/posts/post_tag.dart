import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/src/models/posts/post.dart';

part 'post_tag.freezed.dart';
part 'post_tag.g.dart';

/// Represents a post tag with ownership, protection, and event lifecycle.
@freezed
sealed class SnPostTag with _$SnPostTag {
  const factory SnPostTag({
    required String id,
    required String slug,
    String? name,
    String? description,
    @JsonKey(name: 'owner_publisher_id') String? ownerPublisherId,
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
}
