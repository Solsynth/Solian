// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'realm.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnRealm {

 int get id; String get slug; String get name; String get description; String? get verifiedAs; DateTime? get verifiedAt; bool get isCommunity; bool get isPublic; SnCloudFile? get picture; SnCloudFile? get background; int get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnRealm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnRealmCopyWith<SnRealm> get copyWith => _$SnRealmCopyWithImpl<SnRealm>(this as SnRealm, _$identity);

  /// Serializes this SnRealm to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnRealm&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.verifiedAs, verifiedAs) || other.verifiedAs == verifiedAs)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.isCommunity, isCommunity) || other.isCommunity == isCommunity)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,verifiedAs,verifiedAt,isCommunity,isPublic,picture,background,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnRealm(id: $id, slug: $slug, name: $name, description: $description, verifiedAs: $verifiedAs, verifiedAt: $verifiedAt, isCommunity: $isCommunity, isPublic: $isPublic, picture: $picture, background: $background, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnRealmCopyWith<$Res>  {
  factory $SnRealmCopyWith(SnRealm value, $Res Function(SnRealm) _then) = _$SnRealmCopyWithImpl;
@useResult
$Res call({
 int id, String slug, String name, String description, String? verifiedAs, DateTime? verifiedAt, bool isCommunity, bool isPublic, SnCloudFile? picture, SnCloudFile? background, int accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnCloudFileCopyWith<$Res>? get picture;$SnCloudFileCopyWith<$Res>? get background;

}
/// @nodoc
class _$SnRealmCopyWithImpl<$Res>
    implements $SnRealmCopyWith<$Res> {
  _$SnRealmCopyWithImpl(this._self, this._then);

  final SnRealm _self;
  final $Res Function(SnRealm) _then;

/// Create a copy of SnRealm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = null,Object? verifiedAs = freezed,Object? verifiedAt = freezed,Object? isCommunity = null,Object? isPublic = null,Object? picture = freezed,Object? background = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,verifiedAs: freezed == verifiedAs ? _self.verifiedAs : verifiedAs // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnRealm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnRealm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _SnRealm implements SnRealm {
  const _SnRealm({required this.id, required this.slug, required this.name, required this.description, required this.verifiedAs, required this.verifiedAt, required this.isCommunity, required this.isPublic, required this.picture, required this.background, required this.accountId, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnRealm.fromJson(Map<String, dynamic> json) => _$SnRealmFromJson(json);

@override final  int id;
@override final  String slug;
@override final  String name;
@override final  String description;
@override final  String? verifiedAs;
@override final  DateTime? verifiedAt;
@override final  bool isCommunity;
@override final  bool isPublic;
@override final  SnCloudFile? picture;
@override final  SnCloudFile? background;
@override final  int accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnRealm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnRealmCopyWith<_SnRealm> get copyWith => __$SnRealmCopyWithImpl<_SnRealm>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnRealmToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnRealm&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.verifiedAs, verifiedAs) || other.verifiedAs == verifiedAs)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.isCommunity, isCommunity) || other.isCommunity == isCommunity)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,verifiedAs,verifiedAt,isCommunity,isPublic,picture,background,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnRealm(id: $id, slug: $slug, name: $name, description: $description, verifiedAs: $verifiedAs, verifiedAt: $verifiedAt, isCommunity: $isCommunity, isPublic: $isPublic, picture: $picture, background: $background, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnRealmCopyWith<$Res> implements $SnRealmCopyWith<$Res> {
  factory _$SnRealmCopyWith(_SnRealm value, $Res Function(_SnRealm) _then) = __$SnRealmCopyWithImpl;
@override @useResult
$Res call({
 int id, String slug, String name, String description, String? verifiedAs, DateTime? verifiedAt, bool isCommunity, bool isPublic, SnCloudFile? picture, SnCloudFile? background, int accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnCloudFileCopyWith<$Res>? get picture;@override $SnCloudFileCopyWith<$Res>? get background;

}
/// @nodoc
class __$SnRealmCopyWithImpl<$Res>
    implements _$SnRealmCopyWith<$Res> {
  __$SnRealmCopyWithImpl(this._self, this._then);

  final _SnRealm _self;
  final $Res Function(_SnRealm) _then;

/// Create a copy of SnRealm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = null,Object? verifiedAs = freezed,Object? verifiedAt = freezed,Object? isCommunity = null,Object? isPublic = null,Object? picture = freezed,Object? background = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnRealm(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,verifiedAs: freezed == verifiedAs ? _self.verifiedAs : verifiedAs // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnRealm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnRealm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}
}

// dart format on
