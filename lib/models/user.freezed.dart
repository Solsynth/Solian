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

 String get id; String get name; String get nick; String get language; bool get isSuperuser; SnAccountProfile get profile; List<SnAccountBadge> get badges; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountCopyWith<SnAccount> get copyWith => _$SnAccountCopyWithImpl<SnAccount>(this as SnAccount, _$identity);

  /// Serializes this SnAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.language, language) || other.language == language)&&(identical(other.isSuperuser, isSuperuser) || other.isSuperuser == isSuperuser)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.badges, badges)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nick,language,isSuperuser,profile,const DeepCollectionEquality().hash(badges),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccount(id: $id, name: $name, nick: $nick, language: $language, isSuperuser: $isSuperuser, profile: $profile, badges: $badges, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAccountCopyWith<$Res>  {
  factory $SnAccountCopyWith(SnAccount value, $Res Function(SnAccount) _then) = _$SnAccountCopyWithImpl;
@useResult
$Res call({
 String id, String name, String nick, String language, bool isSuperuser, SnAccountProfile profile, List<SnAccountBadge> badges, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? nick = null,Object? language = null,Object? isSuperuser = null,Object? profile = null,Object? badges = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,isSuperuser: null == isSuperuser ? _self.isSuperuser : isSuperuser // ignore: cast_nullable_to_non_nullable
as bool,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as SnAccountProfile,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<SnAccountBadge>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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
  const _SnAccount({required this.id, required this.name, required this.nick, required this.language, required this.isSuperuser, required this.profile, final  List<SnAccountBadge> badges = const [], required this.createdAt, required this.updatedAt, required this.deletedAt}): _badges = badges;
  factory _SnAccount.fromJson(Map<String, dynamic> json) => _$SnAccountFromJson(json);

@override final  String id;
@override final  String name;
@override final  String nick;
@override final  String language;
@override final  bool isSuperuser;
@override final  SnAccountProfile profile;
 final  List<SnAccountBadge> _badges;
@override@JsonKey() List<SnAccountBadge> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.language, language) || other.language == language)&&(identical(other.isSuperuser, isSuperuser) || other.isSuperuser == isSuperuser)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other._badges, _badges)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nick,language,isSuperuser,profile,const DeepCollectionEquality().hash(_badges),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccount(id: $id, name: $name, nick: $nick, language: $language, isSuperuser: $isSuperuser, profile: $profile, badges: $badges, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAccountCopyWith<$Res> implements $SnAccountCopyWith<$Res> {
  factory _$SnAccountCopyWith(_SnAccount value, $Res Function(_SnAccount) _then) = __$SnAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String nick, String language, bool isSuperuser, SnAccountProfile profile, List<SnAccountBadge> badges, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? nick = null,Object? language = null,Object? isSuperuser = null,Object? profile = null,Object? badges = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,isSuperuser: null == isSuperuser ? _self.isSuperuser : isSuperuser // ignore: cast_nullable_to_non_nullable
as bool,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as SnAccountProfile,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<SnAccountBadge>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

 String get id; String? get firstName; String? get middleName; String? get lastName; String get bio; String get gender; String get pronouns; String get location; String get timeZone; DateTime? get birthday; DateTime? get lastSeenAt; SnAccountBadge? get activeBadge; int get experience; int get level; double get levelingProgress; SnCloudFile? get picture; SnCloudFile? get background; SnVerificationMark? get verification; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountProfileCopyWith<SnAccountProfile> get copyWith => _$SnAccountProfileCopyWithImpl<SnAccountProfile>(this as SnAccountProfile, _$identity);

  /// Serializes this SnAccountProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.pronouns, pronouns) || other.pronouns == pronouns)&&(identical(other.location, location) || other.location == location)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.activeBadge, activeBadge) || other.activeBadge == activeBadge)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.level, level) || other.level == level)&&(identical(other.levelingProgress, levelingProgress) || other.levelingProgress == levelingProgress)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,middleName,lastName,bio,gender,pronouns,location,timeZone,birthday,lastSeenAt,activeBadge,experience,level,levelingProgress,picture,background,verification,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'SnAccountProfile(id: $id, firstName: $firstName, middleName: $middleName, lastName: $lastName, bio: $bio, gender: $gender, pronouns: $pronouns, location: $location, timeZone: $timeZone, birthday: $birthday, lastSeenAt: $lastSeenAt, activeBadge: $activeBadge, experience: $experience, level: $level, levelingProgress: $levelingProgress, picture: $picture, background: $background, verification: $verification, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAccountProfileCopyWith<$Res>  {
  factory $SnAccountProfileCopyWith(SnAccountProfile value, $Res Function(SnAccountProfile) _then) = _$SnAccountProfileCopyWithImpl;
@useResult
$Res call({
 String id, String? firstName, String? middleName, String? lastName, String bio, String gender, String pronouns, String location, String timeZone, DateTime? birthday, DateTime? lastSeenAt, SnAccountBadge? activeBadge, int experience, int level, double levelingProgress, SnCloudFile? picture, SnCloudFile? background, SnVerificationMark? verification, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnAccountBadgeCopyWith<$Res>? get activeBadge;$SnCloudFileCopyWith<$Res>? get picture;$SnCloudFileCopyWith<$Res>? get background;$SnVerificationMarkCopyWith<$Res>? get verification;

}
/// @nodoc
class _$SnAccountProfileCopyWithImpl<$Res>
    implements $SnAccountProfileCopyWith<$Res> {
  _$SnAccountProfileCopyWithImpl(this._self, this._then);

  final SnAccountProfile _self;
  final $Res Function(SnAccountProfile) _then;

/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = freezed,Object? middleName = freezed,Object? lastName = freezed,Object? bio = null,Object? gender = null,Object? pronouns = null,Object? location = null,Object? timeZone = null,Object? birthday = freezed,Object? lastSeenAt = freezed,Object? activeBadge = freezed,Object? experience = null,Object? level = null,Object? levelingProgress = null,Object? picture = freezed,Object? background = freezed,Object? verification = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,middleName: freezed == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,pronouns: null == pronouns ? _self.pronouns : pronouns // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,activeBadge: freezed == activeBadge ? _self.activeBadge : activeBadge // ignore: cast_nullable_to_non_nullable
as SnAccountBadge?,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,levelingProgress: null == levelingProgress ? _self.levelingProgress : levelingProgress // ignore: cast_nullable_to_non_nullable
as double,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountBadgeCopyWith<$Res>? get activeBadge {
    if (_self.activeBadge == null) {
    return null;
  }

  return $SnAccountBadgeCopyWith<$Res>(_self.activeBadge!, (value) {
    return _then(_self.copyWith(activeBadge: value));
  });
}/// Create a copy of SnAccountProfile
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
}/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $SnVerificationMarkCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _SnAccountProfile implements SnAccountProfile {
  const _SnAccountProfile({required this.id, required this.firstName, required this.middleName, required this.lastName, this.bio = '', this.gender = '', this.pronouns = '', this.location = '', this.timeZone = '', this.birthday, this.lastSeenAt, this.activeBadge, required this.experience, required this.level, required this.levelingProgress, required this.picture, required this.background, required this.verification, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnAccountProfile.fromJson(Map<String, dynamic> json) => _$SnAccountProfileFromJson(json);

@override final  String id;
@override final  String? firstName;
@override final  String? middleName;
@override final  String? lastName;
@override@JsonKey() final  String bio;
@override@JsonKey() final  String gender;
@override@JsonKey() final  String pronouns;
@override@JsonKey() final  String location;
@override@JsonKey() final  String timeZone;
@override final  DateTime? birthday;
@override final  DateTime? lastSeenAt;
@override final  SnAccountBadge? activeBadge;
@override final  int experience;
@override final  int level;
@override final  double levelingProgress;
@override final  SnCloudFile? picture;
@override final  SnCloudFile? background;
@override final  SnVerificationMark? verification;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.pronouns, pronouns) || other.pronouns == pronouns)&&(identical(other.location, location) || other.location == location)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.activeBadge, activeBadge) || other.activeBadge == activeBadge)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.level, level) || other.level == level)&&(identical(other.levelingProgress, levelingProgress) || other.levelingProgress == levelingProgress)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,middleName,lastName,bio,gender,pronouns,location,timeZone,birthday,lastSeenAt,activeBadge,experience,level,levelingProgress,picture,background,verification,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'SnAccountProfile(id: $id, firstName: $firstName, middleName: $middleName, lastName: $lastName, bio: $bio, gender: $gender, pronouns: $pronouns, location: $location, timeZone: $timeZone, birthday: $birthday, lastSeenAt: $lastSeenAt, activeBadge: $activeBadge, experience: $experience, level: $level, levelingProgress: $levelingProgress, picture: $picture, background: $background, verification: $verification, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAccountProfileCopyWith<$Res> implements $SnAccountProfileCopyWith<$Res> {
  factory _$SnAccountProfileCopyWith(_SnAccountProfile value, $Res Function(_SnAccountProfile) _then) = __$SnAccountProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String? firstName, String? middleName, String? lastName, String bio, String gender, String pronouns, String location, String timeZone, DateTime? birthday, DateTime? lastSeenAt, SnAccountBadge? activeBadge, int experience, int level, double levelingProgress, SnCloudFile? picture, SnCloudFile? background, SnVerificationMark? verification, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnAccountBadgeCopyWith<$Res>? get activeBadge;@override $SnCloudFileCopyWith<$Res>? get picture;@override $SnCloudFileCopyWith<$Res>? get background;@override $SnVerificationMarkCopyWith<$Res>? get verification;

}
/// @nodoc
class __$SnAccountProfileCopyWithImpl<$Res>
    implements _$SnAccountProfileCopyWith<$Res> {
  __$SnAccountProfileCopyWithImpl(this._self, this._then);

  final _SnAccountProfile _self;
  final $Res Function(_SnAccountProfile) _then;

/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = freezed,Object? middleName = freezed,Object? lastName = freezed,Object? bio = null,Object? gender = null,Object? pronouns = null,Object? location = null,Object? timeZone = null,Object? birthday = freezed,Object? lastSeenAt = freezed,Object? activeBadge = freezed,Object? experience = null,Object? level = null,Object? levelingProgress = null,Object? picture = freezed,Object? background = freezed,Object? verification = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAccountProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,middleName: freezed == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,pronouns: null == pronouns ? _self.pronouns : pronouns // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,activeBadge: freezed == activeBadge ? _self.activeBadge : activeBadge // ignore: cast_nullable_to_non_nullable
as SnAccountBadge?,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,levelingProgress: null == levelingProgress ? _self.levelingProgress : levelingProgress // ignore: cast_nullable_to_non_nullable
as double,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountBadgeCopyWith<$Res>? get activeBadge {
    if (_self.activeBadge == null) {
    return null;
  }

  return $SnAccountBadgeCopyWith<$Res>(_self.activeBadge!, (value) {
    return _then(_self.copyWith(activeBadge: value));
  });
}/// Create a copy of SnAccountProfile
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
}/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $SnVerificationMarkCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}
}


/// @nodoc
mixin _$SnAccountStatus {

 String get id; int get attitude; bool get isOnline; bool get isInvisible; bool get isNotDisturb; bool get isCustomized; String get label; DateTime? get clearedAt; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountStatusCopyWith<SnAccountStatus> get copyWith => _$SnAccountStatusCopyWithImpl<SnAccountStatus>(this as SnAccountStatus, _$identity);

  /// Serializes this SnAccountStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.attitude, attitude) || other.attitude == attitude)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isInvisible, isInvisible) || other.isInvisible == isInvisible)&&(identical(other.isNotDisturb, isNotDisturb) || other.isNotDisturb == isNotDisturb)&&(identical(other.isCustomized, isCustomized) || other.isCustomized == isCustomized)&&(identical(other.label, label) || other.label == label)&&(identical(other.clearedAt, clearedAt) || other.clearedAt == clearedAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,attitude,isOnline,isInvisible,isNotDisturb,isCustomized,label,clearedAt,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountStatus(id: $id, attitude: $attitude, isOnline: $isOnline, isInvisible: $isInvisible, isNotDisturb: $isNotDisturb, isCustomized: $isCustomized, label: $label, clearedAt: $clearedAt, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAccountStatusCopyWith<$Res>  {
  factory $SnAccountStatusCopyWith(SnAccountStatus value, $Res Function(SnAccountStatus) _then) = _$SnAccountStatusCopyWithImpl;
@useResult
$Res call({
 String id, int attitude, bool isOnline, bool isInvisible, bool isNotDisturb, bool isCustomized, String label, DateTime? clearedAt, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnAccountStatusCopyWithImpl<$Res>
    implements $SnAccountStatusCopyWith<$Res> {
  _$SnAccountStatusCopyWithImpl(this._self, this._then);

  final SnAccountStatus _self;
  final $Res Function(SnAccountStatus) _then;

/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? attitude = null,Object? isOnline = null,Object? isInvisible = null,Object? isNotDisturb = null,Object? isCustomized = null,Object? label = null,Object? clearedAt = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,isInvisible: null == isInvisible ? _self.isInvisible : isInvisible // ignore: cast_nullable_to_non_nullable
as bool,isNotDisturb: null == isNotDisturb ? _self.isNotDisturb : isNotDisturb // ignore: cast_nullable_to_non_nullable
as bool,isCustomized: null == isCustomized ? _self.isCustomized : isCustomized // ignore: cast_nullable_to_non_nullable
as bool,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,clearedAt: freezed == clearedAt ? _self.clearedAt : clearedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SnAccountStatus implements SnAccountStatus {
  const _SnAccountStatus({required this.id, required this.attitude, required this.isOnline, required this.isInvisible, required this.isNotDisturb, required this.isCustomized, this.label = "", required this.clearedAt, required this.accountId, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnAccountStatus.fromJson(Map<String, dynamic> json) => _$SnAccountStatusFromJson(json);

@override final  String id;
@override final  int attitude;
@override final  bool isOnline;
@override final  bool isInvisible;
@override final  bool isNotDisturb;
@override final  bool isCustomized;
@override@JsonKey() final  String label;
@override final  DateTime? clearedAt;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountStatusCopyWith<_SnAccountStatus> get copyWith => __$SnAccountStatusCopyWithImpl<_SnAccountStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.attitude, attitude) || other.attitude == attitude)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isInvisible, isInvisible) || other.isInvisible == isInvisible)&&(identical(other.isNotDisturb, isNotDisturb) || other.isNotDisturb == isNotDisturb)&&(identical(other.isCustomized, isCustomized) || other.isCustomized == isCustomized)&&(identical(other.label, label) || other.label == label)&&(identical(other.clearedAt, clearedAt) || other.clearedAt == clearedAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,attitude,isOnline,isInvisible,isNotDisturb,isCustomized,label,clearedAt,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountStatus(id: $id, attitude: $attitude, isOnline: $isOnline, isInvisible: $isInvisible, isNotDisturb: $isNotDisturb, isCustomized: $isCustomized, label: $label, clearedAt: $clearedAt, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAccountStatusCopyWith<$Res> implements $SnAccountStatusCopyWith<$Res> {
  factory _$SnAccountStatusCopyWith(_SnAccountStatus value, $Res Function(_SnAccountStatus) _then) = __$SnAccountStatusCopyWithImpl;
@override @useResult
$Res call({
 String id, int attitude, bool isOnline, bool isInvisible, bool isNotDisturb, bool isCustomized, String label, DateTime? clearedAt, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnAccountStatusCopyWithImpl<$Res>
    implements _$SnAccountStatusCopyWith<$Res> {
  __$SnAccountStatusCopyWithImpl(this._self, this._then);

  final _SnAccountStatus _self;
  final $Res Function(_SnAccountStatus) _then;

/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? attitude = null,Object? isOnline = null,Object? isInvisible = null,Object? isNotDisturb = null,Object? isCustomized = null,Object? label = null,Object? clearedAt = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAccountStatus(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,isInvisible: null == isInvisible ? _self.isInvisible : isInvisible // ignore: cast_nullable_to_non_nullable
as bool,isNotDisturb: null == isNotDisturb ? _self.isNotDisturb : isNotDisturb // ignore: cast_nullable_to_non_nullable
as bool,isCustomized: null == isCustomized ? _self.isCustomized : isCustomized // ignore: cast_nullable_to_non_nullable
as bool,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,clearedAt: freezed == clearedAt ? _self.clearedAt : clearedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnAccountBadge {

 String get id; String get type; String? get label; String? get caption; Map<String, dynamic> get meta; DateTime? get expiredAt; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get activatedAt; DateTime? get deletedAt;
/// Create a copy of SnAccountBadge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountBadgeCopyWith<SnAccountBadge> get copyWith => _$SnAccountBadgeCopyWithImpl<SnAccountBadge>(this as SnAccountBadge, _$identity);

  /// Serializes this SnAccountBadge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.caption, caption) || other.caption == caption)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,label,caption,const DeepCollectionEquality().hash(meta),expiredAt,accountId,createdAt,updatedAt,activatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountBadge(id: $id, type: $type, label: $label, caption: $caption, meta: $meta, expiredAt: $expiredAt, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, activatedAt: $activatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAccountBadgeCopyWith<$Res>  {
  factory $SnAccountBadgeCopyWith(SnAccountBadge value, $Res Function(SnAccountBadge) _then) = _$SnAccountBadgeCopyWithImpl;
@useResult
$Res call({
 String id, String type, String? label, String? caption, Map<String, dynamic> meta, DateTime? expiredAt, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? activatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnAccountBadgeCopyWithImpl<$Res>
    implements $SnAccountBadgeCopyWith<$Res> {
  _$SnAccountBadgeCopyWithImpl(this._self, this._then);

  final SnAccountBadge _self;
  final $Res Function(SnAccountBadge) _then;

/// Create a copy of SnAccountBadge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? label = freezed,Object? caption = freezed,Object? meta = null,Object? expiredAt = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? activatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SnAccountBadge implements SnAccountBadge {
  const _SnAccountBadge({required this.id, required this.type, required this.label, required this.caption, required final  Map<String, dynamic> meta, required this.expiredAt, required this.accountId, required this.createdAt, required this.updatedAt, required this.activatedAt, required this.deletedAt}): _meta = meta;
  factory _SnAccountBadge.fromJson(Map<String, dynamic> json) => _$SnAccountBadgeFromJson(json);

@override final  String id;
@override final  String type;
@override final  String? label;
@override final  String? caption;
 final  Map<String, dynamic> _meta;
@override Map<String, dynamic> get meta {
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meta);
}

@override final  DateTime? expiredAt;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? activatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAccountBadge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountBadgeCopyWith<_SnAccountBadge> get copyWith => __$SnAccountBadgeCopyWithImpl<_SnAccountBadge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountBadgeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.caption, caption) || other.caption == caption)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,label,caption,const DeepCollectionEquality().hash(_meta),expiredAt,accountId,createdAt,updatedAt,activatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountBadge(id: $id, type: $type, label: $label, caption: $caption, meta: $meta, expiredAt: $expiredAt, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, activatedAt: $activatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAccountBadgeCopyWith<$Res> implements $SnAccountBadgeCopyWith<$Res> {
  factory _$SnAccountBadgeCopyWith(_SnAccountBadge value, $Res Function(_SnAccountBadge) _then) = __$SnAccountBadgeCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String? label, String? caption, Map<String, dynamic> meta, DateTime? expiredAt, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? activatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnAccountBadgeCopyWithImpl<$Res>
    implements _$SnAccountBadgeCopyWith<$Res> {
  __$SnAccountBadgeCopyWithImpl(this._self, this._then);

  final _SnAccountBadge _self;
  final $Res Function(_SnAccountBadge) _then;

/// Create a copy of SnAccountBadge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? label = freezed,Object? caption = freezed,Object? meta = null,Object? expiredAt = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? activatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_SnAccountBadge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnContactMethod {

 String get id; int get type; DateTime? get verifiedAt; bool get isPrimary; String get content; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnContactMethod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnContactMethodCopyWith<SnContactMethod> get copyWith => _$SnContactMethodCopyWithImpl<SnContactMethod>(this as SnContactMethod, _$identity);

  /// Serializes this SnContactMethod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnContactMethod&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.content, content) || other.content == content)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,verifiedAt,isPrimary,content,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnContactMethod(id: $id, type: $type, verifiedAt: $verifiedAt, isPrimary: $isPrimary, content: $content, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnContactMethodCopyWith<$Res>  {
  factory $SnContactMethodCopyWith(SnContactMethod value, $Res Function(SnContactMethod) _then) = _$SnContactMethodCopyWithImpl;
@useResult
$Res call({
 String id, int type, DateTime? verifiedAt, bool isPrimary, String content, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnContactMethodCopyWithImpl<$Res>
    implements $SnContactMethodCopyWith<$Res> {
  _$SnContactMethodCopyWithImpl(this._self, this._then);

  final SnContactMethod _self;
  final $Res Function(SnContactMethod) _then;

/// Create a copy of SnContactMethod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? verifiedAt = freezed,Object? isPrimary = null,Object? content = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SnContactMethod implements SnContactMethod {
  const _SnContactMethod({required this.id, required this.type, required this.verifiedAt, required this.isPrimary, required this.content, required this.accountId, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnContactMethod.fromJson(Map<String, dynamic> json) => _$SnContactMethodFromJson(json);

@override final  String id;
@override final  int type;
@override final  DateTime? verifiedAt;
@override final  bool isPrimary;
@override final  String content;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnContactMethod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnContactMethodCopyWith<_SnContactMethod> get copyWith => __$SnContactMethodCopyWithImpl<_SnContactMethod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnContactMethodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnContactMethod&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.content, content) || other.content == content)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,verifiedAt,isPrimary,content,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnContactMethod(id: $id, type: $type, verifiedAt: $verifiedAt, isPrimary: $isPrimary, content: $content, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnContactMethodCopyWith<$Res> implements $SnContactMethodCopyWith<$Res> {
  factory _$SnContactMethodCopyWith(_SnContactMethod value, $Res Function(_SnContactMethod) _then) = __$SnContactMethodCopyWithImpl;
@override @useResult
$Res call({
 String id, int type, DateTime? verifiedAt, bool isPrimary, String content, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnContactMethodCopyWithImpl<$Res>
    implements _$SnContactMethodCopyWith<$Res> {
  __$SnContactMethodCopyWithImpl(this._self, this._then);

  final _SnContactMethod _self;
  final $Res Function(_SnContactMethod) _then;

/// Create a copy of SnContactMethod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? verifiedAt = freezed,Object? isPrimary = null,Object? content = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnContactMethod(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnNotification {

 DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; String get id; String get topic; String get title; String get subtitle; String get content; Map<String, dynamic> get meta; int get priority; DateTime? get viewedAt; String get accountId;
/// Create a copy of SnNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnNotificationCopyWith<SnNotification> get copyWith => _$SnNotificationCopyWithImpl<SnNotification>(this as SnNotification, _$identity);

  /// Serializes this SnNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnNotification&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt)&&(identical(other.accountId, accountId) || other.accountId == accountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,deletedAt,id,topic,title,subtitle,content,const DeepCollectionEquality().hash(meta),priority,viewedAt,accountId);

@override
String toString() {
  return 'SnNotification(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, topic: $topic, title: $title, subtitle: $subtitle, content: $content, meta: $meta, priority: $priority, viewedAt: $viewedAt, accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class $SnNotificationCopyWith<$Res>  {
  factory $SnNotificationCopyWith(SnNotification value, $Res Function(SnNotification) _then) = _$SnNotificationCopyWithImpl;
@useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, String topic, String title, String subtitle, String content, Map<String, dynamic> meta, int priority, DateTime? viewedAt, String accountId
});




}
/// @nodoc
class _$SnNotificationCopyWithImpl<$Res>
    implements $SnNotificationCopyWith<$Res> {
  _$SnNotificationCopyWithImpl(this._self, this._then);

  final SnNotification _self;
  final $Res Function(SnNotification) _then;

/// Create a copy of SnNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? topic = null,Object? title = null,Object? subtitle = null,Object? content = null,Object? meta = null,Object? priority = null,Object? viewedAt = freezed,Object? accountId = null,}) {
  return _then(_self.copyWith(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,viewedAt: freezed == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SnNotification implements SnNotification {
  const _SnNotification({required this.createdAt, required this.updatedAt, required this.deletedAt, required this.id, required this.topic, required this.title, this.subtitle = '', required this.content, final  Map<String, dynamic> meta = const {}, required this.priority, required this.viewedAt, required this.accountId}): _meta = meta;
  factory _SnNotification.fromJson(Map<String, dynamic> json) => _$SnNotificationFromJson(json);

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  String id;
@override final  String topic;
@override final  String title;
@override@JsonKey() final  String subtitle;
@override final  String content;
 final  Map<String, dynamic> _meta;
@override@JsonKey() Map<String, dynamic> get meta {
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meta);
}

@override final  int priority;
@override final  DateTime? viewedAt;
@override final  String accountId;

/// Create a copy of SnNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnNotificationCopyWith<_SnNotification> get copyWith => __$SnNotificationCopyWithImpl<_SnNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnNotification&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt)&&(identical(other.accountId, accountId) || other.accountId == accountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,deletedAt,id,topic,title,subtitle,content,const DeepCollectionEquality().hash(_meta),priority,viewedAt,accountId);

@override
String toString() {
  return 'SnNotification(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, topic: $topic, title: $title, subtitle: $subtitle, content: $content, meta: $meta, priority: $priority, viewedAt: $viewedAt, accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class _$SnNotificationCopyWith<$Res> implements $SnNotificationCopyWith<$Res> {
  factory _$SnNotificationCopyWith(_SnNotification value, $Res Function(_SnNotification) _then) = __$SnNotificationCopyWithImpl;
@override @useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, String topic, String title, String subtitle, String content, Map<String, dynamic> meta, int priority, DateTime? viewedAt, String accountId
});




}
/// @nodoc
class __$SnNotificationCopyWithImpl<$Res>
    implements _$SnNotificationCopyWith<$Res> {
  __$SnNotificationCopyWithImpl(this._self, this._then);

  final _SnNotification _self;
  final $Res Function(_SnNotification) _then;

/// Create a copy of SnNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? topic = null,Object? title = null,Object? subtitle = null,Object? content = null,Object? meta = null,Object? priority = null,Object? viewedAt = freezed,Object? accountId = null,}) {
  return _then(_SnNotification(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,viewedAt: freezed == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SnVerificationMark {

 int get type; String? get title; String? get description; String? get verifiedBy;
/// Create a copy of SnVerificationMark
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<SnVerificationMark> get copyWith => _$SnVerificationMarkCopyWithImpl<SnVerificationMark>(this as SnVerificationMark, _$identity);

  /// Serializes this SnVerificationMark to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnVerificationMark&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,title,description,verifiedBy);

@override
String toString() {
  return 'SnVerificationMark(type: $type, title: $title, description: $description, verifiedBy: $verifiedBy)';
}


}

/// @nodoc
abstract mixin class $SnVerificationMarkCopyWith<$Res>  {
  factory $SnVerificationMarkCopyWith(SnVerificationMark value, $Res Function(SnVerificationMark) _then) = _$SnVerificationMarkCopyWithImpl;
@useResult
$Res call({
 int type, String? title, String? description, String? verifiedBy
});




}
/// @nodoc
class _$SnVerificationMarkCopyWithImpl<$Res>
    implements $SnVerificationMarkCopyWith<$Res> {
  _$SnVerificationMarkCopyWithImpl(this._self, this._then);

  final SnVerificationMark _self;
  final $Res Function(SnVerificationMark) _then;

/// Create a copy of SnVerificationMark
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? title = freezed,Object? description = freezed,Object? verifiedBy = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SnVerificationMark implements SnVerificationMark {
  const _SnVerificationMark({required this.type, required this.title, required this.description, required this.verifiedBy});
  factory _SnVerificationMark.fromJson(Map<String, dynamic> json) => _$SnVerificationMarkFromJson(json);

@override final  int type;
@override final  String? title;
@override final  String? description;
@override final  String? verifiedBy;

/// Create a copy of SnVerificationMark
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnVerificationMarkCopyWith<_SnVerificationMark> get copyWith => __$SnVerificationMarkCopyWithImpl<_SnVerificationMark>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnVerificationMarkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnVerificationMark&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,title,description,verifiedBy);

@override
String toString() {
  return 'SnVerificationMark(type: $type, title: $title, description: $description, verifiedBy: $verifiedBy)';
}


}

/// @nodoc
abstract mixin class _$SnVerificationMarkCopyWith<$Res> implements $SnVerificationMarkCopyWith<$Res> {
  factory _$SnVerificationMarkCopyWith(_SnVerificationMark value, $Res Function(_SnVerificationMark) _then) = __$SnVerificationMarkCopyWithImpl;
@override @useResult
$Res call({
 int type, String? title, String? description, String? verifiedBy
});




}
/// @nodoc
class __$SnVerificationMarkCopyWithImpl<$Res>
    implements _$SnVerificationMarkCopyWith<$Res> {
  __$SnVerificationMarkCopyWithImpl(this._self, this._then);

  final _SnVerificationMark _self;
  final $Res Function(_SnVerificationMark) _then;

/// Create a copy of SnVerificationMark
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? title = freezed,Object? description = freezed,Object? verifiedBy = freezed,}) {
  return _then(_SnVerificationMark(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
