// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bot_key.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnAccountApiKey {

 String get id; String get label; String get accountId; String get sessionId; DateTime get createdAt; DateTime get updatedAt; String? get key;
/// Create a copy of SnAccountApiKey
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountApiKeyCopyWith<SnAccountApiKey> get copyWith => _$SnAccountApiKeyCopyWithImpl<SnAccountApiKey>(this as SnAccountApiKey, _$identity);

  /// Serializes this SnAccountApiKey to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountApiKey&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.key, key) || other.key == key));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,accountId,sessionId,createdAt,updatedAt,key);

@override
String toString() {
  return 'SnAccountApiKey(id: $id, label: $label, accountId: $accountId, sessionId: $sessionId, createdAt: $createdAt, updatedAt: $updatedAt, key: $key)';
}


}

/// @nodoc
abstract mixin class $SnAccountApiKeyCopyWith<$Res>  {
  factory $SnAccountApiKeyCopyWith(SnAccountApiKey value, $Res Function(SnAccountApiKey) _then) = _$SnAccountApiKeyCopyWithImpl;
@useResult
$Res call({
 String id, String label, String accountId, String sessionId, DateTime createdAt, DateTime updatedAt, String? key
});




}
/// @nodoc
class _$SnAccountApiKeyCopyWithImpl<$Res>
    implements $SnAccountApiKeyCopyWith<$Res> {
  _$SnAccountApiKeyCopyWithImpl(this._self, this._then);

  final SnAccountApiKey _self;
  final $Res Function(SnAccountApiKey) _then;

/// Create a copy of SnAccountApiKey
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? accountId = null,Object? sessionId = null,Object? createdAt = null,Object? updatedAt = null,Object? key = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnAccountApiKey].
extension SnAccountApiKeyPatterns on SnAccountApiKey {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAccountApiKey value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAccountApiKey() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAccountApiKey value)  $default,){
final _that = this;
switch (_that) {
case _SnAccountApiKey():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAccountApiKey value)?  $default,){
final _that = this;
switch (_that) {
case _SnAccountApiKey() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String accountId,  String sessionId,  DateTime createdAt,  DateTime updatedAt,  String? key)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAccountApiKey() when $default != null:
return $default(_that.id,_that.label,_that.accountId,_that.sessionId,_that.createdAt,_that.updatedAt,_that.key);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String accountId,  String sessionId,  DateTime createdAt,  DateTime updatedAt,  String? key)  $default,) {final _that = this;
switch (_that) {
case _SnAccountApiKey():
return $default(_that.id,_that.label,_that.accountId,_that.sessionId,_that.createdAt,_that.updatedAt,_that.key);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String accountId,  String sessionId,  DateTime createdAt,  DateTime updatedAt,  String? key)?  $default,) {final _that = this;
switch (_that) {
case _SnAccountApiKey() when $default != null:
return $default(_that.id,_that.label,_that.accountId,_that.sessionId,_that.createdAt,_that.updatedAt,_that.key);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAccountApiKey implements SnAccountApiKey {
  const _SnAccountApiKey({required this.id, required this.label, required this.accountId, required this.sessionId, required this.createdAt, required this.updatedAt, this.key});
  factory _SnAccountApiKey.fromJson(Map<String, dynamic> json) => _$SnAccountApiKeyFromJson(json);

@override final  String id;
@override final  String label;
@override final  String accountId;
@override final  String sessionId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? key;

/// Create a copy of SnAccountApiKey
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountApiKeyCopyWith<_SnAccountApiKey> get copyWith => __$SnAccountApiKeyCopyWithImpl<_SnAccountApiKey>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountApiKeyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountApiKey&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.key, key) || other.key == key));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,accountId,sessionId,createdAt,updatedAt,key);

@override
String toString() {
  return 'SnAccountApiKey(id: $id, label: $label, accountId: $accountId, sessionId: $sessionId, createdAt: $createdAt, updatedAt: $updatedAt, key: $key)';
}


}

/// @nodoc
abstract mixin class _$SnAccountApiKeyCopyWith<$Res> implements $SnAccountApiKeyCopyWith<$Res> {
  factory _$SnAccountApiKeyCopyWith(_SnAccountApiKey value, $Res Function(_SnAccountApiKey) _then) = __$SnAccountApiKeyCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String accountId, String sessionId, DateTime createdAt, DateTime updatedAt, String? key
});




}
/// @nodoc
class __$SnAccountApiKeyCopyWithImpl<$Res>
    implements _$SnAccountApiKeyCopyWith<$Res> {
  __$SnAccountApiKeyCopyWithImpl(this._self, this._then);

  final _SnAccountApiKey _self;
  final $Res Function(_SnAccountApiKey) _then;

/// Create a copy of SnAccountApiKey
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? accountId = null,Object? sessionId = null,Object? createdAt = null,Object? updatedAt = null,Object? key = freezed,}) {
  return _then(_SnAccountApiKey(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
