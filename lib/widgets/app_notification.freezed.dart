// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppNotification implements DiagnosticableTreeMixin {

 SnNotification get data;@JsonKey(ignore: true) IconData? get icon;@JsonKey(ignore: true) Duration? get duration; DateTime? get createdAt;@JsonKey(ignore: true) bool get isAnimatingOut;
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<AppNotification> get copyWith => _$AppNotificationCopyWithImpl<AppNotification>(this as AppNotification, _$identity);

  /// Serializes this AppNotification to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AppNotification'))
    ..add(DiagnosticsProperty('data', data))..add(DiagnosticsProperty('icon', icon))..add(DiagnosticsProperty('duration', duration))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('isAnimatingOut', isAnimatingOut));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppNotification&&(identical(other.data, data) || other.data == data)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isAnimatingOut, isAnimatingOut) || other.isAnimatingOut == isAnimatingOut));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data,icon,duration,createdAt,isAnimatingOut);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AppNotification(data: $data, icon: $icon, duration: $duration, createdAt: $createdAt, isAnimatingOut: $isAnimatingOut)';
}


}

/// @nodoc
abstract mixin class $AppNotificationCopyWith<$Res>  {
  factory $AppNotificationCopyWith(AppNotification value, $Res Function(AppNotification) _then) = _$AppNotificationCopyWithImpl;
@useResult
$Res call({
 SnNotification data,@JsonKey(ignore: true) IconData? icon,@JsonKey(ignore: true) Duration? duration, DateTime? createdAt,@JsonKey(ignore: true) bool isAnimatingOut
});


$SnNotificationCopyWith<$Res> get data;

}
/// @nodoc
class _$AppNotificationCopyWithImpl<$Res>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._self, this._then);

  final AppNotification _self;
  final $Res Function(AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? icon = freezed,Object? duration = freezed,Object? createdAt = freezed,Object? isAnimatingOut = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as SnNotification,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isAnimatingOut: null == isAnimatingOut ? _self.isAnimatingOut : isAnimatingOut // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnNotificationCopyWith<$Res> get data {
  
  return $SnNotificationCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _AppNotification with DiagnosticableTreeMixin implements AppNotification {
  const _AppNotification({required this.data, @JsonKey(ignore: true) this.icon, @JsonKey(ignore: true) this.duration, this.createdAt = null, @JsonKey(ignore: true) this.isAnimatingOut = false});
  factory _AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

@override final  SnNotification data;
@override@JsonKey(ignore: true) final  IconData? icon;
@override@JsonKey(ignore: true) final  Duration? duration;
@override@JsonKey() final  DateTime? createdAt;
@override@JsonKey(ignore: true) final  bool isAnimatingOut;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppNotificationCopyWith<_AppNotification> get copyWith => __$AppNotificationCopyWithImpl<_AppNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppNotificationToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AppNotification'))
    ..add(DiagnosticsProperty('data', data))..add(DiagnosticsProperty('icon', icon))..add(DiagnosticsProperty('duration', duration))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('isAnimatingOut', isAnimatingOut));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppNotification&&(identical(other.data, data) || other.data == data)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isAnimatingOut, isAnimatingOut) || other.isAnimatingOut == isAnimatingOut));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,data,icon,duration,createdAt,isAnimatingOut);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AppNotification(data: $data, icon: $icon, duration: $duration, createdAt: $createdAt, isAnimatingOut: $isAnimatingOut)';
}


}

/// @nodoc
abstract mixin class _$AppNotificationCopyWith<$Res> implements $AppNotificationCopyWith<$Res> {
  factory _$AppNotificationCopyWith(_AppNotification value, $Res Function(_AppNotification) _then) = __$AppNotificationCopyWithImpl;
@override @useResult
$Res call({
 SnNotification data,@JsonKey(ignore: true) IconData? icon,@JsonKey(ignore: true) Duration? duration, DateTime? createdAt,@JsonKey(ignore: true) bool isAnimatingOut
});


@override $SnNotificationCopyWith<$Res> get data;

}
/// @nodoc
class __$AppNotificationCopyWithImpl<$Res>
    implements _$AppNotificationCopyWith<$Res> {
  __$AppNotificationCopyWithImpl(this._self, this._then);

  final _AppNotification _self;
  final $Res Function(_AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? icon = freezed,Object? duration = freezed,Object? createdAt = freezed,Object? isAnimatingOut = null,}) {
  return _then(_AppNotification(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as SnNotification,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isAnimatingOut: null == isAnimatingOut ? _self.isAnimatingOut : isAnimatingOut // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnNotificationCopyWith<$Res> get data {
  
  return $SnNotificationCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
