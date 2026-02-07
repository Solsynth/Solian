// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_challenge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SnAuthChallenge _$SnAuthChallengeFromJson(Map<String, dynamic> json) {
  return _SnAuthChallenge.fromJson(json);
}

/// @nodoc
mixin _$SnAuthChallenge {
  String get id => throw _privateConstructorUsedError;
  DateTime? get expiredAt => throw _privateConstructorUsedError;
  int get stepRemain => throw _privateConstructorUsedError;
  int get stepTotal => throw _privateConstructorUsedError;
  int get failedAttempts => throw _privateConstructorUsedError;
  List<String> get blacklistFactors => throw _privateConstructorUsedError;
  List<dynamic> get audiences => throw _privateConstructorUsedError;
  List<dynamic> get scopes => throw _privateConstructorUsedError;
  String get ipAddress => throw _privateConstructorUsedError;
  String get userAgent => throw _privateConstructorUsedError;
  String? get nonce => throw _privateConstructorUsedError;
  String? get countryCode => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String get accountId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Serializes this SnAuthChallenge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAuthChallenge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAuthChallengeCopyWith<SnAuthChallenge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAuthChallengeCopyWith<$Res> {
  factory $SnAuthChallengeCopyWith(
    SnAuthChallenge value,
    $Res Function(SnAuthChallenge) then,
  ) = _$SnAuthChallengeCopyWithImpl<$Res, SnAuthChallenge>;
  @useResult
  $Res call({
    String id,
    DateTime? expiredAt,
    int stepRemain,
    int stepTotal,
    int failedAttempts,
    List<String> blacklistFactors,
    List<dynamic> audiences,
    List<dynamic> scopes,
    String ipAddress,
    String userAgent,
    String? nonce,
    String? countryCode,
    String? country,
    String? city,
    String accountId,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$SnAuthChallengeCopyWithImpl<$Res, $Val extends SnAuthChallenge>
    implements $SnAuthChallengeCopyWith<$Res> {
  _$SnAuthChallengeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAuthChallenge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? expiredAt = freezed,
    Object? stepRemain = null,
    Object? stepTotal = null,
    Object? failedAttempts = null,
    Object? blacklistFactors = null,
    Object? audiences = null,
    Object? scopes = null,
    Object? ipAddress = null,
    Object? userAgent = null,
    Object? nonce = freezed,
    Object? countryCode = freezed,
    Object? country = freezed,
    Object? city = freezed,
    Object? accountId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            expiredAt: freezed == expiredAt
                ? _value.expiredAt
                : expiredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            stepRemain: null == stepRemain
                ? _value.stepRemain
                : stepRemain // ignore: cast_nullable_to_non_nullable
                      as int,
            stepTotal: null == stepTotal
                ? _value.stepTotal
                : stepTotal // ignore: cast_nullable_to_non_nullable
                      as int,
            failedAttempts: null == failedAttempts
                ? _value.failedAttempts
                : failedAttempts // ignore: cast_nullable_to_non_nullable
                      as int,
            blacklistFactors: null == blacklistFactors
                ? _value.blacklistFactors
                : blacklistFactors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            audiences: null == audiences
                ? _value.audiences
                : audiences // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
            scopes: null == scopes
                ? _value.scopes
                : scopes // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
            ipAddress: null == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            userAgent: null == userAgent
                ? _value.userAgent
                : userAgent // ignore: cast_nullable_to_non_nullable
                      as String,
            nonce: freezed == nonce
                ? _value.nonce
                : nonce // ignore: cast_nullable_to_non_nullable
                      as String?,
            countryCode: freezed == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            country: freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String?,
            city: freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String?,
            accountId: null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SnAuthChallengeImplCopyWith<$Res>
    implements $SnAuthChallengeCopyWith<$Res> {
  factory _$$SnAuthChallengeImplCopyWith(
    _$SnAuthChallengeImpl value,
    $Res Function(_$SnAuthChallengeImpl) then,
  ) = __$$SnAuthChallengeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime? expiredAt,
    int stepRemain,
    int stepTotal,
    int failedAttempts,
    List<String> blacklistFactors,
    List<dynamic> audiences,
    List<dynamic> scopes,
    String ipAddress,
    String userAgent,
    String? nonce,
    String? countryCode,
    String? country,
    String? city,
    String accountId,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$SnAuthChallengeImplCopyWithImpl<$Res>
    extends _$SnAuthChallengeCopyWithImpl<$Res, _$SnAuthChallengeImpl>
    implements _$$SnAuthChallengeImplCopyWith<$Res> {
  __$$SnAuthChallengeImplCopyWithImpl(
    _$SnAuthChallengeImpl _value,
    $Res Function(_$SnAuthChallengeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SnAuthChallenge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? expiredAt = freezed,
    Object? stepRemain = null,
    Object? stepTotal = null,
    Object? failedAttempts = null,
    Object? blacklistFactors = null,
    Object? audiences = null,
    Object? scopes = null,
    Object? ipAddress = null,
    Object? userAgent = null,
    Object? nonce = freezed,
    Object? countryCode = freezed,
    Object? country = freezed,
    Object? city = freezed,
    Object? accountId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$SnAuthChallengeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        expiredAt: freezed == expiredAt
            ? _value.expiredAt
            : expiredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        stepRemain: null == stepRemain
            ? _value.stepRemain
            : stepRemain // ignore: cast_nullable_to_non_nullable
                  as int,
        stepTotal: null == stepTotal
            ? _value.stepTotal
            : stepTotal // ignore: cast_nullable_to_non_nullable
                  as int,
        failedAttempts: null == failedAttempts
            ? _value.failedAttempts
            : failedAttempts // ignore: cast_nullable_to_non_nullable
                  as int,
        blacklistFactors: null == blacklistFactors
            ? _value._blacklistFactors
            : blacklistFactors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        audiences: null == audiences
            ? _value._audiences
            : audiences // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
        scopes: null == scopes
            ? _value._scopes
            : scopes // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
        ipAddress: null == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        userAgent: null == userAgent
            ? _value.userAgent
            : userAgent // ignore: cast_nullable_to_non_nullable
                  as String,
        nonce: freezed == nonce
            ? _value.nonce
            : nonce // ignore: cast_nullable_to_non_nullable
                  as String?,
        countryCode: freezed == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        country: freezed == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String?,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String?,
        accountId: null == accountId
            ? _value.accountId
            : accountId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAuthChallengeImpl implements _SnAuthChallenge {
  const _$SnAuthChallengeImpl({
    required this.id,
    this.expiredAt,
    required this.stepRemain,
    required this.stepTotal,
    required this.failedAttempts,
    required final List<String> blacklistFactors,
    required final List<dynamic> audiences,
    required final List<dynamic> scopes,
    required this.ipAddress,
    required this.userAgent,
    this.nonce,
    this.countryCode,
    this.country,
    this.city,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  }) : _blacklistFactors = blacklistFactors,
       _audiences = audiences,
       _scopes = scopes;

  factory _$SnAuthChallengeImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAuthChallengeImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime? expiredAt;
  @override
  final int stepRemain;
  @override
  final int stepTotal;
  @override
  final int failedAttempts;
  final List<String> _blacklistFactors;
  @override
  List<String> get blacklistFactors {
    if (_blacklistFactors is EqualUnmodifiableListView)
      return _blacklistFactors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blacklistFactors);
  }

  final List<dynamic> _audiences;
  @override
  List<dynamic> get audiences {
    if (_audiences is EqualUnmodifiableListView) return _audiences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_audiences);
  }

  final List<dynamic> _scopes;
  @override
  List<dynamic> get scopes {
    if (_scopes is EqualUnmodifiableListView) return _scopes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scopes);
  }

  @override
  final String ipAddress;
  @override
  final String userAgent;
  @override
  final String? nonce;
  @override
  final String? countryCode;
  @override
  final String? country;
  @override
  final String? city;
  @override
  final String accountId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'SnAuthChallenge(id: $id, expiredAt: $expiredAt, stepRemain: $stepRemain, stepTotal: $stepTotal, failedAttempts: $failedAttempts, blacklistFactors: $blacklistFactors, audiences: $audiences, scopes: $scopes, ipAddress: $ipAddress, userAgent: $userAgent, nonce: $nonce, countryCode: $countryCode, country: $country, city: $city, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAuthChallengeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.expiredAt, expiredAt) ||
                other.expiredAt == expiredAt) &&
            (identical(other.stepRemain, stepRemain) ||
                other.stepRemain == stepRemain) &&
            (identical(other.stepTotal, stepTotal) ||
                other.stepTotal == stepTotal) &&
            (identical(other.failedAttempts, failedAttempts) ||
                other.failedAttempts == failedAttempts) &&
            const DeepCollectionEquality().equals(
              other._blacklistFactors,
              _blacklistFactors,
            ) &&
            const DeepCollectionEquality().equals(
              other._audiences,
              _audiences,
            ) &&
            const DeepCollectionEquality().equals(other._scopes, _scopes) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.nonce, nonce) || other.nonce == nonce) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    expiredAt,
    stepRemain,
    stepTotal,
    failedAttempts,
    const DeepCollectionEquality().hash(_blacklistFactors),
    const DeepCollectionEquality().hash(_audiences),
    const DeepCollectionEquality().hash(_scopes),
    ipAddress,
    userAgent,
    nonce,
    countryCode,
    country,
    city,
    accountId,
    createdAt,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of SnAuthChallenge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAuthChallengeImplCopyWith<_$SnAuthChallengeImpl> get copyWith =>
      __$$SnAuthChallengeImplCopyWithImpl<_$SnAuthChallengeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAuthChallengeImplToJson(this);
  }
}

abstract class _SnAuthChallenge implements SnAuthChallenge {
  const factory _SnAuthChallenge({
    required final String id,
    final DateTime? expiredAt,
    required final int stepRemain,
    required final int stepTotal,
    required final int failedAttempts,
    required final List<String> blacklistFactors,
    required final List<dynamic> audiences,
    required final List<dynamic> scopes,
    required final String ipAddress,
    required final String userAgent,
    final String? nonce,
    final String? countryCode,
    final String? country,
    final String? city,
    required final String accountId,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$SnAuthChallengeImpl;

  factory _SnAuthChallenge.fromJson(Map<String, dynamic> json) =
      _$SnAuthChallengeImpl.fromJson;

  @override
  String get id;
  @override
  DateTime? get expiredAt;
  @override
  int get stepRemain;
  @override
  int get stepTotal;
  @override
  int get failedAttempts;
  @override
  List<String> get blacklistFactors;
  @override
  List<dynamic> get audiences;
  @override
  List<dynamic> get scopes;
  @override
  String get ipAddress;
  @override
  String get userAgent;
  @override
  String? get nonce;
  @override
  String? get countryCode;
  @override
  String? get country;
  @override
  String? get city;
  @override
  String get accountId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of SnAuthChallenge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAuthChallengeImplCopyWith<_$SnAuthChallengeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnAuthFactor _$SnAuthFactorFromJson(Map<String, dynamic> json) {
  return _SnAuthFactor.fromJson(json);
}

/// @nodoc
mixin _$SnAuthFactor {
  String get id => throw _privateConstructorUsedError;
  int get type => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  DateTime? get expiredAt => throw _privateConstructorUsedError;
  DateTime? get enabledAt => throw _privateConstructorUsedError;
  int get trustworthy => throw _privateConstructorUsedError;
  Map<String, dynamic>? get createdResponse =>
      throw _privateConstructorUsedError;

  /// Serializes this SnAuthFactor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAuthFactor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAuthFactorCopyWith<SnAuthFactor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAuthFactorCopyWith<$Res> {
  factory $SnAuthFactorCopyWith(
    SnAuthFactor value,
    $Res Function(SnAuthFactor) then,
  ) = _$SnAuthFactorCopyWithImpl<$Res, SnAuthFactor>;
  @useResult
  $Res call({
    String id,
    int type,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
    DateTime? expiredAt,
    DateTime? enabledAt,
    int trustworthy,
    Map<String, dynamic>? createdResponse,
  });
}

/// @nodoc
class _$SnAuthFactorCopyWithImpl<$Res, $Val extends SnAuthFactor>
    implements $SnAuthFactorCopyWith<$Res> {
  _$SnAuthFactorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAuthFactor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? expiredAt = freezed,
    Object? enabledAt = freezed,
    Object? trustworthy = null,
    Object? createdResponse = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiredAt: freezed == expiredAt
                ? _value.expiredAt
                : expiredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            enabledAt: freezed == enabledAt
                ? _value.enabledAt
                : enabledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            trustworthy: null == trustworthy
                ? _value.trustworthy
                : trustworthy // ignore: cast_nullable_to_non_nullable
                      as int,
            createdResponse: freezed == createdResponse
                ? _value.createdResponse
                : createdResponse // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SnAuthFactorImplCopyWith<$Res>
    implements $SnAuthFactorCopyWith<$Res> {
  factory _$$SnAuthFactorImplCopyWith(
    _$SnAuthFactorImpl value,
    $Res Function(_$SnAuthFactorImpl) then,
  ) = __$$SnAuthFactorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int type,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
    DateTime? expiredAt,
    DateTime? enabledAt,
    int trustworthy,
    Map<String, dynamic>? createdResponse,
  });
}

/// @nodoc
class __$$SnAuthFactorImplCopyWithImpl<$Res>
    extends _$SnAuthFactorCopyWithImpl<$Res, _$SnAuthFactorImpl>
    implements _$$SnAuthFactorImplCopyWith<$Res> {
  __$$SnAuthFactorImplCopyWithImpl(
    _$SnAuthFactorImpl _value,
    $Res Function(_$SnAuthFactorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SnAuthFactor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? expiredAt = freezed,
    Object? enabledAt = freezed,
    Object? trustworthy = null,
    Object? createdResponse = freezed,
  }) {
    return _then(
      _$SnAuthFactorImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiredAt: freezed == expiredAt
            ? _value.expiredAt
            : expiredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        enabledAt: freezed == enabledAt
            ? _value.enabledAt
            : enabledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        trustworthy: null == trustworthy
            ? _value.trustworthy
            : trustworthy // ignore: cast_nullable_to_non_nullable
                  as int,
        createdResponse: freezed == createdResponse
            ? _value._createdResponse
            : createdResponse // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAuthFactorImpl implements _SnAuthFactor {
  const _$SnAuthFactorImpl({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.expiredAt,
    this.enabledAt,
    required this.trustworthy,
    final Map<String, dynamic>? createdResponse,
  }) : _createdResponse = createdResponse;

  factory _$SnAuthFactorImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAuthFactorImplFromJson(json);

  @override
  final String id;
  @override
  final int type;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final DateTime? expiredAt;
  @override
  final DateTime? enabledAt;
  @override
  final int trustworthy;
  final Map<String, dynamic>? _createdResponse;
  @override
  Map<String, dynamic>? get createdResponse {
    final value = _createdResponse;
    if (value == null) return null;
    if (_createdResponse is EqualUnmodifiableMapView) return _createdResponse;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'SnAuthFactor(id: $id, type: $type, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, expiredAt: $expiredAt, enabledAt: $enabledAt, trustworthy: $trustworthy, createdResponse: $createdResponse)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAuthFactorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.expiredAt, expiredAt) ||
                other.expiredAt == expiredAt) &&
            (identical(other.enabledAt, enabledAt) ||
                other.enabledAt == enabledAt) &&
            (identical(other.trustworthy, trustworthy) ||
                other.trustworthy == trustworthy) &&
            const DeepCollectionEquality().equals(
              other._createdResponse,
              _createdResponse,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    createdAt,
    updatedAt,
    deletedAt,
    expiredAt,
    enabledAt,
    trustworthy,
    const DeepCollectionEquality().hash(_createdResponse),
  );

  /// Create a copy of SnAuthFactor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAuthFactorImplCopyWith<_$SnAuthFactorImpl> get copyWith =>
      __$$SnAuthFactorImplCopyWithImpl<_$SnAuthFactorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAuthFactorImplToJson(this);
  }
}

abstract class _SnAuthFactor implements SnAuthFactor {
  const factory _SnAuthFactor({
    required final String id,
    required final int type,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
    final DateTime? expiredAt,
    final DateTime? enabledAt,
    required final int trustworthy,
    final Map<String, dynamic>? createdResponse,
  }) = _$SnAuthFactorImpl;

  factory _SnAuthFactor.fromJson(Map<String, dynamic> json) =
      _$SnAuthFactorImpl.fromJson;

  @override
  String get id;
  @override
  int get type;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  DateTime? get expiredAt;
  @override
  DateTime? get enabledAt;
  @override
  int get trustworthy;
  @override
  Map<String, dynamic>? get createdResponse;

  /// Create a copy of SnAuthFactor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAuthFactorImplCopyWith<_$SnAuthFactorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnAccountConnection _$SnAccountConnectionFromJson(Map<String, dynamic> json) {
  return _SnAccountConnection.fromJson(json);
}

/// @nodoc
mixin _$SnAccountConnection {
  String get id => throw _privateConstructorUsedError;
  String get accountId => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  String get providedIdentifier => throw _privateConstructorUsedError;
  Map<String, dynamic> get meta => throw _privateConstructorUsedError;
  DateTime get lastUsedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Serializes this SnAccountConnection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAccountConnection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAccountConnectionCopyWith<SnAccountConnection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAccountConnectionCopyWith<$Res> {
  factory $SnAccountConnectionCopyWith(
    SnAccountConnection value,
    $Res Function(SnAccountConnection) then,
  ) = _$SnAccountConnectionCopyWithImpl<$Res, SnAccountConnection>;
  @useResult
  $Res call({
    String id,
    String accountId,
    String provider,
    String providedIdentifier,
    Map<String, dynamic> meta,
    DateTime lastUsedAt,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$SnAccountConnectionCopyWithImpl<$Res, $Val extends SnAccountConnection>
    implements $SnAccountConnectionCopyWith<$Res> {
  _$SnAccountConnectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAccountConnection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? provider = null,
    Object? providedIdentifier = null,
    Object? meta = null,
    Object? lastUsedAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            accountId: null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                      as String,
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            providedIdentifier: null == providedIdentifier
                ? _value.providedIdentifier
                : providedIdentifier // ignore: cast_nullable_to_non_nullable
                      as String,
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            lastUsedAt: null == lastUsedAt
                ? _value.lastUsedAt
                : lastUsedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SnAccountConnectionImplCopyWith<$Res>
    implements $SnAccountConnectionCopyWith<$Res> {
  factory _$$SnAccountConnectionImplCopyWith(
    _$SnAccountConnectionImpl value,
    $Res Function(_$SnAccountConnectionImpl) then,
  ) = __$$SnAccountConnectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String accountId,
    String provider,
    String providedIdentifier,
    Map<String, dynamic> meta,
    DateTime lastUsedAt,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$SnAccountConnectionImplCopyWithImpl<$Res>
    extends _$SnAccountConnectionCopyWithImpl<$Res, _$SnAccountConnectionImpl>
    implements _$$SnAccountConnectionImplCopyWith<$Res> {
  __$$SnAccountConnectionImplCopyWithImpl(
    _$SnAccountConnectionImpl _value,
    $Res Function(_$SnAccountConnectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SnAccountConnection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? provider = null,
    Object? providedIdentifier = null,
    Object? meta = null,
    Object? lastUsedAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$SnAccountConnectionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        accountId: null == accountId
            ? _value.accountId
            : accountId // ignore: cast_nullable_to_non_nullable
                  as String,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        providedIdentifier: null == providedIdentifier
            ? _value.providedIdentifier
            : providedIdentifier // ignore: cast_nullable_to_non_nullable
                  as String,
        meta: null == meta
            ? _value._meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        lastUsedAt: null == lastUsedAt
            ? _value.lastUsedAt
            : lastUsedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAccountConnectionImpl implements _SnAccountConnection {
  const _$SnAccountConnectionImpl({
    required this.id,
    required this.accountId,
    required this.provider,
    required this.providedIdentifier,
    final Map<String, dynamic> meta = const {},
    required this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  }) : _meta = meta;

  factory _$SnAccountConnectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAccountConnectionImplFromJson(json);

  @override
  final String id;
  @override
  final String accountId;
  @override
  final String provider;
  @override
  final String providedIdentifier;
  final Map<String, dynamic> _meta;
  @override
  @JsonKey()
  Map<String, dynamic> get meta {
    if (_meta is EqualUnmodifiableMapView) return _meta;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_meta);
  }

  @override
  final DateTime lastUsedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'SnAccountConnection(id: $id, accountId: $accountId, provider: $provider, providedIdentifier: $providedIdentifier, meta: $meta, lastUsedAt: $lastUsedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAccountConnectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.providedIdentifier, providedIdentifier) ||
                other.providedIdentifier == providedIdentifier) &&
            const DeepCollectionEquality().equals(other._meta, _meta) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                other.lastUsedAt == lastUsedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    accountId,
    provider,
    providedIdentifier,
    const DeepCollectionEquality().hash(_meta),
    lastUsedAt,
    createdAt,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of SnAccountConnection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAccountConnectionImplCopyWith<_$SnAccountConnectionImpl> get copyWith =>
      __$$SnAccountConnectionImplCopyWithImpl<_$SnAccountConnectionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAccountConnectionImplToJson(this);
  }
}

abstract class _SnAccountConnection implements SnAccountConnection {
  const factory _SnAccountConnection({
    required final String id,
    required final String accountId,
    required final String provider,
    required final String providedIdentifier,
    final Map<String, dynamic> meta,
    required final DateTime lastUsedAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$SnAccountConnectionImpl;

  factory _SnAccountConnection.fromJson(Map<String, dynamic> json) =
      _$SnAccountConnectionImpl.fromJson;

  @override
  String get id;
  @override
  String get accountId;
  @override
  String get provider;
  @override
  String get providedIdentifier;
  @override
  Map<String, dynamic> get meta;
  @override
  DateTime get lastUsedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of SnAccountConnection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAccountConnectionImplCopyWith<_$SnAccountConnectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
