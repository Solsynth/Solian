// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plugin_registry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MiniAppSyncResult {

 bool get success; List<String>? get added; List<String>? get updated; List<String>? get removed; String? get error;
/// Create a copy of MiniAppSyncResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MiniAppSyncResultCopyWith<MiniAppSyncResult> get copyWith => _$MiniAppSyncResultCopyWithImpl<MiniAppSyncResult>(this as MiniAppSyncResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MiniAppSyncResult&&(identical(other.success, success) || other.success == success)&&const DeepCollectionEquality().equals(other.added, added)&&const DeepCollectionEquality().equals(other.updated, updated)&&const DeepCollectionEquality().equals(other.removed, removed)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,success,const DeepCollectionEquality().hash(added),const DeepCollectionEquality().hash(updated),const DeepCollectionEquality().hash(removed),error);

@override
String toString() {
  return 'MiniAppSyncResult(success: $success, added: $added, updated: $updated, removed: $removed, error: $error)';
}


}

/// @nodoc
abstract mixin class $MiniAppSyncResultCopyWith<$Res>  {
  factory $MiniAppSyncResultCopyWith(MiniAppSyncResult value, $Res Function(MiniAppSyncResult) _then) = _$MiniAppSyncResultCopyWithImpl;
@useResult
$Res call({
 bool success, List<String>? added, List<String>? updated, List<String>? removed, String? error
});




}
/// @nodoc
class _$MiniAppSyncResultCopyWithImpl<$Res>
    implements $MiniAppSyncResultCopyWith<$Res> {
  _$MiniAppSyncResultCopyWithImpl(this._self, this._then);

  final MiniAppSyncResult _self;
  final $Res Function(MiniAppSyncResult) _then;

/// Create a copy of MiniAppSyncResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? added = freezed,Object? updated = freezed,Object? removed = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,added: freezed == added ? _self.added : added // ignore: cast_nullable_to_non_nullable
as List<String>?,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as List<String>?,removed: freezed == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as List<String>?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MiniAppSyncResult].
extension MiniAppSyncResultPatterns on MiniAppSyncResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MiniAppSyncResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MiniAppSyncResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MiniAppSyncResult value)  $default,){
final _that = this;
switch (_that) {
case _MiniAppSyncResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MiniAppSyncResult value)?  $default,){
final _that = this;
switch (_that) {
case _MiniAppSyncResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  List<String>? added,  List<String>? updated,  List<String>? removed,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MiniAppSyncResult() when $default != null:
return $default(_that.success,_that.added,_that.updated,_that.removed,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  List<String>? added,  List<String>? updated,  List<String>? removed,  String? error)  $default,) {final _that = this;
switch (_that) {
case _MiniAppSyncResult():
return $default(_that.success,_that.added,_that.updated,_that.removed,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  List<String>? added,  List<String>? updated,  List<String>? removed,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _MiniAppSyncResult() when $default != null:
return $default(_that.success,_that.added,_that.updated,_that.removed,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _MiniAppSyncResult implements MiniAppSyncResult {
  const _MiniAppSyncResult({required this.success, final  List<String>? added, final  List<String>? updated, final  List<String>? removed, this.error}): _added = added,_updated = updated,_removed = removed;
  

@override final  bool success;
 final  List<String>? _added;
@override List<String>? get added {
  final value = _added;
  if (value == null) return null;
  if (_added is EqualUnmodifiableListView) return _added;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _updated;
@override List<String>? get updated {
  final value = _updated;
  if (value == null) return null;
  if (_updated is EqualUnmodifiableListView) return _updated;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _removed;
@override List<String>? get removed {
  final value = _removed;
  if (value == null) return null;
  if (_removed is EqualUnmodifiableListView) return _removed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? error;

/// Create a copy of MiniAppSyncResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MiniAppSyncResultCopyWith<_MiniAppSyncResult> get copyWith => __$MiniAppSyncResultCopyWithImpl<_MiniAppSyncResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MiniAppSyncResult&&(identical(other.success, success) || other.success == success)&&const DeepCollectionEquality().equals(other._added, _added)&&const DeepCollectionEquality().equals(other._updated, _updated)&&const DeepCollectionEquality().equals(other._removed, _removed)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,success,const DeepCollectionEquality().hash(_added),const DeepCollectionEquality().hash(_updated),const DeepCollectionEquality().hash(_removed),error);

@override
String toString() {
  return 'MiniAppSyncResult(success: $success, added: $added, updated: $updated, removed: $removed, error: $error)';
}


}

/// @nodoc
abstract mixin class _$MiniAppSyncResultCopyWith<$Res> implements $MiniAppSyncResultCopyWith<$Res> {
  factory _$MiniAppSyncResultCopyWith(_MiniAppSyncResult value, $Res Function(_MiniAppSyncResult) _then) = __$MiniAppSyncResultCopyWithImpl;
@override @useResult
$Res call({
 bool success, List<String>? added, List<String>? updated, List<String>? removed, String? error
});




}
/// @nodoc
class __$MiniAppSyncResultCopyWithImpl<$Res>
    implements _$MiniAppSyncResultCopyWith<$Res> {
  __$MiniAppSyncResultCopyWithImpl(this._self, this._then);

  final _MiniAppSyncResult _self;
  final $Res Function(_MiniAppSyncResult) _then;

/// Create a copy of MiniAppSyncResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? added = freezed,Object? updated = freezed,Object? removed = freezed,Object? error = freezed,}) {
  return _then(_MiniAppSyncResult(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,added: freezed == added ? _self._added : added // ignore: cast_nullable_to_non_nullable
as List<String>?,updated: freezed == updated ? _self._updated : updated // ignore: cast_nullable_to_non_nullable
as List<String>?,removed: freezed == removed ? _self._removed : removed // ignore: cast_nullable_to_non_nullable
as List<String>?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
