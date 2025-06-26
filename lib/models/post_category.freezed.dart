// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostCategory {

 String get id; String get slug; String? get name; List<SnPost> get posts;
/// Create a copy of PostCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCategoryCopyWith<PostCategory> get copyWith => _$PostCategoryCopyWithImpl<PostCategory>(this as PostCategory, _$identity);

  /// Serializes this PostCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.posts, posts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,const DeepCollectionEquality().hash(posts));

@override
String toString() {
  return 'PostCategory(id: $id, slug: $slug, name: $name, posts: $posts)';
}


}

/// @nodoc
abstract mixin class $PostCategoryCopyWith<$Res>  {
  factory $PostCategoryCopyWith(PostCategory value, $Res Function(PostCategory) _then) = _$PostCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String? name, List<SnPost> posts
});




}
/// @nodoc
class _$PostCategoryCopyWithImpl<$Res>
    implements $PostCategoryCopyWith<$Res> {
  _$PostCategoryCopyWithImpl(this._self, this._then);

  final PostCategory _self;
  final $Res Function(PostCategory) _then;

/// Create a copy of PostCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = freezed,Object? posts = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<SnPost>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _PostCategory implements PostCategory {
  const _PostCategory({required this.id, required this.slug, this.name, final  List<SnPost> posts = const []}): _posts = posts;
  factory _PostCategory.fromJson(Map<String, dynamic> json) => _$PostCategoryFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String? name;
 final  List<SnPost> _posts;
@override@JsonKey() List<SnPost> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}


/// Create a copy of PostCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCategoryCopyWith<_PostCategory> get copyWith => __$PostCategoryCopyWithImpl<_PostCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._posts, _posts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,const DeepCollectionEquality().hash(_posts));

@override
String toString() {
  return 'PostCategory(id: $id, slug: $slug, name: $name, posts: $posts)';
}


}

/// @nodoc
abstract mixin class _$PostCategoryCopyWith<$Res> implements $PostCategoryCopyWith<$Res> {
  factory _$PostCategoryCopyWith(_PostCategory value, $Res Function(_PostCategory) _then) = __$PostCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String? name, List<SnPost> posts
});




}
/// @nodoc
class __$PostCategoryCopyWithImpl<$Res>
    implements _$PostCategoryCopyWith<$Res> {
  __$PostCategoryCopyWithImpl(this._self, this._then);

  final _PostCategory _self;
  final $Res Function(_PostCategory) _then;

/// Create a copy of PostCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = freezed,Object? posts = null,}) {
  return _then(_PostCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<SnPost>,
  ));
}


}

// dart format on
