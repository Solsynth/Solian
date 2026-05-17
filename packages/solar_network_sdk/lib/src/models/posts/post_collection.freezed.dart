// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPostCollection {

 String get id; String get slug; String? get name; String? get description;@JsonKey(name: 'publisher_id') String get publisherId; SnPublisher? get publisher; SnCloudFileReference? get background; SnCloudFileReference? get icon; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of SnPostCollection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostCollectionCopyWith<SnPostCollection> get copyWith => _$SnPostCollectionCopyWithImpl<SnPostCollection>(this as SnPostCollection, _$identity);

  /// Serializes this SnPostCollection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPostCollection&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.background, background) || other.background == background)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,publisherId,publisher,background,icon,createdAt,updatedAt);

@override
String toString() {
  return 'SnPostCollection(id: $id, slug: $slug, name: $name, description: $description, publisherId: $publisherId, publisher: $publisher, background: $background, icon: $icon, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SnPostCollectionCopyWith<$Res>  {
  factory $SnPostCollectionCopyWith(SnPostCollection value, $Res Function(SnPostCollection) _then) = _$SnPostCollectionCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String? name, String? description,@JsonKey(name: 'publisher_id') String publisherId, SnPublisher? publisher, SnCloudFileReference? background, SnCloudFileReference? icon, DateTime? createdAt, DateTime? updatedAt
});


$SnPublisherCopyWith<$Res>? get publisher;$SnCloudFileReferenceCopyWith<$Res>? get background;$SnCloudFileReferenceCopyWith<$Res>? get icon;

}
/// @nodoc
class _$SnPostCollectionCopyWithImpl<$Res>
    implements $SnPostCollectionCopyWith<$Res> {
  _$SnPostCollectionCopyWithImpl(this._self, this._then);

  final SnPostCollection _self;
  final $Res Function(SnPostCollection) _then;

/// Create a copy of SnPostCollection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = freezed,Object? description = freezed,Object? publisherId = null,Object? publisher = freezed,Object? background = freezed,Object? icon = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnPostCollection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of SnPostCollection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnPostCollection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get icon {
    if (_self.icon == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.icon!, (value) {
    return _then(_self.copyWith(icon: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPostCollection].
extension SnPostCollectionPatterns on SnPostCollection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPostCollection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPostCollection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPostCollection value)  $default,){
final _that = this;
switch (_that) {
case _SnPostCollection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPostCollection value)?  $default,){
final _that = this;
switch (_that) {
case _SnPostCollection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String? name,  String? description, @JsonKey(name: 'publisher_id')  String publisherId,  SnPublisher? publisher,  SnCloudFileReference? background,  SnCloudFileReference? icon,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPostCollection() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.publisherId,_that.publisher,_that.background,_that.icon,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String? name,  String? description, @JsonKey(name: 'publisher_id')  String publisherId,  SnPublisher? publisher,  SnCloudFileReference? background,  SnCloudFileReference? icon,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPostCollection():
return $default(_that.id,_that.slug,_that.name,_that.description,_that.publisherId,_that.publisher,_that.background,_that.icon,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String? name,  String? description, @JsonKey(name: 'publisher_id')  String publisherId,  SnPublisher? publisher,  SnCloudFileReference? background,  SnCloudFileReference? icon,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPostCollection() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.publisherId,_that.publisher,_that.background,_that.icon,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPostCollection implements SnPostCollection {
  const _SnPostCollection({required this.id, required this.slug, this.name, this.description, @JsonKey(name: 'publisher_id') required this.publisherId, this.publisher, this.background, this.icon, this.createdAt = null, this.updatedAt = null});
  factory _SnPostCollection.fromJson(Map<String, dynamic> json) => _$SnPostCollectionFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String? name;
@override final  String? description;
@override@JsonKey(name: 'publisher_id') final  String publisherId;
@override final  SnPublisher? publisher;
@override final  SnCloudFileReference? background;
@override final  SnCloudFileReference? icon;
@override@JsonKey() final  DateTime? createdAt;
@override@JsonKey() final  DateTime? updatedAt;

/// Create a copy of SnPostCollection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPostCollectionCopyWith<_SnPostCollection> get copyWith => __$SnPostCollectionCopyWithImpl<_SnPostCollection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPostCollectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPostCollection&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.background, background) || other.background == background)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,publisherId,publisher,background,icon,createdAt,updatedAt);

@override
String toString() {
  return 'SnPostCollection(id: $id, slug: $slug, name: $name, description: $description, publisherId: $publisherId, publisher: $publisher, background: $background, icon: $icon, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPostCollectionCopyWith<$Res> implements $SnPostCollectionCopyWith<$Res> {
  factory _$SnPostCollectionCopyWith(_SnPostCollection value, $Res Function(_SnPostCollection) _then) = __$SnPostCollectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String? name, String? description,@JsonKey(name: 'publisher_id') String publisherId, SnPublisher? publisher, SnCloudFileReference? background, SnCloudFileReference? icon, DateTime? createdAt, DateTime? updatedAt
});


@override $SnPublisherCopyWith<$Res>? get publisher;@override $SnCloudFileReferenceCopyWith<$Res>? get background;@override $SnCloudFileReferenceCopyWith<$Res>? get icon;

}
/// @nodoc
class __$SnPostCollectionCopyWithImpl<$Res>
    implements _$SnPostCollectionCopyWith<$Res> {
  __$SnPostCollectionCopyWithImpl(this._self, this._then);

  final _SnPostCollection _self;
  final $Res Function(_SnPostCollection) _then;

/// Create a copy of SnPostCollection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = freezed,Object? description = freezed,Object? publisherId = null,Object? publisher = freezed,Object? background = freezed,Object? icon = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_SnPostCollection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnPostCollection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}/// Create a copy of SnPostCollection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnPostCollection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get icon {
    if (_self.icon == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.icon!, (value) {
    return _then(_self.copyWith(icon: value));
  });
}
}

// dart format on
