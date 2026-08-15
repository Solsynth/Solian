// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'name_change_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnNameChangeCardOrder {

 String get purchaseId; String get orderId; double get amount;
/// Create a copy of SnNameChangeCardOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnNameChangeCardOrderCopyWith<SnNameChangeCardOrder> get copyWith => _$SnNameChangeCardOrderCopyWithImpl<SnNameChangeCardOrder>(this as SnNameChangeCardOrder, _$identity);

  /// Serializes this SnNameChangeCardOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnNameChangeCardOrder&&(identical(other.purchaseId, purchaseId) || other.purchaseId == purchaseId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purchaseId,orderId,amount);

@override
String toString() {
  return 'SnNameChangeCardOrder(purchaseId: $purchaseId, orderId: $orderId, amount: $amount)';
}


}

/// @nodoc
abstract mixin class $SnNameChangeCardOrderCopyWith<$Res>  {
  factory $SnNameChangeCardOrderCopyWith(SnNameChangeCardOrder value, $Res Function(SnNameChangeCardOrder) _then) = _$SnNameChangeCardOrderCopyWithImpl;
@useResult
$Res call({
 String purchaseId, String orderId, double amount
});




}
/// @nodoc
class _$SnNameChangeCardOrderCopyWithImpl<$Res>
    implements $SnNameChangeCardOrderCopyWith<$Res> {
  _$SnNameChangeCardOrderCopyWithImpl(this._self, this._then);

  final SnNameChangeCardOrder _self;
  final $Res Function(SnNameChangeCardOrder) _then;

/// Create a copy of SnNameChangeCardOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? purchaseId = null,Object? orderId = null,Object? amount = null,}) {
  return _then(SnNameChangeCardOrder(
purchaseId: null == purchaseId ? _self.purchaseId : purchaseId // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SnNameChangeCardOrder].
extension SnNameChangeCardOrderPatterns on SnNameChangeCardOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnNameChangeCardOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnNameChangeCardOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnNameChangeCardOrder value)  $default,){
final _that = this;
switch (_that) {
case _SnNameChangeCardOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnNameChangeCardOrder value)?  $default,){
final _that = this;
switch (_that) {
case _SnNameChangeCardOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String purchaseId,  String orderId,  double amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnNameChangeCardOrder() when $default != null:
return $default(_that.purchaseId,_that.orderId,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String purchaseId,  String orderId,  double amount)  $default,) {final _that = this;
switch (_that) {
case _SnNameChangeCardOrder():
return $default(_that.purchaseId,_that.orderId,_that.amount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String purchaseId,  String orderId,  double amount)?  $default,) {final _that = this;
switch (_that) {
case _SnNameChangeCardOrder() when $default != null:
return $default(_that.purchaseId,_that.orderId,_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnNameChangeCardOrder extends SnNameChangeCardOrder {
  const _SnNameChangeCardOrder({required this.purchaseId, required this.orderId, required this.amount}): super._();
  factory _SnNameChangeCardOrder.fromJson(Map<String, dynamic> json) => _$SnNameChangeCardOrderFromJson(json);

@override final  String purchaseId;
@override final  String orderId;
@override final  double amount;

/// Create a copy of SnNameChangeCardOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnNameChangeCardOrderCopyWith<_SnNameChangeCardOrder> get copyWith => __$SnNameChangeCardOrderCopyWithImpl<_SnNameChangeCardOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnNameChangeCardOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnNameChangeCardOrder&&(identical(other.purchaseId, purchaseId) || other.purchaseId == purchaseId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,purchaseId,orderId,amount);

@override
String toString() {
  return 'SnNameChangeCardOrder(purchaseId: $purchaseId, orderId: $orderId, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$SnNameChangeCardOrderCopyWith<$Res> implements $SnNameChangeCardOrderCopyWith<$Res> {
  factory _$SnNameChangeCardOrderCopyWith(_SnNameChangeCardOrder value, $Res Function(_SnNameChangeCardOrder) _then) = __$SnNameChangeCardOrderCopyWithImpl;
@override @useResult
$Res call({
 String purchaseId, String orderId, double amount
});




}
/// @nodoc
class __$SnNameChangeCardOrderCopyWithImpl<$Res>
    implements _$SnNameChangeCardOrderCopyWith<$Res> {
  __$SnNameChangeCardOrderCopyWithImpl(this._self, this._then);

  final _SnNameChangeCardOrder _self;
  final $Res Function(_SnNameChangeCardOrder) _then;

/// Create a copy of SnNameChangeCardOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? purchaseId = null,Object? orderId = null,Object? amount = null,}) {
  return _then(_SnNameChangeCardOrder(
purchaseId: null == purchaseId ? _self.purchaseId : purchaseId // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$SnNameChangeCardPurchase {

 String get id; String get accountId; String get orderId; double get amount; DateTime? get fulfilledAt; DateTime? get consumedAt;@SnNameChangeCardTargetTypeConverter() SnNameChangeCardTargetType? get targetType; String? get targetId; String? get oldName; String? get newName; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SnNameChangeCardPurchase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnNameChangeCardPurchaseCopyWith<SnNameChangeCardPurchase> get copyWith => _$SnNameChangeCardPurchaseCopyWithImpl<SnNameChangeCardPurchase>(this as SnNameChangeCardPurchase, _$identity);

  /// Serializes this SnNameChangeCardPurchase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnNameChangeCardPurchase&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.fulfilledAt, fulfilledAt) || other.fulfilledAt == fulfilledAt)&&(identical(other.consumedAt, consumedAt) || other.consumedAt == consumedAt)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.oldName, oldName) || other.oldName == oldName)&&(identical(other.newName, newName) || other.newName == newName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,orderId,amount,fulfilledAt,consumedAt,targetType,targetId,oldName,newName,createdAt,updatedAt);

@override
String toString() {
  return 'SnNameChangeCardPurchase(id: $id, accountId: $accountId, orderId: $orderId, amount: $amount, fulfilledAt: $fulfilledAt, consumedAt: $consumedAt, targetType: $targetType, targetId: $targetId, oldName: $oldName, newName: $newName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SnNameChangeCardPurchaseCopyWith<$Res>  {
  factory $SnNameChangeCardPurchaseCopyWith(SnNameChangeCardPurchase value, $Res Function(SnNameChangeCardPurchase) _then) = _$SnNameChangeCardPurchaseCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, String orderId, double amount, DateTime? fulfilledAt, DateTime? consumedAt,@SnNameChangeCardTargetTypeConverter() SnNameChangeCardTargetType? targetType, String? targetId, String? oldName, String? newName, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SnNameChangeCardPurchaseCopyWithImpl<$Res>
    implements $SnNameChangeCardPurchaseCopyWith<$Res> {
  _$SnNameChangeCardPurchaseCopyWithImpl(this._self, this._then);

  final SnNameChangeCardPurchase _self;
  final $Res Function(SnNameChangeCardPurchase) _then;

/// Create a copy of SnNameChangeCardPurchase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? orderId = null,Object? amount = null,Object? fulfilledAt = freezed,Object? consumedAt = freezed,Object? targetType = freezed,Object? targetId = freezed,Object? oldName = freezed,Object? newName = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(SnNameChangeCardPurchase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,fulfilledAt: freezed == fulfilledAt ? _self.fulfilledAt : fulfilledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,consumedAt: freezed == consumedAt ? _self.consumedAt : consumedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,targetType: freezed == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as SnNameChangeCardTargetType?,targetId: freezed == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String?,oldName: freezed == oldName ? _self.oldName : oldName // ignore: cast_nullable_to_non_nullable
as String?,newName: freezed == newName ? _self.newName : newName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SnNameChangeCardPurchase].
extension SnNameChangeCardPurchasePatterns on SnNameChangeCardPurchase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnNameChangeCardPurchase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnNameChangeCardPurchase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnNameChangeCardPurchase value)  $default,){
final _that = this;
switch (_that) {
case _SnNameChangeCardPurchase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnNameChangeCardPurchase value)?  $default,){
final _that = this;
switch (_that) {
case _SnNameChangeCardPurchase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  String orderId,  double amount,  DateTime? fulfilledAt,  DateTime? consumedAt, @SnNameChangeCardTargetTypeConverter()  SnNameChangeCardTargetType? targetType,  String? targetId,  String? oldName,  String? newName,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnNameChangeCardPurchase() when $default != null:
return $default(_that.id,_that.accountId,_that.orderId,_that.amount,_that.fulfilledAt,_that.consumedAt,_that.targetType,_that.targetId,_that.oldName,_that.newName,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  String orderId,  double amount,  DateTime? fulfilledAt,  DateTime? consumedAt, @SnNameChangeCardTargetTypeConverter()  SnNameChangeCardTargetType? targetType,  String? targetId,  String? oldName,  String? newName,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SnNameChangeCardPurchase():
return $default(_that.id,_that.accountId,_that.orderId,_that.amount,_that.fulfilledAt,_that.consumedAt,_that.targetType,_that.targetId,_that.oldName,_that.newName,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  String orderId,  double amount,  DateTime? fulfilledAt,  DateTime? consumedAt, @SnNameChangeCardTargetTypeConverter()  SnNameChangeCardTargetType? targetType,  String? targetId,  String? oldName,  String? newName,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnNameChangeCardPurchase() when $default != null:
return $default(_that.id,_that.accountId,_that.orderId,_that.amount,_that.fulfilledAt,_that.consumedAt,_that.targetType,_that.targetId,_that.oldName,_that.newName,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnNameChangeCardPurchase extends SnNameChangeCardPurchase {
  const _SnNameChangeCardPurchase({required this.id, required this.accountId, required this.orderId, required this.amount, this.fulfilledAt, this.consumedAt, @SnNameChangeCardTargetTypeConverter() this.targetType, this.targetId, this.oldName, this.newName, required this.createdAt, required this.updatedAt}): super._();
  factory _SnNameChangeCardPurchase.fromJson(Map<String, dynamic> json) => _$SnNameChangeCardPurchaseFromJson(json);

@override final  String id;
@override final  String accountId;
@override final  String orderId;
@override final  double amount;
@override final  DateTime? fulfilledAt;
@override final  DateTime? consumedAt;
@override@SnNameChangeCardTargetTypeConverter() final  SnNameChangeCardTargetType? targetType;
@override final  String? targetId;
@override final  String? oldName;
@override final  String? newName;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SnNameChangeCardPurchase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnNameChangeCardPurchaseCopyWith<_SnNameChangeCardPurchase> get copyWith => __$SnNameChangeCardPurchaseCopyWithImpl<_SnNameChangeCardPurchase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnNameChangeCardPurchaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnNameChangeCardPurchase&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.fulfilledAt, fulfilledAt) || other.fulfilledAt == fulfilledAt)&&(identical(other.consumedAt, consumedAt) || other.consumedAt == consumedAt)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.oldName, oldName) || other.oldName == oldName)&&(identical(other.newName, newName) || other.newName == newName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,orderId,amount,fulfilledAt,consumedAt,targetType,targetId,oldName,newName,createdAt,updatedAt);

@override
String toString() {
  return 'SnNameChangeCardPurchase(id: $id, accountId: $accountId, orderId: $orderId, amount: $amount, fulfilledAt: $fulfilledAt, consumedAt: $consumedAt, targetType: $targetType, targetId: $targetId, oldName: $oldName, newName: $newName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnNameChangeCardPurchaseCopyWith<$Res> implements $SnNameChangeCardPurchaseCopyWith<$Res> {
  factory _$SnNameChangeCardPurchaseCopyWith(_SnNameChangeCardPurchase value, $Res Function(_SnNameChangeCardPurchase) _then) = __$SnNameChangeCardPurchaseCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, String orderId, double amount, DateTime? fulfilledAt, DateTime? consumedAt,@SnNameChangeCardTargetTypeConverter() SnNameChangeCardTargetType? targetType, String? targetId, String? oldName, String? newName, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SnNameChangeCardPurchaseCopyWithImpl<$Res>
    implements _$SnNameChangeCardPurchaseCopyWith<$Res> {
  __$SnNameChangeCardPurchaseCopyWithImpl(this._self, this._then);

  final _SnNameChangeCardPurchase _self;
  final $Res Function(_SnNameChangeCardPurchase) _then;

/// Create a copy of SnNameChangeCardPurchase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? orderId = null,Object? amount = null,Object? fulfilledAt = freezed,Object? consumedAt = freezed,Object? targetType = freezed,Object? targetId = freezed,Object? oldName = freezed,Object? newName = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SnNameChangeCardPurchase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,fulfilledAt: freezed == fulfilledAt ? _self.fulfilledAt : fulfilledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,consumedAt: freezed == consumedAt ? _self.consumedAt : consumedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,targetType: freezed == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as SnNameChangeCardTargetType?,targetId: freezed == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String?,oldName: freezed == oldName ? _self.oldName : oldName // ignore: cast_nullable_to_non_nullable
as String?,newName: freezed == newName ? _self.newName : newName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
