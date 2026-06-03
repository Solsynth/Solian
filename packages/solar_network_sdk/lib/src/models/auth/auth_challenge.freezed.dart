// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_challenge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnAuthChallenge {

 String get id; DateTime? get expiredAt; int get stepRemain; int get stepTotal; int get failedAttempts; List<String> get blacklistFactors; List<dynamic> get audiences; List<dynamic> get scopes; String get ipAddress; String get userAgent; String? get nonce; String? get countryCode; String? get country; String? get city; String? get deviceId; String? get deviceName; int? get platform; DateTime? get approvedAt; DateTime? get declinedAt; String? get approvedBySessionId; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAuthChallenge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAuthChallengeCopyWith<SnAuthChallenge> get copyWith => _$SnAuthChallengeCopyWithImpl<SnAuthChallenge>(this as SnAuthChallenge, _$identity);

  /// Serializes this SnAuthChallenge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAuthChallenge&&(identical(other.id, id) || other.id == id)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.stepRemain, stepRemain) || other.stepRemain == stepRemain)&&(identical(other.stepTotal, stepTotal) || other.stepTotal == stepTotal)&&(identical(other.failedAttempts, failedAttempts) || other.failedAttempts == failedAttempts)&&const DeepCollectionEquality().equals(other.blacklistFactors, blacklistFactors)&&const DeepCollectionEquality().equals(other.audiences, audiences)&&const DeepCollectionEquality().equals(other.scopes, scopes)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.declinedAt, declinedAt) || other.declinedAt == declinedAt)&&(identical(other.approvedBySessionId, approvedBySessionId) || other.approvedBySessionId == approvedBySessionId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,expiredAt,stepRemain,stepTotal,failedAttempts,const DeepCollectionEquality().hash(blacklistFactors),const DeepCollectionEquality().hash(audiences),const DeepCollectionEquality().hash(scopes),ipAddress,userAgent,nonce,countryCode,country,city,deviceId,deviceName,platform,approvedAt,declinedAt,approvedBySessionId,accountId,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'SnAuthChallenge(id: $id, expiredAt: $expiredAt, stepRemain: $stepRemain, stepTotal: $stepTotal, failedAttempts: $failedAttempts, blacklistFactors: $blacklistFactors, audiences: $audiences, scopes: $scopes, ipAddress: $ipAddress, userAgent: $userAgent, nonce: $nonce, countryCode: $countryCode, country: $country, city: $city, deviceId: $deviceId, deviceName: $deviceName, platform: $platform, approvedAt: $approvedAt, declinedAt: $declinedAt, approvedBySessionId: $approvedBySessionId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAuthChallengeCopyWith<$Res>  {
  factory $SnAuthChallengeCopyWith(SnAuthChallenge value, $Res Function(SnAuthChallenge) _then) = _$SnAuthChallengeCopyWithImpl;
@useResult
$Res call({
 String id, DateTime? expiredAt, int stepRemain, int stepTotal, int failedAttempts, List<String> blacklistFactors, List<dynamic> audiences, List<dynamic> scopes, String ipAddress, String userAgent, String? nonce, String? countryCode, String? country, String? city, String? deviceId, String? deviceName, int? platform, DateTime? approvedAt, DateTime? declinedAt, String? approvedBySessionId, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? expiredAt = freezed,Object? stepRemain = null,Object? stepTotal = null,Object? failedAttempts = null,Object? blacklistFactors = null,Object? audiences = null,Object? scopes = null,Object? ipAddress = null,Object? userAgent = null,Object? nonce = freezed,Object? countryCode = freezed,Object? country = freezed,Object? city = freezed,Object? deviceId = freezed,Object? deviceName = freezed,Object? platform = freezed,Object? approvedAt = freezed,Object? declinedAt = freezed,Object? approvedBySessionId = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,stepRemain: null == stepRemain ? _self.stepRemain : stepRemain // ignore: cast_nullable_to_non_nullable
as int,stepTotal: null == stepTotal ? _self.stepTotal : stepTotal // ignore: cast_nullable_to_non_nullable
as int,failedAttempts: null == failedAttempts ? _self.failedAttempts : failedAttempts // ignore: cast_nullable_to_non_nullable
as int,blacklistFactors: null == blacklistFactors ? _self.blacklistFactors : blacklistFactors // ignore: cast_nullable_to_non_nullable
as List<String>,audiences: null == audiences ? _self.audiences : audiences // ignore: cast_nullable_to_non_nullable
as List<dynamic>,scopes: null == scopes ? _self.scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<dynamic>,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,nonce: freezed == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,declinedAt: freezed == declinedAt ? _self.declinedAt : declinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBySessionId: freezed == approvedBySessionId ? _self.approvedBySessionId : approvedBySessionId // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnAuthChallenge].
extension SnAuthChallengePatterns on SnAuthChallenge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAuthChallenge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAuthChallenge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAuthChallenge value)  $default,){
final _that = this;
switch (_that) {
case _SnAuthChallenge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAuthChallenge value)?  $default,){
final _that = this;
switch (_that) {
case _SnAuthChallenge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime? expiredAt,  int stepRemain,  int stepTotal,  int failedAttempts,  List<String> blacklistFactors,  List<dynamic> audiences,  List<dynamic> scopes,  String ipAddress,  String userAgent,  String? nonce,  String? countryCode,  String? country,  String? city,  String? deviceId,  String? deviceName,  int? platform,  DateTime? approvedAt,  DateTime? declinedAt,  String? approvedBySessionId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAuthChallenge() when $default != null:
return $default(_that.id,_that.expiredAt,_that.stepRemain,_that.stepTotal,_that.failedAttempts,_that.blacklistFactors,_that.audiences,_that.scopes,_that.ipAddress,_that.userAgent,_that.nonce,_that.countryCode,_that.country,_that.city,_that.deviceId,_that.deviceName,_that.platform,_that.approvedAt,_that.declinedAt,_that.approvedBySessionId,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime? expiredAt,  int stepRemain,  int stepTotal,  int failedAttempts,  List<String> blacklistFactors,  List<dynamic> audiences,  List<dynamic> scopes,  String ipAddress,  String userAgent,  String? nonce,  String? countryCode,  String? country,  String? city,  String? deviceId,  String? deviceName,  int? platform,  DateTime? approvedAt,  DateTime? declinedAt,  String? approvedBySessionId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnAuthChallenge():
return $default(_that.id,_that.expiredAt,_that.stepRemain,_that.stepTotal,_that.failedAttempts,_that.blacklistFactors,_that.audiences,_that.scopes,_that.ipAddress,_that.userAgent,_that.nonce,_that.countryCode,_that.country,_that.city,_that.deviceId,_that.deviceName,_that.platform,_that.approvedAt,_that.declinedAt,_that.approvedBySessionId,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime? expiredAt,  int stepRemain,  int stepTotal,  int failedAttempts,  List<String> blacklistFactors,  List<dynamic> audiences,  List<dynamic> scopes,  String ipAddress,  String userAgent,  String? nonce,  String? countryCode,  String? country,  String? city,  String? deviceId,  String? deviceName,  int? platform,  DateTime? approvedAt,  DateTime? declinedAt,  String? approvedBySessionId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnAuthChallenge() when $default != null:
return $default(_that.id,_that.expiredAt,_that.stepRemain,_that.stepTotal,_that.failedAttempts,_that.blacklistFactors,_that.audiences,_that.scopes,_that.ipAddress,_that.userAgent,_that.nonce,_that.countryCode,_that.country,_that.city,_that.deviceId,_that.deviceName,_that.platform,_that.approvedAt,_that.declinedAt,_that.approvedBySessionId,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAuthChallenge implements SnAuthChallenge {
  const _SnAuthChallenge({required this.id, this.expiredAt, required this.stepRemain, required this.stepTotal, required this.failedAttempts, required final  List<String> blacklistFactors, required final  List<dynamic> audiences, required final  List<dynamic> scopes, required this.ipAddress, required this.userAgent, this.nonce, this.countryCode, this.country, this.city, this.deviceId, this.deviceName, this.platform, this.approvedAt, this.declinedAt, this.approvedBySessionId, required this.accountId, required this.createdAt, required this.updatedAt, this.deletedAt}): _blacklistFactors = blacklistFactors,_audiences = audiences,_scopes = scopes;
  factory _SnAuthChallenge.fromJson(Map<String, dynamic> json) => _$SnAuthChallengeFromJson(json);

@override final  String id;
@override final  DateTime? expiredAt;
@override final  int stepRemain;
@override final  int stepTotal;
@override final  int failedAttempts;
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
@override final  String? nonce;
@override final  String? countryCode;
@override final  String? country;
@override final  String? city;
@override final  String? deviceId;
@override final  String? deviceName;
@override final  int? platform;
@override final  DateTime? approvedAt;
@override final  DateTime? declinedAt;
@override final  String? approvedBySessionId;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAuthChallenge&&(identical(other.id, id) || other.id == id)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.stepRemain, stepRemain) || other.stepRemain == stepRemain)&&(identical(other.stepTotal, stepTotal) || other.stepTotal == stepTotal)&&(identical(other.failedAttempts, failedAttempts) || other.failedAttempts == failedAttempts)&&const DeepCollectionEquality().equals(other._blacklistFactors, _blacklistFactors)&&const DeepCollectionEquality().equals(other._audiences, _audiences)&&const DeepCollectionEquality().equals(other._scopes, _scopes)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.country, country) || other.country == country)&&(identical(other.city, city) || other.city == city)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.declinedAt, declinedAt) || other.declinedAt == declinedAt)&&(identical(other.approvedBySessionId, approvedBySessionId) || other.approvedBySessionId == approvedBySessionId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,expiredAt,stepRemain,stepTotal,failedAttempts,const DeepCollectionEquality().hash(_blacklistFactors),const DeepCollectionEquality().hash(_audiences),const DeepCollectionEquality().hash(_scopes),ipAddress,userAgent,nonce,countryCode,country,city,deviceId,deviceName,platform,approvedAt,declinedAt,approvedBySessionId,accountId,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'SnAuthChallenge(id: $id, expiredAt: $expiredAt, stepRemain: $stepRemain, stepTotal: $stepTotal, failedAttempts: $failedAttempts, blacklistFactors: $blacklistFactors, audiences: $audiences, scopes: $scopes, ipAddress: $ipAddress, userAgent: $userAgent, nonce: $nonce, countryCode: $countryCode, country: $country, city: $city, deviceId: $deviceId, deviceName: $deviceName, platform: $platform, approvedAt: $approvedAt, declinedAt: $declinedAt, approvedBySessionId: $approvedBySessionId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAuthChallengeCopyWith<$Res> implements $SnAuthChallengeCopyWith<$Res> {
  factory _$SnAuthChallengeCopyWith(_SnAuthChallenge value, $Res Function(_SnAuthChallenge) _then) = __$SnAuthChallengeCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime? expiredAt, int stepRemain, int stepTotal, int failedAttempts, List<String> blacklistFactors, List<dynamic> audiences, List<dynamic> scopes, String ipAddress, String userAgent, String? nonce, String? countryCode, String? country, String? city, String? deviceId, String? deviceName, int? platform, DateTime? approvedAt, DateTime? declinedAt, String? approvedBySessionId, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? expiredAt = freezed,Object? stepRemain = null,Object? stepTotal = null,Object? failedAttempts = null,Object? blacklistFactors = null,Object? audiences = null,Object? scopes = null,Object? ipAddress = null,Object? userAgent = null,Object? nonce = freezed,Object? countryCode = freezed,Object? country = freezed,Object? city = freezed,Object? deviceId = freezed,Object? deviceName = freezed,Object? platform = freezed,Object? approvedAt = freezed,Object? declinedAt = freezed,Object? approvedBySessionId = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAuthChallenge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,stepRemain: null == stepRemain ? _self.stepRemain : stepRemain // ignore: cast_nullable_to_non_nullable
as int,stepTotal: null == stepTotal ? _self.stepTotal : stepTotal // ignore: cast_nullable_to_non_nullable
as int,failedAttempts: null == failedAttempts ? _self.failedAttempts : failedAttempts // ignore: cast_nullable_to_non_nullable
as int,blacklistFactors: null == blacklistFactors ? _self._blacklistFactors : blacklistFactors // ignore: cast_nullable_to_non_nullable
as List<String>,audiences: null == audiences ? _self._audiences : audiences // ignore: cast_nullable_to_non_nullable
as List<dynamic>,scopes: null == scopes ? _self._scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<dynamic>,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,nonce: freezed == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String?,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,platform: freezed == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int?,approvedAt: freezed == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,declinedAt: freezed == declinedAt ? _self.declinedAt : declinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,approvedBySessionId: freezed == approvedBySessionId ? _self.approvedBySessionId : approvedBySessionId // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
