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
mixin _$AppSettings {

 bool get autoTranslate; bool get dataSavingMode; bool get soundEffects; bool get aprilFoolFeatures; bool get enterToSend; bool get appBarTransparent; bool get showBackgroundImage; String? get customFonts; int? get appColorScheme;// The color stored via the int type
 Size? get windowSize;// The window size for desktop platforms
 double get windowOpacity;// The window opacity for desktop platforms
 String? get defaultPoolId; String get messageDisplayStyle; String? get themeMode;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.autoTranslate, autoTranslate) || other.autoTranslate == autoTranslate)&&(identical(other.dataSavingMode, dataSavingMode) || other.dataSavingMode == dataSavingMode)&&(identical(other.soundEffects, soundEffects) || other.soundEffects == soundEffects)&&(identical(other.aprilFoolFeatures, aprilFoolFeatures) || other.aprilFoolFeatures == aprilFoolFeatures)&&(identical(other.enterToSend, enterToSend) || other.enterToSend == enterToSend)&&(identical(other.appBarTransparent, appBarTransparent) || other.appBarTransparent == appBarTransparent)&&(identical(other.showBackgroundImage, showBackgroundImage) || other.showBackgroundImage == showBackgroundImage)&&(identical(other.customFonts, customFonts) || other.customFonts == customFonts)&&(identical(other.appColorScheme, appColorScheme) || other.appColorScheme == appColorScheme)&&(identical(other.windowSize, windowSize) || other.windowSize == windowSize)&&(identical(other.windowOpacity, windowOpacity) || other.windowOpacity == windowOpacity)&&(identical(other.defaultPoolId, defaultPoolId) || other.defaultPoolId == defaultPoolId)&&(identical(other.messageDisplayStyle, messageDisplayStyle) || other.messageDisplayStyle == messageDisplayStyle)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode));
}


@override
int get hashCode => Object.hash(runtimeType,autoTranslate,dataSavingMode,soundEffects,aprilFoolFeatures,enterToSend,appBarTransparent,showBackgroundImage,customFonts,appColorScheme,windowSize,windowOpacity,defaultPoolId,messageDisplayStyle,themeMode);

@override
String toString() {
  return 'AppSettings(autoTranslate: $autoTranslate, dataSavingMode: $dataSavingMode, soundEffects: $soundEffects, aprilFoolFeatures: $aprilFoolFeatures, enterToSend: $enterToSend, appBarTransparent: $appBarTransparent, showBackgroundImage: $showBackgroundImage, customFonts: $customFonts, appColorScheme: $appColorScheme, windowSize: $windowSize, windowOpacity: $windowOpacity, defaultPoolId: $defaultPoolId, messageDisplayStyle: $messageDisplayStyle, themeMode: $themeMode)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 bool autoTranslate, bool dataSavingMode, bool soundEffects, bool aprilFoolFeatures, bool enterToSend, bool appBarTransparent, bool showBackgroundImage, String? customFonts, int? appColorScheme, Size? windowSize, double windowOpacity, String? defaultPoolId, String messageDisplayStyle, String? themeMode
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? autoTranslate = null,Object? dataSavingMode = null,Object? soundEffects = null,Object? aprilFoolFeatures = null,Object? enterToSend = null,Object? appBarTransparent = null,Object? showBackgroundImage = null,Object? customFonts = freezed,Object? appColorScheme = freezed,Object? windowSize = freezed,Object? windowOpacity = null,Object? defaultPoolId = freezed,Object? messageDisplayStyle = null,Object? themeMode = null,}) {
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
as int?,windowSize: freezed == windowSize ? _self.windowSize : windowSize // ignore: cast_nullable_to_non_nullable
as Size?,windowOpacity: null == windowOpacity ? _self.windowOpacity : windowOpacity // ignore: cast_nullable_to_non_nullable
as double,defaultPoolId: freezed == defaultPoolId ? _self.defaultPoolId : defaultPoolId // ignore: cast_nullable_to_non_nullable
as String?,messageDisplayStyle: null == messageDisplayStyle ? _self.messageDisplayStyle : messageDisplayStyle // ignore: cast_nullable_to_non_nullable
as String,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool autoTranslate,  bool dataSavingMode,  bool soundEffects,  bool aprilFoolFeatures,  bool enterToSend,  bool appBarTransparent,  bool showBackgroundImage,  String? customFonts,  int? appColorScheme,  Size? windowSize,  double windowOpacity,  String? defaultPoolId,  String messageDisplayStyle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.autoTranslate,_that.dataSavingMode,_that.soundEffects,_that.aprilFoolFeatures,_that.enterToSend,_that.appBarTransparent,_that.showBackgroundImage,_that.customFonts,_that.appColorScheme,_that.windowSize,_that.windowOpacity,_that.defaultPoolId,_that.messageDisplayStyle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool autoTranslate,  bool dataSavingMode,  bool soundEffects,  bool aprilFoolFeatures,  bool enterToSend,  bool appBarTransparent,  bool showBackgroundImage,  String? customFonts,  int? appColorScheme,  Size? windowSize,  double windowOpacity,  String? defaultPoolId,  String messageDisplayStyle)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.autoTranslate,_that.dataSavingMode,_that.soundEffects,_that.aprilFoolFeatures,_that.enterToSend,_that.appBarTransparent,_that.showBackgroundImage,_that.customFonts,_that.appColorScheme,_that.windowSize,_that.windowOpacity,_that.defaultPoolId,_that.messageDisplayStyle);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool autoTranslate,  bool dataSavingMode,  bool soundEffects,  bool aprilFoolFeatures,  bool enterToSend,  bool appBarTransparent,  bool showBackgroundImage,  String? customFonts,  int? appColorScheme,  Size? windowSize,  double windowOpacity,  String? defaultPoolId,  String messageDisplayStyle)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.autoTranslate,_that.dataSavingMode,_that.soundEffects,_that.aprilFoolFeatures,_that.enterToSend,_that.appBarTransparent,_that.showBackgroundImage,_that.customFonts,_that.appColorScheme,_that.windowSize,_that.windowOpacity,_that.defaultPoolId,_that.messageDisplayStyle);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings implements AppSettings {
  const _AppSettings({required this.autoTranslate, required this.dataSavingMode, required this.soundEffects, required this.aprilFoolFeatures, required this.enterToSend, required this.appBarTransparent, required this.showBackgroundImage, required this.customFonts, required this.appColorScheme, required this.windowSize, required this.windowOpacity, required this.defaultPoolId, required this.messageDisplayStyle, required this.themeMode});
  

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
@override final  Size? windowSize;
// The window size for desktop platforms
@override final  double windowOpacity;
// The window opacity for desktop platforms
@override final  String? defaultPoolId;
@override final  String messageDisplayStyle;
@override final  String? themeMode;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.autoTranslate, autoTranslate) || other.autoTranslate == autoTranslate)&&(identical(other.dataSavingMode, dataSavingMode) || other.dataSavingMode == dataSavingMode)&&(identical(other.soundEffects, soundEffects) || other.soundEffects == soundEffects)&&(identical(other.aprilFoolFeatures, aprilFoolFeatures) || other.aprilFoolFeatures == aprilFoolFeatures)&&(identical(other.enterToSend, enterToSend) || other.enterToSend == enterToSend)&&(identical(other.appBarTransparent, appBarTransparent) || other.appBarTransparent == appBarTransparent)&&(identical(other.showBackgroundImage, showBackgroundImage) || other.showBackgroundImage == showBackgroundImage)&&(identical(other.customFonts, customFonts) || other.customFonts == customFonts)&&(identical(other.appColorScheme, appColorScheme) || other.appColorScheme == appColorScheme)&&(identical(other.windowSize, windowSize) || other.windowSize == windowSize)&&(identical(other.windowOpacity, windowOpacity) || other.windowOpacity == windowOpacity)&&(identical(other.defaultPoolId, defaultPoolId) || other.defaultPoolId == defaultPoolId)&&(identical(other.messageDisplayStyle, messageDisplayStyle) || other.messageDisplayStyle == messageDisplayStyle));
}


@override
int get hashCode => Object.hash(runtimeType,autoTranslate,dataSavingMode,soundEffects,aprilFoolFeatures,enterToSend,appBarTransparent,showBackgroundImage,customFonts,appColorScheme,windowSize,windowOpacity,defaultPoolId,messageDisplayStyle);

@override
String toString() {
  return 'AppSettings(autoTranslate: $autoTranslate, dataSavingMode: $dataSavingMode, soundEffects: $soundEffects, aprilFoolFeatures: $aprilFoolFeatures, enterToSend: $enterToSend, appBarTransparent: $appBarTransparent, showBackgroundImage: $showBackgroundImage, customFonts: $customFonts, appColorScheme: $appColorScheme, windowSize: $windowSize, windowOpacity: $windowOpacity, defaultPoolId: $defaultPoolId, messageDisplayStyle: $messageDisplayStyle)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool autoTranslate, bool dataSavingMode, bool soundEffects, bool aprilFoolFeatures, bool enterToSend, bool appBarTransparent, bool showBackgroundImage, String? customFonts, int? appColorScheme, Size? windowSize, double windowOpacity, String? defaultPoolId, String messageDisplayStyle, String? themeMode
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? autoTranslate = null,Object? dataSavingMode = null,Object? soundEffects = null,Object? aprilFoolFeatures = null,Object? enterToSend = null,Object? appBarTransparent = null,Object? showBackgroundImage = null,Object? customFonts = freezed,Object? appColorScheme = freezed,Object? windowSize = freezed,Object? windowOpacity = null,Object? defaultPoolId = freezed,Object? messageDisplayStyle = null,Object? themeMode = null,}) {
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
as int?,windowSize: freezed == windowSize ? _self.windowSize : windowSize // ignore: cast_nullable_to_non_nullable
as Size?,windowOpacity: null == windowOpacity ? _self.windowOpacity : windowOpacity // ignore: cast_nullable_to_non_nullable
as double,defaultPoolId: freezed == defaultPoolId ? _self.defaultPoolId : defaultPoolId // ignore: cast_nullable_to_non_nullable
as String?,messageDisplayStyle: null == messageDisplayStyle ? _self.messageDisplayStyle : messageDisplayStyle // ignore: cast_nullable_to_non_nullable
as String,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
