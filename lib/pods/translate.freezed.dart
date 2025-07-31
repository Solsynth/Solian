// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TranslateQuery {

 String get text; String get lang;
/// Create a copy of TranslateQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslateQueryCopyWith<TranslateQuery> get copyWith => _$TranslateQueryCopyWithImpl<TranslateQuery>(this as TranslateQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranslateQuery&&(identical(other.text, text) || other.text == text)&&(identical(other.lang, lang) || other.lang == lang));
}


@override
int get hashCode => Object.hash(runtimeType,text,lang);

@override
String toString() {
  return 'TranslateQuery(text: $text, lang: $lang)';
}


}

/// @nodoc
abstract mixin class $TranslateQueryCopyWith<$Res>  {
  factory $TranslateQueryCopyWith(TranslateQuery value, $Res Function(TranslateQuery) _then) = _$TranslateQueryCopyWithImpl;
@useResult
$Res call({
 String text, String lang
});




}
/// @nodoc
class _$TranslateQueryCopyWithImpl<$Res>
    implements $TranslateQueryCopyWith<$Res> {
  _$TranslateQueryCopyWithImpl(this._self, this._then);

  final TranslateQuery _self;
  final $Res Function(TranslateQuery) _then;

/// Create a copy of TranslateQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? lang = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TranslateQuery].
extension TranslateQueryPatterns on TranslateQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranslateQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranslateQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranslateQuery value)  $default,){
final _that = this;
switch (_that) {
case _TranslateQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranslateQuery value)?  $default,){
final _that = this;
switch (_that) {
case _TranslateQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  String lang)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranslateQuery() when $default != null:
return $default(_that.text,_that.lang);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  String lang)  $default,) {final _that = this;
switch (_that) {
case _TranslateQuery():
return $default(_that.text,_that.lang);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  String lang)?  $default,) {final _that = this;
switch (_that) {
case _TranslateQuery() when $default != null:
return $default(_that.text,_that.lang);case _:
  return null;

}
}

}

/// @nodoc


class _TranslateQuery implements TranslateQuery {
  const _TranslateQuery({required this.text, required this.lang});
  

@override final  String text;
@override final  String lang;

/// Create a copy of TranslateQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslateQueryCopyWith<_TranslateQuery> get copyWith => __$TranslateQueryCopyWithImpl<_TranslateQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranslateQuery&&(identical(other.text, text) || other.text == text)&&(identical(other.lang, lang) || other.lang == lang));
}


@override
int get hashCode => Object.hash(runtimeType,text,lang);

@override
String toString() {
  return 'TranslateQuery(text: $text, lang: $lang)';
}


}

/// @nodoc
abstract mixin class _$TranslateQueryCopyWith<$Res> implements $TranslateQueryCopyWith<$Res> {
  factory _$TranslateQueryCopyWith(_TranslateQuery value, $Res Function(_TranslateQuery) _then) = __$TranslateQueryCopyWithImpl;
@override @useResult
$Res call({
 String text, String lang
});




}
/// @nodoc
class __$TranslateQueryCopyWithImpl<$Res>
    implements _$TranslateQueryCopyWith<$Res> {
  __$TranslateQueryCopyWithImpl(this._self, this._then);

  final _TranslateQuery _self;
  final $Res Function(_TranslateQuery) _then;

/// Create a copy of TranslateQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? lang = null,}) {
  return _then(_TranslateQuery(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
