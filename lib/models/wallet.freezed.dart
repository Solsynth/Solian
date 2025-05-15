// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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

// dart format on
