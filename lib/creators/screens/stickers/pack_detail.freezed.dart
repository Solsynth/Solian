// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pack_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StickerWithPackQuery {

 String get packId; String get id;
/// Create a copy of StickerWithPackQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StickerWithPackQueryCopyWith<StickerWithPackQuery> get copyWith => _$StickerWithPackQueryCopyWithImpl<StickerWithPackQuery>(this as StickerWithPackQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StickerWithPackQuery&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,packId,id);

@override
String toString() {
  return 'StickerWithPackQuery(packId: $packId, id: $id)';
}


}

/// @nodoc
abstract mixin class $StickerWithPackQueryCopyWith<$Res>  {
  factory $StickerWithPackQueryCopyWith(StickerWithPackQuery value, $Res Function(StickerWithPackQuery) _then) = _$StickerWithPackQueryCopyWithImpl;
@useResult
$Res call({
 String packId, String id
});




}
/// @nodoc
class _$StickerWithPackQueryCopyWithImpl<$Res>
    implements $StickerWithPackQueryCopyWith<$Res> {
  _$StickerWithPackQueryCopyWithImpl(this._self, this._then);

  final StickerWithPackQuery _self;
  final $Res Function(StickerWithPackQuery) _then;

/// Create a copy of StickerWithPackQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packId = null,Object? id = null,}) {
  return _then(_self.copyWith(
packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StickerWithPackQuery].
extension StickerWithPackQueryPatterns on StickerWithPackQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StickerWithPackQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StickerWithPackQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StickerWithPackQuery value)  $default,){
final _that = this;
switch (_that) {
case _StickerWithPackQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StickerWithPackQuery value)?  $default,){
final _that = this;
switch (_that) {
case _StickerWithPackQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String packId,  String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StickerWithPackQuery() when $default != null:
return $default(_that.packId,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String packId,  String id)  $default,) {final _that = this;
switch (_that) {
case _StickerWithPackQuery():
return $default(_that.packId,_that.id);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String packId,  String id)?  $default,) {final _that = this;
switch (_that) {
case _StickerWithPackQuery() when $default != null:
return $default(_that.packId,_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _StickerWithPackQuery implements StickerWithPackQuery {
  const _StickerWithPackQuery({required this.packId, required this.id});
  

@override final  String packId;
@override final  String id;

/// Create a copy of StickerWithPackQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StickerWithPackQueryCopyWith<_StickerWithPackQuery> get copyWith => __$StickerWithPackQueryCopyWithImpl<_StickerWithPackQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StickerWithPackQuery&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,packId,id);

@override
String toString() {
  return 'StickerWithPackQuery(packId: $packId, id: $id)';
}


}

/// @nodoc
abstract mixin class _$StickerWithPackQueryCopyWith<$Res> implements $StickerWithPackQueryCopyWith<$Res> {
  factory _$StickerWithPackQueryCopyWith(_StickerWithPackQuery value, $Res Function(_StickerWithPackQuery) _then) = __$StickerWithPackQueryCopyWithImpl;
@override @useResult
$Res call({
 String packId, String id
});




}
/// @nodoc
class __$StickerWithPackQueryCopyWithImpl<$Res>
    implements _$StickerWithPackQueryCopyWith<$Res> {
  __$StickerWithPackQueryCopyWithImpl(this._self, this._then);

  final _StickerWithPackQuery _self;
  final $Res Function(_StickerWithPackQuery) _then;

/// Create a copy of StickerWithPackQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packId = null,Object? id = null,}) {
  return _then(_StickerWithPackQuery(
packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
