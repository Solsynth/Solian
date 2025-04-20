// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnCloudFile {

 String get id; String get name; String? get description; Map<String, dynamic>? get fileMeta; Map<String, dynamic>? get userMeta; String? get mimeType; String? get hash; int get size; DateTime get uploadedAt; String? get uploadedTo; int get usedCount; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnCloudFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<SnCloudFile> get copyWith => _$SnCloudFileCopyWithImpl<SnCloudFile>(this as SnCloudFile, _$identity);

  /// Serializes this SnCloudFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnCloudFile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.fileMeta, fileMeta)&&const DeepCollectionEquality().equals(other.userMeta, userMeta)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.size, size) || other.size == size)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.uploadedTo, uploadedTo) || other.uploadedTo == uploadedTo)&&(identical(other.usedCount, usedCount) || other.usedCount == usedCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(fileMeta),const DeepCollectionEquality().hash(userMeta),mimeType,hash,size,uploadedAt,uploadedTo,usedCount,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnCloudFile(id: $id, name: $name, description: $description, fileMeta: $fileMeta, userMeta: $userMeta, mimeType: $mimeType, hash: $hash, size: $size, uploadedAt: $uploadedAt, uploadedTo: $uploadedTo, usedCount: $usedCount, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnCloudFileCopyWith<$Res>  {
  factory $SnCloudFileCopyWith(SnCloudFile value, $Res Function(SnCloudFile) _then) = _$SnCloudFileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, Map<String, dynamic>? fileMeta, Map<String, dynamic>? userMeta, String? mimeType, String? hash, int size, DateTime uploadedAt, String? uploadedTo, int usedCount, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? fileMeta = freezed,Object? userMeta = freezed,Object? mimeType = freezed,Object? hash = freezed,Object? size = null,Object? uploadedAt = null,Object? uploadedTo = freezed,Object? usedCount = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileMeta: freezed == fileMeta ? _self.fileMeta : fileMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,userMeta: freezed == userMeta ? _self.userMeta : userMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,uploadedTo: freezed == uploadedTo ? _self.uploadedTo : uploadedTo // ignore: cast_nullable_to_non_nullable
as String?,usedCount: null == usedCount ? _self.usedCount : usedCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SnCloudFile implements SnCloudFile {
  const _SnCloudFile({required this.id, required this.name, required this.description, required final  Map<String, dynamic>? fileMeta, required final  Map<String, dynamic>? userMeta, required this.mimeType, required this.hash, required this.size, required this.uploadedAt, required this.uploadedTo, required this.usedCount, required this.createdAt, required this.updatedAt, required this.deletedAt}): _fileMeta = fileMeta,_userMeta = userMeta;
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

@override final  String? mimeType;
@override final  String? hash;
@override final  int size;
@override final  DateTime uploadedAt;
@override final  String? uploadedTo;
@override final  int usedCount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnCloudFile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._fileMeta, _fileMeta)&&const DeepCollectionEquality().equals(other._userMeta, _userMeta)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.size, size) || other.size == size)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.uploadedTo, uploadedTo) || other.uploadedTo == uploadedTo)&&(identical(other.usedCount, usedCount) || other.usedCount == usedCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(_fileMeta),const DeepCollectionEquality().hash(_userMeta),mimeType,hash,size,uploadedAt,uploadedTo,usedCount,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnCloudFile(id: $id, name: $name, description: $description, fileMeta: $fileMeta, userMeta: $userMeta, mimeType: $mimeType, hash: $hash, size: $size, uploadedAt: $uploadedAt, uploadedTo: $uploadedTo, usedCount: $usedCount, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnCloudFileCopyWith<$Res> implements $SnCloudFileCopyWith<$Res> {
  factory _$SnCloudFileCopyWith(_SnCloudFile value, $Res Function(_SnCloudFile) _then) = __$SnCloudFileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, Map<String, dynamic>? fileMeta, Map<String, dynamic>? userMeta, String? mimeType, String? hash, int size, DateTime uploadedAt, String? uploadedTo, int usedCount, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? fileMeta = freezed,Object? userMeta = freezed,Object? mimeType = freezed,Object? hash = freezed,Object? size = null,Object? uploadedAt = null,Object? uploadedTo = freezed,Object? usedCount = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnCloudFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,fileMeta: freezed == fileMeta ? _self._fileMeta : fileMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,userMeta: freezed == userMeta ? _self._userMeta : userMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,hash: freezed == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String?,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,uploadedTo: freezed == uploadedTo ? _self.uploadedTo : uploadedTo // ignore: cast_nullable_to_non_nullable
as String?,usedCount: null == usedCount ? _self.usedCount : usedCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
