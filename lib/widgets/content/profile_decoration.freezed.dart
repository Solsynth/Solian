// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_decoration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileDecoration {

 String get text; Color get color; Color? get textColor;
/// Create a copy of ProfileDecoration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileDecorationCopyWith<ProfileDecoration> get copyWith => _$ProfileDecorationCopyWithImpl<ProfileDecoration>(this as ProfileDecoration, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileDecoration&&(identical(other.text, text) || other.text == text)&&(identical(other.color, color) || other.color == color)&&(identical(other.textColor, textColor) || other.textColor == textColor));
}


@override
int get hashCode => Object.hash(runtimeType,text,color,textColor);

@override
String toString() {
  return 'ProfileDecoration(text: $text, color: $color, textColor: $textColor)';
}


}

/// @nodoc
abstract mixin class $ProfileDecorationCopyWith<$Res>  {
  factory $ProfileDecorationCopyWith(ProfileDecoration value, $Res Function(ProfileDecoration) _then) = _$ProfileDecorationCopyWithImpl;
@useResult
$Res call({
 String text, Color color, Color? textColor
});




}
/// @nodoc
class _$ProfileDecorationCopyWithImpl<$Res>
    implements $ProfileDecorationCopyWith<$Res> {
  _$ProfileDecorationCopyWithImpl(this._self, this._then);

  final ProfileDecoration _self;
  final $Res Function(ProfileDecoration) _then;

/// Create a copy of ProfileDecoration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? color = null,Object? textColor = freezed,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,textColor: freezed == textColor ? _self.textColor : textColor // ignore: cast_nullable_to_non_nullable
as Color?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileDecoration].
extension ProfileDecorationPatterns on ProfileDecoration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileDecoration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileDecoration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileDecoration value)  $default,){
final _that = this;
switch (_that) {
case _ProfileDecoration():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileDecoration value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileDecoration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  Color color,  Color? textColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileDecoration() when $default != null:
return $default(_that.text,_that.color,_that.textColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  Color color,  Color? textColor)  $default,) {final _that = this;
switch (_that) {
case _ProfileDecoration():
return $default(_that.text,_that.color,_that.textColor);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  Color color,  Color? textColor)?  $default,) {final _that = this;
switch (_that) {
case _ProfileDecoration() when $default != null:
return $default(_that.text,_that.color,_that.textColor);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileDecoration implements ProfileDecoration {
  const _ProfileDecoration({required this.text, required this.color, this.textColor});
  

@override final  String text;
@override final  Color color;
@override final  Color? textColor;

/// Create a copy of ProfileDecoration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileDecorationCopyWith<_ProfileDecoration> get copyWith => __$ProfileDecorationCopyWithImpl<_ProfileDecoration>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileDecoration&&(identical(other.text, text) || other.text == text)&&(identical(other.color, color) || other.color == color)&&(identical(other.textColor, textColor) || other.textColor == textColor));
}


@override
int get hashCode => Object.hash(runtimeType,text,color,textColor);

@override
String toString() {
  return 'ProfileDecoration(text: $text, color: $color, textColor: $textColor)';
}


}

/// @nodoc
abstract mixin class _$ProfileDecorationCopyWith<$Res> implements $ProfileDecorationCopyWith<$Res> {
  factory _$ProfileDecorationCopyWith(_ProfileDecoration value, $Res Function(_ProfileDecoration) _then) = __$ProfileDecorationCopyWithImpl;
@override @useResult
$Res call({
 String text, Color color, Color? textColor
});




}
/// @nodoc
class __$ProfileDecorationCopyWithImpl<$Res>
    implements _$ProfileDecorationCopyWith<$Res> {
  __$ProfileDecorationCopyWithImpl(this._self, this._then);

  final _ProfileDecoration _self;
  final $Res Function(_ProfileDecoration) _then;

/// Create a copy of ProfileDecoration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? color = null,Object? textColor = freezed,}) {
  return _then(_ProfileDecoration(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,textColor: freezed == textColor ? _self.textColor : textColor // ignore: cast_nullable_to_non_nullable
as Color?,
  ));
}


}

// dart format on
