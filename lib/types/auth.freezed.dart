// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnAuthResult {
  bool get isFinished;
  SnAuthTicket? get ticket;

  /// Create a copy of SnAuthResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnAuthResultCopyWith<SnAuthResult> get copyWith =>
      _$SnAuthResultCopyWithImpl<SnAuthResult>(
          this as SnAuthResult, _$identity);

  /// Serializes this SnAuthResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnAuthResult &&
            (identical(other.isFinished, isFinished) ||
                other.isFinished == isFinished) &&
            (identical(other.ticket, ticket) || other.ticket == ticket));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isFinished, ticket);

  @override
  String toString() {
    return 'SnAuthResult(isFinished: $isFinished, ticket: $ticket)';
  }
}

/// @nodoc
abstract mixin class $SnAuthResultCopyWith<$Res> {
  factory $SnAuthResultCopyWith(
          SnAuthResult value, $Res Function(SnAuthResult) _then) =
      _$SnAuthResultCopyWithImpl;
  @useResult
  $Res call({bool isFinished, SnAuthTicket? ticket});

  $SnAuthTicketCopyWith<$Res>? get ticket;
}

/// @nodoc
class _$SnAuthResultCopyWithImpl<$Res> implements $SnAuthResultCopyWith<$Res> {
  _$SnAuthResultCopyWithImpl(this._self, this._then);

  final SnAuthResult _self;
  final $Res Function(SnAuthResult) _then;

  /// Create a copy of SnAuthResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isFinished = null,
    Object? ticket = freezed,
  }) {
    return _then(_self.copyWith(
      isFinished: null == isFinished
          ? _self.isFinished
          : isFinished // ignore: cast_nullable_to_non_nullable
              as bool,
      ticket: freezed == ticket
          ? _self.ticket
          : ticket // ignore: cast_nullable_to_non_nullable
              as SnAuthTicket?,
    ));
  }

  /// Create a copy of SnAuthResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAuthTicketCopyWith<$Res>? get ticket {
    if (_self.ticket == null) {
      return null;
    }

    return $SnAuthTicketCopyWith<$Res>(_self.ticket!, (value) {
      return _then(_self.copyWith(ticket: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SnAuthResult implements SnAuthResult {
  const _SnAuthResult({required this.isFinished, required this.ticket});
  factory _SnAuthResult.fromJson(Map<String, dynamic> json) =>
      _$SnAuthResultFromJson(json);

  @override
  final bool isFinished;
  @override
  final SnAuthTicket? ticket;

  /// Create a copy of SnAuthResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnAuthResultCopyWith<_SnAuthResult> get copyWith =>
      __$SnAuthResultCopyWithImpl<_SnAuthResult>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnAuthResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnAuthResult &&
            (identical(other.isFinished, isFinished) ||
                other.isFinished == isFinished) &&
            (identical(other.ticket, ticket) || other.ticket == ticket));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isFinished, ticket);

  @override
  String toString() {
    return 'SnAuthResult(isFinished: $isFinished, ticket: $ticket)';
  }
}

/// @nodoc
abstract mixin class _$SnAuthResultCopyWith<$Res>
    implements $SnAuthResultCopyWith<$Res> {
  factory _$SnAuthResultCopyWith(
          _SnAuthResult value, $Res Function(_SnAuthResult) _then) =
      __$SnAuthResultCopyWithImpl;
  @override
  @useResult
  $Res call({bool isFinished, SnAuthTicket? ticket});

  @override
  $SnAuthTicketCopyWith<$Res>? get ticket;
}

/// @nodoc
class __$SnAuthResultCopyWithImpl<$Res>
    implements _$SnAuthResultCopyWith<$Res> {
  __$SnAuthResultCopyWithImpl(this._self, this._then);

  final _SnAuthResult _self;
  final $Res Function(_SnAuthResult) _then;

  /// Create a copy of SnAuthResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isFinished = null,
    Object? ticket = freezed,
  }) {
    return _then(_SnAuthResult(
      isFinished: null == isFinished
          ? _self.isFinished
          : isFinished // ignore: cast_nullable_to_non_nullable
              as bool,
      ticket: freezed == ticket
          ? _self.ticket
          : ticket // ignore: cast_nullable_to_non_nullable
              as SnAuthTicket?,
    ));
  }

  /// Create a copy of SnAuthResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAuthTicketCopyWith<$Res>? get ticket {
    if (_self.ticket == null) {
      return null;
    }

    return $SnAuthTicketCopyWith<$Res>(_self.ticket!, (value) {
      return _then(_self.copyWith(ticket: value));
    });
  }
}

/// @nodoc
mixin _$SnAuthTicket {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  int get stepRemain;
  String? get grantToken;
  String? get accessToken;
  String? get refreshToken;
  String get ipAddress;
  String? get location;
  double? get coordinateX;
  double? get coordinateY;
  String get userAgent;
  DateTime? get expiredAt;
  DateTime? get lastGrantAt;
  DateTime? get availableAt;
  String? get nonce;
  int? get accountId;
  List<int> get factorTrail;

  /// Create a copy of SnAuthTicket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnAuthTicketCopyWith<SnAuthTicket> get copyWith =>
      _$SnAuthTicketCopyWithImpl<SnAuthTicket>(
          this as SnAuthTicket, _$identity);

  /// Serializes this SnAuthTicket to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnAuthTicket &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.stepRemain, stepRemain) ||
                other.stepRemain == stepRemain) &&
            (identical(other.grantToken, grantToken) ||
                other.grantToken == grantToken) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.coordinateX, coordinateX) ||
                other.coordinateX == coordinateX) &&
            (identical(other.coordinateY, coordinateY) ||
                other.coordinateY == coordinateY) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.expiredAt, expiredAt) ||
                other.expiredAt == expiredAt) &&
            (identical(other.lastGrantAt, lastGrantAt) ||
                other.lastGrantAt == lastGrantAt) &&
            (identical(other.availableAt, availableAt) ||
                other.availableAt == availableAt) &&
            (identical(other.nonce, nonce) || other.nonce == nonce) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            const DeepCollectionEquality()
                .equals(other.factorTrail, factorTrail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        createdAt,
        updatedAt,
        deletedAt,
        stepRemain,
        grantToken,
        accessToken,
        refreshToken,
        ipAddress,
        location,
        coordinateX,
        coordinateY,
        userAgent,
        expiredAt,
        lastGrantAt,
        availableAt,
        nonce,
        accountId,
        const DeepCollectionEquality().hash(factorTrail)
      ]);

  @override
  String toString() {
    return 'SnAuthTicket(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, stepRemain: $stepRemain, grantToken: $grantToken, accessToken: $accessToken, refreshToken: $refreshToken, ipAddress: $ipAddress, location: $location, coordinateX: $coordinateX, coordinateY: $coordinateY, userAgent: $userAgent, expiredAt: $expiredAt, lastGrantAt: $lastGrantAt, availableAt: $availableAt, nonce: $nonce, accountId: $accountId, factorTrail: $factorTrail)';
  }
}

/// @nodoc
abstract mixin class $SnAuthTicketCopyWith<$Res> {
  factory $SnAuthTicketCopyWith(
          SnAuthTicket value, $Res Function(SnAuthTicket) _then) =
      _$SnAuthTicketCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int stepRemain,
      String? grantToken,
      String? accessToken,
      String? refreshToken,
      String ipAddress,
      String? location,
      double? coordinateX,
      double? coordinateY,
      String userAgent,
      DateTime? expiredAt,
      DateTime? lastGrantAt,
      DateTime? availableAt,
      String? nonce,
      int? accountId,
      List<int> factorTrail});
}

/// @nodoc
class _$SnAuthTicketCopyWithImpl<$Res> implements $SnAuthTicketCopyWith<$Res> {
  _$SnAuthTicketCopyWithImpl(this._self, this._then);

  final SnAuthTicket _self;
  final $Res Function(SnAuthTicket) _then;

  /// Create a copy of SnAuthTicket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? stepRemain = null,
    Object? grantToken = freezed,
    Object? accessToken = freezed,
    Object? refreshToken = freezed,
    Object? ipAddress = null,
    Object? location = freezed,
    Object? coordinateX = freezed,
    Object? coordinateY = freezed,
    Object? userAgent = null,
    Object? expiredAt = freezed,
    Object? lastGrantAt = freezed,
    Object? availableAt = freezed,
    Object? nonce = freezed,
    Object? accountId = freezed,
    Object? factorTrail = null,
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
      stepRemain: null == stepRemain
          ? _self.stepRemain
          : stepRemain // ignore: cast_nullable_to_non_nullable
              as int,
      grantToken: freezed == grantToken
          ? _self.grantToken
          : grantToken // ignore: cast_nullable_to_non_nullable
              as String?,
      accessToken: freezed == accessToken
          ? _self.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      refreshToken: freezed == refreshToken
          ? _self.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      ipAddress: null == ipAddress
          ? _self.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      coordinateX: freezed == coordinateX
          ? _self.coordinateX
          : coordinateX // ignore: cast_nullable_to_non_nullable
              as double?,
      coordinateY: freezed == coordinateY
          ? _self.coordinateY
          : coordinateY // ignore: cast_nullable_to_non_nullable
              as double?,
      userAgent: null == userAgent
          ? _self.userAgent
          : userAgent // ignore: cast_nullable_to_non_nullable
              as String,
      expiredAt: freezed == expiredAt
          ? _self.expiredAt
          : expiredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastGrantAt: freezed == lastGrantAt
          ? _self.lastGrantAt
          : lastGrantAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      availableAt: freezed == availableAt
          ? _self.availableAt
          : availableAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nonce: freezed == nonce
          ? _self.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String?,
      accountId: freezed == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int?,
      factorTrail: null == factorTrail
          ? _self.factorTrail
          : factorTrail // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnAuthTicket implements SnAuthTicket {
  const _SnAuthTicket(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.stepRemain,
      required this.grantToken,
      required this.accessToken,
      required this.refreshToken,
      required this.ipAddress,
      required this.location,
      required this.coordinateX,
      required this.coordinateY,
      required this.userAgent,
      required this.expiredAt,
      required this.lastGrantAt,
      required this.availableAt,
      required this.nonce,
      required this.accountId,
      final List<int> factorTrail = const []})
      : _factorTrail = factorTrail;
  factory _SnAuthTicket.fromJson(Map<String, dynamic> json) =>
      _$SnAuthTicketFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final int stepRemain;
  @override
  final String? grantToken;
  @override
  final String? accessToken;
  @override
  final String? refreshToken;
  @override
  final String ipAddress;
  @override
  final String? location;
  @override
  final double? coordinateX;
  @override
  final double? coordinateY;
  @override
  final String userAgent;
  @override
  final DateTime? expiredAt;
  @override
  final DateTime? lastGrantAt;
  @override
  final DateTime? availableAt;
  @override
  final String? nonce;
  @override
  final int? accountId;
  final List<int> _factorTrail;
  @override
  @JsonKey()
  List<int> get factorTrail {
    if (_factorTrail is EqualUnmodifiableListView) return _factorTrail;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_factorTrail);
  }

  /// Create a copy of SnAuthTicket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnAuthTicketCopyWith<_SnAuthTicket> get copyWith =>
      __$SnAuthTicketCopyWithImpl<_SnAuthTicket>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnAuthTicketToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnAuthTicket &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.stepRemain, stepRemain) ||
                other.stepRemain == stepRemain) &&
            (identical(other.grantToken, grantToken) ||
                other.grantToken == grantToken) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.coordinateX, coordinateX) ||
                other.coordinateX == coordinateX) &&
            (identical(other.coordinateY, coordinateY) ||
                other.coordinateY == coordinateY) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.expiredAt, expiredAt) ||
                other.expiredAt == expiredAt) &&
            (identical(other.lastGrantAt, lastGrantAt) ||
                other.lastGrantAt == lastGrantAt) &&
            (identical(other.availableAt, availableAt) ||
                other.availableAt == availableAt) &&
            (identical(other.nonce, nonce) || other.nonce == nonce) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            const DeepCollectionEquality()
                .equals(other._factorTrail, _factorTrail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        createdAt,
        updatedAt,
        deletedAt,
        stepRemain,
        grantToken,
        accessToken,
        refreshToken,
        ipAddress,
        location,
        coordinateX,
        coordinateY,
        userAgent,
        expiredAt,
        lastGrantAt,
        availableAt,
        nonce,
        accountId,
        const DeepCollectionEquality().hash(_factorTrail)
      ]);

  @override
  String toString() {
    return 'SnAuthTicket(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, stepRemain: $stepRemain, grantToken: $grantToken, accessToken: $accessToken, refreshToken: $refreshToken, ipAddress: $ipAddress, location: $location, coordinateX: $coordinateX, coordinateY: $coordinateY, userAgent: $userAgent, expiredAt: $expiredAt, lastGrantAt: $lastGrantAt, availableAt: $availableAt, nonce: $nonce, accountId: $accountId, factorTrail: $factorTrail)';
  }
}

/// @nodoc
abstract mixin class _$SnAuthTicketCopyWith<$Res>
    implements $SnAuthTicketCopyWith<$Res> {
  factory _$SnAuthTicketCopyWith(
          _SnAuthTicket value, $Res Function(_SnAuthTicket) _then) =
      __$SnAuthTicketCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int stepRemain,
      String? grantToken,
      String? accessToken,
      String? refreshToken,
      String ipAddress,
      String? location,
      double? coordinateX,
      double? coordinateY,
      String userAgent,
      DateTime? expiredAt,
      DateTime? lastGrantAt,
      DateTime? availableAt,
      String? nonce,
      int? accountId,
      List<int> factorTrail});
}

/// @nodoc
class __$SnAuthTicketCopyWithImpl<$Res>
    implements _$SnAuthTicketCopyWith<$Res> {
  __$SnAuthTicketCopyWithImpl(this._self, this._then);

  final _SnAuthTicket _self;
  final $Res Function(_SnAuthTicket) _then;

  /// Create a copy of SnAuthTicket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? stepRemain = null,
    Object? grantToken = freezed,
    Object? accessToken = freezed,
    Object? refreshToken = freezed,
    Object? ipAddress = null,
    Object? location = freezed,
    Object? coordinateX = freezed,
    Object? coordinateY = freezed,
    Object? userAgent = null,
    Object? expiredAt = freezed,
    Object? lastGrantAt = freezed,
    Object? availableAt = freezed,
    Object? nonce = freezed,
    Object? accountId = freezed,
    Object? factorTrail = null,
  }) {
    return _then(_SnAuthTicket(
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
      stepRemain: null == stepRemain
          ? _self.stepRemain
          : stepRemain // ignore: cast_nullable_to_non_nullable
              as int,
      grantToken: freezed == grantToken
          ? _self.grantToken
          : grantToken // ignore: cast_nullable_to_non_nullable
              as String?,
      accessToken: freezed == accessToken
          ? _self.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      refreshToken: freezed == refreshToken
          ? _self.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      ipAddress: null == ipAddress
          ? _self.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      coordinateX: freezed == coordinateX
          ? _self.coordinateX
          : coordinateX // ignore: cast_nullable_to_non_nullable
              as double?,
      coordinateY: freezed == coordinateY
          ? _self.coordinateY
          : coordinateY // ignore: cast_nullable_to_non_nullable
              as double?,
      userAgent: null == userAgent
          ? _self.userAgent
          : userAgent // ignore: cast_nullable_to_non_nullable
              as String,
      expiredAt: freezed == expiredAt
          ? _self.expiredAt
          : expiredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastGrantAt: freezed == lastGrantAt
          ? _self.lastGrantAt
          : lastGrantAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      availableAt: freezed == availableAt
          ? _self.availableAt
          : availableAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nonce: freezed == nonce
          ? _self.nonce
          : nonce // ignore: cast_nullable_to_non_nullable
              as String?,
      accountId: freezed == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int?,
      factorTrail: null == factorTrail
          ? _self._factorTrail
          : factorTrail // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
mixin _$SnAuthFactor {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  int get type;
  Map<String, dynamic>? get config;
  int? get accountId;

  /// Create a copy of SnAuthFactor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnAuthFactorCopyWith<SnAuthFactor> get copyWith =>
      _$SnAuthFactorCopyWithImpl<SnAuthFactor>(
          this as SnAuthFactor, _$identity);

  /// Serializes this SnAuthFactor to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnAuthFactor &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other.config, config) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt,
      deletedAt, type, const DeepCollectionEquality().hash(config), accountId);

  @override
  String toString() {
    return 'SnAuthFactor(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, type: $type, config: $config, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class $SnAuthFactorCopyWith<$Res> {
  factory $SnAuthFactorCopyWith(
          SnAuthFactor value, $Res Function(SnAuthFactor) _then) =
      _$SnAuthFactorCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int type,
      Map<String, dynamic>? config,
      int? accountId});
}

/// @nodoc
class _$SnAuthFactorCopyWithImpl<$Res> implements $SnAuthFactorCopyWith<$Res> {
  _$SnAuthFactorCopyWithImpl(this._self, this._then);

  final SnAuthFactor _self;
  final $Res Function(SnAuthFactor) _then;

  /// Create a copy of SnAuthFactor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? type = null,
    Object? config = freezed,
    Object? accountId = freezed,
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
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      config: freezed == config
          ? _self.config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      accountId: freezed == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnAuthFactor implements SnAuthFactor {
  const _SnAuthFactor(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.type,
      required final Map<String, dynamic>? config,
      required this.accountId})
      : _config = config;
  factory _SnAuthFactor.fromJson(Map<String, dynamic> json) =>
      _$SnAuthFactorFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final int type;
  final Map<String, dynamic>? _config;
  @override
  Map<String, dynamic>? get config {
    final value = _config;
    if (value == null) return null;
    if (_config is EqualUnmodifiableMapView) return _config;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final int? accountId;

  /// Create a copy of SnAuthFactor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnAuthFactorCopyWith<_SnAuthFactor> get copyWith =>
      __$SnAuthFactorCopyWithImpl<_SnAuthFactor>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnAuthFactorToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnAuthFactor &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._config, _config) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt,
      deletedAt, type, const DeepCollectionEquality().hash(_config), accountId);

  @override
  String toString() {
    return 'SnAuthFactor(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, type: $type, config: $config, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class _$SnAuthFactorCopyWith<$Res>
    implements $SnAuthFactorCopyWith<$Res> {
  factory _$SnAuthFactorCopyWith(
          _SnAuthFactor value, $Res Function(_SnAuthFactor) _then) =
      __$SnAuthFactorCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int type,
      Map<String, dynamic>? config,
      int? accountId});
}

/// @nodoc
class __$SnAuthFactorCopyWithImpl<$Res>
    implements _$SnAuthFactorCopyWith<$Res> {
  __$SnAuthFactorCopyWithImpl(this._self, this._then);

  final _SnAuthFactor _self;
  final $Res Function(_SnAuthFactor) _then;

  /// Create a copy of SnAuthFactor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? type = null,
    Object? config = freezed,
    Object? accountId = freezed,
  }) {
    return _then(_SnAuthFactor(
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
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      config: freezed == config
          ? _self._config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      accountId: freezed == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
