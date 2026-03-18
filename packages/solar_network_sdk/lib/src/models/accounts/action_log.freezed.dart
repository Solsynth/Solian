// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'action_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnActionLog {

 String get id; String get action; Map<String, dynamic> get meta; String get userAgent; String get ipAddress; GeoIpLocation? get location; String get accountId; String? get sessionId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnActionLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnActionLogCopyWith<SnActionLog> get copyWith => _$SnActionLogCopyWithImpl<SnActionLog>(this as SnActionLog, _$identity);

  /// Serializes this SnActionLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnActionLog&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.location, location) || other.location == location)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,const DeepCollectionEquality().hash(meta),userAgent,ipAddress,location,accountId,sessionId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnActionLog(id: $id, action: $action, meta: $meta, userAgent: $userAgent, ipAddress: $ipAddress, location: $location, accountId: $accountId, sessionId: $sessionId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnActionLogCopyWith<$Res>  {
  factory $SnActionLogCopyWith(SnActionLog value, $Res Function(SnActionLog) _then) = _$SnActionLogCopyWithImpl;
@useResult
$Res call({
 String id, String action, Map<String, dynamic> meta, String userAgent, String ipAddress, GeoIpLocation? location, String accountId, String? sessionId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$GeoIpLocationCopyWith<$Res>? get location;

}
/// @nodoc
class _$SnActionLogCopyWithImpl<$Res>
    implements $SnActionLogCopyWith<$Res> {
  _$SnActionLogCopyWithImpl(this._self, this._then);

  final SnActionLog _self;
  final $Res Function(SnActionLog) _then;

/// Create a copy of SnActionLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? action = null,Object? meta = null,Object? userAgent = null,Object? ipAddress = null,Object? location = freezed,Object? accountId = null,Object? sessionId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoIpLocation?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnActionLog
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


/// Adds pattern-matching-related methods to [SnActionLog].
extension SnActionLogPatterns on SnActionLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnActionLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnActionLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnActionLog value)  $default,){
final _that = this;
switch (_that) {
case _SnActionLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnActionLog value)?  $default,){
final _that = this;
switch (_that) {
case _SnActionLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String action,  Map<String, dynamic> meta,  String userAgent,  String ipAddress,  GeoIpLocation? location,  String accountId,  String? sessionId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnActionLog() when $default != null:
return $default(_that.id,_that.action,_that.meta,_that.userAgent,_that.ipAddress,_that.location,_that.accountId,_that.sessionId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String action,  Map<String, dynamic> meta,  String userAgent,  String ipAddress,  GeoIpLocation? location,  String accountId,  String? sessionId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnActionLog():
return $default(_that.id,_that.action,_that.meta,_that.userAgent,_that.ipAddress,_that.location,_that.accountId,_that.sessionId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String action,  Map<String, dynamic> meta,  String userAgent,  String ipAddress,  GeoIpLocation? location,  String accountId,  String? sessionId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnActionLog() when $default != null:
return $default(_that.id,_that.action,_that.meta,_that.userAgent,_that.ipAddress,_that.location,_that.accountId,_that.sessionId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnActionLog implements SnActionLog {
  const _SnActionLog({required this.id, required this.action, required final  Map<String, dynamic> meta, required this.userAgent, required this.ipAddress, required this.location, required this.accountId, required this.sessionId, required this.createdAt, required this.updatedAt, required this.deletedAt}): _meta = meta;
  factory _SnActionLog.fromJson(Map<String, dynamic> json) => _$SnActionLogFromJson(json);

@override final  String id;
@override final  String action;
 final  Map<String, dynamic> _meta;
@override Map<String, dynamic> get meta {
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meta);
}

@override final  String userAgent;
@override final  String ipAddress;
@override final  GeoIpLocation? location;
@override final  String accountId;
@override final  String? sessionId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnActionLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnActionLogCopyWith<_SnActionLog> get copyWith => __$SnActionLogCopyWithImpl<_SnActionLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnActionLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnActionLog&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.userAgent, userAgent) || other.userAgent == userAgent)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.location, location) || other.location == location)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,action,const DeepCollectionEquality().hash(_meta),userAgent,ipAddress,location,accountId,sessionId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnActionLog(id: $id, action: $action, meta: $meta, userAgent: $userAgent, ipAddress: $ipAddress, location: $location, accountId: $accountId, sessionId: $sessionId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnActionLogCopyWith<$Res> implements $SnActionLogCopyWith<$Res> {
  factory _$SnActionLogCopyWith(_SnActionLog value, $Res Function(_SnActionLog) _then) = __$SnActionLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String action, Map<String, dynamic> meta, String userAgent, String ipAddress, GeoIpLocation? location, String accountId, String? sessionId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $GeoIpLocationCopyWith<$Res>? get location;

}
/// @nodoc
class __$SnActionLogCopyWithImpl<$Res>
    implements _$SnActionLogCopyWith<$Res> {
  __$SnActionLogCopyWithImpl(this._self, this._then);

  final _SnActionLog _self;
  final $Res Function(_SnActionLog) _then;

/// Create a copy of SnActionLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? action = null,Object? meta = null,Object? userAgent = null,Object? ipAddress = null,Object? location = freezed,Object? accountId = null,Object? sessionId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnActionLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,userAgent: null == userAgent ? _self.userAgent : userAgent // ignore: cast_nullable_to_non_nullable
as String,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoIpLocation?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnActionLog
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
