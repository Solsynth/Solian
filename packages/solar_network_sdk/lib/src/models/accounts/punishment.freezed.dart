// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'punishment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnAccountPunishment {

 String get id; String get reason;@JsonKey(name: 'expired_at') DateTime? get expiredAt;@PunishmentTypeConverter() PunishmentType get type;@JsonKey(name: 'blocked_permissions') List<String>? get blockedPermissions;@JsonKey(name: 'account_id') String get accountId; SnAccount? get account;@JsonKey(name: 'creator_id') String? get creatorId; SnAccount? get creator;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'deleted_at') DateTime? get deletedAt;
/// Create a copy of SnAccountPunishment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountPunishmentCopyWith<SnAccountPunishment> get copyWith => _$SnAccountPunishmentCopyWithImpl<SnAccountPunishment>(this as SnAccountPunishment, _$identity);

  /// Serializes this SnAccountPunishment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountPunishment&&(identical(other.id, id) || other.id == id)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.blockedPermissions, blockedPermissions)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reason,expiredAt,type,const DeepCollectionEquality().hash(blockedPermissions),accountId,account,creatorId,creator,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountPunishment(id: $id, reason: $reason, expiredAt: $expiredAt, type: $type, blockedPermissions: $blockedPermissions, accountId: $accountId, account: $account, creatorId: $creatorId, creator: $creator, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAccountPunishmentCopyWith<$Res>  {
  factory $SnAccountPunishmentCopyWith(SnAccountPunishment value, $Res Function(SnAccountPunishment) _then) = _$SnAccountPunishmentCopyWithImpl;
@useResult
$Res call({
 String id, String reason,@JsonKey(name: 'expired_at') DateTime? expiredAt,@PunishmentTypeConverter() PunishmentType type,@JsonKey(name: 'blocked_permissions') List<String>? blockedPermissions,@JsonKey(name: 'account_id') String accountId, SnAccount? account,@JsonKey(name: 'creator_id') String? creatorId, SnAccount? creator,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'deleted_at') DateTime? deletedAt
});


$SnAccountCopyWith<$Res>? get account;$SnAccountCopyWith<$Res>? get creator;

}
/// @nodoc
class _$SnAccountPunishmentCopyWithImpl<$Res>
    implements $SnAccountPunishmentCopyWith<$Res> {
  _$SnAccountPunishmentCopyWithImpl(this._self, this._then);

  final SnAccountPunishment _self;
  final $Res Function(SnAccountPunishment) _then;

/// Create a copy of SnAccountPunishment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reason = null,Object? expiredAt = freezed,Object? type = null,Object? blockedPermissions = freezed,Object? accountId = null,Object? account = freezed,Object? creatorId = freezed,Object? creator = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PunishmentType,blockedPermissions: freezed == blockedPermissions ? _self.blockedPermissions : blockedPermissions // ignore: cast_nullable_to_non_nullable
as List<String>?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,creatorId: freezed == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String?,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as SnAccount?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnAccountPunishment
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
}/// Create a copy of SnAccountPunishment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get creator {
    if (_self.creator == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.creator!, (value) {
    return _then(_self.copyWith(creator: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnAccountPunishment].
extension SnAccountPunishmentPatterns on SnAccountPunishment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAccountPunishment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAccountPunishment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAccountPunishment value)  $default,){
final _that = this;
switch (_that) {
case _SnAccountPunishment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAccountPunishment value)?  $default,){
final _that = this;
switch (_that) {
case _SnAccountPunishment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reason, @JsonKey(name: 'expired_at')  DateTime? expiredAt, @PunishmentTypeConverter()  PunishmentType type, @JsonKey(name: 'blocked_permissions')  List<String>? blockedPermissions, @JsonKey(name: 'account_id')  String accountId,  SnAccount? account, @JsonKey(name: 'creator_id')  String? creatorId,  SnAccount? creator, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAccountPunishment() when $default != null:
return $default(_that.id,_that.reason,_that.expiredAt,_that.type,_that.blockedPermissions,_that.accountId,_that.account,_that.creatorId,_that.creator,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reason, @JsonKey(name: 'expired_at')  DateTime? expiredAt, @PunishmentTypeConverter()  PunishmentType type, @JsonKey(name: 'blocked_permissions')  List<String>? blockedPermissions, @JsonKey(name: 'account_id')  String accountId,  SnAccount? account, @JsonKey(name: 'creator_id')  String? creatorId,  SnAccount? creator, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnAccountPunishment():
return $default(_that.id,_that.reason,_that.expiredAt,_that.type,_that.blockedPermissions,_that.accountId,_that.account,_that.creatorId,_that.creator,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reason, @JsonKey(name: 'expired_at')  DateTime? expiredAt, @PunishmentTypeConverter()  PunishmentType type, @JsonKey(name: 'blocked_permissions')  List<String>? blockedPermissions, @JsonKey(name: 'account_id')  String accountId,  SnAccount? account, @JsonKey(name: 'creator_id')  String? creatorId,  SnAccount? creator, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnAccountPunishment() when $default != null:
return $default(_that.id,_that.reason,_that.expiredAt,_that.type,_that.blockedPermissions,_that.accountId,_that.account,_that.creatorId,_that.creator,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAccountPunishment implements SnAccountPunishment {
  const _SnAccountPunishment({required this.id, required this.reason, @JsonKey(name: 'expired_at') this.expiredAt, @PunishmentTypeConverter() required this.type, @JsonKey(name: 'blocked_permissions') final  List<String>? blockedPermissions, @JsonKey(name: 'account_id') required this.accountId, this.account, @JsonKey(name: 'creator_id') this.creatorId, this.creator, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'deleted_at') this.deletedAt}): _blockedPermissions = blockedPermissions;
  factory _SnAccountPunishment.fromJson(Map<String, dynamic> json) => _$SnAccountPunishmentFromJson(json);

@override final  String id;
@override final  String reason;
@override@JsonKey(name: 'expired_at') final  DateTime? expiredAt;
@override@PunishmentTypeConverter() final  PunishmentType type;
 final  List<String>? _blockedPermissions;
@override@JsonKey(name: 'blocked_permissions') List<String>? get blockedPermissions {
  final value = _blockedPermissions;
  if (value == null) return null;
  if (_blockedPermissions is EqualUnmodifiableListView) return _blockedPermissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'account_id') final  String accountId;
@override final  SnAccount? account;
@override@JsonKey(name: 'creator_id') final  String? creatorId;
@override final  SnAccount? creator;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'deleted_at') final  DateTime? deletedAt;

/// Create a copy of SnAccountPunishment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountPunishmentCopyWith<_SnAccountPunishment> get copyWith => __$SnAccountPunishmentCopyWithImpl<_SnAccountPunishment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountPunishmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountPunishment&&(identical(other.id, id) || other.id == id)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._blockedPermissions, _blockedPermissions)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reason,expiredAt,type,const DeepCollectionEquality().hash(_blockedPermissions),accountId,account,creatorId,creator,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountPunishment(id: $id, reason: $reason, expiredAt: $expiredAt, type: $type, blockedPermissions: $blockedPermissions, accountId: $accountId, account: $account, creatorId: $creatorId, creator: $creator, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAccountPunishmentCopyWith<$Res> implements $SnAccountPunishmentCopyWith<$Res> {
  factory _$SnAccountPunishmentCopyWith(_SnAccountPunishment value, $Res Function(_SnAccountPunishment) _then) = __$SnAccountPunishmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String reason,@JsonKey(name: 'expired_at') DateTime? expiredAt,@PunishmentTypeConverter() PunishmentType type,@JsonKey(name: 'blocked_permissions') List<String>? blockedPermissions,@JsonKey(name: 'account_id') String accountId, SnAccount? account,@JsonKey(name: 'creator_id') String? creatorId, SnAccount? creator,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'deleted_at') DateTime? deletedAt
});


@override $SnAccountCopyWith<$Res>? get account;@override $SnAccountCopyWith<$Res>? get creator;

}
/// @nodoc
class __$SnAccountPunishmentCopyWithImpl<$Res>
    implements _$SnAccountPunishmentCopyWith<$Res> {
  __$SnAccountPunishmentCopyWithImpl(this._self, this._then);

  final _SnAccountPunishment _self;
  final $Res Function(_SnAccountPunishment) _then;

/// Create a copy of SnAccountPunishment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reason = null,Object? expiredAt = freezed,Object? type = null,Object? blockedPermissions = freezed,Object? accountId = null,Object? account = freezed,Object? creatorId = freezed,Object? creator = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAccountPunishment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PunishmentType,blockedPermissions: freezed == blockedPermissions ? _self._blockedPermissions : blockedPermissions // ignore: cast_nullable_to_non_nullable
as List<String>?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,creatorId: freezed == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String?,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as SnAccount?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnAccountPunishment
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
}/// Create a copy of SnAccountPunishment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get creator {
    if (_self.creator == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.creator!, (value) {
    return _then(_self.copyWith(creator: value));
  });
}
}

// dart format on
