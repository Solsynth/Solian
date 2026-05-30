// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppTask {

 String get id; String get title; AppTaskStatus get status; DateTime get createdAt; DateTime get updatedAt; String get type; double get progress; String? get statusMessage; String? get errorMessage; Map<String, dynamic>? get metadata; Map<String, dynamic>? get result;
/// Create a copy of AppTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppTaskCopyWith<AppTask> get copyWith => _$AppTaskCopyWithImpl<AppTask>(this as AppTask, _$identity);

  /// Serializes this AppTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&const DeepCollectionEquality().equals(other.result, result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,status,createdAt,updatedAt,type,progress,statusMessage,errorMessage,const DeepCollectionEquality().hash(metadata),const DeepCollectionEquality().hash(result));

@override
String toString() {
  return 'AppTask(id: $id, title: $title, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, type: $type, progress: $progress, statusMessage: $statusMessage, errorMessage: $errorMessage, metadata: $metadata, result: $result)';
}


}

/// @nodoc
abstract mixin class $AppTaskCopyWith<$Res>  {
  factory $AppTaskCopyWith(AppTask value, $Res Function(AppTask) _then) = _$AppTaskCopyWithImpl;
@useResult
$Res call({
 String id, String title, AppTaskStatus status, DateTime createdAt, DateTime updatedAt, String type, double progress, String? statusMessage, String? errorMessage, Map<String, dynamic>? metadata, Map<String, dynamic>? result
});




}
/// @nodoc
class _$AppTaskCopyWithImpl<$Res>
    implements $AppTaskCopyWith<$Res> {
  _$AppTaskCopyWithImpl(this._self, this._then);

  final AppTask _self;
  final $Res Function(AppTask) _then;

/// Create a copy of AppTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? type = null,Object? progress = null,Object? statusMessage = freezed,Object? errorMessage = freezed,Object? metadata = freezed,Object? result = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppTaskStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,statusMessage: freezed == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppTask].
extension AppTaskPatterns on AppTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppTask value)  $default,){
final _that = this;
switch (_that) {
case _AppTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppTask value)?  $default,){
final _that = this;
switch (_that) {
case _AppTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  AppTaskStatus status,  DateTime createdAt,  DateTime updatedAt,  String type,  double progress,  String? statusMessage,  String? errorMessage,  Map<String, dynamic>? metadata,  Map<String, dynamic>? result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppTask() when $default != null:
return $default(_that.id,_that.title,_that.status,_that.createdAt,_that.updatedAt,_that.type,_that.progress,_that.statusMessage,_that.errorMessage,_that.metadata,_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  AppTaskStatus status,  DateTime createdAt,  DateTime updatedAt,  String type,  double progress,  String? statusMessage,  String? errorMessage,  Map<String, dynamic>? metadata,  Map<String, dynamic>? result)  $default,) {final _that = this;
switch (_that) {
case _AppTask():
return $default(_that.id,_that.title,_that.status,_that.createdAt,_that.updatedAt,_that.type,_that.progress,_that.statusMessage,_that.errorMessage,_that.metadata,_that.result);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  AppTaskStatus status,  DateTime createdAt,  DateTime updatedAt,  String type,  double progress,  String? statusMessage,  String? errorMessage,  Map<String, dynamic>? metadata,  Map<String, dynamic>? result)?  $default,) {final _that = this;
switch (_that) {
case _AppTask() when $default != null:
return $default(_that.id,_that.title,_that.status,_that.createdAt,_that.updatedAt,_that.type,_that.progress,_that.statusMessage,_that.errorMessage,_that.metadata,_that.result);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppTask extends AppTask {
  const _AppTask({required this.id, required this.title, required this.status, required this.createdAt, required this.updatedAt, required this.type, this.progress = 0.0, this.statusMessage, this.errorMessage, final  Map<String, dynamic>? metadata, final  Map<String, dynamic>? result}): _metadata = metadata,_result = result,super._();
  factory _AppTask.fromJson(Map<String, dynamic> json) => _$AppTaskFromJson(json);

@override final  String id;
@override final  String title;
@override final  AppTaskStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String type;
@override@JsonKey() final  double progress;
@override final  String? statusMessage;
@override final  String? errorMessage;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _result;
@override Map<String, dynamic>? get result {
  final value = _result;
  if (value == null) return null;
  if (_result is EqualUnmodifiableMapView) return _result;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of AppTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppTaskCopyWith<_AppTask> get copyWith => __$AppTaskCopyWithImpl<_AppTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.statusMessage, statusMessage) || other.statusMessage == statusMessage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&const DeepCollectionEquality().equals(other._result, _result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,status,createdAt,updatedAt,type,progress,statusMessage,errorMessage,const DeepCollectionEquality().hash(_metadata),const DeepCollectionEquality().hash(_result));

@override
String toString() {
  return 'AppTask(id: $id, title: $title, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, type: $type, progress: $progress, statusMessage: $statusMessage, errorMessage: $errorMessage, metadata: $metadata, result: $result)';
}


}

/// @nodoc
abstract mixin class _$AppTaskCopyWith<$Res> implements $AppTaskCopyWith<$Res> {
  factory _$AppTaskCopyWith(_AppTask value, $Res Function(_AppTask) _then) = __$AppTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, AppTaskStatus status, DateTime createdAt, DateTime updatedAt, String type, double progress, String? statusMessage, String? errorMessage, Map<String, dynamic>? metadata, Map<String, dynamic>? result
});




}
/// @nodoc
class __$AppTaskCopyWithImpl<$Res>
    implements _$AppTaskCopyWith<$Res> {
  __$AppTaskCopyWithImpl(this._self, this._then);

  final _AppTask _self;
  final $Res Function(_AppTask) _then;

/// Create a copy of AppTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? type = null,Object? progress = null,Object? statusMessage = freezed,Object? errorMessage = freezed,Object? metadata = freezed,Object? result = freezed,}) {
  return _then(_AppTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AppTaskStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,statusMessage: freezed == statusMessage ? _self.statusMessage : statusMessage // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,result: freezed == result ? _self._result : result // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
