// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'realm_quota_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RealmQuotaInfo {

 int get total; int get used; int get remaining; int get level; int get perkLevel; List<dynamic> get records;
/// Create a copy of RealmQuotaInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RealmQuotaInfoCopyWith<RealmQuotaInfo> get copyWith => _$RealmQuotaInfoCopyWithImpl<RealmQuotaInfo>(this as RealmQuotaInfo, _$identity);

  /// Serializes this RealmQuotaInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RealmQuotaInfo&&(identical(other.total, total) || other.total == total)&&(identical(other.used, used) || other.used == used)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.level, level) || other.level == level)&&(identical(other.perkLevel, perkLevel) || other.perkLevel == perkLevel)&&const DeepCollectionEquality().equals(other.records, records));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,used,remaining,level,perkLevel,const DeepCollectionEquality().hash(records));

@override
String toString() {
  return 'RealmQuotaInfo(total: $total, used: $used, remaining: $remaining, level: $level, perkLevel: $perkLevel, records: $records)';
}


}

/// @nodoc
abstract mixin class $RealmQuotaInfoCopyWith<$Res>  {
  factory $RealmQuotaInfoCopyWith(RealmQuotaInfo value, $Res Function(RealmQuotaInfo) _then) = _$RealmQuotaInfoCopyWithImpl;
@useResult
$Res call({
 int total, int used, int remaining, int level, int perkLevel, List<dynamic> records
});




}
/// @nodoc
class _$RealmQuotaInfoCopyWithImpl<$Res>
    implements $RealmQuotaInfoCopyWith<$Res> {
  _$RealmQuotaInfoCopyWithImpl(this._self, this._then);

  final RealmQuotaInfo _self;
  final $Res Function(RealmQuotaInfo) _then;

/// Create a copy of RealmQuotaInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? used = null,Object? remaining = null,Object? level = null,Object? perkLevel = null,Object? records = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,used: null == used ? _self.used : used // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,perkLevel: null == perkLevel ? _self.perkLevel : perkLevel // ignore: cast_nullable_to_non_nullable
as int,records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [RealmQuotaInfo].
extension RealmQuotaInfoPatterns on RealmQuotaInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RealmQuotaInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RealmQuotaInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RealmQuotaInfo value)  $default,){
final _that = this;
switch (_that) {
case _RealmQuotaInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RealmQuotaInfo value)?  $default,){
final _that = this;
switch (_that) {
case _RealmQuotaInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int used,  int remaining,  int level,  int perkLevel,  List<dynamic> records)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RealmQuotaInfo() when $default != null:
return $default(_that.total,_that.used,_that.remaining,_that.level,_that.perkLevel,_that.records);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int used,  int remaining,  int level,  int perkLevel,  List<dynamic> records)  $default,) {final _that = this;
switch (_that) {
case _RealmQuotaInfo():
return $default(_that.total,_that.used,_that.remaining,_that.level,_that.perkLevel,_that.records);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int used,  int remaining,  int level,  int perkLevel,  List<dynamic> records)?  $default,) {final _that = this;
switch (_that) {
case _RealmQuotaInfo() when $default != null:
return $default(_that.total,_that.used,_that.remaining,_that.level,_that.perkLevel,_that.records);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RealmQuotaInfo implements RealmQuotaInfo {
  const _RealmQuotaInfo({required this.total, required this.used, required this.remaining, required this.level, required this.perkLevel, required final  List<dynamic> records}): _records = records;
  factory _RealmQuotaInfo.fromJson(Map<String, dynamic> json) => _$RealmQuotaInfoFromJson(json);

@override final  int total;
@override final  int used;
@override final  int remaining;
@override final  int level;
@override final  int perkLevel;
 final  List<dynamic> _records;
@override List<dynamic> get records {
  if (_records is EqualUnmodifiableListView) return _records;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_records);
}


/// Create a copy of RealmQuotaInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RealmQuotaInfoCopyWith<_RealmQuotaInfo> get copyWith => __$RealmQuotaInfoCopyWithImpl<_RealmQuotaInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RealmQuotaInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RealmQuotaInfo&&(identical(other.total, total) || other.total == total)&&(identical(other.used, used) || other.used == used)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.level, level) || other.level == level)&&(identical(other.perkLevel, perkLevel) || other.perkLevel == perkLevel)&&const DeepCollectionEquality().equals(other._records, _records));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,used,remaining,level,perkLevel,const DeepCollectionEquality().hash(_records));

@override
String toString() {
  return 'RealmQuotaInfo(total: $total, used: $used, remaining: $remaining, level: $level, perkLevel: $perkLevel, records: $records)';
}


}

/// @nodoc
abstract mixin class _$RealmQuotaInfoCopyWith<$Res> implements $RealmQuotaInfoCopyWith<$Res> {
  factory _$RealmQuotaInfoCopyWith(_RealmQuotaInfo value, $Res Function(_RealmQuotaInfo) _then) = __$RealmQuotaInfoCopyWithImpl;
@override @useResult
$Res call({
 int total, int used, int remaining, int level, int perkLevel, List<dynamic> records
});




}
/// @nodoc
class __$RealmQuotaInfoCopyWithImpl<$Res>
    implements _$RealmQuotaInfoCopyWith<$Res> {
  __$RealmQuotaInfoCopyWithImpl(this._self, this._then);

  final _RealmQuotaInfo _self;
  final $Res Function(_RealmQuotaInfo) _then;

/// Create a copy of RealmQuotaInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? used = null,Object? remaining = null,Object? level = null,Object? perkLevel = null,Object? records = null,}) {
  return _then(_RealmQuotaInfo(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,used: null == used ? _self.used : used // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,perkLevel: null == perkLevel ? _self.perkLevel : perkLevel // ignore: cast_nullable_to_non_nullable
as int,records: null == records ? _self._records : records // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}


}

// dart format on
