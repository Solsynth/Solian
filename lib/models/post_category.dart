import 'package:easy_localization/easy_localization.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/post.dart';
import 'package:island/utils/text.dart';

part 'post_category.freezed.dart';
part 'post_category.g.dart';

@freezed
sealed class SnPostCategory with _$SnPostCategory {
  const SnPostCategory._();

  const factory SnPostCategory({
    required String id,
    required String slug,
    String? name,
    @Default([]) List<SnPost> posts,
    @Default(0) int usage,
  }) = _SnPostCategory;

  factory SnPostCategory.fromJson(Map<String, dynamic> json) =>
      _$SnPostCategoryFromJson(json);

  String get categoryDisplayTitle {
    final capitalizedSlug = slug.capitalizeEachWord();
    if ('postCategory$capitalizedSlug'.trExists()) {
      return 'postCategory$capitalizedSlug'.tr();
    }
    return name ?? slug;
  }
}
