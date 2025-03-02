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
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get balance;
  String get password;
  int get accountId;

  /// Create a copy of SnWallet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnWalletCopyWith<SnWallet> get copyWith =>
      _$SnWalletCopyWithImpl<SnWallet>(this as SnWallet, _$identity);

  /// Serializes this SnWallet to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnWallet &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt,
      deletedAt, balance, password, accountId);

  @override
  String toString() {
    return 'SnWallet(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, balance: $balance, password: $password, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class $SnWalletCopyWith<$Res> {
  factory $SnWalletCopyWith(SnWallet value, $Res Function(SnWallet) _then) =
      _$SnWalletCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String balance,
      String password,
      int accountId});
}

/// @nodoc
class _$SnWalletCopyWithImpl<$Res> implements $SnWalletCopyWith<$Res> {
  _$SnWalletCopyWithImpl(this._self, this._then);

  final SnWallet _self;
  final $Res Function(SnWallet) _then;

  /// Create a copy of SnWallet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? balance = null,
    Object? password = null,
    Object? accountId = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      balance: null == balance
          ? _self.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnWallet implements SnWallet {
  const _SnWallet(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.balance,
      required this.password,
      required this.accountId});
  factory _SnWallet.fromJson(Map<String, dynamic> json) =>
      _$SnWalletFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String balance;
  @override
  final String password;
  @override
  final int accountId;

  /// Create a copy of SnWallet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnWalletCopyWith<_SnWallet> get copyWith =>
      __$SnWalletCopyWithImpl<_SnWallet>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnWalletToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnWallet &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt,
      deletedAt, balance, password, accountId);

  @override
  String toString() {
    return 'SnWallet(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, balance: $balance, password: $password, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class _$SnWalletCopyWith<$Res>
    implements $SnWalletCopyWith<$Res> {
  factory _$SnWalletCopyWith(_SnWallet value, $Res Function(_SnWallet) _then) =
      __$SnWalletCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String balance,
      String password,
      int accountId});
}

/// @nodoc
class __$SnWalletCopyWithImpl<$Res> implements _$SnWalletCopyWith<$Res> {
  __$SnWalletCopyWithImpl(this._self, this._then);

  final _SnWallet _self;
  final $Res Function(_SnWallet) _then;

  /// Create a copy of SnWallet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? balance = null,
    Object? password = null,
    Object? accountId = null,
  }) {
    return _then(_SnWallet(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      balance: null == balance
          ? _self.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$SnTransaction {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get remark;
  String get amount;
  SnWallet? get payer;
  SnWallet? get payee;
  int? get payerId;
  int? get payeeId;

  /// Create a copy of SnTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnTransactionCopyWith<SnTransaction> get copyWith =>
      _$SnTransactionCopyWithImpl<SnTransaction>(
          this as SnTransaction, _$identity);

  /// Serializes this SnTransaction to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnTransaction &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.remark, remark) || other.remark == remark) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.payer, payer) || other.payer == payer) &&
            (identical(other.payee, payee) || other.payee == payee) &&
            (identical(other.payerId, payerId) || other.payerId == payerId) &&
            (identical(other.payeeId, payeeId) || other.payeeId == payeeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt,
      deletedAt, remark, amount, payer, payee, payerId, payeeId);

  @override
  String toString() {
    return 'SnTransaction(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, remark: $remark, amount: $amount, payer: $payer, payee: $payee, payerId: $payerId, payeeId: $payeeId)';
  }
}

/// @nodoc
abstract mixin class $SnTransactionCopyWith<$Res> {
  factory $SnTransactionCopyWith(
          SnTransaction value, $Res Function(SnTransaction) _then) =
      _$SnTransactionCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String remark,
      String amount,
      SnWallet? payer,
      SnWallet? payee,
      int? payerId,
      int? payeeId});

  $SnWalletCopyWith<$Res>? get payer;
  $SnWalletCopyWith<$Res>? get payee;
}

/// @nodoc
class _$SnTransactionCopyWithImpl<$Res>
    implements $SnTransactionCopyWith<$Res> {
  _$SnTransactionCopyWithImpl(this._self, this._then);

  final SnTransaction _self;
  final $Res Function(SnTransaction) _then;

  /// Create a copy of SnTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? remark = null,
    Object? amount = null,
    Object? payer = freezed,
    Object? payee = freezed,
    Object? payerId = freezed,
    Object? payeeId = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      remark: null == remark
          ? _self.remark
          : remark // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      payer: freezed == payer
          ? _self.payer
          : payer // ignore: cast_nullable_to_non_nullable
              as SnWallet?,
      payee: freezed == payee
          ? _self.payee
          : payee // ignore: cast_nullable_to_non_nullable
              as SnWallet?,
      payerId: freezed == payerId
          ? _self.payerId
          : payerId // ignore: cast_nullable_to_non_nullable
              as int?,
      payeeId: freezed == payeeId
          ? _self.payeeId
          : payeeId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }

  /// Create a copy of SnTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnWalletCopyWith<$Res>? get payer {
    if (_self.payer == null) {
      return null;
    }

    return $SnWalletCopyWith<$Res>(_self.payer!, (value) {
      return _then(_self.copyWith(payer: value));
    });
  }

  /// Create a copy of SnTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnWalletCopyWith<$Res>? get payee {
    if (_self.payee == null) {
      return null;
    }

    return $SnWalletCopyWith<$Res>(_self.payee!, (value) {
      return _then(_self.copyWith(payee: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SnTransaction implements SnTransaction {
  const _SnTransaction(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.remark,
      required this.amount,
      required this.payer,
      required this.payee,
      required this.payerId,
      required this.payeeId});
  factory _SnTransaction.fromJson(Map<String, dynamic> json) =>
      _$SnTransactionFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String remark;
  @override
  final String amount;
  @override
  final SnWallet? payer;
  @override
  final SnWallet? payee;
  @override
  final int? payerId;
  @override
  final int? payeeId;

  /// Create a copy of SnTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnTransactionCopyWith<_SnTransaction> get copyWith =>
      __$SnTransactionCopyWithImpl<_SnTransaction>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnTransactionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnTransaction &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.remark, remark) || other.remark == remark) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.payer, payer) || other.payer == payer) &&
            (identical(other.payee, payee) || other.payee == payee) &&
            (identical(other.payerId, payerId) || other.payerId == payerId) &&
            (identical(other.payeeId, payeeId) || other.payeeId == payeeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt,
      deletedAt, remark, amount, payer, payee, payerId, payeeId);

  @override
  String toString() {
    return 'SnTransaction(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, remark: $remark, amount: $amount, payer: $payer, payee: $payee, payerId: $payerId, payeeId: $payeeId)';
  }
}

/// @nodoc
abstract mixin class _$SnTransactionCopyWith<$Res>
    implements $SnTransactionCopyWith<$Res> {
  factory _$SnTransactionCopyWith(
          _SnTransaction value, $Res Function(_SnTransaction) _then) =
      __$SnTransactionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String remark,
      String amount,
      SnWallet? payer,
      SnWallet? payee,
      int? payerId,
      int? payeeId});

  @override
  $SnWalletCopyWith<$Res>? get payer;
  @override
  $SnWalletCopyWith<$Res>? get payee;
}

/// @nodoc
class __$SnTransactionCopyWithImpl<$Res>
    implements _$SnTransactionCopyWith<$Res> {
  __$SnTransactionCopyWithImpl(this._self, this._then);

  final _SnTransaction _self;
  final $Res Function(_SnTransaction) _then;

  /// Create a copy of SnTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? remark = null,
    Object? amount = null,
    Object? payer = freezed,
    Object? payee = freezed,
    Object? payerId = freezed,
    Object? payeeId = freezed,
  }) {
    return _then(_SnTransaction(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      remark: null == remark
          ? _self.remark
          : remark // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      payer: freezed == payer
          ? _self.payer
          : payer // ignore: cast_nullable_to_non_nullable
              as SnWallet?,
      payee: freezed == payee
          ? _self.payee
          : payee // ignore: cast_nullable_to_non_nullable
              as SnWallet?,
      payerId: freezed == payerId
          ? _self.payerId
          : payerId // ignore: cast_nullable_to_non_nullable
              as int?,
      payeeId: freezed == payeeId
          ? _self.payeeId
          : payeeId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }

  /// Create a copy of SnTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnWalletCopyWith<$Res>? get payer {
    if (_self.payer == null) {
      return null;
    }

    return $SnWalletCopyWith<$Res>(_self.payer!, (value) {
      return _then(_self.copyWith(payer: value));
    });
  }

  /// Create a copy of SnTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnWalletCopyWith<$Res>? get payee {
    if (_self.payee == null) {
      return null;
    }

    return $SnWalletCopyWith<$Res>(_self.payee!, (value) {
      return _then(_self.copyWith(payee: value));
    });
  }
}

// dart format on
