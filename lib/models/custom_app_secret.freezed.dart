// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'custom_app_secret.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomAppSecret {

 String get id; String? get secret; DateTime get createdAt; String? get description; int? get expiresIn; bool? get isOidc;
/// Create a copy of CustomAppSecret
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomAppSecretCopyWith<CustomAppSecret> get copyWith => _$CustomAppSecretCopyWithImpl<CustomAppSecret>(this as CustomAppSecret, _$identity);

  /// Serializes this CustomAppSecret to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomAppSecret&&(identical(other.id, id) || other.id == id)&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.isOidc, isOidc) || other.isOidc == isOidc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,secret,createdAt,description,expiresIn,isOidc);

@override
String toString() {
  return 'CustomAppSecret(id: $id, secret: $secret, createdAt: $createdAt, description: $description, expiresIn: $expiresIn, isOidc: $isOidc)';
}


}

/// @nodoc
abstract mixin class $CustomAppSecretCopyWith<$Res>  {
  factory $CustomAppSecretCopyWith(CustomAppSecret value, $Res Function(CustomAppSecret) _then) = _$CustomAppSecretCopyWithImpl;
@useResult
$Res call({
 String id, String? secret, DateTime createdAt, String? description, int? expiresIn, bool? isOidc
});




}
/// @nodoc
class _$CustomAppSecretCopyWithImpl<$Res>
    implements $CustomAppSecretCopyWith<$Res> {
  _$CustomAppSecretCopyWithImpl(this._self, this._then);

  final CustomAppSecret _self;
  final $Res Function(CustomAppSecret) _then;

/// Create a copy of CustomAppSecret
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? secret = freezed,Object? createdAt = null,Object? description = freezed,Object? expiresIn = freezed,Object? isOidc = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,secret: freezed == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,isOidc: freezed == isOidc ? _self.isOidc : isOidc // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomAppSecret].
extension CustomAppSecretPatterns on CustomAppSecret {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomAppSecret value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomAppSecret() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomAppSecret value)  $default,){
final _that = this;
switch (_that) {
case _CustomAppSecret():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomAppSecret value)?  $default,){
final _that = this;
switch (_that) {
case _CustomAppSecret() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? secret,  DateTime createdAt,  String? description,  int? expiresIn,  bool? isOidc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomAppSecret() when $default != null:
return $default(_that.id,_that.secret,_that.createdAt,_that.description,_that.expiresIn,_that.isOidc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? secret,  DateTime createdAt,  String? description,  int? expiresIn,  bool? isOidc)  $default,) {final _that = this;
switch (_that) {
case _CustomAppSecret():
return $default(_that.id,_that.secret,_that.createdAt,_that.description,_that.expiresIn,_that.isOidc);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? secret,  DateTime createdAt,  String? description,  int? expiresIn,  bool? isOidc)?  $default,) {final _that = this;
switch (_that) {
case _CustomAppSecret() when $default != null:
return $default(_that.id,_that.secret,_that.createdAt,_that.description,_that.expiresIn,_that.isOidc);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomAppSecret implements CustomAppSecret {
  const _CustomAppSecret({required this.id, required this.secret, required this.createdAt, this.description, this.expiresIn, this.isOidc});
  factory _CustomAppSecret.fromJson(Map<String, dynamic> json) => _$CustomAppSecretFromJson(json);

@override final  String id;
@override final  String? secret;
@override final  DateTime createdAt;
@override final  String? description;
@override final  int? expiresIn;
@override final  bool? isOidc;

/// Create a copy of CustomAppSecret
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomAppSecretCopyWith<_CustomAppSecret> get copyWith => __$CustomAppSecretCopyWithImpl<_CustomAppSecret>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomAppSecretToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomAppSecret&&(identical(other.id, id) || other.id == id)&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.isOidc, isOidc) || other.isOidc == isOidc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,secret,createdAt,description,expiresIn,isOidc);

@override
String toString() {
  return 'CustomAppSecret(id: $id, secret: $secret, createdAt: $createdAt, description: $description, expiresIn: $expiresIn, isOidc: $isOidc)';
}


}

/// @nodoc
abstract mixin class _$CustomAppSecretCopyWith<$Res> implements $CustomAppSecretCopyWith<$Res> {
  factory _$CustomAppSecretCopyWith(_CustomAppSecret value, $Res Function(_CustomAppSecret) _then) = __$CustomAppSecretCopyWithImpl;
@override @useResult
$Res call({
 String id, String? secret, DateTime createdAt, String? description, int? expiresIn, bool? isOidc
});




}
/// @nodoc
class __$CustomAppSecretCopyWithImpl<$Res>
    implements _$CustomAppSecretCopyWith<$Res> {
  __$CustomAppSecretCopyWithImpl(this._self, this._then);

  final _CustomAppSecret _self;
  final $Res Function(_CustomAppSecret) _then;

/// Create a copy of CustomAppSecret
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? secret = freezed,Object? createdAt = null,Object? description = freezed,Object? expiresIn = freezed,Object? isOidc = freezed,}) {
  return _then(_CustomAppSecret(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,secret: freezed == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,isOidc: freezed == isOidc ? _self.isOidc : isOidc // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
