// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UniversalFile {

 dynamic get data; UniversalFileType get type; bool get isLink; String? get displayName;
/// Create a copy of UniversalFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UniversalFileCopyWith<UniversalFile> get copyWith => _$UniversalFileCopyWithImpl<UniversalFile>(this as UniversalFile, _$identity);

  /// Serializes this UniversalFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UniversalFile&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.type, type) || other.type == type)&&(identical(other.isLink, isLink) || other.isLink == isLink)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),type,isLink,displayName);

@override
String toString() {
  return 'UniversalFile(data: $data, type: $type, isLink: $isLink, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $UniversalFileCopyWith<$Res>  {
  factory $UniversalFileCopyWith(UniversalFile value, $Res Function(UniversalFile) _then) = _$UniversalFileCopyWithImpl;
@useResult
$Res call({
 dynamic data, UniversalFileType type, bool isLink, String? displayName
});




}
/// @nodoc
class _$UniversalFileCopyWithImpl<$Res>
    implements $UniversalFileCopyWith<$Res> {
  _$UniversalFileCopyWithImpl(this._self, this._then);

  final UniversalFile _self;
  final $Res Function(UniversalFile) _then;

/// Create a copy of UniversalFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,Object? type = null,Object? isLink = null,Object? displayName = freezed,}) {
  return _then(_self.copyWith(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as UniversalFileType,isLink: null == isLink ? _self.isLink : isLink // ignore: cast_nullable_to_non_nullable
as bool,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UniversalFile].
extension UniversalFilePatterns on UniversalFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UniversalFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UniversalFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UniversalFile value)  $default,){
final _that = this;
switch (_that) {
case _UniversalFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UniversalFile value)?  $default,){
final _that = this;
switch (_that) {
case _UniversalFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( dynamic data,  UniversalFileType type,  bool isLink,  String? displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UniversalFile() when $default != null:
return $default(_that.data,_that.type,_that.isLink,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( dynamic data,  UniversalFileType type,  bool isLink,  String? displayName)  $default,) {final _that = this;
switch (_that) {
case _UniversalFile():
return $default(_that.data,_that.type,_that.isLink,_that.displayName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( dynamic data,  UniversalFileType type,  bool isLink,  String? displayName)?  $default,) {final _that = this;
switch (_that) {
case _UniversalFile() when $default != null:
return $default(_that.data,_that.type,_that.isLink,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UniversalFile extends UniversalFile {
  const _UniversalFile({required this.data, required this.type, this.isLink = false, this.displayName}): super._();
  factory _UniversalFile.fromJson(Map<String, dynamic> json) => _$UniversalFileFromJson(json);

@override final  dynamic data;
@override final  UniversalFileType type;
@override@JsonKey() final  bool isLink;
@override final  String? displayName;

/// Create a copy of UniversalFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UniversalFileCopyWith<_UniversalFile> get copyWith => __$UniversalFileCopyWithImpl<_UniversalFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UniversalFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UniversalFile&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.type, type) || other.type == type)&&(identical(other.isLink, isLink) || other.isLink == isLink)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),type,isLink,displayName);

@override
String toString() {
  return 'UniversalFile(data: $data, type: $type, isLink: $isLink, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$UniversalFileCopyWith<$Res> implements $UniversalFileCopyWith<$Res> {
  factory _$UniversalFileCopyWith(_UniversalFile value, $Res Function(_UniversalFile) _then) = __$UniversalFileCopyWithImpl;
@override @useResult
$Res call({
 dynamic data, UniversalFileType type, bool isLink, String? displayName
});




}
/// @nodoc
class __$UniversalFileCopyWithImpl<$Res>
    implements _$UniversalFileCopyWith<$Res> {
  __$UniversalFileCopyWithImpl(this._self, this._then);

  final _UniversalFile _self;
  final $Res Function(_UniversalFile) _then;

/// Create a copy of UniversalFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,Object? type = null,Object? isLink = null,Object? displayName = freezed,}) {
  return _then(_UniversalFile(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as UniversalFileType,isLink: null == isLink ? _self.isLink : isLink // ignore: cast_nullable_to_non_nullable
as bool,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SnFileReplica {

 String get id; String get objectId; String get poolId; SnFilePool? get pool; String get storageId; int get status; bool get isPrimary; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnFileReplica
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFileReplicaCopyWith<SnFileReplica> get copyWith => _$SnFileReplicaCopyWithImpl<SnFileReplica>(this as SnFileReplica, _$identity);

  /// Serializes this SnFileReplica to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFileReplica&&(identical(other.id, id) || other.id == id)&&(identical(other.objectId, objectId) || other.objectId == objectId)&&(identical(other.poolId, poolId) || other.poolId == poolId)&&(identical(other.pool, pool) || other.pool == pool)&&(identical(other.storageId, storageId) || other.storageId == storageId)&&(identical(other.status, status) || other.status == status)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,objectId,poolId,pool,storageId,status,isPrimary,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnFileReplica(id: $id, objectId: $objectId, poolId: $poolId, pool: $pool, storageId: $storageId, status: $status, isPrimary: $isPrimary, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnFileReplicaCopyWith<$Res>  {
  factory $SnFileReplicaCopyWith(SnFileReplica value, $Res Function(SnFileReplica) _then) = _$SnFileReplicaCopyWithImpl;
@useResult
$Res call({
 String id, String objectId, String poolId, SnFilePool? pool, String storageId, int status, bool isPrimary, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnFilePoolCopyWith<$Res>? get pool;

}
/// @nodoc
class _$SnFileReplicaCopyWithImpl<$Res>
    implements $SnFileReplicaCopyWith<$Res> {
  _$SnFileReplicaCopyWithImpl(this._self, this._then);

  final SnFileReplica _self;
  final $Res Function(SnFileReplica) _then;

/// Create a copy of SnFileReplica
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? objectId = null,Object? poolId = null,Object? pool = freezed,Object? storageId = null,Object? status = null,Object? isPrimary = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,objectId: null == objectId ? _self.objectId : objectId // ignore: cast_nullable_to_non_nullable
as String,poolId: null == poolId ? _self.poolId : poolId // ignore: cast_nullable_to_non_nullable
as String,pool: freezed == pool ? _self.pool : pool // ignore: cast_nullable_to_non_nullable
as SnFilePool?,storageId: null == storageId ? _self.storageId : storageId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnFileReplica
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnFilePoolCopyWith<$Res>? get pool {
    if (_self.pool == null) {
    return null;
  }

  return $SnFilePoolCopyWith<$Res>(_self.pool!, (value) {
    return _then(_self.copyWith(pool: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnFileReplica].
extension SnFileReplicaPatterns on SnFileReplica {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFileReplica value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFileReplica() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFileReplica value)  $default,){
final _that = this;
switch (_that) {
case _SnFileReplica():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFileReplica value)?  $default,){
final _that = this;
switch (_that) {
case _SnFileReplica() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String objectId,  String poolId,  SnFilePool? pool,  String storageId,  int status,  bool isPrimary,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFileReplica() when $default != null:
return $default(_that.id,_that.objectId,_that.poolId,_that.pool,_that.storageId,_that.status,_that.isPrimary,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String objectId,  String poolId,  SnFilePool? pool,  String storageId,  int status,  bool isPrimary,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnFileReplica():
return $default(_that.id,_that.objectId,_that.poolId,_that.pool,_that.storageId,_that.status,_that.isPrimary,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String objectId,  String poolId,  SnFilePool? pool,  String storageId,  int status,  bool isPrimary,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnFileReplica() when $default != null:
return $default(_that.id,_that.objectId,_that.poolId,_that.pool,_that.storageId,_that.status,_that.isPrimary,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFileReplica implements SnFileReplica {
  const _SnFileReplica({required this.id, required this.objectId, required this.poolId, required this.pool, required this.storageId, required this.status, required this.isPrimary, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnFileReplica.fromJson(Map<String, dynamic> json) => _$SnFileReplicaFromJson(json);

@override final  String id;
@override final  String objectId;
@override final  String poolId;
@override final  SnFilePool? pool;
@override final  String storageId;
@override final  int status;
@override final  bool isPrimary;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnFileReplica
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFileReplicaCopyWith<_SnFileReplica> get copyWith => __$SnFileReplicaCopyWithImpl<_SnFileReplica>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFileReplicaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFileReplica&&(identical(other.id, id) || other.id == id)&&(identical(other.objectId, objectId) || other.objectId == objectId)&&(identical(other.poolId, poolId) || other.poolId == poolId)&&(identical(other.pool, pool) || other.pool == pool)&&(identical(other.storageId, storageId) || other.storageId == storageId)&&(identical(other.status, status) || other.status == status)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,objectId,poolId,pool,storageId,status,isPrimary,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnFileReplica(id: $id, objectId: $objectId, poolId: $poolId, pool: $pool, storageId: $storageId, status: $status, isPrimary: $isPrimary, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnFileReplicaCopyWith<$Res> implements $SnFileReplicaCopyWith<$Res> {
  factory _$SnFileReplicaCopyWith(_SnFileReplica value, $Res Function(_SnFileReplica) _then) = __$SnFileReplicaCopyWithImpl;
@override @useResult
$Res call({
 String id, String objectId, String poolId, SnFilePool? pool, String storageId, int status, bool isPrimary, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnFilePoolCopyWith<$Res>? get pool;

}
/// @nodoc
class __$SnFileReplicaCopyWithImpl<$Res>
    implements _$SnFileReplicaCopyWith<$Res> {
  __$SnFileReplicaCopyWithImpl(this._self, this._then);

  final _SnFileReplica _self;
  final $Res Function(_SnFileReplica) _then;

/// Create a copy of SnFileReplica
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? objectId = null,Object? poolId = null,Object? pool = freezed,Object? storageId = null,Object? status = null,Object? isPrimary = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnFileReplica(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,objectId: null == objectId ? _self.objectId : objectId // ignore: cast_nullable_to_non_nullable
as String,poolId: null == poolId ? _self.poolId : poolId // ignore: cast_nullable_to_non_nullable
as String,pool: freezed == pool ? _self.pool : pool // ignore: cast_nullable_to_non_nullable
as SnFilePool?,storageId: null == storageId ? _self.storageId : storageId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnFileReplica
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnFilePoolCopyWith<$Res>? get pool {
    if (_self.pool == null) {
    return null;
  }

  return $SnFilePoolCopyWith<$Res>(_self.pool!, (value) {
    return _then(_self.copyWith(pool: value));
  });
}
}


/// @nodoc
mixin _$SnCloudFileObject {

 String get id; int get size; Map<String, dynamic>? get meta; String? get mimeType; String? get hash; bool get hasCompression; bool get hasThumbnail; List<SnFileReplica> get fileReplicas; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnCloudFileObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnCloudFileObjectCopyWith<SnCloudFileObject> get copyWith => _$SnCloudFileObjectCopyWithImpl<SnCloudFileObject>(this as SnCloudFileObject, _$identity);

  /// Serializes this SnCloudFileObject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnCloudFileObject&&(identical(other.id, id) || other.id == id)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.hasCompression, hasCompression) || other.hasCompression == hasCompression)&&(identical(other.hasThumbnail, hasThumbnail) || other.hasThumbnail == hasThumbnail)&&const DeepCollectionEquality().equals(other.fileReplicas, fileReplicas)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,size,const DeepCollectionEquality().hash(meta),mimeType,hash,hasCompression,hasThumbnail,const DeepCollectionEquality().hash(fileReplicas),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnCloudFileObject(id: $id, size: $size, meta: $meta, mimeType: $mimeType, hash: $hash, hasCompression: $hasCompression, hasThumbnail: $hasThumbnail, fileReplicas: $fileReplicas, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnCloudFileObjectCopyWith<$Res>  {
  factory $SnCloudFileObjectCopyWith(SnCloudFileObject value, $Res Function(SnCloudFileObject) _then) = _$SnCloudFileObjectCopyWithImpl;
@useResult
$Res call({
 String id, int size, Map<String, dynamic>? meta, String? mimeType, String? hash, bool hasCompression, bool hasThumbnail, List<SnFileReplica> fileReplicas, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnCloudFileObjectCopyWithImpl<$Res>
    implements $SnCloudFileObjectCopyWith<$Res> {
  _$SnCloudFileObjectCopyWithImpl(this._self, this._then);

  final SnCloudFileObject _self;
  final $Res Function(SnCloudFileObject) _then;

/// Create a copy of SnCloudFileObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? size = null,Object? meta = freezed,Object? mimeType = freezed,Object? hash = freezed,Object? hasCompression = null,Object? hasThumbnail = null,Object? fileReplicas = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,hasCompression: null == hasCompression ? _self.hasCompression : hasCompression // ignore: cast_nullable_to_non_nullable
as bool,hasThumbnail: null == hasThumbnail ? _self.hasThumbnail : hasThumbnail // ignore: cast_nullable_to_non_nullable
as bool,fileReplicas: null == fileReplicas ? _self.fileReplicas : fileReplicas // ignore: cast_nullable_to_non_nullable
as List<SnFileReplica>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnCloudFileObject].
extension SnCloudFileObjectPatterns on SnCloudFileObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnCloudFileObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnCloudFileObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnCloudFileObject value)  $default,){
final _that = this;
switch (_that) {
case _SnCloudFileObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnCloudFileObject value)?  $default,){
final _that = this;
switch (_that) {
case _SnCloudFileObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int size,  Map<String, dynamic>? meta,  String? mimeType,  String? hash,  bool hasCompression,  bool hasThumbnail,  List<SnFileReplica> fileReplicas,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnCloudFileObject() when $default != null:
return $default(_that.id,_that.size,_that.meta,_that.mimeType,_that.hash,_that.hasCompression,_that.hasThumbnail,_that.fileReplicas,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int size,  Map<String, dynamic>? meta,  String? mimeType,  String? hash,  bool hasCompression,  bool hasThumbnail,  List<SnFileReplica> fileReplicas,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnCloudFileObject():
return $default(_that.id,_that.size,_that.meta,_that.mimeType,_that.hash,_that.hasCompression,_that.hasThumbnail,_that.fileReplicas,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int size,  Map<String, dynamic>? meta,  String? mimeType,  String? hash,  bool hasCompression,  bool hasThumbnail,  List<SnFileReplica> fileReplicas,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnCloudFileObject() when $default != null:
return $default(_that.id,_that.size,_that.meta,_that.mimeType,_that.hash,_that.hasCompression,_that.hasThumbnail,_that.fileReplicas,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnCloudFileObject implements SnCloudFileObject {
  const _SnCloudFileObject({required this.id, required this.size, required final  Map<String, dynamic>? meta, required this.mimeType, required this.hash, required this.hasCompression, required this.hasThumbnail, required final  List<SnFileReplica> fileReplicas, required this.createdAt, required this.updatedAt, required this.deletedAt}): _meta = meta,_fileReplicas = fileReplicas;
  factory _SnCloudFileObject.fromJson(Map<String, dynamic> json) => _$SnCloudFileObjectFromJson(json);

@override final  String id;
@override final  int size;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? mimeType;
@override final  String? hash;
@override final  bool hasCompression;
@override final  bool hasThumbnail;
 final  List<SnFileReplica> _fileReplicas;
@override List<SnFileReplica> get fileReplicas {
  if (_fileReplicas is EqualUnmodifiableListView) return _fileReplicas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fileReplicas);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnCloudFileObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnCloudFileObjectCopyWith<_SnCloudFileObject> get copyWith => __$SnCloudFileObjectCopyWithImpl<_SnCloudFileObject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnCloudFileObjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnCloudFileObject&&(identical(other.id, id) || other.id == id)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.hasCompression, hasCompression) || other.hasCompression == hasCompression)&&(identical(other.hasThumbnail, hasThumbnail) || other.hasThumbnail == hasThumbnail)&&const DeepCollectionEquality().equals(other._fileReplicas, _fileReplicas)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,size,const DeepCollectionEquality().hash(_meta),mimeType,hash,hasCompression,hasThumbnail,const DeepCollectionEquality().hash(_fileReplicas),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnCloudFileObject(id: $id, size: $size, meta: $meta, mimeType: $mimeType, hash: $hash, hasCompression: $hasCompression, hasThumbnail: $hasThumbnail, fileReplicas: $fileReplicas, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnCloudFileObjectCopyWith<$Res> implements $SnCloudFileObjectCopyWith<$Res> {
  factory _$SnCloudFileObjectCopyWith(_SnCloudFileObject value, $Res Function(_SnCloudFileObject) _then) = __$SnCloudFileObjectCopyWithImpl;
@override @useResult
$Res call({
 String id, int size, Map<String, dynamic>? meta, String? mimeType, String? hash, bool hasCompression, bool hasThumbnail, List<SnFileReplica> fileReplicas, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnCloudFileObjectCopyWithImpl<$Res>
    implements _$SnCloudFileObjectCopyWith<$Res> {
  __$SnCloudFileObjectCopyWithImpl(this._self, this._then);

  final _SnCloudFileObject _self;
  final $Res Function(_SnCloudFileObject) _then;

/// Create a copy of SnCloudFileObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? size = null,Object? meta = freezed,Object? mimeType = freezed,Object? hash = freezed,Object? hasCompression = null,Object? hasThumbnail = null,Object? fileReplicas = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnCloudFileObject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,hasCompression: null == hasCompression ? _self.hasCompression : hasCompression // ignore: cast_nullable_to_non_nullable
as bool,hasThumbnail: null == hasThumbnail ? _self.hasThumbnail : hasThumbnail // ignore: cast_nullable_to_non_nullable
as bool,fileReplicas: null == fileReplicas ? _self._fileReplicas : fileReplicas // ignore: cast_nullable_to_non_nullable
as List<SnFileReplica>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnCloudFile {

 String get id; String get name; String? get description; Map<String, dynamic>? get fileMeta; Map<String, dynamic>? get userMeta; List<int> get sensitiveMarks; String? get mimeType; String? get hash; int get size; DateTime? get uploadedAt; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; String? get url;
/// Create a copy of SnCloudFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<SnCloudFile> get copyWith => _$SnCloudFileCopyWithImpl<SnCloudFile>(this as SnCloudFile, _$identity);

  /// Serializes this SnCloudFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnCloudFile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.fileMeta, fileMeta)&&const DeepCollectionEquality().equals(other.userMeta, userMeta)&&const DeepCollectionEquality().equals(other.sensitiveMarks, sensitiveMarks)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.size, size) || other.size == size)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(fileMeta),const DeepCollectionEquality().hash(userMeta),const DeepCollectionEquality().hash(sensitiveMarks),mimeType,hash,size,uploadedAt,createdAt,updatedAt,deletedAt,url);

@override
String toString() {
  return 'SnCloudFile(id: $id, name: $name, description: $description, fileMeta: $fileMeta, userMeta: $userMeta, sensitiveMarks: $sensitiveMarks, mimeType: $mimeType, hash: $hash, size: $size, uploadedAt: $uploadedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, url: $url)';
}


}

/// @nodoc
abstract mixin class $SnCloudFileCopyWith<$Res>  {
  factory $SnCloudFileCopyWith(SnCloudFile value, $Res Function(SnCloudFile) _then) = _$SnCloudFileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, Map<String, dynamic>? fileMeta, Map<String, dynamic>? userMeta, List<int> sensitiveMarks, String? mimeType, String? hash, int size, DateTime? uploadedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String? url
});




}
/// @nodoc
class _$SnCloudFileCopyWithImpl<$Res>
    implements $SnCloudFileCopyWith<$Res> {
  _$SnCloudFileCopyWithImpl(this._self, this._then);

  final SnCloudFile _self;
  final $Res Function(SnCloudFile) _then;

/// Create a copy of SnCloudFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? fileMeta = freezed,Object? userMeta = freezed,Object? sensitiveMarks = null,Object? mimeType = freezed,Object? hash = freezed,Object? size = null,Object? uploadedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? url = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileMeta: freezed == fileMeta ? _self.fileMeta : fileMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,userMeta: freezed == userMeta ? _self.userMeta : userMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,sensitiveMarks: null == sensitiveMarks ? _self.sensitiveMarks : sensitiveMarks // ignore: cast_nullable_to_non_nullable
as List<int>,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnCloudFile].
extension SnCloudFilePatterns on SnCloudFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnCloudFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnCloudFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnCloudFile value)  $default,){
final _that = this;
switch (_that) {
case _SnCloudFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnCloudFile value)?  $default,){
final _that = this;
switch (_that) {
case _SnCloudFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  Map<String, dynamic>? fileMeta,  Map<String, dynamic>? userMeta,  List<int> sensitiveMarks,  String? mimeType,  String? hash,  int size,  DateTime? uploadedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnCloudFile() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.fileMeta,_that.userMeta,_that.sensitiveMarks,_that.mimeType,_that.hash,_that.size,_that.uploadedAt,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  Map<String, dynamic>? fileMeta,  Map<String, dynamic>? userMeta,  List<int> sensitiveMarks,  String? mimeType,  String? hash,  int size,  DateTime? uploadedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String? url)  $default,) {final _that = this;
switch (_that) {
case _SnCloudFile():
return $default(_that.id,_that.name,_that.description,_that.fileMeta,_that.userMeta,_that.sensitiveMarks,_that.mimeType,_that.hash,_that.size,_that.uploadedAt,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.url);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  Map<String, dynamic>? fileMeta,  Map<String, dynamic>? userMeta,  List<int> sensitiveMarks,  String? mimeType,  String? hash,  int size,  DateTime? uploadedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _SnCloudFile() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.fileMeta,_that.userMeta,_that.sensitiveMarks,_that.mimeType,_that.hash,_that.size,_that.uploadedAt,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnCloudFile implements SnCloudFile {
  const _SnCloudFile({required this.id, required this.name, required this.description, required final  Map<String, dynamic>? fileMeta, required final  Map<String, dynamic>? userMeta, final  List<int> sensitiveMarks = const [], required this.mimeType, required this.hash, required this.size, required this.uploadedAt, required this.createdAt, required this.updatedAt, required this.deletedAt, this.url}): _fileMeta = fileMeta,_userMeta = userMeta,_sensitiveMarks = sensitiveMarks;
  factory _SnCloudFile.fromJson(Map<String, dynamic> json) => _$SnCloudFileFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
 final  Map<String, dynamic>? _fileMeta;
@override Map<String, dynamic>? get fileMeta {
  final value = _fileMeta;
  if (value == null) return null;
  if (_fileMeta is EqualUnmodifiableMapView) return _fileMeta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _userMeta;
@override Map<String, dynamic>? get userMeta {
  final value = _userMeta;
  if (value == null) return null;
  if (_userMeta is EqualUnmodifiableMapView) return _userMeta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<int> _sensitiveMarks;
@override@JsonKey() List<int> get sensitiveMarks {
  if (_sensitiveMarks is EqualUnmodifiableListView) return _sensitiveMarks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sensitiveMarks);
}

@override final  String? mimeType;
@override final  String? hash;
@override final  int size;
@override final  DateTime? uploadedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  String? url;

/// Create a copy of SnCloudFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnCloudFileCopyWith<_SnCloudFile> get copyWith => __$SnCloudFileCopyWithImpl<_SnCloudFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnCloudFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnCloudFile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._fileMeta, _fileMeta)&&const DeepCollectionEquality().equals(other._userMeta, _userMeta)&&const DeepCollectionEquality().equals(other._sensitiveMarks, _sensitiveMarks)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.size, size) || other.size == size)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(_fileMeta),const DeepCollectionEquality().hash(_userMeta),const DeepCollectionEquality().hash(_sensitiveMarks),mimeType,hash,size,uploadedAt,createdAt,updatedAt,deletedAt,url);

@override
String toString() {
  return 'SnCloudFile(id: $id, name: $name, description: $description, fileMeta: $fileMeta, userMeta: $userMeta, sensitiveMarks: $sensitiveMarks, mimeType: $mimeType, hash: $hash, size: $size, uploadedAt: $uploadedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, url: $url)';
}


}

/// @nodoc
abstract mixin class _$SnCloudFileCopyWith<$Res> implements $SnCloudFileCopyWith<$Res> {
  factory _$SnCloudFileCopyWith(_SnCloudFile value, $Res Function(_SnCloudFile) _then) = __$SnCloudFileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, Map<String, dynamic>? fileMeta, Map<String, dynamic>? userMeta, List<int> sensitiveMarks, String? mimeType, String? hash, int size, DateTime? uploadedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String? url
});




}
/// @nodoc
class __$SnCloudFileCopyWithImpl<$Res>
    implements _$SnCloudFileCopyWith<$Res> {
  __$SnCloudFileCopyWithImpl(this._self, this._then);

  final _SnCloudFile _self;
  final $Res Function(_SnCloudFile) _then;

/// Create a copy of SnCloudFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? fileMeta = freezed,Object? userMeta = freezed,Object? sensitiveMarks = null,Object? mimeType = freezed,Object? hash = freezed,Object? size = null,Object? uploadedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? url = freezed,}) {
  return _then(_SnCloudFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileMeta: freezed == fileMeta ? _self._fileMeta : fileMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,userMeta: freezed == userMeta ? _self._userMeta : userMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,sensitiveMarks: null == sensitiveMarks ? _self._sensitiveMarks : sensitiveMarks // ignore: cast_nullable_to_non_nullable
as List<int>,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SnCloudFileIndex {

 String get id; String get path; String get fileId; SnCloudFile get file; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnCloudFileIndex
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnCloudFileIndexCopyWith<SnCloudFileIndex> get copyWith => _$SnCloudFileIndexCopyWithImpl<SnCloudFileIndex>(this as SnCloudFileIndex, _$identity);

  /// Serializes this SnCloudFileIndex to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnCloudFileIndex&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.file, file) || other.file == file)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,path,fileId,file,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnCloudFileIndex(id: $id, path: $path, fileId: $fileId, file: $file, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnCloudFileIndexCopyWith<$Res>  {
  factory $SnCloudFileIndexCopyWith(SnCloudFileIndex value, $Res Function(SnCloudFileIndex) _then) = _$SnCloudFileIndexCopyWithImpl;
@useResult
$Res call({
 String id, String path, String fileId, SnCloudFile file, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnCloudFileCopyWith<$Res> get file;

}
/// @nodoc
class _$SnCloudFileIndexCopyWithImpl<$Res>
    implements $SnCloudFileIndexCopyWith<$Res> {
  _$SnCloudFileIndexCopyWithImpl(this._self, this._then);

  final SnCloudFileIndex _self;
  final $Res Function(SnCloudFileIndex) _then;

/// Create a copy of SnCloudFileIndex
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? path = null,Object? fileId = null,Object? file = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as SnCloudFile,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnCloudFileIndex
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res> get file {
  
  return $SnCloudFileCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnCloudFileIndex].
extension SnCloudFileIndexPatterns on SnCloudFileIndex {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnCloudFileIndex value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnCloudFileIndex() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnCloudFileIndex value)  $default,){
final _that = this;
switch (_that) {
case _SnCloudFileIndex():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnCloudFileIndex value)?  $default,){
final _that = this;
switch (_that) {
case _SnCloudFileIndex() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String path,  String fileId,  SnCloudFile file,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnCloudFileIndex() when $default != null:
return $default(_that.id,_that.path,_that.fileId,_that.file,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String path,  String fileId,  SnCloudFile file,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnCloudFileIndex():
return $default(_that.id,_that.path,_that.fileId,_that.file,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String path,  String fileId,  SnCloudFile file,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnCloudFileIndex() when $default != null:
return $default(_that.id,_that.path,_that.fileId,_that.file,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnCloudFileIndex implements SnCloudFileIndex {
  const _SnCloudFileIndex({required this.id, required this.path, required this.fileId, required this.file, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnCloudFileIndex.fromJson(Map<String, dynamic> json) => _$SnCloudFileIndexFromJson(json);

@override final  String id;
@override final  String path;
@override final  String fileId;
@override final  SnCloudFile file;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnCloudFileIndex
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnCloudFileIndexCopyWith<_SnCloudFileIndex> get copyWith => __$SnCloudFileIndexCopyWithImpl<_SnCloudFileIndex>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnCloudFileIndexToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnCloudFileIndex&&(identical(other.id, id) || other.id == id)&&(identical(other.path, path) || other.path == path)&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.file, file) || other.file == file)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,path,fileId,file,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnCloudFileIndex(id: $id, path: $path, fileId: $fileId, file: $file, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnCloudFileIndexCopyWith<$Res> implements $SnCloudFileIndexCopyWith<$Res> {
  factory _$SnCloudFileIndexCopyWith(_SnCloudFileIndex value, $Res Function(_SnCloudFileIndex) _then) = __$SnCloudFileIndexCopyWithImpl;
@override @useResult
$Res call({
 String id, String path, String fileId, SnCloudFile file, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnCloudFileCopyWith<$Res> get file;

}
/// @nodoc
class __$SnCloudFileIndexCopyWithImpl<$Res>
    implements _$SnCloudFileIndexCopyWith<$Res> {
  __$SnCloudFileIndexCopyWithImpl(this._self, this._then);

  final _SnCloudFileIndex _self;
  final $Res Function(_SnCloudFileIndex) _then;

/// Create a copy of SnCloudFileIndex
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? path = null,Object? fileId = null,Object? file = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnCloudFileIndex(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as SnCloudFile,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnCloudFileIndex
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res> get file {
  
  return $SnCloudFileCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}
}

// dart format on
