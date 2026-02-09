// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'autocomplete_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AutocompleteSuggestion {

 String get type; String get keyword; dynamic get data;
/// Create a copy of AutocompleteSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutocompleteSuggestionCopyWith<AutocompleteSuggestion> get copyWith => _$AutocompleteSuggestionCopyWithImpl<AutocompleteSuggestion>(this as AutocompleteSuggestion, _$identity);

  /// Serializes this AutocompleteSuggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutocompleteSuggestion&&(identical(other.type, type) || other.type == type)&&(identical(other.keyword, keyword) || other.keyword == keyword)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,keyword,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'AutocompleteSuggestion(type: $type, keyword: $keyword, data: $data)';
}


}

/// @nodoc
abstract mixin class $AutocompleteSuggestionCopyWith<$Res>  {
  factory $AutocompleteSuggestionCopyWith(AutocompleteSuggestion value, $Res Function(AutocompleteSuggestion) _then) = _$AutocompleteSuggestionCopyWithImpl;
@useResult
$Res call({
 String type, String keyword, dynamic data
});




}
/// @nodoc
class _$AutocompleteSuggestionCopyWithImpl<$Res>
    implements $AutocompleteSuggestionCopyWith<$Res> {
  _$AutocompleteSuggestionCopyWithImpl(this._self, this._then);

  final AutocompleteSuggestion _self;
  final $Res Function(AutocompleteSuggestion) _then;

/// Create a copy of AutocompleteSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? keyword = null,Object? data = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [AutocompleteSuggestion].
extension AutocompleteSuggestionPatterns on AutocompleteSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AutocompleteSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AutocompleteSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AutocompleteSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _AutocompleteSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AutocompleteSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _AutocompleteSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String keyword,  dynamic data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AutocompleteSuggestion() when $default != null:
return $default(_that.type,_that.keyword,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String keyword,  dynamic data)  $default,) {final _that = this;
switch (_that) {
case _AutocompleteSuggestion():
return $default(_that.type,_that.keyword,_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String keyword,  dynamic data)?  $default,) {final _that = this;
switch (_that) {
case _AutocompleteSuggestion() when $default != null:
return $default(_that.type,_that.keyword,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AutocompleteSuggestion implements AutocompleteSuggestion {
  const _AutocompleteSuggestion({required this.type, required this.keyword, required this.data});
  factory _AutocompleteSuggestion.fromJson(Map<String, dynamic> json) => _$AutocompleteSuggestionFromJson(json);

@override final  String type;
@override final  String keyword;
@override final  dynamic data;

/// Create a copy of AutocompleteSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AutocompleteSuggestionCopyWith<_AutocompleteSuggestion> get copyWith => __$AutocompleteSuggestionCopyWithImpl<_AutocompleteSuggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AutocompleteSuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AutocompleteSuggestion&&(identical(other.type, type) || other.type == type)&&(identical(other.keyword, keyword) || other.keyword == keyword)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,keyword,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'AutocompleteSuggestion(type: $type, keyword: $keyword, data: $data)';
}


}

/// @nodoc
abstract mixin class _$AutocompleteSuggestionCopyWith<$Res> implements $AutocompleteSuggestionCopyWith<$Res> {
  factory _$AutocompleteSuggestionCopyWith(_AutocompleteSuggestion value, $Res Function(_AutocompleteSuggestion) _then) = __$AutocompleteSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String type, String keyword, dynamic data
});




}
/// @nodoc
class __$AutocompleteSuggestionCopyWithImpl<$Res>
    implements _$AutocompleteSuggestionCopyWith<$Res> {
  __$AutocompleteSuggestionCopyWithImpl(this._self, this._then);

  final _AutocompleteSuggestion _self;
  final $Res Function(_AutocompleteSuggestion) _then;

/// Create a copy of AutocompleteSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? keyword = null,Object? data = freezed,}) {
  return _then(_AutocompleteSuggestion(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
