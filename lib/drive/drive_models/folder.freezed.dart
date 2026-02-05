// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'folder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnCloudFolder {

 String get id; String get name; String? get parentFolderId; String get accountId; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SnCloudFolder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnCloudFolderCopyWith<SnCloudFolder> get copyWith => _$SnCloudFolderCopyWithImpl<SnCloudFolder>(this as SnCloudFolder, _$identity);

  /// Serializes this SnCloudFolder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnCloudFolder&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentFolderId, parentFolderId) || other.parentFolderId == parentFolderId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,parentFolderId,accountId,createdAt,updatedAt);

@override
String toString() {
  return 'SnCloudFolder(id: $id, name: $name, parentFolderId: $parentFolderId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SnCloudFolderCopyWith<$Res>  {
  factory $SnCloudFolderCopyWith(SnCloudFolder value, $Res Function(SnCloudFolder) _then) = _$SnCloudFolderCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? parentFolderId, String accountId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SnCloudFolderCopyWithImpl<$Res>
    implements $SnCloudFolderCopyWith<$Res> {
  _$SnCloudFolderCopyWithImpl(this._self, this._then);

  final SnCloudFolder _self;
  final $Res Function(SnCloudFolder) _then;

/// Create a copy of SnCloudFolder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? parentFolderId = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentFolderId: freezed == parentFolderId ? _self.parentFolderId : parentFolderId // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SnCloudFolder].
extension SnCloudFolderPatterns on SnCloudFolder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnCloudFolder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnCloudFolder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnCloudFolder value)  $default,){
final _that = this;
switch (_that) {
case _SnCloudFolder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnCloudFolder value)?  $default,){
final _that = this;
switch (_that) {
case _SnCloudFolder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? parentFolderId,  String accountId,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnCloudFolder() when $default != null:
return $default(_that.id,_that.name,_that.parentFolderId,_that.accountId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? parentFolderId,  String accountId,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SnCloudFolder():
return $default(_that.id,_that.name,_that.parentFolderId,_that.accountId,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? parentFolderId,  String accountId,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnCloudFolder() when $default != null:
return $default(_that.id,_that.name,_that.parentFolderId,_that.accountId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnCloudFolder implements SnCloudFolder {
  const _SnCloudFolder({required this.id, required this.name, required this.parentFolderId, required this.accountId, required this.createdAt, required this.updatedAt});
  factory _SnCloudFolder.fromJson(Map<String, dynamic> json) => _$SnCloudFolderFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? parentFolderId;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SnCloudFolder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnCloudFolderCopyWith<_SnCloudFolder> get copyWith => __$SnCloudFolderCopyWithImpl<_SnCloudFolder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnCloudFolderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnCloudFolder&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.parentFolderId, parentFolderId) || other.parentFolderId == parentFolderId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,parentFolderId,accountId,createdAt,updatedAt);

@override
String toString() {
  return 'SnCloudFolder(id: $id, name: $name, parentFolderId: $parentFolderId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnCloudFolderCopyWith<$Res> implements $SnCloudFolderCopyWith<$Res> {
  factory _$SnCloudFolderCopyWith(_SnCloudFolder value, $Res Function(_SnCloudFolder) _then) = __$SnCloudFolderCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? parentFolderId, String accountId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SnCloudFolderCopyWithImpl<$Res>
    implements _$SnCloudFolderCopyWith<$Res> {
  __$SnCloudFolderCopyWithImpl(this._self, this._then);

  final _SnCloudFolder _self;
  final $Res Function(_SnCloudFolder) _then;

/// Create a copy of SnCloudFolder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? parentFolderId = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SnCloudFolder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,parentFolderId: freezed == parentFolderId ? _self.parentFolderId : parentFolderId // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
