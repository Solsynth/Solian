// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'developer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeveloperStats {

 int get totalCustomApps;
/// Create a copy of DeveloperStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeveloperStatsCopyWith<DeveloperStats> get copyWith => _$DeveloperStatsCopyWithImpl<DeveloperStats>(this as DeveloperStats, _$identity);

  /// Serializes this DeveloperStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeveloperStats&&(identical(other.totalCustomApps, totalCustomApps) || other.totalCustomApps == totalCustomApps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCustomApps);

@override
String toString() {
  return 'DeveloperStats(totalCustomApps: $totalCustomApps)';
}


}

/// @nodoc
abstract mixin class $DeveloperStatsCopyWith<$Res>  {
  factory $DeveloperStatsCopyWith(DeveloperStats value, $Res Function(DeveloperStats) _then) = _$DeveloperStatsCopyWithImpl;
@useResult
$Res call({
 int totalCustomApps
});




}
/// @nodoc
class _$DeveloperStatsCopyWithImpl<$Res>
    implements $DeveloperStatsCopyWith<$Res> {
  _$DeveloperStatsCopyWithImpl(this._self, this._then);

  final DeveloperStats _self;
  final $Res Function(DeveloperStats) _then;

/// Create a copy of DeveloperStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCustomApps = null,}) {
  return _then(_self.copyWith(
totalCustomApps: null == totalCustomApps ? _self.totalCustomApps : totalCustomApps // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _DeveloperStats implements DeveloperStats {
  const _DeveloperStats({this.totalCustomApps = 0});
  factory _DeveloperStats.fromJson(Map<String, dynamic> json) => _$DeveloperStatsFromJson(json);

@override@JsonKey() final  int totalCustomApps;

/// Create a copy of DeveloperStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeveloperStatsCopyWith<_DeveloperStats> get copyWith => __$DeveloperStatsCopyWithImpl<_DeveloperStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeveloperStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeveloperStats&&(identical(other.totalCustomApps, totalCustomApps) || other.totalCustomApps == totalCustomApps));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCustomApps);

@override
String toString() {
  return 'DeveloperStats(totalCustomApps: $totalCustomApps)';
}


}

/// @nodoc
abstract mixin class _$DeveloperStatsCopyWith<$Res> implements $DeveloperStatsCopyWith<$Res> {
  factory _$DeveloperStatsCopyWith(_DeveloperStats value, $Res Function(_DeveloperStats) _then) = __$DeveloperStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalCustomApps
});




}
/// @nodoc
class __$DeveloperStatsCopyWithImpl<$Res>
    implements _$DeveloperStatsCopyWith<$Res> {
  __$DeveloperStatsCopyWithImpl(this._self, this._then);

  final _DeveloperStats _self;
  final $Res Function(_DeveloperStats) _then;

/// Create a copy of DeveloperStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCustomApps = null,}) {
  return _then(_DeveloperStats(
totalCustomApps: null == totalCustomApps ? _self.totalCustomApps : totalCustomApps // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
