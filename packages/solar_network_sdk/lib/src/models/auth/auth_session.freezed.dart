// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SnAuthSession _$SnAuthSessionFromJson(Map<String, dynamic> json) {
  return _SnAuthSession.fromJson(json);
}

/// @nodoc
mixin _$SnAuthSession {
  String get id => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;
  DateTime get lastGrantedAt => throw _privateConstructorUsedError;
  DateTime? get expiredAt => throw _privateConstructorUsedError;
  List<dynamic> get audiences => throw _privateConstructorUsedError;
  List<dynamic> get scopes => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;
  String? get userAgent => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  int get type => throw _privateConstructorUsedError;
  String get accountId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Serializes this SnAuthSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAuthSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAuthSessionCopyWith<SnAuthSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAuthSessionCopyWith<$Res> {
  factory $SnAuthSessionCopyWith(
    SnAuthSession value,
    $Res Function(SnAuthSession) then,
  ) = _$SnAuthSessionCopyWithImpl<$Res, SnAuthSession>;
  @useResult
  $Res call({
    String id,
    String? label,
    DateTime lastGrantedAt,
    DateTime? expiredAt,
    List<dynamic> audiences,
    List<dynamic> scopes,
    String? ipAddress,
    String? userAgent,
    String? location,
    int type,
    String accountId,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$SnAuthSessionCopyWithImpl<$Res, $Val extends SnAuthSession>
    implements $SnAuthSessionCopyWith<$Res> {
  _$SnAuthSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAuthSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = freezed,
    Object? lastGrantedAt = null,
    Object? expiredAt = freezed,
    Object? audiences = null,
    Object? scopes = null,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? location = freezed,
    Object? type = null,
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
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastGrantedAt: null == lastGrantedAt
                ? _value.lastGrantedAt
                : lastGrantedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiredAt: freezed == expiredAt
                ? _value.expiredAt
                : expiredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            audiences: null == audiences
                ? _value.audiences
                : audiences // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
            scopes: null == scopes
                ? _value.scopes
                : scopes // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
            ipAddress: freezed == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            userAgent: freezed == userAgent
                ? _value.userAgent
                : userAgent // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$SnAuthSessionImplCopyWith<$Res>
    implements $SnAuthSessionCopyWith<$Res> {
  factory _$$SnAuthSessionImplCopyWith(
    _$SnAuthSessionImpl value,
    $Res Function(_$SnAuthSessionImpl) then,
  ) = __$$SnAuthSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? label,
    DateTime lastGrantedAt,
    DateTime? expiredAt,
    List<dynamic> audiences,
    List<dynamic> scopes,
    String? ipAddress,
    String? userAgent,
    String? location,
    int type,
    String accountId,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$SnAuthSessionImplCopyWithImpl<$Res>
    extends _$SnAuthSessionCopyWithImpl<$Res, _$SnAuthSessionImpl>
    implements _$$SnAuthSessionImplCopyWith<$Res> {
  __$$SnAuthSessionImplCopyWithImpl(
    _$SnAuthSessionImpl _value,
    $Res Function(_$SnAuthSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SnAuthSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = freezed,
    Object? lastGrantedAt = null,
    Object? expiredAt = freezed,
    Object? audiences = null,
    Object? scopes = null,
    Object? ipAddress = freezed,
    Object? userAgent = freezed,
    Object? location = freezed,
    Object? type = null,
    Object? accountId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$SnAuthSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastGrantedAt: null == lastGrantedAt
            ? _value.lastGrantedAt
            : lastGrantedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiredAt: freezed == expiredAt
            ? _value.expiredAt
            : expiredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        audiences: null == audiences
            ? _value._audiences
            : audiences // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
        scopes: null == scopes
            ? _value._scopes
            : scopes // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
        ipAddress: freezed == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        userAgent: freezed == userAgent
            ? _value.userAgent
            : userAgent // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$SnAuthSessionImpl implements _SnAuthSession {
  const _$SnAuthSessionImpl({
    required this.id,
    this.label,
    required this.lastGrantedAt,
    this.expiredAt,
    required final List<dynamic> audiences,
    required final List<dynamic> scopes,
    this.ipAddress,
    this.userAgent,
    this.location,
    required this.type,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  }) : _audiences = audiences,
       _scopes = scopes;

  factory _$SnAuthSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAuthSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String? label;
  @override
  final DateTime lastGrantedAt;
  @override
  final DateTime? expiredAt;
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
  final String? ipAddress;
  @override
  final String? userAgent;
  @override
  final String? location;
  @override
  final int type;
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
    return 'SnAuthSession(id: $id, label: $label, lastGrantedAt: $lastGrantedAt, expiredAt: $expiredAt, audiences: $audiences, scopes: $scopes, ipAddress: $ipAddress, userAgent: $userAgent, location: $location, type: $type, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAuthSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.lastGrantedAt, lastGrantedAt) ||
                other.lastGrantedAt == lastGrantedAt) &&
            (identical(other.expiredAt, expiredAt) ||
                other.expiredAt == expiredAt) &&
            const DeepCollectionEquality().equals(
              other._audiences,
              _audiences,
            ) &&
            const DeepCollectionEquality().equals(other._scopes, _scopes) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.userAgent, userAgent) ||
                other.userAgent == userAgent) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.type, type) || other.type == type) &&
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
    label,
    lastGrantedAt,
    expiredAt,
    const DeepCollectionEquality().hash(_audiences),
    const DeepCollectionEquality().hash(_scopes),
    ipAddress,
    userAgent,
    location,
    type,
    accountId,
    createdAt,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of SnAuthSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAuthSessionImplCopyWith<_$SnAuthSessionImpl> get copyWith =>
      __$$SnAuthSessionImplCopyWithImpl<_$SnAuthSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAuthSessionImplToJson(this);
  }
}

abstract class _SnAuthSession implements SnAuthSession {
  const factory _SnAuthSession({
    required final String id,
    final String? label,
    required final DateTime lastGrantedAt,
    final DateTime? expiredAt,
    required final List<dynamic> audiences,
    required final List<dynamic> scopes,
    final String? ipAddress,
    final String? userAgent,
    final String? location,
    required final int type,
    required final String accountId,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletedAt,
  }) = _$SnAuthSessionImpl;

  factory _SnAuthSession.fromJson(Map<String, dynamic> json) =
      _$SnAuthSessionImpl.fromJson;

  @override
  String get id;
  @override
  String? get label;
  @override
  DateTime get lastGrantedAt;
  @override
  DateTime? get expiredAt;
  @override
  List<dynamic> get audiences;
  @override
  List<dynamic> get scopes;
  @override
  String? get ipAddress;
  @override
  String? get userAgent;
  @override
  String? get location;
  @override
  int get type;
  @override
  String get accountId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;

  /// Create a copy of SnAuthSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAuthSessionImplCopyWith<_$SnAuthSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
