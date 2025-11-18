// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reference {

 String get id;@JsonKey(name: 'file_id') String get fileId; SnCloudFile? get file; String get usage;@JsonKey(name: 'resource_id') String get resourceId;@JsonKey(name: 'expired_at') DateTime? get expiredAt;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'deleted_at') DateTime? get deletedAt;
/// Create a copy of Reference
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReferenceCopyWith<Reference> get copyWith => _$ReferenceCopyWithImpl<Reference>(this as Reference, _$identity);

  /// Serializes this Reference to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reference&&(identical(other.id, id) || other.id == id)&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.file, file) || other.file == file)&&(identical(other.usage, usage) || other.usage == usage)&&(identical(other.resourceId, resourceId) || other.resourceId == resourceId)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileId,file,usage,resourceId,expiredAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'Reference(id: $id, fileId: $fileId, file: $file, usage: $usage, resourceId: $resourceId, expiredAt: $expiredAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $ReferenceCopyWith<$Res>  {
  factory $ReferenceCopyWith(Reference value, $Res Function(Reference) _then) = _$ReferenceCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'file_id') String fileId, SnCloudFile? file, String usage,@JsonKey(name: 'resource_id') String resourceId,@JsonKey(name: 'expired_at') DateTime? expiredAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'deleted_at') DateTime? deletedAt
});


$SnCloudFileCopyWith<$Res>? get file;

}
/// @nodoc
class _$ReferenceCopyWithImpl<$Res>
    implements $ReferenceCopyWith<$Res> {
  _$ReferenceCopyWithImpl(this._self, this._then);

  final Reference _self;
  final $Res Function(Reference) _then;

/// Create a copy of Reference
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fileId = null,Object? file = freezed,Object? usage = null,Object? resourceId = null,Object? expiredAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as String,resourceId: null == resourceId ? _self.resourceId : resourceId // ignore: cast_nullable_to_non_nullable
as String,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Reference
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get file {
    if (_self.file == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.file!, (value) {
    return _then(_self.copyWith(file: value));
  });
}
}


/// Adds pattern-matching-related methods to [Reference].
extension ReferencePatterns on Reference {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reference value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reference() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reference value)  $default,){
final _that = this;
switch (_that) {
case _Reference():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reference value)?  $default,){
final _that = this;
switch (_that) {
case _Reference() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'file_id')  String fileId,  SnCloudFile? file,  String usage, @JsonKey(name: 'resource_id')  String resourceId, @JsonKey(name: 'expired_at')  DateTime? expiredAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reference() when $default != null:
return $default(_that.id,_that.fileId,_that.file,_that.usage,_that.resourceId,_that.expiredAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'file_id')  String fileId,  SnCloudFile? file,  String usage, @JsonKey(name: 'resource_id')  String resourceId, @JsonKey(name: 'expired_at')  DateTime? expiredAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Reference():
return $default(_that.id,_that.fileId,_that.file,_that.usage,_that.resourceId,_that.expiredAt,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'file_id')  String fileId,  SnCloudFile? file,  String usage, @JsonKey(name: 'resource_id')  String resourceId, @JsonKey(name: 'expired_at')  DateTime? expiredAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'deleted_at')  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Reference() when $default != null:
return $default(_that.id,_that.fileId,_that.file,_that.usage,_that.resourceId,_that.expiredAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reference implements Reference {
  const _Reference({required this.id, @JsonKey(name: 'file_id') required this.fileId, this.file, required this.usage, @JsonKey(name: 'resource_id') required this.resourceId, @JsonKey(name: 'expired_at') this.expiredAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'deleted_at') this.deletedAt});
  factory _Reference.fromJson(Map<String, dynamic> json) => _$ReferenceFromJson(json);

@override final  String id;
@override@JsonKey(name: 'file_id') final  String fileId;
@override final  SnCloudFile? file;
@override final  String usage;
@override@JsonKey(name: 'resource_id') final  String resourceId;
@override@JsonKey(name: 'expired_at') final  DateTime? expiredAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'deleted_at') final  DateTime? deletedAt;

/// Create a copy of Reference
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReferenceCopyWith<_Reference> get copyWith => __$ReferenceCopyWithImpl<_Reference>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReferenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reference&&(identical(other.id, id) || other.id == id)&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.file, file) || other.file == file)&&(identical(other.usage, usage) || other.usage == usage)&&(identical(other.resourceId, resourceId) || other.resourceId == resourceId)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fileId,file,usage,resourceId,expiredAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'Reference(id: $id, fileId: $fileId, file: $file, usage: $usage, resourceId: $resourceId, expiredAt: $expiredAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$ReferenceCopyWith<$Res> implements $ReferenceCopyWith<$Res> {
  factory _$ReferenceCopyWith(_Reference value, $Res Function(_Reference) _then) = __$ReferenceCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'file_id') String fileId, SnCloudFile? file, String usage,@JsonKey(name: 'resource_id') String resourceId,@JsonKey(name: 'expired_at') DateTime? expiredAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'deleted_at') DateTime? deletedAt
});


@override $SnCloudFileCopyWith<$Res>? get file;

}
/// @nodoc
class __$ReferenceCopyWithImpl<$Res>
    implements _$ReferenceCopyWith<$Res> {
  __$ReferenceCopyWithImpl(this._self, this._then);

  final _Reference _self;
  final $Res Function(_Reference) _then;

/// Create a copy of Reference
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fileId = null,Object? file = freezed,Object? usage = null,Object? resourceId = null,Object? expiredAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_Reference(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as String,resourceId: null == resourceId ? _self.resourceId : resourceId // ignore: cast_nullable_to_non_nullable
as String,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Reference
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get file {
    if (_self.file == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.file!, (value) {
    return _then(_self.copyWith(file: value));
  });
}
}

// dart format on
