// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnWallet {

 String get id; List<SnWalletPocket> get pockets; String get accountId; SnAccount? get account; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnWallet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnWalletCopyWith<SnWallet> get copyWith => _$SnWalletCopyWithImpl<SnWallet>(this as SnWallet, _$identity);

  /// Serializes this SnWallet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnWallet&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.pockets, pockets)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(pockets),accountId,account,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnWallet(id: $id, pockets: $pockets, accountId: $accountId, account: $account, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnWalletCopyWith<$Res>  {
  factory $SnWalletCopyWith(SnWallet value, $Res Function(SnWallet) _then) = _$SnWalletCopyWithImpl;
@useResult
$Res call({
 String id, List<SnWalletPocket> pockets, String accountId, SnAccount? account, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnWalletCopyWithImpl<$Res>
    implements $SnWalletCopyWith<$Res> {
  _$SnWalletCopyWithImpl(this._self, this._then);

  final SnWallet _self;
  final $Res Function(SnWallet) _then;

/// Create a copy of SnWallet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? pockets = null,Object? accountId = null,Object? account = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pockets: null == pockets ? _self.pockets : pockets // ignore: cast_nullable_to_non_nullable
as List<SnWalletPocket>,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnWallet
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnWallet].
extension SnWalletPatterns on SnWallet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnWallet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnWallet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnWallet value)  $default,){
final _that = this;
switch (_that) {
case _SnWallet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnWallet value)?  $default,){
final _that = this;
switch (_that) {
case _SnWallet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<SnWalletPocket> pockets,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnWallet() when $default != null:
return $default(_that.id,_that.pockets,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<SnWalletPocket> pockets,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnWallet():
return $default(_that.id,_that.pockets,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<SnWalletPocket> pockets,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnWallet() when $default != null:
return $default(_that.id,_that.pockets,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnWallet implements SnWallet {
  const _SnWallet({required this.id, required final  List<SnWalletPocket> pockets, required this.accountId, required this.account, required this.createdAt, required this.updatedAt, required this.deletedAt}): _pockets = pockets;
  factory _SnWallet.fromJson(Map<String, dynamic> json) => _$SnWalletFromJson(json);

@override final  String id;
 final  List<SnWalletPocket> _pockets;
@override List<SnWalletPocket> get pockets {
  if (_pockets is EqualUnmodifiableListView) return _pockets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pockets);
}

@override final  String accountId;
@override final  SnAccount? account;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnWallet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnWalletCopyWith<_SnWallet> get copyWith => __$SnWalletCopyWithImpl<_SnWallet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnWalletToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnWallet&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._pockets, _pockets)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_pockets),accountId,account,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnWallet(id: $id, pockets: $pockets, accountId: $accountId, account: $account, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnWalletCopyWith<$Res> implements $SnWalletCopyWith<$Res> {
  factory _$SnWalletCopyWith(_SnWallet value, $Res Function(_SnWallet) _then) = __$SnWalletCopyWithImpl;
@override @useResult
$Res call({
 String id, List<SnWalletPocket> pockets, String accountId, SnAccount? account, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnWalletCopyWithImpl<$Res>
    implements _$SnWalletCopyWith<$Res> {
  __$SnWalletCopyWithImpl(this._self, this._then);

  final _SnWallet _self;
  final $Res Function(_SnWallet) _then;

/// Create a copy of SnWallet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? pockets = null,Object? accountId = null,Object? account = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnWallet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,pockets: null == pockets ? _self._pockets : pockets // ignore: cast_nullable_to_non_nullable
as List<SnWalletPocket>,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnWallet
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// @nodoc
mixin _$SnWalletPocket {

 String get id; String get currency; double get amount; String get walletId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnWalletPocket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnWalletPocketCopyWith<SnWalletPocket> get copyWith => _$SnWalletPocketCopyWithImpl<SnWalletPocket>(this as SnWalletPocket, _$identity);

  /// Serializes this SnWalletPocket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnWalletPocket&&(identical(other.id, id) || other.id == id)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,currency,amount,walletId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnWalletPocket(id: $id, currency: $currency, amount: $amount, walletId: $walletId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnWalletPocketCopyWith<$Res>  {
  factory $SnWalletPocketCopyWith(SnWalletPocket value, $Res Function(SnWalletPocket) _then) = _$SnWalletPocketCopyWithImpl;
@useResult
$Res call({
 String id, String currency, double amount, String walletId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnWalletPocketCopyWithImpl<$Res>
    implements $SnWalletPocketCopyWith<$Res> {
  _$SnWalletPocketCopyWithImpl(this._self, this._then);

  final SnWalletPocket _self;
  final $Res Function(SnWalletPocket) _then;

/// Create a copy of SnWalletPocket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? currency = null,Object? amount = null,Object? walletId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnWalletPocket].
extension SnWalletPocketPatterns on SnWalletPocket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnWalletPocket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnWalletPocket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnWalletPocket value)  $default,){
final _that = this;
switch (_that) {
case _SnWalletPocket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnWalletPocket value)?  $default,){
final _that = this;
switch (_that) {
case _SnWalletPocket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String currency,  double amount,  String walletId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnWalletPocket() when $default != null:
return $default(_that.id,_that.currency,_that.amount,_that.walletId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String currency,  double amount,  String walletId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnWalletPocket():
return $default(_that.id,_that.currency,_that.amount,_that.walletId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String currency,  double amount,  String walletId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnWalletPocket() when $default != null:
return $default(_that.id,_that.currency,_that.amount,_that.walletId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnWalletPocket implements SnWalletPocket {
  const _SnWalletPocket({required this.id, required this.currency, required this.amount, required this.walletId, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnWalletPocket.fromJson(Map<String, dynamic> json) => _$SnWalletPocketFromJson(json);

@override final  String id;
@override final  String currency;
@override final  double amount;
@override final  String walletId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnWalletPocket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnWalletPocketCopyWith<_SnWalletPocket> get copyWith => __$SnWalletPocketCopyWithImpl<_SnWalletPocket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnWalletPocketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnWalletPocket&&(identical(other.id, id) || other.id == id)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,currency,amount,walletId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnWalletPocket(id: $id, currency: $currency, amount: $amount, walletId: $walletId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnWalletPocketCopyWith<$Res> implements $SnWalletPocketCopyWith<$Res> {
  factory _$SnWalletPocketCopyWith(_SnWalletPocket value, $Res Function(_SnWalletPocket) _then) = __$SnWalletPocketCopyWithImpl;
@override @useResult
$Res call({
 String id, String currency, double amount, String walletId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnWalletPocketCopyWithImpl<$Res>
    implements _$SnWalletPocketCopyWith<$Res> {
  __$SnWalletPocketCopyWithImpl(this._self, this._then);

  final _SnWalletPocket _self;
  final $Res Function(_SnWalletPocket) _then;

/// Create a copy of SnWalletPocket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? currency = null,Object? amount = null,Object? walletId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnWalletPocket(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnTransaction {

 String get id; String get currency; double get amount; String? get remarks; int get type; String? get payerWalletId; SnWallet? get payerWallet; String? get payeeWalletId; SnWallet? get payeeWallet; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnTransactionCopyWith<SnTransaction> get copyWith => _$SnTransactionCopyWithImpl<SnTransaction>(this as SnTransaction, _$identity);

  /// Serializes this SnTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.type, type) || other.type == type)&&(identical(other.payerWalletId, payerWalletId) || other.payerWalletId == payerWalletId)&&(identical(other.payerWallet, payerWallet) || other.payerWallet == payerWallet)&&(identical(other.payeeWalletId, payeeWalletId) || other.payeeWalletId == payeeWalletId)&&(identical(other.payeeWallet, payeeWallet) || other.payeeWallet == payeeWallet)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,currency,amount,remarks,type,payerWalletId,payerWallet,payeeWalletId,payeeWallet,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnTransaction(id: $id, currency: $currency, amount: $amount, remarks: $remarks, type: $type, payerWalletId: $payerWalletId, payerWallet: $payerWallet, payeeWalletId: $payeeWalletId, payeeWallet: $payeeWallet, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnTransactionCopyWith<$Res>  {
  factory $SnTransactionCopyWith(SnTransaction value, $Res Function(SnTransaction) _then) = _$SnTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String currency, double amount, String? remarks, int type, String? payerWalletId, SnWallet? payerWallet, String? payeeWalletId, SnWallet? payeeWallet, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnWalletCopyWith<$Res>? get payerWallet;$SnWalletCopyWith<$Res>? get payeeWallet;

}
/// @nodoc
class _$SnTransactionCopyWithImpl<$Res>
    implements $SnTransactionCopyWith<$Res> {
  _$SnTransactionCopyWithImpl(this._self, this._then);

  final SnTransaction _self;
  final $Res Function(SnTransaction) _then;

/// Create a copy of SnTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? currency = null,Object? amount = null,Object? remarks = freezed,Object? type = null,Object? payerWalletId = freezed,Object? payerWallet = freezed,Object? payeeWalletId = freezed,Object? payeeWallet = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,payerWalletId: freezed == payerWalletId ? _self.payerWalletId : payerWalletId // ignore: cast_nullable_to_non_nullable
as String?,payerWallet: freezed == payerWallet ? _self.payerWallet : payerWallet // ignore: cast_nullable_to_non_nullable
as SnWallet?,payeeWalletId: freezed == payeeWalletId ? _self.payeeWalletId : payeeWalletId // ignore: cast_nullable_to_non_nullable
as String?,payeeWallet: freezed == payeeWallet ? _self.payeeWallet : payeeWallet // ignore: cast_nullable_to_non_nullable
as SnWallet?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnWalletCopyWith<$Res>? get payerWallet {
    if (_self.payerWallet == null) {
    return null;
  }

  return $SnWalletCopyWith<$Res>(_self.payerWallet!, (value) {
    return _then(_self.copyWith(payerWallet: value));
  });
}/// Create a copy of SnTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnWalletCopyWith<$Res>? get payeeWallet {
    if (_self.payeeWallet == null) {
    return null;
  }

  return $SnWalletCopyWith<$Res>(_self.payeeWallet!, (value) {
    return _then(_self.copyWith(payeeWallet: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnTransaction].
extension SnTransactionPatterns on SnTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnTransaction value)  $default,){
final _that = this;
switch (_that) {
case _SnTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _SnTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String currency,  double amount,  String? remarks,  int type,  String? payerWalletId,  SnWallet? payerWallet,  String? payeeWalletId,  SnWallet? payeeWallet,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnTransaction() when $default != null:
return $default(_that.id,_that.currency,_that.amount,_that.remarks,_that.type,_that.payerWalletId,_that.payerWallet,_that.payeeWalletId,_that.payeeWallet,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String currency,  double amount,  String? remarks,  int type,  String? payerWalletId,  SnWallet? payerWallet,  String? payeeWalletId,  SnWallet? payeeWallet,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnTransaction():
return $default(_that.id,_that.currency,_that.amount,_that.remarks,_that.type,_that.payerWalletId,_that.payerWallet,_that.payeeWalletId,_that.payeeWallet,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String currency,  double amount,  String? remarks,  int type,  String? payerWalletId,  SnWallet? payerWallet,  String? payeeWalletId,  SnWallet? payeeWallet,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnTransaction() when $default != null:
return $default(_that.id,_that.currency,_that.amount,_that.remarks,_that.type,_that.payerWalletId,_that.payerWallet,_that.payeeWalletId,_that.payeeWallet,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnTransaction implements SnTransaction {
  const _SnTransaction({required this.id, required this.currency, required this.amount, required this.remarks, required this.type, required this.payerWalletId, required this.payerWallet, required this.payeeWalletId, required this.payeeWallet, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnTransaction.fromJson(Map<String, dynamic> json) => _$SnTransactionFromJson(json);

@override final  String id;
@override final  String currency;
@override final  double amount;
@override final  String? remarks;
@override final  int type;
@override final  String? payerWalletId;
@override final  SnWallet? payerWallet;
@override final  String? payeeWalletId;
@override final  SnWallet? payeeWallet;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnTransactionCopyWith<_SnTransaction> get copyWith => __$SnTransactionCopyWithImpl<_SnTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.type, type) || other.type == type)&&(identical(other.payerWalletId, payerWalletId) || other.payerWalletId == payerWalletId)&&(identical(other.payerWallet, payerWallet) || other.payerWallet == payerWallet)&&(identical(other.payeeWalletId, payeeWalletId) || other.payeeWalletId == payeeWalletId)&&(identical(other.payeeWallet, payeeWallet) || other.payeeWallet == payeeWallet)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,currency,amount,remarks,type,payerWalletId,payerWallet,payeeWalletId,payeeWallet,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnTransaction(id: $id, currency: $currency, amount: $amount, remarks: $remarks, type: $type, payerWalletId: $payerWalletId, payerWallet: $payerWallet, payeeWalletId: $payeeWalletId, payeeWallet: $payeeWallet, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnTransactionCopyWith<$Res> implements $SnTransactionCopyWith<$Res> {
  factory _$SnTransactionCopyWith(_SnTransaction value, $Res Function(_SnTransaction) _then) = __$SnTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String currency, double amount, String? remarks, int type, String? payerWalletId, SnWallet? payerWallet, String? payeeWalletId, SnWallet? payeeWallet, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnWalletCopyWith<$Res>? get payerWallet;@override $SnWalletCopyWith<$Res>? get payeeWallet;

}
/// @nodoc
class __$SnTransactionCopyWithImpl<$Res>
    implements _$SnTransactionCopyWith<$Res> {
  __$SnTransactionCopyWithImpl(this._self, this._then);

  final _SnTransaction _self;
  final $Res Function(_SnTransaction) _then;

/// Create a copy of SnTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? currency = null,Object? amount = null,Object? remarks = freezed,Object? type = null,Object? payerWalletId = freezed,Object? payerWallet = freezed,Object? payeeWalletId = freezed,Object? payeeWallet = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,payerWalletId: freezed == payerWalletId ? _self.payerWalletId : payerWalletId // ignore: cast_nullable_to_non_nullable
as String?,payerWallet: freezed == payerWallet ? _self.payerWallet : payerWallet // ignore: cast_nullable_to_non_nullable
as SnWallet?,payeeWalletId: freezed == payeeWalletId ? _self.payeeWalletId : payeeWalletId // ignore: cast_nullable_to_non_nullable
as String?,payeeWallet: freezed == payeeWallet ? _self.payeeWallet : payeeWallet // ignore: cast_nullable_to_non_nullable
as SnWallet?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnWalletCopyWith<$Res>? get payerWallet {
    if (_self.payerWallet == null) {
    return null;
  }

  return $SnWalletCopyWith<$Res>(_self.payerWallet!, (value) {
    return _then(_self.copyWith(payerWallet: value));
  });
}/// Create a copy of SnTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnWalletCopyWith<$Res>? get payeeWallet {
    if (_self.payeeWallet == null) {
    return null;
  }

  return $SnWalletCopyWith<$Res>(_self.payeeWallet!, (value) {
    return _then(_self.copyWith(payeeWallet: value));
  });
}
}


/// @nodoc
mixin _$SnWalletSubscription {

 String get id; DateTime get begunAt; DateTime? get endedAt; String get identifier; bool get isActive; bool get isFreeTrial; int get status; String? get paymentMethod; Map<String, dynamic>? get paymentDetails; double? get basePrice; String? get couponId; dynamic get coupon; DateTime? get renewalAt; String get accountId; SnAccount? get account; bool get isAvailable; double? get finalPrice; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnWalletSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnWalletSubscriptionCopyWith<SnWalletSubscription> get copyWith => _$SnWalletSubscriptionCopyWithImpl<SnWalletSubscription>(this as SnWalletSubscription, _$identity);

  /// Serializes this SnWalletSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnWalletSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.begunAt, begunAt) || other.begunAt == begunAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isFreeTrial, isFreeTrial) || other.isFreeTrial == isFreeTrial)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&const DeepCollectionEquality().equals(other.paymentDetails, paymentDetails)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.couponId, couponId) || other.couponId == couponId)&&const DeepCollectionEquality().equals(other.coupon, coupon)&&(identical(other.renewalAt, renewalAt) || other.renewalAt == renewalAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.finalPrice, finalPrice) || other.finalPrice == finalPrice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,begunAt,endedAt,identifier,isActive,isFreeTrial,status,paymentMethod,const DeepCollectionEquality().hash(paymentDetails),basePrice,couponId,const DeepCollectionEquality().hash(coupon),renewalAt,accountId,account,isAvailable,finalPrice,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'SnWalletSubscription(id: $id, begunAt: $begunAt, endedAt: $endedAt, identifier: $identifier, isActive: $isActive, isFreeTrial: $isFreeTrial, status: $status, paymentMethod: $paymentMethod, paymentDetails: $paymentDetails, basePrice: $basePrice, couponId: $couponId, coupon: $coupon, renewalAt: $renewalAt, accountId: $accountId, account: $account, isAvailable: $isAvailable, finalPrice: $finalPrice, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnWalletSubscriptionCopyWith<$Res>  {
  factory $SnWalletSubscriptionCopyWith(SnWalletSubscription value, $Res Function(SnWalletSubscription) _then) = _$SnWalletSubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, DateTime begunAt, DateTime? endedAt, String identifier, bool isActive, bool isFreeTrial, int status, String? paymentMethod, Map<String, dynamic>? paymentDetails, double? basePrice, String? couponId, dynamic coupon, DateTime? renewalAt, String accountId, SnAccount? account, bool isAvailable, double? finalPrice, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnWalletSubscriptionCopyWithImpl<$Res>
    implements $SnWalletSubscriptionCopyWith<$Res> {
  _$SnWalletSubscriptionCopyWithImpl(this._self, this._then);

  final SnWalletSubscription _self;
  final $Res Function(SnWalletSubscription) _then;

/// Create a copy of SnWalletSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? begunAt = null,Object? endedAt = freezed,Object? identifier = null,Object? isActive = null,Object? isFreeTrial = null,Object? status = null,Object? paymentMethod = freezed,Object? paymentDetails = freezed,Object? basePrice = freezed,Object? couponId = freezed,Object? coupon = freezed,Object? renewalAt = freezed,Object? accountId = null,Object? account = freezed,Object? isAvailable = null,Object? finalPrice = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,begunAt: null == begunAt ? _self.begunAt : begunAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isFreeTrial: null == isFreeTrial ? _self.isFreeTrial : isFreeTrial // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,paymentDetails: freezed == paymentDetails ? _self.paymentDetails : paymentDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,basePrice: freezed == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double?,couponId: freezed == couponId ? _self.couponId : couponId // ignore: cast_nullable_to_non_nullable
as String?,coupon: freezed == coupon ? _self.coupon : coupon // ignore: cast_nullable_to_non_nullable
as dynamic,renewalAt: freezed == renewalAt ? _self.renewalAt : renewalAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,finalPrice: freezed == finalPrice ? _self.finalPrice : finalPrice // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnWalletSubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnWalletSubscription].
extension SnWalletSubscriptionPatterns on SnWalletSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnWalletSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnWalletSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnWalletSubscription value)  $default,){
final _that = this;
switch (_that) {
case _SnWalletSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnWalletSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _SnWalletSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime begunAt,  DateTime? endedAt,  String identifier,  bool isActive,  bool isFreeTrial,  int status,  String? paymentMethod,  Map<String, dynamic>? paymentDetails,  double? basePrice,  String? couponId,  dynamic coupon,  DateTime? renewalAt,  String accountId,  SnAccount? account,  bool isAvailable,  double? finalPrice,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnWalletSubscription() when $default != null:
return $default(_that.id,_that.begunAt,_that.endedAt,_that.identifier,_that.isActive,_that.isFreeTrial,_that.status,_that.paymentMethod,_that.paymentDetails,_that.basePrice,_that.couponId,_that.coupon,_that.renewalAt,_that.accountId,_that.account,_that.isAvailable,_that.finalPrice,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime begunAt,  DateTime? endedAt,  String identifier,  bool isActive,  bool isFreeTrial,  int status,  String? paymentMethod,  Map<String, dynamic>? paymentDetails,  double? basePrice,  String? couponId,  dynamic coupon,  DateTime? renewalAt,  String accountId,  SnAccount? account,  bool isAvailable,  double? finalPrice,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnWalletSubscription():
return $default(_that.id,_that.begunAt,_that.endedAt,_that.identifier,_that.isActive,_that.isFreeTrial,_that.status,_that.paymentMethod,_that.paymentDetails,_that.basePrice,_that.couponId,_that.coupon,_that.renewalAt,_that.accountId,_that.account,_that.isAvailable,_that.finalPrice,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime begunAt,  DateTime? endedAt,  String identifier,  bool isActive,  bool isFreeTrial,  int status,  String? paymentMethod,  Map<String, dynamic>? paymentDetails,  double? basePrice,  String? couponId,  dynamic coupon,  DateTime? renewalAt,  String accountId,  SnAccount? account,  bool isAvailable,  double? finalPrice,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnWalletSubscription() when $default != null:
return $default(_that.id,_that.begunAt,_that.endedAt,_that.identifier,_that.isActive,_that.isFreeTrial,_that.status,_that.paymentMethod,_that.paymentDetails,_that.basePrice,_that.couponId,_that.coupon,_that.renewalAt,_that.accountId,_that.account,_that.isAvailable,_that.finalPrice,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnWalletSubscription implements SnWalletSubscription {
  const _SnWalletSubscription({required this.id, required this.begunAt, required this.endedAt, required this.identifier, this.isActive = true, this.isFreeTrial = false, this.status = 1, required this.paymentMethod, required final  Map<String, dynamic>? paymentDetails, required this.basePrice, required this.couponId, required this.coupon, required this.renewalAt, required this.accountId, required this.account, this.isAvailable = true, required this.finalPrice, required this.createdAt, required this.updatedAt, required this.deletedAt}): _paymentDetails = paymentDetails;
  factory _SnWalletSubscription.fromJson(Map<String, dynamic> json) => _$SnWalletSubscriptionFromJson(json);

@override final  String id;
@override final  DateTime begunAt;
@override final  DateTime? endedAt;
@override final  String identifier;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isFreeTrial;
@override@JsonKey() final  int status;
@override final  String? paymentMethod;
 final  Map<String, dynamic>? _paymentDetails;
@override Map<String, dynamic>? get paymentDetails {
  final value = _paymentDetails;
  if (value == null) return null;
  if (_paymentDetails is EqualUnmodifiableMapView) return _paymentDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  double? basePrice;
@override final  String? couponId;
@override final  dynamic coupon;
@override final  DateTime? renewalAt;
@override final  String accountId;
@override final  SnAccount? account;
@override@JsonKey() final  bool isAvailable;
@override final  double? finalPrice;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnWalletSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnWalletSubscriptionCopyWith<_SnWalletSubscription> get copyWith => __$SnWalletSubscriptionCopyWithImpl<_SnWalletSubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnWalletSubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnWalletSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.begunAt, begunAt) || other.begunAt == begunAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isFreeTrial, isFreeTrial) || other.isFreeTrial == isFreeTrial)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&const DeepCollectionEquality().equals(other._paymentDetails, _paymentDetails)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.couponId, couponId) || other.couponId == couponId)&&const DeepCollectionEquality().equals(other.coupon, coupon)&&(identical(other.renewalAt, renewalAt) || other.renewalAt == renewalAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.finalPrice, finalPrice) || other.finalPrice == finalPrice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,begunAt,endedAt,identifier,isActive,isFreeTrial,status,paymentMethod,const DeepCollectionEquality().hash(_paymentDetails),basePrice,couponId,const DeepCollectionEquality().hash(coupon),renewalAt,accountId,account,isAvailable,finalPrice,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'SnWalletSubscription(id: $id, begunAt: $begunAt, endedAt: $endedAt, identifier: $identifier, isActive: $isActive, isFreeTrial: $isFreeTrial, status: $status, paymentMethod: $paymentMethod, paymentDetails: $paymentDetails, basePrice: $basePrice, couponId: $couponId, coupon: $coupon, renewalAt: $renewalAt, accountId: $accountId, account: $account, isAvailable: $isAvailable, finalPrice: $finalPrice, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnWalletSubscriptionCopyWith<$Res> implements $SnWalletSubscriptionCopyWith<$Res> {
  factory _$SnWalletSubscriptionCopyWith(_SnWalletSubscription value, $Res Function(_SnWalletSubscription) _then) = __$SnWalletSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime begunAt, DateTime? endedAt, String identifier, bool isActive, bool isFreeTrial, int status, String? paymentMethod, Map<String, dynamic>? paymentDetails, double? basePrice, String? couponId, dynamic coupon, DateTime? renewalAt, String accountId, SnAccount? account, bool isAvailable, double? finalPrice, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnWalletSubscriptionCopyWithImpl<$Res>
    implements _$SnWalletSubscriptionCopyWith<$Res> {
  __$SnWalletSubscriptionCopyWithImpl(this._self, this._then);

  final _SnWalletSubscription _self;
  final $Res Function(_SnWalletSubscription) _then;

/// Create a copy of SnWalletSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? begunAt = null,Object? endedAt = freezed,Object? identifier = null,Object? isActive = null,Object? isFreeTrial = null,Object? status = null,Object? paymentMethod = freezed,Object? paymentDetails = freezed,Object? basePrice = freezed,Object? couponId = freezed,Object? coupon = freezed,Object? renewalAt = freezed,Object? accountId = null,Object? account = freezed,Object? isAvailable = null,Object? finalPrice = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnWalletSubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,begunAt: null == begunAt ? _self.begunAt : begunAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isFreeTrial: null == isFreeTrial ? _self.isFreeTrial : isFreeTrial // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,paymentDetails: freezed == paymentDetails ? _self._paymentDetails : paymentDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,basePrice: freezed == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double?,couponId: freezed == couponId ? _self.couponId : couponId // ignore: cast_nullable_to_non_nullable
as String?,coupon: freezed == coupon ? _self.coupon : coupon // ignore: cast_nullable_to_non_nullable
as dynamic,renewalAt: freezed == renewalAt ? _self.renewalAt : renewalAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,finalPrice: freezed == finalPrice ? _self.finalPrice : finalPrice // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnWalletSubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// @nodoc
mixin _$SnWalletSubscriptionRef {

 String get id; bool get isActive; String get accountId; DateTime get createdAt; DateTime? get deletedAt; DateTime get updatedAt; String get identifier;
/// Create a copy of SnWalletSubscriptionRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnWalletSubscriptionRefCopyWith<SnWalletSubscriptionRef> get copyWith => _$SnWalletSubscriptionRefCopyWithImpl<SnWalletSubscriptionRef>(this as SnWalletSubscriptionRef, _$identity);

  /// Serializes this SnWalletSubscriptionRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnWalletSubscriptionRef&&(identical(other.id, id) || other.id == id)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.identifier, identifier) || other.identifier == identifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isActive,accountId,createdAt,deletedAt,updatedAt,identifier);

@override
String toString() {
  return 'SnWalletSubscriptionRef(id: $id, isActive: $isActive, accountId: $accountId, createdAt: $createdAt, deletedAt: $deletedAt, updatedAt: $updatedAt, identifier: $identifier)';
}


}

/// @nodoc
abstract mixin class $SnWalletSubscriptionRefCopyWith<$Res>  {
  factory $SnWalletSubscriptionRefCopyWith(SnWalletSubscriptionRef value, $Res Function(SnWalletSubscriptionRef) _then) = _$SnWalletSubscriptionRefCopyWithImpl;
@useResult
$Res call({
 String id, bool isActive, String accountId, DateTime createdAt, DateTime? deletedAt, DateTime updatedAt, String identifier
});




}
/// @nodoc
class _$SnWalletSubscriptionRefCopyWithImpl<$Res>
    implements $SnWalletSubscriptionRefCopyWith<$Res> {
  _$SnWalletSubscriptionRefCopyWithImpl(this._self, this._then);

  final SnWalletSubscriptionRef _self;
  final $Res Function(SnWalletSubscriptionRef) _then;

/// Create a copy of SnWalletSubscriptionRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isActive = null,Object? accountId = null,Object? createdAt = null,Object? deletedAt = freezed,Object? updatedAt = null,Object? identifier = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnWalletSubscriptionRef].
extension SnWalletSubscriptionRefPatterns on SnWalletSubscriptionRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnWalletSubscriptionRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnWalletSubscriptionRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnWalletSubscriptionRef value)  $default,){
final _that = this;
switch (_that) {
case _SnWalletSubscriptionRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnWalletSubscriptionRef value)?  $default,){
final _that = this;
switch (_that) {
case _SnWalletSubscriptionRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool isActive,  String accountId,  DateTime createdAt,  DateTime? deletedAt,  DateTime updatedAt,  String identifier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnWalletSubscriptionRef() when $default != null:
return $default(_that.id,_that.isActive,_that.accountId,_that.createdAt,_that.deletedAt,_that.updatedAt,_that.identifier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool isActive,  String accountId,  DateTime createdAt,  DateTime? deletedAt,  DateTime updatedAt,  String identifier)  $default,) {final _that = this;
switch (_that) {
case _SnWalletSubscriptionRef():
return $default(_that.id,_that.isActive,_that.accountId,_that.createdAt,_that.deletedAt,_that.updatedAt,_that.identifier);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool isActive,  String accountId,  DateTime createdAt,  DateTime? deletedAt,  DateTime updatedAt,  String identifier)?  $default,) {final _that = this;
switch (_that) {
case _SnWalletSubscriptionRef() when $default != null:
return $default(_that.id,_that.isActive,_that.accountId,_that.createdAt,_that.deletedAt,_that.updatedAt,_that.identifier);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnWalletSubscriptionRef implements SnWalletSubscriptionRef {
  const _SnWalletSubscriptionRef({required this.id, required this.isActive, required this.accountId, required this.createdAt, required this.deletedAt, required this.updatedAt, required this.identifier});
  factory _SnWalletSubscriptionRef.fromJson(Map<String, dynamic> json) => _$SnWalletSubscriptionRefFromJson(json);

@override final  String id;
@override final  bool isActive;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime? deletedAt;
@override final  DateTime updatedAt;
@override final  String identifier;

/// Create a copy of SnWalletSubscriptionRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnWalletSubscriptionRefCopyWith<_SnWalletSubscriptionRef> get copyWith => __$SnWalletSubscriptionRefCopyWithImpl<_SnWalletSubscriptionRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnWalletSubscriptionRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnWalletSubscriptionRef&&(identical(other.id, id) || other.id == id)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.identifier, identifier) || other.identifier == identifier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isActive,accountId,createdAt,deletedAt,updatedAt,identifier);

@override
String toString() {
  return 'SnWalletSubscriptionRef(id: $id, isActive: $isActive, accountId: $accountId, createdAt: $createdAt, deletedAt: $deletedAt, updatedAt: $updatedAt, identifier: $identifier)';
}


}

/// @nodoc
abstract mixin class _$SnWalletSubscriptionRefCopyWith<$Res> implements $SnWalletSubscriptionRefCopyWith<$Res> {
  factory _$SnWalletSubscriptionRefCopyWith(_SnWalletSubscriptionRef value, $Res Function(_SnWalletSubscriptionRef) _then) = __$SnWalletSubscriptionRefCopyWithImpl;
@override @useResult
$Res call({
 String id, bool isActive, String accountId, DateTime createdAt, DateTime? deletedAt, DateTime updatedAt, String identifier
});




}
/// @nodoc
class __$SnWalletSubscriptionRefCopyWithImpl<$Res>
    implements _$SnWalletSubscriptionRefCopyWith<$Res> {
  __$SnWalletSubscriptionRefCopyWithImpl(this._self, this._then);

  final _SnWalletSubscriptionRef _self;
  final $Res Function(_SnWalletSubscriptionRef) _then;

/// Create a copy of SnWalletSubscriptionRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isActive = null,Object? accountId = null,Object? createdAt = null,Object? deletedAt = freezed,Object? updatedAt = null,Object? identifier = null,}) {
  return _then(_SnWalletSubscriptionRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SnWalletOrder {

 String get id; int get status; String get currency; String? get remarks; String get appIdentifier; Map<String, dynamic> get meta; int get amount; DateTime get expiredAt; String? get payeeWalletId; String? get transactionId; String? get issuerAppId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnWalletOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnWalletOrderCopyWith<SnWalletOrder> get copyWith => _$SnWalletOrderCopyWithImpl<SnWalletOrder>(this as SnWalletOrder, _$identity);

  /// Serializes this SnWalletOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnWalletOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.appIdentifier, appIdentifier) || other.appIdentifier == appIdentifier)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.payeeWalletId, payeeWalletId) || other.payeeWalletId == payeeWalletId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.issuerAppId, issuerAppId) || other.issuerAppId == issuerAppId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,currency,remarks,appIdentifier,const DeepCollectionEquality().hash(meta),amount,expiredAt,payeeWalletId,transactionId,issuerAppId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnWalletOrder(id: $id, status: $status, currency: $currency, remarks: $remarks, appIdentifier: $appIdentifier, meta: $meta, amount: $amount, expiredAt: $expiredAt, payeeWalletId: $payeeWalletId, transactionId: $transactionId, issuerAppId: $issuerAppId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnWalletOrderCopyWith<$Res>  {
  factory $SnWalletOrderCopyWith(SnWalletOrder value, $Res Function(SnWalletOrder) _then) = _$SnWalletOrderCopyWithImpl;
@useResult
$Res call({
 String id, int status, String currency, String? remarks, String appIdentifier, Map<String, dynamic> meta, int amount, DateTime expiredAt, String? payeeWalletId, String? transactionId, String? issuerAppId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnWalletOrderCopyWithImpl<$Res>
    implements $SnWalletOrderCopyWith<$Res> {
  _$SnWalletOrderCopyWithImpl(this._self, this._then);

  final SnWalletOrder _self;
  final $Res Function(SnWalletOrder) _then;

/// Create a copy of SnWalletOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? currency = null,Object? remarks = freezed,Object? appIdentifier = null,Object? meta = null,Object? amount = null,Object? expiredAt = null,Object? payeeWalletId = freezed,Object? transactionId = freezed,Object? issuerAppId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,appIdentifier: null == appIdentifier ? _self.appIdentifier : appIdentifier // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,expiredAt: null == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime,payeeWalletId: freezed == payeeWalletId ? _self.payeeWalletId : payeeWalletId // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,issuerAppId: freezed == issuerAppId ? _self.issuerAppId : issuerAppId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnWalletOrder].
extension SnWalletOrderPatterns on SnWalletOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnWalletOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnWalletOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnWalletOrder value)  $default,){
final _that = this;
switch (_that) {
case _SnWalletOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnWalletOrder value)?  $default,){
final _that = this;
switch (_that) {
case _SnWalletOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int status,  String currency,  String? remarks,  String appIdentifier,  Map<String, dynamic> meta,  int amount,  DateTime expiredAt,  String? payeeWalletId,  String? transactionId,  String? issuerAppId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnWalletOrder() when $default != null:
return $default(_that.id,_that.status,_that.currency,_that.remarks,_that.appIdentifier,_that.meta,_that.amount,_that.expiredAt,_that.payeeWalletId,_that.transactionId,_that.issuerAppId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int status,  String currency,  String? remarks,  String appIdentifier,  Map<String, dynamic> meta,  int amount,  DateTime expiredAt,  String? payeeWalletId,  String? transactionId,  String? issuerAppId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnWalletOrder():
return $default(_that.id,_that.status,_that.currency,_that.remarks,_that.appIdentifier,_that.meta,_that.amount,_that.expiredAt,_that.payeeWalletId,_that.transactionId,_that.issuerAppId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int status,  String currency,  String? remarks,  String appIdentifier,  Map<String, dynamic> meta,  int amount,  DateTime expiredAt,  String? payeeWalletId,  String? transactionId,  String? issuerAppId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnWalletOrder() when $default != null:
return $default(_that.id,_that.status,_that.currency,_that.remarks,_that.appIdentifier,_that.meta,_that.amount,_that.expiredAt,_that.payeeWalletId,_that.transactionId,_that.issuerAppId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnWalletOrder implements SnWalletOrder {
  const _SnWalletOrder({required this.id, required this.status, required this.currency, required this.remarks, required this.appIdentifier, final  Map<String, dynamic> meta = const {}, required this.amount, required this.expiredAt, required this.payeeWalletId, required this.transactionId, required this.issuerAppId, required this.createdAt, required this.updatedAt, required this.deletedAt}): _meta = meta;
  factory _SnWalletOrder.fromJson(Map<String, dynamic> json) => _$SnWalletOrderFromJson(json);

@override final  String id;
@override final  int status;
@override final  String currency;
@override final  String? remarks;
@override final  String appIdentifier;
 final  Map<String, dynamic> _meta;
@override@JsonKey() Map<String, dynamic> get meta {
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meta);
}

@override final  int amount;
@override final  DateTime expiredAt;
@override final  String? payeeWalletId;
@override final  String? transactionId;
@override final  String? issuerAppId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnWalletOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnWalletOrderCopyWith<_SnWalletOrder> get copyWith => __$SnWalletOrderCopyWithImpl<_SnWalletOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnWalletOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnWalletOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.appIdentifier, appIdentifier) || other.appIdentifier == appIdentifier)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.payeeWalletId, payeeWalletId) || other.payeeWalletId == payeeWalletId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.issuerAppId, issuerAppId) || other.issuerAppId == issuerAppId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,currency,remarks,appIdentifier,const DeepCollectionEquality().hash(_meta),amount,expiredAt,payeeWalletId,transactionId,issuerAppId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnWalletOrder(id: $id, status: $status, currency: $currency, remarks: $remarks, appIdentifier: $appIdentifier, meta: $meta, amount: $amount, expiredAt: $expiredAt, payeeWalletId: $payeeWalletId, transactionId: $transactionId, issuerAppId: $issuerAppId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnWalletOrderCopyWith<$Res> implements $SnWalletOrderCopyWith<$Res> {
  factory _$SnWalletOrderCopyWith(_SnWalletOrder value, $Res Function(_SnWalletOrder) _then) = __$SnWalletOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, int status, String currency, String? remarks, String appIdentifier, Map<String, dynamic> meta, int amount, DateTime expiredAt, String? payeeWalletId, String? transactionId, String? issuerAppId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnWalletOrderCopyWithImpl<$Res>
    implements _$SnWalletOrderCopyWith<$Res> {
  __$SnWalletOrderCopyWithImpl(this._self, this._then);

  final _SnWalletOrder _self;
  final $Res Function(_SnWalletOrder) _then;

/// Create a copy of SnWalletOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? currency = null,Object? remarks = freezed,Object? appIdentifier = null,Object? meta = null,Object? amount = null,Object? expiredAt = null,Object? payeeWalletId = freezed,Object? transactionId = freezed,Object? issuerAppId = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnWalletOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,appIdentifier: null == appIdentifier ? _self.appIdentifier : appIdentifier // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,expiredAt: null == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime,payeeWalletId: freezed == payeeWalletId ? _self.payeeWalletId : payeeWalletId // ignore: cast_nullable_to_non_nullable
as String?,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,issuerAppId: freezed == issuerAppId ? _self.issuerAppId : issuerAppId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnWalletGift {

 String get id; String get giftCode; String get subscriptionIdentifier; String? get recipientId; SnAccount? get recipient; String get gifterId; SnAccount? get gifter; String? get redeemerId; SnAccount? get redeemer; String? get message; int get status; DateTime? get redeemedAt; DateTime? get expiredAt; String? get subscriptionId; SnWalletSubscription? get subscription; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnWalletGift
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnWalletGiftCopyWith<SnWalletGift> get copyWith => _$SnWalletGiftCopyWithImpl<SnWalletGift>(this as SnWalletGift, _$identity);

  /// Serializes this SnWalletGift to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnWalletGift&&(identical(other.id, id) || other.id == id)&&(identical(other.giftCode, giftCode) || other.giftCode == giftCode)&&(identical(other.subscriptionIdentifier, subscriptionIdentifier) || other.subscriptionIdentifier == subscriptionIdentifier)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.gifterId, gifterId) || other.gifterId == gifterId)&&(identical(other.gifter, gifter) || other.gifter == gifter)&&(identical(other.redeemerId, redeemerId) || other.redeemerId == redeemerId)&&(identical(other.redeemer, redeemer) || other.redeemer == redeemer)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.redeemedAt, redeemedAt) || other.redeemedAt == redeemedAt)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,giftCode,subscriptionIdentifier,recipientId,recipient,gifterId,gifter,redeemerId,redeemer,message,status,redeemedAt,expiredAt,subscriptionId,subscription,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnWalletGift(id: $id, giftCode: $giftCode, subscriptionIdentifier: $subscriptionIdentifier, recipientId: $recipientId, recipient: $recipient, gifterId: $gifterId, gifter: $gifter, redeemerId: $redeemerId, redeemer: $redeemer, message: $message, status: $status, redeemedAt: $redeemedAt, expiredAt: $expiredAt, subscriptionId: $subscriptionId, subscription: $subscription, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnWalletGiftCopyWith<$Res>  {
  factory $SnWalletGiftCopyWith(SnWalletGift value, $Res Function(SnWalletGift) _then) = _$SnWalletGiftCopyWithImpl;
@useResult
$Res call({
 String id, String giftCode, String subscriptionIdentifier, String? recipientId, SnAccount? recipient, String gifterId, SnAccount? gifter, String? redeemerId, SnAccount? redeemer, String? message, int status, DateTime? redeemedAt, DateTime? expiredAt, String? subscriptionId, SnWalletSubscription? subscription, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnAccountCopyWith<$Res>? get recipient;$SnAccountCopyWith<$Res>? get gifter;$SnAccountCopyWith<$Res>? get redeemer;$SnWalletSubscriptionCopyWith<$Res>? get subscription;

}
/// @nodoc
class _$SnWalletGiftCopyWithImpl<$Res>
    implements $SnWalletGiftCopyWith<$Res> {
  _$SnWalletGiftCopyWithImpl(this._self, this._then);

  final SnWalletGift _self;
  final $Res Function(SnWalletGift) _then;

/// Create a copy of SnWalletGift
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? giftCode = null,Object? subscriptionIdentifier = null,Object? recipientId = freezed,Object? recipient = freezed,Object? gifterId = null,Object? gifter = freezed,Object? redeemerId = freezed,Object? redeemer = freezed,Object? message = freezed,Object? status = null,Object? redeemedAt = freezed,Object? expiredAt = freezed,Object? subscriptionId = freezed,Object? subscription = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,giftCode: null == giftCode ? _self.giftCode : giftCode // ignore: cast_nullable_to_non_nullable
as String,subscriptionIdentifier: null == subscriptionIdentifier ? _self.subscriptionIdentifier : subscriptionIdentifier // ignore: cast_nullable_to_non_nullable
as String,recipientId: freezed == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as String?,recipient: freezed == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as SnAccount?,gifterId: null == gifterId ? _self.gifterId : gifterId // ignore: cast_nullable_to_non_nullable
as String,gifter: freezed == gifter ? _self.gifter : gifter // ignore: cast_nullable_to_non_nullable
as SnAccount?,redeemerId: freezed == redeemerId ? _self.redeemerId : redeemerId // ignore: cast_nullable_to_non_nullable
as String?,redeemer: freezed == redeemer ? _self.redeemer : redeemer // ignore: cast_nullable_to_non_nullable
as SnAccount?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,redeemedAt: freezed == redeemedAt ? _self.redeemedAt : redeemedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnWalletSubscription?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnWalletGift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get recipient {
    if (_self.recipient == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.recipient!, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of SnWalletGift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get gifter {
    if (_self.gifter == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.gifter!, (value) {
    return _then(_self.copyWith(gifter: value));
  });
}/// Create a copy of SnWalletGift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get redeemer {
    if (_self.redeemer == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.redeemer!, (value) {
    return _then(_self.copyWith(redeemer: value));
  });
}/// Create a copy of SnWalletGift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnWalletSubscriptionCopyWith<$Res>? get subscription {
    if (_self.subscription == null) {
    return null;
  }

  return $SnWalletSubscriptionCopyWith<$Res>(_self.subscription!, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnWalletGift].
extension SnWalletGiftPatterns on SnWalletGift {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnWalletGift value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnWalletGift() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnWalletGift value)  $default,){
final _that = this;
switch (_that) {
case _SnWalletGift():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnWalletGift value)?  $default,){
final _that = this;
switch (_that) {
case _SnWalletGift() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String giftCode,  String subscriptionIdentifier,  String? recipientId,  SnAccount? recipient,  String gifterId,  SnAccount? gifter,  String? redeemerId,  SnAccount? redeemer,  String? message,  int status,  DateTime? redeemedAt,  DateTime? expiredAt,  String? subscriptionId,  SnWalletSubscription? subscription,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnWalletGift() when $default != null:
return $default(_that.id,_that.giftCode,_that.subscriptionIdentifier,_that.recipientId,_that.recipient,_that.gifterId,_that.gifter,_that.redeemerId,_that.redeemer,_that.message,_that.status,_that.redeemedAt,_that.expiredAt,_that.subscriptionId,_that.subscription,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String giftCode,  String subscriptionIdentifier,  String? recipientId,  SnAccount? recipient,  String gifterId,  SnAccount? gifter,  String? redeemerId,  SnAccount? redeemer,  String? message,  int status,  DateTime? redeemedAt,  DateTime? expiredAt,  String? subscriptionId,  SnWalletSubscription? subscription,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnWalletGift():
return $default(_that.id,_that.giftCode,_that.subscriptionIdentifier,_that.recipientId,_that.recipient,_that.gifterId,_that.gifter,_that.redeemerId,_that.redeemer,_that.message,_that.status,_that.redeemedAt,_that.expiredAt,_that.subscriptionId,_that.subscription,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String giftCode,  String subscriptionIdentifier,  String? recipientId,  SnAccount? recipient,  String gifterId,  SnAccount? gifter,  String? redeemerId,  SnAccount? redeemer,  String? message,  int status,  DateTime? redeemedAt,  DateTime? expiredAt,  String? subscriptionId,  SnWalletSubscription? subscription,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnWalletGift() when $default != null:
return $default(_that.id,_that.giftCode,_that.subscriptionIdentifier,_that.recipientId,_that.recipient,_that.gifterId,_that.gifter,_that.redeemerId,_that.redeemer,_that.message,_that.status,_that.redeemedAt,_that.expiredAt,_that.subscriptionId,_that.subscription,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnWalletGift implements SnWalletGift {
  const _SnWalletGift({required this.id, required this.giftCode, required this.subscriptionIdentifier, required this.recipientId, required this.recipient, required this.gifterId, required this.gifter, required this.redeemerId, required this.redeemer, required this.message, required this.status, required this.redeemedAt, required this.expiredAt, required this.subscriptionId, required this.subscription, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnWalletGift.fromJson(Map<String, dynamic> json) => _$SnWalletGiftFromJson(json);

@override final  String id;
@override final  String giftCode;
@override final  String subscriptionIdentifier;
@override final  String? recipientId;
@override final  SnAccount? recipient;
@override final  String gifterId;
@override final  SnAccount? gifter;
@override final  String? redeemerId;
@override final  SnAccount? redeemer;
@override final  String? message;
@override final  int status;
@override final  DateTime? redeemedAt;
@override final  DateTime? expiredAt;
@override final  String? subscriptionId;
@override final  SnWalletSubscription? subscription;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnWalletGift
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnWalletGiftCopyWith<_SnWalletGift> get copyWith => __$SnWalletGiftCopyWithImpl<_SnWalletGift>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnWalletGiftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnWalletGift&&(identical(other.id, id) || other.id == id)&&(identical(other.giftCode, giftCode) || other.giftCode == giftCode)&&(identical(other.subscriptionIdentifier, subscriptionIdentifier) || other.subscriptionIdentifier == subscriptionIdentifier)&&(identical(other.recipientId, recipientId) || other.recipientId == recipientId)&&(identical(other.recipient, recipient) || other.recipient == recipient)&&(identical(other.gifterId, gifterId) || other.gifterId == gifterId)&&(identical(other.gifter, gifter) || other.gifter == gifter)&&(identical(other.redeemerId, redeemerId) || other.redeemerId == redeemerId)&&(identical(other.redeemer, redeemer) || other.redeemer == redeemer)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.redeemedAt, redeemedAt) || other.redeemedAt == redeemedAt)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,giftCode,subscriptionIdentifier,recipientId,recipient,gifterId,gifter,redeemerId,redeemer,message,status,redeemedAt,expiredAt,subscriptionId,subscription,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnWalletGift(id: $id, giftCode: $giftCode, subscriptionIdentifier: $subscriptionIdentifier, recipientId: $recipientId, recipient: $recipient, gifterId: $gifterId, gifter: $gifter, redeemerId: $redeemerId, redeemer: $redeemer, message: $message, status: $status, redeemedAt: $redeemedAt, expiredAt: $expiredAt, subscriptionId: $subscriptionId, subscription: $subscription, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnWalletGiftCopyWith<$Res> implements $SnWalletGiftCopyWith<$Res> {
  factory _$SnWalletGiftCopyWith(_SnWalletGift value, $Res Function(_SnWalletGift) _then) = __$SnWalletGiftCopyWithImpl;
@override @useResult
$Res call({
 String id, String giftCode, String subscriptionIdentifier, String? recipientId, SnAccount? recipient, String gifterId, SnAccount? gifter, String? redeemerId, SnAccount? redeemer, String? message, int status, DateTime? redeemedAt, DateTime? expiredAt, String? subscriptionId, SnWalletSubscription? subscription, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnAccountCopyWith<$Res>? get recipient;@override $SnAccountCopyWith<$Res>? get gifter;@override $SnAccountCopyWith<$Res>? get redeemer;@override $SnWalletSubscriptionCopyWith<$Res>? get subscription;

}
/// @nodoc
class __$SnWalletGiftCopyWithImpl<$Res>
    implements _$SnWalletGiftCopyWith<$Res> {
  __$SnWalletGiftCopyWithImpl(this._self, this._then);

  final _SnWalletGift _self;
  final $Res Function(_SnWalletGift) _then;

/// Create a copy of SnWalletGift
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? giftCode = null,Object? subscriptionIdentifier = null,Object? recipientId = freezed,Object? recipient = freezed,Object? gifterId = null,Object? gifter = freezed,Object? redeemerId = freezed,Object? redeemer = freezed,Object? message = freezed,Object? status = null,Object? redeemedAt = freezed,Object? expiredAt = freezed,Object? subscriptionId = freezed,Object? subscription = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnWalletGift(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,giftCode: null == giftCode ? _self.giftCode : giftCode // ignore: cast_nullable_to_non_nullable
as String,subscriptionIdentifier: null == subscriptionIdentifier ? _self.subscriptionIdentifier : subscriptionIdentifier // ignore: cast_nullable_to_non_nullable
as String,recipientId: freezed == recipientId ? _self.recipientId : recipientId // ignore: cast_nullable_to_non_nullable
as String?,recipient: freezed == recipient ? _self.recipient : recipient // ignore: cast_nullable_to_non_nullable
as SnAccount?,gifterId: null == gifterId ? _self.gifterId : gifterId // ignore: cast_nullable_to_non_nullable
as String,gifter: freezed == gifter ? _self.gifter : gifter // ignore: cast_nullable_to_non_nullable
as SnAccount?,redeemerId: freezed == redeemerId ? _self.redeemerId : redeemerId // ignore: cast_nullable_to_non_nullable
as String?,redeemer: freezed == redeemer ? _self.redeemer : redeemer // ignore: cast_nullable_to_non_nullable
as SnAccount?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,redeemedAt: freezed == redeemedAt ? _self.redeemedAt : redeemedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,subscriptionId: freezed == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String?,subscription: freezed == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as SnWalletSubscription?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnWalletGift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get recipient {
    if (_self.recipient == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.recipient!, (value) {
    return _then(_self.copyWith(recipient: value));
  });
}/// Create a copy of SnWalletGift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get gifter {
    if (_self.gifter == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.gifter!, (value) {
    return _then(_self.copyWith(gifter: value));
  });
}/// Create a copy of SnWalletGift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get redeemer {
    if (_self.redeemer == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.redeemer!, (value) {
    return _then(_self.copyWith(redeemer: value));
  });
}/// Create a copy of SnWalletGift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnWalletSubscriptionCopyWith<$Res>? get subscription {
    if (_self.subscription == null) {
    return null;
  }

  return $SnWalletSubscriptionCopyWith<$Res>(_self.subscription!, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}

// dart format on
