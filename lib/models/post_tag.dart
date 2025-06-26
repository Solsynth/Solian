
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/post.dart';

part 'post_tag.freezed.dart';
part 'post_tag.g.dart';

@freezed
sealed class PostTag with _$PostTag {
  const factory PostTag({
    required String id,
    required String slug,
    String? name,
    @Default([]) List<SnPost> posts,
  }) = _PostTag;

  factory PostTag.fromJson(Map<String, dynamic> json) =>
      _$PostTagFromJson(json);
}
