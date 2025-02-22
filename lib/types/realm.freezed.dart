// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'realm.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SnRealmMember _$SnRealmMemberFromJson(Map<String, dynamic> json) {
  return _SnRealmMember.fromJson(json);
}

/// @nodoc
mixin _$SnRealmMember {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  int get realmId => throw _privateConstructorUsedError;
  int get accountId => throw _privateConstructorUsedError;
  SnRealm get realm => throw _privateConstructorUsedError;
  SnAccount get account => throw _privateConstructorUsedError;
  int get powerLevel => throw _privateConstructorUsedError;

  /// Serializes this SnRealmMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnRealmMemberCopyWith<SnRealmMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnRealmMemberCopyWith<$Res> {
  factory $SnRealmMemberCopyWith(
          SnRealmMember value, $Res Function(SnRealmMember) then) =
      _$SnRealmMemberCopyWithImpl<$Res, SnRealmMember>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int realmId,
      int accountId,
      SnRealm realm,
      SnAccount account,
      int powerLevel});

  $SnRealmCopyWith<$Res> get realm;
  $SnAccountCopyWith<$Res> get account;
}

/// @nodoc
class _$SnRealmMemberCopyWithImpl<$Res, $Val extends SnRealmMember>
    implements $SnRealmMemberCopyWith<$Res> {
  _$SnRealmMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? realmId = null,
    Object? accountId = null,
    Object? realm = null,
    Object? account = null,
    Object? powerLevel = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      realmId: null == realmId
          ? _value.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      realm: null == realm
          ? _value.realm
          : realm // ignore: cast_nullable_to_non_nullable
              as SnRealm,
      account: null == account
          ? _value.account
          : account // ignore: cast_nullable_to_non_nullable
              as SnAccount,
      powerLevel: null == powerLevel
          ? _value.powerLevel
          : powerLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnRealmCopyWith<$Res> get realm {
    return $SnRealmCopyWith<$Res>(_value.realm, (value) {
      return _then(_value.copyWith(realm: value) as $Val);
    });
  }

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAccountCopyWith<$Res> get account {
    return $SnAccountCopyWith<$Res>(_value.account, (value) {
      return _then(_value.copyWith(account: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnRealmMemberImplCopyWith<$Res>
    implements $SnRealmMemberCopyWith<$Res> {
  factory _$$SnRealmMemberImplCopyWith(
          _$SnRealmMemberImpl value, $Res Function(_$SnRealmMemberImpl) then) =
      __$$SnRealmMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int realmId,
      int accountId,
      SnRealm realm,
      SnAccount account,
      int powerLevel});

  @override
  $SnRealmCopyWith<$Res> get realm;
  @override
  $SnAccountCopyWith<$Res> get account;
}

/// @nodoc
class __$$SnRealmMemberImplCopyWithImpl<$Res>
    extends _$SnRealmMemberCopyWithImpl<$Res, _$SnRealmMemberImpl>
    implements _$$SnRealmMemberImplCopyWith<$Res> {
  __$$SnRealmMemberImplCopyWithImpl(
      _$SnRealmMemberImpl _value, $Res Function(_$SnRealmMemberImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? realmId = null,
    Object? accountId = null,
    Object? realm = null,
    Object? account = null,
    Object? powerLevel = null,
  }) {
    return _then(_$SnRealmMemberImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      realmId: null == realmId
          ? _value.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      realm: null == realm
          ? _value.realm
          : realm // ignore: cast_nullable_to_non_nullable
              as SnRealm,
      account: null == account
          ? _value.account
          : account // ignore: cast_nullable_to_non_nullable
              as SnAccount,
      powerLevel: null == powerLevel
          ? _value.powerLevel
          : powerLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnRealmMemberImpl implements _SnRealmMember {
  const _$SnRealmMemberImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.realmId,
      required this.accountId,
      required this.realm,
      required this.account,
      required this.powerLevel});

  factory _$SnRealmMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnRealmMemberImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final int realmId;
  @override
  final int accountId;
  @override
  final SnRealm realm;
  @override
  final SnAccount account;
  @override
  final int powerLevel;

  @override
  String toString() {
    return 'SnRealmMember(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, realmId: $realmId, accountId: $accountId, realm: $realm, account: $account, powerLevel: $powerLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnRealmMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.realmId, realmId) || other.realmId == realmId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.realm, realm) || other.realm == realm) &&
            (identical(other.account, account) || other.account == account) &&
            (identical(other.powerLevel, powerLevel) ||
                other.powerLevel == powerLevel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt,
      deletedAt, realmId, accountId, realm, account, powerLevel);

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnRealmMemberImplCopyWith<_$SnRealmMemberImpl> get copyWith =>
      __$$SnRealmMemberImplCopyWithImpl<_$SnRealmMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnRealmMemberImplToJson(
      this,
    );
  }
}

abstract class _SnRealmMember implements SnRealmMember {
  const factory _SnRealmMember(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final int realmId,
      required final int accountId,
      required final SnRealm realm,
      required final SnAccount account,
      required final int powerLevel}) = _$SnRealmMemberImpl;

  factory _SnRealmMember.fromJson(Map<String, dynamic> json) =
      _$SnRealmMemberImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  int get realmId;
  @override
  int get accountId;
  @override
  SnRealm get realm;
  @override
  SnAccount get account;
  @override
  int get powerLevel;

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnRealmMemberImplCopyWith<_$SnRealmMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnRealm _$SnRealmFromJson(Map<String, dynamic> json) {
  return _SnRealm.fromJson(json);
}

/// @nodoc
mixin _$SnRealm {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  String get alias => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<SnRealmMember>? get members => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  String? get banner => throw _privateConstructorUsedError;
  Map<String, dynamic>? get accessPolicy => throw _privateConstructorUsedError;
  int get accountId => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  bool get isCommunity => throw _privateConstructorUsedError;
  int get popularity => throw _privateConstructorUsedError;

  /// Serializes this SnRealm to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnRealm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnRealmCopyWith<SnRealm> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnRealmCopyWith<$Res> {
  factory $SnRealmCopyWith(SnRealm value, $Res Function(SnRealm) then) =
      _$SnRealmCopyWithImpl<$Res, SnRealm>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String alias,
      String name,
      String description,
      List<SnRealmMember>? members,
      String? avatar,
      String? banner,
      Map<String, dynamic>? accessPolicy,
      int accountId,
      bool isPublic,
      bool isCommunity,
      int popularity});
}

/// @nodoc
class _$SnRealmCopyWithImpl<$Res, $Val extends SnRealm>
    implements $SnRealmCopyWith<$Res> {
  _$SnRealmCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnRealm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? alias = null,
    Object? name = null,
    Object? description = null,
    Object? members = freezed,
    Object? avatar = freezed,
    Object? banner = freezed,
    Object? accessPolicy = freezed,
    Object? accountId = null,
    Object? isPublic = null,
    Object? isCommunity = null,
    Object? popularity = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      alias: null == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      members: freezed == members
          ? _value.members
          : members // ignore: cast_nullable_to_non_nullable
              as List<SnRealmMember>?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      banner: freezed == banner
          ? _value.banner
          : banner // ignore: cast_nullable_to_non_nullable
              as String?,
      accessPolicy: freezed == accessPolicy
          ? _value.accessPolicy
          : accessPolicy // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommunity: null == isCommunity
          ? _value.isCommunity
          : isCommunity // ignore: cast_nullable_to_non_nullable
              as bool,
      popularity: null == popularity
          ? _value.popularity
          : popularity // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnRealmImplCopyWith<$Res> implements $SnRealmCopyWith<$Res> {
  factory _$$SnRealmImplCopyWith(
          _$SnRealmImpl value, $Res Function(_$SnRealmImpl) then) =
      __$$SnRealmImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String alias,
      String name,
      String description,
      List<SnRealmMember>? members,
      String? avatar,
      String? banner,
      Map<String, dynamic>? accessPolicy,
      int accountId,
      bool isPublic,
      bool isCommunity,
      int popularity});
}

/// @nodoc
class __$$SnRealmImplCopyWithImpl<$Res>
    extends _$SnRealmCopyWithImpl<$Res, _$SnRealmImpl>
    implements _$$SnRealmImplCopyWith<$Res> {
  __$$SnRealmImplCopyWithImpl(
      _$SnRealmImpl _value, $Res Function(_$SnRealmImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnRealm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? alias = null,
    Object? name = null,
    Object? description = null,
    Object? members = freezed,
    Object? avatar = freezed,
    Object? banner = freezed,
    Object? accessPolicy = freezed,
    Object? accountId = null,
    Object? isPublic = null,
    Object? isCommunity = null,
    Object? popularity = null,
  }) {
    return _then(_$SnRealmImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      alias: null == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      members: freezed == members
          ? _value._members
          : members // ignore: cast_nullable_to_non_nullable
              as List<SnRealmMember>?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      banner: freezed == banner
          ? _value.banner
          : banner // ignore: cast_nullable_to_non_nullable
              as String?,
      accessPolicy: freezed == accessPolicy
          ? _value._accessPolicy
          : accessPolicy // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommunity: null == isCommunity
          ? _value.isCommunity
          : isCommunity // ignore: cast_nullable_to_non_nullable
              as bool,
      popularity: null == popularity
          ? _value.popularity
          : popularity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnRealmImpl extends _SnRealm {
  const _$SnRealmImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.alias,
      required this.name,
      required this.description,
      final List<SnRealmMember>? members,
      required this.avatar,
      required this.banner,
      required final Map<String, dynamic>? accessPolicy,
      required this.accountId,
      required this.isPublic,
      required this.isCommunity,
      this.popularity = 0})
      : _members = members,
        _accessPolicy = accessPolicy,
        super._();

  factory _$SnRealmImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnRealmImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String alias;
  @override
  final String name;
  @override
  final String description;
  final List<SnRealmMember>? _members;
  @override
  List<SnRealmMember>? get members {
    final value = _members;
    if (value == null) return null;
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? avatar;
  @override
  final String? banner;
  final Map<String, dynamic>? _accessPolicy;
  @override
  Map<String, dynamic>? get accessPolicy {
    final value = _accessPolicy;
    if (value == null) return null;
    if (_accessPolicy is EqualUnmodifiableMapView) return _accessPolicy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final int accountId;
  @override
  final bool isPublic;
  @override
  final bool isCommunity;
  @override
  @JsonKey()
  final int popularity;

  @override
  String toString() {
    return 'SnRealm(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, members: $members, avatar: $avatar, banner: $banner, accessPolicy: $accessPolicy, accountId: $accountId, isPublic: $isPublic, isCommunity: $isCommunity, popularity: $popularity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnRealmImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._members, _members) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.banner, banner) || other.banner == banner) &&
            const DeepCollectionEquality()
                .equals(other._accessPolicy, _accessPolicy) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.isCommunity, isCommunity) ||
                other.isCommunity == isCommunity) &&
            (identical(other.popularity, popularity) ||
                other.popularity == popularity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      alias,
      name,
      description,
      const DeepCollectionEquality().hash(_members),
      avatar,
      banner,
      const DeepCollectionEquality().hash(_accessPolicy),
      accountId,
      isPublic,
      isCommunity,
      popularity);

  /// Create a copy of SnRealm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnRealmImplCopyWith<_$SnRealmImpl> get copyWith =>
      __$$SnRealmImplCopyWithImpl<_$SnRealmImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnRealmImplToJson(
      this,
    );
  }
}

abstract class _SnRealm extends SnRealm {
  const factory _SnRealm(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final String alias,
      required final String name,
      required final String description,
      final List<SnRealmMember>? members,
      required final String? avatar,
      required final String? banner,
      required final Map<String, dynamic>? accessPolicy,
      required final int accountId,
      required final bool isPublic,
      required final bool isCommunity,
      final int popularity}) = _$SnRealmImpl;
  const _SnRealm._() : super._();

  factory _SnRealm.fromJson(Map<String, dynamic> json) = _$SnRealmImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  String get alias;
  @override
  String get name;
  @override
  String get description;
  @override
  List<SnRealmMember>? get members;
  @override
  String? get avatar;
  @override
  String? get banner;
  @override
  Map<String, dynamic>? get accessPolicy;
  @override
  int get accountId;
  @override
  bool get isPublic;
  @override
  bool get isCommunity;
  @override
  int get popularity;

  /// Create a copy of SnRealm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnRealmImplCopyWith<_$SnRealmImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
