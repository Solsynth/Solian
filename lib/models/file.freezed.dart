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
mixin _$SnCloudFile {

 String get id; String get name; String? get description; Map<String, dynamic>? get fileMeta; Map<String, dynamic>? get userMeta; SnFilePool? get pool; List<int> get sensitiveMarks; String? get mimeType; String? get hash; int get size; DateTime? get uploadedAt; String? get uploadedTo; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; String? get url;
/// Create a copy of SnCloudFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<SnCloudFile> get copyWith => _$SnCloudFileCopyWithImpl<SnCloudFile>(this as SnCloudFile, _$identity);

  /// Serializes this SnCloudFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnCloudFile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.fileMeta, fileMeta)&&const DeepCollectionEquality().equals(other.userMeta, userMeta)&&(identical(other.pool, pool) || other.pool == pool)&&const DeepCollectionEquality().equals(other.sensitiveMarks, sensitiveMarks)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.size, size) || other.size == size)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.uploadedTo, uploadedTo) || other.uploadedTo == uploadedTo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(fileMeta),const DeepCollectionEquality().hash(userMeta),pool,const DeepCollectionEquality().hash(sensitiveMarks),mimeType,hash,size,uploadedAt,uploadedTo,createdAt,updatedAt,deletedAt,url);

@override
String toString() {
  return 'SnCloudFile(id: $id, name: $name, description: $description, fileMeta: $fileMeta, userMeta: $userMeta, pool: $pool, sensitiveMarks: $sensitiveMarks, mimeType: $mimeType, hash: $hash, size: $size, uploadedAt: $uploadedAt, uploadedTo: $uploadedTo, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, url: $url)';
}


}

/// @nodoc
abstract mixin class $SnCloudFileCopyWith<$Res>  {
  factory $SnCloudFileCopyWith(SnCloudFile value, $Res Function(SnCloudFile) _then) = _$SnCloudFileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, Map<String, dynamic>? fileMeta, Map<String, dynamic>? userMeta, SnFilePool? pool, List<int> sensitiveMarks, String? mimeType, String? hash, int size, DateTime? uploadedAt, String? uploadedTo, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String? url
});


$SnFilePoolCopyWith<$Res>? get pool;

}
/// @nodoc
class _$SnCloudFileCopyWithImpl<$Res>
    implements $SnCloudFileCopyWith<$Res> {
  _$SnCloudFileCopyWithImpl(this._self, this._then);

  final SnCloudFile _self;
  final $Res Function(SnCloudFile) _then;

/// Create a copy of SnCloudFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? fileMeta = freezed,Object? userMeta = freezed,Object? pool = freezed,Object? sensitiveMarks = null,Object? mimeType = freezed,Object? hash = freezed,Object? size = null,Object? uploadedAt = freezed,Object? uploadedTo = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? url = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileMeta: freezed == fileMeta ? _self.fileMeta : fileMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,userMeta: freezed == userMeta ? _self.userMeta : userMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,pool: freezed == pool ? _self.pool : pool // ignore: cast_nullable_to_non_nullable
as SnFilePool?,sensitiveMarks: null == sensitiveMarks ? _self.sensitiveMarks : sensitiveMarks // ignore: cast_nullable_to_non_nullable
as List<int>,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,uploadedTo: freezed == uploadedTo ? _self.uploadedTo : uploadedTo // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SnCloudFile
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  Map<String, dynamic>? fileMeta,  Map<String, dynamic>? userMeta,  SnFilePool? pool,  List<int> sensitiveMarks,  String? mimeType,  String? hash,  int size,  DateTime? uploadedAt,  String? uploadedTo,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String? url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnCloudFile() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.fileMeta,_that.userMeta,_that.pool,_that.sensitiveMarks,_that.mimeType,_that.hash,_that.size,_that.uploadedAt,_that.uploadedTo,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  Map<String, dynamic>? fileMeta,  Map<String, dynamic>? userMeta,  SnFilePool? pool,  List<int> sensitiveMarks,  String? mimeType,  String? hash,  int size,  DateTime? uploadedAt,  String? uploadedTo,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String? url)  $default,) {final _that = this;
switch (_that) {
case _SnCloudFile():
return $default(_that.id,_that.name,_that.description,_that.fileMeta,_that.userMeta,_that.pool,_that.sensitiveMarks,_that.mimeType,_that.hash,_that.size,_that.uploadedAt,_that.uploadedTo,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.url);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  Map<String, dynamic>? fileMeta,  Map<String, dynamic>? userMeta,  SnFilePool? pool,  List<int> sensitiveMarks,  String? mimeType,  String? hash,  int size,  DateTime? uploadedAt,  String? uploadedTo,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String? url)?  $default,) {final _that = this;
switch (_that) {
case _SnCloudFile() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.fileMeta,_that.userMeta,_that.pool,_that.sensitiveMarks,_that.mimeType,_that.hash,_that.size,_that.uploadedAt,_that.uploadedTo,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnCloudFile implements SnCloudFile {
  const _SnCloudFile({required this.id, required this.name, required this.description, required final  Map<String, dynamic>? fileMeta, required final  Map<String, dynamic>? userMeta, required this.pool, final  List<int> sensitiveMarks = const [], required this.mimeType, required this.hash, required this.size, required this.uploadedAt, required this.uploadedTo, required this.createdAt, required this.updatedAt, required this.deletedAt, this.url}): _fileMeta = fileMeta,_userMeta = userMeta,_sensitiveMarks = sensitiveMarks;
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

@override final  SnFilePool? pool;
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
@override final  String? uploadedTo;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnCloudFile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._fileMeta, _fileMeta)&&const DeepCollectionEquality().equals(other._userMeta, _userMeta)&&(identical(other.pool, pool) || other.pool == pool)&&const DeepCollectionEquality().equals(other._sensitiveMarks, _sensitiveMarks)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.size, size) || other.size == size)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.uploadedTo, uploadedTo) || other.uploadedTo == uploadedTo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(_fileMeta),const DeepCollectionEquality().hash(_userMeta),pool,const DeepCollectionEquality().hash(_sensitiveMarks),mimeType,hash,size,uploadedAt,uploadedTo,createdAt,updatedAt,deletedAt,url);

@override
String toString() {
  return 'SnCloudFile(id: $id, name: $name, description: $description, fileMeta: $fileMeta, userMeta: $userMeta, pool: $pool, sensitiveMarks: $sensitiveMarks, mimeType: $mimeType, hash: $hash, size: $size, uploadedAt: $uploadedAt, uploadedTo: $uploadedTo, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, url: $url)';
}


}

/// @nodoc
abstract mixin class _$SnCloudFileCopyWith<$Res> implements $SnCloudFileCopyWith<$Res> {
  factory _$SnCloudFileCopyWith(_SnCloudFile value, $Res Function(_SnCloudFile) _then) = __$SnCloudFileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, Map<String, dynamic>? fileMeta, Map<String, dynamic>? userMeta, SnFilePool? pool, List<int> sensitiveMarks, String? mimeType, String? hash, int size, DateTime? uploadedAt, String? uploadedTo, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String? url
});


@override $SnFilePoolCopyWith<$Res>? get pool;

}
/// @nodoc
class __$SnCloudFileCopyWithImpl<$Res>
    implements _$SnCloudFileCopyWith<$Res> {
  __$SnCloudFileCopyWithImpl(this._self, this._then);

  final _SnCloudFile _self;
  final $Res Function(_SnCloudFile) _then;

/// Create a copy of SnCloudFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? fileMeta = freezed,Object? userMeta = freezed,Object? pool = freezed,Object? sensitiveMarks = null,Object? mimeType = freezed,Object? hash = freezed,Object? size = null,Object? uploadedAt = freezed,Object? uploadedTo = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? url = freezed,}) {
  return _then(_SnCloudFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileMeta: freezed == fileMeta ? _self._fileMeta : fileMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,userMeta: freezed == userMeta ? _self._userMeta : userMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,pool: freezed == pool ? _self.pool : pool // ignore: cast_nullable_to_non_nullable
as SnFilePool?,sensitiveMarks: null == sensitiveMarks ? _self._sensitiveMarks : sensitiveMarks // ignore: cast_nullable_to_non_nullable
as List<int>,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,uploadedAt: freezed == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,uploadedTo: freezed == uploadedTo ? _self.uploadedTo : uploadedTo // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SnCloudFile
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
