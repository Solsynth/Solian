// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RouteItem {

 String get name; String get path; String get description; IconData get icon;
/// Create a copy of RouteItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteItemCopyWith<RouteItem> get copyWith => _$RouteItemCopyWithImpl<RouteItem>(this as RouteItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteItem&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon));
}


@override
int get hashCode => Object.hash(runtimeType,name,path,description,icon);

@override
String toString() {
  return 'RouteItem(name: $name, path: $path, description: $description, icon: $icon)';
}


}

/// @nodoc
abstract mixin class $RouteItemCopyWith<$Res>  {
  factory $RouteItemCopyWith(RouteItem value, $Res Function(RouteItem) _then) = _$RouteItemCopyWithImpl;
@useResult
$Res call({
 String name, String path, String description, IconData icon
});




}
/// @nodoc
class _$RouteItemCopyWithImpl<$Res>
    implements $RouteItemCopyWith<$Res> {
  _$RouteItemCopyWithImpl(this._self, this._then);

  final RouteItem _self;
  final $Res Function(RouteItem) _then;

/// Create a copy of RouteItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? path = null,Object? description = null,Object? icon = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteItem].
extension RouteItemPatterns on RouteItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteItem value)  $default,){
final _that = this;
switch (_that) {
case _RouteItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteItem value)?  $default,){
final _that = this;
switch (_that) {
case _RouteItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String path,  String description,  IconData icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteItem() when $default != null:
return $default(_that.name,_that.path,_that.description,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String path,  String description,  IconData icon)  $default,) {final _that = this;
switch (_that) {
case _RouteItem():
return $default(_that.name,_that.path,_that.description,_that.icon);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String path,  String description,  IconData icon)?  $default,) {final _that = this;
switch (_that) {
case _RouteItem() when $default != null:
return $default(_that.name,_that.path,_that.description,_that.icon);case _:
  return null;

}
}

}

/// @nodoc


class _RouteItem implements RouteItem {
  const _RouteItem({required this.name, required this.path, required this.description, required this.icon});
  

@override final  String name;
@override final  String path;
@override final  String description;
@override final  IconData icon;

/// Create a copy of RouteItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteItemCopyWith<_RouteItem> get copyWith => __$RouteItemCopyWithImpl<_RouteItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteItem&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon));
}


@override
int get hashCode => Object.hash(runtimeType,name,path,description,icon);

@override
String toString() {
  return 'RouteItem(name: $name, path: $path, description: $description, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$RouteItemCopyWith<$Res> implements $RouteItemCopyWith<$Res> {
  factory _$RouteItemCopyWith(_RouteItem value, $Res Function(_RouteItem) _then) = __$RouteItemCopyWithImpl;
@override @useResult
$Res call({
 String name, String path, String description, IconData icon
});




}
/// @nodoc
class __$RouteItemCopyWithImpl<$Res>
    implements _$RouteItemCopyWith<$Res> {
  __$RouteItemCopyWithImpl(this._self, this._then);

  final _RouteItem _self;
  final $Res Function(_RouteItem) _then;

/// Create a copy of RouteItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? path = null,Object? description = null,Object? icon = null,}) {
  return _then(_RouteItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,
  ));
}


}

// dart format on
