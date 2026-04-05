// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'metric.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnFitnessMetric {

 String get id; String get accountId; FitnessMetricType get metricType; double get value; String get unit; DateTime get recordedAt; String? get notes; String? get source; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SnFitnessMetric
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFitnessMetricCopyWith<SnFitnessMetric> get copyWith => _$SnFitnessMetricCopyWithImpl<SnFitnessMetric>(this as SnFitnessMetric, _$identity);

  /// Serializes this SnFitnessMetric to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFitnessMetric&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,metricType,value,unit,recordedAt,notes,source,createdAt,updatedAt);

@override
String toString() {
  return 'SnFitnessMetric(id: $id, accountId: $accountId, metricType: $metricType, value: $value, unit: $unit, recordedAt: $recordedAt, notes: $notes, source: $source, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SnFitnessMetricCopyWith<$Res>  {
  factory $SnFitnessMetricCopyWith(SnFitnessMetric value, $Res Function(SnFitnessMetric) _then) = _$SnFitnessMetricCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, FitnessMetricType metricType, double value, String unit, DateTime recordedAt, String? notes, String? source, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SnFitnessMetricCopyWithImpl<$Res>
    implements $SnFitnessMetricCopyWith<$Res> {
  _$SnFitnessMetricCopyWithImpl(this._self, this._then);

  final SnFitnessMetric _self;
  final $Res Function(SnFitnessMetric) _then;

/// Create a copy of SnFitnessMetric
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? metricType = null,Object? value = null,Object? unit = null,Object? recordedAt = null,Object? notes = freezed,Object? source = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as FitnessMetricType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SnFitnessMetric].
extension SnFitnessMetricPatterns on SnFitnessMetric {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFitnessMetric value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFitnessMetric() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFitnessMetric value)  $default,){
final _that = this;
switch (_that) {
case _SnFitnessMetric():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFitnessMetric value)?  $default,){
final _that = this;
switch (_that) {
case _SnFitnessMetric() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  FitnessMetricType metricType,  double value,  String unit,  DateTime recordedAt,  String? notes,  String? source,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFitnessMetric() when $default != null:
return $default(_that.id,_that.accountId,_that.metricType,_that.value,_that.unit,_that.recordedAt,_that.notes,_that.source,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  FitnessMetricType metricType,  double value,  String unit,  DateTime recordedAt,  String? notes,  String? source,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SnFitnessMetric():
return $default(_that.id,_that.accountId,_that.metricType,_that.value,_that.unit,_that.recordedAt,_that.notes,_that.source,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  FitnessMetricType metricType,  double value,  String unit,  DateTime recordedAt,  String? notes,  String? source,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnFitnessMetric() when $default != null:
return $default(_that.id,_that.accountId,_that.metricType,_that.value,_that.unit,_that.recordedAt,_that.notes,_that.source,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFitnessMetric implements SnFitnessMetric {
  const _SnFitnessMetric({required this.id, required this.accountId, required this.metricType, required this.value, required this.unit, required this.recordedAt, this.notes, this.source, required this.createdAt, required this.updatedAt});
  factory _SnFitnessMetric.fromJson(Map<String, dynamic> json) => _$SnFitnessMetricFromJson(json);

@override final  String id;
@override final  String accountId;
@override final  FitnessMetricType metricType;
@override final  double value;
@override final  String unit;
@override final  DateTime recordedAt;
@override final  String? notes;
@override final  String? source;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SnFitnessMetric
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFitnessMetricCopyWith<_SnFitnessMetric> get copyWith => __$SnFitnessMetricCopyWithImpl<_SnFitnessMetric>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFitnessMetricToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFitnessMetric&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,metricType,value,unit,recordedAt,notes,source,createdAt,updatedAt);

@override
String toString() {
  return 'SnFitnessMetric(id: $id, accountId: $accountId, metricType: $metricType, value: $value, unit: $unit, recordedAt: $recordedAt, notes: $notes, source: $source, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnFitnessMetricCopyWith<$Res> implements $SnFitnessMetricCopyWith<$Res> {
  factory _$SnFitnessMetricCopyWith(_SnFitnessMetric value, $Res Function(_SnFitnessMetric) _then) = __$SnFitnessMetricCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, FitnessMetricType metricType, double value, String unit, DateTime recordedAt, String? notes, String? source, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SnFitnessMetricCopyWithImpl<$Res>
    implements _$SnFitnessMetricCopyWith<$Res> {
  __$SnFitnessMetricCopyWithImpl(this._self, this._then);

  final _SnFitnessMetric _self;
  final $Res Function(_SnFitnessMetric) _then;

/// Create a copy of SnFitnessMetric
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? metricType = null,Object? value = null,Object? unit = null,Object? recordedAt = null,Object? notes = freezed,Object? source = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SnFitnessMetric(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as FitnessMetricType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$CreateMetricRequest {

 FitnessMetricType get metricType; double get value; String get unit;@DateTimeConverter() DateTime get recordedAt; String? get notes; String? get source; String? get externalId;
/// Create a copy of CreateMetricRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateMetricRequestCopyWith<CreateMetricRequest> get copyWith => _$CreateMetricRequestCopyWithImpl<CreateMetricRequest>(this as CreateMetricRequest, _$identity);

  /// Serializes this CreateMetricRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateMetricRequest&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.source, source) || other.source == source)&&(identical(other.externalId, externalId) || other.externalId == externalId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metricType,value,unit,recordedAt,notes,source,externalId);

@override
String toString() {
  return 'CreateMetricRequest(metricType: $metricType, value: $value, unit: $unit, recordedAt: $recordedAt, notes: $notes, source: $source, externalId: $externalId)';
}


}

/// @nodoc
abstract mixin class $CreateMetricRequestCopyWith<$Res>  {
  factory $CreateMetricRequestCopyWith(CreateMetricRequest value, $Res Function(CreateMetricRequest) _then) = _$CreateMetricRequestCopyWithImpl;
@useResult
$Res call({
 FitnessMetricType metricType, double value, String unit,@DateTimeConverter() DateTime recordedAt, String? notes, String? source, String? externalId
});




}
/// @nodoc
class _$CreateMetricRequestCopyWithImpl<$Res>
    implements $CreateMetricRequestCopyWith<$Res> {
  _$CreateMetricRequestCopyWithImpl(this._self, this._then);

  final CreateMetricRequest _self;
  final $Res Function(CreateMetricRequest) _then;

/// Create a copy of CreateMetricRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metricType = null,Object? value = null,Object? unit = null,Object? recordedAt = null,Object? notes = freezed,Object? source = freezed,Object? externalId = freezed,}) {
  return _then(_self.copyWith(
metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as FitnessMetricType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateMetricRequest].
extension CreateMetricRequestPatterns on CreateMetricRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateMetricRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateMetricRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateMetricRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateMetricRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateMetricRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateMetricRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FitnessMetricType metricType,  double value,  String unit, @DateTimeConverter()  DateTime recordedAt,  String? notes,  String? source,  String? externalId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateMetricRequest() when $default != null:
return $default(_that.metricType,_that.value,_that.unit,_that.recordedAt,_that.notes,_that.source,_that.externalId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FitnessMetricType metricType,  double value,  String unit, @DateTimeConverter()  DateTime recordedAt,  String? notes,  String? source,  String? externalId)  $default,) {final _that = this;
switch (_that) {
case _CreateMetricRequest():
return $default(_that.metricType,_that.value,_that.unit,_that.recordedAt,_that.notes,_that.source,_that.externalId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FitnessMetricType metricType,  double value,  String unit, @DateTimeConverter()  DateTime recordedAt,  String? notes,  String? source,  String? externalId)?  $default,) {final _that = this;
switch (_that) {
case _CreateMetricRequest() when $default != null:
return $default(_that.metricType,_that.value,_that.unit,_that.recordedAt,_that.notes,_that.source,_that.externalId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateMetricRequest implements CreateMetricRequest {
  const _CreateMetricRequest({required this.metricType, required this.value, required this.unit, @DateTimeConverter() required this.recordedAt, this.notes, this.source, this.externalId});
  factory _CreateMetricRequest.fromJson(Map<String, dynamic> json) => _$CreateMetricRequestFromJson(json);

@override final  FitnessMetricType metricType;
@override final  double value;
@override final  String unit;
@override@DateTimeConverter() final  DateTime recordedAt;
@override final  String? notes;
@override final  String? source;
@override final  String? externalId;

/// Create a copy of CreateMetricRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateMetricRequestCopyWith<_CreateMetricRequest> get copyWith => __$CreateMetricRequestCopyWithImpl<_CreateMetricRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateMetricRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateMetricRequest&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.source, source) || other.source == source)&&(identical(other.externalId, externalId) || other.externalId == externalId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metricType,value,unit,recordedAt,notes,source,externalId);

@override
String toString() {
  return 'CreateMetricRequest(metricType: $metricType, value: $value, unit: $unit, recordedAt: $recordedAt, notes: $notes, source: $source, externalId: $externalId)';
}


}

/// @nodoc
abstract mixin class _$CreateMetricRequestCopyWith<$Res> implements $CreateMetricRequestCopyWith<$Res> {
  factory _$CreateMetricRequestCopyWith(_CreateMetricRequest value, $Res Function(_CreateMetricRequest) _then) = __$CreateMetricRequestCopyWithImpl;
@override @useResult
$Res call({
 FitnessMetricType metricType, double value, String unit,@DateTimeConverter() DateTime recordedAt, String? notes, String? source, String? externalId
});




}
/// @nodoc
class __$CreateMetricRequestCopyWithImpl<$Res>
    implements _$CreateMetricRequestCopyWith<$Res> {
  __$CreateMetricRequestCopyWithImpl(this._self, this._then);

  final _CreateMetricRequest _self;
  final $Res Function(_CreateMetricRequest) _then;

/// Create a copy of CreateMetricRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metricType = null,Object? value = null,Object? unit = null,Object? recordedAt = null,Object? notes = freezed,Object? source = freezed,Object? externalId = freezed,}) {
  return _then(_CreateMetricRequest(
metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as FitnessMetricType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateMetricRequest {

 FitnessMetricType get metricType; double get value; String get unit;@DateTimeConverter() DateTime get recordedAt; String? get notes; String? get source;
/// Create a copy of UpdateMetricRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateMetricRequestCopyWith<UpdateMetricRequest> get copyWith => _$UpdateMetricRequestCopyWithImpl<UpdateMetricRequest>(this as UpdateMetricRequest, _$identity);

  /// Serializes this UpdateMetricRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateMetricRequest&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metricType,value,unit,recordedAt,notes,source);

@override
String toString() {
  return 'UpdateMetricRequest(metricType: $metricType, value: $value, unit: $unit, recordedAt: $recordedAt, notes: $notes, source: $source)';
}


}

/// @nodoc
abstract mixin class $UpdateMetricRequestCopyWith<$Res>  {
  factory $UpdateMetricRequestCopyWith(UpdateMetricRequest value, $Res Function(UpdateMetricRequest) _then) = _$UpdateMetricRequestCopyWithImpl;
@useResult
$Res call({
 FitnessMetricType metricType, double value, String unit,@DateTimeConverter() DateTime recordedAt, String? notes, String? source
});




}
/// @nodoc
class _$UpdateMetricRequestCopyWithImpl<$Res>
    implements $UpdateMetricRequestCopyWith<$Res> {
  _$UpdateMetricRequestCopyWithImpl(this._self, this._then);

  final UpdateMetricRequest _self;
  final $Res Function(UpdateMetricRequest) _then;

/// Create a copy of UpdateMetricRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metricType = null,Object? value = null,Object? unit = null,Object? recordedAt = null,Object? notes = freezed,Object? source = freezed,}) {
  return _then(_self.copyWith(
metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as FitnessMetricType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateMetricRequest].
extension UpdateMetricRequestPatterns on UpdateMetricRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateMetricRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateMetricRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateMetricRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateMetricRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateMetricRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateMetricRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FitnessMetricType metricType,  double value,  String unit, @DateTimeConverter()  DateTime recordedAt,  String? notes,  String? source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateMetricRequest() when $default != null:
return $default(_that.metricType,_that.value,_that.unit,_that.recordedAt,_that.notes,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FitnessMetricType metricType,  double value,  String unit, @DateTimeConverter()  DateTime recordedAt,  String? notes,  String? source)  $default,) {final _that = this;
switch (_that) {
case _UpdateMetricRequest():
return $default(_that.metricType,_that.value,_that.unit,_that.recordedAt,_that.notes,_that.source);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FitnessMetricType metricType,  double value,  String unit, @DateTimeConverter()  DateTime recordedAt,  String? notes,  String? source)?  $default,) {final _that = this;
switch (_that) {
case _UpdateMetricRequest() when $default != null:
return $default(_that.metricType,_that.value,_that.unit,_that.recordedAt,_that.notes,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateMetricRequest implements UpdateMetricRequest {
  const _UpdateMetricRequest({required this.metricType, required this.value, required this.unit, @DateTimeConverter() required this.recordedAt, this.notes, this.source});
  factory _UpdateMetricRequest.fromJson(Map<String, dynamic> json) => _$UpdateMetricRequestFromJson(json);

@override final  FitnessMetricType metricType;
@override final  double value;
@override final  String unit;
@override@DateTimeConverter() final  DateTime recordedAt;
@override final  String? notes;
@override final  String? source;

/// Create a copy of UpdateMetricRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateMetricRequestCopyWith<_UpdateMetricRequest> get copyWith => __$UpdateMetricRequestCopyWithImpl<_UpdateMetricRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateMetricRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateMetricRequest&&(identical(other.metricType, metricType) || other.metricType == metricType)&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,metricType,value,unit,recordedAt,notes,source);

@override
String toString() {
  return 'UpdateMetricRequest(metricType: $metricType, value: $value, unit: $unit, recordedAt: $recordedAt, notes: $notes, source: $source)';
}


}

/// @nodoc
abstract mixin class _$UpdateMetricRequestCopyWith<$Res> implements $UpdateMetricRequestCopyWith<$Res> {
  factory _$UpdateMetricRequestCopyWith(_UpdateMetricRequest value, $Res Function(_UpdateMetricRequest) _then) = __$UpdateMetricRequestCopyWithImpl;
@override @useResult
$Res call({
 FitnessMetricType metricType, double value, String unit,@DateTimeConverter() DateTime recordedAt, String? notes, String? source
});




}
/// @nodoc
class __$UpdateMetricRequestCopyWithImpl<$Res>
    implements _$UpdateMetricRequestCopyWith<$Res> {
  __$UpdateMetricRequestCopyWithImpl(this._self, this._then);

  final _UpdateMetricRequest _self;
  final $Res Function(_UpdateMetricRequest) _then;

/// Create a copy of UpdateMetricRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metricType = null,Object? value = null,Object? unit = null,Object? recordedAt = null,Object? notes = freezed,Object? source = freezed,}) {
  return _then(_UpdateMetricRequest(
metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as FitnessMetricType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateMetricsBatchRequest {

 List<CreateMetricRequest> get metrics;
/// Create a copy of CreateMetricsBatchRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateMetricsBatchRequestCopyWith<CreateMetricsBatchRequest> get copyWith => _$CreateMetricsBatchRequestCopyWithImpl<CreateMetricsBatchRequest>(this as CreateMetricsBatchRequest, _$identity);

  /// Serializes this CreateMetricsBatchRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateMetricsBatchRequest&&const DeepCollectionEquality().equals(other.metrics, metrics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(metrics));

@override
String toString() {
  return 'CreateMetricsBatchRequest(metrics: $metrics)';
}


}

/// @nodoc
abstract mixin class $CreateMetricsBatchRequestCopyWith<$Res>  {
  factory $CreateMetricsBatchRequestCopyWith(CreateMetricsBatchRequest value, $Res Function(CreateMetricsBatchRequest) _then) = _$CreateMetricsBatchRequestCopyWithImpl;
@useResult
$Res call({
 List<CreateMetricRequest> metrics
});




}
/// @nodoc
class _$CreateMetricsBatchRequestCopyWithImpl<$Res>
    implements $CreateMetricsBatchRequestCopyWith<$Res> {
  _$CreateMetricsBatchRequestCopyWithImpl(this._self, this._then);

  final CreateMetricsBatchRequest _self;
  final $Res Function(CreateMetricsBatchRequest) _then;

/// Create a copy of CreateMetricsBatchRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metrics = null,}) {
  return _then(_self.copyWith(
metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as List<CreateMetricRequest>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateMetricsBatchRequest].
extension CreateMetricsBatchRequestPatterns on CreateMetricsBatchRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateMetricsBatchRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateMetricsBatchRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateMetricsBatchRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateMetricsBatchRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateMetricsBatchRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateMetricsBatchRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CreateMetricRequest> metrics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateMetricsBatchRequest() when $default != null:
return $default(_that.metrics);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CreateMetricRequest> metrics)  $default,) {final _that = this;
switch (_that) {
case _CreateMetricsBatchRequest():
return $default(_that.metrics);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CreateMetricRequest> metrics)?  $default,) {final _that = this;
switch (_that) {
case _CreateMetricsBatchRequest() when $default != null:
return $default(_that.metrics);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateMetricsBatchRequest implements CreateMetricsBatchRequest {
  const _CreateMetricsBatchRequest({required final  List<CreateMetricRequest> metrics}): _metrics = metrics;
  factory _CreateMetricsBatchRequest.fromJson(Map<String, dynamic> json) => _$CreateMetricsBatchRequestFromJson(json);

 final  List<CreateMetricRequest> _metrics;
@override List<CreateMetricRequest> get metrics {
  if (_metrics is EqualUnmodifiableListView) return _metrics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_metrics);
}


/// Create a copy of CreateMetricsBatchRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateMetricsBatchRequestCopyWith<_CreateMetricsBatchRequest> get copyWith => __$CreateMetricsBatchRequestCopyWithImpl<_CreateMetricsBatchRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateMetricsBatchRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateMetricsBatchRequest&&const DeepCollectionEquality().equals(other._metrics, _metrics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_metrics));

@override
String toString() {
  return 'CreateMetricsBatchRequest(metrics: $metrics)';
}


}

/// @nodoc
abstract mixin class _$CreateMetricsBatchRequestCopyWith<$Res> implements $CreateMetricsBatchRequestCopyWith<$Res> {
  factory _$CreateMetricsBatchRequestCopyWith(_CreateMetricsBatchRequest value, $Res Function(_CreateMetricsBatchRequest) _then) = __$CreateMetricsBatchRequestCopyWithImpl;
@override @useResult
$Res call({
 List<CreateMetricRequest> metrics
});




}
/// @nodoc
class __$CreateMetricsBatchRequestCopyWithImpl<$Res>
    implements _$CreateMetricsBatchRequestCopyWith<$Res> {
  __$CreateMetricsBatchRequestCopyWithImpl(this._self, this._then);

  final _CreateMetricsBatchRequest _self;
  final $Res Function(_CreateMetricsBatchRequest) _then;

/// Create a copy of CreateMetricsBatchRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metrics = null,}) {
  return _then(_CreateMetricsBatchRequest(
metrics: null == metrics ? _self._metrics : metrics // ignore: cast_nullable_to_non_nullable
as List<CreateMetricRequest>,
  ));
}


}

// dart format on
