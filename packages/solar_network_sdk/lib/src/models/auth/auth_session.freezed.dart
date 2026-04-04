// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnAuthSession {

 String get id; String? get label; DateTime get lastGrantedAt; DateTime? get expiredAt; List<String> get audiences; List<String> get scopes; String? get ipAddress; String? get userAgent; GeoIpLocation? get location; int get type; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; bool get isCurrent;
/// Create a copy of SnAuthSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAuthSessionCopyWith<SnAuthSession> get copyWith => _$SnAuthSessionCopyWithImpl<SnAuthSession>(this as SnAuthSession, _$identity);

  /// Serializes this SnAuthSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAuthSession&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.lastGrantedAt, lastGrantedAt) || other.lastGrantedAt == lastGrantedAt)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&const DeepCollectionEquality().equals(other.audiences, audiences)&&const DeepCollectionEquality().equals(other.scopes, scopes)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.location, location) || other.location == location)&&(identical(other.type, type) || other.type == type)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,lastGrantedAt,expiredAt,const DeepCollectionEquality().hash(audiences),const DeepCollectionEquality().hash(scopes),ipAddress,userAgent,location,type,accountId,createdAt,updatedAt,deletedAt,isCurrent);

@override
String toString() {
  return 'SnAuthSession(id: $id, label: $label, lastGrantedAt: $lastGrantedAt, expiredAt: $expiredAt, audiences: $audiences, scopes: $scopes, ipAddress: $ipAddress, userAgent: $userAgent, location: $location, type: $type, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class $SnAuthSessionCopyWith<$Res>  {
  factory $SnAuthSessionCopyWith(SnAuthSession value, $Res Function(SnAuthSession) _then) = _$SnAuthSessionCopyWithImpl;
@useResult
$Res call({
 String id, String? label, DateTime lastGrantedAt, DateTime? expiredAt, List<String> audiences, List<String> scopes, String? ipAddress, String? userAgent, GeoIpLocation? location, int type, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, bool isCurrent
});


$GeoIpLocationCopyWith<$Res>? get location;

}
/// @nodoc
class _$SnAuthSessionCopyWithImpl<$Res>
    implements $SnAuthSessionCopyWith<$Res> {
  _$SnAuthSessionCopyWithImpl(this._self, this._then);

  final SnAuthSession _self;
  final $Res Function(SnAuthSession) _then;

/// Create a copy of SnAuthSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = freezed,Object? lastGrantedAt = null,Object? expiredAt = freezed,Object? audiences = null,Object? scopes = null,Object? ipAddress = freezed,Object? userAgent = freezed,Object? location = freezed,Object? type = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? isCurrent = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,lastGrantedAt: null == lastGrantedAt ? _self.lastGrantedAt : lastGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,audiences: null == audiences ? _self.audiences : audiences // ignore: cast_nullable_to_non_nullable
as List<String>,scopes: null == scopes ? _self.scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<String>,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoIpLocation?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SnAuthSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoIpLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $GeoIpLocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnAuthSession].
extension SnAuthSessionPatterns on SnAuthSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAuthSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAuthSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAuthSession value)  $default,){
final _that = this;
switch (_that) {
case _SnAuthSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAuthSession value)?  $default,){
final _that = this;
switch (_that) {
case _SnAuthSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? label,  DateTime lastGrantedAt,  DateTime? expiredAt,  List<String> audiences,  List<String> scopes,  String? ipAddress,  String? userAgent,  GeoIpLocation? location,  int type,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  bool isCurrent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAuthSession() when $default != null:
return $default(_that.id,_that.label,_that.lastGrantedAt,_that.expiredAt,_that.audiences,_that.scopes,_that.ipAddress,_that.userAgent,_that.location,_that.type,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.isCurrent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? label,  DateTime lastGrantedAt,  DateTime? expiredAt,  List<String> audiences,  List<String> scopes,  String? ipAddress,  String? userAgent,  GeoIpLocation? location,  int type,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  bool isCurrent)  $default,) {final _that = this;
switch (_that) {
case _SnAuthSession():
return $default(_that.id,_that.label,_that.lastGrantedAt,_that.expiredAt,_that.audiences,_that.scopes,_that.ipAddress,_that.userAgent,_that.location,_that.type,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.isCurrent);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? label,  DateTime lastGrantedAt,  DateTime? expiredAt,  List<String> audiences,  List<String> scopes,  String? ipAddress,  String? userAgent,  GeoIpLocation? location,  int type,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  bool isCurrent)?  $default,) {final _that = this;
switch (_that) {
case _SnAuthSession() when $default != null:
return $default(_that.id,_that.label,_that.lastGrantedAt,_that.expiredAt,_that.audiences,_that.scopes,_that.ipAddress,_that.userAgent,_that.location,_that.type,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.isCurrent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAuthSession implements SnAuthSession {
  const _SnAuthSession({required this.id, this.label, required this.lastGrantedAt, this.expiredAt, final  List<String> audiences = const [], final  List<String> scopes = const [], this.ipAddress, this.userAgent, this.location, required this.type, required this.accountId, required this.createdAt, required this.updatedAt, this.deletedAt, this.isCurrent = false}): _audiences = audiences,_scopes = scopes;
  factory _SnAuthSession.fromJson(Map<String, dynamic> json) => _$SnAuthSessionFromJson(json);

@override final  String id;
@override final  String? label;
@override final  DateTime lastGrantedAt;
@override final  DateTime? expiredAt;
 final  List<String> _audiences;
@override@JsonKey() List<String> get audiences {
  if (_audiences is EqualUnmodifiableListView) return _audiences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_audiences);
}

 final  List<String> _scopes;
@override@JsonKey() List<String> get scopes {
  if (_scopes is EqualUnmodifiableListView) return _scopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scopes);
}

@override final  String? ipAddress;
@override final  String? userAgent;
@override final  GeoIpLocation? location;
@override final  int type;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override@JsonKey() final  bool isCurrent;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAuthSession&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.lastGrantedAt, lastGrantedAt) || other.lastGrantedAt == lastGrantedAt)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&const DeepCollectionEquality().equals(other._audiences, _audiences)&&const DeepCollectionEquality().equals(other._scopes, _scopes)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.location, location) || other.location == location)&&(identical(other.type, type) || other.type == type)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,lastGrantedAt,expiredAt,const DeepCollectionEquality().hash(_audiences),const DeepCollectionEquality().hash(_scopes),ipAddress,userAgent,location,type,accountId,createdAt,updatedAt,deletedAt,isCurrent);

@override
String toString() {
  return 'SnAuthSession(id: $id, label: $label, lastGrantedAt: $lastGrantedAt, expiredAt: $expiredAt, audiences: $audiences, scopes: $scopes, ipAddress: $ipAddress, userAgent: $userAgent, location: $location, type: $type, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class _$SnAuthSessionCopyWith<$Res> implements $SnAuthSessionCopyWith<$Res> {
  factory _$SnAuthSessionCopyWith(_SnAuthSession value, $Res Function(_SnAuthSession) _then) = __$SnAuthSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String? label, DateTime lastGrantedAt, DateTime? expiredAt, List<String> audiences, List<String> scopes, String? ipAddress, String? userAgent, GeoIpLocation? location, int type, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, bool isCurrent
});


@override $GeoIpLocationCopyWith<$Res>? get location;

}
/// @nodoc
class __$SnAuthSessionCopyWithImpl<$Res>
    implements _$SnAuthSessionCopyWith<$Res> {
  __$SnAuthSessionCopyWithImpl(this._self, this._then);

  final _SnAuthSession _self;
  final $Res Function(_SnAuthSession) _then;

/// Create a copy of SnAuthSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = freezed,Object? lastGrantedAt = null,Object? expiredAt = freezed,Object? audiences = null,Object? scopes = null,Object? ipAddress = freezed,Object? userAgent = freezed,Object? location = freezed,Object? type = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? isCurrent = null,}) {
  return _then(_SnAuthSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,lastGrantedAt: null == lastGrantedAt ? _self.lastGrantedAt : lastGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,audiences: null == audiences ? _self._audiences : audiences // ignore: cast_nullable_to_non_nullable
as List<String>,scopes: null == scopes ? _self._scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<String>,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,userAgent: freezed == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoIpLocation?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SnAuthSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeoIpLocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $GeoIpLocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

// dart format on
