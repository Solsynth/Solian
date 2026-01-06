// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'relationship.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnRelationship {

 DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt; String get accountId;// Usually the account was not included in the response
 SnAccount? get account; String get relatedId; SnAccount? get related; DateTime? get expiredAt; int get status;
/// Create a copy of SnRelationship
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnRelationshipCopyWith<SnRelationship> get copyWith => _$SnRelationshipCopyWithImpl<SnRelationship>(this as SnRelationship, _$identity);

  /// Serializes this SnRelationship to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnRelationship&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.relatedId, relatedId) || other.relatedId == relatedId)&&(identical(other.related, related) || other.related == related)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,deletedAt,accountId,account,relatedId,related,expiredAt,status);

@override
String toString() {
  return 'SnRelationship(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, accountId: $accountId, account: $account, relatedId: $relatedId, related: $related, expiredAt: $expiredAt, status: $status)';
}


}

/// @nodoc
abstract mixin class $SnRelationshipCopyWith<$Res>  {
  factory $SnRelationshipCopyWith(SnRelationship value, $Res Function(SnRelationship) _then) = _$SnRelationshipCopyWithImpl;
@useResult
$Res call({
 DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, String accountId, SnAccount? account, String relatedId, SnAccount? related, DateTime? expiredAt, int status
});


$SnAccountCopyWith<$Res>? get account;$SnAccountCopyWith<$Res>? get related;

}
/// @nodoc
class _$SnRelationshipCopyWithImpl<$Res>
    implements $SnRelationshipCopyWith<$Res> {
  _$SnRelationshipCopyWithImpl(this._self, this._then);

  final SnRelationship _self;
  final $Res Function(SnRelationship) _then;

/// Create a copy of SnRelationship
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? accountId = null,Object? account = freezed,Object? relatedId = null,Object? related = freezed,Object? expiredAt = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,relatedId: null == relatedId ? _self.relatedId : relatedId // ignore: cast_nullable_to_non_nullable
as String,related: freezed == related ? _self.related : related // ignore: cast_nullable_to_non_nullable
as SnAccount?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SnRelationship
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
}/// Create a copy of SnRelationship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get related {
    if (_self.related == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.related!, (value) {
    return _then(_self.copyWith(related: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnRelationship].
extension SnRelationshipPatterns on SnRelationship {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnRelationship value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnRelationship() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnRelationship value)  $default,){
final _that = this;
switch (_that) {
case _SnRelationship():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnRelationship value)?  $default,){
final _that = this;
switch (_that) {
case _SnRelationship() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String accountId,  SnAccount? account,  String relatedId,  SnAccount? related,  DateTime? expiredAt,  int status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnRelationship() when $default != null:
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.accountId,_that.account,_that.relatedId,_that.related,_that.expiredAt,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String accountId,  SnAccount? account,  String relatedId,  SnAccount? related,  DateTime? expiredAt,  int status)  $default,) {final _that = this;
switch (_that) {
case _SnRelationship():
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.accountId,_that.account,_that.relatedId,_that.related,_that.expiredAt,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String accountId,  SnAccount? account,  String relatedId,  SnAccount? related,  DateTime? expiredAt,  int status)?  $default,) {final _that = this;
switch (_that) {
case _SnRelationship() when $default != null:
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.accountId,_that.account,_that.relatedId,_that.related,_that.expiredAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnRelationship implements SnRelationship {
  const _SnRelationship({required this.createdAt, required this.updatedAt, required this.deletedAt, required this.accountId, required this.account, required this.relatedId, required this.related, required this.expiredAt, required this.status});
  factory _SnRelationship.fromJson(Map<String, dynamic> json) => _$SnRelationshipFromJson(json);

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;
@override final  String accountId;
// Usually the account was not included in the response
@override final  SnAccount? account;
@override final  String relatedId;
@override final  SnAccount? related;
@override final  DateTime? expiredAt;
@override final  int status;

/// Create a copy of SnRelationship
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnRelationshipCopyWith<_SnRelationship> get copyWith => __$SnRelationshipCopyWithImpl<_SnRelationship>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnRelationshipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnRelationship&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.relatedId, relatedId) || other.relatedId == relatedId)&&(identical(other.related, related) || other.related == related)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,deletedAt,accountId,account,relatedId,related,expiredAt,status);

@override
String toString() {
  return 'SnRelationship(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, accountId: $accountId, account: $account, relatedId: $relatedId, related: $related, expiredAt: $expiredAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SnRelationshipCopyWith<$Res> implements $SnRelationshipCopyWith<$Res> {
  factory _$SnRelationshipCopyWith(_SnRelationship value, $Res Function(_SnRelationship) _then) = __$SnRelationshipCopyWithImpl;
@override @useResult
$Res call({
 DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, String accountId, SnAccount? account, String relatedId, SnAccount? related, DateTime? expiredAt, int status
});


@override $SnAccountCopyWith<$Res>? get account;@override $SnAccountCopyWith<$Res>? get related;

}
/// @nodoc
class __$SnRelationshipCopyWithImpl<$Res>
    implements _$SnRelationshipCopyWith<$Res> {
  __$SnRelationshipCopyWithImpl(this._self, this._then);

  final _SnRelationship _self;
  final $Res Function(_SnRelationship) _then;

/// Create a copy of SnRelationship
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? accountId = null,Object? account = freezed,Object? relatedId = null,Object? related = freezed,Object? expiredAt = freezed,Object? status = null,}) {
  return _then(_SnRelationship(
createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,relatedId: null == relatedId ? _self.relatedId : relatedId // ignore: cast_nullable_to_non_nullable
as String,related: freezed == related ? _self.related : related // ignore: cast_nullable_to_non_nullable
as SnAccount?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SnRelationship
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
}/// Create a copy of SnRelationship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get related {
    if (_self.related == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.related!, (value) {
    return _then(_self.copyWith(related: value));
  });
}
}

// dart format on
