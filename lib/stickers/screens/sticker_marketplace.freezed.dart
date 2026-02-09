// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sticker_marketplace.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarketplaceStickerQuery {

 bool get byUsage; String? get query;
/// Create a copy of MarketplaceStickerQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketplaceStickerQueryCopyWith<MarketplaceStickerQuery> get copyWith => _$MarketplaceStickerQueryCopyWithImpl<MarketplaceStickerQuery>(this as MarketplaceStickerQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketplaceStickerQuery&&(identical(other.byUsage, byUsage) || other.byUsage == byUsage)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,byUsage,query);

@override
String toString() {
  return 'MarketplaceStickerQuery(byUsage: $byUsage, query: $query)';
}


}

/// @nodoc
abstract mixin class $MarketplaceStickerQueryCopyWith<$Res>  {
  factory $MarketplaceStickerQueryCopyWith(MarketplaceStickerQuery value, $Res Function(MarketplaceStickerQuery) _then) = _$MarketplaceStickerQueryCopyWithImpl;
@useResult
$Res call({
 bool byUsage, String? query
});




}
/// @nodoc
class _$MarketplaceStickerQueryCopyWithImpl<$Res>
    implements $MarketplaceStickerQueryCopyWith<$Res> {
  _$MarketplaceStickerQueryCopyWithImpl(this._self, this._then);

  final MarketplaceStickerQuery _self;
  final $Res Function(MarketplaceStickerQuery) _then;

/// Create a copy of MarketplaceStickerQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? byUsage = null,Object? query = freezed,}) {
  return _then(_self.copyWith(
byUsage: null == byUsage ? _self.byUsage : byUsage // ignore: cast_nullable_to_non_nullable
as bool,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketplaceStickerQuery].
extension MarketplaceStickerQueryPatterns on MarketplaceStickerQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketplaceStickerQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketplaceStickerQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketplaceStickerQuery value)  $default,){
final _that = this;
switch (_that) {
case _MarketplaceStickerQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketplaceStickerQuery value)?  $default,){
final _that = this;
switch (_that) {
case _MarketplaceStickerQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool byUsage,  String? query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketplaceStickerQuery() when $default != null:
return $default(_that.byUsage,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool byUsage,  String? query)  $default,) {final _that = this;
switch (_that) {
case _MarketplaceStickerQuery():
return $default(_that.byUsage,_that.query);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool byUsage,  String? query)?  $default,) {final _that = this;
switch (_that) {
case _MarketplaceStickerQuery() when $default != null:
return $default(_that.byUsage,_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _MarketplaceStickerQuery implements MarketplaceStickerQuery {
  const _MarketplaceStickerQuery({required this.byUsage, required this.query});
  

@override final  bool byUsage;
@override final  String? query;

/// Create a copy of MarketplaceStickerQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketplaceStickerQueryCopyWith<_MarketplaceStickerQuery> get copyWith => __$MarketplaceStickerQueryCopyWithImpl<_MarketplaceStickerQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketplaceStickerQuery&&(identical(other.byUsage, byUsage) || other.byUsage == byUsage)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,byUsage,query);

@override
String toString() {
  return 'MarketplaceStickerQuery(byUsage: $byUsage, query: $query)';
}


}

/// @nodoc
abstract mixin class _$MarketplaceStickerQueryCopyWith<$Res> implements $MarketplaceStickerQueryCopyWith<$Res> {
  factory _$MarketplaceStickerQueryCopyWith(_MarketplaceStickerQuery value, $Res Function(_MarketplaceStickerQuery) _then) = __$MarketplaceStickerQueryCopyWithImpl;
@override @useResult
$Res call({
 bool byUsage, String? query
});




}
/// @nodoc
class __$MarketplaceStickerQueryCopyWithImpl<$Res>
    implements _$MarketplaceStickerQueryCopyWith<$Res> {
  __$MarketplaceStickerQueryCopyWithImpl(this._self, this._then);

  final _MarketplaceStickerQuery _self;
  final $Res Function(_MarketplaceStickerQuery) _then;

/// Create a copy of MarketplaceStickerQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? byUsage = null,Object? query = freezed,}) {
  return _then(_MarketplaceStickerQuery(
byUsage: null == byUsage ? _self.byUsage : byUsage // ignore: cast_nullable_to_non_nullable
as bool,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
