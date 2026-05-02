// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'publisher_rating_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPublisherRatingRecord {

 String get id;@JsonKey(name: 'reason_type') String get reasonType; String get reason; double get delta; SnPublisherRatingStatus get status;@JsonKey(name: 'expired_at') DateTime? get expiredAt;@JsonKey(name: 'publisher_id') String get publisherId;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'deleted_at') DateTime? get deletedAt;
/// Create a copy of SnPublisherRatingRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherRatingRecordCopyWith<SnPublisherRatingRecord> get copyWith => _$SnPublisherRatingRecordCopyWithImpl<SnPublisherRatingRecord>(this as SnPublisherRatingRecord, _$identity);

  /// Serializes this SnPublisherRatingRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherRatingRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.reasonType, reasonType) || other.reasonType == reasonType)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reasonType,reason,delta,status,expiredAt,publisherId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPublisherRatingRecord(id: $id, reasonType: $reasonType, reason: $reason, delta: $delta, status: $status, expiredAt: $expiredAt, publisherId: $publisherId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnPublisherRatingRecordCopyWith<$Res>  {
  factory $SnPublisherRatingRecordCopyWith(SnPublisherRatingRecord value, $Res Function(SnPublisherRatingRecord) _then) = _$SnPublisherRatingRecordCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'reason_type') String reasonType, String reason, double delta, SnPublisherRatingStatus status,@JsonKey(name: 'expired_at') DateTime? expiredAt,@JsonKey(name: 'publisher_id') String publisherId,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'deleted_at') DateTime? deletedAt
});




}
/// @nodoc
class _$SnPublisherRatingRecordCopyWithImpl<$Res>
    implements $SnPublisherRatingRecordCopyWith<$Res> {
  _$SnPublisherRatingRecordCopyWithImpl(this._self, this._then);

  final SnPublisherRatingRecord _self;
  final $Res Function(SnPublisherRatingRecord) _then;

/// Create a copy of SnPublisherRatingRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reasonType = null,Object? reason = null,Object? delta = null,Object? status = null,Object? expiredAt = freezed,Object? publisherId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reasonType: null == reasonType ? _self.reasonType : reasonType // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnPublisherRatingStatus,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPublisherRatingRecord].
extension SnPublisherRatingRecordPatterns on SnPublisherRatingRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherRatingRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherRatingRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherRatingRecord value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherRatingRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherRatingRecord value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherRatingRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'reason_type')  String reasonType,  String reason,  double delta,  SnPublisherRatingStatus status, @JsonKey(name: 'expired_at')  DateTime? expiredAt, @JsonKey(name: 'publisher_id')  String publisherId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherRatingRecord() when $default != null:
return $default(_that.id,_that.reasonType,_that.reason,_that.delta,_that.status,_that.expiredAt,_that.publisherId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'reason_type')  String reasonType,  String reason,  double delta,  SnPublisherRatingStatus status, @JsonKey(name: 'expired_at')  DateTime? expiredAt, @JsonKey(name: 'publisher_id')  String publisherId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherRatingRecord():
return $default(_that.id,_that.reasonType,_that.reason,_that.delta,_that.status,_that.expiredAt,_that.publisherId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'reason_type')  String reasonType,  String reason,  double delta,  SnPublisherRatingStatus status, @JsonKey(name: 'expired_at')  DateTime? expiredAt, @JsonKey(name: 'publisher_id')  String publisherId, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherRatingRecord() when $default != null:
return $default(_that.id,_that.reasonType,_that.reason,_that.delta,_that.status,_that.expiredAt,_that.publisherId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherRatingRecord implements SnPublisherRatingRecord {
  const _SnPublisherRatingRecord({required this.id, @JsonKey(name: 'reason_type') required this.reasonType, required this.reason, required this.delta, required this.status, @JsonKey(name: 'expired_at') this.expiredAt, @JsonKey(name: 'publisher_id') required this.publisherId, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'deleted_at') this.deletedAt});
  factory _SnPublisherRatingRecord.fromJson(Map<String, dynamic> json) => _$SnPublisherRatingRecordFromJson(json);

@override final  String id;
@override@JsonKey(name: 'reason_type') final  String reasonType;
@override final  String reason;
@override final  double delta;
@override final  SnPublisherRatingStatus status;
@override@JsonKey(name: 'expired_at') final  DateTime? expiredAt;
@override@JsonKey(name: 'publisher_id') final  String publisherId;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'deleted_at') final  DateTime? deletedAt;

/// Create a copy of SnPublisherRatingRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherRatingRecordCopyWith<_SnPublisherRatingRecord> get copyWith => __$SnPublisherRatingRecordCopyWithImpl<_SnPublisherRatingRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherRatingRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherRatingRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.reasonType, reasonType) || other.reasonType == reasonType)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reasonType,reason,delta,status,expiredAt,publisherId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPublisherRatingRecord(id: $id, reasonType: $reasonType, reason: $reason, delta: $delta, status: $status, expiredAt: $expiredAt, publisherId: $publisherId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherRatingRecordCopyWith<$Res> implements $SnPublisherRatingRecordCopyWith<$Res> {
  factory _$SnPublisherRatingRecordCopyWith(_SnPublisherRatingRecord value, $Res Function(_SnPublisherRatingRecord) _then) = __$SnPublisherRatingRecordCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'reason_type') String reasonType, String reason, double delta, SnPublisherRatingStatus status,@JsonKey(name: 'expired_at') DateTime? expiredAt,@JsonKey(name: 'publisher_id') String publisherId,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'deleted_at') DateTime? deletedAt
});




}
/// @nodoc
class __$SnPublisherRatingRecordCopyWithImpl<$Res>
    implements _$SnPublisherRatingRecordCopyWith<$Res> {
  __$SnPublisherRatingRecordCopyWithImpl(this._self, this._then);

  final _SnPublisherRatingRecord _self;
  final $Res Function(_SnPublisherRatingRecord) _then;

/// Create a copy of SnPublisherRatingRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reasonType = null,Object? reason = null,Object? delta = null,Object? status = null,Object? expiredAt = freezed,Object? publisherId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnPublisherRatingRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reasonType: null == reasonType ? _self.reasonType : reasonType // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnPublisherRatingStatus,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
