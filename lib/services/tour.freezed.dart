// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tour.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Tour {

 String get id; bool get isStartup;
/// Create a copy of Tour
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TourCopyWith<Tour> get copyWith => _$TourCopyWithImpl<Tour>(this as Tour, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tour&&(identical(other.id, id) || other.id == id)&&(identical(other.isStartup, isStartup) || other.isStartup == isStartup));
}


@override
int get hashCode => Object.hash(runtimeType,id,isStartup);

@override
String toString() {
  return 'Tour(id: $id, isStartup: $isStartup)';
}


}

/// @nodoc
abstract mixin class $TourCopyWith<$Res>  {
  factory $TourCopyWith(Tour value, $Res Function(Tour) _then) = _$TourCopyWithImpl;
@useResult
$Res call({
 String id, bool isStartup
});




}
/// @nodoc
class _$TourCopyWithImpl<$Res>
    implements $TourCopyWith<$Res> {
  _$TourCopyWithImpl(this._self, this._then);

  final Tour _self;
  final $Res Function(Tour) _then;

/// Create a copy of Tour
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isStartup = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isStartup: null == isStartup ? _self.isStartup : isStartup // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Tour].
extension TourPatterns on Tour {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tour value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tour() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tour value)  $default,){
final _that = this;
switch (_that) {
case _Tour():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tour value)?  $default,){
final _that = this;
switch (_that) {
case _Tour() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool isStartup)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tour() when $default != null:
return $default(_that.id,_that.isStartup);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool isStartup)  $default,) {final _that = this;
switch (_that) {
case _Tour():
return $default(_that.id,_that.isStartup);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool isStartup)?  $default,) {final _that = this;
switch (_that) {
case _Tour() when $default != null:
return $default(_that.id,_that.isStartup);case _:
  return null;

}
}

}

/// @nodoc


class _Tour extends Tour {
  const _Tour({required this.id, required this.isStartup}): super._();
  

@override final  String id;
@override final  bool isStartup;

/// Create a copy of Tour
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TourCopyWith<_Tour> get copyWith => __$TourCopyWithImpl<_Tour>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tour&&(identical(other.id, id) || other.id == id)&&(identical(other.isStartup, isStartup) || other.isStartup == isStartup));
}


@override
int get hashCode => Object.hash(runtimeType,id,isStartup);

@override
String toString() {
  return 'Tour(id: $id, isStartup: $isStartup)';
}


}

/// @nodoc
abstract mixin class _$TourCopyWith<$Res> implements $TourCopyWith<$Res> {
  factory _$TourCopyWith(_Tour value, $Res Function(_Tour) _then) = __$TourCopyWithImpl;
@override @useResult
$Res call({
 String id, bool isStartup
});




}
/// @nodoc
class __$TourCopyWithImpl<$Res>
    implements _$TourCopyWith<$Res> {
  __$TourCopyWithImpl(this._self, this._then);

  final _Tour _self;
  final $Res Function(_Tour) _then;

/// Create a copy of Tour
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isStartup = null,}) {
  return _then(_Tour(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isStartup: null == isStartup ? _self.isStartup : isStartup // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
