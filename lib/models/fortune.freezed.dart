// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fortune.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnFortuneSaying {

 String get content; String get source; String get language;
/// Create a copy of SnFortuneSaying
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFortuneSayingCopyWith<SnFortuneSaying> get copyWith => _$SnFortuneSayingCopyWithImpl<SnFortuneSaying>(this as SnFortuneSaying, _$identity);

  /// Serializes this SnFortuneSaying to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFortuneSaying&&(identical(other.content, content) || other.content == content)&&(identical(other.source, source) || other.source == source)&&(identical(other.language, language) || other.language == language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,source,language);

@override
String toString() {
  return 'SnFortuneSaying(content: $content, source: $source, language: $language)';
}


}

/// @nodoc
abstract mixin class $SnFortuneSayingCopyWith<$Res>  {
  factory $SnFortuneSayingCopyWith(SnFortuneSaying value, $Res Function(SnFortuneSaying) _then) = _$SnFortuneSayingCopyWithImpl;
@useResult
$Res call({
 String content, String source, String language
});




}
/// @nodoc
class _$SnFortuneSayingCopyWithImpl<$Res>
    implements $SnFortuneSayingCopyWith<$Res> {
  _$SnFortuneSayingCopyWithImpl(this._self, this._then);

  final SnFortuneSaying _self;
  final $Res Function(SnFortuneSaying) _then;

/// Create a copy of SnFortuneSaying
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? content = null,Object? source = null,Object? language = null,}) {
  return _then(_self.copyWith(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnFortuneSaying].
extension SnFortuneSayingPatterns on SnFortuneSaying {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFortuneSaying value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFortuneSaying() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFortuneSaying value)  $default,){
final _that = this;
switch (_that) {
case _SnFortuneSaying():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFortuneSaying value)?  $default,){
final _that = this;
switch (_that) {
case _SnFortuneSaying() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String content,  String source,  String language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFortuneSaying() when $default != null:
return $default(_that.content,_that.source,_that.language);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String content,  String source,  String language)  $default,) {final _that = this;
switch (_that) {
case _SnFortuneSaying():
return $default(_that.content,_that.source,_that.language);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String content,  String source,  String language)?  $default,) {final _that = this;
switch (_that) {
case _SnFortuneSaying() when $default != null:
return $default(_that.content,_that.source,_that.language);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFortuneSaying implements SnFortuneSaying {
  const _SnFortuneSaying({required this.content, required this.source, required this.language});
  factory _SnFortuneSaying.fromJson(Map<String, dynamic> json) => _$SnFortuneSayingFromJson(json);

@override final  String content;
@override final  String source;
@override final  String language;

/// Create a copy of SnFortuneSaying
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFortuneSayingCopyWith<_SnFortuneSaying> get copyWith => __$SnFortuneSayingCopyWithImpl<_SnFortuneSaying>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFortuneSayingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFortuneSaying&&(identical(other.content, content) || other.content == content)&&(identical(other.source, source) || other.source == source)&&(identical(other.language, language) || other.language == language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,content,source,language);

@override
String toString() {
  return 'SnFortuneSaying(content: $content, source: $source, language: $language)';
}


}

/// @nodoc
abstract mixin class _$SnFortuneSayingCopyWith<$Res> implements $SnFortuneSayingCopyWith<$Res> {
  factory _$SnFortuneSayingCopyWith(_SnFortuneSaying value, $Res Function(_SnFortuneSaying) _then) = __$SnFortuneSayingCopyWithImpl;
@override @useResult
$Res call({
 String content, String source, String language
});




}
/// @nodoc
class __$SnFortuneSayingCopyWithImpl<$Res>
    implements _$SnFortuneSayingCopyWith<$Res> {
  __$SnFortuneSayingCopyWithImpl(this._self, this._then);

  final _SnFortuneSaying _self;
  final $Res Function(_SnFortuneSaying) _then;

/// Create a copy of SnFortuneSaying
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? content = null,Object? source = null,Object? language = null,}) {
  return _then(_SnFortuneSaying(
content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
