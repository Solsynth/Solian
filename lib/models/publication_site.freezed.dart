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
mixin _$SnPublicationSiteNavItems {

 String get label; String get href;
/// Create a copy of SnPublicationSiteNavItems
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublicationSiteNavItemsCopyWith<SnPublicationSiteNavItems> get copyWith => _$SnPublicationSiteNavItemsCopyWithImpl<SnPublicationSiteNavItems>(this as SnPublicationSiteNavItems, _$identity);

  /// Serializes this SnPublicationSiteNavItems to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublicationSiteNavItems&&(identical(other.label, label) || other.label == label)&&(identical(other.href, href) || other.href == href));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,href);

@override
String toString() {
  return 'SnPublicationSiteNavItems(label: $label, href: $href)';
}


}

/// @nodoc
abstract mixin class $SnPublicationSiteNavItemsCopyWith<$Res>  {
  factory $SnPublicationSiteNavItemsCopyWith(SnPublicationSiteNavItems value, $Res Function(SnPublicationSiteNavItems) _then) = _$SnPublicationSiteNavItemsCopyWithImpl;
@useResult
$Res call({
 String label, String href
});




}
/// @nodoc
class _$SnPublicationSiteNavItemsCopyWithImpl<$Res>
    implements $SnPublicationSiteNavItemsCopyWith<$Res> {
  _$SnPublicationSiteNavItemsCopyWithImpl(this._self, this._then);

  final SnPublicationSiteNavItems _self;
  final $Res Function(SnPublicationSiteNavItems) _then;

/// Create a copy of SnPublicationSiteNavItems
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? href = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,href: null == href ? _self.href : href // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPublicationSiteNavItems].
extension SnPublicationSiteNavItemsPatterns on SnPublicationSiteNavItems {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublicationSiteNavItems value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublicationSiteNavItems() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublicationSiteNavItems value)  $default,){
final _that = this;
switch (_that) {
case _SnPublicationSiteNavItems():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublicationSiteNavItems value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublicationSiteNavItems() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String href)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublicationSiteNavItems() when $default != null:
return $default(_that.label,_that.href);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String href)  $default,) {final _that = this;
switch (_that) {
case _SnPublicationSiteNavItems():
return $default(_that.label,_that.href);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String href)?  $default,) {final _that = this;
switch (_that) {
case _SnPublicationSiteNavItems() when $default != null:
return $default(_that.label,_that.href);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublicationSiteNavItems implements SnPublicationSiteNavItems {
  const _SnPublicationSiteNavItems({required this.label, required this.href});
  factory _SnPublicationSiteNavItems.fromJson(Map<String, dynamic> json) => _$SnPublicationSiteNavItemsFromJson(json);

@override final  String label;
@override final  String href;

/// Create a copy of SnPublicationSiteNavItems
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublicationSiteNavItemsCopyWith<_SnPublicationSiteNavItems> get copyWith => __$SnPublicationSiteNavItemsCopyWithImpl<_SnPublicationSiteNavItems>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublicationSiteNavItemsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublicationSiteNavItems&&(identical(other.label, label) || other.label == label)&&(identical(other.href, href) || other.href == href));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,href);

@override
String toString() {
  return 'SnPublicationSiteNavItems(label: $label, href: $href)';
}


}

/// @nodoc
abstract mixin class _$SnPublicationSiteNavItemsCopyWith<$Res> implements $SnPublicationSiteNavItemsCopyWith<$Res> {
  factory _$SnPublicationSiteNavItemsCopyWith(_SnPublicationSiteNavItems value, $Res Function(_SnPublicationSiteNavItems) _then) = __$SnPublicationSiteNavItemsCopyWithImpl;
@override @useResult
$Res call({
 String label, String href
});




}
/// @nodoc
class __$SnPublicationSiteNavItemsCopyWithImpl<$Res>
    implements _$SnPublicationSiteNavItemsCopyWith<$Res> {
  __$SnPublicationSiteNavItemsCopyWithImpl(this._self, this._then);

  final _SnPublicationSiteNavItems _self;
  final $Res Function(_SnPublicationSiteNavItems) _then;

/// Create a copy of SnPublicationSiteNavItems
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? href = null,}) {
  return _then(_SnPublicationSiteNavItems(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,href: null == href ? _self.href : href // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SnPublicationSiteConfig {

 String? get styleOverride; List<SnPublicationSiteNavItems>? get navItems;
/// Create a copy of SnPublicationSiteConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublicationSiteConfigCopyWith<SnPublicationSiteConfig> get copyWith => _$SnPublicationSiteConfigCopyWithImpl<SnPublicationSiteConfig>(this as SnPublicationSiteConfig, _$identity);

  /// Serializes this SnPublicationSiteConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublicationSiteConfig&&(identical(other.styleOverride, styleOverride) || other.styleOverride == styleOverride)&&const DeepCollectionEquality().equals(other.navItems, navItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,styleOverride,const DeepCollectionEquality().hash(navItems));

@override
String toString() {
  return 'SnPublicationSiteConfig(styleOverride: $styleOverride, navItems: $navItems)';
}


}

/// @nodoc
abstract mixin class $SnPublicationSiteConfigCopyWith<$Res>  {
  factory $SnPublicationSiteConfigCopyWith(SnPublicationSiteConfig value, $Res Function(SnPublicationSiteConfig) _then) = _$SnPublicationSiteConfigCopyWithImpl;
@useResult
$Res call({
 String? styleOverride, List<SnPublicationSiteNavItems>? navItems
});




}
/// @nodoc
class _$SnPublicationSiteConfigCopyWithImpl<$Res>
    implements $SnPublicationSiteConfigCopyWith<$Res> {
  _$SnPublicationSiteConfigCopyWithImpl(this._self, this._then);

  final SnPublicationSiteConfig _self;
  final $Res Function(SnPublicationSiteConfig) _then;

/// Create a copy of SnPublicationSiteConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? styleOverride = freezed,Object? navItems = freezed,}) {
  return _then(_self.copyWith(
styleOverride: freezed == styleOverride ? _self.styleOverride : styleOverride // ignore: cast_nullable_to_non_nullable
as String?,navItems: freezed == navItems ? _self.navItems : navItems // ignore: cast_nullable_to_non_nullable
as List<SnPublicationSiteNavItems>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPublicationSiteConfig].
extension SnPublicationSiteConfigPatterns on SnPublicationSiteConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublicationSiteConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublicationSiteConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublicationSiteConfig value)  $default,){
final _that = this;
switch (_that) {
case _SnPublicationSiteConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublicationSiteConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublicationSiteConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? styleOverride,  List<SnPublicationSiteNavItems>? navItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublicationSiteConfig() when $default != null:
return $default(_that.styleOverride,_that.navItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? styleOverride,  List<SnPublicationSiteNavItems>? navItems)  $default,) {final _that = this;
switch (_that) {
case _SnPublicationSiteConfig():
return $default(_that.styleOverride,_that.navItems);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? styleOverride,  List<SnPublicationSiteNavItems>? navItems)?  $default,) {final _that = this;
switch (_that) {
case _SnPublicationSiteConfig() when $default != null:
return $default(_that.styleOverride,_that.navItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublicationSiteConfig implements SnPublicationSiteConfig {
  const _SnPublicationSiteConfig({this.styleOverride, final  List<SnPublicationSiteNavItems>? navItems}): _navItems = navItems;
  factory _SnPublicationSiteConfig.fromJson(Map<String, dynamic> json) => _$SnPublicationSiteConfigFromJson(json);

@override final  String? styleOverride;
 final  List<SnPublicationSiteNavItems>? _navItems;
@override List<SnPublicationSiteNavItems>? get navItems {
  final value = _navItems;
  if (value == null) return null;
  if (_navItems is EqualUnmodifiableListView) return _navItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of SnPublicationSiteConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublicationSiteConfigCopyWith<_SnPublicationSiteConfig> get copyWith => __$SnPublicationSiteConfigCopyWithImpl<_SnPublicationSiteConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublicationSiteConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublicationSiteConfig&&(identical(other.styleOverride, styleOverride) || other.styleOverride == styleOverride)&&const DeepCollectionEquality().equals(other._navItems, _navItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,styleOverride,const DeepCollectionEquality().hash(_navItems));

@override
String toString() {
  return 'SnPublicationSiteConfig(styleOverride: $styleOverride, navItems: $navItems)';
}


}

/// @nodoc
abstract mixin class _$SnPublicationSiteConfigCopyWith<$Res> implements $SnPublicationSiteConfigCopyWith<$Res> {
  factory _$SnPublicationSiteConfigCopyWith(_SnPublicationSiteConfig value, $Res Function(_SnPublicationSiteConfig) _then) = __$SnPublicationSiteConfigCopyWithImpl;
@override @useResult
$Res call({
 String? styleOverride, List<SnPublicationSiteNavItems>? navItems
});




}
/// @nodoc
class __$SnPublicationSiteConfigCopyWithImpl<$Res>
    implements _$SnPublicationSiteConfigCopyWith<$Res> {
  __$SnPublicationSiteConfigCopyWithImpl(this._self, this._then);

  final _SnPublicationSiteConfig _self;
  final $Res Function(_SnPublicationSiteConfig) _then;

/// Create a copy of SnPublicationSiteConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? styleOverride = freezed,Object? navItems = freezed,}) {
  return _then(_SnPublicationSiteConfig(
styleOverride: freezed == styleOverride ? _self.styleOverride : styleOverride // ignore: cast_nullable_to_non_nullable
as String?,navItems: freezed == navItems ? _self._navItems : navItems // ignore: cast_nullable_to_non_nullable
as List<SnPublicationSiteNavItems>?,
  ));
}


}


/// @nodoc
mixin _$SnPublicationSite {

 String get id; String get slug; String get name; String? get description; int? get mode; String get publisherId; String get accountId; DateTime get createdAt; DateTime get updatedAt; List<SnPublicationPage> get pages; SnPublicationSiteConfig get config;
/// Create a copy of SnPublicationSite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublicationSiteCopyWith<SnPublicationSite> get copyWith => _$SnPublicationSiteCopyWithImpl<SnPublicationSite>(this as SnPublicationSite, _$identity);

  /// Serializes this SnPublicationSite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublicationSite&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.pages, pages)&&(identical(other.config, config) || other.config == config));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,mode,publisherId,accountId,createdAt,updatedAt,const DeepCollectionEquality().hash(pages),config);

@override
String toString() {
  return 'SnPublicationSite(id: $id, slug: $slug, name: $name, description: $description, mode: $mode, publisherId: $publisherId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, pages: $pages, config: $config)';
}


}

/// @nodoc
abstract mixin class $SnPublicationSiteCopyWith<$Res>  {
  factory $SnPublicationSiteCopyWith(SnPublicationSite value, $Res Function(SnPublicationSite) _then) = _$SnPublicationSiteCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String name, String? description, int? mode, String publisherId, String accountId, DateTime createdAt, DateTime updatedAt, List<SnPublicationPage> pages, SnPublicationSiteConfig config
});


$SnPublicationSiteConfigCopyWith<$Res> get config;

}
/// @nodoc
class _$SnPublicationSiteCopyWithImpl<$Res>
    implements $SnPublicationSiteCopyWith<$Res> {
  _$SnPublicationSiteCopyWithImpl(this._self, this._then);

  final SnPublicationSite _self;
  final $Res Function(SnPublicationSite) _then;

/// Create a copy of SnPublicationSite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = freezed,Object? mode = freezed,Object? publisherId = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? pages = null,Object? config = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as int?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as List<SnPublicationPage>,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as SnPublicationSiteConfig,
  ));
}
/// Create a copy of SnPublicationSite
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublicationSiteConfigCopyWith<$Res> get config {
  
  return $SnPublicationSiteConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String? description,  int? mode,  String publisherId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  List<SnPublicationPage> pages,  SnPublicationSiteConfig config)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublicationSite() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.mode,_that.publisherId,_that.accountId,_that.createdAt,_that.updatedAt,_that.pages,_that.config);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String? description,  int? mode,  String publisherId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  List<SnPublicationPage> pages,  SnPublicationSiteConfig config)  $default,) {final _that = this;
switch (_that) {
case _SnPublicationSite():
return $default(_that.id,_that.slug,_that.name,_that.description,_that.mode,_that.publisherId,_that.accountId,_that.createdAt,_that.updatedAt,_that.pages,_that.config);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String name,  String? description,  int? mode,  String publisherId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  List<SnPublicationPage> pages,  SnPublicationSiteConfig config)?  $default,) {final _that = this;
switch (_that) {
case _SnPublicationSite() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.mode,_that.publisherId,_that.accountId,_that.createdAt,_that.updatedAt,_that.pages,_that.config);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublicationSite implements SnPublicationSite {
  const _SnPublicationSite({required this.id, required this.slug, required this.name, this.description, this.mode, required this.publisherId, required this.accountId, required this.createdAt, required this.updatedAt, required final  List<SnPublicationPage> pages, required this.config}): _pages = pages;
  factory _SnPublicationSite.fromJson(Map<String, dynamic> json) => _$SnPublicationSiteFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String name;
@override final  String? description;
@override final  int? mode;
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

@override final  SnPublicationSiteConfig config;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublicationSite&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._pages, _pages)&&(identical(other.config, config) || other.config == config));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,mode,publisherId,accountId,createdAt,updatedAt,const DeepCollectionEquality().hash(_pages),config);

@override
String toString() {
  return 'SnPublicationSite(id: $id, slug: $slug, name: $name, description: $description, mode: $mode, publisherId: $publisherId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, pages: $pages, config: $config)';
}


}

/// @nodoc
abstract mixin class _$SnPublicationSiteCopyWith<$Res> implements $SnPublicationSiteCopyWith<$Res> {
  factory _$SnPublicationSiteCopyWith(_SnPublicationSite value, $Res Function(_SnPublicationSite) _then) = __$SnPublicationSiteCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String name, String? description, int? mode, String publisherId, String accountId, DateTime createdAt, DateTime updatedAt, List<SnPublicationPage> pages, SnPublicationSiteConfig config
});


@override $SnPublicationSiteConfigCopyWith<$Res> get config;

}
/// @nodoc
class __$SnPublicationSiteCopyWithImpl<$Res>
    implements _$SnPublicationSiteCopyWith<$Res> {
  __$SnPublicationSiteCopyWithImpl(this._self, this._then);

  final _SnPublicationSite _self;
  final $Res Function(_SnPublicationSite) _then;

/// Create a copy of SnPublicationSite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = freezed,Object? mode = freezed,Object? publisherId = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? pages = null,Object? config = null,}) {
  return _then(_SnPublicationSite(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as int?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,pages: null == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as List<SnPublicationPage>,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as SnPublicationSiteConfig,
  ));
}

/// Create a copy of SnPublicationSite
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublicationSiteConfigCopyWith<$Res> get config {
  
  return $SnPublicationSiteConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
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
