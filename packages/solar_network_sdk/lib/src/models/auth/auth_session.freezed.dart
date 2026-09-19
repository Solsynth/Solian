// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnAuthSession {

 String get id; String? get label; DateTime get lastGrantedAt; DateTime? get expiredAt; List<String> get audiences; List<String> get scopes; String? get ipAddress; String? get userAgent; GeoIpLocation? get location; int get type; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; bool get isCurrent; int? get childrenCount; String get category; bool get trusted; bool get isOnline;
/// Create a copy of SnAuthSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAuthSessionCopyWith<SnAuthSession> get copyWith => _$SnAuthSessionCopyWithImpl<SnAuthSession>(this as SnAuthSession, _$identity);

  /// Serializes this SnAuthSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnAuthSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAuthSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.lastGrantedAt, _this.lastGrantedAt) || other.lastGrantedAt == _this.lastGrantedAt)&&(identical(other.expiredAt, _this.expiredAt) || other.expiredAt == _this.expiredAt)&&const DeepCollectionEquality().equals(other.audiences, _this.audiences)&&const DeepCollectionEquality().equals(other.scopes, _this.scopes)&&(identical(other.ipAddress, _this.ipAddress) || other.ipAddress == _this.ipAddress)&&(identical(other.userAgent, _this.userAgent) || other.userAgent == _this.userAgent)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&(identical(other.isCurrent, _this.isCurrent) || other.isCurrent == _this.isCurrent)&&(identical(other.childrenCount, _this.childrenCount) || other.childrenCount == _this.childrenCount)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.trusted, _this.trusted) || other.trusted == _this.trusted)&&(identical(other.isOnline, _this.isOnline) || other.isOnline == _this.isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnAuthSession;
  return Object.hashAll([runtimeType,_this.id,_this.label,_this.lastGrantedAt,_this.expiredAt,const DeepCollectionEquality().hash(_this.audiences),const DeepCollectionEquality().hash(_this.scopes),_this.ipAddress,_this.userAgent,_this.location,_this.type,_this.accountId,_this.createdAt,_this.updatedAt,_this.deletedAt,_this.isCurrent,_this.childrenCount,_this.category,_this.trusted,_this.isOnline]);
}

@override
String toString() {
  final _this = this as SnAuthSession;
  return 'SnAuthSession(id: ${_this.id}, label: ${_this.label}, lastGrantedAt: ${_this.lastGrantedAt}, expiredAt: ${_this.expiredAt}, audiences: ${_this.audiences}, scopes: ${_this.scopes}, ipAddress: ${_this.ipAddress}, userAgent: ${_this.userAgent}, location: ${_this.location}, type: ${_this.type}, accountId: ${_this.accountId}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt}, isCurrent: ${_this.isCurrent}, childrenCount: ${_this.childrenCount}, category: ${_this.category}, trusted: ${_this.trusted}, isOnline: ${_this.isOnline})';
}


}

/// @nodoc
abstract mixin class $SnAuthSessionCopyWith<$Res>  {
  factory $SnAuthSessionCopyWith(SnAuthSession value, $Res Function(SnAuthSession) _then) = _$SnAuthSessionCopyWithImpl;
@useResult
$Res call({
 String id, String? label, DateTime lastGrantedAt, DateTime? expiredAt, List<String> audiences, List<String> scopes, String? ipAddress, String? userAgent, GeoIpLocation? location, int type, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, bool isCurrent, int? childrenCount, String category, bool trusted, bool isOnline
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = freezed,Object? lastGrantedAt = null,Object? expiredAt = freezed,Object? audiences = null,Object? scopes = null,Object? ipAddress = freezed,Object? userAgent = freezed,Object? location = freezed,Object? type = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? isCurrent = null,Object? childrenCount = freezed,Object? category = null,Object? trusted = null,Object? isOnline = null,}) {
  return _then(SnAuthSession(
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
as bool,childrenCount: freezed == childrenCount ? _self.childrenCount : childrenCount // ignore: cast_nullable_to_non_nullable
as int?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,trusted: null == trusted ? _self.trusted : trusted // ignore: cast_nullable_to_non_nullable
as bool,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? label,  DateTime lastGrantedAt,  DateTime? expiredAt,  List<String> audiences,  List<String> scopes,  String? ipAddress,  String? userAgent,  GeoIpLocation? location,  int type,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  bool isCurrent,  int? childrenCount,  String category,  bool trusted,  bool isOnline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAuthSession() when $default != null:
return $default(_that.id,_that.label,_that.lastGrantedAt,_that.expiredAt,_that.audiences,_that.scopes,_that.ipAddress,_that.userAgent,_that.location,_that.type,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.isCurrent,_that.childrenCount,_that.category,_that.trusted,_that.isOnline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? label,  DateTime lastGrantedAt,  DateTime? expiredAt,  List<String> audiences,  List<String> scopes,  String? ipAddress,  String? userAgent,  GeoIpLocation? location,  int type,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  bool isCurrent,  int? childrenCount,  String category,  bool trusted,  bool isOnline)  $default,) {final _that = this;
switch (_that) {
case _SnAuthSession():
return $default(_that.id,_that.label,_that.lastGrantedAt,_that.expiredAt,_that.audiences,_that.scopes,_that.ipAddress,_that.userAgent,_that.location,_that.type,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.isCurrent,_that.childrenCount,_that.category,_that.trusted,_that.isOnline);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? label,  DateTime lastGrantedAt,  DateTime? expiredAt,  List<String> audiences,  List<String> scopes,  String? ipAddress,  String? userAgent,  GeoIpLocation? location,  int type,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  bool isCurrent,  int? childrenCount,  String category,  bool trusted,  bool isOnline)?  $default,) {final _that = this;
switch (_that) {
case _SnAuthSession() when $default != null:
return $default(_that.id,_that.label,_that.lastGrantedAt,_that.expiredAt,_that.audiences,_that.scopes,_that.ipAddress,_that.userAgent,_that.location,_that.type,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.isCurrent,_that.childrenCount,_that.category,_that.trusted,_that.isOnline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAuthSession implements SnAuthSession {
  const _SnAuthSession({required this.id, this.label, required this.lastGrantedAt, this.expiredAt,  List<String> audiences = const [],  List<String> scopes = const [], this.ipAddress, this.userAgent, this.location, required this.type, required this.accountId, required this.createdAt, required this.updatedAt, this.deletedAt, this.isCurrent = false, this.childrenCount, this.category = 'device', this.trusted = false, this.isOnline = false}): _audiences = audiences,_scopes = scopes;
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
@override final  int? childrenCount;
@override@JsonKey() final  String category;
@override@JsonKey() final  bool trusted;
@override@JsonKey() final  bool isOnline;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAuthSession&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.lastGrantedAt, lastGrantedAt) || other.lastGrantedAt == lastGrantedAt)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&const DeepCollectionEquality().equals(other.audiences, _audiences)&&const DeepCollectionEquality().equals(other.scopes, _scopes)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.location, location) || other.location == location)&&(identical(other.type, type) || other.type == type)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&(identical(other.childrenCount, childrenCount) || other.childrenCount == childrenCount)&&(identical(other.category, category) || other.category == category)&&(identical(other.trusted, trusted) || other.trusted == trusted)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,label,lastGrantedAt,expiredAt,const DeepCollectionEquality().hash(_audiences),const DeepCollectionEquality().hash(_scopes),ipAddress,userAgent,location,type,accountId,createdAt,updatedAt,deletedAt,isCurrent,childrenCount,category,trusted,isOnline]);
}

@override
String toString() {
    return 'SnAuthSession(id: $id, label: $label, lastGrantedAt: $lastGrantedAt, expiredAt: $expiredAt, audiences: $audiences, scopes: $scopes, ipAddress: $ipAddress, userAgent: $userAgent, location: $location, type: $type, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, isCurrent: $isCurrent, childrenCount: $childrenCount, category: $category, trusted: $trusted, isOnline: $isOnline)';
}


}

/// @nodoc
abstract mixin class _$SnAuthSessionCopyWith<$Res> implements $SnAuthSessionCopyWith<$Res> {
  factory _$SnAuthSessionCopyWith(_SnAuthSession value, $Res Function(_SnAuthSession) _then) = __$SnAuthSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String? label, DateTime lastGrantedAt, DateTime? expiredAt, List<String> audiences, List<String> scopes, String? ipAddress, String? userAgent, GeoIpLocation? location, int type, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, bool isCurrent, int? childrenCount, String category, bool trusted, bool isOnline
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = freezed,Object? lastGrantedAt = null,Object? expiredAt = freezed,Object? audiences = null,Object? scopes = null,Object? ipAddress = freezed,Object? userAgent = freezed,Object? location = freezed,Object? type = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? isCurrent = null,Object? childrenCount = freezed,Object? category = null,Object? trusted = null,Object? isOnline = null,}) {
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
as bool,childrenCount: freezed == childrenCount ? _self.childrenCount : childrenCount // ignore: cast_nullable_to_non_nullable
as int?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,trusted: null == trusted ? _self.trusted : trusted // ignore: cast_nullable_to_non_nullable
as bool,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
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
