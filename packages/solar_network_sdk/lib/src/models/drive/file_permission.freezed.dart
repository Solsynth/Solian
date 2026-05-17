// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_permission.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnFilePermissionStatus {

 bool get readable; bool get writable; bool get manageable; String get visibility;@JsonKey(name: 'inherited_from') String? get inheritedFrom;
/// Create a copy of SnFilePermissionStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFilePermissionStatusCopyWith<SnFilePermissionStatus> get copyWith => _$SnFilePermissionStatusCopyWithImpl<SnFilePermissionStatus>(this as SnFilePermissionStatus, _$identity);

  /// Serializes this SnFilePermissionStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFilePermissionStatus&&(identical(other.readable, readable) || other.readable == readable)&&(identical(other.writable, writable) || other.writable == writable)&&(identical(other.manageable, manageable) || other.manageable == manageable)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.inheritedFrom, inheritedFrom) || other.inheritedFrom == inheritedFrom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,readable,writable,manageable,visibility,inheritedFrom);

@override
String toString() {
  return 'SnFilePermissionStatus(readable: $readable, writable: $writable, manageable: $manageable, visibility: $visibility, inheritedFrom: $inheritedFrom)';
}


}

/// @nodoc
abstract mixin class $SnFilePermissionStatusCopyWith<$Res>  {
  factory $SnFilePermissionStatusCopyWith(SnFilePermissionStatus value, $Res Function(SnFilePermissionStatus) _then) = _$SnFilePermissionStatusCopyWithImpl;
@useResult
$Res call({
 bool readable, bool writable, bool manageable, String visibility,@JsonKey(name: 'inherited_from') String? inheritedFrom
});




}
/// @nodoc
class _$SnFilePermissionStatusCopyWithImpl<$Res>
    implements $SnFilePermissionStatusCopyWith<$Res> {
  _$SnFilePermissionStatusCopyWithImpl(this._self, this._then);

  final SnFilePermissionStatus _self;
  final $Res Function(SnFilePermissionStatus) _then;

/// Create a copy of SnFilePermissionStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? readable = null,Object? writable = null,Object? manageable = null,Object? visibility = null,Object? inheritedFrom = freezed,}) {
  return _then(_self.copyWith(
readable: null == readable ? _self.readable : readable // ignore: cast_nullable_to_non_nullable
as bool,writable: null == writable ? _self.writable : writable // ignore: cast_nullable_to_non_nullable
as bool,manageable: null == manageable ? _self.manageable : manageable // ignore: cast_nullable_to_non_nullable
as bool,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,inheritedFrom: freezed == inheritedFrom ? _self.inheritedFrom : inheritedFrom // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnFilePermissionStatus].
extension SnFilePermissionStatusPatterns on SnFilePermissionStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFilePermissionStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFilePermissionStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFilePermissionStatus value)  $default,){
final _that = this;
switch (_that) {
case _SnFilePermissionStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFilePermissionStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SnFilePermissionStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool readable,  bool writable,  bool manageable,  String visibility, @JsonKey(name: 'inherited_from')  String? inheritedFrom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFilePermissionStatus() when $default != null:
return $default(_that.readable,_that.writable,_that.manageable,_that.visibility,_that.inheritedFrom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool readable,  bool writable,  bool manageable,  String visibility, @JsonKey(name: 'inherited_from')  String? inheritedFrom)  $default,) {final _that = this;
switch (_that) {
case _SnFilePermissionStatus():
return $default(_that.readable,_that.writable,_that.manageable,_that.visibility,_that.inheritedFrom);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool readable,  bool writable,  bool manageable,  String visibility, @JsonKey(name: 'inherited_from')  String? inheritedFrom)?  $default,) {final _that = this;
switch (_that) {
case _SnFilePermissionStatus() when $default != null:
return $default(_that.readable,_that.writable,_that.manageable,_that.visibility,_that.inheritedFrom);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFilePermissionStatus implements SnFilePermissionStatus {
  const _SnFilePermissionStatus({required this.readable, required this.writable, required this.manageable, required this.visibility, @JsonKey(name: 'inherited_from') this.inheritedFrom});
  factory _SnFilePermissionStatus.fromJson(Map<String, dynamic> json) => _$SnFilePermissionStatusFromJson(json);

@override final  bool readable;
@override final  bool writable;
@override final  bool manageable;
@override final  String visibility;
@override@JsonKey(name: 'inherited_from') final  String? inheritedFrom;

/// Create a copy of SnFilePermissionStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFilePermissionStatusCopyWith<_SnFilePermissionStatus> get copyWith => __$SnFilePermissionStatusCopyWithImpl<_SnFilePermissionStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFilePermissionStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFilePermissionStatus&&(identical(other.readable, readable) || other.readable == readable)&&(identical(other.writable, writable) || other.writable == writable)&&(identical(other.manageable, manageable) || other.manageable == manageable)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.inheritedFrom, inheritedFrom) || other.inheritedFrom == inheritedFrom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,readable,writable,manageable,visibility,inheritedFrom);

@override
String toString() {
  return 'SnFilePermissionStatus(readable: $readable, writable: $writable, manageable: $manageable, visibility: $visibility, inheritedFrom: $inheritedFrom)';
}


}

/// @nodoc
abstract mixin class _$SnFilePermissionStatusCopyWith<$Res> implements $SnFilePermissionStatusCopyWith<$Res> {
  factory _$SnFilePermissionStatusCopyWith(_SnFilePermissionStatus value, $Res Function(_SnFilePermissionStatus) _then) = __$SnFilePermissionStatusCopyWithImpl;
@override @useResult
$Res call({
 bool readable, bool writable, bool manageable, String visibility,@JsonKey(name: 'inherited_from') String? inheritedFrom
});




}
/// @nodoc
class __$SnFilePermissionStatusCopyWithImpl<$Res>
    implements _$SnFilePermissionStatusCopyWith<$Res> {
  __$SnFilePermissionStatusCopyWithImpl(this._self, this._then);

  final _SnFilePermissionStatus _self;
  final $Res Function(_SnFilePermissionStatus) _then;

/// Create a copy of SnFilePermissionStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? readable = null,Object? writable = null,Object? manageable = null,Object? visibility = null,Object? inheritedFrom = freezed,}) {
  return _then(_SnFilePermissionStatus(
readable: null == readable ? _self.readable : readable // ignore: cast_nullable_to_non_nullable
as bool,writable: null == writable ? _self.writable : writable // ignore: cast_nullable_to_non_nullable
as bool,manageable: null == manageable ? _self.manageable : manageable // ignore: cast_nullable_to_non_nullable
as bool,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,inheritedFrom: freezed == inheritedFrom ? _self.inheritedFrom : inheritedFrom // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SnFilePermission {

 String? get id;@JsonKey(name: 'file_id') String get fileId;@JsonKey(name: 'subject_type') String get subjectType;@JsonKey(name: 'subject_id') String get subjectId; String get permission; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnFilePermission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFilePermissionCopyWith<SnFilePermission> get copyWith => _$SnFilePermissionCopyWithImpl<SnFilePermission>(this as SnFilePermission, _$identity);

  /// Serializes this SnFilePermission to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFilePermission&&(identical(other.id, id) || other.id == id)&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.subjectType, subjectType) || other.subjectType == subjectType)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.permission, permission) || other.permission == permission)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileId,subjectType,subjectId,permission,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnFilePermission(id: $id, fileId: $fileId, subjectType: $subjectType, subjectId: $subjectId, permission: $permission, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnFilePermissionCopyWith<$Res>  {
  factory $SnFilePermissionCopyWith(SnFilePermission value, $Res Function(SnFilePermission) _then) = _$SnFilePermissionCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'file_id') String fileId,@JsonKey(name: 'subject_type') String subjectType,@JsonKey(name: 'subject_id') String subjectId, String permission, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnFilePermissionCopyWithImpl<$Res>
    implements $SnFilePermissionCopyWith<$Res> {
  _$SnFilePermissionCopyWithImpl(this._self, this._then);

  final SnFilePermission _self;
  final $Res Function(SnFilePermission) _then;

/// Create a copy of SnFilePermission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? fileId = null,Object? subjectType = null,Object? subjectId = null,Object? permission = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,subjectType: null == subjectType ? _self.subjectType : subjectType // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,permission: null == permission ? _self.permission : permission // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnFilePermission].
extension SnFilePermissionPatterns on SnFilePermission {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFilePermission value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFilePermission() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFilePermission value)  $default,){
final _that = this;
switch (_that) {
case _SnFilePermission():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFilePermission value)?  $default,){
final _that = this;
switch (_that) {
case _SnFilePermission() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'file_id')  String fileId, @JsonKey(name: 'subject_type')  String subjectType, @JsonKey(name: 'subject_id')  String subjectId,  String permission,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFilePermission() when $default != null:
return $default(_that.id,_that.fileId,_that.subjectType,_that.subjectId,_that.permission,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'file_id')  String fileId, @JsonKey(name: 'subject_type')  String subjectType, @JsonKey(name: 'subject_id')  String subjectId,  String permission,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnFilePermission():
return $default(_that.id,_that.fileId,_that.subjectType,_that.subjectId,_that.permission,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'file_id')  String fileId, @JsonKey(name: 'subject_type')  String subjectType, @JsonKey(name: 'subject_id')  String subjectId,  String permission,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnFilePermission() when $default != null:
return $default(_that.id,_that.fileId,_that.subjectType,_that.subjectId,_that.permission,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFilePermission implements SnFilePermission {
  const _SnFilePermission({this.id, @JsonKey(name: 'file_id') required this.fileId, @JsonKey(name: 'subject_type') required this.subjectType, @JsonKey(name: 'subject_id') required this.subjectId, required this.permission, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnFilePermission.fromJson(Map<String, dynamic> json) => _$SnFilePermissionFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'file_id') final  String fileId;
@override@JsonKey(name: 'subject_type') final  String subjectType;
@override@JsonKey(name: 'subject_id') final  String subjectId;
@override final  String permission;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnFilePermission
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFilePermissionCopyWith<_SnFilePermission> get copyWith => __$SnFilePermissionCopyWithImpl<_SnFilePermission>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFilePermissionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFilePermission&&(identical(other.id, id) || other.id == id)&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.subjectType, subjectType) || other.subjectType == subjectType)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.permission, permission) || other.permission == permission)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileId,subjectType,subjectId,permission,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnFilePermission(id: $id, fileId: $fileId, subjectType: $subjectType, subjectId: $subjectId, permission: $permission, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnFilePermissionCopyWith<$Res> implements $SnFilePermissionCopyWith<$Res> {
  factory _$SnFilePermissionCopyWith(_SnFilePermission value, $Res Function(_SnFilePermission) _then) = __$SnFilePermissionCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'file_id') String fileId,@JsonKey(name: 'subject_type') String subjectType,@JsonKey(name: 'subject_id') String subjectId, String permission, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnFilePermissionCopyWithImpl<$Res>
    implements _$SnFilePermissionCopyWith<$Res> {
  __$SnFilePermissionCopyWithImpl(this._self, this._then);

  final _SnFilePermission _self;
  final $Res Function(_SnFilePermission) _then;

/// Create a copy of SnFilePermission
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? fileId = null,Object? subjectType = null,Object? subjectId = null,Object? permission = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_SnFilePermission(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,subjectType: null == subjectType ? _self.subjectType : subjectType // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,permission: null == permission ? _self.permission : permission // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
