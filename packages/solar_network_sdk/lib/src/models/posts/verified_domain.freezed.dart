// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verified_domain.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPublisherVerifiedDomain {

 String get id;@JsonKey(name: 'publisher_id') String get publisherId; String get domain; DomainVerificationStatus get status;@JsonKey(name: 'verified_at') DateTime? get verifiedAt;@JsonKey(name: 'last_checked_at') DateTime? get lastCheckedAt;@JsonKey(name: 'failed_attempts') int get failedAttempts;@JsonKey(name: 'last_error') String? get lastError;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of SnPublisherVerifiedDomain
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherVerifiedDomainCopyWith<SnPublisherVerifiedDomain> get copyWith => _$SnPublisherVerifiedDomainCopyWithImpl<SnPublisherVerifiedDomain>(this as SnPublisherVerifiedDomain, _$identity);

  /// Serializes this SnPublisherVerifiedDomain to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherVerifiedDomain&&(identical(other.id, id) || other.id == id)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.status, status) || other.status == status)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.lastCheckedAt, lastCheckedAt) || other.lastCheckedAt == lastCheckedAt)&&(identical(other.failedAttempts, failedAttempts) || other.failedAttempts == failedAttempts)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publisherId,domain,status,verifiedAt,lastCheckedAt,failedAttempts,lastError,createdAt,updatedAt);

@override
String toString() {
  return 'SnPublisherVerifiedDomain(id: $id, publisherId: $publisherId, domain: $domain, status: $status, verifiedAt: $verifiedAt, lastCheckedAt: $lastCheckedAt, failedAttempts: $failedAttempts, lastError: $lastError, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SnPublisherVerifiedDomainCopyWith<$Res>  {
  factory $SnPublisherVerifiedDomainCopyWith(SnPublisherVerifiedDomain value, $Res Function(SnPublisherVerifiedDomain) _then) = _$SnPublisherVerifiedDomainCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'publisher_id') String publisherId, String domain, DomainVerificationStatus status,@JsonKey(name: 'verified_at') DateTime? verifiedAt,@JsonKey(name: 'last_checked_at') DateTime? lastCheckedAt,@JsonKey(name: 'failed_attempts') int failedAttempts,@JsonKey(name: 'last_error') String? lastError,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$SnPublisherVerifiedDomainCopyWithImpl<$Res>
    implements $SnPublisherVerifiedDomainCopyWith<$Res> {
  _$SnPublisherVerifiedDomainCopyWithImpl(this._self, this._then);

  final SnPublisherVerifiedDomain _self;
  final $Res Function(SnPublisherVerifiedDomain) _then;

/// Create a copy of SnPublisherVerifiedDomain
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? publisherId = null,Object? domain = null,Object? status = null,Object? verifiedAt = freezed,Object? lastCheckedAt = freezed,Object? failedAttempts = null,Object? lastError = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DomainVerificationStatus,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastCheckedAt: freezed == lastCheckedAt ? _self.lastCheckedAt : lastCheckedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failedAttempts: null == failedAttempts ? _self.failedAttempts : failedAttempts // ignore: cast_nullable_to_non_nullable
as int,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPublisherVerifiedDomain].
extension SnPublisherVerifiedDomainPatterns on SnPublisherVerifiedDomain {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherVerifiedDomain value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherVerifiedDomain() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherVerifiedDomain value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherVerifiedDomain():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherVerifiedDomain value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherVerifiedDomain() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'publisher_id')  String publisherId,  String domain,  DomainVerificationStatus status, @JsonKey(name: 'verified_at')  DateTime? verifiedAt, @JsonKey(name: 'last_checked_at')  DateTime? lastCheckedAt, @JsonKey(name: 'failed_attempts')  int failedAttempts, @JsonKey(name: 'last_error')  String? lastError, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherVerifiedDomain() when $default != null:
return $default(_that.id,_that.publisherId,_that.domain,_that.status,_that.verifiedAt,_that.lastCheckedAt,_that.failedAttempts,_that.lastError,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'publisher_id')  String publisherId,  String domain,  DomainVerificationStatus status, @JsonKey(name: 'verified_at')  DateTime? verifiedAt, @JsonKey(name: 'last_checked_at')  DateTime? lastCheckedAt, @JsonKey(name: 'failed_attempts')  int failedAttempts, @JsonKey(name: 'last_error')  String? lastError, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherVerifiedDomain():
return $default(_that.id,_that.publisherId,_that.domain,_that.status,_that.verifiedAt,_that.lastCheckedAt,_that.failedAttempts,_that.lastError,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'publisher_id')  String publisherId,  String domain,  DomainVerificationStatus status, @JsonKey(name: 'verified_at')  DateTime? verifiedAt, @JsonKey(name: 'last_checked_at')  DateTime? lastCheckedAt, @JsonKey(name: 'failed_attempts')  int failedAttempts, @JsonKey(name: 'last_error')  String? lastError, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherVerifiedDomain() when $default != null:
return $default(_that.id,_that.publisherId,_that.domain,_that.status,_that.verifiedAt,_that.lastCheckedAt,_that.failedAttempts,_that.lastError,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherVerifiedDomain implements SnPublisherVerifiedDomain {
  const _SnPublisherVerifiedDomain({required this.id, @JsonKey(name: 'publisher_id') required this.publisherId, required this.domain, this.status = DomainVerificationStatus.pending, @JsonKey(name: 'verified_at') this.verifiedAt = null, @JsonKey(name: 'last_checked_at') this.lastCheckedAt = null, @JsonKey(name: 'failed_attempts') this.failedAttempts = 0, @JsonKey(name: 'last_error') this.lastError = null, @JsonKey(name: 'created_at') this.createdAt = null, @JsonKey(name: 'updated_at') this.updatedAt = null});
  factory _SnPublisherVerifiedDomain.fromJson(Map<String, dynamic> json) => _$SnPublisherVerifiedDomainFromJson(json);

@override final  String id;
@override@JsonKey(name: 'publisher_id') final  String publisherId;
@override final  String domain;
@override@JsonKey() final  DomainVerificationStatus status;
@override@JsonKey(name: 'verified_at') final  DateTime? verifiedAt;
@override@JsonKey(name: 'last_checked_at') final  DateTime? lastCheckedAt;
@override@JsonKey(name: 'failed_attempts') final  int failedAttempts;
@override@JsonKey(name: 'last_error') final  String? lastError;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of SnPublisherVerifiedDomain
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherVerifiedDomainCopyWith<_SnPublisherVerifiedDomain> get copyWith => __$SnPublisherVerifiedDomainCopyWithImpl<_SnPublisherVerifiedDomain>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherVerifiedDomainToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherVerifiedDomain&&(identical(other.id, id) || other.id == id)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.status, status) || other.status == status)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.lastCheckedAt, lastCheckedAt) || other.lastCheckedAt == lastCheckedAt)&&(identical(other.failedAttempts, failedAttempts) || other.failedAttempts == failedAttempts)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,publisherId,domain,status,verifiedAt,lastCheckedAt,failedAttempts,lastError,createdAt,updatedAt);

@override
String toString() {
  return 'SnPublisherVerifiedDomain(id: $id, publisherId: $publisherId, domain: $domain, status: $status, verifiedAt: $verifiedAt, lastCheckedAt: $lastCheckedAt, failedAttempts: $failedAttempts, lastError: $lastError, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherVerifiedDomainCopyWith<$Res> implements $SnPublisherVerifiedDomainCopyWith<$Res> {
  factory _$SnPublisherVerifiedDomainCopyWith(_SnPublisherVerifiedDomain value, $Res Function(_SnPublisherVerifiedDomain) _then) = __$SnPublisherVerifiedDomainCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'publisher_id') String publisherId, String domain, DomainVerificationStatus status,@JsonKey(name: 'verified_at') DateTime? verifiedAt,@JsonKey(name: 'last_checked_at') DateTime? lastCheckedAt,@JsonKey(name: 'failed_attempts') int failedAttempts,@JsonKey(name: 'last_error') String? lastError,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$SnPublisherVerifiedDomainCopyWithImpl<$Res>
    implements _$SnPublisherVerifiedDomainCopyWith<$Res> {
  __$SnPublisherVerifiedDomainCopyWithImpl(this._self, this._then);

  final _SnPublisherVerifiedDomain _self;
  final $Res Function(_SnPublisherVerifiedDomain) _then;

/// Create a copy of SnPublisherVerifiedDomain
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? publisherId = null,Object? domain = null,Object? status = null,Object? verifiedAt = freezed,Object? lastCheckedAt = freezed,Object? failedAttempts = null,Object? lastError = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_SnPublisherVerifiedDomain(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DomainVerificationStatus,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastCheckedAt: freezed == lastCheckedAt ? _self.lastCheckedAt : lastCheckedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,failedAttempts: null == failedAttempts ? _self.failedAttempts : failedAttempts // ignore: cast_nullable_to_non_nullable
as int,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
