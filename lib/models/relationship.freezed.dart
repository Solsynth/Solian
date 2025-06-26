// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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

 DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt; String get accountId; SnAccount get account; String get relatedId; SnAccount get related; DateTime? get expiredAt; int get status;
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
 DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, String accountId, SnAccount account, String relatedId, SnAccount related, DateTime? expiredAt, int status
});


$SnAccountCopyWith<$Res> get account;$SnAccountCopyWith<$Res> get related;

}
/// @nodoc
class _$SnRelationshipCopyWithImpl<$Res>
    implements $SnRelationshipCopyWith<$Res> {
  _$SnRelationshipCopyWithImpl(this._self, this._then);

  final SnRelationship _self;
  final $Res Function(SnRelationship) _then;

/// Create a copy of SnRelationship
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? accountId = null,Object? account = null,Object? relatedId = null,Object? related = null,Object? expiredAt = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount,relatedId: null == relatedId ? _self.relatedId : relatedId // ignore: cast_nullable_to_non_nullable
as String,related: null == related ? _self.related : related // ignore: cast_nullable_to_non_nullable
as SnAccount,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SnRelationship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get account {
  
  return $SnAccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of SnRelationship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get related {
  
  return $SnAccountCopyWith<$Res>(_self.related, (value) {
    return _then(_self.copyWith(related: value));
  });
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
@override final  SnAccount account;
@override final  String relatedId;
@override final  SnAccount related;
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
 DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, String accountId, SnAccount account, String relatedId, SnAccount related, DateTime? expiredAt, int status
});


@override $SnAccountCopyWith<$Res> get account;@override $SnAccountCopyWith<$Res> get related;

}
/// @nodoc
class __$SnRelationshipCopyWithImpl<$Res>
    implements _$SnRelationshipCopyWith<$Res> {
  __$SnRelationshipCopyWithImpl(this._self, this._then);

  final _SnRelationship _self;
  final $Res Function(_SnRelationship) _then;

/// Create a copy of SnRelationship
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? accountId = null,Object? account = null,Object? relatedId = null,Object? related = null,Object? expiredAt = freezed,Object? status = null,}) {
  return _then(_SnRelationship(
createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount,relatedId: null == relatedId ? _self.relatedId : relatedId // ignore: cast_nullable_to_non_nullable
as String,related: null == related ? _self.related : related // ignore: cast_nullable_to_non_nullable
as SnAccount,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SnRelationship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get account {
  
  return $SnAccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of SnRelationship
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get related {
  
  return $SnAccountCopyWith<$Res>(_self.related, (value) {
    return _then(_self.copyWith(related: value));
  });
}
}

// dart format on
