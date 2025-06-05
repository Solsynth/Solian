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

 String get id; DateTime get expiredAt; int get stepRemain; int get stepTotal; List<String> get blacklistFactors; List<String> get audiences; List<String> get scopes; String get ipAddress; String get userAgent; String? get deviceId; String? get nonce; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAuthChallenge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAuthChallengeCopyWith<SnAuthChallenge> get copyWith => _$SnAuthChallengeCopyWithImpl<SnAuthChallenge>(this as SnAuthChallenge, _$identity);

  /// Serializes this SnAuthChallenge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAuthChallenge&&(identical(other.id, id) || other.id == id)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.stepRemain, stepRemain) || other.stepRemain == stepRemain)&&(identical(other.stepTotal, stepTotal) || other.stepTotal == stepTotal)&&const DeepCollectionEquality().equals(other.blacklistFactors, blacklistFactors)&&const DeepCollectionEquality().equals(other.audiences, audiences)&&const DeepCollectionEquality().equals(other.scopes, scopes)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,expiredAt,stepRemain,stepTotal,const DeepCollectionEquality().hash(blacklistFactors),const DeepCollectionEquality().hash(audiences),const DeepCollectionEquality().hash(scopes),ipAddress,userAgent,deviceId,nonce,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAuthChallenge(id: $id, expiredAt: $expiredAt, stepRemain: $stepRemain, stepTotal: $stepTotal, blacklistFactors: $blacklistFactors, audiences: $audiences, scopes: $scopes, ipAddress: $ipAddress, userAgent: $userAgent, deviceId: $deviceId, nonce: $nonce, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAuthChallengeCopyWith<$Res>  {
  factory $SnAuthChallengeCopyWith(SnAuthChallenge value, $Res Function(SnAuthChallenge) _then) = _$SnAuthChallengeCopyWithImpl;
@useResult
$Res call({
 String id, DateTime expiredAt, int stepRemain, int stepTotal, List<String> blacklistFactors, List<String> audiences, List<String> scopes, String ipAddress, String userAgent, String? deviceId, String? nonce, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? expiredAt = null,Object? stepRemain = null,Object? stepTotal = null,Object? blacklistFactors = null,Object? audiences = null,Object? scopes = null,Object? ipAddress = null,Object? userAgent = null,Object? deviceId = freezed,Object? nonce = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,expiredAt: null == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime,stepRemain: null == stepRemain ? _self.stepRemain : stepRemain // ignore: cast_nullable_to_non_nullable
as int,stepTotal: null == stepTotal ? _self.stepTotal : stepTotal // ignore: cast_nullable_to_non_nullable
as int,blacklistFactors: null == blacklistFactors ? _self.blacklistFactors : blacklistFactors // ignore: cast_nullable_to_non_nullable
as List<String>,audiences: null == audiences ? _self.audiences : audiences // ignore: cast_nullable_to_non_nullable
as List<String>,scopes: null == scopes ? _self.scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<String>,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,nonce: freezed == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SnAuthChallenge implements SnAuthChallenge {
  const _SnAuthChallenge({required this.id, required this.expiredAt, required this.stepRemain, required this.stepTotal, required final  List<String> blacklistFactors, required final  List<String> audiences, required final  List<String> scopes, required this.ipAddress, required this.userAgent, required this.deviceId, required this.nonce, required this.createdAt, required this.updatedAt, required this.deletedAt}): _blacklistFactors = blacklistFactors,_audiences = audiences,_scopes = scopes;
  factory _SnAuthChallenge.fromJson(Map<String, dynamic> json) => _$SnAuthChallengeFromJson(json);

@override final  String id;
@override final  DateTime expiredAt;
@override final  int stepRemain;
@override final  int stepTotal;
 final  List<String> _blacklistFactors;
@override List<String> get blacklistFactors {
  if (_blacklistFactors is EqualUnmodifiableListView) return _blacklistFactors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blacklistFactors);
}

 final  List<String> _audiences;
@override List<String> get audiences {
  if (_audiences is EqualUnmodifiableListView) return _audiences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_audiences);
}

 final  List<String> _scopes;
@override List<String> get scopes {
  if (_scopes is EqualUnmodifiableListView) return _scopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scopes);
}

@override final  String ipAddress;
@override final  String userAgent;
@override final  String? deviceId;
@override final  String? nonce;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAuthChallenge&&(identical(other.id, id) || other.id == id)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.stepRemain, stepRemain) || other.stepRemain == stepRemain)&&(identical(other.stepTotal, stepTotal) || other.stepTotal == stepTotal)&&const DeepCollectionEquality().equals(other._blacklistFactors, _blacklistFactors)&&const DeepCollectionEquality().equals(other._audiences, _audiences)&&const DeepCollectionEquality().equals(other._scopes, _scopes)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,expiredAt,stepRemain,stepTotal,const DeepCollectionEquality().hash(_blacklistFactors),const DeepCollectionEquality().hash(_audiences),const DeepCollectionEquality().hash(_scopes),ipAddress,userAgent,deviceId,nonce,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAuthChallenge(id: $id, expiredAt: $expiredAt, stepRemain: $stepRemain, stepTotal: $stepTotal, blacklistFactors: $blacklistFactors, audiences: $audiences, scopes: $scopes, ipAddress: $ipAddress, userAgent: $userAgent, deviceId: $deviceId, nonce: $nonce, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAuthChallengeCopyWith<$Res> implements $SnAuthChallengeCopyWith<$Res> {
  factory _$SnAuthChallengeCopyWith(_SnAuthChallenge value, $Res Function(_SnAuthChallenge) _then) = __$SnAuthChallengeCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime expiredAt, int stepRemain, int stepTotal, List<String> blacklistFactors, List<String> audiences, List<String> scopes, String ipAddress, String userAgent, String? deviceId, String? nonce, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? expiredAt = null,Object? stepRemain = null,Object? stepTotal = null,Object? blacklistFactors = null,Object? audiences = null,Object? scopes = null,Object? ipAddress = null,Object? userAgent = null,Object? deviceId = freezed,Object? nonce = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAuthChallenge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,expiredAt: null == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime,stepRemain: null == stepRemain ? _self.stepRemain : stepRemain // ignore: cast_nullable_to_non_nullable
as int,stepTotal: null == stepTotal ? _self.stepTotal : stepTotal // ignore: cast_nullable_to_non_nullable
as int,blacklistFactors: null == blacklistFactors ? _self._blacklistFactors : blacklistFactors // ignore: cast_nullable_to_non_nullable
as List<String>,audiences: null == audiences ? _self._audiences : audiences // ignore: cast_nullable_to_non_nullable
as List<String>,scopes: null == scopes ? _self._scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<String>,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,nonce: freezed == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
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

// dart format on
