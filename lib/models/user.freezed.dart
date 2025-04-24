// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnAccount {

 int get id; String get name; String get nick; String get language; bool get isSuperuser; SnAccountProfile get profile; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountCopyWith<SnAccount> get copyWith => _$SnAccountCopyWithImpl<SnAccount>(this as SnAccount, _$identity);

  /// Serializes this SnAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.language, language) || other.language == language)&&(identical(other.isSuperuser, isSuperuser) || other.isSuperuser == isSuperuser)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nick,language,isSuperuser,profile,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccount(id: $id, name: $name, nick: $nick, language: $language, isSuperuser: $isSuperuser, profile: $profile, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAccountCopyWith<$Res>  {
  factory $SnAccountCopyWith(SnAccount value, $Res Function(SnAccount) _then) = _$SnAccountCopyWithImpl;
@useResult
$Res call({
 int id, String name, String nick, String language, bool isSuperuser, SnAccountProfile profile, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnAccountProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$SnAccountCopyWithImpl<$Res>
    implements $SnAccountCopyWith<$Res> {
  _$SnAccountCopyWithImpl(this._self, this._then);

  final SnAccount _self;
  final $Res Function(SnAccount) _then;

/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? nick = null,Object? language = null,Object? isSuperuser = null,Object? profile = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,isSuperuser: null == isSuperuser ? _self.isSuperuser : isSuperuser // ignore: cast_nullable_to_non_nullable
as bool,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as SnAccountProfile,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountProfileCopyWith<$Res> get profile {
  
  return $SnAccountProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _SnAccount implements SnAccount {
  const _SnAccount({required this.id, required this.name, required this.nick, required this.language, required this.isSuperuser, required this.profile, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnAccount.fromJson(Map<String, dynamic> json) => _$SnAccountFromJson(json);

@override final  int id;
@override final  String name;
@override final  String nick;
@override final  String language;
@override final  bool isSuperuser;
@override final  SnAccountProfile profile;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountCopyWith<_SnAccount> get copyWith => __$SnAccountCopyWithImpl<_SnAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.language, language) || other.language == language)&&(identical(other.isSuperuser, isSuperuser) || other.isSuperuser == isSuperuser)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nick,language,isSuperuser,profile,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccount(id: $id, name: $name, nick: $nick, language: $language, isSuperuser: $isSuperuser, profile: $profile, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAccountCopyWith<$Res> implements $SnAccountCopyWith<$Res> {
  factory _$SnAccountCopyWith(_SnAccount value, $Res Function(_SnAccount) _then) = __$SnAccountCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String nick, String language, bool isSuperuser, SnAccountProfile profile, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnAccountProfileCopyWith<$Res> get profile;

}
/// @nodoc
class __$SnAccountCopyWithImpl<$Res>
    implements _$SnAccountCopyWith<$Res> {
  __$SnAccountCopyWithImpl(this._self, this._then);

  final _SnAccount _self;
  final $Res Function(_SnAccount) _then;

/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? nick = null,Object? language = null,Object? isSuperuser = null,Object? profile = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,isSuperuser: null == isSuperuser ? _self.isSuperuser : isSuperuser // ignore: cast_nullable_to_non_nullable
as bool,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as SnAccountProfile,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountProfileCopyWith<$Res> get profile {
  
  return $SnAccountProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$SnAccountProfile {

 int get id; String? get firstName; String? get middleName; String? get lastName; String? get bio; SnCloudFile? get picture; SnCloudFile? get background; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountProfileCopyWith<SnAccountProfile> get copyWith => _$SnAccountProfileCopyWithImpl<SnAccountProfile>(this as SnAccountProfile, _$identity);

  /// Serializes this SnAccountProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,middleName,lastName,bio,picture,background,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountProfile(id: $id, firstName: $firstName, middleName: $middleName, lastName: $lastName, bio: $bio, picture: $picture, background: $background, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAccountProfileCopyWith<$Res>  {
  factory $SnAccountProfileCopyWith(SnAccountProfile value, $Res Function(SnAccountProfile) _then) = _$SnAccountProfileCopyWithImpl;
@useResult
$Res call({
 int id, String? firstName, String? middleName, String? lastName, String? bio, SnCloudFile? picture, SnCloudFile? background, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnCloudFileCopyWith<$Res>? get picture;$SnCloudFileCopyWith<$Res>? get background;

}
/// @nodoc
class _$SnAccountProfileCopyWithImpl<$Res>
    implements $SnAccountProfileCopyWith<$Res> {
  _$SnAccountProfileCopyWithImpl(this._self, this._then);

  final SnAccountProfile _self;
  final $Res Function(SnAccountProfile) _then;

/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = freezed,Object? middleName = freezed,Object? lastName = freezed,Object? bio = freezed,Object? picture = freezed,Object? background = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,middleName: freezed == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnAccountProfile
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
}/// Create a copy of SnAccountProfile
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

class _SnAccountProfile implements SnAccountProfile {
  const _SnAccountProfile({required this.id, required this.firstName, required this.middleName, required this.lastName, required this.bio, required this.picture, required this.background, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnAccountProfile.fromJson(Map<String, dynamic> json) => _$SnAccountProfileFromJson(json);

@override final  int id;
@override final  String? firstName;
@override final  String? middleName;
@override final  String? lastName;
@override final  String? bio;
@override final  SnCloudFile? picture;
@override final  SnCloudFile? background;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountProfileCopyWith<_SnAccountProfile> get copyWith => __$SnAccountProfileCopyWithImpl<_SnAccountProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,middleName,lastName,bio,picture,background,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountProfile(id: $id, firstName: $firstName, middleName: $middleName, lastName: $lastName, bio: $bio, picture: $picture, background: $background, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAccountProfileCopyWith<$Res> implements $SnAccountProfileCopyWith<$Res> {
  factory _$SnAccountProfileCopyWith(_SnAccountProfile value, $Res Function(_SnAccountProfile) _then) = __$SnAccountProfileCopyWithImpl;
@override @useResult
$Res call({
 int id, String? firstName, String? middleName, String? lastName, String? bio, SnCloudFile? picture, SnCloudFile? background, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnCloudFileCopyWith<$Res>? get picture;@override $SnCloudFileCopyWith<$Res>? get background;

}
/// @nodoc
class __$SnAccountProfileCopyWithImpl<$Res>
    implements _$SnAccountProfileCopyWith<$Res> {
  __$SnAccountProfileCopyWithImpl(this._self, this._then);

  final _SnAccountProfile _self;
  final $Res Function(_SnAccountProfile) _then;

/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = freezed,Object? middleName = freezed,Object? lastName = freezed,Object? bio = freezed,Object? picture = freezed,Object? background = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAccountProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,middleName: freezed == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnAccountProfile
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
}/// Create a copy of SnAccountProfile
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
