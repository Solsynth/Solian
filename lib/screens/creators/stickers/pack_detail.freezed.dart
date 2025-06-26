// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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
