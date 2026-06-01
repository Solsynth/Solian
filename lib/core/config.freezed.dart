// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IpOverride implements DiagnosticableTreeMixin {

 String get ip; int? get port;
/// Create a copy of IpOverride
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpOverrideCopyWith<IpOverride> get copyWith => _$IpOverrideCopyWithImpl<IpOverride>(this as IpOverride, _$identity);

  /// Serializes this IpOverride to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'IpOverride'))
    ..add(DiagnosticsProperty('ip', ip))..add(DiagnosticsProperty('port', port));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpOverride&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.port, port) || other.port == port));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ip,port);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'IpOverride(ip: $ip, port: $port)';
}


}

/// @nodoc
abstract mixin class $IpOverrideCopyWith<$Res>  {
  factory $IpOverrideCopyWith(IpOverride value, $Res Function(IpOverride) _then) = _$IpOverrideCopyWithImpl;
@useResult
$Res call({
 String ip, int? port
});




}
/// @nodoc
class _$IpOverrideCopyWithImpl<$Res>
    implements $IpOverrideCopyWith<$Res> {
  _$IpOverrideCopyWithImpl(this._self, this._then);

  final IpOverride _self;
  final $Res Function(IpOverride) _then;

/// Create a copy of IpOverride
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ip = null,Object? port = freezed,}) {
  return _then(_self.copyWith(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,port: freezed == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [IpOverride].
extension IpOverridePatterns on IpOverride {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpOverride value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpOverride() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpOverride value)  $default,){
final _that = this;
switch (_that) {
case _IpOverride():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpOverride value)?  $default,){
final _that = this;
switch (_that) {
case _IpOverride() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ip,  int? port)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpOverride() when $default != null:
return $default(_that.ip,_that.port);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ip,  int? port)  $default,) {final _that = this;
switch (_that) {
case _IpOverride():
return $default(_that.ip,_that.port);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ip,  int? port)?  $default,) {final _that = this;
switch (_that) {
case _IpOverride() when $default != null:
return $default(_that.ip,_that.port);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IpOverride with DiagnosticableTreeMixin implements IpOverride {
  const _IpOverride({required this.ip, this.port});
  factory _IpOverride.fromJson(Map<String, dynamic> json) => _$IpOverrideFromJson(json);

@override final  String ip;
@override final  int? port;

/// Create a copy of IpOverride
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpOverrideCopyWith<_IpOverride> get copyWith => __$IpOverrideCopyWithImpl<_IpOverride>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IpOverrideToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'IpOverride'))
    ..add(DiagnosticsProperty('ip', ip))..add(DiagnosticsProperty('port', port));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpOverride&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.port, port) || other.port == port));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ip,port);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'IpOverride(ip: $ip, port: $port)';
}


}

/// @nodoc
abstract mixin class _$IpOverrideCopyWith<$Res> implements $IpOverrideCopyWith<$Res> {
  factory _$IpOverrideCopyWith(_IpOverride value, $Res Function(_IpOverride) _then) = __$IpOverrideCopyWithImpl;
@override @useResult
$Res call({
 String ip, int? port
});




}
/// @nodoc
class __$IpOverrideCopyWithImpl<$Res>
    implements _$IpOverrideCopyWith<$Res> {
  __$IpOverrideCopyWithImpl(this._self, this._then);

  final _IpOverride _self;
  final $Res Function(_IpOverride) _then;

/// Create a copy of IpOverride
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? port = freezed,}) {
  return _then(_IpOverride(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,port: freezed == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$IpOverrideSettings implements DiagnosticableTreeMixin {

 bool get enabled; List<IpOverride> get overrides;
/// Create a copy of IpOverrideSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpOverrideSettingsCopyWith<IpOverrideSettings> get copyWith => _$IpOverrideSettingsCopyWithImpl<IpOverrideSettings>(this as IpOverrideSettings, _$identity);

  /// Serializes this IpOverrideSettings to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'IpOverrideSettings'))
    ..add(DiagnosticsProperty('enabled', enabled))..add(DiagnosticsProperty('overrides', overrides));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpOverrideSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&const DeepCollectionEquality().equals(other.overrides, overrides));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,const DeepCollectionEquality().hash(overrides));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'IpOverrideSettings(enabled: $enabled, overrides: $overrides)';
}


}

/// @nodoc
abstract mixin class $IpOverrideSettingsCopyWith<$Res>  {
  factory $IpOverrideSettingsCopyWith(IpOverrideSettings value, $Res Function(IpOverrideSettings) _then) = _$IpOverrideSettingsCopyWithImpl;
@useResult
$Res call({
 bool enabled, List<IpOverride> overrides
});




}
/// @nodoc
class _$IpOverrideSettingsCopyWithImpl<$Res>
    implements $IpOverrideSettingsCopyWith<$Res> {
  _$IpOverrideSettingsCopyWithImpl(this._self, this._then);

  final IpOverrideSettings _self;
  final $Res Function(IpOverrideSettings) _then;

/// Create a copy of IpOverrideSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? overrides = null,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,overrides: null == overrides ? _self.overrides : overrides // ignore: cast_nullable_to_non_nullable
as List<IpOverride>,
  ));
}

}


/// Adds pattern-matching-related methods to [IpOverrideSettings].
extension IpOverrideSettingsPatterns on IpOverrideSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpOverrideSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpOverrideSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpOverrideSettings value)  $default,){
final _that = this;
switch (_that) {
case _IpOverrideSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpOverrideSettings value)?  $default,){
final _that = this;
switch (_that) {
case _IpOverrideSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  List<IpOverride> overrides)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpOverrideSettings() when $default != null:
return $default(_that.enabled,_that.overrides);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  List<IpOverride> overrides)  $default,) {final _that = this;
switch (_that) {
case _IpOverrideSettings():
return $default(_that.enabled,_that.overrides);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  List<IpOverride> overrides)?  $default,) {final _that = this;
switch (_that) {
case _IpOverrideSettings() when $default != null:
return $default(_that.enabled,_that.overrides);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IpOverrideSettings with DiagnosticableTreeMixin implements IpOverrideSettings {
  const _IpOverrideSettings({required this.enabled, required final  List<IpOverride> overrides}): _overrides = overrides;
  factory _IpOverrideSettings.fromJson(Map<String, dynamic> json) => _$IpOverrideSettingsFromJson(json);

@override final  bool enabled;
 final  List<IpOverride> _overrides;
@override List<IpOverride> get overrides {
  if (_overrides is EqualUnmodifiableListView) return _overrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_overrides);
}


/// Create a copy of IpOverrideSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpOverrideSettingsCopyWith<_IpOverrideSettings> get copyWith => __$IpOverrideSettingsCopyWithImpl<_IpOverrideSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IpOverrideSettingsToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'IpOverrideSettings'))
    ..add(DiagnosticsProperty('enabled', enabled))..add(DiagnosticsProperty('overrides', overrides));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpOverrideSettings&&(identical(other.enabled, enabled) || other.enabled == enabled)&&const DeepCollectionEquality().equals(other._overrides, _overrides));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,const DeepCollectionEquality().hash(_overrides));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'IpOverrideSettings(enabled: $enabled, overrides: $overrides)';
}


}

/// @nodoc
abstract mixin class _$IpOverrideSettingsCopyWith<$Res> implements $IpOverrideSettingsCopyWith<$Res> {
  factory _$IpOverrideSettingsCopyWith(_IpOverrideSettings value, $Res Function(_IpOverrideSettings) _then) = __$IpOverrideSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, List<IpOverride> overrides
});




}
/// @nodoc
class __$IpOverrideSettingsCopyWithImpl<$Res>
    implements _$IpOverrideSettingsCopyWith<$Res> {
  __$IpOverrideSettingsCopyWithImpl(this._self, this._then);

  final _IpOverrideSettings _self;
  final $Res Function(_IpOverrideSettings) _then;

/// Create a copy of IpOverrideSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? overrides = null,}) {
  return _then(_IpOverrideSettings(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,overrides: null == overrides ? _self._overrides : overrides // ignore: cast_nullable_to_non_nullable
as List<IpOverride>,
  ));
}


}


/// @nodoc
mixin _$ThemeColors implements DiagnosticableTreeMixin {

 int? get primary; int? get onPrimary; int? get primaryContainer; int? get secondary; int? get onSecondary; int? get secondaryContainer; int? get tertiary; int? get onTertiary; int? get tertiaryContainer; int? get surface; int? get surfaceContainerHighest; int? get background; int? get outline; int? get shadow; int? get error;
/// Create a copy of ThemeColors
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeColorsCopyWith<ThemeColors> get copyWith => _$ThemeColorsCopyWithImpl<ThemeColors>(this as ThemeColors, _$identity);

  /// Serializes this ThemeColors to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ThemeColors'))
    ..add(DiagnosticsProperty('primary', primary))..add(DiagnosticsProperty('onPrimary', onPrimary))..add(DiagnosticsProperty('primaryContainer', primaryContainer))..add(DiagnosticsProperty('secondary', secondary))..add(DiagnosticsProperty('onSecondary', onSecondary))..add(DiagnosticsProperty('secondaryContainer', secondaryContainer))..add(DiagnosticsProperty('tertiary', tertiary))..add(DiagnosticsProperty('onTertiary', onTertiary))..add(DiagnosticsProperty('tertiaryContainer', tertiaryContainer))..add(DiagnosticsProperty('surface', surface))..add(DiagnosticsProperty('surfaceContainerHighest', surfaceContainerHighest))..add(DiagnosticsProperty('background', background))..add(DiagnosticsProperty('outline', outline))..add(DiagnosticsProperty('shadow', shadow))..add(DiagnosticsProperty('error', error));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeColors&&(identical(other.primary, primary) || other.primary == primary)&&(identical(other.onPrimary, onPrimary) || other.onPrimary == onPrimary)&&(identical(other.primaryContainer, primaryContainer) || other.primaryContainer == primaryContainer)&&(identical(other.secondary, secondary) || other.secondary == secondary)&&(identical(other.onSecondary, onSecondary) || other.onSecondary == onSecondary)&&(identical(other.secondaryContainer, secondaryContainer) || other.secondaryContainer == secondaryContainer)&&(identical(other.tertiary, tertiary) || other.tertiary == tertiary)&&(identical(other.onTertiary, onTertiary) || other.onTertiary == onTertiary)&&(identical(other.tertiaryContainer, tertiaryContainer) || other.tertiaryContainer == tertiaryContainer)&&(identical(other.surface, surface) || other.surface == surface)&&(identical(other.surfaceContainerHighest, surfaceContainerHighest) || other.surfaceContainerHighest == surfaceContainerHighest)&&(identical(other.background, background) || other.background == background)&&(identical(other.outline, outline) || other.outline == outline)&&(identical(other.shadow, shadow) || other.shadow == shadow)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primary,onPrimary,primaryContainer,secondary,onSecondary,secondaryContainer,tertiary,onTertiary,tertiaryContainer,surface,surfaceContainerHighest,background,outline,shadow,error);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ThemeColors(primary: $primary, onPrimary: $onPrimary, primaryContainer: $primaryContainer, secondary: $secondary, onSecondary: $onSecondary, secondaryContainer: $secondaryContainer, tertiary: $tertiary, onTertiary: $onTertiary, tertiaryContainer: $tertiaryContainer, surface: $surface, surfaceContainerHighest: $surfaceContainerHighest, background: $background, outline: $outline, shadow: $shadow, error: $error)';
}


}

/// @nodoc
abstract mixin class $ThemeColorsCopyWith<$Res>  {
  factory $ThemeColorsCopyWith(ThemeColors value, $Res Function(ThemeColors) _then) = _$ThemeColorsCopyWithImpl;
@useResult
$Res call({
 int? primary, int? onPrimary, int? primaryContainer, int? secondary, int? onSecondary, int? secondaryContainer, int? tertiary, int? onTertiary, int? tertiaryContainer, int? surface, int? surfaceContainerHighest, int? background, int? outline, int? shadow, int? error
});




}
/// @nodoc
class _$ThemeColorsCopyWithImpl<$Res>
    implements $ThemeColorsCopyWith<$Res> {
  _$ThemeColorsCopyWithImpl(this._self, this._then);

  final ThemeColors _self;
  final $Res Function(ThemeColors) _then;

/// Create a copy of ThemeColors
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primary = freezed,Object? onPrimary = freezed,Object? primaryContainer = freezed,Object? secondary = freezed,Object? onSecondary = freezed,Object? secondaryContainer = freezed,Object? tertiary = freezed,Object? onTertiary = freezed,Object? tertiaryContainer = freezed,Object? surface = freezed,Object? surfaceContainerHighest = freezed,Object? background = freezed,Object? outline = freezed,Object? shadow = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
primary: freezed == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as int?,onPrimary: freezed == onPrimary ? _self.onPrimary : onPrimary // ignore: cast_nullable_to_non_nullable
as int?,primaryContainer: freezed == primaryContainer ? _self.primaryContainer : primaryContainer // ignore: cast_nullable_to_non_nullable
as int?,secondary: freezed == secondary ? _self.secondary : secondary // ignore: cast_nullable_to_non_nullable
as int?,onSecondary: freezed == onSecondary ? _self.onSecondary : onSecondary // ignore: cast_nullable_to_non_nullable
as int?,secondaryContainer: freezed == secondaryContainer ? _self.secondaryContainer : secondaryContainer // ignore: cast_nullable_to_non_nullable
as int?,tertiary: freezed == tertiary ? _self.tertiary : tertiary // ignore: cast_nullable_to_non_nullable
as int?,onTertiary: freezed == onTertiary ? _self.onTertiary : onTertiary // ignore: cast_nullable_to_non_nullable
as int?,tertiaryContainer: freezed == tertiaryContainer ? _self.tertiaryContainer : tertiaryContainer // ignore: cast_nullable_to_non_nullable
as int?,surface: freezed == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as int?,surfaceContainerHighest: freezed == surfaceContainerHighest ? _self.surfaceContainerHighest : surfaceContainerHighest // ignore: cast_nullable_to_non_nullable
as int?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as int?,outline: freezed == outline ? _self.outline : outline // ignore: cast_nullable_to_non_nullable
as int?,shadow: freezed == shadow ? _self.shadow : shadow // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemeColors].
extension ThemeColorsPatterns on ThemeColors {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeColors value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeColors() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeColors value)  $default,){
final _that = this;
switch (_that) {
case _ThemeColors():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeColors value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeColors() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? primary,  int? onPrimary,  int? primaryContainer,  int? secondary,  int? onSecondary,  int? secondaryContainer,  int? tertiary,  int? onTertiary,  int? tertiaryContainer,  int? surface,  int? surfaceContainerHighest,  int? background,  int? outline,  int? shadow,  int? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeColors() when $default != null:
return $default(_that.primary,_that.onPrimary,_that.primaryContainer,_that.secondary,_that.onSecondary,_that.secondaryContainer,_that.tertiary,_that.onTertiary,_that.tertiaryContainer,_that.surface,_that.surfaceContainerHighest,_that.background,_that.outline,_that.shadow,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? primary,  int? onPrimary,  int? primaryContainer,  int? secondary,  int? onSecondary,  int? secondaryContainer,  int? tertiary,  int? onTertiary,  int? tertiaryContainer,  int? surface,  int? surfaceContainerHighest,  int? background,  int? outline,  int? shadow,  int? error)  $default,) {final _that = this;
switch (_that) {
case _ThemeColors():
return $default(_that.primary,_that.onPrimary,_that.primaryContainer,_that.secondary,_that.onSecondary,_that.secondaryContainer,_that.tertiary,_that.onTertiary,_that.tertiaryContainer,_that.surface,_that.surfaceContainerHighest,_that.background,_that.outline,_that.shadow,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? primary,  int? onPrimary,  int? primaryContainer,  int? secondary,  int? onSecondary,  int? secondaryContainer,  int? tertiary,  int? onTertiary,  int? tertiaryContainer,  int? surface,  int? surfaceContainerHighest,  int? background,  int? outline,  int? shadow,  int? error)?  $default,) {final _that = this;
switch (_that) {
case _ThemeColors() when $default != null:
return $default(_that.primary,_that.onPrimary,_that.primaryContainer,_that.secondary,_that.onSecondary,_that.secondaryContainer,_that.tertiary,_that.onTertiary,_that.tertiaryContainer,_that.surface,_that.surfaceContainerHighest,_that.background,_that.outline,_that.shadow,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemeColors with DiagnosticableTreeMixin implements ThemeColors {
   _ThemeColors({this.primary, this.onPrimary, this.primaryContainer, this.secondary, this.onSecondary, this.secondaryContainer, this.tertiary, this.onTertiary, this.tertiaryContainer, this.surface, this.surfaceContainerHighest, this.background, this.outline, this.shadow, this.error});
  factory _ThemeColors.fromJson(Map<String, dynamic> json) => _$ThemeColorsFromJson(json);

@override final  int? primary;
@override final  int? onPrimary;
@override final  int? primaryContainer;
@override final  int? secondary;
@override final  int? onSecondary;
@override final  int? secondaryContainer;
@override final  int? tertiary;
@override final  int? onTertiary;
@override final  int? tertiaryContainer;
@override final  int? surface;
@override final  int? surfaceContainerHighest;
@override final  int? background;
@override final  int? outline;
@override final  int? shadow;
@override final  int? error;

/// Create a copy of ThemeColors
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemeColorsCopyWith<_ThemeColors> get copyWith => __$ThemeColorsCopyWithImpl<_ThemeColors>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThemeColorsToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ThemeColors'))
    ..add(DiagnosticsProperty('primary', primary))..add(DiagnosticsProperty('onPrimary', onPrimary))..add(DiagnosticsProperty('primaryContainer', primaryContainer))..add(DiagnosticsProperty('secondary', secondary))..add(DiagnosticsProperty('onSecondary', onSecondary))..add(DiagnosticsProperty('secondaryContainer', secondaryContainer))..add(DiagnosticsProperty('tertiary', tertiary))..add(DiagnosticsProperty('onTertiary', onTertiary))..add(DiagnosticsProperty('tertiaryContainer', tertiaryContainer))..add(DiagnosticsProperty('surface', surface))..add(DiagnosticsProperty('surfaceContainerHighest', surfaceContainerHighest))..add(DiagnosticsProperty('background', background))..add(DiagnosticsProperty('outline', outline))..add(DiagnosticsProperty('shadow', shadow))..add(DiagnosticsProperty('error', error));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeColors&&(identical(other.primary, primary) || other.primary == primary)&&(identical(other.onPrimary, onPrimary) || other.onPrimary == onPrimary)&&(identical(other.primaryContainer, primaryContainer) || other.primaryContainer == primaryContainer)&&(identical(other.secondary, secondary) || other.secondary == secondary)&&(identical(other.onSecondary, onSecondary) || other.onSecondary == onSecondary)&&(identical(other.secondaryContainer, secondaryContainer) || other.secondaryContainer == secondaryContainer)&&(identical(other.tertiary, tertiary) || other.tertiary == tertiary)&&(identical(other.onTertiary, onTertiary) || other.onTertiary == onTertiary)&&(identical(other.tertiaryContainer, tertiaryContainer) || other.tertiaryContainer == tertiaryContainer)&&(identical(other.surface, surface) || other.surface == surface)&&(identical(other.surfaceContainerHighest, surfaceContainerHighest) || other.surfaceContainerHighest == surfaceContainerHighest)&&(identical(other.background, background) || other.background == background)&&(identical(other.outline, outline) || other.outline == outline)&&(identical(other.shadow, shadow) || other.shadow == shadow)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primary,onPrimary,primaryContainer,secondary,onSecondary,secondaryContainer,tertiary,onTertiary,tertiaryContainer,surface,surfaceContainerHighest,background,outline,shadow,error);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ThemeColors(primary: $primary, onPrimary: $onPrimary, primaryContainer: $primaryContainer, secondary: $secondary, onSecondary: $onSecondary, secondaryContainer: $secondaryContainer, tertiary: $tertiary, onTertiary: $onTertiary, tertiaryContainer: $tertiaryContainer, surface: $surface, surfaceContainerHighest: $surfaceContainerHighest, background: $background, outline: $outline, shadow: $shadow, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ThemeColorsCopyWith<$Res> implements $ThemeColorsCopyWith<$Res> {
  factory _$ThemeColorsCopyWith(_ThemeColors value, $Res Function(_ThemeColors) _then) = __$ThemeColorsCopyWithImpl;
@override @useResult
$Res call({
 int? primary, int? onPrimary, int? primaryContainer, int? secondary, int? onSecondary, int? secondaryContainer, int? tertiary, int? onTertiary, int? tertiaryContainer, int? surface, int? surfaceContainerHighest, int? background, int? outline, int? shadow, int? error
});




}
/// @nodoc
class __$ThemeColorsCopyWithImpl<$Res>
    implements _$ThemeColorsCopyWith<$Res> {
  __$ThemeColorsCopyWithImpl(this._self, this._then);

  final _ThemeColors _self;
  final $Res Function(_ThemeColors) _then;

/// Create a copy of ThemeColors
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primary = freezed,Object? onPrimary = freezed,Object? primaryContainer = freezed,Object? secondary = freezed,Object? onSecondary = freezed,Object? secondaryContainer = freezed,Object? tertiary = freezed,Object? onTertiary = freezed,Object? tertiaryContainer = freezed,Object? surface = freezed,Object? surfaceContainerHighest = freezed,Object? background = freezed,Object? outline = freezed,Object? shadow = freezed,Object? error = freezed,}) {
  return _then(_ThemeColors(
primary: freezed == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as int?,onPrimary: freezed == onPrimary ? _self.onPrimary : onPrimary // ignore: cast_nullable_to_non_nullable
as int?,primaryContainer: freezed == primaryContainer ? _self.primaryContainer : primaryContainer // ignore: cast_nullable_to_non_nullable
as int?,secondary: freezed == secondary ? _self.secondary : secondary // ignore: cast_nullable_to_non_nullable
as int?,onSecondary: freezed == onSecondary ? _self.onSecondary : onSecondary // ignore: cast_nullable_to_non_nullable
as int?,secondaryContainer: freezed == secondaryContainer ? _self.secondaryContainer : secondaryContainer // ignore: cast_nullable_to_non_nullable
as int?,tertiary: freezed == tertiary ? _self.tertiary : tertiary // ignore: cast_nullable_to_non_nullable
as int?,onTertiary: freezed == onTertiary ? _self.onTertiary : onTertiary // ignore: cast_nullable_to_non_nullable
as int?,tertiaryContainer: freezed == tertiaryContainer ? _self.tertiaryContainer : tertiaryContainer // ignore: cast_nullable_to_non_nullable
as int?,surface: freezed == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as int?,surfaceContainerHighest: freezed == surfaceContainerHighest ? _self.surfaceContainerHighest : surfaceContainerHighest // ignore: cast_nullable_to_non_nullable
as int?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as int?,outline: freezed == outline ? _self.outline : outline // ignore: cast_nullable_to_non_nullable
as int?,shadow: freezed == shadow ? _self.shadow : shadow // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$DashboardConfig implements DiagnosticableTreeMixin {

 List<String> get verticalLayouts; List<String> get horizontalLayouts; bool get showSearchBar; bool get showClockAndCountdown; bool get countdownIncludeNotableDays;
/// Create a copy of DashboardConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardConfigCopyWith<DashboardConfig> get copyWith => _$DashboardConfigCopyWithImpl<DashboardConfig>(this as DashboardConfig, _$identity);

  /// Serializes this DashboardConfig to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DashboardConfig'))
    ..add(DiagnosticsProperty('verticalLayouts', verticalLayouts))..add(DiagnosticsProperty('horizontalLayouts', horizontalLayouts))..add(DiagnosticsProperty('showSearchBar', showSearchBar))..add(DiagnosticsProperty('showClockAndCountdown', showClockAndCountdown))..add(DiagnosticsProperty('countdownIncludeNotableDays', countdownIncludeNotableDays));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardConfig&&const DeepCollectionEquality().equals(other.verticalLayouts, verticalLayouts)&&const DeepCollectionEquality().equals(other.horizontalLayouts, horizontalLayouts)&&(identical(other.showSearchBar, showSearchBar) || other.showSearchBar == showSearchBar)&&(identical(other.showClockAndCountdown, showClockAndCountdown) || other.showClockAndCountdown == showClockAndCountdown)&&(identical(other.countdownIncludeNotableDays, countdownIncludeNotableDays) || other.countdownIncludeNotableDays == countdownIncludeNotableDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(verticalLayouts),const DeepCollectionEquality().hash(horizontalLayouts),showSearchBar,showClockAndCountdown,countdownIncludeNotableDays);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DashboardConfig(verticalLayouts: $verticalLayouts, horizontalLayouts: $horizontalLayouts, showSearchBar: $showSearchBar, showClockAndCountdown: $showClockAndCountdown, countdownIncludeNotableDays: $countdownIncludeNotableDays)';
}


}

/// @nodoc
abstract mixin class $DashboardConfigCopyWith<$Res>  {
  factory $DashboardConfigCopyWith(DashboardConfig value, $Res Function(DashboardConfig) _then) = _$DashboardConfigCopyWithImpl;
@useResult
$Res call({
 List<String> verticalLayouts, List<String> horizontalLayouts, bool showSearchBar, bool showClockAndCountdown, bool countdownIncludeNotableDays
});




}
/// @nodoc
class _$DashboardConfigCopyWithImpl<$Res>
    implements $DashboardConfigCopyWith<$Res> {
  _$DashboardConfigCopyWithImpl(this._self, this._then);

  final DashboardConfig _self;
  final $Res Function(DashboardConfig) _then;

/// Create a copy of DashboardConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? verticalLayouts = null,Object? horizontalLayouts = null,Object? showSearchBar = null,Object? showClockAndCountdown = null,Object? countdownIncludeNotableDays = null,}) {
  return _then(_self.copyWith(
verticalLayouts: null == verticalLayouts ? _self.verticalLayouts : verticalLayouts // ignore: cast_nullable_to_non_nullable
as List<String>,horizontalLayouts: null == horizontalLayouts ? _self.horizontalLayouts : horizontalLayouts // ignore: cast_nullable_to_non_nullable
as List<String>,showSearchBar: null == showSearchBar ? _self.showSearchBar : showSearchBar // ignore: cast_nullable_to_non_nullable
as bool,showClockAndCountdown: null == showClockAndCountdown ? _self.showClockAndCountdown : showClockAndCountdown // ignore: cast_nullable_to_non_nullable
as bool,countdownIncludeNotableDays: null == countdownIncludeNotableDays ? _self.countdownIncludeNotableDays : countdownIncludeNotableDays // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardConfig].
extension DashboardConfigPatterns on DashboardConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardConfig value)  $default,){
final _that = this;
switch (_that) {
case _DashboardConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardConfig value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> verticalLayouts,  List<String> horizontalLayouts,  bool showSearchBar,  bool showClockAndCountdown,  bool countdownIncludeNotableDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardConfig() when $default != null:
return $default(_that.verticalLayouts,_that.horizontalLayouts,_that.showSearchBar,_that.showClockAndCountdown,_that.countdownIncludeNotableDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> verticalLayouts,  List<String> horizontalLayouts,  bool showSearchBar,  bool showClockAndCountdown,  bool countdownIncludeNotableDays)  $default,) {final _that = this;
switch (_that) {
case _DashboardConfig():
return $default(_that.verticalLayouts,_that.horizontalLayouts,_that.showSearchBar,_that.showClockAndCountdown,_that.countdownIncludeNotableDays);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> verticalLayouts,  List<String> horizontalLayouts,  bool showSearchBar,  bool showClockAndCountdown,  bool countdownIncludeNotableDays)?  $default,) {final _that = this;
switch (_that) {
case _DashboardConfig() when $default != null:
return $default(_that.verticalLayouts,_that.horizontalLayouts,_that.showSearchBar,_that.showClockAndCountdown,_that.countdownIncludeNotableDays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardConfig with DiagnosticableTreeMixin implements DashboardConfig {
   _DashboardConfig({required final  List<String> verticalLayouts, required final  List<String> horizontalLayouts, required this.showSearchBar, required this.showClockAndCountdown, this.countdownIncludeNotableDays = true}): _verticalLayouts = verticalLayouts,_horizontalLayouts = horizontalLayouts;
  factory _DashboardConfig.fromJson(Map<String, dynamic> json) => _$DashboardConfigFromJson(json);

 final  List<String> _verticalLayouts;
@override List<String> get verticalLayouts {
  if (_verticalLayouts is EqualUnmodifiableListView) return _verticalLayouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_verticalLayouts);
}

 final  List<String> _horizontalLayouts;
@override List<String> get horizontalLayouts {
  if (_horizontalLayouts is EqualUnmodifiableListView) return _horizontalLayouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_horizontalLayouts);
}

@override final  bool showSearchBar;
@override final  bool showClockAndCountdown;
@override@JsonKey() final  bool countdownIncludeNotableDays;

/// Create a copy of DashboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardConfigCopyWith<_DashboardConfig> get copyWith => __$DashboardConfigCopyWithImpl<_DashboardConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardConfigToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DashboardConfig'))
    ..add(DiagnosticsProperty('verticalLayouts', verticalLayouts))..add(DiagnosticsProperty('horizontalLayouts', horizontalLayouts))..add(DiagnosticsProperty('showSearchBar', showSearchBar))..add(DiagnosticsProperty('showClockAndCountdown', showClockAndCountdown))..add(DiagnosticsProperty('countdownIncludeNotableDays', countdownIncludeNotableDays));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardConfig&&const DeepCollectionEquality().equals(other._verticalLayouts, _verticalLayouts)&&const DeepCollectionEquality().equals(other._horizontalLayouts, _horizontalLayouts)&&(identical(other.showSearchBar, showSearchBar) || other.showSearchBar == showSearchBar)&&(identical(other.showClockAndCountdown, showClockAndCountdown) || other.showClockAndCountdown == showClockAndCountdown)&&(identical(other.countdownIncludeNotableDays, countdownIncludeNotableDays) || other.countdownIncludeNotableDays == countdownIncludeNotableDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_verticalLayouts),const DeepCollectionEquality().hash(_horizontalLayouts),showSearchBar,showClockAndCountdown,countdownIncludeNotableDays);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DashboardConfig(verticalLayouts: $verticalLayouts, horizontalLayouts: $horizontalLayouts, showSearchBar: $showSearchBar, showClockAndCountdown: $showClockAndCountdown, countdownIncludeNotableDays: $countdownIncludeNotableDays)';
}


}

/// @nodoc
abstract mixin class _$DashboardConfigCopyWith<$Res> implements $DashboardConfigCopyWith<$Res> {
  factory _$DashboardConfigCopyWith(_DashboardConfig value, $Res Function(_DashboardConfig) _then) = __$DashboardConfigCopyWithImpl;
@override @useResult
$Res call({
 List<String> verticalLayouts, List<String> horizontalLayouts, bool showSearchBar, bool showClockAndCountdown, bool countdownIncludeNotableDays
});




}
/// @nodoc
class __$DashboardConfigCopyWithImpl<$Res>
    implements _$DashboardConfigCopyWith<$Res> {
  __$DashboardConfigCopyWithImpl(this._self, this._then);

  final _DashboardConfig _self;
  final $Res Function(_DashboardConfig) _then;

/// Create a copy of DashboardConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verticalLayouts = null,Object? horizontalLayouts = null,Object? showSearchBar = null,Object? showClockAndCountdown = null,Object? countdownIncludeNotableDays = null,}) {
  return _then(_DashboardConfig(
verticalLayouts: null == verticalLayouts ? _self._verticalLayouts : verticalLayouts // ignore: cast_nullable_to_non_nullable
as List<String>,horizontalLayouts: null == horizontalLayouts ? _self._horizontalLayouts : horizontalLayouts // ignore: cast_nullable_to_non_nullable
as List<String>,showSearchBar: null == showSearchBar ? _self.showSearchBar : showSearchBar // ignore: cast_nullable_to_non_nullable
as bool,showClockAndCountdown: null == showClockAndCountdown ? _self.showClockAndCountdown : showClockAndCountdown // ignore: cast_nullable_to_non_nullable
as bool,countdownIncludeNotableDays: null == countdownIncludeNotableDays ? _self.countdownIncludeNotableDays : countdownIncludeNotableDays // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ExploreSettings implements DiagnosticableTreeMixin {

 String get mode; bool get aggressiveMode; List<String> get selectedPublisherNames; List<String> get selectedCategoryIds; List<String> get selectedTagIds;
/// Create a copy of ExploreSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExploreSettingsCopyWith<ExploreSettings> get copyWith => _$ExploreSettingsCopyWithImpl<ExploreSettings>(this as ExploreSettings, _$identity);

  /// Serializes this ExploreSettings to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ExploreSettings'))
    ..add(DiagnosticsProperty('mode', mode))..add(DiagnosticsProperty('aggressiveMode', aggressiveMode))..add(DiagnosticsProperty('selectedPublisherNames', selectedPublisherNames))..add(DiagnosticsProperty('selectedCategoryIds', selectedCategoryIds))..add(DiagnosticsProperty('selectedTagIds', selectedTagIds));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExploreSettings&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.aggressiveMode, aggressiveMode) || other.aggressiveMode == aggressiveMode)&&const DeepCollectionEquality().equals(other.selectedPublisherNames, selectedPublisherNames)&&const DeepCollectionEquality().equals(other.selectedCategoryIds, selectedCategoryIds)&&const DeepCollectionEquality().equals(other.selectedTagIds, selectedTagIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,aggressiveMode,const DeepCollectionEquality().hash(selectedPublisherNames),const DeepCollectionEquality().hash(selectedCategoryIds),const DeepCollectionEquality().hash(selectedTagIds));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ExploreSettings(mode: $mode, aggressiveMode: $aggressiveMode, selectedPublisherNames: $selectedPublisherNames, selectedCategoryIds: $selectedCategoryIds, selectedTagIds: $selectedTagIds)';
}


}

/// @nodoc
abstract mixin class $ExploreSettingsCopyWith<$Res>  {
  factory $ExploreSettingsCopyWith(ExploreSettings value, $Res Function(ExploreSettings) _then) = _$ExploreSettingsCopyWithImpl;
@useResult
$Res call({
 String mode, bool aggressiveMode, List<String> selectedPublisherNames, List<String> selectedCategoryIds, List<String> selectedTagIds
});




}
/// @nodoc
class _$ExploreSettingsCopyWithImpl<$Res>
    implements $ExploreSettingsCopyWith<$Res> {
  _$ExploreSettingsCopyWithImpl(this._self, this._then);

  final ExploreSettings _self;
  final $Res Function(ExploreSettings) _then;

/// Create a copy of ExploreSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? aggressiveMode = null,Object? selectedPublisherNames = null,Object? selectedCategoryIds = null,Object? selectedTagIds = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,aggressiveMode: null == aggressiveMode ? _self.aggressiveMode : aggressiveMode // ignore: cast_nullable_to_non_nullable
as bool,selectedPublisherNames: null == selectedPublisherNames ? _self.selectedPublisherNames : selectedPublisherNames // ignore: cast_nullable_to_non_nullable
as List<String>,selectedCategoryIds: null == selectedCategoryIds ? _self.selectedCategoryIds : selectedCategoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,selectedTagIds: null == selectedTagIds ? _self.selectedTagIds : selectedTagIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExploreSettings].
extension ExploreSettingsPatterns on ExploreSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExploreSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExploreSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExploreSettings value)  $default,){
final _that = this;
switch (_that) {
case _ExploreSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExploreSettings value)?  $default,){
final _that = this;
switch (_that) {
case _ExploreSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mode,  bool aggressiveMode,  List<String> selectedPublisherNames,  List<String> selectedCategoryIds,  List<String> selectedTagIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExploreSettings() when $default != null:
return $default(_that.mode,_that.aggressiveMode,_that.selectedPublisherNames,_that.selectedCategoryIds,_that.selectedTagIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mode,  bool aggressiveMode,  List<String> selectedPublisherNames,  List<String> selectedCategoryIds,  List<String> selectedTagIds)  $default,) {final _that = this;
switch (_that) {
case _ExploreSettings():
return $default(_that.mode,_that.aggressiveMode,_that.selectedPublisherNames,_that.selectedCategoryIds,_that.selectedTagIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mode,  bool aggressiveMode,  List<String> selectedPublisherNames,  List<String> selectedCategoryIds,  List<String> selectedTagIds)?  $default,) {final _that = this;
switch (_that) {
case _ExploreSettings() when $default != null:
return $default(_that.mode,_that.aggressiveMode,_that.selectedPublisherNames,_that.selectedCategoryIds,_that.selectedTagIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExploreSettings with DiagnosticableTreeMixin implements ExploreSettings {
  const _ExploreSettings({this.mode = 'personalized', this.aggressiveMode = true, final  List<String> selectedPublisherNames = const <String>[], final  List<String> selectedCategoryIds = const <String>[], final  List<String> selectedTagIds = const <String>[]}): _selectedPublisherNames = selectedPublisherNames,_selectedCategoryIds = selectedCategoryIds,_selectedTagIds = selectedTagIds;
  factory _ExploreSettings.fromJson(Map<String, dynamic> json) => _$ExploreSettingsFromJson(json);

@override@JsonKey() final  String mode;
@override@JsonKey() final  bool aggressiveMode;
 final  List<String> _selectedPublisherNames;
@override@JsonKey() List<String> get selectedPublisherNames {
  if (_selectedPublisherNames is EqualUnmodifiableListView) return _selectedPublisherNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedPublisherNames);
}

 final  List<String> _selectedCategoryIds;
@override@JsonKey() List<String> get selectedCategoryIds {
  if (_selectedCategoryIds is EqualUnmodifiableListView) return _selectedCategoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedCategoryIds);
}

 final  List<String> _selectedTagIds;
@override@JsonKey() List<String> get selectedTagIds {
  if (_selectedTagIds is EqualUnmodifiableListView) return _selectedTagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedTagIds);
}


/// Create a copy of ExploreSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExploreSettingsCopyWith<_ExploreSettings> get copyWith => __$ExploreSettingsCopyWithImpl<_ExploreSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExploreSettingsToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ExploreSettings'))
    ..add(DiagnosticsProperty('mode', mode))..add(DiagnosticsProperty('aggressiveMode', aggressiveMode))..add(DiagnosticsProperty('selectedPublisherNames', selectedPublisherNames))..add(DiagnosticsProperty('selectedCategoryIds', selectedCategoryIds))..add(DiagnosticsProperty('selectedTagIds', selectedTagIds));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExploreSettings&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.aggressiveMode, aggressiveMode) || other.aggressiveMode == aggressiveMode)&&const DeepCollectionEquality().equals(other._selectedPublisherNames, _selectedPublisherNames)&&const DeepCollectionEquality().equals(other._selectedCategoryIds, _selectedCategoryIds)&&const DeepCollectionEquality().equals(other._selectedTagIds, _selectedTagIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,aggressiveMode,const DeepCollectionEquality().hash(_selectedPublisherNames),const DeepCollectionEquality().hash(_selectedCategoryIds),const DeepCollectionEquality().hash(_selectedTagIds));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ExploreSettings(mode: $mode, aggressiveMode: $aggressiveMode, selectedPublisherNames: $selectedPublisherNames, selectedCategoryIds: $selectedCategoryIds, selectedTagIds: $selectedTagIds)';
}


}

/// @nodoc
abstract mixin class _$ExploreSettingsCopyWith<$Res> implements $ExploreSettingsCopyWith<$Res> {
  factory _$ExploreSettingsCopyWith(_ExploreSettings value, $Res Function(_ExploreSettings) _then) = __$ExploreSettingsCopyWithImpl;
@override @useResult
$Res call({
 String mode, bool aggressiveMode, List<String> selectedPublisherNames, List<String> selectedCategoryIds, List<String> selectedTagIds
});




}
/// @nodoc
class __$ExploreSettingsCopyWithImpl<$Res>
    implements _$ExploreSettingsCopyWith<$Res> {
  __$ExploreSettingsCopyWithImpl(this._self, this._then);

  final _ExploreSettings _self;
  final $Res Function(_ExploreSettings) _then;

/// Create a copy of ExploreSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? aggressiveMode = null,Object? selectedPublisherNames = null,Object? selectedCategoryIds = null,Object? selectedTagIds = null,}) {
  return _then(_ExploreSettings(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,aggressiveMode: null == aggressiveMode ? _self.aggressiveMode : aggressiveMode // ignore: cast_nullable_to_non_nullable
as bool,selectedPublisherNames: null == selectedPublisherNames ? _self._selectedPublisherNames : selectedPublisherNames // ignore: cast_nullable_to_non_nullable
as List<String>,selectedCategoryIds: null == selectedCategoryIds ? _self._selectedCategoryIds : selectedCategoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,selectedTagIds: null == selectedTagIds ? _self._selectedTagIds : selectedTagIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$AppSettings implements DiagnosticableTreeMixin {

 bool get dataSavingMode; bool get soundEffects; bool get festivalFeatures; bool get enterToSend; bool get appBarTransparent; bool get showBackgroundImage; bool get notifyWithHaptic; bool get enableTts; String? get ttsVoice; double get ttsSpeechRate; double get ttsPitch; double get ttsVolume; String get ttsLanguage; String? get customFonts; int? get appColorScheme;// The color stored via the int type
 ThemeColors? get customColors; Size? get windowSize;// The window size for desktop platforms
 double get windowOpacity;// The window opacity for desktop platforms
 double get cardTransparency;// The card background opacity
 String? get defaultPoolId; String get messageDisplayStyle; String get attachmentsListStyle; String get linkCollapseMode; String? get themeMode; bool get disableAnimation; bool get groupedChatList; String? get firstLaunchAt; bool get askedReview; String? get dashSearchEngine; String? get defaultScreen; String get realmDisplayMode; String get chatEventMessageMode; bool get showChatSystemMessages; DashboardConfig? get dashboardConfig; ExploreSettings get exploreSettings; bool get mediaProxyEnabled; bool get friendStatusDesktopNotification;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AppSettings'))
    ..add(DiagnosticsProperty('dataSavingMode', dataSavingMode))..add(DiagnosticsProperty('soundEffects', soundEffects))..add(DiagnosticsProperty('festivalFeatures', festivalFeatures))..add(DiagnosticsProperty('enterToSend', enterToSend))..add(DiagnosticsProperty('appBarTransparent', appBarTransparent))..add(DiagnosticsProperty('showBackgroundImage', showBackgroundImage))..add(DiagnosticsProperty('notifyWithHaptic', notifyWithHaptic))..add(DiagnosticsProperty('enableTts', enableTts))..add(DiagnosticsProperty('ttsVoice', ttsVoice))..add(DiagnosticsProperty('ttsSpeechRate', ttsSpeechRate))..add(DiagnosticsProperty('ttsPitch', ttsPitch))..add(DiagnosticsProperty('ttsVolume', ttsVolume))..add(DiagnosticsProperty('ttsLanguage', ttsLanguage))..add(DiagnosticsProperty('customFonts', customFonts))..add(DiagnosticsProperty('appColorScheme', appColorScheme))..add(DiagnosticsProperty('customColors', customColors))..add(DiagnosticsProperty('windowSize', windowSize))..add(DiagnosticsProperty('windowOpacity', windowOpacity))..add(DiagnosticsProperty('cardTransparency', cardTransparency))..add(DiagnosticsProperty('defaultPoolId', defaultPoolId))..add(DiagnosticsProperty('messageDisplayStyle', messageDisplayStyle))..add(DiagnosticsProperty('attachmentsListStyle', attachmentsListStyle))..add(DiagnosticsProperty('linkCollapseMode', linkCollapseMode))..add(DiagnosticsProperty('themeMode', themeMode))..add(DiagnosticsProperty('disableAnimation', disableAnimation))..add(DiagnosticsProperty('groupedChatList', groupedChatList))..add(DiagnosticsProperty('firstLaunchAt', firstLaunchAt))..add(DiagnosticsProperty('askedReview', askedReview))..add(DiagnosticsProperty('dashSearchEngine', dashSearchEngine))..add(DiagnosticsProperty('defaultScreen', defaultScreen))..add(DiagnosticsProperty('realmDisplayMode', realmDisplayMode))..add(DiagnosticsProperty('chatEventMessageMode', chatEventMessageMode))..add(DiagnosticsProperty('showChatSystemMessages', showChatSystemMessages))..add(DiagnosticsProperty('dashboardConfig', dashboardConfig))..add(DiagnosticsProperty('exploreSettings', exploreSettings))..add(DiagnosticsProperty('mediaProxyEnabled', mediaProxyEnabled))..add(DiagnosticsProperty('friendStatusDesktopNotification', friendStatusDesktopNotification));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.dataSavingMode, dataSavingMode) || other.dataSavingMode == dataSavingMode)&&(identical(other.soundEffects, soundEffects) || other.soundEffects == soundEffects)&&(identical(other.festivalFeatures, festivalFeatures) || other.festivalFeatures == festivalFeatures)&&(identical(other.enterToSend, enterToSend) || other.enterToSend == enterToSend)&&(identical(other.appBarTransparent, appBarTransparent) || other.appBarTransparent == appBarTransparent)&&(identical(other.showBackgroundImage, showBackgroundImage) || other.showBackgroundImage == showBackgroundImage)&&(identical(other.notifyWithHaptic, notifyWithHaptic) || other.notifyWithHaptic == notifyWithHaptic)&&(identical(other.enableTts, enableTts) || other.enableTts == enableTts)&&(identical(other.ttsVoice, ttsVoice) || other.ttsVoice == ttsVoice)&&(identical(other.ttsSpeechRate, ttsSpeechRate) || other.ttsSpeechRate == ttsSpeechRate)&&(identical(other.ttsPitch, ttsPitch) || other.ttsPitch == ttsPitch)&&(identical(other.ttsVolume, ttsVolume) || other.ttsVolume == ttsVolume)&&(identical(other.ttsLanguage, ttsLanguage) || other.ttsLanguage == ttsLanguage)&&(identical(other.customFonts, customFonts) || other.customFonts == customFonts)&&(identical(other.appColorScheme, appColorScheme) || other.appColorScheme == appColorScheme)&&(identical(other.customColors, customColors) || other.customColors == customColors)&&(identical(other.windowSize, windowSize) || other.windowSize == windowSize)&&(identical(other.windowOpacity, windowOpacity) || other.windowOpacity == windowOpacity)&&(identical(other.cardTransparency, cardTransparency) || other.cardTransparency == cardTransparency)&&(identical(other.defaultPoolId, defaultPoolId) || other.defaultPoolId == defaultPoolId)&&(identical(other.messageDisplayStyle, messageDisplayStyle) || other.messageDisplayStyle == messageDisplayStyle)&&(identical(other.attachmentsListStyle, attachmentsListStyle) || other.attachmentsListStyle == attachmentsListStyle)&&(identical(other.linkCollapseMode, linkCollapseMode) || other.linkCollapseMode == linkCollapseMode)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.disableAnimation, disableAnimation) || other.disableAnimation == disableAnimation)&&(identical(other.groupedChatList, groupedChatList) || other.groupedChatList == groupedChatList)&&(identical(other.firstLaunchAt, firstLaunchAt) || other.firstLaunchAt == firstLaunchAt)&&(identical(other.askedReview, askedReview) || other.askedReview == askedReview)&&(identical(other.dashSearchEngine, dashSearchEngine) || other.dashSearchEngine == dashSearchEngine)&&(identical(other.defaultScreen, defaultScreen) || other.defaultScreen == defaultScreen)&&(identical(other.realmDisplayMode, realmDisplayMode) || other.realmDisplayMode == realmDisplayMode)&&(identical(other.chatEventMessageMode, chatEventMessageMode) || other.chatEventMessageMode == chatEventMessageMode)&&(identical(other.showChatSystemMessages, showChatSystemMessages) || other.showChatSystemMessages == showChatSystemMessages)&&(identical(other.dashboardConfig, dashboardConfig) || other.dashboardConfig == dashboardConfig)&&(identical(other.exploreSettings, exploreSettings) || other.exploreSettings == exploreSettings)&&(identical(other.mediaProxyEnabled, mediaProxyEnabled) || other.mediaProxyEnabled == mediaProxyEnabled)&&(identical(other.friendStatusDesktopNotification, friendStatusDesktopNotification) || other.friendStatusDesktopNotification == friendStatusDesktopNotification));
}


@override
int get hashCode => Object.hashAll([runtimeType,dataSavingMode,soundEffects,festivalFeatures,enterToSend,appBarTransparent,showBackgroundImage,notifyWithHaptic,enableTts,ttsVoice,ttsSpeechRate,ttsPitch,ttsVolume,ttsLanguage,customFonts,appColorScheme,customColors,windowSize,windowOpacity,cardTransparency,defaultPoolId,messageDisplayStyle,attachmentsListStyle,linkCollapseMode,themeMode,disableAnimation,groupedChatList,firstLaunchAt,askedReview,dashSearchEngine,defaultScreen,realmDisplayMode,chatEventMessageMode,showChatSystemMessages,dashboardConfig,exploreSettings,mediaProxyEnabled,friendStatusDesktopNotification]);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AppSettings(dataSavingMode: $dataSavingMode, soundEffects: $soundEffects, festivalFeatures: $festivalFeatures, enterToSend: $enterToSend, appBarTransparent: $appBarTransparent, showBackgroundImage: $showBackgroundImage, notifyWithHaptic: $notifyWithHaptic, enableTts: $enableTts, ttsVoice: $ttsVoice, ttsSpeechRate: $ttsSpeechRate, ttsPitch: $ttsPitch, ttsVolume: $ttsVolume, ttsLanguage: $ttsLanguage, customFonts: $customFonts, appColorScheme: $appColorScheme, customColors: $customColors, windowSize: $windowSize, windowOpacity: $windowOpacity, cardTransparency: $cardTransparency, defaultPoolId: $defaultPoolId, messageDisplayStyle: $messageDisplayStyle, attachmentsListStyle: $attachmentsListStyle, linkCollapseMode: $linkCollapseMode, themeMode: $themeMode, disableAnimation: $disableAnimation, groupedChatList: $groupedChatList, firstLaunchAt: $firstLaunchAt, askedReview: $askedReview, dashSearchEngine: $dashSearchEngine, defaultScreen: $defaultScreen, realmDisplayMode: $realmDisplayMode, chatEventMessageMode: $chatEventMessageMode, showChatSystemMessages: $showChatSystemMessages, dashboardConfig: $dashboardConfig, exploreSettings: $exploreSettings, mediaProxyEnabled: $mediaProxyEnabled, friendStatusDesktopNotification: $friendStatusDesktopNotification)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 bool dataSavingMode, bool soundEffects, bool festivalFeatures, bool enterToSend, bool appBarTransparent, bool showBackgroundImage, bool notifyWithHaptic, bool enableTts, String? ttsVoice, double ttsSpeechRate, double ttsPitch, double ttsVolume, String ttsLanguage, String? customFonts, int? appColorScheme, ThemeColors? customColors, Size? windowSize, double windowOpacity, double cardTransparency, String? defaultPoolId, String messageDisplayStyle, String attachmentsListStyle, String linkCollapseMode, String? themeMode, bool disableAnimation, bool groupedChatList, String? firstLaunchAt, bool askedReview, String? dashSearchEngine, String? defaultScreen, String realmDisplayMode, String chatEventMessageMode, bool showChatSystemMessages, DashboardConfig? dashboardConfig, ExploreSettings exploreSettings, bool mediaProxyEnabled, bool friendStatusDesktopNotification
});


$ThemeColorsCopyWith<$Res>? get customColors;$DashboardConfigCopyWith<$Res>? get dashboardConfig;$ExploreSettingsCopyWith<$Res> get exploreSettings;

}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dataSavingMode = null,Object? soundEffects = null,Object? festivalFeatures = null,Object? enterToSend = null,Object? appBarTransparent = null,Object? showBackgroundImage = null,Object? notifyWithHaptic = null,Object? enableTts = null,Object? ttsVoice = freezed,Object? ttsSpeechRate = null,Object? ttsPitch = null,Object? ttsVolume = null,Object? ttsLanguage = null,Object? customFonts = freezed,Object? appColorScheme = freezed,Object? customColors = freezed,Object? windowSize = freezed,Object? windowOpacity = null,Object? cardTransparency = null,Object? defaultPoolId = freezed,Object? messageDisplayStyle = null,Object? attachmentsListStyle = null,Object? linkCollapseMode = null,Object? themeMode = freezed,Object? disableAnimation = null,Object? groupedChatList = null,Object? firstLaunchAt = freezed,Object? askedReview = null,Object? dashSearchEngine = freezed,Object? defaultScreen = freezed,Object? realmDisplayMode = null,Object? chatEventMessageMode = null,Object? showChatSystemMessages = null,Object? dashboardConfig = freezed,Object? exploreSettings = null,Object? mediaProxyEnabled = null,Object? friendStatusDesktopNotification = null,}) {
  return _then(_self.copyWith(
dataSavingMode: null == dataSavingMode ? _self.dataSavingMode : dataSavingMode // ignore: cast_nullable_to_non_nullable
as bool,soundEffects: null == soundEffects ? _self.soundEffects : soundEffects // ignore: cast_nullable_to_non_nullable
as bool,festivalFeatures: null == festivalFeatures ? _self.festivalFeatures : festivalFeatures // ignore: cast_nullable_to_non_nullable
as bool,enterToSend: null == enterToSend ? _self.enterToSend : enterToSend // ignore: cast_nullable_to_non_nullable
as bool,appBarTransparent: null == appBarTransparent ? _self.appBarTransparent : appBarTransparent // ignore: cast_nullable_to_non_nullable
as bool,showBackgroundImage: null == showBackgroundImage ? _self.showBackgroundImage : showBackgroundImage // ignore: cast_nullable_to_non_nullable
as bool,notifyWithHaptic: null == notifyWithHaptic ? _self.notifyWithHaptic : notifyWithHaptic // ignore: cast_nullable_to_non_nullable
as bool,enableTts: null == enableTts ? _self.enableTts : enableTts // ignore: cast_nullable_to_non_nullable
as bool,ttsVoice: freezed == ttsVoice ? _self.ttsVoice : ttsVoice // ignore: cast_nullable_to_non_nullable
as String?,ttsSpeechRate: null == ttsSpeechRate ? _self.ttsSpeechRate : ttsSpeechRate // ignore: cast_nullable_to_non_nullable
as double,ttsPitch: null == ttsPitch ? _self.ttsPitch : ttsPitch // ignore: cast_nullable_to_non_nullable
as double,ttsVolume: null == ttsVolume ? _self.ttsVolume : ttsVolume // ignore: cast_nullable_to_non_nullable
as double,ttsLanguage: null == ttsLanguage ? _self.ttsLanguage : ttsLanguage // ignore: cast_nullable_to_non_nullable
as String,customFonts: freezed == customFonts ? _self.customFonts : customFonts // ignore: cast_nullable_to_non_nullable
as String?,appColorScheme: freezed == appColorScheme ? _self.appColorScheme : appColorScheme // ignore: cast_nullable_to_non_nullable
as int?,customColors: freezed == customColors ? _self.customColors : customColors // ignore: cast_nullable_to_non_nullable
as ThemeColors?,windowSize: freezed == windowSize ? _self.windowSize : windowSize // ignore: cast_nullable_to_non_nullable
as Size?,windowOpacity: null == windowOpacity ? _self.windowOpacity : windowOpacity // ignore: cast_nullable_to_non_nullable
as double,cardTransparency: null == cardTransparency ? _self.cardTransparency : cardTransparency // ignore: cast_nullable_to_non_nullable
as double,defaultPoolId: freezed == defaultPoolId ? _self.defaultPoolId : defaultPoolId // ignore: cast_nullable_to_non_nullable
as String?,messageDisplayStyle: null == messageDisplayStyle ? _self.messageDisplayStyle : messageDisplayStyle // ignore: cast_nullable_to_non_nullable
as String,attachmentsListStyle: null == attachmentsListStyle ? _self.attachmentsListStyle : attachmentsListStyle // ignore: cast_nullable_to_non_nullable
as String,linkCollapseMode: null == linkCollapseMode ? _self.linkCollapseMode : linkCollapseMode // ignore: cast_nullable_to_non_nullable
as String,themeMode: freezed == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String?,disableAnimation: null == disableAnimation ? _self.disableAnimation : disableAnimation // ignore: cast_nullable_to_non_nullable
as bool,groupedChatList: null == groupedChatList ? _self.groupedChatList : groupedChatList // ignore: cast_nullable_to_non_nullable
as bool,firstLaunchAt: freezed == firstLaunchAt ? _self.firstLaunchAt : firstLaunchAt // ignore: cast_nullable_to_non_nullable
as String?,askedReview: null == askedReview ? _self.askedReview : askedReview // ignore: cast_nullable_to_non_nullable
as bool,dashSearchEngine: freezed == dashSearchEngine ? _self.dashSearchEngine : dashSearchEngine // ignore: cast_nullable_to_non_nullable
as String?,defaultScreen: freezed == defaultScreen ? _self.defaultScreen : defaultScreen // ignore: cast_nullable_to_non_nullable
as String?,realmDisplayMode: null == realmDisplayMode ? _self.realmDisplayMode : realmDisplayMode // ignore: cast_nullable_to_non_nullable
as String,chatEventMessageMode: null == chatEventMessageMode ? _self.chatEventMessageMode : chatEventMessageMode // ignore: cast_nullable_to_non_nullable
as String,showChatSystemMessages: null == showChatSystemMessages ? _self.showChatSystemMessages : showChatSystemMessages // ignore: cast_nullable_to_non_nullable
as bool,dashboardConfig: freezed == dashboardConfig ? _self.dashboardConfig : dashboardConfig // ignore: cast_nullable_to_non_nullable
as DashboardConfig?,exploreSettings: null == exploreSettings ? _self.exploreSettings : exploreSettings // ignore: cast_nullable_to_non_nullable
as ExploreSettings,mediaProxyEnabled: null == mediaProxyEnabled ? _self.mediaProxyEnabled : mediaProxyEnabled // ignore: cast_nullable_to_non_nullable
as bool,friendStatusDesktopNotification: null == friendStatusDesktopNotification ? _self.friendStatusDesktopNotification : friendStatusDesktopNotification // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemeColorsCopyWith<$Res>? get customColors {
    if (_self.customColors == null) {
    return null;
  }

  return $ThemeColorsCopyWith<$Res>(_self.customColors!, (value) {
    return _then(_self.copyWith(customColors: value));
  });
}/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardConfigCopyWith<$Res>? get dashboardConfig {
    if (_self.dashboardConfig == null) {
    return null;
  }

  return $DashboardConfigCopyWith<$Res>(_self.dashboardConfig!, (value) {
    return _then(_self.copyWith(dashboardConfig: value));
  });
}/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExploreSettingsCopyWith<$Res> get exploreSettings {
  
  return $ExploreSettingsCopyWith<$Res>(_self.exploreSettings, (value) {
    return _then(_self.copyWith(exploreSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool dataSavingMode,  bool soundEffects,  bool festivalFeatures,  bool enterToSend,  bool appBarTransparent,  bool showBackgroundImage,  bool notifyWithHaptic,  bool enableTts,  String? ttsVoice,  double ttsSpeechRate,  double ttsPitch,  double ttsVolume,  String ttsLanguage,  String? customFonts,  int? appColorScheme,  ThemeColors? customColors,  Size? windowSize,  double windowOpacity,  double cardTransparency,  String? defaultPoolId,  String messageDisplayStyle,  String attachmentsListStyle,  String linkCollapseMode,  String? themeMode,  bool disableAnimation,  bool groupedChatList,  String? firstLaunchAt,  bool askedReview,  String? dashSearchEngine,  String? defaultScreen,  String realmDisplayMode,  String chatEventMessageMode,  bool showChatSystemMessages,  DashboardConfig? dashboardConfig,  ExploreSettings exploreSettings,  bool mediaProxyEnabled,  bool friendStatusDesktopNotification)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.dataSavingMode,_that.soundEffects,_that.festivalFeatures,_that.enterToSend,_that.appBarTransparent,_that.showBackgroundImage,_that.notifyWithHaptic,_that.enableTts,_that.ttsVoice,_that.ttsSpeechRate,_that.ttsPitch,_that.ttsVolume,_that.ttsLanguage,_that.customFonts,_that.appColorScheme,_that.customColors,_that.windowSize,_that.windowOpacity,_that.cardTransparency,_that.defaultPoolId,_that.messageDisplayStyle,_that.attachmentsListStyle,_that.linkCollapseMode,_that.themeMode,_that.disableAnimation,_that.groupedChatList,_that.firstLaunchAt,_that.askedReview,_that.dashSearchEngine,_that.defaultScreen,_that.realmDisplayMode,_that.chatEventMessageMode,_that.showChatSystemMessages,_that.dashboardConfig,_that.exploreSettings,_that.mediaProxyEnabled,_that.friendStatusDesktopNotification);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool dataSavingMode,  bool soundEffects,  bool festivalFeatures,  bool enterToSend,  bool appBarTransparent,  bool showBackgroundImage,  bool notifyWithHaptic,  bool enableTts,  String? ttsVoice,  double ttsSpeechRate,  double ttsPitch,  double ttsVolume,  String ttsLanguage,  String? customFonts,  int? appColorScheme,  ThemeColors? customColors,  Size? windowSize,  double windowOpacity,  double cardTransparency,  String? defaultPoolId,  String messageDisplayStyle,  String attachmentsListStyle,  String linkCollapseMode,  String? themeMode,  bool disableAnimation,  bool groupedChatList,  String? firstLaunchAt,  bool askedReview,  String? dashSearchEngine,  String? defaultScreen,  String realmDisplayMode,  String chatEventMessageMode,  bool showChatSystemMessages,  DashboardConfig? dashboardConfig,  ExploreSettings exploreSettings,  bool mediaProxyEnabled,  bool friendStatusDesktopNotification)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.dataSavingMode,_that.soundEffects,_that.festivalFeatures,_that.enterToSend,_that.appBarTransparent,_that.showBackgroundImage,_that.notifyWithHaptic,_that.enableTts,_that.ttsVoice,_that.ttsSpeechRate,_that.ttsPitch,_that.ttsVolume,_that.ttsLanguage,_that.customFonts,_that.appColorScheme,_that.customColors,_that.windowSize,_that.windowOpacity,_that.cardTransparency,_that.defaultPoolId,_that.messageDisplayStyle,_that.attachmentsListStyle,_that.linkCollapseMode,_that.themeMode,_that.disableAnimation,_that.groupedChatList,_that.firstLaunchAt,_that.askedReview,_that.dashSearchEngine,_that.defaultScreen,_that.realmDisplayMode,_that.chatEventMessageMode,_that.showChatSystemMessages,_that.dashboardConfig,_that.exploreSettings,_that.mediaProxyEnabled,_that.friendStatusDesktopNotification);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool dataSavingMode,  bool soundEffects,  bool festivalFeatures,  bool enterToSend,  bool appBarTransparent,  bool showBackgroundImage,  bool notifyWithHaptic,  bool enableTts,  String? ttsVoice,  double ttsSpeechRate,  double ttsPitch,  double ttsVolume,  String ttsLanguage,  String? customFonts,  int? appColorScheme,  ThemeColors? customColors,  Size? windowSize,  double windowOpacity,  double cardTransparency,  String? defaultPoolId,  String messageDisplayStyle,  String attachmentsListStyle,  String linkCollapseMode,  String? themeMode,  bool disableAnimation,  bool groupedChatList,  String? firstLaunchAt,  bool askedReview,  String? dashSearchEngine,  String? defaultScreen,  String realmDisplayMode,  String chatEventMessageMode,  bool showChatSystemMessages,  DashboardConfig? dashboardConfig,  ExploreSettings exploreSettings,  bool mediaProxyEnabled,  bool friendStatusDesktopNotification)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.dataSavingMode,_that.soundEffects,_that.festivalFeatures,_that.enterToSend,_that.appBarTransparent,_that.showBackgroundImage,_that.notifyWithHaptic,_that.enableTts,_that.ttsVoice,_that.ttsSpeechRate,_that.ttsPitch,_that.ttsVolume,_that.ttsLanguage,_that.customFonts,_that.appColorScheme,_that.customColors,_that.windowSize,_that.windowOpacity,_that.cardTransparency,_that.defaultPoolId,_that.messageDisplayStyle,_that.attachmentsListStyle,_that.linkCollapseMode,_that.themeMode,_that.disableAnimation,_that.groupedChatList,_that.firstLaunchAt,_that.askedReview,_that.dashSearchEngine,_that.defaultScreen,_that.realmDisplayMode,_that.chatEventMessageMode,_that.showChatSystemMessages,_that.dashboardConfig,_that.exploreSettings,_that.mediaProxyEnabled,_that.friendStatusDesktopNotification);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings with DiagnosticableTreeMixin implements AppSettings {
  const _AppSettings({required this.dataSavingMode, required this.soundEffects, required this.festivalFeatures, required this.enterToSend, required this.appBarTransparent, required this.showBackgroundImage, required this.notifyWithHaptic, required this.enableTts, required this.ttsVoice, required this.ttsSpeechRate, required this.ttsPitch, required this.ttsVolume, required this.ttsLanguage, required this.customFonts, required this.appColorScheme, required this.customColors, required this.windowSize, required this.windowOpacity, required this.cardTransparency, required this.defaultPoolId, required this.messageDisplayStyle, required this.attachmentsListStyle, required this.linkCollapseMode, required this.themeMode, required this.disableAnimation, required this.groupedChatList, required this.firstLaunchAt, required this.askedReview, required this.dashSearchEngine, required this.defaultScreen, required this.realmDisplayMode, required this.chatEventMessageMode, required this.showChatSystemMessages, required this.dashboardConfig, required this.exploreSettings, required this.mediaProxyEnabled, required this.friendStatusDesktopNotification});
  

@override final  bool dataSavingMode;
@override final  bool soundEffects;
@override final  bool festivalFeatures;
@override final  bool enterToSend;
@override final  bool appBarTransparent;
@override final  bool showBackgroundImage;
@override final  bool notifyWithHaptic;
@override final  bool enableTts;
@override final  String? ttsVoice;
@override final  double ttsSpeechRate;
@override final  double ttsPitch;
@override final  double ttsVolume;
@override final  String ttsLanguage;
@override final  String? customFonts;
@override final  int? appColorScheme;
// The color stored via the int type
@override final  ThemeColors? customColors;
@override final  Size? windowSize;
// The window size for desktop platforms
@override final  double windowOpacity;
// The window opacity for desktop platforms
@override final  double cardTransparency;
// The card background opacity
@override final  String? defaultPoolId;
@override final  String messageDisplayStyle;
@override final  String attachmentsListStyle;
@override final  String linkCollapseMode;
@override final  String? themeMode;
@override final  bool disableAnimation;
@override final  bool groupedChatList;
@override final  String? firstLaunchAt;
@override final  bool askedReview;
@override final  String? dashSearchEngine;
@override final  String? defaultScreen;
@override final  String realmDisplayMode;
@override final  String chatEventMessageMode;
@override final  bool showChatSystemMessages;
@override final  DashboardConfig? dashboardConfig;
@override final  ExploreSettings exploreSettings;
@override final  bool mediaProxyEnabled;
@override final  bool friendStatusDesktopNotification;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AppSettings'))
    ..add(DiagnosticsProperty('dataSavingMode', dataSavingMode))..add(DiagnosticsProperty('soundEffects', soundEffects))..add(DiagnosticsProperty('festivalFeatures', festivalFeatures))..add(DiagnosticsProperty('enterToSend', enterToSend))..add(DiagnosticsProperty('appBarTransparent', appBarTransparent))..add(DiagnosticsProperty('showBackgroundImage', showBackgroundImage))..add(DiagnosticsProperty('notifyWithHaptic', notifyWithHaptic))..add(DiagnosticsProperty('enableTts', enableTts))..add(DiagnosticsProperty('ttsVoice', ttsVoice))..add(DiagnosticsProperty('ttsSpeechRate', ttsSpeechRate))..add(DiagnosticsProperty('ttsPitch', ttsPitch))..add(DiagnosticsProperty('ttsVolume', ttsVolume))..add(DiagnosticsProperty('ttsLanguage', ttsLanguage))..add(DiagnosticsProperty('customFonts', customFonts))..add(DiagnosticsProperty('appColorScheme', appColorScheme))..add(DiagnosticsProperty('customColors', customColors))..add(DiagnosticsProperty('windowSize', windowSize))..add(DiagnosticsProperty('windowOpacity', windowOpacity))..add(DiagnosticsProperty('cardTransparency', cardTransparency))..add(DiagnosticsProperty('defaultPoolId', defaultPoolId))..add(DiagnosticsProperty('messageDisplayStyle', messageDisplayStyle))..add(DiagnosticsProperty('attachmentsListStyle', attachmentsListStyle))..add(DiagnosticsProperty('linkCollapseMode', linkCollapseMode))..add(DiagnosticsProperty('themeMode', themeMode))..add(DiagnosticsProperty('disableAnimation', disableAnimation))..add(DiagnosticsProperty('groupedChatList', groupedChatList))..add(DiagnosticsProperty('firstLaunchAt', firstLaunchAt))..add(DiagnosticsProperty('askedReview', askedReview))..add(DiagnosticsProperty('dashSearchEngine', dashSearchEngine))..add(DiagnosticsProperty('defaultScreen', defaultScreen))..add(DiagnosticsProperty('realmDisplayMode', realmDisplayMode))..add(DiagnosticsProperty('chatEventMessageMode', chatEventMessageMode))..add(DiagnosticsProperty('showChatSystemMessages', showChatSystemMessages))..add(DiagnosticsProperty('dashboardConfig', dashboardConfig))..add(DiagnosticsProperty('exploreSettings', exploreSettings))..add(DiagnosticsProperty('mediaProxyEnabled', mediaProxyEnabled))..add(DiagnosticsProperty('friendStatusDesktopNotification', friendStatusDesktopNotification));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.dataSavingMode, dataSavingMode) || other.dataSavingMode == dataSavingMode)&&(identical(other.soundEffects, soundEffects) || other.soundEffects == soundEffects)&&(identical(other.festivalFeatures, festivalFeatures) || other.festivalFeatures == festivalFeatures)&&(identical(other.enterToSend, enterToSend) || other.enterToSend == enterToSend)&&(identical(other.appBarTransparent, appBarTransparent) || other.appBarTransparent == appBarTransparent)&&(identical(other.showBackgroundImage, showBackgroundImage) || other.showBackgroundImage == showBackgroundImage)&&(identical(other.notifyWithHaptic, notifyWithHaptic) || other.notifyWithHaptic == notifyWithHaptic)&&(identical(other.enableTts, enableTts) || other.enableTts == enableTts)&&(identical(other.ttsVoice, ttsVoice) || other.ttsVoice == ttsVoice)&&(identical(other.ttsSpeechRate, ttsSpeechRate) || other.ttsSpeechRate == ttsSpeechRate)&&(identical(other.ttsPitch, ttsPitch) || other.ttsPitch == ttsPitch)&&(identical(other.ttsVolume, ttsVolume) || other.ttsVolume == ttsVolume)&&(identical(other.ttsLanguage, ttsLanguage) || other.ttsLanguage == ttsLanguage)&&(identical(other.customFonts, customFonts) || other.customFonts == customFonts)&&(identical(other.appColorScheme, appColorScheme) || other.appColorScheme == appColorScheme)&&(identical(other.customColors, customColors) || other.customColors == customColors)&&(identical(other.windowSize, windowSize) || other.windowSize == windowSize)&&(identical(other.windowOpacity, windowOpacity) || other.windowOpacity == windowOpacity)&&(identical(other.cardTransparency, cardTransparency) || other.cardTransparency == cardTransparency)&&(identical(other.defaultPoolId, defaultPoolId) || other.defaultPoolId == defaultPoolId)&&(identical(other.messageDisplayStyle, messageDisplayStyle) || other.messageDisplayStyle == messageDisplayStyle)&&(identical(other.attachmentsListStyle, attachmentsListStyle) || other.attachmentsListStyle == attachmentsListStyle)&&(identical(other.linkCollapseMode, linkCollapseMode) || other.linkCollapseMode == linkCollapseMode)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.disableAnimation, disableAnimation) || other.disableAnimation == disableAnimation)&&(identical(other.groupedChatList, groupedChatList) || other.groupedChatList == groupedChatList)&&(identical(other.firstLaunchAt, firstLaunchAt) || other.firstLaunchAt == firstLaunchAt)&&(identical(other.askedReview, askedReview) || other.askedReview == askedReview)&&(identical(other.dashSearchEngine, dashSearchEngine) || other.dashSearchEngine == dashSearchEngine)&&(identical(other.defaultScreen, defaultScreen) || other.defaultScreen == defaultScreen)&&(identical(other.realmDisplayMode, realmDisplayMode) || other.realmDisplayMode == realmDisplayMode)&&(identical(other.chatEventMessageMode, chatEventMessageMode) || other.chatEventMessageMode == chatEventMessageMode)&&(identical(other.showChatSystemMessages, showChatSystemMessages) || other.showChatSystemMessages == showChatSystemMessages)&&(identical(other.dashboardConfig, dashboardConfig) || other.dashboardConfig == dashboardConfig)&&(identical(other.exploreSettings, exploreSettings) || other.exploreSettings == exploreSettings)&&(identical(other.mediaProxyEnabled, mediaProxyEnabled) || other.mediaProxyEnabled == mediaProxyEnabled)&&(identical(other.friendStatusDesktopNotification, friendStatusDesktopNotification) || other.friendStatusDesktopNotification == friendStatusDesktopNotification));
}


@override
int get hashCode => Object.hashAll([runtimeType,dataSavingMode,soundEffects,festivalFeatures,enterToSend,appBarTransparent,showBackgroundImage,notifyWithHaptic,enableTts,ttsVoice,ttsSpeechRate,ttsPitch,ttsVolume,ttsLanguage,customFonts,appColorScheme,customColors,windowSize,windowOpacity,cardTransparency,defaultPoolId,messageDisplayStyle,attachmentsListStyle,linkCollapseMode,themeMode,disableAnimation,groupedChatList,firstLaunchAt,askedReview,dashSearchEngine,defaultScreen,realmDisplayMode,chatEventMessageMode,showChatSystemMessages,dashboardConfig,exploreSettings,mediaProxyEnabled,friendStatusDesktopNotification]);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AppSettings(dataSavingMode: $dataSavingMode, soundEffects: $soundEffects, festivalFeatures: $festivalFeatures, enterToSend: $enterToSend, appBarTransparent: $appBarTransparent, showBackgroundImage: $showBackgroundImage, notifyWithHaptic: $notifyWithHaptic, enableTts: $enableTts, ttsVoice: $ttsVoice, ttsSpeechRate: $ttsSpeechRate, ttsPitch: $ttsPitch, ttsVolume: $ttsVolume, ttsLanguage: $ttsLanguage, customFonts: $customFonts, appColorScheme: $appColorScheme, customColors: $customColors, windowSize: $windowSize, windowOpacity: $windowOpacity, cardTransparency: $cardTransparency, defaultPoolId: $defaultPoolId, messageDisplayStyle: $messageDisplayStyle, attachmentsListStyle: $attachmentsListStyle, linkCollapseMode: $linkCollapseMode, themeMode: $themeMode, disableAnimation: $disableAnimation, groupedChatList: $groupedChatList, firstLaunchAt: $firstLaunchAt, askedReview: $askedReview, dashSearchEngine: $dashSearchEngine, defaultScreen: $defaultScreen, realmDisplayMode: $realmDisplayMode, chatEventMessageMode: $chatEventMessageMode, showChatSystemMessages: $showChatSystemMessages, dashboardConfig: $dashboardConfig, exploreSettings: $exploreSettings, mediaProxyEnabled: $mediaProxyEnabled, friendStatusDesktopNotification: $friendStatusDesktopNotification)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool dataSavingMode, bool soundEffects, bool festivalFeatures, bool enterToSend, bool appBarTransparent, bool showBackgroundImage, bool notifyWithHaptic, bool enableTts, String? ttsVoice, double ttsSpeechRate, double ttsPitch, double ttsVolume, String ttsLanguage, String? customFonts, int? appColorScheme, ThemeColors? customColors, Size? windowSize, double windowOpacity, double cardTransparency, String? defaultPoolId, String messageDisplayStyle, String attachmentsListStyle, String linkCollapseMode, String? themeMode, bool disableAnimation, bool groupedChatList, String? firstLaunchAt, bool askedReview, String? dashSearchEngine, String? defaultScreen, String realmDisplayMode, String chatEventMessageMode, bool showChatSystemMessages, DashboardConfig? dashboardConfig, ExploreSettings exploreSettings, bool mediaProxyEnabled, bool friendStatusDesktopNotification
});


@override $ThemeColorsCopyWith<$Res>? get customColors;@override $DashboardConfigCopyWith<$Res>? get dashboardConfig;@override $ExploreSettingsCopyWith<$Res> get exploreSettings;

}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dataSavingMode = null,Object? soundEffects = null,Object? festivalFeatures = null,Object? enterToSend = null,Object? appBarTransparent = null,Object? showBackgroundImage = null,Object? notifyWithHaptic = null,Object? enableTts = null,Object? ttsVoice = freezed,Object? ttsSpeechRate = null,Object? ttsPitch = null,Object? ttsVolume = null,Object? ttsLanguage = null,Object? customFonts = freezed,Object? appColorScheme = freezed,Object? customColors = freezed,Object? windowSize = freezed,Object? windowOpacity = null,Object? cardTransparency = null,Object? defaultPoolId = freezed,Object? messageDisplayStyle = null,Object? attachmentsListStyle = null,Object? linkCollapseMode = null,Object? themeMode = freezed,Object? disableAnimation = null,Object? groupedChatList = null,Object? firstLaunchAt = freezed,Object? askedReview = null,Object? dashSearchEngine = freezed,Object? defaultScreen = freezed,Object? realmDisplayMode = null,Object? chatEventMessageMode = null,Object? showChatSystemMessages = null,Object? dashboardConfig = freezed,Object? exploreSettings = null,Object? mediaProxyEnabled = null,Object? friendStatusDesktopNotification = null,}) {
  return _then(_AppSettings(
dataSavingMode: null == dataSavingMode ? _self.dataSavingMode : dataSavingMode // ignore: cast_nullable_to_non_nullable
as bool,soundEffects: null == soundEffects ? _self.soundEffects : soundEffects // ignore: cast_nullable_to_non_nullable
as bool,festivalFeatures: null == festivalFeatures ? _self.festivalFeatures : festivalFeatures // ignore: cast_nullable_to_non_nullable
as bool,enterToSend: null == enterToSend ? _self.enterToSend : enterToSend // ignore: cast_nullable_to_non_nullable
as bool,appBarTransparent: null == appBarTransparent ? _self.appBarTransparent : appBarTransparent // ignore: cast_nullable_to_non_nullable
as bool,showBackgroundImage: null == showBackgroundImage ? _self.showBackgroundImage : showBackgroundImage // ignore: cast_nullable_to_non_nullable
as bool,notifyWithHaptic: null == notifyWithHaptic ? _self.notifyWithHaptic : notifyWithHaptic // ignore: cast_nullable_to_non_nullable
as bool,enableTts: null == enableTts ? _self.enableTts : enableTts // ignore: cast_nullable_to_non_nullable
as bool,ttsVoice: freezed == ttsVoice ? _self.ttsVoice : ttsVoice // ignore: cast_nullable_to_non_nullable
as String?,ttsSpeechRate: null == ttsSpeechRate ? _self.ttsSpeechRate : ttsSpeechRate // ignore: cast_nullable_to_non_nullable
as double,ttsPitch: null == ttsPitch ? _self.ttsPitch : ttsPitch // ignore: cast_nullable_to_non_nullable
as double,ttsVolume: null == ttsVolume ? _self.ttsVolume : ttsVolume // ignore: cast_nullable_to_non_nullable
as double,ttsLanguage: null == ttsLanguage ? _self.ttsLanguage : ttsLanguage // ignore: cast_nullable_to_non_nullable
as String,customFonts: freezed == customFonts ? _self.customFonts : customFonts // ignore: cast_nullable_to_non_nullable
as String?,appColorScheme: freezed == appColorScheme ? _self.appColorScheme : appColorScheme // ignore: cast_nullable_to_non_nullable
as int?,customColors: freezed == customColors ? _self.customColors : customColors // ignore: cast_nullable_to_non_nullable
as ThemeColors?,windowSize: freezed == windowSize ? _self.windowSize : windowSize // ignore: cast_nullable_to_non_nullable
as Size?,windowOpacity: null == windowOpacity ? _self.windowOpacity : windowOpacity // ignore: cast_nullable_to_non_nullable
as double,cardTransparency: null == cardTransparency ? _self.cardTransparency : cardTransparency // ignore: cast_nullable_to_non_nullable
as double,defaultPoolId: freezed == defaultPoolId ? _self.defaultPoolId : defaultPoolId // ignore: cast_nullable_to_non_nullable
as String?,messageDisplayStyle: null == messageDisplayStyle ? _self.messageDisplayStyle : messageDisplayStyle // ignore: cast_nullable_to_non_nullable
as String,attachmentsListStyle: null == attachmentsListStyle ? _self.attachmentsListStyle : attachmentsListStyle // ignore: cast_nullable_to_non_nullable
as String,linkCollapseMode: null == linkCollapseMode ? _self.linkCollapseMode : linkCollapseMode // ignore: cast_nullable_to_non_nullable
as String,themeMode: freezed == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String?,disableAnimation: null == disableAnimation ? _self.disableAnimation : disableAnimation // ignore: cast_nullable_to_non_nullable
as bool,groupedChatList: null == groupedChatList ? _self.groupedChatList : groupedChatList // ignore: cast_nullable_to_non_nullable
as bool,firstLaunchAt: freezed == firstLaunchAt ? _self.firstLaunchAt : firstLaunchAt // ignore: cast_nullable_to_non_nullable
as String?,askedReview: null == askedReview ? _self.askedReview : askedReview // ignore: cast_nullable_to_non_nullable
as bool,dashSearchEngine: freezed == dashSearchEngine ? _self.dashSearchEngine : dashSearchEngine // ignore: cast_nullable_to_non_nullable
as String?,defaultScreen: freezed == defaultScreen ? _self.defaultScreen : defaultScreen // ignore: cast_nullable_to_non_nullable
as String?,realmDisplayMode: null == realmDisplayMode ? _self.realmDisplayMode : realmDisplayMode // ignore: cast_nullable_to_non_nullable
as String,chatEventMessageMode: null == chatEventMessageMode ? _self.chatEventMessageMode : chatEventMessageMode // ignore: cast_nullable_to_non_nullable
as String,showChatSystemMessages: null == showChatSystemMessages ? _self.showChatSystemMessages : showChatSystemMessages // ignore: cast_nullable_to_non_nullable
as bool,dashboardConfig: freezed == dashboardConfig ? _self.dashboardConfig : dashboardConfig // ignore: cast_nullable_to_non_nullable
as DashboardConfig?,exploreSettings: null == exploreSettings ? _self.exploreSettings : exploreSettings // ignore: cast_nullable_to_non_nullable
as ExploreSettings,mediaProxyEnabled: null == mediaProxyEnabled ? _self.mediaProxyEnabled : mediaProxyEnabled // ignore: cast_nullable_to_non_nullable
as bool,friendStatusDesktopNotification: null == friendStatusDesktopNotification ? _self.friendStatusDesktopNotification : friendStatusDesktopNotification // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ThemeColorsCopyWith<$Res>? get customColors {
    if (_self.customColors == null) {
    return null;
  }

  return $ThemeColorsCopyWith<$Res>(_self.customColors!, (value) {
    return _then(_self.copyWith(customColors: value));
  });
}/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardConfigCopyWith<$Res>? get dashboardConfig {
    if (_self.dashboardConfig == null) {
    return null;
  }

  return $DashboardConfigCopyWith<$Res>(_self.dashboardConfig!, (value) {
    return _then(_self.copyWith(dashboardConfig: value));
  });
}/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExploreSettingsCopyWith<$Res> get exploreSettings {
  
  return $ExploreSettingsCopyWith<$Res>(_self.exploreSettings, (value) {
    return _then(_self.copyWith(exploreSettings: value));
  });
}
}

// dart format on
