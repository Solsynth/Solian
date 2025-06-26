
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/post.dart';

part 'post_category.freezed.dart';
part 'post_category.g.dart';

@freezed
sealed class PostCategory with _$PostCategory {
  const factory PostCategory({
    required String id,
    required String slug,
    String? name,
    @Default([]) List<SnPost> posts,
  }) = _PostCategory;

  factory PostCategory.fromJson(Map<String, dynamic> json) =>
      _$PostCategoryFromJson(json);
}
