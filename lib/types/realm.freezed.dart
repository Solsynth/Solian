// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'realm.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnRealmMember {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  int get realmId;
  int get accountId;
  SnRealm get realm;
  SnAccount get account;
  int get powerLevel;

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnRealmMemberCopyWith<SnRealmMember> get copyWith =>
      _$SnRealmMemberCopyWithImpl<SnRealmMember>(
          this as SnRealmMember, _$identity);

  /// Serializes this SnRealmMember to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnRealmMember &&
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

  @override
  String toString() {
    return 'SnRealmMember(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, realmId: $realmId, accountId: $accountId, realm: $realm, account: $account, powerLevel: $powerLevel)';
  }
}

/// @nodoc
abstract mixin class $SnRealmMemberCopyWith<$Res> {
  factory $SnRealmMemberCopyWith(
          SnRealmMember value, $Res Function(SnRealmMember) _then) =
      _$SnRealmMemberCopyWithImpl;
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
class _$SnRealmMemberCopyWithImpl<$Res>
    implements $SnRealmMemberCopyWith<$Res> {
  _$SnRealmMemberCopyWithImpl(this._self, this._then);

  final SnRealmMember _self;
  final $Res Function(SnRealmMember) _then;

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
      realmId: null == realmId
          ? _self.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      realm: null == realm
          ? _self.realm
          : realm // ignore: cast_nullable_to_non_nullable
              as SnRealm,
      account: null == account
          ? _self.account
          : account // ignore: cast_nullable_to_non_nullable
              as SnAccount,
      powerLevel: null == powerLevel
          ? _self.powerLevel
          : powerLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnRealmCopyWith<$Res> get realm {
    return $SnRealmCopyWith<$Res>(_self.realm, (value) {
      return _then(_self.copyWith(realm: value));
    });
  }

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAccountCopyWith<$Res> get account {
    return $SnAccountCopyWith<$Res>(_self.account, (value) {
      return _then(_self.copyWith(account: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SnRealmMember implements SnRealmMember {
  const _SnRealmMember(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.realmId,
      required this.accountId,
      required this.realm,
      required this.account,
      required this.powerLevel});
  factory _SnRealmMember.fromJson(Map<String, dynamic> json) =>
      _$SnRealmMemberFromJson(json);

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

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnRealmMemberCopyWith<_SnRealmMember> get copyWith =>
      __$SnRealmMemberCopyWithImpl<_SnRealmMember>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnRealmMemberToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnRealmMember &&
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

  @override
  String toString() {
    return 'SnRealmMember(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, realmId: $realmId, accountId: $accountId, realm: $realm, account: $account, powerLevel: $powerLevel)';
  }
}

/// @nodoc
abstract mixin class _$SnRealmMemberCopyWith<$Res>
    implements $SnRealmMemberCopyWith<$Res> {
  factory _$SnRealmMemberCopyWith(
          _SnRealmMember value, $Res Function(_SnRealmMember) _then) =
      __$SnRealmMemberCopyWithImpl;
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
class __$SnRealmMemberCopyWithImpl<$Res>
    implements _$SnRealmMemberCopyWith<$Res> {
  __$SnRealmMemberCopyWithImpl(this._self, this._then);

  final _SnRealmMember _self;
  final $Res Function(_SnRealmMember) _then;

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_SnRealmMember(
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
      realmId: null == realmId
          ? _self.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      realm: null == realm
          ? _self.realm
          : realm // ignore: cast_nullable_to_non_nullable
              as SnRealm,
      account: null == account
          ? _self.account
          : account // ignore: cast_nullable_to_non_nullable
              as SnAccount,
      powerLevel: null == powerLevel
          ? _self.powerLevel
          : powerLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnRealmCopyWith<$Res> get realm {
    return $SnRealmCopyWith<$Res>(_self.realm, (value) {
      return _then(_self.copyWith(realm: value));
    });
  }

  /// Create a copy of SnRealmMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAccountCopyWith<$Res> get account {
    return $SnAccountCopyWith<$Res>(_self.account, (value) {
      return _then(_self.copyWith(account: value));
    });
  }
}

/// @nodoc
mixin _$SnRealm {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get alias;
  String get name;
  String get description;
  List<SnRealmMember>? get members;
  String? get avatar;
  String? get banner;
  Map<String, dynamic>? get accessPolicy;
  int get accountId;
  bool get isPublic;
  bool get isCommunity;
  int get popularity;

  /// Create a copy of SnRealm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnRealmCopyWith<SnRealm> get copyWith =>
      _$SnRealmCopyWithImpl<SnRealm>(this as SnRealm, _$identity);

  /// Serializes this SnRealm to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnRealm &&
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
            const DeepCollectionEquality().equals(other.members, members) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.banner, banner) || other.banner == banner) &&
            const DeepCollectionEquality()
                .equals(other.accessPolicy, accessPolicy) &&
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
      const DeepCollectionEquality().hash(members),
      avatar,
      banner,
      const DeepCollectionEquality().hash(accessPolicy),
      accountId,
      isPublic,
      isCommunity,
      popularity);

  @override
  String toString() {
    return 'SnRealm(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, members: $members, avatar: $avatar, banner: $banner, accessPolicy: $accessPolicy, accountId: $accountId, isPublic: $isPublic, isCommunity: $isCommunity, popularity: $popularity)';
  }
}

/// @nodoc
abstract mixin class $SnRealmCopyWith<$Res> {
  factory $SnRealmCopyWith(SnRealm value, $Res Function(SnRealm) _then) =
      _$SnRealmCopyWithImpl;
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
class _$SnRealmCopyWithImpl<$Res> implements $SnRealmCopyWith<$Res> {
  _$SnRealmCopyWithImpl(this._self, this._then);

  final SnRealm _self;
  final $Res Function(SnRealm) _then;

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
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      members: freezed == members
          ? _self.members
          : members // ignore: cast_nullable_to_non_nullable
              as List<SnRealmMember>?,
      avatar: freezed == avatar
          ? _self.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      banner: freezed == banner
          ? _self.banner
          : banner // ignore: cast_nullable_to_non_nullable
              as String?,
      accessPolicy: freezed == accessPolicy
          ? _self.accessPolicy
          : accessPolicy // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      isPublic: null == isPublic
          ? _self.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommunity: null == isCommunity
          ? _self.isCommunity
          : isCommunity // ignore: cast_nullable_to_non_nullable
              as bool,
      popularity: null == popularity
          ? _self.popularity
          : popularity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnRealm extends SnRealm {
  const _SnRealm(
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
  factory _SnRealm.fromJson(Map<String, dynamic> json) =>
      _$SnRealmFromJson(json);

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

  /// Create a copy of SnRealm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnRealmCopyWith<_SnRealm> get copyWith =>
      __$SnRealmCopyWithImpl<_SnRealm>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnRealmToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnRealm &&
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

  @override
  String toString() {
    return 'SnRealm(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, members: $members, avatar: $avatar, banner: $banner, accessPolicy: $accessPolicy, accountId: $accountId, isPublic: $isPublic, isCommunity: $isCommunity, popularity: $popularity)';
  }
}

/// @nodoc
abstract mixin class _$SnRealmCopyWith<$Res> implements $SnRealmCopyWith<$Res> {
  factory _$SnRealmCopyWith(_SnRealm value, $Res Function(_SnRealm) _then) =
      __$SnRealmCopyWithImpl;
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
class __$SnRealmCopyWithImpl<$Res> implements _$SnRealmCopyWith<$Res> {
  __$SnRealmCopyWithImpl(this._self, this._then);

  final _SnRealm _self;
  final $Res Function(_SnRealm) _then;

  /// Create a copy of SnRealm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_SnRealm(
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
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      members: freezed == members
          ? _self._members
          : members // ignore: cast_nullable_to_non_nullable
              as List<SnRealmMember>?,
      avatar: freezed == avatar
          ? _self.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      banner: freezed == banner
          ? _self.banner
          : banner // ignore: cast_nullable_to_non_nullable
              as String?,
      accessPolicy: freezed == accessPolicy
          ? _self._accessPolicy
          : accessPolicy // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      isPublic: null == isPublic
          ? _self.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommunity: null == isCommunity
          ? _self.isCommunity
          : isCommunity // ignore: cast_nullable_to_non_nullable
              as bool,
      popularity: null == popularity
          ? _self.popularity
          : popularity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
