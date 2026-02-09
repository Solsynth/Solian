// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'articles.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ArticleListQuery {

 String? get feedId; String? get publisherId;
/// Create a copy of ArticleListQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArticleListQueryCopyWith<ArticleListQuery> get copyWith => _$ArticleListQueryCopyWithImpl<ArticleListQuery>(this as ArticleListQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArticleListQuery&&(identical(other.feedId, feedId) || other.feedId == feedId)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId));
}


@override
int get hashCode => Object.hash(runtimeType,feedId,publisherId);

@override
String toString() {
  return 'ArticleListQuery(feedId: $feedId, publisherId: $publisherId)';
}


}

/// @nodoc
abstract mixin class $ArticleListQueryCopyWith<$Res>  {
  factory $ArticleListQueryCopyWith(ArticleListQuery value, $Res Function(ArticleListQuery) _then) = _$ArticleListQueryCopyWithImpl;
@useResult
$Res call({
 String? feedId, String? publisherId
});




}
/// @nodoc
class _$ArticleListQueryCopyWithImpl<$Res>
    implements $ArticleListQueryCopyWith<$Res> {
  _$ArticleListQueryCopyWithImpl(this._self, this._then);

  final ArticleListQuery _self;
  final $Res Function(ArticleListQuery) _then;

/// Create a copy of ArticleListQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? feedId = freezed,Object? publisherId = freezed,}) {
  return _then(_self.copyWith(
feedId: freezed == feedId ? _self.feedId : feedId // ignore: cast_nullable_to_non_nullable
as String?,publisherId: freezed == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ArticleListQuery].
extension ArticleListQueryPatterns on ArticleListQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArticleListQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArticleListQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArticleListQuery value)  $default,){
final _that = this;
switch (_that) {
case _ArticleListQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArticleListQuery value)?  $default,){
final _that = this;
switch (_that) {
case _ArticleListQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? feedId,  String? publisherId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArticleListQuery() when $default != null:
return $default(_that.feedId,_that.publisherId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? feedId,  String? publisherId)  $default,) {final _that = this;
switch (_that) {
case _ArticleListQuery():
return $default(_that.feedId,_that.publisherId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? feedId,  String? publisherId)?  $default,) {final _that = this;
switch (_that) {
case _ArticleListQuery() when $default != null:
return $default(_that.feedId,_that.publisherId);case _:
  return null;

}
}

}

/// @nodoc


class _ArticleListQuery implements ArticleListQuery {
  const _ArticleListQuery({this.feedId, this.publisherId});
  

@override final  String? feedId;
@override final  String? publisherId;

/// Create a copy of ArticleListQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArticleListQueryCopyWith<_ArticleListQuery> get copyWith => __$ArticleListQueryCopyWithImpl<_ArticleListQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArticleListQuery&&(identical(other.feedId, feedId) || other.feedId == feedId)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId));
}


@override
int get hashCode => Object.hash(runtimeType,feedId,publisherId);

@override
String toString() {
  return 'ArticleListQuery(feedId: $feedId, publisherId: $publisherId)';
}


}

/// @nodoc
abstract mixin class _$ArticleListQueryCopyWith<$Res> implements $ArticleListQueryCopyWith<$Res> {
  factory _$ArticleListQueryCopyWith(_ArticleListQuery value, $Res Function(_ArticleListQuery) _then) = __$ArticleListQueryCopyWithImpl;
@override @useResult
$Res call({
 String? feedId, String? publisherId
});




}
/// @nodoc
class __$ArticleListQueryCopyWithImpl<$Res>
    implements _$ArticleListQueryCopyWith<$Res> {
  __$ArticleListQueryCopyWithImpl(this._self, this._then);

  final _ArticleListQuery _self;
  final $Res Function(_ArticleListQuery) _then;

/// Create a copy of ArticleListQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? feedId = freezed,Object? publisherId = freezed,}) {
  return _then(_ArticleListQuery(
feedId: freezed == feedId ? _self.feedId : feedId // ignore: cast_nullable_to_non_nullable
as String?,publisherId: freezed == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
