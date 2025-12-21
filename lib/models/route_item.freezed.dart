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

 String get name; String get path; String get description; List<String> get searchableAliases; IconData get icon;
/// Create a copy of RouteItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteItemCopyWith<RouteItem> get copyWith => _$RouteItemCopyWithImpl<RouteItem>(this as RouteItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteItem&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.searchableAliases, searchableAliases)&&(identical(other.icon, icon) || other.icon == icon));
}


@override
int get hashCode => Object.hash(runtimeType,name,path,description,const DeepCollectionEquality().hash(searchableAliases),icon);

@override
String toString() {
  return 'RouteItem(name: $name, path: $path, description: $description, searchableAliases: $searchableAliases, icon: $icon)';
}


}

/// @nodoc
abstract mixin class $RouteItemCopyWith<$Res>  {
  factory $RouteItemCopyWith(RouteItem value, $Res Function(RouteItem) _then) = _$RouteItemCopyWithImpl;
@useResult
$Res call({
 String name, String path, String description, List<String> searchableAliases, IconData icon
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? path = null,Object? description = null,Object? searchableAliases = null,Object? icon = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,searchableAliases: null == searchableAliases ? _self.searchableAliases : searchableAliases // ignore: cast_nullable_to_non_nullable
as List<String>,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String path,  String description,  List<String> searchableAliases,  IconData icon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteItem() when $default != null:
return $default(_that.name,_that.path,_that.description,_that.searchableAliases,_that.icon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String path,  String description,  List<String> searchableAliases,  IconData icon)  $default,) {final _that = this;
switch (_that) {
case _RouteItem():
return $default(_that.name,_that.path,_that.description,_that.searchableAliases,_that.icon);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String path,  String description,  List<String> searchableAliases,  IconData icon)?  $default,) {final _that = this;
switch (_that) {
case _RouteItem() when $default != null:
return $default(_that.name,_that.path,_that.description,_that.searchableAliases,_that.icon);case _:
  return null;

}
}

}

/// @nodoc


class _RouteItem implements RouteItem {
  const _RouteItem({required this.name, required this.path, required this.description, final  List<String> searchableAliases = const [], required this.icon}): _searchableAliases = searchableAliases;
  

@override final  String name;
@override final  String path;
@override final  String description;
 final  List<String> _searchableAliases;
@override@JsonKey() List<String> get searchableAliases {
  if (_searchableAliases is EqualUnmodifiableListView) return _searchableAliases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_searchableAliases);
}

@override final  IconData icon;

/// Create a copy of RouteItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteItemCopyWith<_RouteItem> get copyWith => __$RouteItemCopyWithImpl<_RouteItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteItem&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._searchableAliases, _searchableAliases)&&(identical(other.icon, icon) || other.icon == icon));
}


@override
int get hashCode => Object.hash(runtimeType,name,path,description,const DeepCollectionEquality().hash(_searchableAliases),icon);

@override
String toString() {
  return 'RouteItem(name: $name, path: $path, description: $description, searchableAliases: $searchableAliases, icon: $icon)';
}


}

/// @nodoc
abstract mixin class _$RouteItemCopyWith<$Res> implements $RouteItemCopyWith<$Res> {
  factory _$RouteItemCopyWith(_RouteItem value, $Res Function(_RouteItem) _then) = __$RouteItemCopyWithImpl;
@override @useResult
$Res call({
 String name, String path, String description, List<String> searchableAliases, IconData icon
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? path = null,Object? description = null,Object? searchableAliases = null,Object? icon = null,}) {
  return _then(_RouteItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,searchableAliases: null == searchableAliases ? _self._searchableAliases : searchableAliases // ignore: cast_nullable_to_non_nullable
as List<String>,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,
  ));
}


}

/// @nodoc
mixin _$SpecialAction {

 String get name; String get description; IconData get icon; VoidCallback get action; List<String> get searchableAliases;
/// Create a copy of SpecialAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpecialActionCopyWith<SpecialAction> get copyWith => _$SpecialActionCopyWithImpl<SpecialAction>(this as SpecialAction, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpecialAction&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.action, action) || other.action == action)&&const DeepCollectionEquality().equals(other.searchableAliases, searchableAliases));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,icon,action,const DeepCollectionEquality().hash(searchableAliases));

@override
String toString() {
  return 'SpecialAction(name: $name, description: $description, icon: $icon, action: $action, searchableAliases: $searchableAliases)';
}


}

/// @nodoc
abstract mixin class $SpecialActionCopyWith<$Res>  {
  factory $SpecialActionCopyWith(SpecialAction value, $Res Function(SpecialAction) _then) = _$SpecialActionCopyWithImpl;
@useResult
$Res call({
 String name, String description, IconData icon, VoidCallback action, List<String> searchableAliases
});




}
/// @nodoc
class _$SpecialActionCopyWithImpl<$Res>
    implements $SpecialActionCopyWith<$Res> {
  _$SpecialActionCopyWithImpl(this._self, this._then);

  final SpecialAction _self;
  final $Res Function(SpecialAction) _then;

/// Create a copy of SpecialAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? icon = null,Object? action = null,Object? searchableAliases = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as VoidCallback,searchableAliases: null == searchableAliases ? _self.searchableAliases : searchableAliases // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SpecialAction].
extension SpecialActionPatterns on SpecialAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpecialAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpecialAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpecialAction value)  $default,){
final _that = this;
switch (_that) {
case _SpecialAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpecialAction value)?  $default,){
final _that = this;
switch (_that) {
case _SpecialAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  IconData icon,  VoidCallback action,  List<String> searchableAliases)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpecialAction() when $default != null:
return $default(_that.name,_that.description,_that.icon,_that.action,_that.searchableAliases);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  IconData icon,  VoidCallback action,  List<String> searchableAliases)  $default,) {final _that = this;
switch (_that) {
case _SpecialAction():
return $default(_that.name,_that.description,_that.icon,_that.action,_that.searchableAliases);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  IconData icon,  VoidCallback action,  List<String> searchableAliases)?  $default,) {final _that = this;
switch (_that) {
case _SpecialAction() when $default != null:
return $default(_that.name,_that.description,_that.icon,_that.action,_that.searchableAliases);case _:
  return null;

}
}

}

/// @nodoc


class _SpecialAction implements SpecialAction {
  const _SpecialAction({required this.name, required this.description, required this.icon, required this.action, final  List<String> searchableAliases = const []}): _searchableAliases = searchableAliases;
  

@override final  String name;
@override final  String description;
@override final  IconData icon;
@override final  VoidCallback action;
 final  List<String> _searchableAliases;
@override@JsonKey() List<String> get searchableAliases {
  if (_searchableAliases is EqualUnmodifiableListView) return _searchableAliases;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_searchableAliases);
}


/// Create a copy of SpecialAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpecialActionCopyWith<_SpecialAction> get copyWith => __$SpecialActionCopyWithImpl<_SpecialAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpecialAction&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.action, action) || other.action == action)&&const DeepCollectionEquality().equals(other._searchableAliases, _searchableAliases));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,icon,action,const DeepCollectionEquality().hash(_searchableAliases));

@override
String toString() {
  return 'SpecialAction(name: $name, description: $description, icon: $icon, action: $action, searchableAliases: $searchableAliases)';
}


}

/// @nodoc
abstract mixin class _$SpecialActionCopyWith<$Res> implements $SpecialActionCopyWith<$Res> {
  factory _$SpecialActionCopyWith(_SpecialAction value, $Res Function(_SpecialAction) _then) = __$SpecialActionCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, IconData icon, VoidCallback action, List<String> searchableAliases
});




}
/// @nodoc
class __$SpecialActionCopyWithImpl<$Res>
    implements _$SpecialActionCopyWith<$Res> {
  __$SpecialActionCopyWithImpl(this._self, this._then);

  final _SpecialAction _self;
  final $Res Function(_SpecialAction) _then;

/// Create a copy of SpecialAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? icon = null,Object? action = null,Object? searchableAliases = null,}) {
  return _then(_SpecialAction(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as VoidCallback,searchableAliases: null == searchableAliases ? _self._searchableAliases : searchableAliases // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
