// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnPostCategory _$SnPostCategoryFromJson(Map<String, dynamic> json) =>
    _SnPostCategory(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String?,
      posts:
          (json['posts'] as List<dynamic>?)
              ?.map((e) => SnPost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      usage: (json['usage'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SnPostCategoryToJson(_SnPostCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'posts': instance.posts.map((e) => e.toJson()).toList(),
      'usage': instance.usage,
    };

_SnCategorySubscription _$SnCategorySubscriptionFromJson(
  Map<String, dynamic> json,
) => _SnCategorySubscription(
  id: json['id'] as String,
  accountId: json['account_id'] as String,
  categoryId: json['category_id'] as String?,
  category: json['category'] == null
      ? null
      : SnPostCategory.fromJson(json['category'] as Map<String, dynamic>),
  tagId: json['tag_id'] as String?,
  tag: json['tag'] == null
      ? null
      : SnPostTag.fromJson(json['tag'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnCategorySubscriptionToJson(
  _SnCategorySubscription instance,
) => <String, dynamic>{
  'id': instance.id,
  'account_id': instance.accountId,
  'category_id': instance.categoryId,
  'category': instance.category?.toJson(),
  'tag_id': instance.tagId,
  'tag': instance.tag?.toJson(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
