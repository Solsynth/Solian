// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnSiteFileEntry {

 bool get isDirectory; String get relativePath; int get size;// Size in bytes (0 for directories)
 DateTime get modified;
/// Create a copy of SnSiteFileEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnSiteFileEntryCopyWith<SnSiteFileEntry> get copyWith => _$SnSiteFileEntryCopyWithImpl<SnSiteFileEntry>(this as SnSiteFileEntry, _$identity);

  /// Serializes this SnSiteFileEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnSiteFileEntry&&(identical(other.isDirectory, isDirectory) || other.isDirectory == isDirectory)&&(identical(other.relativePath, relativePath) || other.relativePath == relativePath)&&(identical(other.size, size) || other.size == size)&&(identical(other.modified, modified) || other.modified == modified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isDirectory,relativePath,size,modified);

@override
String toString() {
  return 'SnSiteFileEntry(isDirectory: $isDirectory, relativePath: $relativePath, size: $size, modified: $modified)';
}


}

/// @nodoc
abstract mixin class $SnSiteFileEntryCopyWith<$Res>  {
  factory $SnSiteFileEntryCopyWith(SnSiteFileEntry value, $Res Function(SnSiteFileEntry) _then) = _$SnSiteFileEntryCopyWithImpl;
@useResult
$Res call({
 bool isDirectory, String relativePath, int size, DateTime modified
});




}
/// @nodoc
class _$SnSiteFileEntryCopyWithImpl<$Res>
    implements $SnSiteFileEntryCopyWith<$Res> {
  _$SnSiteFileEntryCopyWithImpl(this._self, this._then);

  final SnSiteFileEntry _self;
  final $Res Function(SnSiteFileEntry) _then;

/// Create a copy of SnSiteFileEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isDirectory = null,Object? relativePath = null,Object? size = null,Object? modified = null,}) {
  return _then(_self.copyWith(
isDirectory: null == isDirectory ? _self.isDirectory : isDirectory // ignore: cast_nullable_to_non_nullable
as bool,relativePath: null == relativePath ? _self.relativePath : relativePath // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,modified: null == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SnSiteFileEntry].
extension SnSiteFileEntryPatterns on SnSiteFileEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnSiteFileEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnSiteFileEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnSiteFileEntry value)  $default,){
final _that = this;
switch (_that) {
case _SnSiteFileEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnSiteFileEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SnSiteFileEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isDirectory,  String relativePath,  int size,  DateTime modified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnSiteFileEntry() when $default != null:
return $default(_that.isDirectory,_that.relativePath,_that.size,_that.modified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isDirectory,  String relativePath,  int size,  DateTime modified)  $default,) {final _that = this;
switch (_that) {
case _SnSiteFileEntry():
return $default(_that.isDirectory,_that.relativePath,_that.size,_that.modified);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isDirectory,  String relativePath,  int size,  DateTime modified)?  $default,) {final _that = this;
switch (_that) {
case _SnSiteFileEntry() when $default != null:
return $default(_that.isDirectory,_that.relativePath,_that.size,_that.modified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnSiteFileEntry implements SnSiteFileEntry {
  const _SnSiteFileEntry({required this.isDirectory, required this.relativePath, required this.size, required this.modified});
  factory _SnSiteFileEntry.fromJson(Map<String, dynamic> json) => _$SnSiteFileEntryFromJson(json);

@override final  bool isDirectory;
@override final  String relativePath;
@override final  int size;
// Size in bytes (0 for directories)
@override final  DateTime modified;

/// Create a copy of SnSiteFileEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnSiteFileEntryCopyWith<_SnSiteFileEntry> get copyWith => __$SnSiteFileEntryCopyWithImpl<_SnSiteFileEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnSiteFileEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnSiteFileEntry&&(identical(other.isDirectory, isDirectory) || other.isDirectory == isDirectory)&&(identical(other.relativePath, relativePath) || other.relativePath == relativePath)&&(identical(other.size, size) || other.size == size)&&(identical(other.modified, modified) || other.modified == modified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isDirectory,relativePath,size,modified);

@override
String toString() {
  return 'SnSiteFileEntry(isDirectory: $isDirectory, relativePath: $relativePath, size: $size, modified: $modified)';
}


}

/// @nodoc
abstract mixin class _$SnSiteFileEntryCopyWith<$Res> implements $SnSiteFileEntryCopyWith<$Res> {
  factory _$SnSiteFileEntryCopyWith(_SnSiteFileEntry value, $Res Function(_SnSiteFileEntry) _then) = __$SnSiteFileEntryCopyWithImpl;
@override @useResult
$Res call({
 bool isDirectory, String relativePath, int size, DateTime modified
});




}
/// @nodoc
class __$SnSiteFileEntryCopyWithImpl<$Res>
    implements _$SnSiteFileEntryCopyWith<$Res> {
  __$SnSiteFileEntryCopyWithImpl(this._self, this._then);

  final _SnSiteFileEntry _self;
  final $Res Function(_SnSiteFileEntry) _then;

/// Create a copy of SnSiteFileEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isDirectory = null,Object? relativePath = null,Object? size = null,Object? modified = null,}) {
  return _then(_SnSiteFileEntry(
isDirectory: null == isDirectory ? _self.isDirectory : isDirectory // ignore: cast_nullable_to_non_nullable
as bool,relativePath: null == relativePath ? _self.relativePath : relativePath // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,modified: null == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$SnFileContent {

 String get content;
/// Create a copy of SnFileContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFileContentCopyWith<SnFileContent> get copyWith => _$SnFileContentCopyWithImpl<SnFileContent>(this as SnFileContent, _$identity);

  /// Serializes this SnFileContent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFileContent&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content);

@override
String toString() {
  return 'SnFileContent(content: $content)';
}


}

/// @nodoc
abstract mixin class $SnFileContentCopyWith<$Res>  {
  factory $SnFileContentCopyWith(SnFileContent value, $Res Function(SnFileContent) _then) = _$SnFileContentCopyWithImpl;
@useResult
$Res call({
 String content
});




}
/// @nodoc
class _$SnFileContentCopyWithImpl<$Res>
    implements $SnFileContentCopyWith<$Res> {
  _$SnFileContentCopyWithImpl(this._self, this._then);

  final SnFileContent _self;
  final $Res Function(SnFileContent) _then;

/// Create a copy of SnFileContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,}) {
  return _then(_self.copyWith(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnFileContent].
extension SnFileContentPatterns on SnFileContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFileContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFileContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFileContent value)  $default,){
final _that = this;
switch (_that) {
case _SnFileContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFileContent value)?  $default,){
final _that = this;
switch (_that) {
case _SnFileContent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFileContent() when $default != null:
return $default(_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String content)  $default,) {final _that = this;
switch (_that) {
case _SnFileContent():
return $default(_that.content);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String content)?  $default,) {final _that = this;
switch (_that) {
case _SnFileContent() when $default != null:
return $default(_that.content);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFileContent implements SnFileContent {
  const _SnFileContent({required this.content});
  factory _SnFileContent.fromJson(Map<String, dynamic> json) => _$SnFileContentFromJson(json);

@override final  String content;

/// Create a copy of SnFileContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFileContentCopyWith<_SnFileContent> get copyWith => __$SnFileContentCopyWithImpl<_SnFileContent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFileContentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFileContent&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content);

@override
String toString() {
  return 'SnFileContent(content: $content)';
}


}

/// @nodoc
abstract mixin class _$SnFileContentCopyWith<$Res> implements $SnFileContentCopyWith<$Res> {
  factory _$SnFileContentCopyWith(_SnFileContent value, $Res Function(_SnFileContent) _then) = __$SnFileContentCopyWithImpl;
@override @useResult
$Res call({
 String content
});




}
/// @nodoc
class __$SnFileContentCopyWithImpl<$Res>
    implements _$SnFileContentCopyWith<$Res> {
  __$SnFileContentCopyWithImpl(this._self, this._then);

  final _SnFileContent _self;
  final $Res Function(_SnFileContent) _then;

/// Create a copy of SnFileContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,}) {
  return _then(_SnFileContent(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
