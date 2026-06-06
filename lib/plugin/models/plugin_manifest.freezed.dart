// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plugin_manifest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PluginManifest {

/// Unique reverse-domain identifier, e.g. "com.example.myplugin".
 String get id;/// Human-readable plugin name.
 String get name;/// Semver version string.
 String get version;/// Plugin author.
 String get author;/// Short description.
 String get description;/// Entry point JavaScript file relative to the plugin directory.
 String get entry;/// List of permissions this plugin requires.
 List<PluginPermission> get permissions;/// Whether this plugin should run as a background task.
 bool get background;/// Optional icon name (Material Symbols).
 String? get icon;/// Optional homepage URL.
 String? get homepage;
/// Create a copy of PluginManifest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PluginManifestCopyWith<PluginManifest> get copyWith => _$PluginManifestCopyWithImpl<PluginManifest>(this as PluginManifest, _$identity);

  /// Serializes this PluginManifest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PluginManifest&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.author, author) || other.author == author)&&(identical(other.description, description) || other.description == description)&&(identical(other.entry, entry) || other.entry == entry)&&const DeepCollectionEquality().equals(other.permissions, permissions)&&(identical(other.background, background) || other.background == background)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.homepage, homepage) || other.homepage == homepage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,version,author,description,entry,const DeepCollectionEquality().hash(permissions),background,icon,homepage);

@override
String toString() {
  return 'PluginManifest(id: $id, name: $name, version: $version, author: $author, description: $description, entry: $entry, permissions: $permissions, background: $background, icon: $icon, homepage: $homepage)';
}


}

/// @nodoc
abstract mixin class $PluginManifestCopyWith<$Res>  {
  factory $PluginManifestCopyWith(PluginManifest value, $Res Function(PluginManifest) _then) = _$PluginManifestCopyWithImpl;
@useResult
$Res call({
 String id, String name, String version, String author, String description, String entry, List<PluginPermission> permissions, bool background, String? icon, String? homepage
});




}
/// @nodoc
class _$PluginManifestCopyWithImpl<$Res>
    implements $PluginManifestCopyWith<$Res> {
  _$PluginManifestCopyWithImpl(this._self, this._then);

  final PluginManifest _self;
  final $Res Function(PluginManifest) _then;

/// Create a copy of PluginManifest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? version = null,Object? author = null,Object? description = null,Object? entry = null,Object? permissions = null,Object? background = null,Object? icon = freezed,Object? homepage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<PluginPermission>,background: null == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as bool,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,homepage: freezed == homepage ? _self.homepage : homepage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PluginManifest].
extension PluginManifestPatterns on PluginManifest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PluginManifest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PluginManifest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PluginManifest value)  $default,){
final _that = this;
switch (_that) {
case _PluginManifest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PluginManifest value)?  $default,){
final _that = this;
switch (_that) {
case _PluginManifest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String version,  String author,  String description,  String entry,  List<PluginPermission> permissions,  bool background,  String? icon,  String? homepage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PluginManifest() when $default != null:
return $default(_that.id,_that.name,_that.version,_that.author,_that.description,_that.entry,_that.permissions,_that.background,_that.icon,_that.homepage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String version,  String author,  String description,  String entry,  List<PluginPermission> permissions,  bool background,  String? icon,  String? homepage)  $default,) {final _that = this;
switch (_that) {
case _PluginManifest():
return $default(_that.id,_that.name,_that.version,_that.author,_that.description,_that.entry,_that.permissions,_that.background,_that.icon,_that.homepage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String version,  String author,  String description,  String entry,  List<PluginPermission> permissions,  bool background,  String? icon,  String? homepage)?  $default,) {final _that = this;
switch (_that) {
case _PluginManifest() when $default != null:
return $default(_that.id,_that.name,_that.version,_that.author,_that.description,_that.entry,_that.permissions,_that.background,_that.icon,_that.homepage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PluginManifest implements PluginManifest {
  const _PluginManifest({required this.id, required this.name, this.version = '1.0.0', this.author = '', this.description = '', this.entry = 'main.js', final  List<PluginPermission> permissions = const [], this.background = false, this.icon, this.homepage}): _permissions = permissions;
  factory _PluginManifest.fromJson(Map<String, dynamic> json) => _$PluginManifestFromJson(json);

/// Unique reverse-domain identifier, e.g. "com.example.myplugin".
@override final  String id;
/// Human-readable plugin name.
@override final  String name;
/// Semver version string.
@override@JsonKey() final  String version;
/// Plugin author.
@override@JsonKey() final  String author;
/// Short description.
@override@JsonKey() final  String description;
/// Entry point JavaScript file relative to the plugin directory.
@override@JsonKey() final  String entry;
/// List of permissions this plugin requires.
 final  List<PluginPermission> _permissions;
/// List of permissions this plugin requires.
@override@JsonKey() List<PluginPermission> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}

/// Whether this plugin should run as a background task.
@override@JsonKey() final  bool background;
/// Optional icon name (Material Symbols).
@override final  String? icon;
/// Optional homepage URL.
@override final  String? homepage;

/// Create a copy of PluginManifest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PluginManifestCopyWith<_PluginManifest> get copyWith => __$PluginManifestCopyWithImpl<_PluginManifest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PluginManifestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PluginManifest&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.author, author) || other.author == author)&&(identical(other.description, description) || other.description == description)&&(identical(other.entry, entry) || other.entry == entry)&&const DeepCollectionEquality().equals(other._permissions, _permissions)&&(identical(other.background, background) || other.background == background)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.homepage, homepage) || other.homepage == homepage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,version,author,description,entry,const DeepCollectionEquality().hash(_permissions),background,icon,homepage);

@override
String toString() {
  return 'PluginManifest(id: $id, name: $name, version: $version, author: $author, description: $description, entry: $entry, permissions: $permissions, background: $background, icon: $icon, homepage: $homepage)';
}


}

/// @nodoc
abstract mixin class _$PluginManifestCopyWith<$Res> implements $PluginManifestCopyWith<$Res> {
  factory _$PluginManifestCopyWith(_PluginManifest value, $Res Function(_PluginManifest) _then) = __$PluginManifestCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String version, String author, String description, String entry, List<PluginPermission> permissions, bool background, String? icon, String? homepage
});




}
/// @nodoc
class __$PluginManifestCopyWithImpl<$Res>
    implements _$PluginManifestCopyWith<$Res> {
  __$PluginManifestCopyWithImpl(this._self, this._then);

  final _PluginManifest _self;
  final $Res Function(_PluginManifest) _then;

/// Create a copy of PluginManifest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? version = null,Object? author = null,Object? description = null,Object? entry = null,Object? permissions = null,Object? background = null,Object? icon = freezed,Object? homepage = freezed,}) {
  return _then(_PluginManifest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<PluginPermission>,background: null == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as bool,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,homepage: freezed == homepage ? _self.homepage : homepage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
