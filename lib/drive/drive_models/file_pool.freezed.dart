// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_pool.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnFilePool {

 String get id; String get name; String? get description; Map<String, dynamic>? get storageConfig; Map<String, dynamic>? get billingConfig; Map<String, dynamic>? get policyConfig; bool? get isHidden; String? get accountId; String? get resourceIdentifier; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnFilePool
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFilePoolCopyWith<SnFilePool> get copyWith => _$SnFilePoolCopyWithImpl<SnFilePool>(this as SnFilePool, _$identity);

  /// Serializes this SnFilePool to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFilePool&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.storageConfig, storageConfig)&&const DeepCollectionEquality().equals(other.billingConfig, billingConfig)&&const DeepCollectionEquality().equals(other.policyConfig, policyConfig)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(storageConfig),const DeepCollectionEquality().hash(billingConfig),const DeepCollectionEquality().hash(policyConfig),isHidden,accountId,resourceIdentifier,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnFilePool(id: $id, name: $name, description: $description, storageConfig: $storageConfig, billingConfig: $billingConfig, policyConfig: $policyConfig, isHidden: $isHidden, accountId: $accountId, resourceIdentifier: $resourceIdentifier, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnFilePoolCopyWith<$Res>  {
  factory $SnFilePoolCopyWith(SnFilePool value, $Res Function(SnFilePool) _then) = _$SnFilePoolCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, Map<String, dynamic>? storageConfig, Map<String, dynamic>? billingConfig, Map<String, dynamic>? policyConfig, bool? isHidden, String? accountId, String? resourceIdentifier, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnFilePoolCopyWithImpl<$Res>
    implements $SnFilePoolCopyWith<$Res> {
  _$SnFilePoolCopyWithImpl(this._self, this._then);

  final SnFilePool _self;
  final $Res Function(SnFilePool) _then;

/// Create a copy of SnFilePool
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? storageConfig = freezed,Object? billingConfig = freezed,Object? policyConfig = freezed,Object? isHidden = freezed,Object? accountId = freezed,Object? resourceIdentifier = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,storageConfig: freezed == storageConfig ? _self.storageConfig : storageConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,billingConfig: freezed == billingConfig ? _self.billingConfig : billingConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,policyConfig: freezed == policyConfig ? _self.policyConfig : policyConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isHidden: freezed == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,resourceIdentifier: freezed == resourceIdentifier ? _self.resourceIdentifier : resourceIdentifier // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnFilePool].
extension SnFilePoolPatterns on SnFilePool {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFilePool value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFilePool() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFilePool value)  $default,){
final _that = this;
switch (_that) {
case _SnFilePool():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFilePool value)?  $default,){
final _that = this;
switch (_that) {
case _SnFilePool() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  Map<String, dynamic>? storageConfig,  Map<String, dynamic>? billingConfig,  Map<String, dynamic>? policyConfig,  bool? isHidden,  String? accountId,  String? resourceIdentifier,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFilePool() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.storageConfig,_that.billingConfig,_that.policyConfig,_that.isHidden,_that.accountId,_that.resourceIdentifier,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  Map<String, dynamic>? storageConfig,  Map<String, dynamic>? billingConfig,  Map<String, dynamic>? policyConfig,  bool? isHidden,  String? accountId,  String? resourceIdentifier,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnFilePool():
return $default(_that.id,_that.name,_that.description,_that.storageConfig,_that.billingConfig,_that.policyConfig,_that.isHidden,_that.accountId,_that.resourceIdentifier,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  Map<String, dynamic>? storageConfig,  Map<String, dynamic>? billingConfig,  Map<String, dynamic>? policyConfig,  bool? isHidden,  String? accountId,  String? resourceIdentifier,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnFilePool() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.storageConfig,_that.billingConfig,_that.policyConfig,_that.isHidden,_that.accountId,_that.resourceIdentifier,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFilePool implements SnFilePool {
  const _SnFilePool({required this.id, required this.name, this.description, final  Map<String, dynamic>? storageConfig, final  Map<String, dynamic>? billingConfig, final  Map<String, dynamic>? policyConfig, this.isHidden, this.accountId, this.resourceIdentifier, this.createdAt, this.updatedAt, this.deletedAt}): _storageConfig = storageConfig,_billingConfig = billingConfig,_policyConfig = policyConfig;
  factory _SnFilePool.fromJson(Map<String, dynamic> json) => _$SnFilePoolFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
 final  Map<String, dynamic>? _storageConfig;
@override Map<String, dynamic>? get storageConfig {
  final value = _storageConfig;
  if (value == null) return null;
  if (_storageConfig is EqualUnmodifiableMapView) return _storageConfig;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _billingConfig;
@override Map<String, dynamic>? get billingConfig {
  final value = _billingConfig;
  if (value == null) return null;
  if (_billingConfig is EqualUnmodifiableMapView) return _billingConfig;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _policyConfig;
@override Map<String, dynamic>? get policyConfig {
  final value = _policyConfig;
  if (value == null) return null;
  if (_policyConfig is EqualUnmodifiableMapView) return _policyConfig;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  bool? isHidden;
@override final  String? accountId;
@override final  String? resourceIdentifier;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnFilePool
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFilePoolCopyWith<_SnFilePool> get copyWith => __$SnFilePoolCopyWithImpl<_SnFilePool>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFilePoolToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFilePool&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._storageConfig, _storageConfig)&&const DeepCollectionEquality().equals(other._billingConfig, _billingConfig)&&const DeepCollectionEquality().equals(other._policyConfig, _policyConfig)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.resourceIdentifier, resourceIdentifier) || other.resourceIdentifier == resourceIdentifier)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(_storageConfig),const DeepCollectionEquality().hash(_billingConfig),const DeepCollectionEquality().hash(_policyConfig),isHidden,accountId,resourceIdentifier,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnFilePool(id: $id, name: $name, description: $description, storageConfig: $storageConfig, billingConfig: $billingConfig, policyConfig: $policyConfig, isHidden: $isHidden, accountId: $accountId, resourceIdentifier: $resourceIdentifier, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnFilePoolCopyWith<$Res> implements $SnFilePoolCopyWith<$Res> {
  factory _$SnFilePoolCopyWith(_SnFilePool value, $Res Function(_SnFilePool) _then) = __$SnFilePoolCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, Map<String, dynamic>? storageConfig, Map<String, dynamic>? billingConfig, Map<String, dynamic>? policyConfig, bool? isHidden, String? accountId, String? resourceIdentifier, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnFilePoolCopyWithImpl<$Res>
    implements _$SnFilePoolCopyWith<$Res> {
  __$SnFilePoolCopyWithImpl(this._self, this._then);

  final _SnFilePool _self;
  final $Res Function(_SnFilePool) _then;

/// Create a copy of SnFilePool
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? storageConfig = freezed,Object? billingConfig = freezed,Object? policyConfig = freezed,Object? isHidden = freezed,Object? accountId = freezed,Object? resourceIdentifier = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_SnFilePool(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,storageConfig: freezed == storageConfig ? _self._storageConfig : storageConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,billingConfig: freezed == billingConfig ? _self._billingConfig : billingConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,policyConfig: freezed == policyConfig ? _self._policyConfig : policyConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isHidden: freezed == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,resourceIdentifier: freezed == resourceIdentifier ? _self.resourceIdentifier : resourceIdentifier // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
