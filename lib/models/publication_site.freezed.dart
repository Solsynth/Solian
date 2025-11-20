// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'publication_site.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPublicationSite {

 String get id; String get slug; String get name; String? get description; String get publisherId; String get accountId; DateTime get createdAt; DateTime get updatedAt; List<SnPublicationPage> get pages;
/// Create a copy of SnPublicationSite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublicationSiteCopyWith<SnPublicationSite> get copyWith => _$SnPublicationSiteCopyWithImpl<SnPublicationSite>(this as SnPublicationSite, _$identity);

  /// Serializes this SnPublicationSite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublicationSite&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.pages, pages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,publisherId,accountId,createdAt,updatedAt,const DeepCollectionEquality().hash(pages));

@override
String toString() {
  return 'SnPublicationSite(id: $id, slug: $slug, name: $name, description: $description, publisherId: $publisherId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, pages: $pages)';
}


}

/// @nodoc
abstract mixin class $SnPublicationSiteCopyWith<$Res>  {
  factory $SnPublicationSiteCopyWith(SnPublicationSite value, $Res Function(SnPublicationSite) _then) = _$SnPublicationSiteCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String name, String? description, String publisherId, String accountId, DateTime createdAt, DateTime updatedAt, List<SnPublicationPage> pages
});




}
/// @nodoc
class _$SnPublicationSiteCopyWithImpl<$Res>
    implements $SnPublicationSiteCopyWith<$Res> {
  _$SnPublicationSiteCopyWithImpl(this._self, this._then);

  final SnPublicationSite _self;
  final $Res Function(SnPublicationSite) _then;

/// Create a copy of SnPublicationSite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = freezed,Object? publisherId = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? pages = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as List<SnPublicationPage>,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPublicationSite].
extension SnPublicationSitePatterns on SnPublicationSite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublicationSite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublicationSite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublicationSite value)  $default,){
final _that = this;
switch (_that) {
case _SnPublicationSite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublicationSite value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublicationSite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String? description,  String publisherId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  List<SnPublicationPage> pages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublicationSite() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.publisherId,_that.accountId,_that.createdAt,_that.updatedAt,_that.pages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String? description,  String publisherId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  List<SnPublicationPage> pages)  $default,) {final _that = this;
switch (_that) {
case _SnPublicationSite():
return $default(_that.id,_that.slug,_that.name,_that.description,_that.publisherId,_that.accountId,_that.createdAt,_that.updatedAt,_that.pages);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String name,  String? description,  String publisherId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  List<SnPublicationPage> pages)?  $default,) {final _that = this;
switch (_that) {
case _SnPublicationSite() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.publisherId,_that.accountId,_that.createdAt,_that.updatedAt,_that.pages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublicationSite implements SnPublicationSite {
  const _SnPublicationSite({required this.id, required this.slug, required this.name, this.description, required this.publisherId, required this.accountId, required this.createdAt, required this.updatedAt, required final  List<SnPublicationPage> pages}): _pages = pages;
  factory _SnPublicationSite.fromJson(Map<String, dynamic> json) => _$SnPublicationSiteFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String name;
@override final  String? description;
@override final  String publisherId;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<SnPublicationPage> _pages;
@override List<SnPublicationPage> get pages {
  if (_pages is EqualUnmodifiableListView) return _pages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pages);
}


/// Create a copy of SnPublicationSite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublicationSiteCopyWith<_SnPublicationSite> get copyWith => __$SnPublicationSiteCopyWithImpl<_SnPublicationSite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublicationSiteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublicationSite&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._pages, _pages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,publisherId,accountId,createdAt,updatedAt,const DeepCollectionEquality().hash(_pages));

@override
String toString() {
  return 'SnPublicationSite(id: $id, slug: $slug, name: $name, description: $description, publisherId: $publisherId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, pages: $pages)';
}


}

/// @nodoc
abstract mixin class _$SnPublicationSiteCopyWith<$Res> implements $SnPublicationSiteCopyWith<$Res> {
  factory _$SnPublicationSiteCopyWith(_SnPublicationSite value, $Res Function(_SnPublicationSite) _then) = __$SnPublicationSiteCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String name, String? description, String publisherId, String accountId, DateTime createdAt, DateTime updatedAt, List<SnPublicationPage> pages
});




}
/// @nodoc
class __$SnPublicationSiteCopyWithImpl<$Res>
    implements _$SnPublicationSiteCopyWith<$Res> {
  __$SnPublicationSiteCopyWithImpl(this._self, this._then);

  final _SnPublicationSite _self;
  final $Res Function(_SnPublicationSite) _then;

/// Create a copy of SnPublicationSite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = freezed,Object? publisherId = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? pages = null,}) {
  return _then(_SnPublicationSite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pages: null == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as List<SnPublicationPage>,
  ));
}


}


/// @nodoc
mixin _$SnPublicationPage {

 String get id; String? get preset; String? get path; Map<String, dynamic>? get config; String get siteId; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SnPublicationPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublicationPageCopyWith<SnPublicationPage> get copyWith => _$SnPublicationPageCopyWithImpl<SnPublicationPage>(this as SnPublicationPage, _$identity);

  /// Serializes this SnPublicationPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublicationPage&&(identical(other.id, id) || other.id == id)&&(identical(other.preset, preset) || other.preset == preset)&&(identical(other.path, path) || other.path == path)&&const DeepCollectionEquality().equals(other.config, config)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,preset,path,const DeepCollectionEquality().hash(config),siteId,createdAt,updatedAt);

@override
String toString() {
  return 'SnPublicationPage(id: $id, preset: $preset, path: $path, config: $config, siteId: $siteId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SnPublicationPageCopyWith<$Res>  {
  factory $SnPublicationPageCopyWith(SnPublicationPage value, $Res Function(SnPublicationPage) _then) = _$SnPublicationPageCopyWithImpl;
@useResult
$Res call({
 String id, String? preset, String? path, Map<String, dynamic>? config, String siteId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SnPublicationPageCopyWithImpl<$Res>
    implements $SnPublicationPageCopyWith<$Res> {
  _$SnPublicationPageCopyWithImpl(this._self, this._then);

  final SnPublicationPage _self;
  final $Res Function(SnPublicationPage) _then;

/// Create a copy of SnPublicationPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? preset = freezed,Object? path = freezed,Object? config = freezed,Object? siteId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,preset: freezed == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPublicationPage].
extension SnPublicationPagePatterns on SnPublicationPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublicationPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublicationPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublicationPage value)  $default,){
final _that = this;
switch (_that) {
case _SnPublicationPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublicationPage value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublicationPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? preset,  String? path,  Map<String, dynamic>? config,  String siteId,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublicationPage() when $default != null:
return $default(_that.id,_that.preset,_that.path,_that.config,_that.siteId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? preset,  String? path,  Map<String, dynamic>? config,  String siteId,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPublicationPage():
return $default(_that.id,_that.preset,_that.path,_that.config,_that.siteId,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? preset,  String? path,  Map<String, dynamic>? config,  String siteId,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPublicationPage() when $default != null:
return $default(_that.id,_that.preset,_that.path,_that.config,_that.siteId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublicationPage implements SnPublicationPage {
  const _SnPublicationPage({required this.id, this.preset, this.path, final  Map<String, dynamic>? config, required this.siteId, required this.createdAt, required this.updatedAt}): _config = config;
  factory _SnPublicationPage.fromJson(Map<String, dynamic> json) => _$SnPublicationPageFromJson(json);

@override final  String id;
@override final  String? preset;
@override final  String? path;
 final  Map<String, dynamic>? _config;
@override Map<String, dynamic>? get config {
  final value = _config;
  if (value == null) return null;
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String siteId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SnPublicationPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublicationPageCopyWith<_SnPublicationPage> get copyWith => __$SnPublicationPageCopyWithImpl<_SnPublicationPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublicationPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublicationPage&&(identical(other.id, id) || other.id == id)&&(identical(other.preset, preset) || other.preset == preset)&&(identical(other.path, path) || other.path == path)&&const DeepCollectionEquality().equals(other._config, _config)&&(identical(other.siteId, siteId) || other.siteId == siteId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,preset,path,const DeepCollectionEquality().hash(_config),siteId,createdAt,updatedAt);

@override
String toString() {
  return 'SnPublicationPage(id: $id, preset: $preset, path: $path, config: $config, siteId: $siteId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPublicationPageCopyWith<$Res> implements $SnPublicationPageCopyWith<$Res> {
  factory _$SnPublicationPageCopyWith(_SnPublicationPage value, $Res Function(_SnPublicationPage) _then) = __$SnPublicationPageCopyWithImpl;
@override @useResult
$Res call({
 String id, String? preset, String? path, Map<String, dynamic>? config, String siteId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SnPublicationPageCopyWithImpl<$Res>
    implements _$SnPublicationPageCopyWith<$Res> {
  __$SnPublicationPageCopyWithImpl(this._self, this._then);

  final _SnPublicationPage _self;
  final $Res Function(_SnPublicationPage) _then;

/// Create a copy of SnPublicationPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? preset = freezed,Object? path = freezed,Object? config = freezed,Object? siteId = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SnPublicationPage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,preset: freezed == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as String?,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,config: freezed == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,siteId: null == siteId ? _self.siteId : siteId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
