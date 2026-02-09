// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'abuse_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnAbuseReport {

 String get id; String get resourceIdentifier; int get type; String get reason; DateTime? get resolvedAt; String? get resolution; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAbuseReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAbuseReportCopyWith<SnAbuseReport> get copyWith => _$SnAbuseReportCopyWithImpl<SnAbuseReport>(this as SnAbuseReport, _$identity);

  /// Serializes this SnAbuseReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAbuseReport&&(identical(other.id, id) || other.id == id)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&(identical(other.type, type) || other.type == type)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resourceIdentifier,type,reason,resolvedAt,resolution,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAbuseReport(id: $id, resourceIdentifier: $resourceIdentifier, type: $type, reason: $reason, resolvedAt: $resolvedAt, resolution: $resolution, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAbuseReportCopyWith<$Res>  {
  factory $SnAbuseReportCopyWith(SnAbuseReport value, $Res Function(SnAbuseReport) _then) = _$SnAbuseReportCopyWithImpl;
@useResult
$Res call({
 String id, String resourceIdentifier, int type, String reason, DateTime? resolvedAt, String? resolution, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnAbuseReportCopyWithImpl<$Res>
    implements $SnAbuseReportCopyWith<$Res> {
  _$SnAbuseReportCopyWithImpl(this._self, this._then);

  final SnAbuseReport _self;
  final $Res Function(SnAbuseReport) _then;

/// Create a copy of SnAbuseReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? resourceIdentifier = null,Object? type = null,Object? reason = null,Object? resolvedAt = freezed,Object? resolution = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resourceIdentifier: null == resourceIdentifier ? _self.resourceIdentifier : resourceIdentifier // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnAbuseReport].
extension SnAbuseReportPatterns on SnAbuseReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAbuseReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAbuseReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAbuseReport value)  $default,){
final _that = this;
switch (_that) {
case _SnAbuseReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAbuseReport value)?  $default,){
final _that = this;
switch (_that) {
case _SnAbuseReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String resourceIdentifier,  int type,  String reason,  DateTime? resolvedAt,  String? resolution,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAbuseReport() when $default != null:
return $default(_that.id,_that.resourceIdentifier,_that.type,_that.reason,_that.resolvedAt,_that.resolution,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String resourceIdentifier,  int type,  String reason,  DateTime? resolvedAt,  String? resolution,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnAbuseReport():
return $default(_that.id,_that.resourceIdentifier,_that.type,_that.reason,_that.resolvedAt,_that.resolution,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String resourceIdentifier,  int type,  String reason,  DateTime? resolvedAt,  String? resolution,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnAbuseReport() when $default != null:
return $default(_that.id,_that.resourceIdentifier,_that.type,_that.reason,_that.resolvedAt,_that.resolution,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAbuseReport implements SnAbuseReport {
  const _SnAbuseReport({required this.id, required this.resourceIdentifier, required this.type, required this.reason, required this.resolvedAt, required this.resolution, required this.accountId, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnAbuseReport.fromJson(Map<String, dynamic> json) => _$SnAbuseReportFromJson(json);

@override final  String id;
@override final  String resourceIdentifier;
@override final  int type;
@override final  String reason;
@override final  DateTime? resolvedAt;
@override final  String? resolution;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAbuseReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAbuseReportCopyWith<_SnAbuseReport> get copyWith => __$SnAbuseReportCopyWithImpl<_SnAbuseReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAbuseReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAbuseReport&&(identical(other.id, id) || other.id == id)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&(identical(other.type, type) || other.type == type)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,resourceIdentifier,type,reason,resolvedAt,resolution,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAbuseReport(id: $id, resourceIdentifier: $resourceIdentifier, type: $type, reason: $reason, resolvedAt: $resolvedAt, resolution: $resolution, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAbuseReportCopyWith<$Res> implements $SnAbuseReportCopyWith<$Res> {
  factory _$SnAbuseReportCopyWith(_SnAbuseReport value, $Res Function(_SnAbuseReport) _then) = __$SnAbuseReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String resourceIdentifier, int type, String reason, DateTime? resolvedAt, String? resolution, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnAbuseReportCopyWithImpl<$Res>
    implements _$SnAbuseReportCopyWith<$Res> {
  __$SnAbuseReportCopyWithImpl(this._self, this._then);

  final _SnAbuseReport _self;
  final $Res Function(_SnAbuseReport) _then;

/// Create a copy of SnAbuseReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? resourceIdentifier = null,Object? type = null,Object? reason = null,Object? resolvedAt = freezed,Object? resolution = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAbuseReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,resourceIdentifier: null == resourceIdentifier ? _self.resourceIdentifier : resourceIdentifier // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
