// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPostCategory {

 String get id; String get slug; String? get name; List<SnPost> get posts; int get usage;
/// Create a copy of SnPostCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostCategoryCopyWith<SnPostCategory> get copyWith => _$SnPostCategoryCopyWithImpl<SnPostCategory>(this as SnPostCategory, _$identity);

  /// Serializes this SnPostCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPostCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.posts, posts)&&(identical(other.usage, usage) || other.usage == usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,const DeepCollectionEquality().hash(posts),usage);

@override
String toString() {
  return 'SnPostCategory(id: $id, slug: $slug, name: $name, posts: $posts, usage: $usage)';
}


}

/// @nodoc
abstract mixin class $SnPostCategoryCopyWith<$Res>  {
  factory $SnPostCategoryCopyWith(SnPostCategory value, $Res Function(SnPostCategory) _then) = _$SnPostCategoryCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String? name, List<SnPost> posts, int usage
});




}
/// @nodoc
class _$SnPostCategoryCopyWithImpl<$Res>
    implements $SnPostCategoryCopyWith<$Res> {
  _$SnPostCategoryCopyWithImpl(this._self, this._then);

  final SnPostCategory _self;
  final $Res Function(SnPostCategory) _then;

/// Create a copy of SnPostCategory
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


/// Adds pattern-matching-related methods to [SnPostCategory].
extension SnPostCategoryPatterns on SnPostCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPostCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPostCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPostCategory value)  $default,){
final _that = this;
switch (_that) {
case _SnPostCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPostCategory value)?  $default,){
final _that = this;
switch (_that) {
case _SnPostCategory() when $default != null:
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
case _SnPostCategory() when $default != null:
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
case _SnPostCategory():
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
case _SnPostCategory() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.posts,_that.usage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPostCategory extends SnPostCategory {
  const _SnPostCategory({required this.id, required this.slug, this.name, final  List<SnPost> posts = const [], this.usage = 0}): _posts = posts,super._();
  factory _SnPostCategory.fromJson(Map<String, dynamic> json) => _$SnPostCategoryFromJson(json);

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

/// Create a copy of SnPostCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPostCategoryCopyWith<_SnPostCategory> get copyWith => __$SnPostCategoryCopyWithImpl<_SnPostCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPostCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPostCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._posts, _posts)&&(identical(other.usage, usage) || other.usage == usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,const DeepCollectionEquality().hash(_posts),usage);

@override
String toString() {
  return 'SnPostCategory(id: $id, slug: $slug, name: $name, posts: $posts, usage: $usage)';
}


}

/// @nodoc
abstract mixin class _$SnPostCategoryCopyWith<$Res> implements $SnPostCategoryCopyWith<$Res> {
  factory _$SnPostCategoryCopyWith(_SnPostCategory value, $Res Function(_SnPostCategory) _then) = __$SnPostCategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String? name, List<SnPost> posts, int usage
});




}
/// @nodoc
class __$SnPostCategoryCopyWithImpl<$Res>
    implements _$SnPostCategoryCopyWith<$Res> {
  __$SnPostCategoryCopyWithImpl(this._self, this._then);

  final _SnPostCategory _self;
  final $Res Function(_SnPostCategory) _then;

/// Create a copy of SnPostCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = freezed,Object? posts = null,Object? usage = null,}) {
  return _then(_SnPostCategory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<SnPost>,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SnCategorySubscription {

 String get id; String get accountId; String? get categoryId; SnPostCategory? get category; String? get tagId; SnPostTag? get tag; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnCategorySubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnCategorySubscriptionCopyWith<SnCategorySubscription> get copyWith => _$SnCategorySubscriptionCopyWithImpl<SnCategorySubscription>(this as SnCategorySubscription, _$identity);

  /// Serializes this SnCategorySubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnCategorySubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.category, category) || other.category == category)&&(identical(other.tagId, tagId) || other.tagId == tagId)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,categoryId,category,tagId,tag,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnCategorySubscription(id: $id, accountId: $accountId, categoryId: $categoryId, category: $category, tagId: $tagId, tag: $tag, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnCategorySubscriptionCopyWith<$Res>  {
  factory $SnCategorySubscriptionCopyWith(SnCategorySubscription value, $Res Function(SnCategorySubscription) _then) = _$SnCategorySubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, String? categoryId, SnPostCategory? category, String? tagId, SnPostTag? tag, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnPostCategoryCopyWith<$Res>? get category;$SnPostTagCopyWith<$Res>? get tag;

}
/// @nodoc
class _$SnCategorySubscriptionCopyWithImpl<$Res>
    implements $SnCategorySubscriptionCopyWith<$Res> {
  _$SnCategorySubscriptionCopyWithImpl(this._self, this._then);

  final SnCategorySubscription _self;
  final $Res Function(SnCategorySubscription) _then;

/// Create a copy of SnCategorySubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? categoryId = freezed,Object? category = freezed,Object? tagId = freezed,Object? tag = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SnPostCategory?,tagId: freezed == tagId ? _self.tagId : tagId // ignore: cast_nullable_to_non_nullable
as String?,tag: freezed == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as SnPostTag?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnCategorySubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $SnPostCategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of SnCategorySubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostTagCopyWith<$Res>? get tag {
    if (_self.tag == null) {
    return null;
  }

  return $SnPostTagCopyWith<$Res>(_self.tag!, (value) {
    return _then(_self.copyWith(tag: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnCategorySubscription].
extension SnCategorySubscriptionPatterns on SnCategorySubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnCategorySubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnCategorySubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnCategorySubscription value)  $default,){
final _that = this;
switch (_that) {
case _SnCategorySubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnCategorySubscription value)?  $default,){
final _that = this;
switch (_that) {
case _SnCategorySubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  String? categoryId,  SnPostCategory? category,  String? tagId,  SnPostTag? tag,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnCategorySubscription() when $default != null:
return $default(_that.id,_that.accountId,_that.categoryId,_that.category,_that.tagId,_that.tag,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  String? categoryId,  SnPostCategory? category,  String? tagId,  SnPostTag? tag,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnCategorySubscription():
return $default(_that.id,_that.accountId,_that.categoryId,_that.category,_that.tagId,_that.tag,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  String? categoryId,  SnPostCategory? category,  String? tagId,  SnPostTag? tag,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnCategorySubscription() when $default != null:
return $default(_that.id,_that.accountId,_that.categoryId,_that.category,_that.tagId,_that.tag,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnCategorySubscription implements SnCategorySubscription {
  const _SnCategorySubscription({required this.id, required this.accountId, required this.categoryId, required this.category, required this.tagId, required this.tag, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnCategorySubscription.fromJson(Map<String, dynamic> json) => _$SnCategorySubscriptionFromJson(json);

@override final  String id;
@override final  String accountId;
@override final  String? categoryId;
@override final  SnPostCategory? category;
@override final  String? tagId;
@override final  SnPostTag? tag;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnCategorySubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnCategorySubscriptionCopyWith<_SnCategorySubscription> get copyWith => __$SnCategorySubscriptionCopyWithImpl<_SnCategorySubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnCategorySubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnCategorySubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.category, category) || other.category == category)&&(identical(other.tagId, tagId) || other.tagId == tagId)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,categoryId,category,tagId,tag,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnCategorySubscription(id: $id, accountId: $accountId, categoryId: $categoryId, category: $category, tagId: $tagId, tag: $tag, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnCategorySubscriptionCopyWith<$Res> implements $SnCategorySubscriptionCopyWith<$Res> {
  factory _$SnCategorySubscriptionCopyWith(_SnCategorySubscription value, $Res Function(_SnCategorySubscription) _then) = __$SnCategorySubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, String? categoryId, SnPostCategory? category, String? tagId, SnPostTag? tag, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnPostCategoryCopyWith<$Res>? get category;@override $SnPostTagCopyWith<$Res>? get tag;

}
/// @nodoc
class __$SnCategorySubscriptionCopyWithImpl<$Res>
    implements _$SnCategorySubscriptionCopyWith<$Res> {
  __$SnCategorySubscriptionCopyWithImpl(this._self, this._then);

  final _SnCategorySubscription _self;
  final $Res Function(_SnCategorySubscription) _then;

/// Create a copy of SnCategorySubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? categoryId = freezed,Object? category = freezed,Object? tagId = freezed,Object? tag = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnCategorySubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SnPostCategory?,tagId: freezed == tagId ? _self.tagId : tagId // ignore: cast_nullable_to_non_nullable
as String?,tag: freezed == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as SnPostTag?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnCategorySubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostCategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $SnPostCategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of SnCategorySubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPostTagCopyWith<$Res>? get tag {
    if (_self.tag == null) {
    return null;
  }

  return $SnPostTagCopyWith<$Res>(_self.tag!, (value) {
    return _then(_self.copyWith(tag: value));
  });
}
}

// dart format on
