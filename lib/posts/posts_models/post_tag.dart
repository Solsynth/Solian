import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/posts/posts_models/post.dart';

part 'post_tag.freezed.dart';
part 'post_tag.g.dart';

@freezed
sealed class SnPostTag with _$SnPostTag {
  const factory SnPostTag({
    required String id,
    required String slug,
    String? name,
    @Default([]) List<SnPost> posts,
    @Default(0) int usage,
  }) = _SnPostTag;

  factory SnPostTag.fromJson(Map<String, dynamic> json) =>
      _$SnPostTagFromJson(json);
}
