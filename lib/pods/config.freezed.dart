// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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

 bool get realmCompactView; bool get mixedFeed; bool get autoTranslate; bool get hideBottomNav; bool get soundEffects; bool get aprilFoolFeatures; bool get enterToSend;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.realmCompactView, realmCompactView) || other.realmCompactView == realmCompactView)&&(identical(other.mixedFeed, mixedFeed) || other.mixedFeed == mixedFeed)&&(identical(other.autoTranslate, autoTranslate) || other.autoTranslate == autoTranslate)&&(identical(other.hideBottomNav, hideBottomNav) || other.hideBottomNav == hideBottomNav)&&(identical(other.soundEffects, soundEffects) || other.soundEffects == soundEffects)&&(identical(other.aprilFoolFeatures, aprilFoolFeatures) || other.aprilFoolFeatures == aprilFoolFeatures)&&(identical(other.enterToSend, enterToSend) || other.enterToSend == enterToSend));
}


@override
int get hashCode => Object.hash(runtimeType,realmCompactView,mixedFeed,autoTranslate,hideBottomNav,soundEffects,aprilFoolFeatures,enterToSend);

@override
String toString() {
  return 'AppSettings(realmCompactView: $realmCompactView, mixedFeed: $mixedFeed, autoTranslate: $autoTranslate, hideBottomNav: $hideBottomNav, soundEffects: $soundEffects, aprilFoolFeatures: $aprilFoolFeatures, enterToSend: $enterToSend)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 bool realmCompactView, bool mixedFeed, bool autoTranslate, bool hideBottomNav, bool soundEffects, bool aprilFoolFeatures, bool enterToSend
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? realmCompactView = null,Object? mixedFeed = null,Object? autoTranslate = null,Object? hideBottomNav = null,Object? soundEffects = null,Object? aprilFoolFeatures = null,Object? enterToSend = null,}) {
  return _then(_self.copyWith(
realmCompactView: null == realmCompactView ? _self.realmCompactView : realmCompactView // ignore: cast_nullable_to_non_nullable
as bool,mixedFeed: null == mixedFeed ? _self.mixedFeed : mixedFeed // ignore: cast_nullable_to_non_nullable
as bool,autoTranslate: null == autoTranslate ? _self.autoTranslate : autoTranslate // ignore: cast_nullable_to_non_nullable
as bool,hideBottomNav: null == hideBottomNav ? _self.hideBottomNav : hideBottomNav // ignore: cast_nullable_to_non_nullable
as bool,soundEffects: null == soundEffects ? _self.soundEffects : soundEffects // ignore: cast_nullable_to_non_nullable
as bool,aprilFoolFeatures: null == aprilFoolFeatures ? _self.aprilFoolFeatures : aprilFoolFeatures // ignore: cast_nullable_to_non_nullable
as bool,enterToSend: null == enterToSend ? _self.enterToSend : enterToSend // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc


class _AppSettings implements AppSettings {
  const _AppSettings({required this.realmCompactView, required this.mixedFeed, required this.autoTranslate, required this.hideBottomNav, required this.soundEffects, required this.aprilFoolFeatures, required this.enterToSend});
  

@override final  bool realmCompactView;
@override final  bool mixedFeed;
@override final  bool autoTranslate;
@override final  bool hideBottomNav;
@override final  bool soundEffects;
@override final  bool aprilFoolFeatures;
@override final  bool enterToSend;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.realmCompactView, realmCompactView) || other.realmCompactView == realmCompactView)&&(identical(other.mixedFeed, mixedFeed) || other.mixedFeed == mixedFeed)&&(identical(other.autoTranslate, autoTranslate) || other.autoTranslate == autoTranslate)&&(identical(other.hideBottomNav, hideBottomNav) || other.hideBottomNav == hideBottomNav)&&(identical(other.soundEffects, soundEffects) || other.soundEffects == soundEffects)&&(identical(other.aprilFoolFeatures, aprilFoolFeatures) || other.aprilFoolFeatures == aprilFoolFeatures)&&(identical(other.enterToSend, enterToSend) || other.enterToSend == enterToSend));
}


@override
int get hashCode => Object.hash(runtimeType,realmCompactView,mixedFeed,autoTranslate,hideBottomNav,soundEffects,aprilFoolFeatures,enterToSend);

@override
String toString() {
  return 'AppSettings(realmCompactView: $realmCompactView, mixedFeed: $mixedFeed, autoTranslate: $autoTranslate, hideBottomNav: $hideBottomNav, soundEffects: $soundEffects, aprilFoolFeatures: $aprilFoolFeatures, enterToSend: $enterToSend)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool realmCompactView, bool mixedFeed, bool autoTranslate, bool hideBottomNav, bool soundEffects, bool aprilFoolFeatures, bool enterToSend
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
@override @pragma('vm:prefer-inline') $Res call({Object? realmCompactView = null,Object? mixedFeed = null,Object? autoTranslate = null,Object? hideBottomNav = null,Object? soundEffects = null,Object? aprilFoolFeatures = null,Object? enterToSend = null,}) {
  return _then(_AppSettings(
realmCompactView: null == realmCompactView ? _self.realmCompactView : realmCompactView // ignore: cast_nullable_to_non_nullable
as bool,mixedFeed: null == mixedFeed ? _self.mixedFeed : mixedFeed // ignore: cast_nullable_to_non_nullable
as bool,autoTranslate: null == autoTranslate ? _self.autoTranslate : autoTranslate // ignore: cast_nullable_to_non_nullable
as bool,hideBottomNav: null == hideBottomNav ? _self.hideBottomNav : hideBottomNav // ignore: cast_nullable_to_non_nullable
as bool,soundEffects: null == soundEffects ? _self.soundEffects : soundEffects // ignore: cast_nullable_to_non_nullable
as bool,aprilFoolFeatures: null == aprilFoolFeatures ? _self.aprilFoolFeatures : aprilFoolFeatures // ignore: cast_nullable_to_non_nullable
as bool,enterToSend: null == enterToSend ? _self.enterToSend : enterToSend // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
