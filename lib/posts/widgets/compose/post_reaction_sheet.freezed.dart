// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_reaction_sheet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReactionListQuery {

 String get symbol; String get postId;
/// Create a copy of ReactionListQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReactionListQueryCopyWith<ReactionListQuery> get copyWith => _$ReactionListQueryCopyWithImpl<ReactionListQuery>(this as ReactionListQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReactionListQuery&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.postId, postId) || other.postId == postId));
}


@override
int get hashCode => Object.hash(runtimeType,symbol,postId);

@override
String toString() {
  return 'ReactionListQuery(symbol: $symbol, postId: $postId)';
}


}

/// @nodoc
abstract mixin class $ReactionListQueryCopyWith<$Res>  {
  factory $ReactionListQueryCopyWith(ReactionListQuery value, $Res Function(ReactionListQuery) _then) = _$ReactionListQueryCopyWithImpl;
@useResult
$Res call({
 String symbol, String postId
});




}
/// @nodoc
class _$ReactionListQueryCopyWithImpl<$Res>
    implements $ReactionListQueryCopyWith<$Res> {
  _$ReactionListQueryCopyWithImpl(this._self, this._then);

  final ReactionListQuery _self;
  final $Res Function(ReactionListQuery) _then;

/// Create a copy of ReactionListQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? symbol = null,Object? postId = null,}) {
  return _then(_self.copyWith(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReactionListQuery].
extension ReactionListQueryPatterns on ReactionListQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReactionListQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReactionListQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReactionListQuery value)  $default,){
final _that = this;
switch (_that) {
case _ReactionListQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReactionListQuery value)?  $default,){
final _that = this;
switch (_that) {
case _ReactionListQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String symbol,  String postId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReactionListQuery() when $default != null:
return $default(_that.symbol,_that.postId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String symbol,  String postId)  $default,) {final _that = this;
switch (_that) {
case _ReactionListQuery():
return $default(_that.symbol,_that.postId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String symbol,  String postId)?  $default,) {final _that = this;
switch (_that) {
case _ReactionListQuery() when $default != null:
return $default(_that.symbol,_that.postId);case _:
  return null;

}
}

}

/// @nodoc


class _ReactionListQuery implements ReactionListQuery {
  const _ReactionListQuery({required this.symbol, required this.postId});
  

@override final  String symbol;
@override final  String postId;

/// Create a copy of ReactionListQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReactionListQueryCopyWith<_ReactionListQuery> get copyWith => __$ReactionListQueryCopyWithImpl<_ReactionListQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReactionListQuery&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.postId, postId) || other.postId == postId));
}


@override
int get hashCode => Object.hash(runtimeType,symbol,postId);

@override
String toString() {
  return 'ReactionListQuery(symbol: $symbol, postId: $postId)';
}


}

/// @nodoc
abstract mixin class _$ReactionListQueryCopyWith<$Res> implements $ReactionListQueryCopyWith<$Res> {
  factory _$ReactionListQueryCopyWith(_ReactionListQuery value, $Res Function(_ReactionListQuery) _then) = __$ReactionListQueryCopyWithImpl;
@override @useResult
$Res call({
 String symbol, String postId
});




}
/// @nodoc
class __$ReactionListQueryCopyWithImpl<$Res>
    implements _$ReactionListQueryCopyWith<$Res> {
  __$ReactionListQueryCopyWithImpl(this._self, this._then);

  final _ReactionListQuery _self;
  final $Res Function(_ReactionListQuery) _then;

/// Create a copy of ReactionListQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? symbol = null,Object? postId = null,}) {
  return _then(_ReactionListQuery(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
