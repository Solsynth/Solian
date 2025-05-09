// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_calendar.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventCalendarQuery {

 String? get uname; int get year; int get month;
/// Create a copy of EventCalendarQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCalendarQueryCopyWith<EventCalendarQuery> get copyWith => _$EventCalendarQueryCopyWithImpl<EventCalendarQuery>(this as EventCalendarQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventCalendarQuery&&(identical(other.uname, uname) || other.uname == uname)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month));
}


@override
int get hashCode => Object.hash(runtimeType,uname,year,month);

@override
String toString() {
  return 'EventCalendarQuery(uname: $uname, year: $year, month: $month)';
}


}

/// @nodoc
abstract mixin class $EventCalendarQueryCopyWith<$Res>  {
  factory $EventCalendarQueryCopyWith(EventCalendarQuery value, $Res Function(EventCalendarQuery) _then) = _$EventCalendarQueryCopyWithImpl;
@useResult
$Res call({
 String? uname, int year, int month
});




}
/// @nodoc
class _$EventCalendarQueryCopyWithImpl<$Res>
    implements $EventCalendarQueryCopyWith<$Res> {
  _$EventCalendarQueryCopyWithImpl(this._self, this._then);

  final EventCalendarQuery _self;
  final $Res Function(EventCalendarQuery) _then;

/// Create a copy of EventCalendarQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uname = freezed,Object? year = null,Object? month = null,}) {
  return _then(_self.copyWith(
uname: freezed == uname ? _self.uname : uname // ignore: cast_nullable_to_non_nullable
as String?,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc


class _EventCalendarQuery implements EventCalendarQuery {
  const _EventCalendarQuery({required this.uname, required this.year, required this.month});
  

@override final  String? uname;
@override final  int year;
@override final  int month;

/// Create a copy of EventCalendarQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCalendarQueryCopyWith<_EventCalendarQuery> get copyWith => __$EventCalendarQueryCopyWithImpl<_EventCalendarQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventCalendarQuery&&(identical(other.uname, uname) || other.uname == uname)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month));
}


@override
int get hashCode => Object.hash(runtimeType,uname,year,month);

@override
String toString() {
  return 'EventCalendarQuery(uname: $uname, year: $year, month: $month)';
}


}

/// @nodoc
abstract mixin class _$EventCalendarQueryCopyWith<$Res> implements $EventCalendarQueryCopyWith<$Res> {
  factory _$EventCalendarQueryCopyWith(_EventCalendarQuery value, $Res Function(_EventCalendarQuery) _then) = __$EventCalendarQueryCopyWithImpl;
@override @useResult
$Res call({
 String? uname, int year, int month
});




}
/// @nodoc
class __$EventCalendarQueryCopyWithImpl<$Res>
    implements _$EventCalendarQueryCopyWith<$Res> {
  __$EventCalendarQueryCopyWithImpl(this._self, this._then);

  final _EventCalendarQuery _self;
  final $Res Function(_EventCalendarQuery) _then;

/// Create a copy of EventCalendarQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uname = freezed,Object? year = null,Object? month = null,}) {
  return _then(_EventCalendarQuery(
uname: freezed == uname ? _self.uname : uname // ignore: cast_nullable_to_non_nullable
as String?,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
