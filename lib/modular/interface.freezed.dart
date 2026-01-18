// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interface.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PluginMetadata {

 String get id; String get name; String get version; String get description; String? get author; DateTime? get updatedAt;
/// Create a copy of PluginMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PluginMetadataCopyWith<PluginMetadata> get copyWith => _$PluginMetadataCopyWithImpl<PluginMetadata>(this as PluginMetadata, _$identity);

  /// Serializes this PluginMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PluginMetadata&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.description, description) || other.description == description)&&(identical(other.author, author) || other.author == author)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,version,description,author,updatedAt);

@override
String toString() {
  return 'PluginMetadata(id: $id, name: $name, version: $version, description: $description, author: $author, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PluginMetadataCopyWith<$Res>  {
  factory $PluginMetadataCopyWith(PluginMetadata value, $Res Function(PluginMetadata) _then) = _$PluginMetadataCopyWithImpl;
@useResult
$Res call({
 String id, String name, String version, String description, String? author, DateTime? updatedAt
});




}
/// @nodoc
class _$PluginMetadataCopyWithImpl<$Res>
    implements $PluginMetadataCopyWith<$Res> {
  _$PluginMetadataCopyWithImpl(this._self, this._then);

  final PluginMetadata _self;
  final $Res Function(PluginMetadata) _then;

/// Create a copy of PluginMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? version = null,Object? description = null,Object? author = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PluginMetadata].
extension PluginMetadataPatterns on PluginMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PluginMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PluginMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PluginMetadata value)  $default,){
final _that = this;
switch (_that) {
case _PluginMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PluginMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _PluginMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String version,  String description,  String? author,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PluginMetadata() when $default != null:
return $default(_that.id,_that.name,_that.version,_that.description,_that.author,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String version,  String description,  String? author,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PluginMetadata():
return $default(_that.id,_that.name,_that.version,_that.description,_that.author,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String version,  String description,  String? author,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PluginMetadata() when $default != null:
return $default(_that.id,_that.name,_that.version,_that.description,_that.author,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PluginMetadata implements PluginMetadata {
  const _PluginMetadata({required this.id, required this.name, required this.version, required this.description, this.author, this.updatedAt});
  factory _PluginMetadata.fromJson(Map<String, dynamic> json) => _$PluginMetadataFromJson(json);

@override final  String id;
@override final  String name;
@override final  String version;
@override final  String description;
@override final  String? author;
@override final  DateTime? updatedAt;

/// Create a copy of PluginMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PluginMetadataCopyWith<_PluginMetadata> get copyWith => __$PluginMetadataCopyWithImpl<_PluginMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PluginMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PluginMetadata&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.description, description) || other.description == description)&&(identical(other.author, author) || other.author == author)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,version,description,author,updatedAt);

@override
String toString() {
  return 'PluginMetadata(id: $id, name: $name, version: $version, description: $description, author: $author, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PluginMetadataCopyWith<$Res> implements $PluginMetadataCopyWith<$Res> {
  factory _$PluginMetadataCopyWith(_PluginMetadata value, $Res Function(_PluginMetadata) _then) = __$PluginMetadataCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String version, String description, String? author, DateTime? updatedAt
});




}
/// @nodoc
class __$PluginMetadataCopyWithImpl<$Res>
    implements _$PluginMetadataCopyWith<$Res> {
  __$PluginMetadataCopyWithImpl(this._self, this._then);

  final _PluginMetadata _self;
  final $Res Function(_PluginMetadata) _then;

/// Create a copy of PluginMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? version = null,Object? description = null,Object? author = freezed,Object? updatedAt = freezed,}) {
  return _then(_PluginMetadata(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MiniAppMetadata {

 String get id; String get name; String get version; String get description; String? get author; String? get iconUrl; String get downloadUrl; String? get localCachePath; DateTime? get lastUpdated; DateTime? get lastChecked; bool get isEnabled; int get localVersion; int? get sizeBytes;
/// Create a copy of MiniAppMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MiniAppMetadataCopyWith<MiniAppMetadata> get copyWith => _$MiniAppMetadataCopyWithImpl<MiniAppMetadata>(this as MiniAppMetadata, _$identity);

  /// Serializes this MiniAppMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MiniAppMetadata&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.description, description) || other.description == description)&&(identical(other.author, author) || other.author == author)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.localCachePath, localCachePath) || other.localCachePath == localCachePath)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.lastChecked, lastChecked) || other.lastChecked == lastChecked)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.localVersion, localVersion) || other.localVersion == localVersion)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,version,description,author,iconUrl,downloadUrl,localCachePath,lastUpdated,lastChecked,isEnabled,localVersion,sizeBytes);

@override
String toString() {
  return 'MiniAppMetadata(id: $id, name: $name, version: $version, description: $description, author: $author, iconUrl: $iconUrl, downloadUrl: $downloadUrl, localCachePath: $localCachePath, lastUpdated: $lastUpdated, lastChecked: $lastChecked, isEnabled: $isEnabled, localVersion: $localVersion, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class $MiniAppMetadataCopyWith<$Res>  {
  factory $MiniAppMetadataCopyWith(MiniAppMetadata value, $Res Function(MiniAppMetadata) _then) = _$MiniAppMetadataCopyWithImpl;
@useResult
$Res call({
 String id, String name, String version, String description, String? author, String? iconUrl, String downloadUrl, String? localCachePath, DateTime? lastUpdated, DateTime? lastChecked, bool isEnabled, int localVersion, int? sizeBytes
});




}
/// @nodoc
class _$MiniAppMetadataCopyWithImpl<$Res>
    implements $MiniAppMetadataCopyWith<$Res> {
  _$MiniAppMetadataCopyWithImpl(this._self, this._then);

  final MiniAppMetadata _self;
  final $Res Function(MiniAppMetadata) _then;

/// Create a copy of MiniAppMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? version = null,Object? description = null,Object? author = freezed,Object? iconUrl = freezed,Object? downloadUrl = null,Object? localCachePath = freezed,Object? lastUpdated = freezed,Object? lastChecked = freezed,Object? isEnabled = null,Object? localVersion = null,Object? sizeBytes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,localCachePath: freezed == localCachePath ? _self.localCachePath : localCachePath // ignore: cast_nullable_to_non_nullable
as String?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,lastChecked: freezed == lastChecked ? _self.lastChecked : lastChecked // ignore: cast_nullable_to_non_nullable
as DateTime?,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,localVersion: null == localVersion ? _self.localVersion : localVersion // ignore: cast_nullable_to_non_nullable
as int,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MiniAppMetadata].
extension MiniAppMetadataPatterns on MiniAppMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MiniAppMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MiniAppMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MiniAppMetadata value)  $default,){
final _that = this;
switch (_that) {
case _MiniAppMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MiniAppMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _MiniAppMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String version,  String description,  String? author,  String? iconUrl,  String downloadUrl,  String? localCachePath,  DateTime? lastUpdated,  DateTime? lastChecked,  bool isEnabled,  int localVersion,  int? sizeBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MiniAppMetadata() when $default != null:
return $default(_that.id,_that.name,_that.version,_that.description,_that.author,_that.iconUrl,_that.downloadUrl,_that.localCachePath,_that.lastUpdated,_that.lastChecked,_that.isEnabled,_that.localVersion,_that.sizeBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String version,  String description,  String? author,  String? iconUrl,  String downloadUrl,  String? localCachePath,  DateTime? lastUpdated,  DateTime? lastChecked,  bool isEnabled,  int localVersion,  int? sizeBytes)  $default,) {final _that = this;
switch (_that) {
case _MiniAppMetadata():
return $default(_that.id,_that.name,_that.version,_that.description,_that.author,_that.iconUrl,_that.downloadUrl,_that.localCachePath,_that.lastUpdated,_that.lastChecked,_that.isEnabled,_that.localVersion,_that.sizeBytes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String version,  String description,  String? author,  String? iconUrl,  String downloadUrl,  String? localCachePath,  DateTime? lastUpdated,  DateTime? lastChecked,  bool isEnabled,  int localVersion,  int? sizeBytes)?  $default,) {final _that = this;
switch (_that) {
case _MiniAppMetadata() when $default != null:
return $default(_that.id,_that.name,_that.version,_that.description,_that.author,_that.iconUrl,_that.downloadUrl,_that.localCachePath,_that.lastUpdated,_that.lastChecked,_that.isEnabled,_that.localVersion,_that.sizeBytes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MiniAppMetadata implements MiniAppMetadata {
  const _MiniAppMetadata({required this.id, required this.name, required this.version, required this.description, this.author, this.iconUrl, required this.downloadUrl, this.localCachePath, this.lastUpdated, this.lastChecked, this.isEnabled = false, this.localVersion = 0, this.sizeBytes});
  factory _MiniAppMetadata.fromJson(Map<String, dynamic> json) => _$MiniAppMetadataFromJson(json);

@override final  String id;
@override final  String name;
@override final  String version;
@override final  String description;
@override final  String? author;
@override final  String? iconUrl;
@override final  String downloadUrl;
@override final  String? localCachePath;
@override final  DateTime? lastUpdated;
@override final  DateTime? lastChecked;
@override@JsonKey() final  bool isEnabled;
@override@JsonKey() final  int localVersion;
@override final  int? sizeBytes;

/// Create a copy of MiniAppMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MiniAppMetadataCopyWith<_MiniAppMetadata> get copyWith => __$MiniAppMetadataCopyWithImpl<_MiniAppMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MiniAppMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MiniAppMetadata&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.description, description) || other.description == description)&&(identical(other.author, author) || other.author == author)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.localCachePath, localCachePath) || other.localCachePath == localCachePath)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.lastChecked, lastChecked) || other.lastChecked == lastChecked)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.localVersion, localVersion) || other.localVersion == localVersion)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,version,description,author,iconUrl,downloadUrl,localCachePath,lastUpdated,lastChecked,isEnabled,localVersion,sizeBytes);

@override
String toString() {
  return 'MiniAppMetadata(id: $id, name: $name, version: $version, description: $description, author: $author, iconUrl: $iconUrl, downloadUrl: $downloadUrl, localCachePath: $localCachePath, lastUpdated: $lastUpdated, lastChecked: $lastChecked, isEnabled: $isEnabled, localVersion: $localVersion, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class _$MiniAppMetadataCopyWith<$Res> implements $MiniAppMetadataCopyWith<$Res> {
  factory _$MiniAppMetadataCopyWith(_MiniAppMetadata value, $Res Function(_MiniAppMetadata) _then) = __$MiniAppMetadataCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String version, String description, String? author, String? iconUrl, String downloadUrl, String? localCachePath, DateTime? lastUpdated, DateTime? lastChecked, bool isEnabled, int localVersion, int? sizeBytes
});




}
/// @nodoc
class __$MiniAppMetadataCopyWithImpl<$Res>
    implements _$MiniAppMetadataCopyWith<$Res> {
  __$MiniAppMetadataCopyWithImpl(this._self, this._then);

  final _MiniAppMetadata _self;
  final $Res Function(_MiniAppMetadata) _then;

/// Create a copy of MiniAppMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? version = null,Object? description = null,Object? author = freezed,Object? iconUrl = freezed,Object? downloadUrl = null,Object? localCachePath = freezed,Object? lastUpdated = freezed,Object? lastChecked = freezed,Object? isEnabled = null,Object? localVersion = null,Object? sizeBytes = freezed,}) {
  return _then(_MiniAppMetadata(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,localCachePath: freezed == localCachePath ? _self.localCachePath : localCachePath // ignore: cast_nullable_to_non_nullable
as String?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,lastChecked: freezed == lastChecked ? _self.lastChecked : lastChecked // ignore: cast_nullable_to_non_nullable
as DateTime?,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,localVersion: null == localVersion ? _self.localVersion : localVersion // ignore: cast_nullable_to_non_nullable
as int,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$MiniAppServerInfo {

 String get id; String get name; String get version; String get description; String? get author; String? get iconUrl; String get downloadUrl; DateTime get updatedAt; int get sizeBytes;
/// Create a copy of MiniAppServerInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MiniAppServerInfoCopyWith<MiniAppServerInfo> get copyWith => _$MiniAppServerInfoCopyWithImpl<MiniAppServerInfo>(this as MiniAppServerInfo, _$identity);

  /// Serializes this MiniAppServerInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MiniAppServerInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.description, description) || other.description == description)&&(identical(other.author, author) || other.author == author)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,version,description,author,iconUrl,downloadUrl,updatedAt,sizeBytes);

@override
String toString() {
  return 'MiniAppServerInfo(id: $id, name: $name, version: $version, description: $description, author: $author, iconUrl: $iconUrl, downloadUrl: $downloadUrl, updatedAt: $updatedAt, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class $MiniAppServerInfoCopyWith<$Res>  {
  factory $MiniAppServerInfoCopyWith(MiniAppServerInfo value, $Res Function(MiniAppServerInfo) _then) = _$MiniAppServerInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String version, String description, String? author, String? iconUrl, String downloadUrl, DateTime updatedAt, int sizeBytes
});




}
/// @nodoc
class _$MiniAppServerInfoCopyWithImpl<$Res>
    implements $MiniAppServerInfoCopyWith<$Res> {
  _$MiniAppServerInfoCopyWithImpl(this._self, this._then);

  final MiniAppServerInfo _self;
  final $Res Function(MiniAppServerInfo) _then;

/// Create a copy of MiniAppServerInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? version = null,Object? description = null,Object? author = freezed,Object? iconUrl = freezed,Object? downloadUrl = null,Object? updatedAt = null,Object? sizeBytes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MiniAppServerInfo].
extension MiniAppServerInfoPatterns on MiniAppServerInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MiniAppServerInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MiniAppServerInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MiniAppServerInfo value)  $default,){
final _that = this;
switch (_that) {
case _MiniAppServerInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MiniAppServerInfo value)?  $default,){
final _that = this;
switch (_that) {
case _MiniAppServerInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String version,  String description,  String? author,  String? iconUrl,  String downloadUrl,  DateTime updatedAt,  int sizeBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MiniAppServerInfo() when $default != null:
return $default(_that.id,_that.name,_that.version,_that.description,_that.author,_that.iconUrl,_that.downloadUrl,_that.updatedAt,_that.sizeBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String version,  String description,  String? author,  String? iconUrl,  String downloadUrl,  DateTime updatedAt,  int sizeBytes)  $default,) {final _that = this;
switch (_that) {
case _MiniAppServerInfo():
return $default(_that.id,_that.name,_that.version,_that.description,_that.author,_that.iconUrl,_that.downloadUrl,_that.updatedAt,_that.sizeBytes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String version,  String description,  String? author,  String? iconUrl,  String downloadUrl,  DateTime updatedAt,  int sizeBytes)?  $default,) {final _that = this;
switch (_that) {
case _MiniAppServerInfo() when $default != null:
return $default(_that.id,_that.name,_that.version,_that.description,_that.author,_that.iconUrl,_that.downloadUrl,_that.updatedAt,_that.sizeBytes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MiniAppServerInfo implements MiniAppServerInfo {
  const _MiniAppServerInfo({required this.id, required this.name, required this.version, required this.description, this.author, this.iconUrl, required this.downloadUrl, required this.updatedAt, required this.sizeBytes});
  factory _MiniAppServerInfo.fromJson(Map<String, dynamic> json) => _$MiniAppServerInfoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String version;
@override final  String description;
@override final  String? author;
@override final  String? iconUrl;
@override final  String downloadUrl;
@override final  DateTime updatedAt;
@override final  int sizeBytes;

/// Create a copy of MiniAppServerInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MiniAppServerInfoCopyWith<_MiniAppServerInfo> get copyWith => __$MiniAppServerInfoCopyWithImpl<_MiniAppServerInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MiniAppServerInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MiniAppServerInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.description, description) || other.description == description)&&(identical(other.author, author) || other.author == author)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,version,description,author,iconUrl,downloadUrl,updatedAt,sizeBytes);

@override
String toString() {
  return 'MiniAppServerInfo(id: $id, name: $name, version: $version, description: $description, author: $author, iconUrl: $iconUrl, downloadUrl: $downloadUrl, updatedAt: $updatedAt, sizeBytes: $sizeBytes)';
}


}

/// @nodoc
abstract mixin class _$MiniAppServerInfoCopyWith<$Res> implements $MiniAppServerInfoCopyWith<$Res> {
  factory _$MiniAppServerInfoCopyWith(_MiniAppServerInfo value, $Res Function(_MiniAppServerInfo) _then) = __$MiniAppServerInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String version, String description, String? author, String? iconUrl, String downloadUrl, DateTime updatedAt, int sizeBytes
});




}
/// @nodoc
class __$MiniAppServerInfoCopyWithImpl<$Res>
    implements _$MiniAppServerInfoCopyWith<$Res> {
  __$MiniAppServerInfoCopyWithImpl(this._self, this._then);

  final _MiniAppServerInfo _self;
  final $Res Function(_MiniAppServerInfo) _then;

/// Create a copy of MiniAppServerInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? version = null,Object? description = null,Object? author = freezed,Object? iconUrl = freezed,Object? downloadUrl = null,Object? updatedAt = null,Object? sizeBytes = null,}) {
  return _then(_MiniAppServerInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,downloadUrl: null == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
