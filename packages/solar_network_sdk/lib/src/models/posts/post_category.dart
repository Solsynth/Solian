import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/src/models/posts/post.dart';
import 'package:solar_network_sdk/src/models/posts/post_tag.dart';
import 'package:solar_network_sdk/src/utils/string_utils.dart';

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

  String get categoryTranslationKey {
    final capitalizedSlug = slug.capitalizeEachWord();
    return 'postCategory$capitalizedSlug';
  }
}

@freezed
sealed class SnCategorySubscription with _$SnCategorySubscription {
  const factory SnCategorySubscription({
    required String id,
    required String accountId,
    required String? categoryId,
    required SnPostCategory? category,
    required String? tagId,
    required SnPostTag? tag,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnCategorySubscription;

  factory SnCategorySubscription.fromJson(Map<String, dynamic> json) =>
      _$SnCategorySubscriptionFromJson(json);
}
