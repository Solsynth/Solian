// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppToken {

 String get token;
/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppTokenCopyWith<AppToken> get copyWith => _$AppTokenCopyWithImpl<AppToken>(this as AppToken, _$identity);

  /// Serializes this AppToken to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppToken&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'AppToken(token: $token)';
}


}

/// @nodoc
abstract mixin class $AppTokenCopyWith<$Res>  {
  factory $AppTokenCopyWith(AppToken value, $Res Function(AppToken) _then) = _$AppTokenCopyWithImpl;
@useResult
$Res call({
 String token
});




}
/// @nodoc
class _$AppTokenCopyWithImpl<$Res>
    implements $AppTokenCopyWith<$Res> {
  _$AppTokenCopyWithImpl(this._self, this._then);

  final AppToken _self;
  final $Res Function(AppToken) _then;

/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _AppToken implements AppToken {
  const _AppToken({required this.token});
  factory _AppToken.fromJson(Map<String, dynamic> json) => _$AppTokenFromJson(json);

@override final  String token;

/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppTokenCopyWith<_AppToken> get copyWith => __$AppTokenCopyWithImpl<_AppToken>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppTokenToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppToken&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'AppToken(token: $token)';
}


}

/// @nodoc
abstract mixin class _$AppTokenCopyWith<$Res> implements $AppTokenCopyWith<$Res> {
  factory _$AppTokenCopyWith(_AppToken value, $Res Function(_AppToken) _then) = __$AppTokenCopyWithImpl;
@override @useResult
$Res call({
 String token
});




}
/// @nodoc
class __$AppTokenCopyWithImpl<$Res>
    implements _$AppTokenCopyWith<$Res> {
  __$AppTokenCopyWithImpl(this._self, this._then);

  final _AppToken _self;
  final $Res Function(_AppToken) _then;

/// Create a copy of AppToken
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,}) {
  return _then(_AppToken(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SnAuthChallenge {

 String get id; DateTime get expiredAt; int get stepRemain; int get stepTotal; int get failedAttempts; int get platform; int get type; List<String> get blacklistFactors; List<dynamic> get audiences; List<dynamic> get scopes; String get ipAddress; String get userAgent; String get deviceId; String? get nonce; String? get location; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAuthChallenge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAuthChallengeCopyWith<SnAuthChallenge> get copyWith => _$SnAuthChallengeCopyWithImpl<SnAuthChallenge>(this as SnAuthChallenge, _$identity);

  /// Serializes this SnAuthChallenge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAuthChallenge&&(identical(other.id, id) || other.id == id)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.stepRemain, stepRemain) || other.stepRemain == stepRemain)&&(identical(other.stepTotal, stepTotal) || other.stepTotal == stepTotal)&&(identical(other.failedAttempts, failedAttempts) || other.failedAttempts == failedAttempts)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.blacklistFactors, blacklistFactors)&&const DeepCollectionEquality().equals(other.audiences, audiences)&&const DeepCollectionEquality().equals(other.scopes, scopes)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&(identical(other.location, location) || other.location == location)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,expiredAt,stepRemain,stepTotal,failedAttempts,platform,type,const DeepCollectionEquality().hash(blacklistFactors),const DeepCollectionEquality().hash(audiences),const DeepCollectionEquality().hash(scopes),ipAddress,userAgent,deviceId,nonce,location,accountId,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'SnAuthChallenge(id: $id, expiredAt: $expiredAt, stepRemain: $stepRemain, stepTotal: $stepTotal, failedAttempts: $failedAttempts, platform: $platform, type: $type, blacklistFactors: $blacklistFactors, audiences: $audiences, scopes: $scopes, ipAddress: $ipAddress, userAgent: $userAgent, deviceId: $deviceId, nonce: $nonce, location: $location, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAuthChallengeCopyWith<$Res>  {
  factory $SnAuthChallengeCopyWith(SnAuthChallenge value, $Res Function(SnAuthChallenge) _then) = _$SnAuthChallengeCopyWithImpl;
@useResult
$Res call({
 String id, DateTime expiredAt, int stepRemain, int stepTotal, int failedAttempts, int platform, int type, List<String> blacklistFactors, List<dynamic> audiences, List<dynamic> scopes, String ipAddress, String userAgent, String deviceId, String? nonce, String? location, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnAuthChallengeCopyWithImpl<$Res>
    implements $SnAuthChallengeCopyWith<$Res> {
  _$SnAuthChallengeCopyWithImpl(this._self, this._then);

  final SnAuthChallenge _self;
  final $Res Function(SnAuthChallenge) _then;

/// Create a copy of SnAuthChallenge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? expiredAt = null,Object? stepRemain = null,Object? stepTotal = null,Object? failedAttempts = null,Object? platform = null,Object? type = null,Object? blacklistFactors = null,Object? audiences = null,Object? scopes = null,Object? ipAddress = null,Object? userAgent = null,Object? deviceId = null,Object? nonce = freezed,Object? location = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,expiredAt: null == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime,stepRemain: null == stepRemain ? _self.stepRemain : stepRemain // ignore: cast_nullable_to_non_nullable
as int,stepTotal: null == stepTotal ? _self.stepTotal : stepTotal // ignore: cast_nullable_to_non_nullable
as int,failedAttempts: null == failedAttempts ? _self.failedAttempts : failedAttempts // ignore: cast_nullable_to_non_nullable
as int,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,blacklistFactors: null == blacklistFactors ? _self.blacklistFactors : blacklistFactors // ignore: cast_nullable_to_non_nullable
as List<String>,audiences: null == audiences ? _self.audiences : audiences // ignore: cast_nullable_to_non_nullable
as List<dynamic>,scopes: null == scopes ? _self.scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<dynamic>,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,nonce: freezed == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SnAuthChallenge implements SnAuthChallenge {
  const _SnAuthChallenge({required this.id, required this.expiredAt, required this.stepRemain, required this.stepTotal, required this.failedAttempts, required this.platform, required this.type, required final  List<String> blacklistFactors, required final  List<dynamic> audiences, required final  List<dynamic> scopes, required this.ipAddress, required this.userAgent, required this.deviceId, required this.nonce, required this.location, required this.accountId, required this.createdAt, required this.updatedAt, required this.deletedAt}): _blacklistFactors = blacklistFactors,_audiences = audiences,_scopes = scopes;
  factory _SnAuthChallenge.fromJson(Map<String, dynamic> json) => _$SnAuthChallengeFromJson(json);

@override final  String id;
@override final  DateTime expiredAt;
@override final  int stepRemain;
@override final  int stepTotal;
@override final  int failedAttempts;
@override final  int platform;
@override final  int type;
 final  List<String> _blacklistFactors;
@override List<String> get blacklistFactors {
  if (_blacklistFactors is EqualUnmodifiableListView) return _blacklistFactors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blacklistFactors);
}

 final  List<dynamic> _audiences;
@override List<dynamic> get audiences {
  if (_audiences is EqualUnmodifiableListView) return _audiences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_audiences);
}

 final  List<dynamic> _scopes;
@override List<dynamic> get scopes {
  if (_scopes is EqualUnmodifiableListView) return _scopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scopes);
}

@override final  String ipAddress;
@override final  String userAgent;
@override final  String deviceId;
@override final  String? nonce;
@override final  String? location;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAuthChallenge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAuthChallengeCopyWith<_SnAuthChallenge> get copyWith => __$SnAuthChallengeCopyWithImpl<_SnAuthChallenge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAuthChallengeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAuthChallenge&&(identical(other.id, id) || other.id == id)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.stepRemain, stepRemain) || other.stepRemain == stepRemain)&&(identical(other.stepTotal, stepTotal) || other.stepTotal == stepTotal)&&(identical(other.failedAttempts, failedAttempts) || other.failedAttempts == failedAttempts)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._blacklistFactors, _blacklistFactors)&&const DeepCollectionEquality().equals(other._audiences, _audiences)&&const DeepCollectionEquality().equals(other._scopes, _scopes)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&(identical(other.location, location) || other.location == location)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,expiredAt,stepRemain,stepTotal,failedAttempts,platform,type,const DeepCollectionEquality().hash(_blacklistFactors),const DeepCollectionEquality().hash(_audiences),const DeepCollectionEquality().hash(_scopes),ipAddress,userAgent,deviceId,nonce,location,accountId,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'SnAuthChallenge(id: $id, expiredAt: $expiredAt, stepRemain: $stepRemain, stepTotal: $stepTotal, failedAttempts: $failedAttempts, platform: $platform, type: $type, blacklistFactors: $blacklistFactors, audiences: $audiences, scopes: $scopes, ipAddress: $ipAddress, userAgent: $userAgent, deviceId: $deviceId, nonce: $nonce, location: $location, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAuthChallengeCopyWith<$Res> implements $SnAuthChallengeCopyWith<$Res> {
  factory _$SnAuthChallengeCopyWith(_SnAuthChallenge value, $Res Function(_SnAuthChallenge) _then) = __$SnAuthChallengeCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime expiredAt, int stepRemain, int stepTotal, int failedAttempts, int platform, int type, List<String> blacklistFactors, List<dynamic> audiences, List<dynamic> scopes, String ipAddress, String userAgent, String deviceId, String? nonce, String? location, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnAuthChallengeCopyWithImpl<$Res>
    implements _$SnAuthChallengeCopyWith<$Res> {
  __$SnAuthChallengeCopyWithImpl(this._self, this._then);

  final _SnAuthChallenge _self;
  final $Res Function(_SnAuthChallenge) _then;

/// Create a copy of SnAuthChallenge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? expiredAt = null,Object? stepRemain = null,Object? stepTotal = null,Object? failedAttempts = null,Object? platform = null,Object? type = null,Object? blacklistFactors = null,Object? audiences = null,Object? scopes = null,Object? ipAddress = null,Object? userAgent = null,Object? deviceId = null,Object? nonce = freezed,Object? location = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAuthChallenge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,expiredAt: null == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime,stepRemain: null == stepRemain ? _self.stepRemain : stepRemain // ignore: cast_nullable_to_non_nullable
as int,stepTotal: null == stepTotal ? _self.stepTotal : stepTotal // ignore: cast_nullable_to_non_nullable
as int,failedAttempts: null == failedAttempts ? _self.failedAttempts : failedAttempts // ignore: cast_nullable_to_non_nullable
as int,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,blacklistFactors: null == blacklistFactors ? _self._blacklistFactors : blacklistFactors // ignore: cast_nullable_to_non_nullable
as List<String>,audiences: null == audiences ? _self._audiences : audiences // ignore: cast_nullable_to_non_nullable
as List<dynamic>,scopes: null == scopes ? _self._scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<dynamic>,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,nonce: freezed == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnAuthSession {

 String get id; String? get label; DateTime get lastGrantedAt; DateTime get expiredAt; String get accountId; String get challengeId; SnAuthChallenge get challenge; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAuthSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAuthSessionCopyWith<SnAuthSession> get copyWith => _$SnAuthSessionCopyWithImpl<SnAuthSession>(this as SnAuthSession, _$identity);

  /// Serializes this SnAuthSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAuthSession&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.lastGrantedAt, lastGrantedAt) || other.lastGrantedAt == lastGrantedAt)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.challenge, challenge) || other.challenge == challenge)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,lastGrantedAt,expiredAt,accountId,challengeId,challenge,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAuthSession(id: $id, label: $label, lastGrantedAt: $lastGrantedAt, expiredAt: $expiredAt, accountId: $accountId, challengeId: $challengeId, challenge: $challenge, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAuthSessionCopyWith<$Res>  {
  factory $SnAuthSessionCopyWith(SnAuthSession value, $Res Function(SnAuthSession) _then) = _$SnAuthSessionCopyWithImpl;
@useResult
$Res call({
 String id, String? label, DateTime lastGrantedAt, DateTime expiredAt, String accountId, String challengeId, SnAuthChallenge challenge, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnAuthChallengeCopyWith<$Res> get challenge;

}
/// @nodoc
class _$SnAuthSessionCopyWithImpl<$Res>
    implements $SnAuthSessionCopyWith<$Res> {
  _$SnAuthSessionCopyWithImpl(this._self, this._then);

  final SnAuthSession _self;
  final $Res Function(SnAuthSession) _then;

/// Create a copy of SnAuthSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = freezed,Object? lastGrantedAt = null,Object? expiredAt = null,Object? accountId = null,Object? challengeId = null,Object? challenge = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,lastGrantedAt: null == lastGrantedAt ? _self.lastGrantedAt : lastGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiredAt: null == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as SnAuthChallenge,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnAuthSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAuthChallengeCopyWith<$Res> get challenge {
  
  return $SnAuthChallengeCopyWith<$Res>(_self.challenge, (value) {
    return _then(_self.copyWith(challenge: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _SnAuthSession implements SnAuthSession {
  const _SnAuthSession({required this.id, required this.label, required this.lastGrantedAt, required this.expiredAt, required this.accountId, required this.challengeId, required this.challenge, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnAuthSession.fromJson(Map<String, dynamic> json) => _$SnAuthSessionFromJson(json);

@override final  String id;
@override final  String? label;
@override final  DateTime lastGrantedAt;
@override final  DateTime expiredAt;
@override final  String accountId;
@override final  String challengeId;
@override final  SnAuthChallenge challenge;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAuthSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAuthSessionCopyWith<_SnAuthSession> get copyWith => __$SnAuthSessionCopyWithImpl<_SnAuthSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAuthSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAuthSession&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.lastGrantedAt, lastGrantedAt) || other.lastGrantedAt == lastGrantedAt)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.challenge, challenge) || other.challenge == challenge)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,lastGrantedAt,expiredAt,accountId,challengeId,challenge,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAuthSession(id: $id, label: $label, lastGrantedAt: $lastGrantedAt, expiredAt: $expiredAt, accountId: $accountId, challengeId: $challengeId, challenge: $challenge, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAuthSessionCopyWith<$Res> implements $SnAuthSessionCopyWith<$Res> {
  factory _$SnAuthSessionCopyWith(_SnAuthSession value, $Res Function(_SnAuthSession) _then) = __$SnAuthSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String? label, DateTime lastGrantedAt, DateTime expiredAt, String accountId, String challengeId, SnAuthChallenge challenge, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnAuthChallengeCopyWith<$Res> get challenge;

}
/// @nodoc
class __$SnAuthSessionCopyWithImpl<$Res>
    implements _$SnAuthSessionCopyWith<$Res> {
  __$SnAuthSessionCopyWithImpl(this._self, this._then);

  final _SnAuthSession _self;
  final $Res Function(_SnAuthSession) _then;

/// Create a copy of SnAuthSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = freezed,Object? lastGrantedAt = null,Object? expiredAt = null,Object? accountId = null,Object? challengeId = null,Object? challenge = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAuthSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,lastGrantedAt: null == lastGrantedAt ? _self.lastGrantedAt : lastGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiredAt: null == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,challengeId: null == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String,challenge: null == challenge ? _self.challenge : challenge // ignore: cast_nullable_to_non_nullable
as SnAuthChallenge,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnAuthSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAuthChallengeCopyWith<$Res> get challenge {
  
  return $SnAuthChallengeCopyWith<$Res>(_self.challenge, (value) {
    return _then(_self.copyWith(challenge: value));
  });
}
}


/// @nodoc
mixin _$SnAuthFactor {

 String get id; int get type; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; DateTime? get expiredAt; DateTime? get enabledAt; int get trustworthy; Map<String, dynamic>? get createdResponse;
/// Create a copy of SnAuthFactor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAuthFactorCopyWith<SnAuthFactor> get copyWith => _$SnAuthFactorCopyWithImpl<SnAuthFactor>(this as SnAuthFactor, _$identity);

  /// Serializes this SnAuthFactor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAuthFactor&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.enabledAt, enabledAt) || other.enabledAt == enabledAt)&&(identical(other.trustworthy, trustworthy) || other.trustworthy == trustworthy)&&const DeepCollectionEquality().equals(other.createdResponse, createdResponse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,createdAt,updatedAt,deletedAt,expiredAt,enabledAt,trustworthy,const DeepCollectionEquality().hash(createdResponse));

@override
String toString() {
  return 'SnAuthFactor(id: $id, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, expiredAt: $expiredAt, enabledAt: $enabledAt, trustworthy: $trustworthy, createdResponse: $createdResponse)';
}


}

/// @nodoc
abstract mixin class $SnAuthFactorCopyWith<$Res>  {
  factory $SnAuthFactorCopyWith(SnAuthFactor value, $Res Function(SnAuthFactor) _then) = _$SnAuthFactorCopyWithImpl;
@useResult
$Res call({
 String id, int type, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, DateTime? expiredAt, DateTime? enabledAt, int trustworthy, Map<String, dynamic>? createdResponse
});




}
/// @nodoc
class _$SnAuthFactorCopyWithImpl<$Res>
    implements $SnAuthFactorCopyWith<$Res> {
  _$SnAuthFactorCopyWithImpl(this._self, this._then);

  final SnAuthFactor _self;
  final $Res Function(SnAuthFactor) _then;

/// Create a copy of SnAuthFactor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? expiredAt = freezed,Object? enabledAt = freezed,Object? trustworthy = null,Object? createdResponse = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,enabledAt: freezed == enabledAt ? _self.enabledAt : enabledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,trustworthy: null == trustworthy ? _self.trustworthy : trustworthy // ignore: cast_nullable_to_non_nullable
as int,createdResponse: freezed == createdResponse ? _self.createdResponse : createdResponse // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SnAuthFactor implements SnAuthFactor {
  const _SnAuthFactor({required this.id, required this.type, required this.createdAt, required this.updatedAt, required this.deletedAt, required this.expiredAt, required this.enabledAt, required this.trustworthy, required final  Map<String, dynamic>? createdResponse}): _createdResponse = createdResponse;
  factory _SnAuthFactor.fromJson(Map<String, dynamic> json) => _$SnAuthFactorFromJson(json);

@override final  String id;
@override final  int type;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  DateTime? expiredAt;
@override final  DateTime? enabledAt;
@override final  int trustworthy;
 final  Map<String, dynamic>? _createdResponse;
@override Map<String, dynamic>? get createdResponse {
  final value = _createdResponse;
  if (value == null) return null;
  if (_createdResponse is EqualUnmodifiableMapView) return _createdResponse;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of SnAuthFactor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAuthFactorCopyWith<_SnAuthFactor> get copyWith => __$SnAuthFactorCopyWithImpl<_SnAuthFactor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAuthFactorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAuthFactor&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.enabledAt, enabledAt) || other.enabledAt == enabledAt)&&(identical(other.trustworthy, trustworthy) || other.trustworthy == trustworthy)&&const DeepCollectionEquality().equals(other._createdResponse, _createdResponse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,createdAt,updatedAt,deletedAt,expiredAt,enabledAt,trustworthy,const DeepCollectionEquality().hash(_createdResponse));

@override
String toString() {
  return 'SnAuthFactor(id: $id, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, expiredAt: $expiredAt, enabledAt: $enabledAt, trustworthy: $trustworthy, createdResponse: $createdResponse)';
}


}

/// @nodoc
abstract mixin class _$SnAuthFactorCopyWith<$Res> implements $SnAuthFactorCopyWith<$Res> {
  factory _$SnAuthFactorCopyWith(_SnAuthFactor value, $Res Function(_SnAuthFactor) _then) = __$SnAuthFactorCopyWithImpl;
@override @useResult
$Res call({
 String id, int type, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, DateTime? expiredAt, DateTime? enabledAt, int trustworthy, Map<String, dynamic>? createdResponse
});




}
/// @nodoc
class __$SnAuthFactorCopyWithImpl<$Res>
    implements _$SnAuthFactorCopyWith<$Res> {
  __$SnAuthFactorCopyWithImpl(this._self, this._then);

  final _SnAuthFactor _self;
  final $Res Function(_SnAuthFactor) _then;

/// Create a copy of SnAuthFactor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? expiredAt = freezed,Object? enabledAt = freezed,Object? trustworthy = null,Object? createdResponse = freezed,}) {
  return _then(_SnAuthFactor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,enabledAt: freezed == enabledAt ? _self.enabledAt : enabledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,trustworthy: null == trustworthy ? _self.trustworthy : trustworthy // ignore: cast_nullable_to_non_nullable
as int,createdResponse: freezed == createdResponse ? _self._createdResponse : createdResponse // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$SnAuthDevice {

 dynamic get label; String get userAgent; String get deviceId; int get platform; List<SnAuthSession> get sessions;// Not from backend, used for UI
 bool get isCurrent;
/// Create a copy of SnAuthDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAuthDeviceCopyWith<SnAuthDevice> get copyWith => _$SnAuthDeviceCopyWithImpl<SnAuthDevice>(this as SnAuthDevice, _$identity);

  /// Serializes this SnAuthDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAuthDevice&&const DeepCollectionEquality().equals(other.label, label)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.platform, platform) || other.platform == platform)&&const DeepCollectionEquality().equals(other.sessions, sessions)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(label),userAgent,deviceId,platform,const DeepCollectionEquality().hash(sessions),isCurrent);

@override
String toString() {
  return 'SnAuthDevice(label: $label, userAgent: $userAgent, deviceId: $deviceId, platform: $platform, sessions: $sessions, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class $SnAuthDeviceCopyWith<$Res>  {
  factory $SnAuthDeviceCopyWith(SnAuthDevice value, $Res Function(SnAuthDevice) _then) = _$SnAuthDeviceCopyWithImpl;
@useResult
$Res call({
 dynamic label, String userAgent, String deviceId, int platform, List<SnAuthSession> sessions, bool isCurrent
});




}
/// @nodoc
class _$SnAuthDeviceCopyWithImpl<$Res>
    implements $SnAuthDeviceCopyWith<$Res> {
  _$SnAuthDeviceCopyWithImpl(this._self, this._then);

  final SnAuthDevice _self;
  final $Res Function(SnAuthDevice) _then;

/// Create a copy of SnAuthDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = freezed,Object? userAgent = null,Object? deviceId = null,Object? platform = null,Object? sessions = null,Object? isCurrent = null,}) {
  return _then(_self.copyWith(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as dynamic,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<SnAuthSession>,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SnAuthDevice implements SnAuthDevice {
  const _SnAuthDevice({required this.label, required this.userAgent, required this.deviceId, required this.platform, required final  List<SnAuthSession> sessions, this.isCurrent = false}): _sessions = sessions;
  factory _SnAuthDevice.fromJson(Map<String, dynamic> json) => _$SnAuthDeviceFromJson(json);

@override final  dynamic label;
@override final  String userAgent;
@override final  String deviceId;
@override final  int platform;
 final  List<SnAuthSession> _sessions;
@override List<SnAuthSession> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

// Not from backend, used for UI
@override@JsonKey() final  bool isCurrent;

/// Create a copy of SnAuthDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAuthDeviceCopyWith<_SnAuthDevice> get copyWith => __$SnAuthDeviceCopyWithImpl<_SnAuthDevice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAuthDeviceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAuthDevice&&const DeepCollectionEquality().equals(other.label, label)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.platform, platform) || other.platform == platform)&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(label),userAgent,deviceId,platform,const DeepCollectionEquality().hash(_sessions),isCurrent);

@override
String toString() {
  return 'SnAuthDevice(label: $label, userAgent: $userAgent, deviceId: $deviceId, platform: $platform, sessions: $sessions, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class _$SnAuthDeviceCopyWith<$Res> implements $SnAuthDeviceCopyWith<$Res> {
  factory _$SnAuthDeviceCopyWith(_SnAuthDevice value, $Res Function(_SnAuthDevice) _then) = __$SnAuthDeviceCopyWithImpl;
@override @useResult
$Res call({
 dynamic label, String userAgent, String deviceId, int platform, List<SnAuthSession> sessions, bool isCurrent
});




}
/// @nodoc
class __$SnAuthDeviceCopyWithImpl<$Res>
    implements _$SnAuthDeviceCopyWith<$Res> {
  __$SnAuthDeviceCopyWithImpl(this._self, this._then);

  final _SnAuthDevice _self;
  final $Res Function(_SnAuthDevice) _then;

/// Create a copy of SnAuthDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = freezed,Object? userAgent = null,Object? deviceId = null,Object? platform = null,Object? sessions = null,Object? isCurrent = null,}) {
  return _then(_SnAuthDevice(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as dynamic,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<SnAuthSession>,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
