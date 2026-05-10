// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sticker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnSticker {

 String get id; String get slug; String? get name; SnCloudFile get image; int get order;@JsonKey(fromJson: _stickerSizeFromJson) int get size;@JsonKey(fromJson: _stickerModeFromJson) int get mode; String get packId; SnStickerPack? get pack; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnSticker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnStickerCopyWith<SnSticker> get copyWith => _$SnStickerCopyWithImpl<SnSticker>(this as SnSticker, _$identity);

  /// Serializes this SnSticker to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnSticker&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.image, image) || other.image == image)&&(identical(other.order, order) || other.order == order)&&(identical(other.size, size) || other.size == size)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.pack, pack) || other.pack == pack)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,image,order,size,mode,packId,pack,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnSticker(id: $id, slug: $slug, name: $name, image: $image, order: $order, size: $size, mode: $mode, packId: $packId, pack: $pack, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnStickerCopyWith<$Res>  {
  factory $SnStickerCopyWith(SnSticker value, $Res Function(SnSticker) _then) = _$SnStickerCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String? name, SnCloudFile image, int order,@JsonKey(fromJson: _stickerSizeFromJson) int size,@JsonKey(fromJson: _stickerModeFromJson) int mode, String packId, SnStickerPack? pack, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnCloudFileCopyWith<$Res> get image;$SnStickerPackCopyWith<$Res>? get pack;

}
/// @nodoc
class _$SnStickerCopyWithImpl<$Res>
    implements $SnStickerCopyWith<$Res> {
  _$SnStickerCopyWithImpl(this._self, this._then);

  final SnSticker _self;
  final $Res Function(SnSticker) _then;

/// Create a copy of SnSticker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = freezed,Object? image = null,Object? order = null,Object? size = null,Object? mode = null,Object? packId = null,Object? pack = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as SnCloudFile,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as int,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,pack: freezed == pack ? _self.pack : pack // ignore: cast_nullable_to_non_nullable
as SnStickerPack?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnSticker
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res> get image {
  
  return $SnCloudFileCopyWith<$Res>(_self.image, (value) {
    return _then(_self.copyWith(image: value));
  });
}/// Create a copy of SnSticker
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnStickerPackCopyWith<$Res>? get pack {
    if (_self.pack == null) {
    return null;
  }

  return $SnStickerPackCopyWith<$Res>(_self.pack!, (value) {
    return _then(_self.copyWith(pack: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnSticker].
extension SnStickerPatterns on SnSticker {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnSticker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnSticker() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnSticker value)  $default,){
final _that = this;
switch (_that) {
case _SnSticker():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnSticker value)?  $default,){
final _that = this;
switch (_that) {
case _SnSticker() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String? name,  SnCloudFile image,  int order, @JsonKey(fromJson: _stickerSizeFromJson)  int size, @JsonKey(fromJson: _stickerModeFromJson)  int mode,  String packId,  SnStickerPack? pack,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnSticker() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.image,_that.order,_that.size,_that.mode,_that.packId,_that.pack,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String? name,  SnCloudFile image,  int order, @JsonKey(fromJson: _stickerSizeFromJson)  int size, @JsonKey(fromJson: _stickerModeFromJson)  int mode,  String packId,  SnStickerPack? pack,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnSticker():
return $default(_that.id,_that.slug,_that.name,_that.image,_that.order,_that.size,_that.mode,_that.packId,_that.pack,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String? name,  SnCloudFile image,  int order, @JsonKey(fromJson: _stickerSizeFromJson)  int size, @JsonKey(fromJson: _stickerModeFromJson)  int mode,  String packId,  SnStickerPack? pack,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnSticker() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.image,_that.order,_that.size,_that.mode,_that.packId,_that.pack,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnSticker implements SnSticker {
  const _SnSticker({required this.id, required this.slug, this.name, required this.image, this.order = 0, @JsonKey(fromJson: _stickerSizeFromJson) this.size = 0, @JsonKey(fromJson: _stickerModeFromJson) this.mode = 0, required this.packId, required this.pack, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnSticker.fromJson(Map<String, dynamic> json) => _$SnStickerFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String? name;
@override final  SnCloudFile image;
@override@JsonKey() final  int order;
@override@JsonKey(fromJson: _stickerSizeFromJson) final  int size;
@override@JsonKey(fromJson: _stickerModeFromJson) final  int mode;
@override final  String packId;
@override final  SnStickerPack? pack;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnSticker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnStickerCopyWith<_SnSticker> get copyWith => __$SnStickerCopyWithImpl<_SnSticker>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnStickerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnSticker&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.image, image) || other.image == image)&&(identical(other.order, order) || other.order == order)&&(identical(other.size, size) || other.size == size)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.pack, pack) || other.pack == pack)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,image,order,size,mode,packId,pack,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnSticker(id: $id, slug: $slug, name: $name, image: $image, order: $order, size: $size, mode: $mode, packId: $packId, pack: $pack, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnStickerCopyWith<$Res> implements $SnStickerCopyWith<$Res> {
  factory _$SnStickerCopyWith(_SnSticker value, $Res Function(_SnSticker) _then) = __$SnStickerCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String? name, SnCloudFile image, int order,@JsonKey(fromJson: _stickerSizeFromJson) int size,@JsonKey(fromJson: _stickerModeFromJson) int mode, String packId, SnStickerPack? pack, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnCloudFileCopyWith<$Res> get image;@override $SnStickerPackCopyWith<$Res>? get pack;

}
/// @nodoc
class __$SnStickerCopyWithImpl<$Res>
    implements _$SnStickerCopyWith<$Res> {
  __$SnStickerCopyWithImpl(this._self, this._then);

  final _SnSticker _self;
  final $Res Function(_SnSticker) _then;

/// Create a copy of SnSticker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = freezed,Object? image = null,Object? order = null,Object? size = null,Object? mode = null,Object? packId = null,Object? pack = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnSticker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,image: null == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as SnCloudFile,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as int,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,pack: freezed == pack ? _self.pack : pack // ignore: cast_nullable_to_non_nullable
as SnStickerPack?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnSticker
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res> get image {
  
  return $SnCloudFileCopyWith<$Res>(_self.image, (value) {
    return _then(_self.copyWith(image: value));
  });
}/// Create a copy of SnSticker
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnStickerPackCopyWith<$Res>? get pack {
    if (_self.pack == null) {
    return null;
  }

  return $SnStickerPackCopyWith<$Res>(_self.pack!, (value) {
    return _then(_self.copyWith(pack: value));
  });
}
}


/// @nodoc
mixin _$SnStickerPack {

 String get id; String get name; String get description; String get prefix; String get publisherId; SnCloudFile? get icon; SnPublisher? get publisher; int get order; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; List<SnSticker> get stickers;
/// Create a copy of SnStickerPack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnStickerPackCopyWith<SnStickerPack> get copyWith => _$SnStickerPackCopyWithImpl<SnStickerPack>(this as SnStickerPack, _$identity);

  /// Serializes this SnStickerPack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnStickerPack&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.order, order) || other.order == order)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&const DeepCollectionEquality().equals(other.stickers, stickers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,prefix,publisherId,icon,publisher,order,createdAt,updatedAt,deletedAt,const DeepCollectionEquality().hash(stickers));

@override
String toString() {
  return 'SnStickerPack(id: $id, name: $name, description: $description, prefix: $prefix, publisherId: $publisherId, icon: $icon, publisher: $publisher, order: $order, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, stickers: $stickers)';
}


}

/// @nodoc
abstract mixin class $SnStickerPackCopyWith<$Res>  {
  factory $SnStickerPackCopyWith(SnStickerPack value, $Res Function(SnStickerPack) _then) = _$SnStickerPackCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String prefix, String publisherId, SnCloudFile? icon, SnPublisher? publisher, int order, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, List<SnSticker> stickers
});


$SnCloudFileCopyWith<$Res>? get icon;$SnPublisherCopyWith<$Res>? get publisher;

}
/// @nodoc
class _$SnStickerPackCopyWithImpl<$Res>
    implements $SnStickerPackCopyWith<$Res> {
  _$SnStickerPackCopyWithImpl(this._self, this._then);

  final SnStickerPack _self;
  final $Res Function(SnStickerPack) _then;

/// Create a copy of SnStickerPack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? prefix = null,Object? publisherId = null,Object? icon = freezed,Object? publisher = freezed,Object? order = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? stickers = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,stickers: null == stickers ? _self.stickers : stickers // ignore: cast_nullable_to_non_nullable
as List<SnSticker>,
  ));
}
/// Create a copy of SnStickerPack
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get icon {
    if (_self.icon == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.icon!, (value) {
    return _then(_self.copyWith(icon: value));
  });
}/// Create a copy of SnStickerPack
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
}
}


/// Adds pattern-matching-related methods to [SnStickerPack].
extension SnStickerPackPatterns on SnStickerPack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnStickerPack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnStickerPack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnStickerPack value)  $default,){
final _that = this;
switch (_that) {
case _SnStickerPack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnStickerPack value)?  $default,){
final _that = this;
switch (_that) {
case _SnStickerPack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String prefix,  String publisherId,  SnCloudFile? icon,  SnPublisher? publisher,  int order,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnSticker> stickers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnStickerPack() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.prefix,_that.publisherId,_that.icon,_that.publisher,_that.order,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.stickers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String prefix,  String publisherId,  SnCloudFile? icon,  SnPublisher? publisher,  int order,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnSticker> stickers)  $default,) {final _that = this;
switch (_that) {
case _SnStickerPack():
return $default(_that.id,_that.name,_that.description,_that.prefix,_that.publisherId,_that.icon,_that.publisher,_that.order,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.stickers);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String prefix,  String publisherId,  SnCloudFile? icon,  SnPublisher? publisher,  int order,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnSticker> stickers)?  $default,) {final _that = this;
switch (_that) {
case _SnStickerPack() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.prefix,_that.publisherId,_that.icon,_that.publisher,_that.order,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.stickers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnStickerPack implements SnStickerPack {
  const _SnStickerPack({required this.id, required this.name, required this.description, required this.prefix, required this.publisherId, required this.icon, required this.publisher, this.order = 0, required this.createdAt, required this.updatedAt, required this.deletedAt, final  List<SnSticker> stickers = const []}): _stickers = stickers;
  factory _SnStickerPack.fromJson(Map<String, dynamic> json) => _$SnStickerPackFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String prefix;
@override final  String publisherId;
@override final  SnCloudFile? icon;
@override final  SnPublisher? publisher;
@override@JsonKey() final  int order;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
 final  List<SnSticker> _stickers;
@override@JsonKey() List<SnSticker> get stickers {
  if (_stickers is EqualUnmodifiableListView) return _stickers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stickers);
}


/// Create a copy of SnStickerPack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnStickerPackCopyWith<_SnStickerPack> get copyWith => __$SnStickerPackCopyWithImpl<_SnStickerPack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnStickerPackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnStickerPack&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.prefix, prefix) || other.prefix == prefix)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.order, order) || other.order == order)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&const DeepCollectionEquality().equals(other._stickers, _stickers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,prefix,publisherId,icon,publisher,order,createdAt,updatedAt,deletedAt,const DeepCollectionEquality().hash(_stickers));

@override
String toString() {
  return 'SnStickerPack(id: $id, name: $name, description: $description, prefix: $prefix, publisherId: $publisherId, icon: $icon, publisher: $publisher, order: $order, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, stickers: $stickers)';
}


}

/// @nodoc
abstract mixin class _$SnStickerPackCopyWith<$Res> implements $SnStickerPackCopyWith<$Res> {
  factory _$SnStickerPackCopyWith(_SnStickerPack value, $Res Function(_SnStickerPack) _then) = __$SnStickerPackCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String prefix, String publisherId, SnCloudFile? icon, SnPublisher? publisher, int order, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, List<SnSticker> stickers
});


@override $SnCloudFileCopyWith<$Res>? get icon;@override $SnPublisherCopyWith<$Res>? get publisher;

}
/// @nodoc
class __$SnStickerPackCopyWithImpl<$Res>
    implements _$SnStickerPackCopyWith<$Res> {
  __$SnStickerPackCopyWithImpl(this._self, this._then);

  final _SnStickerPack _self;
  final $Res Function(_SnStickerPack) _then;

/// Create a copy of SnStickerPack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? prefix = null,Object? publisherId = null,Object? icon = freezed,Object? publisher = freezed,Object? order = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? stickers = null,}) {
  return _then(_SnStickerPack(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,prefix: null == prefix ? _self.prefix : prefix // ignore: cast_nullable_to_non_nullable
as String,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,stickers: null == stickers ? _self._stickers : stickers // ignore: cast_nullable_to_non_nullable
as List<SnSticker>,
  ));
}

/// Create a copy of SnStickerPack
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get icon {
    if (_self.icon == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.icon!, (value) {
    return _then(_self.copyWith(icon: value));
  });
}/// Create a copy of SnStickerPack
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
}
}


/// @nodoc
mixin _$SnStickerOwnership {

 String get id;@JsonKey(name: 'pack_id') String get packId; SnStickerPack? get pack;@JsonKey(name: 'account_id') String get accountId; SnAccount? get account; int get order; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnStickerOwnership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnStickerOwnershipCopyWith<SnStickerOwnership> get copyWith => _$SnStickerOwnershipCopyWithImpl<SnStickerOwnership>(this as SnStickerOwnership, _$identity);

  /// Serializes this SnStickerOwnership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnStickerOwnership&&(identical(other.id, id) || other.id == id)&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.pack, pack) || other.pack == pack)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.order, order) || other.order == order)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,packId,pack,accountId,account,order,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnStickerOwnership(id: $id, packId: $packId, pack: $pack, accountId: $accountId, account: $account, order: $order, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnStickerOwnershipCopyWith<$Res>  {
  factory $SnStickerOwnershipCopyWith(SnStickerOwnership value, $Res Function(SnStickerOwnership) _then) = _$SnStickerOwnershipCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'pack_id') String packId, SnStickerPack? pack,@JsonKey(name: 'account_id') String accountId, SnAccount? account, int order, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnStickerPackCopyWith<$Res>? get pack;$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnStickerOwnershipCopyWithImpl<$Res>
    implements $SnStickerOwnershipCopyWith<$Res> {
  _$SnStickerOwnershipCopyWithImpl(this._self, this._then);

  final SnStickerOwnership _self;
  final $Res Function(SnStickerOwnership) _then;

/// Create a copy of SnStickerOwnership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? packId = null,Object? pack = freezed,Object? accountId = null,Object? account = freezed,Object? order = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,pack: freezed == pack ? _self.pack : pack // ignore: cast_nullable_to_non_nullable
as SnStickerPack?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnStickerOwnership
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnStickerPackCopyWith<$Res>? get pack {
    if (_self.pack == null) {
    return null;
  }

  return $SnStickerPackCopyWith<$Res>(_self.pack!, (value) {
    return _then(_self.copyWith(pack: value));
  });
}/// Create a copy of SnStickerOwnership
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnStickerOwnership].
extension SnStickerOwnershipPatterns on SnStickerOwnership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnStickerOwnership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnStickerOwnership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnStickerOwnership value)  $default,){
final _that = this;
switch (_that) {
case _SnStickerOwnership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnStickerOwnership value)?  $default,){
final _that = this;
switch (_that) {
case _SnStickerOwnership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'pack_id')  String packId,  SnStickerPack? pack, @JsonKey(name: 'account_id')  String accountId,  SnAccount? account,  int order,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnStickerOwnership() when $default != null:
return $default(_that.id,_that.packId,_that.pack,_that.accountId,_that.account,_that.order,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'pack_id')  String packId,  SnStickerPack? pack, @JsonKey(name: 'account_id')  String accountId,  SnAccount? account,  int order,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnStickerOwnership():
return $default(_that.id,_that.packId,_that.pack,_that.accountId,_that.account,_that.order,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'pack_id')  String packId,  SnStickerPack? pack, @JsonKey(name: 'account_id')  String accountId,  SnAccount? account,  int order,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnStickerOwnership() when $default != null:
return $default(_that.id,_that.packId,_that.pack,_that.accountId,_that.account,_that.order,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnStickerOwnership implements SnStickerOwnership {
  const _SnStickerOwnership({required this.id, @JsonKey(name: 'pack_id') required this.packId, required this.pack, @JsonKey(name: 'account_id') required this.accountId, required this.account, this.order = 0, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnStickerOwnership.fromJson(Map<String, dynamic> json) => _$SnStickerOwnershipFromJson(json);

@override final  String id;
@override@JsonKey(name: 'pack_id') final  String packId;
@override final  SnStickerPack? pack;
@override@JsonKey(name: 'account_id') final  String accountId;
@override final  SnAccount? account;
@override@JsonKey() final  int order;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnStickerOwnership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnStickerOwnershipCopyWith<_SnStickerOwnership> get copyWith => __$SnStickerOwnershipCopyWithImpl<_SnStickerOwnership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnStickerOwnershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnStickerOwnership&&(identical(other.id, id) || other.id == id)&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.pack, pack) || other.pack == pack)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.order, order) || other.order == order)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,packId,pack,accountId,account,order,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnStickerOwnership(id: $id, packId: $packId, pack: $pack, accountId: $accountId, account: $account, order: $order, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnStickerOwnershipCopyWith<$Res> implements $SnStickerOwnershipCopyWith<$Res> {
  factory _$SnStickerOwnershipCopyWith(_SnStickerOwnership value, $Res Function(_SnStickerOwnership) _then) = __$SnStickerOwnershipCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'pack_id') String packId, SnStickerPack? pack,@JsonKey(name: 'account_id') String accountId, SnAccount? account, int order, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnStickerPackCopyWith<$Res>? get pack;@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnStickerOwnershipCopyWithImpl<$Res>
    implements _$SnStickerOwnershipCopyWith<$Res> {
  __$SnStickerOwnershipCopyWithImpl(this._self, this._then);

  final _SnStickerOwnership _self;
  final $Res Function(_SnStickerOwnership) _then;

/// Create a copy of SnStickerOwnership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? packId = null,Object? pack = freezed,Object? accountId = null,Object? account = freezed,Object? order = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnStickerOwnership(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,pack: freezed == pack ? _self.pack : pack // ignore: cast_nullable_to_non_nullable
as SnStickerPack?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnStickerOwnership
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnStickerPackCopyWith<$Res>? get pack {
    if (_self.pack == null) {
    return null;
  }

  return $SnStickerPackCopyWith<$Res>(_self.pack!, (value) {
    return _then(_self.copyWith(pack: value));
  });
}/// Create a copy of SnStickerOwnership
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}

// dart format on
