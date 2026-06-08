// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
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

 String get id; String get slug; String get name; String get description; String? get verifiedAs; DateTime? get verifiedAt; bool get isCommunity; bool get isPublic; SnCloudFileReference? get picture; SnCloudFileReference? get background; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; int get boostPoints; int get boostLevel;
/// Create a copy of SnRealm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnRealmCopyWith<SnRealm> get copyWith => _$SnRealmCopyWithImpl<SnRealm>(this as SnRealm, _$identity);

  /// Serializes this SnRealm to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnRealm&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.verifiedAs, verifiedAs) || other.verifiedAs == verifiedAs)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.isCommunity, isCommunity) || other.isCommunity == isCommunity)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.boostPoints, boostPoints) || other.boostPoints == boostPoints)&&(identical(other.boostLevel, boostLevel) || other.boostLevel == boostLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,verifiedAs,verifiedAt,isCommunity,isPublic,picture,background,accountId,createdAt,updatedAt,deletedAt,boostPoints,boostLevel);

@override
String toString() {
  return 'SnRealm(id: $id, slug: $slug, name: $name, description: $description, verifiedAs: $verifiedAs, verifiedAt: $verifiedAt, isCommunity: $isCommunity, isPublic: $isPublic, picture: $picture, background: $background, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, boostPoints: $boostPoints, boostLevel: $boostLevel)';
}


}

/// @nodoc
abstract mixin class $SnRealmCopyWith<$Res>  {
  factory $SnRealmCopyWith(SnRealm value, $Res Function(SnRealm) _then) = _$SnRealmCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String name, String description, String? verifiedAs, DateTime? verifiedAt, bool isCommunity, bool isPublic, SnCloudFileReference? picture, SnCloudFileReference? background, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, int boostPoints, int boostLevel
});


$SnCloudFileReferenceCopyWith<$Res>? get picture;$SnCloudFileReferenceCopyWith<$Res>? get background;

}
/// @nodoc
class _$SnRealmCopyWithImpl<$Res>
    implements $SnRealmCopyWith<$Res> {
  _$SnRealmCopyWithImpl(this._self, this._then);

  final SnRealm _self;
  final $Res Function(SnRealm) _then;

/// Create a copy of SnRealm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = null,Object? verifiedAs = freezed,Object? verifiedAt = freezed,Object? isCommunity = null,Object? isPublic = null,Object? picture = freezed,Object? background = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? boostPoints = null,Object? boostLevel = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,verifiedAs: freezed == verifiedAs ? _self.verifiedAs : verifiedAs // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,boostPoints: null == boostPoints ? _self.boostPoints : boostPoints // ignore: cast_nullable_to_non_nullable
as int,boostLevel: null == boostLevel ? _self.boostLevel : boostLevel // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SnRealm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnRealm
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
}
}


/// Adds pattern-matching-related methods to [SnRealm].
extension SnRealmPatterns on SnRealm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnRealm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnRealm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnRealm value)  $default,){
final _that = this;
switch (_that) {
case _SnRealm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnRealm value)?  $default,){
final _that = this;
switch (_that) {
case _SnRealm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String description,  String? verifiedAs,  DateTime? verifiedAt,  bool isCommunity,  bool isPublic,  SnCloudFileReference? picture,  SnCloudFileReference? background,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  int boostPoints,  int boostLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnRealm() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.verifiedAs,_that.verifiedAt,_that.isCommunity,_that.isPublic,_that.picture,_that.background,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.boostPoints,_that.boostLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String description,  String? verifiedAs,  DateTime? verifiedAt,  bool isCommunity,  bool isPublic,  SnCloudFileReference? picture,  SnCloudFileReference? background,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  int boostPoints,  int boostLevel)  $default,) {final _that = this;
switch (_that) {
case _SnRealm():
return $default(_that.id,_that.slug,_that.name,_that.description,_that.verifiedAs,_that.verifiedAt,_that.isCommunity,_that.isPublic,_that.picture,_that.background,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.boostPoints,_that.boostLevel);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String name,  String description,  String? verifiedAs,  DateTime? verifiedAt,  bool isCommunity,  bool isPublic,  SnCloudFileReference? picture,  SnCloudFileReference? background,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  int boostPoints,  int boostLevel)?  $default,) {final _that = this;
switch (_that) {
case _SnRealm() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.verifiedAs,_that.verifiedAt,_that.isCommunity,_that.isPublic,_that.picture,_that.background,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.boostPoints,_that.boostLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnRealm implements SnRealm {
  const _SnRealm({required this.id, required this.slug, this.name = '', this.description = '', required this.verifiedAs, required this.verifiedAt, required this.isCommunity, required this.isPublic, required this.picture, required this.background, required this.accountId, required this.createdAt, required this.updatedAt, required this.deletedAt, this.boostPoints = 0, this.boostLevel = 0});
  factory _SnRealm.fromJson(Map<String, dynamic> json) => _$SnRealmFromJson(json);

@override final  String id;
@override final  String slug;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override final  String? verifiedAs;
@override final  DateTime? verifiedAt;
@override final  bool isCommunity;
@override final  bool isPublic;
@override final  SnCloudFileReference? picture;
@override final  SnCloudFileReference? background;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override@JsonKey() final  int boostPoints;
@override@JsonKey() final  int boostLevel;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnRealm&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.verifiedAs, verifiedAs) || other.verifiedAs == verifiedAs)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.isCommunity, isCommunity) || other.isCommunity == isCommunity)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.boostPoints, boostPoints) || other.boostPoints == boostPoints)&&(identical(other.boostLevel, boostLevel) || other.boostLevel == boostLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,verifiedAs,verifiedAt,isCommunity,isPublic,picture,background,accountId,createdAt,updatedAt,deletedAt,boostPoints,boostLevel);

@override
String toString() {
  return 'SnRealm(id: $id, slug: $slug, name: $name, description: $description, verifiedAs: $verifiedAs, verifiedAt: $verifiedAt, isCommunity: $isCommunity, isPublic: $isPublic, picture: $picture, background: $background, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, boostPoints: $boostPoints, boostLevel: $boostLevel)';
}


}

/// @nodoc
abstract mixin class _$SnRealmCopyWith<$Res> implements $SnRealmCopyWith<$Res> {
  factory _$SnRealmCopyWith(_SnRealm value, $Res Function(_SnRealm) _then) = __$SnRealmCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String name, String description, String? verifiedAs, DateTime? verifiedAt, bool isCommunity, bool isPublic, SnCloudFileReference? picture, SnCloudFileReference? background, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, int boostPoints, int boostLevel
});


@override $SnCloudFileReferenceCopyWith<$Res>? get picture;@override $SnCloudFileReferenceCopyWith<$Res>? get background;

}
/// @nodoc
class __$SnRealmCopyWithImpl<$Res>
    implements _$SnRealmCopyWith<$Res> {
  __$SnRealmCopyWithImpl(this._self, this._then);

  final _SnRealm _self;
  final $Res Function(_SnRealm) _then;

/// Create a copy of SnRealm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = null,Object? verifiedAs = freezed,Object? verifiedAt = freezed,Object? isCommunity = null,Object? isPublic = null,Object? picture = freezed,Object? background = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? boostPoints = null,Object? boostLevel = null,}) {
  return _then(_SnRealm(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,verifiedAs: freezed == verifiedAs ? _self.verifiedAs : verifiedAs // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,boostPoints: null == boostPoints ? _self.boostPoints : boostPoints // ignore: cast_nullable_to_non_nullable
as int,boostLevel: null == boostLevel ? _self.boostLevel : boostLevel // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SnRealm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnRealm
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
}
}


/// @nodoc
mixin _$SnRealmMember {

 String get realmId; SnRealm? get realm; String get accountId; SnAccount? get account; int get role; DateTime? get joinedAt; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; SnAccountStatus? get status; String? get nick; String? get bio; String? get labelId; SnRealmLabel? get label; int get experience; int get level; double get levelingProgress;
/// Create a copy of SnRealmMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnRealmMemberCopyWith<SnRealmMember> get copyWith => _$SnRealmMemberCopyWithImpl<SnRealmMember>(this as SnRealmMember, _$identity);

  /// Serializes this SnRealmMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnRealmMember&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.realm, realm) || other.realm == realm)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.labelId, labelId) || other.labelId == labelId)&&(identical(other.label, label) || other.label == label)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.level, level) || other.level == level)&&(identical(other.levelingProgress, levelingProgress) || other.levelingProgress == levelingProgress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,realmId,realm,accountId,account,role,joinedAt,createdAt,updatedAt,deletedAt,status,nick,bio,labelId,label,experience,level,levelingProgress);

@override
String toString() {
  return 'SnRealmMember(realmId: $realmId, realm: $realm, accountId: $accountId, account: $account, role: $role, joinedAt: $joinedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, status: $status, nick: $nick, bio: $bio, labelId: $labelId, label: $label, experience: $experience, level: $level, levelingProgress: $levelingProgress)';
}


}

/// @nodoc
abstract mixin class $SnRealmMemberCopyWith<$Res>  {
  factory $SnRealmMemberCopyWith(SnRealmMember value, $Res Function(SnRealmMember) _then) = _$SnRealmMemberCopyWithImpl;
@useResult
$Res call({
 String realmId, SnRealm? realm, String accountId, SnAccount? account, int role, DateTime? joinedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, SnAccountStatus? status, String? nick, String? bio, String? labelId, SnRealmLabel? label, int experience, int level, double levelingProgress
});


$SnRealmCopyWith<$Res>? get realm;$SnAccountCopyWith<$Res>? get account;$SnAccountStatusCopyWith<$Res>? get status;$SnRealmLabelCopyWith<$Res>? get label;

}
/// @nodoc
class _$SnRealmMemberCopyWithImpl<$Res>
    implements $SnRealmMemberCopyWith<$Res> {
  _$SnRealmMemberCopyWithImpl(this._self, this._then);

  final SnRealmMember _self;
  final $Res Function(SnRealmMember) _then;

/// Create a copy of SnRealmMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? realmId = null,Object? realm = freezed,Object? accountId = null,Object? account = freezed,Object? role = null,Object? joinedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? status = freezed,Object? nick = freezed,Object? bio = freezed,Object? labelId = freezed,Object? label = freezed,Object? experience = null,Object? level = null,Object? levelingProgress = null,}) {
  return _then(_self.copyWith(
realmId: null == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as SnRealm?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnAccountStatus?,nick: freezed == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,labelId: freezed == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as SnRealmLabel?,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,levelingProgress: null == levelingProgress ? _self.levelingProgress : levelingProgress // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of SnRealmMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRealmCopyWith<$Res>? get realm {
    if (_self.realm == null) {
    return null;
  }

  return $SnRealmCopyWith<$Res>(_self.realm!, (value) {
    return _then(_self.copyWith(realm: value));
  });
}/// Create a copy of SnRealmMember
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
}/// Create a copy of SnRealmMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $SnAccountStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of SnRealmMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRealmLabelCopyWith<$Res>? get label {
    if (_self.label == null) {
    return null;
  }

  return $SnRealmLabelCopyWith<$Res>(_self.label!, (value) {
    return _then(_self.copyWith(label: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnRealmMember].
extension SnRealmMemberPatterns on SnRealmMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnRealmMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnRealmMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnRealmMember value)  $default,){
final _that = this;
switch (_that) {
case _SnRealmMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnRealmMember value)?  $default,){
final _that = this;
switch (_that) {
case _SnRealmMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String realmId,  SnRealm? realm,  String accountId,  SnAccount? account,  int role,  DateTime? joinedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  SnAccountStatus? status,  String? nick,  String? bio,  String? labelId,  SnRealmLabel? label,  int experience,  int level,  double levelingProgress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnRealmMember() when $default != null:
return $default(_that.realmId,_that.realm,_that.accountId,_that.account,_that.role,_that.joinedAt,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.status,_that.nick,_that.bio,_that.labelId,_that.label,_that.experience,_that.level,_that.levelingProgress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String realmId,  SnRealm? realm,  String accountId,  SnAccount? account,  int role,  DateTime? joinedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  SnAccountStatus? status,  String? nick,  String? bio,  String? labelId,  SnRealmLabel? label,  int experience,  int level,  double levelingProgress)  $default,) {final _that = this;
switch (_that) {
case _SnRealmMember():
return $default(_that.realmId,_that.realm,_that.accountId,_that.account,_that.role,_that.joinedAt,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.status,_that.nick,_that.bio,_that.labelId,_that.label,_that.experience,_that.level,_that.levelingProgress);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String realmId,  SnRealm? realm,  String accountId,  SnAccount? account,  int role,  DateTime? joinedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  SnAccountStatus? status,  String? nick,  String? bio,  String? labelId,  SnRealmLabel? label,  int experience,  int level,  double levelingProgress)?  $default,) {final _that = this;
switch (_that) {
case _SnRealmMember() when $default != null:
return $default(_that.realmId,_that.realm,_that.accountId,_that.account,_that.role,_that.joinedAt,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.status,_that.nick,_that.bio,_that.labelId,_that.label,_that.experience,_that.level,_that.levelingProgress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnRealmMember implements SnRealmMember {
  const _SnRealmMember({required this.realmId, required this.realm, required this.accountId, required this.account, required this.role, required this.joinedAt, required this.createdAt, required this.updatedAt, required this.deletedAt, required this.status, required this.nick, required this.bio, required this.labelId, required this.label, required this.experience, required this.level, required this.levelingProgress});
  factory _SnRealmMember.fromJson(Map<String, dynamic> json) => _$SnRealmMemberFromJson(json);

@override final  String realmId;
@override final  SnRealm? realm;
@override final  String accountId;
@override final  SnAccount? account;
@override final  int role;
@override final  DateTime? joinedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  SnAccountStatus? status;
@override final  String? nick;
@override final  String? bio;
@override final  String? labelId;
@override final  SnRealmLabel? label;
@override final  int experience;
@override final  int level;
@override final  double levelingProgress;

/// Create a copy of SnRealmMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnRealmMemberCopyWith<_SnRealmMember> get copyWith => __$SnRealmMemberCopyWithImpl<_SnRealmMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnRealmMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnRealmMember&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.realm, realm) || other.realm == realm)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.role, role) || other.role == role)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.labelId, labelId) || other.labelId == labelId)&&(identical(other.label, label) || other.label == label)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.level, level) || other.level == level)&&(identical(other.levelingProgress, levelingProgress) || other.levelingProgress == levelingProgress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,realmId,realm,accountId,account,role,joinedAt,createdAt,updatedAt,deletedAt,status,nick,bio,labelId,label,experience,level,levelingProgress);

@override
String toString() {
  return 'SnRealmMember(realmId: $realmId, realm: $realm, accountId: $accountId, account: $account, role: $role, joinedAt: $joinedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, status: $status, nick: $nick, bio: $bio, labelId: $labelId, label: $label, experience: $experience, level: $level, levelingProgress: $levelingProgress)';
}


}

/// @nodoc
abstract mixin class _$SnRealmMemberCopyWith<$Res> implements $SnRealmMemberCopyWith<$Res> {
  factory _$SnRealmMemberCopyWith(_SnRealmMember value, $Res Function(_SnRealmMember) _then) = __$SnRealmMemberCopyWithImpl;
@override @useResult
$Res call({
 String realmId, SnRealm? realm, String accountId, SnAccount? account, int role, DateTime? joinedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, SnAccountStatus? status, String? nick, String? bio, String? labelId, SnRealmLabel? label, int experience, int level, double levelingProgress
});


@override $SnRealmCopyWith<$Res>? get realm;@override $SnAccountCopyWith<$Res>? get account;@override $SnAccountStatusCopyWith<$Res>? get status;@override $SnRealmLabelCopyWith<$Res>? get label;

}
/// @nodoc
class __$SnRealmMemberCopyWithImpl<$Res>
    implements _$SnRealmMemberCopyWith<$Res> {
  __$SnRealmMemberCopyWithImpl(this._self, this._then);

  final _SnRealmMember _self;
  final $Res Function(_SnRealmMember) _then;

/// Create a copy of SnRealmMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? realmId = null,Object? realm = freezed,Object? accountId = null,Object? account = freezed,Object? role = null,Object? joinedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? status = freezed,Object? nick = freezed,Object? bio = freezed,Object? labelId = freezed,Object? label = freezed,Object? experience = null,Object? level = null,Object? levelingProgress = null,}) {
  return _then(_SnRealmMember(
realmId: null == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as SnRealm?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnAccountStatus?,nick: freezed == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,labelId: freezed == labelId ? _self.labelId : labelId // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as SnRealmLabel?,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,levelingProgress: null == levelingProgress ? _self.levelingProgress : levelingProgress // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of SnRealmMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRealmCopyWith<$Res>? get realm {
    if (_self.realm == null) {
    return null;
  }

  return $SnRealmCopyWith<$Res>(_self.realm!, (value) {
    return _then(_self.copyWith(realm: value));
  });
}/// Create a copy of SnRealmMember
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
}/// Create a copy of SnRealmMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $SnAccountStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of SnRealmMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRealmLabelCopyWith<$Res>? get label {
    if (_self.label == null) {
    return null;
  }

  return $SnRealmLabelCopyWith<$Res>(_self.label!, (value) {
    return _then(_self.copyWith(label: value));
  });
}
}


/// @nodoc
mixin _$SnRealmLabel {

 String get id; String get realmId; String get name; String get description; String? get color; String? get icon; String get createdByAccountId; DateTime get createdAt; DateTime get updatedAt; dynamic get deletedAt;
/// Create a copy of SnRealmLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnRealmLabelCopyWith<SnRealmLabel> get copyWith => _$SnRealmLabelCopyWithImpl<SnRealmLabel>(this as SnRealmLabel, _$identity);

  /// Serializes this SnRealmLabel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnRealmLabel&&(identical(other.id, id) || other.id == id)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.createdByAccountId, createdByAccountId) || other.createdByAccountId == createdByAccountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.deletedAt, deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,realmId,name,description,color,icon,createdByAccountId,createdAt,updatedAt,const DeepCollectionEquality().hash(deletedAt));

@override
String toString() {
  return 'SnRealmLabel(id: $id, realmId: $realmId, name: $name, description: $description, color: $color, icon: $icon, createdByAccountId: $createdByAccountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnRealmLabelCopyWith<$Res>  {
  factory $SnRealmLabelCopyWith(SnRealmLabel value, $Res Function(SnRealmLabel) _then) = _$SnRealmLabelCopyWithImpl;
@useResult
$Res call({
 String id, String realmId, String name, String description, String? color, String? icon, String createdByAccountId, DateTime createdAt, DateTime updatedAt, dynamic deletedAt
});




}
/// @nodoc
class _$SnRealmLabelCopyWithImpl<$Res>
    implements $SnRealmLabelCopyWith<$Res> {
  _$SnRealmLabelCopyWithImpl(this._self, this._then);

  final SnRealmLabel _self;
  final $Res Function(SnRealmLabel) _then;

/// Create a copy of SnRealmLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? realmId = null,Object? name = null,Object? description = null,Object? color = freezed,Object? icon = freezed,Object? createdByAccountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,realmId: null == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,createdByAccountId: null == createdByAccountId ? _self.createdByAccountId : createdByAccountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [SnRealmLabel].
extension SnRealmLabelPatterns on SnRealmLabel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnRealmLabel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnRealmLabel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnRealmLabel value)  $default,){
final _that = this;
switch (_that) {
case _SnRealmLabel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnRealmLabel value)?  $default,){
final _that = this;
switch (_that) {
case _SnRealmLabel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String realmId,  String name,  String description,  String? color,  String? icon,  String createdByAccountId,  DateTime createdAt,  DateTime updatedAt,  dynamic deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnRealmLabel() when $default != null:
return $default(_that.id,_that.realmId,_that.name,_that.description,_that.color,_that.icon,_that.createdByAccountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String realmId,  String name,  String description,  String? color,  String? icon,  String createdByAccountId,  DateTime createdAt,  DateTime updatedAt,  dynamic deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnRealmLabel():
return $default(_that.id,_that.realmId,_that.name,_that.description,_that.color,_that.icon,_that.createdByAccountId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String realmId,  String name,  String description,  String? color,  String? icon,  String createdByAccountId,  DateTime createdAt,  DateTime updatedAt,  dynamic deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnRealmLabel() when $default != null:
return $default(_that.id,_that.realmId,_that.name,_that.description,_that.color,_that.icon,_that.createdByAccountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnRealmLabel implements SnRealmLabel {
  const _SnRealmLabel({required this.id, required this.realmId, this.name = "", this.description = "", required this.color, required this.icon, required this.createdByAccountId, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnRealmLabel.fromJson(Map<String, dynamic> json) => _$SnRealmLabelFromJson(json);

@override final  String id;
@override final  String realmId;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override final  String? color;
@override final  String? icon;
@override final  String createdByAccountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  dynamic deletedAt;

/// Create a copy of SnRealmLabel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnRealmLabelCopyWith<_SnRealmLabel> get copyWith => __$SnRealmLabelCopyWithImpl<_SnRealmLabel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnRealmLabelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnRealmLabel&&(identical(other.id, id) || other.id == id)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.color, color) || other.color == color)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.createdByAccountId, createdByAccountId) || other.createdByAccountId == createdByAccountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.deletedAt, deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,realmId,name,description,color,icon,createdByAccountId,createdAt,updatedAt,const DeepCollectionEquality().hash(deletedAt));

@override
String toString() {
  return 'SnRealmLabel(id: $id, realmId: $realmId, name: $name, description: $description, color: $color, icon: $icon, createdByAccountId: $createdByAccountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnRealmLabelCopyWith<$Res> implements $SnRealmLabelCopyWith<$Res> {
  factory _$SnRealmLabelCopyWith(_SnRealmLabel value, $Res Function(_SnRealmLabel) _then) = __$SnRealmLabelCopyWithImpl;
@override @useResult
$Res call({
 String id, String realmId, String name, String description, String? color, String? icon, String createdByAccountId, DateTime createdAt, DateTime updatedAt, dynamic deletedAt
});




}
/// @nodoc
class __$SnRealmLabelCopyWithImpl<$Res>
    implements _$SnRealmLabelCopyWith<$Res> {
  __$SnRealmLabelCopyWithImpl(this._self, this._then);

  final _SnRealmLabel _self;
  final $Res Function(_SnRealmLabel) _then;

/// Create a copy of SnRealmLabel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? realmId = null,Object? name = null,Object? description = null,Object? color = freezed,Object? icon = freezed,Object? createdByAccountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnRealmLabel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,realmId: null == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,createdByAccountId: null == createdByAccountId ? _self.createdByAccountId : createdByAccountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}


/// @nodoc
mixin _$SnRealmRolePermission {

 int get roleLevel; bool get canChat; bool get canPost; bool get canComment; bool get canUploadMedia; bool get canModeratePosts; bool get canModerateChat; bool get canManageMembers; bool get canManageRealm;
/// Create a copy of SnRealmRolePermission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnRealmRolePermissionCopyWith<SnRealmRolePermission> get copyWith => _$SnRealmRolePermissionCopyWithImpl<SnRealmRolePermission>(this as SnRealmRolePermission, _$identity);

  /// Serializes this SnRealmRolePermission to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnRealmRolePermission&&(identical(other.roleLevel, roleLevel) || other.roleLevel == roleLevel)&&(identical(other.canChat, canChat) || other.canChat == canChat)&&(identical(other.canPost, canPost) || other.canPost == canPost)&&(identical(other.canComment, canComment) || other.canComment == canComment)&&(identical(other.canUploadMedia, canUploadMedia) || other.canUploadMedia == canUploadMedia)&&(identical(other.canModeratePosts, canModeratePosts) || other.canModeratePosts == canModeratePosts)&&(identical(other.canModerateChat, canModerateChat) || other.canModerateChat == canModerateChat)&&(identical(other.canManageMembers, canManageMembers) || other.canManageMembers == canManageMembers)&&(identical(other.canManageRealm, canManageRealm) || other.canManageRealm == canManageRealm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roleLevel,canChat,canPost,canComment,canUploadMedia,canModeratePosts,canModerateChat,canManageMembers,canManageRealm);

@override
String toString() {
  return 'SnRealmRolePermission(roleLevel: $roleLevel, canChat: $canChat, canPost: $canPost, canComment: $canComment, canUploadMedia: $canUploadMedia, canModeratePosts: $canModeratePosts, canModerateChat: $canModerateChat, canManageMembers: $canManageMembers, canManageRealm: $canManageRealm)';
}


}

/// @nodoc
abstract mixin class $SnRealmRolePermissionCopyWith<$Res>  {
  factory $SnRealmRolePermissionCopyWith(SnRealmRolePermission value, $Res Function(SnRealmRolePermission) _then) = _$SnRealmRolePermissionCopyWithImpl;
@useResult
$Res call({
 int roleLevel, bool canChat, bool canPost, bool canComment, bool canUploadMedia, bool canModeratePosts, bool canModerateChat, bool canManageMembers, bool canManageRealm
});




}
/// @nodoc
class _$SnRealmRolePermissionCopyWithImpl<$Res>
    implements $SnRealmRolePermissionCopyWith<$Res> {
  _$SnRealmRolePermissionCopyWithImpl(this._self, this._then);

  final SnRealmRolePermission _self;
  final $Res Function(SnRealmRolePermission) _then;

/// Create a copy of SnRealmRolePermission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roleLevel = null,Object? canChat = null,Object? canPost = null,Object? canComment = null,Object? canUploadMedia = null,Object? canModeratePosts = null,Object? canModerateChat = null,Object? canManageMembers = null,Object? canManageRealm = null,}) {
  return _then(_self.copyWith(
roleLevel: null == roleLevel ? _self.roleLevel : roleLevel // ignore: cast_nullable_to_non_nullable
as int,canChat: null == canChat ? _self.canChat : canChat // ignore: cast_nullable_to_non_nullable
as bool,canPost: null == canPost ? _self.canPost : canPost // ignore: cast_nullable_to_non_nullable
as bool,canComment: null == canComment ? _self.canComment : canComment // ignore: cast_nullable_to_non_nullable
as bool,canUploadMedia: null == canUploadMedia ? _self.canUploadMedia : canUploadMedia // ignore: cast_nullable_to_non_nullable
as bool,canModeratePosts: null == canModeratePosts ? _self.canModeratePosts : canModeratePosts // ignore: cast_nullable_to_non_nullable
as bool,canModerateChat: null == canModerateChat ? _self.canModerateChat : canModerateChat // ignore: cast_nullable_to_non_nullable
as bool,canManageMembers: null == canManageMembers ? _self.canManageMembers : canManageMembers // ignore: cast_nullable_to_non_nullable
as bool,canManageRealm: null == canManageRealm ? _self.canManageRealm : canManageRealm // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SnRealmRolePermission].
extension SnRealmRolePermissionPatterns on SnRealmRolePermission {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnRealmRolePermission value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnRealmRolePermission() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnRealmRolePermission value)  $default,){
final _that = this;
switch (_that) {
case _SnRealmRolePermission():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnRealmRolePermission value)?  $default,){
final _that = this;
switch (_that) {
case _SnRealmRolePermission() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int roleLevel,  bool canChat,  bool canPost,  bool canComment,  bool canUploadMedia,  bool canModeratePosts,  bool canModerateChat,  bool canManageMembers,  bool canManageRealm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnRealmRolePermission() when $default != null:
return $default(_that.roleLevel,_that.canChat,_that.canPost,_that.canComment,_that.canUploadMedia,_that.canModeratePosts,_that.canModerateChat,_that.canManageMembers,_that.canManageRealm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int roleLevel,  bool canChat,  bool canPost,  bool canComment,  bool canUploadMedia,  bool canModeratePosts,  bool canModerateChat,  bool canManageMembers,  bool canManageRealm)  $default,) {final _that = this;
switch (_that) {
case _SnRealmRolePermission():
return $default(_that.roleLevel,_that.canChat,_that.canPost,_that.canComment,_that.canUploadMedia,_that.canModeratePosts,_that.canModerateChat,_that.canManageMembers,_that.canManageRealm);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int roleLevel,  bool canChat,  bool canPost,  bool canComment,  bool canUploadMedia,  bool canModeratePosts,  bool canModerateChat,  bool canManageMembers,  bool canManageRealm)?  $default,) {final _that = this;
switch (_that) {
case _SnRealmRolePermission() when $default != null:
return $default(_that.roleLevel,_that.canChat,_that.canPost,_that.canComment,_that.canUploadMedia,_that.canModeratePosts,_that.canModerateChat,_that.canManageMembers,_that.canManageRealm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnRealmRolePermission implements SnRealmRolePermission {
  const _SnRealmRolePermission({required this.roleLevel, this.canChat = true, this.canPost = true, this.canComment = true, this.canUploadMedia = true, this.canModeratePosts = false, this.canModerateChat = false, this.canManageMembers = false, this.canManageRealm = false});
  factory _SnRealmRolePermission.fromJson(Map<String, dynamic> json) => _$SnRealmRolePermissionFromJson(json);

@override final  int roleLevel;
@override@JsonKey() final  bool canChat;
@override@JsonKey() final  bool canPost;
@override@JsonKey() final  bool canComment;
@override@JsonKey() final  bool canUploadMedia;
@override@JsonKey() final  bool canModeratePosts;
@override@JsonKey() final  bool canModerateChat;
@override@JsonKey() final  bool canManageMembers;
@override@JsonKey() final  bool canManageRealm;

/// Create a copy of SnRealmRolePermission
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnRealmRolePermissionCopyWith<_SnRealmRolePermission> get copyWith => __$SnRealmRolePermissionCopyWithImpl<_SnRealmRolePermission>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnRealmRolePermissionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnRealmRolePermission&&(identical(other.roleLevel, roleLevel) || other.roleLevel == roleLevel)&&(identical(other.canChat, canChat) || other.canChat == canChat)&&(identical(other.canPost, canPost) || other.canPost == canPost)&&(identical(other.canComment, canComment) || other.canComment == canComment)&&(identical(other.canUploadMedia, canUploadMedia) || other.canUploadMedia == canUploadMedia)&&(identical(other.canModeratePosts, canModeratePosts) || other.canModeratePosts == canModeratePosts)&&(identical(other.canModerateChat, canModerateChat) || other.canModerateChat == canModerateChat)&&(identical(other.canManageMembers, canManageMembers) || other.canManageMembers == canManageMembers)&&(identical(other.canManageRealm, canManageRealm) || other.canManageRealm == canManageRealm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roleLevel,canChat,canPost,canComment,canUploadMedia,canModeratePosts,canModerateChat,canManageMembers,canManageRealm);

@override
String toString() {
  return 'SnRealmRolePermission(roleLevel: $roleLevel, canChat: $canChat, canPost: $canPost, canComment: $canComment, canUploadMedia: $canUploadMedia, canModeratePosts: $canModeratePosts, canModerateChat: $canModerateChat, canManageMembers: $canManageMembers, canManageRealm: $canManageRealm)';
}


}

/// @nodoc
abstract mixin class _$SnRealmRolePermissionCopyWith<$Res> implements $SnRealmRolePermissionCopyWith<$Res> {
  factory _$SnRealmRolePermissionCopyWith(_SnRealmRolePermission value, $Res Function(_SnRealmRolePermission) _then) = __$SnRealmRolePermissionCopyWithImpl;
@override @useResult
$Res call({
 int roleLevel, bool canChat, bool canPost, bool canComment, bool canUploadMedia, bool canModeratePosts, bool canModerateChat, bool canManageMembers, bool canManageRealm
});




}
/// @nodoc
class __$SnRealmRolePermissionCopyWithImpl<$Res>
    implements _$SnRealmRolePermissionCopyWith<$Res> {
  __$SnRealmRolePermissionCopyWithImpl(this._self, this._then);

  final _SnRealmRolePermission _self;
  final $Res Function(_SnRealmRolePermission) _then;

/// Create a copy of SnRealmRolePermission
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roleLevel = null,Object? canChat = null,Object? canPost = null,Object? canComment = null,Object? canUploadMedia = null,Object? canModeratePosts = null,Object? canModerateChat = null,Object? canManageMembers = null,Object? canManageRealm = null,}) {
  return _then(_SnRealmRolePermission(
roleLevel: null == roleLevel ? _self.roleLevel : roleLevel // ignore: cast_nullable_to_non_nullable
as int,canChat: null == canChat ? _self.canChat : canChat // ignore: cast_nullable_to_non_nullable
as bool,canPost: null == canPost ? _self.canPost : canPost // ignore: cast_nullable_to_non_nullable
as bool,canComment: null == canComment ? _self.canComment : canComment // ignore: cast_nullable_to_non_nullable
as bool,canUploadMedia: null == canUploadMedia ? _self.canUploadMedia : canUploadMedia // ignore: cast_nullable_to_non_nullable
as bool,canModeratePosts: null == canModeratePosts ? _self.canModeratePosts : canModeratePosts // ignore: cast_nullable_to_non_nullable
as bool,canModerateChat: null == canModerateChat ? _self.canModerateChat : canModerateChat // ignore: cast_nullable_to_non_nullable
as bool,canManageMembers: null == canManageMembers ? _self.canManageMembers : canManageMembers // ignore: cast_nullable_to_non_nullable
as bool,canManageRealm: null == canManageRealm ? _self.canManageRealm : canManageRealm // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SnRealmUserPermission {

 String get accountId; bool? get canChat; bool? get canPost; bool? get canComment; bool? get canUploadMedia; bool? get canModeratePosts; bool? get canModerateChat; bool? get canManageMembers; bool? get canManageRealm;
/// Create a copy of SnRealmUserPermission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnRealmUserPermissionCopyWith<SnRealmUserPermission> get copyWith => _$SnRealmUserPermissionCopyWithImpl<SnRealmUserPermission>(this as SnRealmUserPermission, _$identity);

  /// Serializes this SnRealmUserPermission to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnRealmUserPermission&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.canChat, canChat) || other.canChat == canChat)&&(identical(other.canPost, canPost) || other.canPost == canPost)&&(identical(other.canComment, canComment) || other.canComment == canComment)&&(identical(other.canUploadMedia, canUploadMedia) || other.canUploadMedia == canUploadMedia)&&(identical(other.canModeratePosts, canModeratePosts) || other.canModeratePosts == canModeratePosts)&&(identical(other.canModerateChat, canModerateChat) || other.canModerateChat == canModerateChat)&&(identical(other.canManageMembers, canManageMembers) || other.canManageMembers == canManageMembers)&&(identical(other.canManageRealm, canManageRealm) || other.canManageRealm == canManageRealm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,canChat,canPost,canComment,canUploadMedia,canModeratePosts,canModerateChat,canManageMembers,canManageRealm);

@override
String toString() {
  return 'SnRealmUserPermission(accountId: $accountId, canChat: $canChat, canPost: $canPost, canComment: $canComment, canUploadMedia: $canUploadMedia, canModeratePosts: $canModeratePosts, canModerateChat: $canModerateChat, canManageMembers: $canManageMembers, canManageRealm: $canManageRealm)';
}


}

/// @nodoc
abstract mixin class $SnRealmUserPermissionCopyWith<$Res>  {
  factory $SnRealmUserPermissionCopyWith(SnRealmUserPermission value, $Res Function(SnRealmUserPermission) _then) = _$SnRealmUserPermissionCopyWithImpl;
@useResult
$Res call({
 String accountId, bool? canChat, bool? canPost, bool? canComment, bool? canUploadMedia, bool? canModeratePosts, bool? canModerateChat, bool? canManageMembers, bool? canManageRealm
});




}
/// @nodoc
class _$SnRealmUserPermissionCopyWithImpl<$Res>
    implements $SnRealmUserPermissionCopyWith<$Res> {
  _$SnRealmUserPermissionCopyWithImpl(this._self, this._then);

  final SnRealmUserPermission _self;
  final $Res Function(SnRealmUserPermission) _then;

/// Create a copy of SnRealmUserPermission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? canChat = freezed,Object? canPost = freezed,Object? canComment = freezed,Object? canUploadMedia = freezed,Object? canModeratePosts = freezed,Object? canModerateChat = freezed,Object? canManageMembers = freezed,Object? canManageRealm = freezed,}) {
  return _then(_self.copyWith(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,canChat: freezed == canChat ? _self.canChat : canChat // ignore: cast_nullable_to_non_nullable
as bool?,canPost: freezed == canPost ? _self.canPost : canPost // ignore: cast_nullable_to_non_nullable
as bool?,canComment: freezed == canComment ? _self.canComment : canComment // ignore: cast_nullable_to_non_nullable
as bool?,canUploadMedia: freezed == canUploadMedia ? _self.canUploadMedia : canUploadMedia // ignore: cast_nullable_to_non_nullable
as bool?,canModeratePosts: freezed == canModeratePosts ? _self.canModeratePosts : canModeratePosts // ignore: cast_nullable_to_non_nullable
as bool?,canModerateChat: freezed == canModerateChat ? _self.canModerateChat : canModerateChat // ignore: cast_nullable_to_non_nullable
as bool?,canManageMembers: freezed == canManageMembers ? _self.canManageMembers : canManageMembers // ignore: cast_nullable_to_non_nullable
as bool?,canManageRealm: freezed == canManageRealm ? _self.canManageRealm : canManageRealm // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnRealmUserPermission].
extension SnRealmUserPermissionPatterns on SnRealmUserPermission {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnRealmUserPermission value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnRealmUserPermission() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnRealmUserPermission value)  $default,){
final _that = this;
switch (_that) {
case _SnRealmUserPermission():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnRealmUserPermission value)?  $default,){
final _that = this;
switch (_that) {
case _SnRealmUserPermission() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accountId,  bool? canChat,  bool? canPost,  bool? canComment,  bool? canUploadMedia,  bool? canModeratePosts,  bool? canModerateChat,  bool? canManageMembers,  bool? canManageRealm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnRealmUserPermission() when $default != null:
return $default(_that.accountId,_that.canChat,_that.canPost,_that.canComment,_that.canUploadMedia,_that.canModeratePosts,_that.canModerateChat,_that.canManageMembers,_that.canManageRealm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accountId,  bool? canChat,  bool? canPost,  bool? canComment,  bool? canUploadMedia,  bool? canModeratePosts,  bool? canModerateChat,  bool? canManageMembers,  bool? canManageRealm)  $default,) {final _that = this;
switch (_that) {
case _SnRealmUserPermission():
return $default(_that.accountId,_that.canChat,_that.canPost,_that.canComment,_that.canUploadMedia,_that.canModeratePosts,_that.canModerateChat,_that.canManageMembers,_that.canManageRealm);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accountId,  bool? canChat,  bool? canPost,  bool? canComment,  bool? canUploadMedia,  bool? canModeratePosts,  bool? canModerateChat,  bool? canManageMembers,  bool? canManageRealm)?  $default,) {final _that = this;
switch (_that) {
case _SnRealmUserPermission() when $default != null:
return $default(_that.accountId,_that.canChat,_that.canPost,_that.canComment,_that.canUploadMedia,_that.canModeratePosts,_that.canModerateChat,_that.canManageMembers,_that.canManageRealm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnRealmUserPermission implements SnRealmUserPermission {
  const _SnRealmUserPermission({required this.accountId, this.canChat, this.canPost, this.canComment, this.canUploadMedia, this.canModeratePosts, this.canModerateChat, this.canManageMembers, this.canManageRealm});
  factory _SnRealmUserPermission.fromJson(Map<String, dynamic> json) => _$SnRealmUserPermissionFromJson(json);

@override final  String accountId;
@override final  bool? canChat;
@override final  bool? canPost;
@override final  bool? canComment;
@override final  bool? canUploadMedia;
@override final  bool? canModeratePosts;
@override final  bool? canModerateChat;
@override final  bool? canManageMembers;
@override final  bool? canManageRealm;

/// Create a copy of SnRealmUserPermission
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnRealmUserPermissionCopyWith<_SnRealmUserPermission> get copyWith => __$SnRealmUserPermissionCopyWithImpl<_SnRealmUserPermission>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnRealmUserPermissionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnRealmUserPermission&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.canChat, canChat) || other.canChat == canChat)&&(identical(other.canPost, canPost) || other.canPost == canPost)&&(identical(other.canComment, canComment) || other.canComment == canComment)&&(identical(other.canUploadMedia, canUploadMedia) || other.canUploadMedia == canUploadMedia)&&(identical(other.canModeratePosts, canModeratePosts) || other.canModeratePosts == canModeratePosts)&&(identical(other.canModerateChat, canModerateChat) || other.canModerateChat == canModerateChat)&&(identical(other.canManageMembers, canManageMembers) || other.canManageMembers == canManageMembers)&&(identical(other.canManageRealm, canManageRealm) || other.canManageRealm == canManageRealm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,canChat,canPost,canComment,canUploadMedia,canModeratePosts,canModerateChat,canManageMembers,canManageRealm);

@override
String toString() {
  return 'SnRealmUserPermission(accountId: $accountId, canChat: $canChat, canPost: $canPost, canComment: $canComment, canUploadMedia: $canUploadMedia, canModeratePosts: $canModeratePosts, canModerateChat: $canModerateChat, canManageMembers: $canManageMembers, canManageRealm: $canManageRealm)';
}


}

/// @nodoc
abstract mixin class _$SnRealmUserPermissionCopyWith<$Res> implements $SnRealmUserPermissionCopyWith<$Res> {
  factory _$SnRealmUserPermissionCopyWith(_SnRealmUserPermission value, $Res Function(_SnRealmUserPermission) _then) = __$SnRealmUserPermissionCopyWithImpl;
@override @useResult
$Res call({
 String accountId, bool? canChat, bool? canPost, bool? canComment, bool? canUploadMedia, bool? canModeratePosts, bool? canModerateChat, bool? canManageMembers, bool? canManageRealm
});




}
/// @nodoc
class __$SnRealmUserPermissionCopyWithImpl<$Res>
    implements _$SnRealmUserPermissionCopyWith<$Res> {
  __$SnRealmUserPermissionCopyWithImpl(this._self, this._then);

  final _SnRealmUserPermission _self;
  final $Res Function(_SnRealmUserPermission) _then;

/// Create a copy of SnRealmUserPermission
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? canChat = freezed,Object? canPost = freezed,Object? canComment = freezed,Object? canUploadMedia = freezed,Object? canModeratePosts = freezed,Object? canModerateChat = freezed,Object? canManageMembers = freezed,Object? canManageRealm = freezed,}) {
  return _then(_SnRealmUserPermission(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,canChat: freezed == canChat ? _self.canChat : canChat // ignore: cast_nullable_to_non_nullable
as bool?,canPost: freezed == canPost ? _self.canPost : canPost // ignore: cast_nullable_to_non_nullable
as bool?,canComment: freezed == canComment ? _self.canComment : canComment // ignore: cast_nullable_to_non_nullable
as bool?,canUploadMedia: freezed == canUploadMedia ? _self.canUploadMedia : canUploadMedia // ignore: cast_nullable_to_non_nullable
as bool?,canModeratePosts: freezed == canModeratePosts ? _self.canModeratePosts : canModeratePosts // ignore: cast_nullable_to_non_nullable
as bool?,canModerateChat: freezed == canModerateChat ? _self.canModerateChat : canModerateChat // ignore: cast_nullable_to_non_nullable
as bool?,canManageMembers: freezed == canManageMembers ? _self.canManageMembers : canManageMembers // ignore: cast_nullable_to_non_nullable
as bool?,canManageRealm: freezed == canManageRealm ? _self.canManageRealm : canManageRealm // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
