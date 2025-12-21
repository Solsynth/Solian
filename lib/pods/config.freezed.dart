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
mixin _$ThemeColors {

 int? get primary; int? get secondary; int? get tertiary; int? get surface; int? get background; int? get error;
/// Create a copy of ThemeColors
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeColorsCopyWith<ThemeColors> get copyWith => _$ThemeColorsCopyWithImpl<ThemeColors>(this as ThemeColors, _$identity);

  /// Serializes this ThemeColors to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeColors&&(identical(other.primary, primary) || other.primary == primary)&&(identical(other.secondary, secondary) || other.secondary == secondary)&&(identical(other.tertiary, tertiary) || other.tertiary == tertiary)&&(identical(other.surface, surface) || other.surface == surface)&&(identical(other.background, background) || other.background == background)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primary,secondary,tertiary,surface,background,error);

@override
String toString() {
  return 'ThemeColors(primary: $primary, secondary: $secondary, tertiary: $tertiary, surface: $surface, background: $background, error: $error)';
}


}

/// @nodoc
abstract mixin class $ThemeColorsCopyWith<$Res>  {
  factory $ThemeColorsCopyWith(ThemeColors value, $Res Function(ThemeColors) _then) = _$ThemeColorsCopyWithImpl;
@useResult
$Res call({
 int? primary, int? secondary, int? tertiary, int? surface, int? background, int? error
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
@pragma('vm:prefer-inline') @override $Res call({Object? primary = freezed,Object? secondary = freezed,Object? tertiary = freezed,Object? surface = freezed,Object? background = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
primary: freezed == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as int?,secondary: freezed == secondary ? _self.secondary : secondary // ignore: cast_nullable_to_non_nullable
as int?,tertiary: freezed == tertiary ? _self.tertiary : tertiary // ignore: cast_nullable_to_non_nullable
as int?,surface: freezed == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as int?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? primary,  int? secondary,  int? tertiary,  int? surface,  int? background,  int? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeColors() when $default != null:
return $default(_that.primary,_that.secondary,_that.tertiary,_that.surface,_that.background,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? primary,  int? secondary,  int? tertiary,  int? surface,  int? background,  int? error)  $default,) {final _that = this;
switch (_that) {
case _ThemeColors():
return $default(_that.primary,_that.secondary,_that.tertiary,_that.surface,_that.background,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? primary,  int? secondary,  int? tertiary,  int? surface,  int? background,  int? error)?  $default,) {final _that = this;
switch (_that) {
case _ThemeColors() when $default != null:
return $default(_that.primary,_that.secondary,_that.tertiary,_that.surface,_that.background,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemeColors implements ThemeColors {
   _ThemeColors({this.primary, this.secondary, this.tertiary, this.surface, this.background, this.error});
  factory _ThemeColors.fromJson(Map<String, dynamic> json) => _$ThemeColorsFromJson(json);

@override final  int? primary;
@override final  int? secondary;
@override final  int? tertiary;
@override final  int? surface;
@override final  int? background;
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
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeColors&&(identical(other.primary, primary) || other.primary == primary)&&(identical(other.secondary, secondary) || other.secondary == secondary)&&(identical(other.tertiary, tertiary) || other.tertiary == tertiary)&&(identical(other.surface, surface) || other.surface == surface)&&(identical(other.background, background) || other.background == background)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primary,secondary,tertiary,surface,background,error);

@override
String toString() {
  return 'ThemeColors(primary: $primary, secondary: $secondary, tertiary: $tertiary, surface: $surface, background: $background, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ThemeColorsCopyWith<$Res> implements $ThemeColorsCopyWith<$Res> {
  factory _$ThemeColorsCopyWith(_ThemeColors value, $Res Function(_ThemeColors) _then) = __$ThemeColorsCopyWithImpl;
@override @useResult
$Res call({
 int? primary, int? secondary, int? tertiary, int? surface, int? background, int? error
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
@override @pragma('vm:prefer-inline') $Res call({Object? primary = freezed,Object? secondary = freezed,Object? tertiary = freezed,Object? surface = freezed,Object? background = freezed,Object? error = freezed,}) {
  return _then(_ThemeColors(
primary: freezed == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as int?,secondary: freezed == secondary ? _self.secondary : secondary // ignore: cast_nullable_to_non_nullable
as int?,tertiary: freezed == tertiary ? _self.tertiary : tertiary // ignore: cast_nullable_to_non_nullable
as int?,surface: freezed == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as int?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as int?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$AppSettings {

 bool get autoTranslate; bool get dataSavingMode; bool get soundEffects; bool get aprilFoolFeatures; bool get enterToSend; bool get appBarTransparent; bool get showBackgroundImage; String? get customFonts; int? get appColorScheme;// The color stored via the int type
 ThemeColors? get customColors; Size? get windowSize;// The window size for desktop platforms
 double get windowOpacity;// The window opacity for desktop platforms
 double get cardTransparency;// The card background opacity
 String? get defaultPoolId; String get messageDisplayStyle; String? get themeMode; bool get useMaterial3; bool get disableAnimation; String get fabPosition; bool get groupedChatList;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.autoTranslate, autoTranslate) || other.autoTranslate == autoTranslate)&&(identical(other.dataSavingMode, dataSavingMode) || other.dataSavingMode == dataSavingMode)&&(identical(other.soundEffects, soundEffects) || other.soundEffects == soundEffects)&&(identical(other.aprilFoolFeatures, aprilFoolFeatures) || other.aprilFoolFeatures == aprilFoolFeatures)&&(identical(other.enterToSend, enterToSend) || other.enterToSend == enterToSend)&&(identical(other.appBarTransparent, appBarTransparent) || other.appBarTransparent == appBarTransparent)&&(identical(other.showBackgroundImage, showBackgroundImage) || other.showBackgroundImage == showBackgroundImage)&&(identical(other.customFonts, customFonts) || other.customFonts == customFonts)&&(identical(other.appColorScheme, appColorScheme) || other.appColorScheme == appColorScheme)&&(identical(other.customColors, customColors) || other.customColors == customColors)&&(identical(other.windowSize, windowSize) || other.windowSize == windowSize)&&(identical(other.windowOpacity, windowOpacity) || other.windowOpacity == windowOpacity)&&(identical(other.cardTransparency, cardTransparency) || other.cardTransparency == cardTransparency)&&(identical(other.defaultPoolId, defaultPoolId) || other.defaultPoolId == defaultPoolId)&&(identical(other.messageDisplayStyle, messageDisplayStyle) || other.messageDisplayStyle == messageDisplayStyle)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.useMaterial3, useMaterial3) || other.useMaterial3 == useMaterial3)&&(identical(other.disableAnimation, disableAnimation) || other.disableAnimation == disableAnimation)&&(identical(other.fabPosition, fabPosition) || other.fabPosition == fabPosition)&&(identical(other.groupedChatList, groupedChatList) || other.groupedChatList == groupedChatList));
}


@override
int get hashCode => Object.hashAll([runtimeType,autoTranslate,dataSavingMode,soundEffects,aprilFoolFeatures,enterToSend,appBarTransparent,showBackgroundImage,customFonts,appColorScheme,customColors,windowSize,windowOpacity,cardTransparency,defaultPoolId,messageDisplayStyle,themeMode,useMaterial3,disableAnimation,fabPosition,groupedChatList]);

@override
String toString() {
  return 'AppSettings(autoTranslate: $autoTranslate, dataSavingMode: $dataSavingMode, soundEffects: $soundEffects, aprilFoolFeatures: $aprilFoolFeatures, enterToSend: $enterToSend, appBarTransparent: $appBarTransparent, showBackgroundImage: $showBackgroundImage, customFonts: $customFonts, appColorScheme: $appColorScheme, customColors: $customColors, windowSize: $windowSize, windowOpacity: $windowOpacity, cardTransparency: $cardTransparency, defaultPoolId: $defaultPoolId, messageDisplayStyle: $messageDisplayStyle, themeMode: $themeMode, useMaterial3: $useMaterial3, disableAnimation: $disableAnimation, fabPosition: $fabPosition, groupedChatList: $groupedChatList)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 bool autoTranslate, bool dataSavingMode, bool soundEffects, bool aprilFoolFeatures, bool enterToSend, bool appBarTransparent, bool showBackgroundImage, String? customFonts, int? appColorScheme, ThemeColors? customColors, Size? windowSize, double windowOpacity, double cardTransparency, String? defaultPoolId, String messageDisplayStyle, String? themeMode, bool useMaterial3, bool disableAnimation, String fabPosition, bool groupedChatList
});


$ThemeColorsCopyWith<$Res>? get customColors;

}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? autoTranslate = null,Object? dataSavingMode = null,Object? soundEffects = null,Object? aprilFoolFeatures = null,Object? enterToSend = null,Object? appBarTransparent = null,Object? showBackgroundImage = null,Object? customFonts = freezed,Object? appColorScheme = freezed,Object? customColors = freezed,Object? windowSize = freezed,Object? windowOpacity = null,Object? cardTransparency = null,Object? defaultPoolId = freezed,Object? messageDisplayStyle = null,Object? themeMode = freezed,Object? useMaterial3 = null,Object? disableAnimation = null,Object? fabPosition = null,Object? groupedChatList = null,}) {
  return _then(_self.copyWith(
autoTranslate: null == autoTranslate ? _self.autoTranslate : autoTranslate // ignore: cast_nullable_to_non_nullable
as bool,dataSavingMode: null == dataSavingMode ? _self.dataSavingMode : dataSavingMode // ignore: cast_nullable_to_non_nullable
as bool,soundEffects: null == soundEffects ? _self.soundEffects : soundEffects // ignore: cast_nullable_to_non_nullable
as bool,aprilFoolFeatures: null == aprilFoolFeatures ? _self.aprilFoolFeatures : aprilFoolFeatures // ignore: cast_nullable_to_non_nullable
as bool,enterToSend: null == enterToSend ? _self.enterToSend : enterToSend // ignore: cast_nullable_to_non_nullable
as bool,appBarTransparent: null == appBarTransparent ? _self.appBarTransparent : appBarTransparent // ignore: cast_nullable_to_non_nullable
as bool,showBackgroundImage: null == showBackgroundImage ? _self.showBackgroundImage : showBackgroundImage // ignore: cast_nullable_to_non_nullable
as bool,customFonts: freezed == customFonts ? _self.customFonts : customFonts // ignore: cast_nullable_to_non_nullable
as String?,appColorScheme: freezed == appColorScheme ? _self.appColorScheme : appColorScheme // ignore: cast_nullable_to_non_nullable
as int?,customColors: freezed == customColors ? _self.customColors : customColors // ignore: cast_nullable_to_non_nullable
as ThemeColors?,windowSize: freezed == windowSize ? _self.windowSize : windowSize // ignore: cast_nullable_to_non_nullable
as Size?,windowOpacity: null == windowOpacity ? _self.windowOpacity : windowOpacity // ignore: cast_nullable_to_non_nullable
as double,cardTransparency: null == cardTransparency ? _self.cardTransparency : cardTransparency // ignore: cast_nullable_to_non_nullable
as double,defaultPoolId: freezed == defaultPoolId ? _self.defaultPoolId : defaultPoolId // ignore: cast_nullable_to_non_nullable
as String?,messageDisplayStyle: null == messageDisplayStyle ? _self.messageDisplayStyle : messageDisplayStyle // ignore: cast_nullable_to_non_nullable
as String,themeMode: freezed == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String?,useMaterial3: null == useMaterial3 ? _self.useMaterial3 : useMaterial3 // ignore: cast_nullable_to_non_nullable
as bool,disableAnimation: null == disableAnimation ? _self.disableAnimation : disableAnimation // ignore: cast_nullable_to_non_nullable
as bool,fabPosition: null == fabPosition ? _self.fabPosition : fabPosition // ignore: cast_nullable_to_non_nullable
as String,groupedChatList: null == groupedChatList ? _self.groupedChatList : groupedChatList // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool autoTranslate,  bool dataSavingMode,  bool soundEffects,  bool aprilFoolFeatures,  bool enterToSend,  bool appBarTransparent,  bool showBackgroundImage,  String? customFonts,  int? appColorScheme,  ThemeColors? customColors,  Size? windowSize,  double windowOpacity,  double cardTransparency,  String? defaultPoolId,  String messageDisplayStyle,  String? themeMode,  bool useMaterial3,  bool disableAnimation,  String fabPosition,  bool groupedChatList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.autoTranslate,_that.dataSavingMode,_that.soundEffects,_that.aprilFoolFeatures,_that.enterToSend,_that.appBarTransparent,_that.showBackgroundImage,_that.customFonts,_that.appColorScheme,_that.customColors,_that.windowSize,_that.windowOpacity,_that.cardTransparency,_that.defaultPoolId,_that.messageDisplayStyle,_that.themeMode,_that.useMaterial3,_that.disableAnimation,_that.fabPosition,_that.groupedChatList);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool autoTranslate,  bool dataSavingMode,  bool soundEffects,  bool aprilFoolFeatures,  bool enterToSend,  bool appBarTransparent,  bool showBackgroundImage,  String? customFonts,  int? appColorScheme,  ThemeColors? customColors,  Size? windowSize,  double windowOpacity,  double cardTransparency,  String? defaultPoolId,  String messageDisplayStyle,  String? themeMode,  bool useMaterial3,  bool disableAnimation,  String fabPosition,  bool groupedChatList)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.autoTranslate,_that.dataSavingMode,_that.soundEffects,_that.aprilFoolFeatures,_that.enterToSend,_that.appBarTransparent,_that.showBackgroundImage,_that.customFonts,_that.appColorScheme,_that.customColors,_that.windowSize,_that.windowOpacity,_that.cardTransparency,_that.defaultPoolId,_that.messageDisplayStyle,_that.themeMode,_that.useMaterial3,_that.disableAnimation,_that.fabPosition,_that.groupedChatList);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool autoTranslate,  bool dataSavingMode,  bool soundEffects,  bool aprilFoolFeatures,  bool enterToSend,  bool appBarTransparent,  bool showBackgroundImage,  String? customFonts,  int? appColorScheme,  ThemeColors? customColors,  Size? windowSize,  double windowOpacity,  double cardTransparency,  String? defaultPoolId,  String messageDisplayStyle,  String? themeMode,  bool useMaterial3,  bool disableAnimation,  String fabPosition,  bool groupedChatList)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.autoTranslate,_that.dataSavingMode,_that.soundEffects,_that.aprilFoolFeatures,_that.enterToSend,_that.appBarTransparent,_that.showBackgroundImage,_that.customFonts,_that.appColorScheme,_that.customColors,_that.windowSize,_that.windowOpacity,_that.cardTransparency,_that.defaultPoolId,_that.messageDisplayStyle,_that.themeMode,_that.useMaterial3,_that.disableAnimation,_that.fabPosition,_that.groupedChatList);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings implements AppSettings {
  const _AppSettings({required this.autoTranslate, required this.dataSavingMode, required this.soundEffects, required this.aprilFoolFeatures, required this.enterToSend, required this.appBarTransparent, required this.showBackgroundImage, required this.customFonts, required this.appColorScheme, required this.customColors, required this.windowSize, required this.windowOpacity, required this.cardTransparency, required this.defaultPoolId, required this.messageDisplayStyle, required this.themeMode, required this.useMaterial3, required this.disableAnimation, required this.fabPosition, required this.groupedChatList});
  

@override final  bool autoTranslate;
@override final  bool dataSavingMode;
@override final  bool soundEffects;
@override final  bool aprilFoolFeatures;
@override final  bool enterToSend;
@override final  bool appBarTransparent;
@override final  bool showBackgroundImage;
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
@override final  String? themeMode;
@override final  bool useMaterial3;
@override final  bool disableAnimation;
@override final  String fabPosition;
@override final  bool groupedChatList;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.autoTranslate, autoTranslate) || other.autoTranslate == autoTranslate)&&(identical(other.dataSavingMode, dataSavingMode) || other.dataSavingMode == dataSavingMode)&&(identical(other.soundEffects, soundEffects) || other.soundEffects == soundEffects)&&(identical(other.aprilFoolFeatures, aprilFoolFeatures) || other.aprilFoolFeatures == aprilFoolFeatures)&&(identical(other.enterToSend, enterToSend) || other.enterToSend == enterToSend)&&(identical(other.appBarTransparent, appBarTransparent) || other.appBarTransparent == appBarTransparent)&&(identical(other.showBackgroundImage, showBackgroundImage) || other.showBackgroundImage == showBackgroundImage)&&(identical(other.customFonts, customFonts) || other.customFonts == customFonts)&&(identical(other.appColorScheme, appColorScheme) || other.appColorScheme == appColorScheme)&&(identical(other.customColors, customColors) || other.customColors == customColors)&&(identical(other.windowSize, windowSize) || other.windowSize == windowSize)&&(identical(other.windowOpacity, windowOpacity) || other.windowOpacity == windowOpacity)&&(identical(other.cardTransparency, cardTransparency) || other.cardTransparency == cardTransparency)&&(identical(other.defaultPoolId, defaultPoolId) || other.defaultPoolId == defaultPoolId)&&(identical(other.messageDisplayStyle, messageDisplayStyle) || other.messageDisplayStyle == messageDisplayStyle)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.useMaterial3, useMaterial3) || other.useMaterial3 == useMaterial3)&&(identical(other.disableAnimation, disableAnimation) || other.disableAnimation == disableAnimation)&&(identical(other.fabPosition, fabPosition) || other.fabPosition == fabPosition)&&(identical(other.groupedChatList, groupedChatList) || other.groupedChatList == groupedChatList));
}


@override
int get hashCode => Object.hashAll([runtimeType,autoTranslate,dataSavingMode,soundEffects,aprilFoolFeatures,enterToSend,appBarTransparent,showBackgroundImage,customFonts,appColorScheme,customColors,windowSize,windowOpacity,cardTransparency,defaultPoolId,messageDisplayStyle,themeMode,useMaterial3,disableAnimation,fabPosition,groupedChatList]);

@override
String toString() {
  return 'AppSettings(autoTranslate: $autoTranslate, dataSavingMode: $dataSavingMode, soundEffects: $soundEffects, aprilFoolFeatures: $aprilFoolFeatures, enterToSend: $enterToSend, appBarTransparent: $appBarTransparent, showBackgroundImage: $showBackgroundImage, customFonts: $customFonts, appColorScheme: $appColorScheme, customColors: $customColors, windowSize: $windowSize, windowOpacity: $windowOpacity, cardTransparency: $cardTransparency, defaultPoolId: $defaultPoolId, messageDisplayStyle: $messageDisplayStyle, themeMode: $themeMode, useMaterial3: $useMaterial3, disableAnimation: $disableAnimation, fabPosition: $fabPosition, groupedChatList: $groupedChatList)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool autoTranslate, bool dataSavingMode, bool soundEffects, bool aprilFoolFeatures, bool enterToSend, bool appBarTransparent, bool showBackgroundImage, String? customFonts, int? appColorScheme, ThemeColors? customColors, Size? windowSize, double windowOpacity, double cardTransparency, String? defaultPoolId, String messageDisplayStyle, String? themeMode, bool useMaterial3, bool disableAnimation, String fabPosition, bool groupedChatList
});


@override $ThemeColorsCopyWith<$Res>? get customColors;

}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? autoTranslate = null,Object? dataSavingMode = null,Object? soundEffects = null,Object? aprilFoolFeatures = null,Object? enterToSend = null,Object? appBarTransparent = null,Object? showBackgroundImage = null,Object? customFonts = freezed,Object? appColorScheme = freezed,Object? customColors = freezed,Object? windowSize = freezed,Object? windowOpacity = null,Object? cardTransparency = null,Object? defaultPoolId = freezed,Object? messageDisplayStyle = null,Object? themeMode = freezed,Object? useMaterial3 = null,Object? disableAnimation = null,Object? fabPosition = null,Object? groupedChatList = null,}) {
  return _then(_AppSettings(
autoTranslate: null == autoTranslate ? _self.autoTranslate : autoTranslate // ignore: cast_nullable_to_non_nullable
as bool,dataSavingMode: null == dataSavingMode ? _self.dataSavingMode : dataSavingMode // ignore: cast_nullable_to_non_nullable
as bool,soundEffects: null == soundEffects ? _self.soundEffects : soundEffects // ignore: cast_nullable_to_non_nullable
as bool,aprilFoolFeatures: null == aprilFoolFeatures ? _self.aprilFoolFeatures : aprilFoolFeatures // ignore: cast_nullable_to_non_nullable
as bool,enterToSend: null == enterToSend ? _self.enterToSend : enterToSend // ignore: cast_nullable_to_non_nullable
as bool,appBarTransparent: null == appBarTransparent ? _self.appBarTransparent : appBarTransparent // ignore: cast_nullable_to_non_nullable
as bool,showBackgroundImage: null == showBackgroundImage ? _self.showBackgroundImage : showBackgroundImage // ignore: cast_nullable_to_non_nullable
as bool,customFonts: freezed == customFonts ? _self.customFonts : customFonts // ignore: cast_nullable_to_non_nullable
as String?,appColorScheme: freezed == appColorScheme ? _self.appColorScheme : appColorScheme // ignore: cast_nullable_to_non_nullable
as int?,customColors: freezed == customColors ? _self.customColors : customColors // ignore: cast_nullable_to_non_nullable
as ThemeColors?,windowSize: freezed == windowSize ? _self.windowSize : windowSize // ignore: cast_nullable_to_non_nullable
as Size?,windowOpacity: null == windowOpacity ? _self.windowOpacity : windowOpacity // ignore: cast_nullable_to_non_nullable
as double,cardTransparency: null == cardTransparency ? _self.cardTransparency : cardTransparency // ignore: cast_nullable_to_non_nullable
as double,defaultPoolId: freezed == defaultPoolId ? _self.defaultPoolId : defaultPoolId // ignore: cast_nullable_to_non_nullable
as String?,messageDisplayStyle: null == messageDisplayStyle ? _self.messageDisplayStyle : messageDisplayStyle // ignore: cast_nullable_to_non_nullable
as String,themeMode: freezed == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String?,useMaterial3: null == useMaterial3 ? _self.useMaterial3 : useMaterial3 // ignore: cast_nullable_to_non_nullable
as bool,disableAnimation: null == disableAnimation ? _self.disableAnimation : disableAnimation // ignore: cast_nullable_to_non_nullable
as bool,fabPosition: null == fabPosition ? _self.fabPosition : fabPosition // ignore: cast_nullable_to_non_nullable
as String,groupedChatList: null == groupedChatList ? _self.groupedChatList : groupedChatList // ignore: cast_nullable_to_non_nullable
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
}
}

// dart format on
