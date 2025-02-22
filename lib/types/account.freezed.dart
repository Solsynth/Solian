// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SnAccount _$SnAccountFromJson(Map<String, dynamic> json) {
  return _SnAccount.fromJson(json);
}

/// @nodoc
mixin _$SnAccount {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  DateTime? get confirmedAt => throw _privateConstructorUsedError;
  List<SnAccountContact>? get contacts => throw _privateConstructorUsedError;
  String get avatar => throw _privateConstructorUsedError;
  String get banner => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get nick => throw _privateConstructorUsedError;
  Map<String, dynamic> get permNodes => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  SnAccountProfile? get profile => throw _privateConstructorUsedError;
  List<SnAccountBadge> get badges => throw _privateConstructorUsedError;
  DateTime? get suspendedAt => throw _privateConstructorUsedError;
  int? get affiliatedId => throw _privateConstructorUsedError;
  int? get affiliatedTo => throw _privateConstructorUsedError;
  int? get automatedBy => throw _privateConstructorUsedError;
  int? get automatedId => throw _privateConstructorUsedError;

  /// Serializes this SnAccount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAccountCopyWith<SnAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAccountCopyWith<$Res> {
  factory $SnAccountCopyWith(SnAccount value, $Res Function(SnAccount) then) =
      _$SnAccountCopyWithImpl<$Res, SnAccount>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      DateTime? confirmedAt,
      List<SnAccountContact>? contacts,
      String avatar,
      String banner,
      String description,
      String name,
      String nick,
      Map<String, dynamic> permNodes,
      String language,
      SnAccountProfile? profile,
      List<SnAccountBadge> badges,
      DateTime? suspendedAt,
      int? affiliatedId,
      int? affiliatedTo,
      int? automatedBy,
      int? automatedId});

  $SnAccountProfileCopyWith<$Res>? get profile;
}

/// @nodoc
class _$SnAccountCopyWithImpl<$Res, $Val extends SnAccount>
    implements $SnAccountCopyWith<$Res> {
  _$SnAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? confirmedAt = freezed,
    Object? contacts = freezed,
    Object? avatar = null,
    Object? banner = null,
    Object? description = null,
    Object? name = null,
    Object? nick = null,
    Object? permNodes = null,
    Object? language = null,
    Object? profile = freezed,
    Object? badges = null,
    Object? suspendedAt = freezed,
    Object? affiliatedId = freezed,
    Object? affiliatedTo = freezed,
    Object? automatedBy = freezed,
    Object? automatedId = freezed,
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
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      contacts: freezed == contacts
          ? _value.contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<SnAccountContact>?,
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      banner: null == banner
          ? _value.banner
          : banner // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nick: null == nick
          ? _value.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String,
      permNodes: null == permNodes
          ? _value.permNodes
          : permNodes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as SnAccountProfile?,
      badges: null == badges
          ? _value.badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<SnAccountBadge>,
      suspendedAt: freezed == suspendedAt
          ? _value.suspendedAt
          : suspendedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      affiliatedId: freezed == affiliatedId
          ? _value.affiliatedId
          : affiliatedId // ignore: cast_nullable_to_non_nullable
              as int?,
      affiliatedTo: freezed == affiliatedTo
          ? _value.affiliatedTo
          : affiliatedTo // ignore: cast_nullable_to_non_nullable
              as int?,
      automatedBy: freezed == automatedBy
          ? _value.automatedBy
          : automatedBy // ignore: cast_nullable_to_non_nullable
              as int?,
      automatedId: freezed == automatedId
          ? _value.automatedId
          : automatedId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  /// Create a copy of SnAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAccountProfileCopyWith<$Res>? get profile {
    if (_value.profile == null) {
      return null;
    }

    return $SnAccountProfileCopyWith<$Res>(_value.profile!, (value) {
      return _then(_value.copyWith(profile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnAccountImplCopyWith<$Res>
    implements $SnAccountCopyWith<$Res> {
  factory _$$SnAccountImplCopyWith(
          _$SnAccountImpl value, $Res Function(_$SnAccountImpl) then) =
      __$$SnAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      DateTime? confirmedAt,
      List<SnAccountContact>? contacts,
      String avatar,
      String banner,
      String description,
      String name,
      String nick,
      Map<String, dynamic> permNodes,
      String language,
      SnAccountProfile? profile,
      List<SnAccountBadge> badges,
      DateTime? suspendedAt,
      int? affiliatedId,
      int? affiliatedTo,
      int? automatedBy,
      int? automatedId});

  @override
  $SnAccountProfileCopyWith<$Res>? get profile;
}

/// @nodoc
class __$$SnAccountImplCopyWithImpl<$Res>
    extends _$SnAccountCopyWithImpl<$Res, _$SnAccountImpl>
    implements _$$SnAccountImplCopyWith<$Res> {
  __$$SnAccountImplCopyWithImpl(
      _$SnAccountImpl _value, $Res Function(_$SnAccountImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? confirmedAt = freezed,
    Object? contacts = freezed,
    Object? avatar = null,
    Object? banner = null,
    Object? description = null,
    Object? name = null,
    Object? nick = null,
    Object? permNodes = null,
    Object? language = null,
    Object? profile = freezed,
    Object? badges = null,
    Object? suspendedAt = freezed,
    Object? affiliatedId = freezed,
    Object? affiliatedTo = freezed,
    Object? automatedBy = freezed,
    Object? automatedId = freezed,
  }) {
    return _then(_$SnAccountImpl(
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
      confirmedAt: freezed == confirmedAt
          ? _value.confirmedAt
          : confirmedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      contacts: freezed == contacts
          ? _value._contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<SnAccountContact>?,
      avatar: null == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String,
      banner: null == banner
          ? _value.banner
          : banner // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nick: null == nick
          ? _value.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String,
      permNodes: null == permNodes
          ? _value._permNodes
          : permNodes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as SnAccountProfile?,
      badges: null == badges
          ? _value._badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<SnAccountBadge>,
      suspendedAt: freezed == suspendedAt
          ? _value.suspendedAt
          : suspendedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      affiliatedId: freezed == affiliatedId
          ? _value.affiliatedId
          : affiliatedId // ignore: cast_nullable_to_non_nullable
              as int?,
      affiliatedTo: freezed == affiliatedTo
          ? _value.affiliatedTo
          : affiliatedTo // ignore: cast_nullable_to_non_nullable
              as int?,
      automatedBy: freezed == automatedBy
          ? _value.automatedBy
          : automatedBy // ignore: cast_nullable_to_non_nullable
              as int?,
      automatedId: freezed == automatedId
          ? _value.automatedId
          : automatedId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAccountImpl extends _SnAccount {
  const _$SnAccountImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.confirmedAt,
      required final List<SnAccountContact>? contacts,
      this.avatar = "",
      this.banner = "",
      required this.description,
      required this.name,
      required this.nick,
      final Map<String, dynamic> permNodes = const {},
      required this.language,
      required this.profile,
      final List<SnAccountBadge> badges = const [],
      required this.suspendedAt,
      required this.affiliatedId,
      required this.affiliatedTo,
      required this.automatedBy,
      required this.automatedId})
      : _contacts = contacts,
        _permNodes = permNodes,
        _badges = badges,
        super._();

  factory _$SnAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAccountImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final DateTime? confirmedAt;
  final List<SnAccountContact>? _contacts;
  @override
  List<SnAccountContact>? get contacts {
    final value = _contacts;
    if (value == null) return null;
    if (_contacts is EqualUnmodifiableListView) return _contacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final String avatar;
  @override
  @JsonKey()
  final String banner;
  @override
  final String description;
  @override
  final String name;
  @override
  final String nick;
  final Map<String, dynamic> _permNodes;
  @override
  @JsonKey()
  Map<String, dynamic> get permNodes {
    if (_permNodes is EqualUnmodifiableMapView) return _permNodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_permNodes);
  }

  @override
  final String language;
  @override
  final SnAccountProfile? profile;
  final List<SnAccountBadge> _badges;
  @override
  @JsonKey()
  List<SnAccountBadge> get badges {
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badges);
  }

  @override
  final DateTime? suspendedAt;
  @override
  final int? affiliatedId;
  @override
  final int? affiliatedTo;
  @override
  final int? automatedBy;
  @override
  final int? automatedId;

  @override
  String toString() {
    return 'SnAccount(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, confirmedAt: $confirmedAt, contacts: $contacts, avatar: $avatar, banner: $banner, description: $description, name: $name, nick: $nick, permNodes: $permNodes, language: $language, profile: $profile, badges: $badges, suspendedAt: $suspendedAt, affiliatedId: $affiliatedId, affiliatedTo: $affiliatedTo, automatedBy: $automatedBy, automatedId: $automatedId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt) &&
            const DeepCollectionEquality().equals(other._contacts, _contacts) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.banner, banner) || other.banner == banner) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nick, nick) || other.nick == nick) &&
            const DeepCollectionEquality()
                .equals(other._permNodes, _permNodes) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.profile, profile) || other.profile == profile) &&
            const DeepCollectionEquality().equals(other._badges, _badges) &&
            (identical(other.suspendedAt, suspendedAt) ||
                other.suspendedAt == suspendedAt) &&
            (identical(other.affiliatedId, affiliatedId) ||
                other.affiliatedId == affiliatedId) &&
            (identical(other.affiliatedTo, affiliatedTo) ||
                other.affiliatedTo == affiliatedTo) &&
            (identical(other.automatedBy, automatedBy) ||
                other.automatedBy == automatedBy) &&
            (identical(other.automatedId, automatedId) ||
                other.automatedId == automatedId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        createdAt,
        updatedAt,
        deletedAt,
        confirmedAt,
        const DeepCollectionEquality().hash(_contacts),
        avatar,
        banner,
        description,
        name,
        nick,
        const DeepCollectionEquality().hash(_permNodes),
        language,
        profile,
        const DeepCollectionEquality().hash(_badges),
        suspendedAt,
        affiliatedId,
        affiliatedTo,
        automatedBy,
        automatedId
      ]);

  /// Create a copy of SnAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAccountImplCopyWith<_$SnAccountImpl> get copyWith =>
      __$$SnAccountImplCopyWithImpl<_$SnAccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAccountImplToJson(
      this,
    );
  }
}

abstract class _SnAccount extends SnAccount {
  const factory _SnAccount(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final DateTime? confirmedAt,
      required final List<SnAccountContact>? contacts,
      final String avatar,
      final String banner,
      required final String description,
      required final String name,
      required final String nick,
      final Map<String, dynamic> permNodes,
      required final String language,
      required final SnAccountProfile? profile,
      final List<SnAccountBadge> badges,
      required final DateTime? suspendedAt,
      required final int? affiliatedId,
      required final int? affiliatedTo,
      required final int? automatedBy,
      required final int? automatedId}) = _$SnAccountImpl;
  const _SnAccount._() : super._();

  factory _SnAccount.fromJson(Map<String, dynamic> json) =
      _$SnAccountImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  DateTime? get confirmedAt;
  @override
  List<SnAccountContact>? get contacts;
  @override
  String get avatar;
  @override
  String get banner;
  @override
  String get description;
  @override
  String get name;
  @override
  String get nick;
  @override
  Map<String, dynamic> get permNodes;
  @override
  String get language;
  @override
  SnAccountProfile? get profile;
  @override
  List<SnAccountBadge> get badges;
  @override
  DateTime? get suspendedAt;
  @override
  int? get affiliatedId;
  @override
  int? get affiliatedTo;
  @override
  int? get automatedBy;
  @override
  int? get automatedId;

  /// Create a copy of SnAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAccountImplCopyWith<_$SnAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnAccountContact _$SnAccountContactFromJson(Map<String, dynamic> json) {
  return _SnAccountContact.fromJson(json);
}

/// @nodoc
mixin _$SnAccountContact {
  int get accountId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  int get id => throw _privateConstructorUsedError;
  bool get isPrimary => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  int get type => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get verifiedAt => throw _privateConstructorUsedError;

  /// Serializes this SnAccountContact to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAccountContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAccountContactCopyWith<SnAccountContact> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAccountContactCopyWith<$Res> {
  factory $SnAccountContactCopyWith(
          SnAccountContact value, $Res Function(SnAccountContact) then) =
      _$SnAccountContactCopyWithImpl<$Res, SnAccountContact>;
  @useResult
  $Res call(
      {int accountId,
      String content,
      DateTime createdAt,
      DateTime? deletedAt,
      int id,
      bool isPrimary,
      bool isPublic,
      int type,
      DateTime updatedAt,
      DateTime? verifiedAt});
}

/// @nodoc
class _$SnAccountContactCopyWithImpl<$Res, $Val extends SnAccountContact>
    implements $SnAccountContactCopyWith<$Res> {
  _$SnAccountContactCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAccountContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? deletedAt = freezed,
    Object? id = null,
    Object? isPrimary = null,
    Object? isPublic = null,
    Object? type = null,
    Object? updatedAt = null,
    Object? verifiedAt = freezed,
  }) {
    return _then(_value.copyWith(
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      verifiedAt: freezed == verifiedAt
          ? _value.verifiedAt
          : verifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnAccountContactImplCopyWith<$Res>
    implements $SnAccountContactCopyWith<$Res> {
  factory _$$SnAccountContactImplCopyWith(_$SnAccountContactImpl value,
          $Res Function(_$SnAccountContactImpl) then) =
      __$$SnAccountContactImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int accountId,
      String content,
      DateTime createdAt,
      DateTime? deletedAt,
      int id,
      bool isPrimary,
      bool isPublic,
      int type,
      DateTime updatedAt,
      DateTime? verifiedAt});
}

/// @nodoc
class __$$SnAccountContactImplCopyWithImpl<$Res>
    extends _$SnAccountContactCopyWithImpl<$Res, _$SnAccountContactImpl>
    implements _$$SnAccountContactImplCopyWith<$Res> {
  __$$SnAccountContactImplCopyWithImpl(_$SnAccountContactImpl _value,
      $Res Function(_$SnAccountContactImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnAccountContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? deletedAt = freezed,
    Object? id = null,
    Object? isPrimary = null,
    Object? isPublic = null,
    Object? type = null,
    Object? updatedAt = null,
    Object? verifiedAt = freezed,
  }) {
    return _then(_$SnAccountContactImpl(
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      isPrimary: null == isPrimary
          ? _value.isPrimary
          : isPrimary // ignore: cast_nullable_to_non_nullable
              as bool,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      verifiedAt: freezed == verifiedAt
          ? _value.verifiedAt
          : verifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAccountContactImpl implements _SnAccountContact {
  const _$SnAccountContactImpl(
      {required this.accountId,
      required this.content,
      required this.createdAt,
      required this.deletedAt,
      required this.id,
      required this.isPrimary,
      required this.isPublic,
      required this.type,
      required this.updatedAt,
      required this.verifiedAt});

  factory _$SnAccountContactImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAccountContactImplFromJson(json);

  @override
  final int accountId;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  final DateTime? deletedAt;
  @override
  final int id;
  @override
  final bool isPrimary;
  @override
  final bool isPublic;
  @override
  final int type;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? verifiedAt;

  @override
  String toString() {
    return 'SnAccountContact(accountId: $accountId, content: $content, createdAt: $createdAt, deletedAt: $deletedAt, id: $id, isPrimary: $isPrimary, isPublic: $isPublic, type: $type, updatedAt: $updatedAt, verifiedAt: $verifiedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAccountContactImpl &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.verifiedAt, verifiedAt) ||
                other.verifiedAt == verifiedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accountId, content, createdAt,
      deletedAt, id, isPrimary, isPublic, type, updatedAt, verifiedAt);

  /// Create a copy of SnAccountContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAccountContactImplCopyWith<_$SnAccountContactImpl> get copyWith =>
      __$$SnAccountContactImplCopyWithImpl<_$SnAccountContactImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAccountContactImplToJson(
      this,
    );
  }
}

abstract class _SnAccountContact implements SnAccountContact {
  const factory _SnAccountContact(
      {required final int accountId,
      required final String content,
      required final DateTime createdAt,
      required final DateTime? deletedAt,
      required final int id,
      required final bool isPrimary,
      required final bool isPublic,
      required final int type,
      required final DateTime updatedAt,
      required final DateTime? verifiedAt}) = _$SnAccountContactImpl;

  factory _SnAccountContact.fromJson(Map<String, dynamic> json) =
      _$SnAccountContactImpl.fromJson;

  @override
  int get accountId;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  DateTime? get deletedAt;
  @override
  int get id;
  @override
  bool get isPrimary;
  @override
  bool get isPublic;
  @override
  int get type;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get verifiedAt;

  /// Create a copy of SnAccountContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAccountContactImplCopyWith<_$SnAccountContactImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnAccountProfile _$SnAccountProfileFromJson(Map<String, dynamic> json) {
  return _SnAccountProfile.fromJson(json);
}

/// @nodoc
mixin _$SnAccountProfile {
  int get id => throw _privateConstructorUsedError;
  int get accountId => throw _privateConstructorUsedError;
  DateTime? get birthday => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  int get experience => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  DateTime? get lastSeenAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SnAccountProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAccountProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAccountProfileCopyWith<SnAccountProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAccountProfileCopyWith<$Res> {
  factory $SnAccountProfileCopyWith(
          SnAccountProfile value, $Res Function(SnAccountProfile) then) =
      _$SnAccountProfileCopyWithImpl<$Res, SnAccountProfile>;
  @useResult
  $Res call(
      {int id,
      int accountId,
      DateTime? birthday,
      DateTime createdAt,
      DateTime? deletedAt,
      int experience,
      String firstName,
      String lastName,
      DateTime? lastSeenAt,
      DateTime updatedAt});
}

/// @nodoc
class _$SnAccountProfileCopyWithImpl<$Res, $Val extends SnAccountProfile>
    implements $SnAccountProfileCopyWith<$Res> {
  _$SnAccountProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAccountProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? birthday = freezed,
    Object? createdAt = null,
    Object? deletedAt = freezed,
    Object? experience = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? lastSeenAt = freezed,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      birthday: freezed == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      experience: null == experience
          ? _value.experience
          : experience // ignore: cast_nullable_to_non_nullable
              as int,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      lastSeenAt: freezed == lastSeenAt
          ? _value.lastSeenAt
          : lastSeenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnAccountProfileImplCopyWith<$Res>
    implements $SnAccountProfileCopyWith<$Res> {
  factory _$$SnAccountProfileImplCopyWith(_$SnAccountProfileImpl value,
          $Res Function(_$SnAccountProfileImpl) then) =
      __$$SnAccountProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int accountId,
      DateTime? birthday,
      DateTime createdAt,
      DateTime? deletedAt,
      int experience,
      String firstName,
      String lastName,
      DateTime? lastSeenAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$SnAccountProfileImplCopyWithImpl<$Res>
    extends _$SnAccountProfileCopyWithImpl<$Res, _$SnAccountProfileImpl>
    implements _$$SnAccountProfileImplCopyWith<$Res> {
  __$$SnAccountProfileImplCopyWithImpl(_$SnAccountProfileImpl _value,
      $Res Function(_$SnAccountProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnAccountProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? birthday = freezed,
    Object? createdAt = null,
    Object? deletedAt = freezed,
    Object? experience = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? lastSeenAt = freezed,
    Object? updatedAt = null,
  }) {
    return _then(_$SnAccountProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      birthday: freezed == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      experience: null == experience
          ? _value.experience
          : experience // ignore: cast_nullable_to_non_nullable
              as int,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      lastSeenAt: freezed == lastSeenAt
          ? _value.lastSeenAt
          : lastSeenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAccountProfileImpl implements _SnAccountProfile {
  const _$SnAccountProfileImpl(
      {required this.id,
      required this.accountId,
      required this.birthday,
      required this.createdAt,
      required this.deletedAt,
      required this.experience,
      required this.firstName,
      required this.lastName,
      required this.lastSeenAt,
      required this.updatedAt});

  factory _$SnAccountProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAccountProfileImplFromJson(json);

  @override
  final int id;
  @override
  final int accountId;
  @override
  final DateTime? birthday;
  @override
  final DateTime createdAt;
  @override
  final DateTime? deletedAt;
  @override
  final int experience;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final DateTime? lastSeenAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SnAccountProfile(id: $id, accountId: $accountId, birthday: $birthday, createdAt: $createdAt, deletedAt: $deletedAt, experience: $experience, firstName: $firstName, lastName: $lastName, lastSeenAt: $lastSeenAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAccountProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.birthday, birthday) ||
                other.birthday == birthday) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.experience, experience) ||
                other.experience == experience) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.lastSeenAt, lastSeenAt) ||
                other.lastSeenAt == lastSeenAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      accountId,
      birthday,
      createdAt,
      deletedAt,
      experience,
      firstName,
      lastName,
      lastSeenAt,
      updatedAt);

  /// Create a copy of SnAccountProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAccountProfileImplCopyWith<_$SnAccountProfileImpl> get copyWith =>
      __$$SnAccountProfileImplCopyWithImpl<_$SnAccountProfileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAccountProfileImplToJson(
      this,
    );
  }
}

abstract class _SnAccountProfile implements SnAccountProfile {
  const factory _SnAccountProfile(
      {required final int id,
      required final int accountId,
      required final DateTime? birthday,
      required final DateTime createdAt,
      required final DateTime? deletedAt,
      required final int experience,
      required final String firstName,
      required final String lastName,
      required final DateTime? lastSeenAt,
      required final DateTime updatedAt}) = _$SnAccountProfileImpl;

  factory _SnAccountProfile.fromJson(Map<String, dynamic> json) =
      _$SnAccountProfileImpl.fromJson;

  @override
  int get id;
  @override
  int get accountId;
  @override
  DateTime? get birthday;
  @override
  DateTime get createdAt;
  @override
  DateTime? get deletedAt;
  @override
  int get experience;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  DateTime? get lastSeenAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SnAccountProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAccountProfileImplCopyWith<_$SnAccountProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnRelationship _$SnRelationshipFromJson(Map<String, dynamic> json) {
  return _SnRelationship.fromJson(json);
}

/// @nodoc
mixin _$SnRelationship {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  int get accountId => throw _privateConstructorUsedError;
  int get relatedId => throw _privateConstructorUsedError;
  SnAccount? get account => throw _privateConstructorUsedError;
  SnAccount? get related => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;
  Map<String, dynamic> get permNodes => throw _privateConstructorUsedError;

  /// Serializes this SnRelationship to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnRelationship
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnRelationshipCopyWith<SnRelationship> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnRelationshipCopyWith<$Res> {
  factory $SnRelationshipCopyWith(
          SnRelationship value, $Res Function(SnRelationship) then) =
      _$SnRelationshipCopyWithImpl<$Res, SnRelationship>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int accountId,
      int relatedId,
      SnAccount? account,
      SnAccount? related,
      int status,
      Map<String, dynamic> permNodes});

  $SnAccountCopyWith<$Res>? get account;
  $SnAccountCopyWith<$Res>? get related;
}

/// @nodoc
class _$SnRelationshipCopyWithImpl<$Res, $Val extends SnRelationship>
    implements $SnRelationshipCopyWith<$Res> {
  _$SnRelationshipCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnRelationship
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? accountId = null,
    Object? relatedId = null,
    Object? account = freezed,
    Object? related = freezed,
    Object? status = null,
    Object? permNodes = null,
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
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      relatedId: null == relatedId
          ? _value.relatedId
          : relatedId // ignore: cast_nullable_to_non_nullable
              as int,
      account: freezed == account
          ? _value.account
          : account // ignore: cast_nullable_to_non_nullable
              as SnAccount?,
      related: freezed == related
          ? _value.related
          : related // ignore: cast_nullable_to_non_nullable
              as SnAccount?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      permNodes: null == permNodes
          ? _value.permNodes
          : permNodes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }

  /// Create a copy of SnRelationship
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAccountCopyWith<$Res>? get account {
    if (_value.account == null) {
      return null;
    }

    return $SnAccountCopyWith<$Res>(_value.account!, (value) {
      return _then(_value.copyWith(account: value) as $Val);
    });
  }

  /// Create a copy of SnRelationship
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAccountCopyWith<$Res>? get related {
    if (_value.related == null) {
      return null;
    }

    return $SnAccountCopyWith<$Res>(_value.related!, (value) {
      return _then(_value.copyWith(related: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnRelationshipImplCopyWith<$Res>
    implements $SnRelationshipCopyWith<$Res> {
  factory _$$SnRelationshipImplCopyWith(_$SnRelationshipImpl value,
          $Res Function(_$SnRelationshipImpl) then) =
      __$$SnRelationshipImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int accountId,
      int relatedId,
      SnAccount? account,
      SnAccount? related,
      int status,
      Map<String, dynamic> permNodes});

  @override
  $SnAccountCopyWith<$Res>? get account;
  @override
  $SnAccountCopyWith<$Res>? get related;
}

/// @nodoc
class __$$SnRelationshipImplCopyWithImpl<$Res>
    extends _$SnRelationshipCopyWithImpl<$Res, _$SnRelationshipImpl>
    implements _$$SnRelationshipImplCopyWith<$Res> {
  __$$SnRelationshipImplCopyWithImpl(
      _$SnRelationshipImpl _value, $Res Function(_$SnRelationshipImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnRelationship
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? accountId = null,
    Object? relatedId = null,
    Object? account = freezed,
    Object? related = freezed,
    Object? status = null,
    Object? permNodes = null,
  }) {
    return _then(_$SnRelationshipImpl(
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
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      relatedId: null == relatedId
          ? _value.relatedId
          : relatedId // ignore: cast_nullable_to_non_nullable
              as int,
      account: freezed == account
          ? _value.account
          : account // ignore: cast_nullable_to_non_nullable
              as SnAccount?,
      related: freezed == related
          ? _value.related
          : related // ignore: cast_nullable_to_non_nullable
              as SnAccount?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      permNodes: null == permNodes
          ? _value._permNodes
          : permNodes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnRelationshipImpl implements _SnRelationship {
  const _$SnRelationshipImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.accountId,
      required this.relatedId,
      required this.account,
      required this.related,
      required this.status,
      final Map<String, dynamic> permNodes = const {}})
      : _permNodes = permNodes;

  factory _$SnRelationshipImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnRelationshipImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final int accountId;
  @override
  final int relatedId;
  @override
  final SnAccount? account;
  @override
  final SnAccount? related;
  @override
  final int status;
  final Map<String, dynamic> _permNodes;
  @override
  @JsonKey()
  Map<String, dynamic> get permNodes {
    if (_permNodes is EqualUnmodifiableMapView) return _permNodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_permNodes);
  }

  @override
  String toString() {
    return 'SnRelationship(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, accountId: $accountId, relatedId: $relatedId, account: $account, related: $related, status: $status, permNodes: $permNodes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnRelationshipImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.relatedId, relatedId) ||
                other.relatedId == relatedId) &&
            (identical(other.account, account) || other.account == account) &&
            (identical(other.related, related) || other.related == related) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._permNodes, _permNodes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      accountId,
      relatedId,
      account,
      related,
      status,
      const DeepCollectionEquality().hash(_permNodes));

  /// Create a copy of SnRelationship
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnRelationshipImplCopyWith<_$SnRelationshipImpl> get copyWith =>
      __$$SnRelationshipImplCopyWithImpl<_$SnRelationshipImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnRelationshipImplToJson(
      this,
    );
  }
}

abstract class _SnRelationship implements SnRelationship {
  const factory _SnRelationship(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final int accountId,
      required final int relatedId,
      required final SnAccount? account,
      required final SnAccount? related,
      required final int status,
      final Map<String, dynamic> permNodes}) = _$SnRelationshipImpl;

  factory _SnRelationship.fromJson(Map<String, dynamic> json) =
      _$SnRelationshipImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  int get accountId;
  @override
  int get relatedId;
  @override
  SnAccount? get account;
  @override
  SnAccount? get related;
  @override
  int get status;
  @override
  Map<String, dynamic> get permNodes;

  /// Create a copy of SnRelationship
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnRelationshipImplCopyWith<_$SnRelationshipImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnAccountBadge _$SnAccountBadgeFromJson(Map<String, dynamic> json) {
  return _SnAccountBadge.fromJson(json);
}

/// @nodoc
mixin _$SnAccountBadge {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  dynamic get deletedAt => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get accountId => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this SnAccountBadge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAccountBadge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAccountBadgeCopyWith<SnAccountBadge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAccountBadgeCopyWith<$Res> {
  factory $SnAccountBadgeCopyWith(
          SnAccountBadge value, $Res Function(SnAccountBadge) then) =
      _$SnAccountBadgeCopyWithImpl<$Res, SnAccountBadge>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      dynamic deletedAt,
      String type,
      int accountId,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$SnAccountBadgeCopyWithImpl<$Res, $Val extends SnAccountBadge>
    implements $SnAccountBadgeCopyWith<$Res> {
  _$SnAccountBadgeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAccountBadge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? type = null,
    Object? accountId = null,
    Object? metadata = null,
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
              as dynamic,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnAccountBadgeImplCopyWith<$Res>
    implements $SnAccountBadgeCopyWith<$Res> {
  factory _$$SnAccountBadgeImplCopyWith(_$SnAccountBadgeImpl value,
          $Res Function(_$SnAccountBadgeImpl) then) =
      __$$SnAccountBadgeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      dynamic deletedAt,
      String type,
      int accountId,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$SnAccountBadgeImplCopyWithImpl<$Res>
    extends _$SnAccountBadgeCopyWithImpl<$Res, _$SnAccountBadgeImpl>
    implements _$$SnAccountBadgeImplCopyWith<$Res> {
  __$$SnAccountBadgeImplCopyWithImpl(
      _$SnAccountBadgeImpl _value, $Res Function(_$SnAccountBadgeImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnAccountBadge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? type = null,
    Object? accountId = null,
    Object? metadata = null,
  }) {
    return _then(_$SnAccountBadgeImpl(
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
              as dynamic,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAccountBadgeImpl implements _SnAccountBadge {
  const _$SnAccountBadgeImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.type,
      required this.accountId,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$SnAccountBadgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAccountBadgeImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final dynamic deletedAt;
  @override
  final String type;
  @override
  final int accountId;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'SnAccountBadge(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, type: $type, accountId: $accountId, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAccountBadgeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other.deletedAt, deletedAt) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(deletedAt),
      type,
      accountId,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of SnAccountBadge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAccountBadgeImplCopyWith<_$SnAccountBadgeImpl> get copyWith =>
      __$$SnAccountBadgeImplCopyWithImpl<_$SnAccountBadgeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAccountBadgeImplToJson(
      this,
    );
  }
}

abstract class _SnAccountBadge implements SnAccountBadge {
  const factory _SnAccountBadge(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final dynamic deletedAt,
      required final String type,
      required final int accountId,
      final Map<String, dynamic> metadata}) = _$SnAccountBadgeImpl;

  factory _SnAccountBadge.fromJson(Map<String, dynamic> json) =
      _$SnAccountBadgeImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  dynamic get deletedAt;
  @override
  String get type;
  @override
  int get accountId;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of SnAccountBadge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAccountBadgeImplCopyWith<_$SnAccountBadgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnAccountStatusInfo _$SnAccountStatusInfoFromJson(Map<String, dynamic> json) {
  return _SnAccountStatusInfo.fromJson(json);
}

/// @nodoc
mixin _$SnAccountStatusInfo {
  bool get isDisturbable => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  DateTime? get lastSeenAt => throw _privateConstructorUsedError;
  dynamic get status => throw _privateConstructorUsedError;

  /// Serializes this SnAccountStatusInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAccountStatusInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAccountStatusInfoCopyWith<SnAccountStatusInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAccountStatusInfoCopyWith<$Res> {
  factory $SnAccountStatusInfoCopyWith(
          SnAccountStatusInfo value, $Res Function(SnAccountStatusInfo) then) =
      _$SnAccountStatusInfoCopyWithImpl<$Res, SnAccountStatusInfo>;
  @useResult
  $Res call(
      {bool isDisturbable,
      bool isOnline,
      DateTime? lastSeenAt,
      dynamic status});
}

/// @nodoc
class _$SnAccountStatusInfoCopyWithImpl<$Res, $Val extends SnAccountStatusInfo>
    implements $SnAccountStatusInfoCopyWith<$Res> {
  _$SnAccountStatusInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAccountStatusInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDisturbable = null,
    Object? isOnline = null,
    Object? lastSeenAt = freezed,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      isDisturbable: null == isDisturbable
          ? _value.isDisturbable
          : isDisturbable // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSeenAt: freezed == lastSeenAt
          ? _value.lastSeenAt
          : lastSeenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnAccountStatusInfoImplCopyWith<$Res>
    implements $SnAccountStatusInfoCopyWith<$Res> {
  factory _$$SnAccountStatusInfoImplCopyWith(_$SnAccountStatusInfoImpl value,
          $Res Function(_$SnAccountStatusInfoImpl) then) =
      __$$SnAccountStatusInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isDisturbable,
      bool isOnline,
      DateTime? lastSeenAt,
      dynamic status});
}

/// @nodoc
class __$$SnAccountStatusInfoImplCopyWithImpl<$Res>
    extends _$SnAccountStatusInfoCopyWithImpl<$Res, _$SnAccountStatusInfoImpl>
    implements _$$SnAccountStatusInfoImplCopyWith<$Res> {
  __$$SnAccountStatusInfoImplCopyWithImpl(_$SnAccountStatusInfoImpl _value,
      $Res Function(_$SnAccountStatusInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnAccountStatusInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDisturbable = null,
    Object? isOnline = null,
    Object? lastSeenAt = freezed,
    Object? status = freezed,
  }) {
    return _then(_$SnAccountStatusInfoImpl(
      isDisturbable: null == isDisturbable
          ? _value.isDisturbable
          : isDisturbable // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSeenAt: freezed == lastSeenAt
          ? _value.lastSeenAt
          : lastSeenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAccountStatusInfoImpl implements _SnAccountStatusInfo {
  const _$SnAccountStatusInfoImpl(
      {required this.isDisturbable,
      required this.isOnline,
      required this.lastSeenAt,
      required this.status});

  factory _$SnAccountStatusInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAccountStatusInfoImplFromJson(json);

  @override
  final bool isDisturbable;
  @override
  final bool isOnline;
  @override
  final DateTime? lastSeenAt;
  @override
  final dynamic status;

  @override
  String toString() {
    return 'SnAccountStatusInfo(isDisturbable: $isDisturbable, isOnline: $isOnline, lastSeenAt: $lastSeenAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAccountStatusInfoImpl &&
            (identical(other.isDisturbable, isDisturbable) ||
                other.isDisturbable == isDisturbable) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.lastSeenAt, lastSeenAt) ||
                other.lastSeenAt == lastSeenAt) &&
            const DeepCollectionEquality().equals(other.status, status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isDisturbable, isOnline,
      lastSeenAt, const DeepCollectionEquality().hash(status));

  /// Create a copy of SnAccountStatusInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAccountStatusInfoImplCopyWith<_$SnAccountStatusInfoImpl> get copyWith =>
      __$$SnAccountStatusInfoImplCopyWithImpl<_$SnAccountStatusInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAccountStatusInfoImplToJson(
      this,
    );
  }
}

abstract class _SnAccountStatusInfo implements SnAccountStatusInfo {
  const factory _SnAccountStatusInfo(
      {required final bool isDisturbable,
      required final bool isOnline,
      required final DateTime? lastSeenAt,
      required final dynamic status}) = _$SnAccountStatusInfoImpl;

  factory _SnAccountStatusInfo.fromJson(Map<String, dynamic> json) =
      _$SnAccountStatusInfoImpl.fromJson;

  @override
  bool get isDisturbable;
  @override
  bool get isOnline;
  @override
  DateTime? get lastSeenAt;
  @override
  dynamic get status;

  /// Create a copy of SnAccountStatusInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAccountStatusInfoImplCopyWith<_$SnAccountStatusInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnAbuseReport _$SnAbuseReportFromJson(Map<String, dynamic> json) {
  return _SnAbuseReport.fromJson(json);
}

/// @nodoc
mixin _$SnAbuseReport {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  String get resource => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get accountId => throw _privateConstructorUsedError;

  /// Serializes this SnAbuseReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAbuseReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAbuseReportCopyWith<SnAbuseReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAbuseReportCopyWith<$Res> {
  factory $SnAbuseReportCopyWith(
          SnAbuseReport value, $Res Function(SnAbuseReport) then) =
      _$SnAbuseReportCopyWithImpl<$Res, SnAbuseReport>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String resource,
      String reason,
      String status,
      int accountId});
}

/// @nodoc
class _$SnAbuseReportCopyWithImpl<$Res, $Val extends SnAbuseReport>
    implements $SnAbuseReportCopyWith<$Res> {
  _$SnAbuseReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAbuseReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? resource = null,
    Object? reason = null,
    Object? status = null,
    Object? accountId = null,
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
      resource: null == resource
          ? _value.resource
          : resource // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnAbuseReportImplCopyWith<$Res>
    implements $SnAbuseReportCopyWith<$Res> {
  factory _$$SnAbuseReportImplCopyWith(
          _$SnAbuseReportImpl value, $Res Function(_$SnAbuseReportImpl) then) =
      __$$SnAbuseReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String resource,
      String reason,
      String status,
      int accountId});
}

/// @nodoc
class __$$SnAbuseReportImplCopyWithImpl<$Res>
    extends _$SnAbuseReportCopyWithImpl<$Res, _$SnAbuseReportImpl>
    implements _$$SnAbuseReportImplCopyWith<$Res> {
  __$$SnAbuseReportImplCopyWithImpl(
      _$SnAbuseReportImpl _value, $Res Function(_$SnAbuseReportImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnAbuseReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? resource = null,
    Object? reason = null,
    Object? status = null,
    Object? accountId = null,
  }) {
    return _then(_$SnAbuseReportImpl(
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
      resource: null == resource
          ? _value.resource
          : resource // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAbuseReportImpl implements _SnAbuseReport {
  const _$SnAbuseReportImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.resource,
      required this.reason,
      required this.status,
      required this.accountId});

  factory _$SnAbuseReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAbuseReportImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String resource;
  @override
  final String reason;
  @override
  final String status;
  @override
  final int accountId;

  @override
  String toString() {
    return 'SnAbuseReport(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, resource: $resource, reason: $reason, status: $status, accountId: $accountId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAbuseReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.resource, resource) ||
                other.resource == resource) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt,
      deletedAt, resource, reason, status, accountId);

  /// Create a copy of SnAbuseReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAbuseReportImplCopyWith<_$SnAbuseReportImpl> get copyWith =>
      __$$SnAbuseReportImplCopyWithImpl<_$SnAbuseReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAbuseReportImplToJson(
      this,
    );
  }
}

abstract class _SnAbuseReport implements SnAbuseReport {
  const factory _SnAbuseReport(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final String resource,
      required final String reason,
      required final String status,
      required final int accountId}) = _$SnAbuseReportImpl;

  factory _SnAbuseReport.fromJson(Map<String, dynamic> json) =
      _$SnAbuseReportImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  String get resource;
  @override
  String get reason;
  @override
  String get status;
  @override
  int get accountId;

  /// Create a copy of SnAbuseReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAbuseReportImplCopyWith<_$SnAbuseReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
