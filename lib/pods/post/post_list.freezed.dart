// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostListQuery {

 String? get pubName; String? get realm; int? get type; List<String>? get categories; List<String>? get tags; bool? get pinned; bool get shuffle; bool? get includeReplies; bool? get mediaOnly; String? get queryTerm; String? get order; int? get periodStart; int? get periodEnd; bool get orderDesc;
/// Create a copy of PostListQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostListQueryCopyWith<PostListQuery> get copyWith => _$PostListQueryCopyWithImpl<PostListQuery>(this as PostListQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostListQuery&&(identical(other.pubName, pubName) || other.pubName == pubName)&&(identical(other.realm, realm) || other.realm == realm)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.shuffle, shuffle) || other.shuffle == shuffle)&&(identical(other.includeReplies, includeReplies) || other.includeReplies == includeReplies)&&(identical(other.mediaOnly, mediaOnly) || other.mediaOnly == mediaOnly)&&(identical(other.queryTerm, queryTerm) || other.queryTerm == queryTerm)&&(identical(other.order, order) || other.order == order)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.orderDesc, orderDesc) || other.orderDesc == orderDesc));
}


@override
int get hashCode => Object.hash(runtimeType,pubName,realm,type,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(tags),pinned,shuffle,includeReplies,mediaOnly,queryTerm,order,periodStart,periodEnd,orderDesc);

@override
String toString() {
  return 'PostListQuery(pubName: $pubName, realm: $realm, type: $type, categories: $categories, tags: $tags, pinned: $pinned, shuffle: $shuffle, includeReplies: $includeReplies, mediaOnly: $mediaOnly, queryTerm: $queryTerm, order: $order, periodStart: $periodStart, periodEnd: $periodEnd, orderDesc: $orderDesc)';
}


}

/// @nodoc
abstract mixin class $PostListQueryCopyWith<$Res>  {
  factory $PostListQueryCopyWith(PostListQuery value, $Res Function(PostListQuery) _then) = _$PostListQueryCopyWithImpl;
@useResult
$Res call({
 String? pubName, String? realm, int? type, List<String>? categories, List<String>? tags, bool? pinned, bool shuffle, bool? includeReplies, bool? mediaOnly, String? queryTerm, String? order, int? periodStart, int? periodEnd, bool orderDesc
});




}
/// @nodoc
class _$PostListQueryCopyWithImpl<$Res>
    implements $PostListQueryCopyWith<$Res> {
  _$PostListQueryCopyWithImpl(this._self, this._then);

  final PostListQuery _self;
  final $Res Function(PostListQuery) _then;

/// Create a copy of PostListQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pubName = freezed,Object? realm = freezed,Object? type = freezed,Object? categories = freezed,Object? tags = freezed,Object? pinned = freezed,Object? shuffle = null,Object? includeReplies = freezed,Object? mediaOnly = freezed,Object? queryTerm = freezed,Object? order = freezed,Object? periodStart = freezed,Object? periodEnd = freezed,Object? orderDesc = null,}) {
  return _then(_self.copyWith(
pubName: freezed == pubName ? _self.pubName : pubName // ignore: cast_nullable_to_non_nullable
as String?,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,categories: freezed == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,pinned: freezed == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool?,shuffle: null == shuffle ? _self.shuffle : shuffle // ignore: cast_nullable_to_non_nullable
as bool,includeReplies: freezed == includeReplies ? _self.includeReplies : includeReplies // ignore: cast_nullable_to_non_nullable
as bool?,mediaOnly: freezed == mediaOnly ? _self.mediaOnly : mediaOnly // ignore: cast_nullable_to_non_nullable
as bool?,queryTerm: freezed == queryTerm ? _self.queryTerm : queryTerm // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as int?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as int?,orderDesc: null == orderDesc ? _self.orderDesc : orderDesc // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PostListQuery].
extension PostListQueryPatterns on PostListQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostListQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostListQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostListQuery value)  $default,){
final _that = this;
switch (_that) {
case _PostListQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostListQuery value)?  $default,){
final _that = this;
switch (_that) {
case _PostListQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? pubName,  String? realm,  int? type,  List<String>? categories,  List<String>? tags,  bool? pinned,  bool shuffle,  bool? includeReplies,  bool? mediaOnly,  String? queryTerm,  String? order,  int? periodStart,  int? periodEnd,  bool orderDesc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostListQuery() when $default != null:
return $default(_that.pubName,_that.realm,_that.type,_that.categories,_that.tags,_that.pinned,_that.shuffle,_that.includeReplies,_that.mediaOnly,_that.queryTerm,_that.order,_that.periodStart,_that.periodEnd,_that.orderDesc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? pubName,  String? realm,  int? type,  List<String>? categories,  List<String>? tags,  bool? pinned,  bool shuffle,  bool? includeReplies,  bool? mediaOnly,  String? queryTerm,  String? order,  int? periodStart,  int? periodEnd,  bool orderDesc)  $default,) {final _that = this;
switch (_that) {
case _PostListQuery():
return $default(_that.pubName,_that.realm,_that.type,_that.categories,_that.tags,_that.pinned,_that.shuffle,_that.includeReplies,_that.mediaOnly,_that.queryTerm,_that.order,_that.periodStart,_that.periodEnd,_that.orderDesc);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? pubName,  String? realm,  int? type,  List<String>? categories,  List<String>? tags,  bool? pinned,  bool shuffle,  bool? includeReplies,  bool? mediaOnly,  String? queryTerm,  String? order,  int? periodStart,  int? periodEnd,  bool orderDesc)?  $default,) {final _that = this;
switch (_that) {
case _PostListQuery() when $default != null:
return $default(_that.pubName,_that.realm,_that.type,_that.categories,_that.tags,_that.pinned,_that.shuffle,_that.includeReplies,_that.mediaOnly,_that.queryTerm,_that.order,_that.periodStart,_that.periodEnd,_that.orderDesc);case _:
  return null;

}
}

}

/// @nodoc


class _PostListQuery implements PostListQuery {
  const _PostListQuery({this.pubName, this.realm, this.type, final  List<String>? categories, final  List<String>? tags, this.pinned, this.shuffle = false, this.includeReplies, this.mediaOnly, this.queryTerm, this.order, this.periodStart, this.periodEnd, this.orderDesc = true}): _categories = categories,_tags = tags;
  

@override final  String? pubName;
@override final  String? realm;
@override final  int? type;
 final  List<String>? _categories;
@override List<String>? get categories {
  final value = _categories;
  if (value == null) return null;
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _tags;
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  bool? pinned;
@override@JsonKey() final  bool shuffle;
@override final  bool? includeReplies;
@override final  bool? mediaOnly;
@override final  String? queryTerm;
@override final  String? order;
@override final  int? periodStart;
@override final  int? periodEnd;
@override@JsonKey() final  bool orderDesc;

/// Create a copy of PostListQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostListQueryCopyWith<_PostListQuery> get copyWith => __$PostListQueryCopyWithImpl<_PostListQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostListQuery&&(identical(other.pubName, pubName) || other.pubName == pubName)&&(identical(other.realm, realm) || other.realm == realm)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.pinned, pinned) || other.pinned == pinned)&&(identical(other.shuffle, shuffle) || other.shuffle == shuffle)&&(identical(other.includeReplies, includeReplies) || other.includeReplies == includeReplies)&&(identical(other.mediaOnly, mediaOnly) || other.mediaOnly == mediaOnly)&&(identical(other.queryTerm, queryTerm) || other.queryTerm == queryTerm)&&(identical(other.order, order) || other.order == order)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&(identical(other.orderDesc, orderDesc) || other.orderDesc == orderDesc));
}


@override
int get hashCode => Object.hash(runtimeType,pubName,realm,type,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_tags),pinned,shuffle,includeReplies,mediaOnly,queryTerm,order,periodStart,periodEnd,orderDesc);

@override
String toString() {
  return 'PostListQuery(pubName: $pubName, realm: $realm, type: $type, categories: $categories, tags: $tags, pinned: $pinned, shuffle: $shuffle, includeReplies: $includeReplies, mediaOnly: $mediaOnly, queryTerm: $queryTerm, order: $order, periodStart: $periodStart, periodEnd: $periodEnd, orderDesc: $orderDesc)';
}


}

/// @nodoc
abstract mixin class _$PostListQueryCopyWith<$Res> implements $PostListQueryCopyWith<$Res> {
  factory _$PostListQueryCopyWith(_PostListQuery value, $Res Function(_PostListQuery) _then) = __$PostListQueryCopyWithImpl;
@override @useResult
$Res call({
 String? pubName, String? realm, int? type, List<String>? categories, List<String>? tags, bool? pinned, bool shuffle, bool? includeReplies, bool? mediaOnly, String? queryTerm, String? order, int? periodStart, int? periodEnd, bool orderDesc
});




}
/// @nodoc
class __$PostListQueryCopyWithImpl<$Res>
    implements _$PostListQueryCopyWith<$Res> {
  __$PostListQueryCopyWithImpl(this._self, this._then);

  final _PostListQuery _self;
  final $Res Function(_PostListQuery) _then;

/// Create a copy of PostListQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pubName = freezed,Object? realm = freezed,Object? type = freezed,Object? categories = freezed,Object? tags = freezed,Object? pinned = freezed,Object? shuffle = null,Object? includeReplies = freezed,Object? mediaOnly = freezed,Object? queryTerm = freezed,Object? order = freezed,Object? periodStart = freezed,Object? periodEnd = freezed,Object? orderDesc = null,}) {
  return _then(_PostListQuery(
pubName: freezed == pubName ? _self.pubName : pubName // ignore: cast_nullable_to_non_nullable
as String?,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,categories: freezed == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,pinned: freezed == pinned ? _self.pinned : pinned // ignore: cast_nullable_to_non_nullable
as bool?,shuffle: null == shuffle ? _self.shuffle : shuffle // ignore: cast_nullable_to_non_nullable
as bool,includeReplies: freezed == includeReplies ? _self.includeReplies : includeReplies // ignore: cast_nullable_to_non_nullable
as bool?,mediaOnly: freezed == mediaOnly ? _self.mediaOnly : mediaOnly // ignore: cast_nullable_to_non_nullable
as bool?,queryTerm: freezed == queryTerm ? _self.queryTerm : queryTerm // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as String?,periodStart: freezed == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as int?,periodEnd: freezed == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as int?,orderDesc: null == orderDesc ? _self.orderDesc : orderDesc // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
