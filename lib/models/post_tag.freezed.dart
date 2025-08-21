// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPostTag {

 String get id; String get slug; String? get name; List<SnPost> get posts; int get usage;
/// Create a copy of SnPostTag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostTagCopyWith<SnPostTag> get copyWith => _$SnPostTagCopyWithImpl<SnPostTag>(this as SnPostTag, _$identity);

  /// Serializes this SnPostTag to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPostTag&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.posts, posts)&&(identical(other.usage, usage) || other.usage == usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,const DeepCollectionEquality().hash(posts),usage);

@override
String toString() {
  return 'SnPostTag(id: $id, slug: $slug, name: $name, posts: $posts, usage: $usage)';
}


}

/// @nodoc
abstract mixin class $SnPostTagCopyWith<$Res>  {
  factory $SnPostTagCopyWith(SnPostTag value, $Res Function(SnPostTag) _then) = _$SnPostTagCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String? name, List<SnPost> posts, int usage
});




}
/// @nodoc
class _$SnPostTagCopyWithImpl<$Res>
    implements $SnPostTagCopyWith<$Res> {
  _$SnPostTagCopyWithImpl(this._self, this._then);

  final SnPostTag _self;
  final $Res Function(SnPostTag) _then;

/// Create a copy of SnPostTag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = freezed,Object? posts = null,Object? usage = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<SnPost>,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPostTag].
extension SnPostTagPatterns on SnPostTag {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPostTag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPostTag() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPostTag value)  $default,){
final _that = this;
switch (_that) {
case _SnPostTag():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPostTag value)?  $default,){
final _that = this;
switch (_that) {
case _SnPostTag() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String? name,  List<SnPost> posts,  int usage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPostTag() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.posts,_that.usage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String? name,  List<SnPost> posts,  int usage)  $default,) {final _that = this;
switch (_that) {
case _SnPostTag():
return $default(_that.id,_that.slug,_that.name,_that.posts,_that.usage);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String? name,  List<SnPost> posts,  int usage)?  $default,) {final _that = this;
switch (_that) {
case _SnPostTag() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.posts,_that.usage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPostTag implements SnPostTag {
  const _SnPostTag({required this.id, required this.slug, this.name, final  List<SnPost> posts = const [], this.usage = 0}): _posts = posts;
  factory _SnPostTag.fromJson(Map<String, dynamic> json) => _$SnPostTagFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String? name;
 final  List<SnPost> _posts;
@override@JsonKey() List<SnPost> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

@override@JsonKey() final  int usage;

/// Create a copy of SnPostTag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPostTagCopyWith<_SnPostTag> get copyWith => __$SnPostTagCopyWithImpl<_SnPostTag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPostTagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPostTag&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._posts, _posts)&&(identical(other.usage, usage) || other.usage == usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,const DeepCollectionEquality().hash(_posts),usage);

@override
String toString() {
  return 'SnPostTag(id: $id, slug: $slug, name: $name, posts: $posts, usage: $usage)';
}


}

/// @nodoc
abstract mixin class _$SnPostTagCopyWith<$Res> implements $SnPostTagCopyWith<$Res> {
  factory _$SnPostTagCopyWith(_SnPostTag value, $Res Function(_SnPostTag) _then) = __$SnPostTagCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String? name, List<SnPost> posts, int usage
});




}
/// @nodoc
class __$SnPostTagCopyWithImpl<$Res>
    implements _$SnPostTagCopyWith<$Res> {
  __$SnPostTagCopyWithImpl(this._self, this._then);

  final _SnPostTag _self;
  final $Res Function(_SnPostTag) _then;

/// Create a copy of SnPostTag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = freezed,Object? posts = null,Object? usage = null,}) {
  return _then(_SnPostTag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<SnPost>,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
