// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SnChannel _$SnChannelFromJson(Map<String, dynamic> json) {
  return _SnChannel.fromJson(json);
}

/// @nodoc
mixin _$SnChannel {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  dynamic get deletedAt => throw _privateConstructorUsedError;
  String get alias => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<SnChannelMember>? get members => throw _privateConstructorUsedError;
  List<SnChatMessage>? get messages => throw _privateConstructorUsedError;
  int get type => throw _privateConstructorUsedError;
  int get accountId => throw _privateConstructorUsedError;
  SnRealm? get realm => throw _privateConstructorUsedError;
  int? get realmId => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  bool get isCommunity => throw _privateConstructorUsedError;

  /// Serializes this SnChannel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnChannel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnChannelCopyWith<SnChannel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnChannelCopyWith<$Res> {
  factory $SnChannelCopyWith(SnChannel value, $Res Function(SnChannel) then) =
      _$SnChannelCopyWithImpl<$Res, SnChannel>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      dynamic deletedAt,
      String alias,
      String name,
      String description,
      List<SnChannelMember>? members,
      List<SnChatMessage>? messages,
      int type,
      int accountId,
      SnRealm? realm,
      int? realmId,
      bool isPublic,
      bool isCommunity});

  $SnRealmCopyWith<$Res>? get realm;
}

/// @nodoc
class _$SnChannelCopyWithImpl<$Res, $Val extends SnChannel>
    implements $SnChannelCopyWith<$Res> {
  _$SnChannelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnChannel
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
    Object? messages = freezed,
    Object? type = null,
    Object? accountId = null,
    Object? realm = freezed,
    Object? realmId = freezed,
    Object? isPublic = null,
    Object? isCommunity = null,
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
              as List<SnChannelMember>?,
      messages: freezed == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<SnChatMessage>?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      realm: freezed == realm
          ? _value.realm
          : realm // ignore: cast_nullable_to_non_nullable
              as SnRealm?,
      realmId: freezed == realmId
          ? _value.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int?,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommunity: null == isCommunity
          ? _value.isCommunity
          : isCommunity // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of SnChannel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnRealmCopyWith<$Res>? get realm {
    if (_value.realm == null) {
      return null;
    }

    return $SnRealmCopyWith<$Res>(_value.realm!, (value) {
      return _then(_value.copyWith(realm: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnChannelImplCopyWith<$Res>
    implements $SnChannelCopyWith<$Res> {
  factory _$$SnChannelImplCopyWith(
          _$SnChannelImpl value, $Res Function(_$SnChannelImpl) then) =
      __$$SnChannelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      dynamic deletedAt,
      String alias,
      String name,
      String description,
      List<SnChannelMember>? members,
      List<SnChatMessage>? messages,
      int type,
      int accountId,
      SnRealm? realm,
      int? realmId,
      bool isPublic,
      bool isCommunity});

  @override
  $SnRealmCopyWith<$Res>? get realm;
}

/// @nodoc
class __$$SnChannelImplCopyWithImpl<$Res>
    extends _$SnChannelCopyWithImpl<$Res, _$SnChannelImpl>
    implements _$$SnChannelImplCopyWith<$Res> {
  __$$SnChannelImplCopyWithImpl(
      _$SnChannelImpl _value, $Res Function(_$SnChannelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnChannel
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
    Object? messages = freezed,
    Object? type = null,
    Object? accountId = null,
    Object? realm = freezed,
    Object? realmId = freezed,
    Object? isPublic = null,
    Object? isCommunity = null,
  }) {
    return _then(_$SnChannelImpl(
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
              as List<SnChannelMember>?,
      messages: freezed == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<SnChatMessage>?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      realm: freezed == realm
          ? _value.realm
          : realm // ignore: cast_nullable_to_non_nullable
              as SnRealm?,
      realmId: freezed == realmId
          ? _value.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int?,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommunity: null == isCommunity
          ? _value.isCommunity
          : isCommunity // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnChannelImpl extends _SnChannel {
  const _$SnChannelImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.alias,
      required this.name,
      required this.description,
      required final List<SnChannelMember>? members,
      final List<SnChatMessage>? messages,
      required this.type,
      required this.accountId,
      required this.realm,
      required this.realmId,
      required this.isPublic,
      required this.isCommunity})
      : _members = members,
        _messages = messages,
        super._();

  factory _$SnChannelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnChannelImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final dynamic deletedAt;
  @override
  final String alias;
  @override
  final String name;
  @override
  final String description;
  final List<SnChannelMember>? _members;
  @override
  List<SnChannelMember>? get members {
    final value = _members;
    if (value == null) return null;
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<SnChatMessage>? _messages;
  @override
  List<SnChatMessage>? get messages {
    final value = _messages;
    if (value == null) return null;
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int type;
  @override
  final int accountId;
  @override
  final SnRealm? realm;
  @override
  final int? realmId;
  @override
  final bool isPublic;
  @override
  final bool isCommunity;

  @override
  String toString() {
    return 'SnChannel(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, members: $members, messages: $messages, type: $type, accountId: $accountId, realm: $realm, realmId: $realmId, isPublic: $isPublic, isCommunity: $isCommunity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnChannelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other.deletedAt, deletedAt) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._members, _members) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.realm, realm) || other.realm == realm) &&
            (identical(other.realmId, realmId) || other.realmId == realmId) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.isCommunity, isCommunity) ||
                other.isCommunity == isCommunity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(deletedAt),
      alias,
      name,
      description,
      const DeepCollectionEquality().hash(_members),
      const DeepCollectionEquality().hash(_messages),
      type,
      accountId,
      realm,
      realmId,
      isPublic,
      isCommunity);

  /// Create a copy of SnChannel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnChannelImplCopyWith<_$SnChannelImpl> get copyWith =>
      __$$SnChannelImplCopyWithImpl<_$SnChannelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnChannelImplToJson(
      this,
    );
  }
}

abstract class _SnChannel extends SnChannel {
  const factory _SnChannel(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final dynamic deletedAt,
      required final String alias,
      required final String name,
      required final String description,
      required final List<SnChannelMember>? members,
      final List<SnChatMessage>? messages,
      required final int type,
      required final int accountId,
      required final SnRealm? realm,
      required final int? realmId,
      required final bool isPublic,
      required final bool isCommunity}) = _$SnChannelImpl;
  const _SnChannel._() : super._();

  factory _SnChannel.fromJson(Map<String, dynamic> json) =
      _$SnChannelImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  dynamic get deletedAt;
  @override
  String get alias;
  @override
  String get name;
  @override
  String get description;
  @override
  List<SnChannelMember>? get members;
  @override
  List<SnChatMessage>? get messages;
  @override
  int get type;
  @override
  int get accountId;
  @override
  SnRealm? get realm;
  @override
  int? get realmId;
  @override
  bool get isPublic;
  @override
  bool get isCommunity;

  /// Create a copy of SnChannel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnChannelImplCopyWith<_$SnChannelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnChannelMember _$SnChannelMemberFromJson(Map<String, dynamic> json) {
  return _SnChannelMember.fromJson(json);
}

/// @nodoc
mixin _$SnChannelMember {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  int get channelId => throw _privateConstructorUsedError;
  int get accountId => throw _privateConstructorUsedError;
  String? get nick => throw _privateConstructorUsedError;
  SnChannel? get channel => throw _privateConstructorUsedError;
  SnAccount? get account => throw _privateConstructorUsedError;
  int get notify => throw _privateConstructorUsedError;
  int get powerLevel => throw _privateConstructorUsedError;
  dynamic get calls => throw _privateConstructorUsedError;
  dynamic get events => throw _privateConstructorUsedError;

  /// Serializes this SnChannelMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnChannelMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnChannelMemberCopyWith<SnChannelMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnChannelMemberCopyWith<$Res> {
  factory $SnChannelMemberCopyWith(
          SnChannelMember value, $Res Function(SnChannelMember) then) =
      _$SnChannelMemberCopyWithImpl<$Res, SnChannelMember>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int channelId,
      int accountId,
      String? nick,
      SnChannel? channel,
      SnAccount? account,
      int notify,
      int powerLevel,
      dynamic calls,
      dynamic events});

  $SnChannelCopyWith<$Res>? get channel;
  $SnAccountCopyWith<$Res>? get account;
}

/// @nodoc
class _$SnChannelMemberCopyWithImpl<$Res, $Val extends SnChannelMember>
    implements $SnChannelMemberCopyWith<$Res> {
  _$SnChannelMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnChannelMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? channelId = null,
    Object? accountId = null,
    Object? nick = freezed,
    Object? channel = freezed,
    Object? account = freezed,
    Object? notify = null,
    Object? powerLevel = null,
    Object? calls = freezed,
    Object? events = freezed,
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
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      nick: freezed == nick
          ? _value.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String?,
      channel: freezed == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as SnChannel?,
      account: freezed == account
          ? _value.account
          : account // ignore: cast_nullable_to_non_nullable
              as SnAccount?,
      notify: null == notify
          ? _value.notify
          : notify // ignore: cast_nullable_to_non_nullable
              as int,
      powerLevel: null == powerLevel
          ? _value.powerLevel
          : powerLevel // ignore: cast_nullable_to_non_nullable
              as int,
      calls: freezed == calls
          ? _value.calls
          : calls // ignore: cast_nullable_to_non_nullable
              as dynamic,
      events: freezed == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }

  /// Create a copy of SnChannelMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChannelCopyWith<$Res>? get channel {
    if (_value.channel == null) {
      return null;
    }

    return $SnChannelCopyWith<$Res>(_value.channel!, (value) {
      return _then(_value.copyWith(channel: value) as $Val);
    });
  }

  /// Create a copy of SnChannelMember
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
}

/// @nodoc
abstract class _$$SnChannelMemberImplCopyWith<$Res>
    implements $SnChannelMemberCopyWith<$Res> {
  factory _$$SnChannelMemberImplCopyWith(_$SnChannelMemberImpl value,
          $Res Function(_$SnChannelMemberImpl) then) =
      __$$SnChannelMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int channelId,
      int accountId,
      String? nick,
      SnChannel? channel,
      SnAccount? account,
      int notify,
      int powerLevel,
      dynamic calls,
      dynamic events});

  @override
  $SnChannelCopyWith<$Res>? get channel;
  @override
  $SnAccountCopyWith<$Res>? get account;
}

/// @nodoc
class __$$SnChannelMemberImplCopyWithImpl<$Res>
    extends _$SnChannelMemberCopyWithImpl<$Res, _$SnChannelMemberImpl>
    implements _$$SnChannelMemberImplCopyWith<$Res> {
  __$$SnChannelMemberImplCopyWithImpl(
      _$SnChannelMemberImpl _value, $Res Function(_$SnChannelMemberImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnChannelMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? channelId = null,
    Object? accountId = null,
    Object? nick = freezed,
    Object? channel = freezed,
    Object? account = freezed,
    Object? notify = null,
    Object? powerLevel = null,
    Object? calls = freezed,
    Object? events = freezed,
  }) {
    return _then(_$SnChannelMemberImpl(
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
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      nick: freezed == nick
          ? _value.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String?,
      channel: freezed == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as SnChannel?,
      account: freezed == account
          ? _value.account
          : account // ignore: cast_nullable_to_non_nullable
              as SnAccount?,
      notify: null == notify
          ? _value.notify
          : notify // ignore: cast_nullable_to_non_nullable
              as int,
      powerLevel: null == powerLevel
          ? _value.powerLevel
          : powerLevel // ignore: cast_nullable_to_non_nullable
              as int,
      calls: freezed == calls
          ? _value.calls
          : calls // ignore: cast_nullable_to_non_nullable
              as dynamic,
      events: freezed == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnChannelMemberImpl extends _SnChannelMember {
  const _$SnChannelMemberImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.channelId,
      required this.accountId,
      required this.nick,
      required this.channel,
      required this.account,
      this.notify = 0,
      required this.powerLevel,
      this.calls,
      this.events})
      : super._();

  factory _$SnChannelMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnChannelMemberImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final int channelId;
  @override
  final int accountId;
  @override
  final String? nick;
  @override
  final SnChannel? channel;
  @override
  final SnAccount? account;
  @override
  @JsonKey()
  final int notify;
  @override
  final int powerLevel;
  @override
  final dynamic calls;
  @override
  final dynamic events;

  @override
  String toString() {
    return 'SnChannelMember(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, channelId: $channelId, accountId: $accountId, nick: $nick, channel: $channel, account: $account, notify: $notify, powerLevel: $powerLevel, calls: $calls, events: $events)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnChannelMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.nick, nick) || other.nick == nick) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.account, account) || other.account == account) &&
            (identical(other.notify, notify) || other.notify == notify) &&
            (identical(other.powerLevel, powerLevel) ||
                other.powerLevel == powerLevel) &&
            const DeepCollectionEquality().equals(other.calls, calls) &&
            const DeepCollectionEquality().equals(other.events, events));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      channelId,
      accountId,
      nick,
      channel,
      account,
      notify,
      powerLevel,
      const DeepCollectionEquality().hash(calls),
      const DeepCollectionEquality().hash(events));

  /// Create a copy of SnChannelMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnChannelMemberImplCopyWith<_$SnChannelMemberImpl> get copyWith =>
      __$$SnChannelMemberImplCopyWithImpl<_$SnChannelMemberImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnChannelMemberImplToJson(
      this,
    );
  }
}

abstract class _SnChannelMember extends SnChannelMember {
  const factory _SnChannelMember(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final int channelId,
      required final int accountId,
      required final String? nick,
      required final SnChannel? channel,
      required final SnAccount? account,
      final int notify,
      required final int powerLevel,
      final dynamic calls,
      final dynamic events}) = _$SnChannelMemberImpl;
  const _SnChannelMember._() : super._();

  factory _SnChannelMember.fromJson(Map<String, dynamic> json) =
      _$SnChannelMemberImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  int get channelId;
  @override
  int get accountId;
  @override
  String? get nick;
  @override
  SnChannel? get channel;
  @override
  SnAccount? get account;
  @override
  int get notify;
  @override
  int get powerLevel;
  @override
  dynamic get calls;
  @override
  dynamic get events;

  /// Create a copy of SnChannelMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnChannelMemberImplCopyWith<_$SnChannelMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnChatMessage _$SnChatMessageFromJson(Map<String, dynamic> json) {
  return _SnChatMessage.fromJson(json);
}

/// @nodoc
mixin _$SnChatMessage {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  String get uuid => throw _privateConstructorUsedError;
  Map<String, dynamic> get body => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  SnChannel get channel => throw _privateConstructorUsedError;
  SnChannelMember get sender => throw _privateConstructorUsedError;
  int get channelId => throw _privateConstructorUsedError;
  int get senderId => throw _privateConstructorUsedError;
  int? get quoteEventId => throw _privateConstructorUsedError;
  int? get relatedEventId => throw _privateConstructorUsedError;
  SnChatMessagePreload? get preload => throw _privateConstructorUsedError;

  /// Serializes this SnChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnChatMessageCopyWith<SnChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnChatMessageCopyWith<$Res> {
  factory $SnChatMessageCopyWith(
          SnChatMessage value, $Res Function(SnChatMessage) then) =
      _$SnChatMessageCopyWithImpl<$Res, SnChatMessage>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String uuid,
      Map<String, dynamic> body,
      String type,
      SnChannel channel,
      SnChannelMember sender,
      int channelId,
      int senderId,
      int? quoteEventId,
      int? relatedEventId,
      SnChatMessagePreload? preload});

  $SnChannelCopyWith<$Res> get channel;
  $SnChannelMemberCopyWith<$Res> get sender;
  $SnChatMessagePreloadCopyWith<$Res>? get preload;
}

/// @nodoc
class _$SnChatMessageCopyWithImpl<$Res, $Val extends SnChatMessage>
    implements $SnChatMessageCopyWith<$Res> {
  _$SnChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? uuid = null,
    Object? body = null,
    Object? type = null,
    Object? channel = null,
    Object? sender = null,
    Object? channelId = null,
    Object? senderId = null,
    Object? quoteEventId = freezed,
    Object? relatedEventId = freezed,
    Object? preload = freezed,
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
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as SnChannel,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as SnChannelMember,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as int,
      quoteEventId: freezed == quoteEventId
          ? _value.quoteEventId
          : quoteEventId // ignore: cast_nullable_to_non_nullable
              as int?,
      relatedEventId: freezed == relatedEventId
          ? _value.relatedEventId
          : relatedEventId // ignore: cast_nullable_to_non_nullable
              as int?,
      preload: freezed == preload
          ? _value.preload
          : preload // ignore: cast_nullable_to_non_nullable
              as SnChatMessagePreload?,
    ) as $Val);
  }

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChannelCopyWith<$Res> get channel {
    return $SnChannelCopyWith<$Res>(_value.channel, (value) {
      return _then(_value.copyWith(channel: value) as $Val);
    });
  }

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChannelMemberCopyWith<$Res> get sender {
    return $SnChannelMemberCopyWith<$Res>(_value.sender, (value) {
      return _then(_value.copyWith(sender: value) as $Val);
    });
  }

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChatMessagePreloadCopyWith<$Res>? get preload {
    if (_value.preload == null) {
      return null;
    }

    return $SnChatMessagePreloadCopyWith<$Res>(_value.preload!, (value) {
      return _then(_value.copyWith(preload: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnChatMessageImplCopyWith<$Res>
    implements $SnChatMessageCopyWith<$Res> {
  factory _$$SnChatMessageImplCopyWith(
          _$SnChatMessageImpl value, $Res Function(_$SnChatMessageImpl) then) =
      __$$SnChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String uuid,
      Map<String, dynamic> body,
      String type,
      SnChannel channel,
      SnChannelMember sender,
      int channelId,
      int senderId,
      int? quoteEventId,
      int? relatedEventId,
      SnChatMessagePreload? preload});

  @override
  $SnChannelCopyWith<$Res> get channel;
  @override
  $SnChannelMemberCopyWith<$Res> get sender;
  @override
  $SnChatMessagePreloadCopyWith<$Res>? get preload;
}

/// @nodoc
class __$$SnChatMessageImplCopyWithImpl<$Res>
    extends _$SnChatMessageCopyWithImpl<$Res, _$SnChatMessageImpl>
    implements _$$SnChatMessageImplCopyWith<$Res> {
  __$$SnChatMessageImplCopyWithImpl(
      _$SnChatMessageImpl _value, $Res Function(_$SnChatMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? uuid = null,
    Object? body = null,
    Object? type = null,
    Object? channel = null,
    Object? sender = null,
    Object? channelId = null,
    Object? senderId = null,
    Object? quoteEventId = freezed,
    Object? relatedEventId = freezed,
    Object? preload = freezed,
  }) {
    return _then(_$SnChatMessageImpl(
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
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value._body
          : body // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as SnChannel,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as SnChannelMember,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as int,
      quoteEventId: freezed == quoteEventId
          ? _value.quoteEventId
          : quoteEventId // ignore: cast_nullable_to_non_nullable
              as int?,
      relatedEventId: freezed == relatedEventId
          ? _value.relatedEventId
          : relatedEventId // ignore: cast_nullable_to_non_nullable
              as int?,
      preload: freezed == preload
          ? _value.preload
          : preload // ignore: cast_nullable_to_non_nullable
              as SnChatMessagePreload?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnChatMessageImpl extends _SnChatMessage {
  const _$SnChatMessageImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.uuid,
      final Map<String, dynamic> body = const {},
      required this.type,
      required this.channel,
      required this.sender,
      required this.channelId,
      required this.senderId,
      required this.quoteEventId,
      required this.relatedEventId,
      this.preload})
      : _body = body,
        super._();

  factory _$SnChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnChatMessageImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String uuid;
  final Map<String, dynamic> _body;
  @override
  @JsonKey()
  Map<String, dynamic> get body {
    if (_body is EqualUnmodifiableMapView) return _body;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_body);
  }

  @override
  final String type;
  @override
  final SnChannel channel;
  @override
  final SnChannelMember sender;
  @override
  final int channelId;
  @override
  final int senderId;
  @override
  final int? quoteEventId;
  @override
  final int? relatedEventId;
  @override
  final SnChatMessagePreload? preload;

  @override
  String toString() {
    return 'SnChatMessage(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, uuid: $uuid, body: $body, type: $type, channel: $channel, sender: $sender, channelId: $channelId, senderId: $senderId, quoteEventId: $quoteEventId, relatedEventId: $relatedEventId, preload: $preload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            const DeepCollectionEquality().equals(other._body, _body) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.quoteEventId, quoteEventId) ||
                other.quoteEventId == quoteEventId) &&
            (identical(other.relatedEventId, relatedEventId) ||
                other.relatedEventId == relatedEventId) &&
            (identical(other.preload, preload) || other.preload == preload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      uuid,
      const DeepCollectionEquality().hash(_body),
      type,
      channel,
      sender,
      channelId,
      senderId,
      quoteEventId,
      relatedEventId,
      preload);

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnChatMessageImplCopyWith<_$SnChatMessageImpl> get copyWith =>
      __$$SnChatMessageImplCopyWithImpl<_$SnChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnChatMessageImplToJson(
      this,
    );
  }
}

abstract class _SnChatMessage extends SnChatMessage {
  const factory _SnChatMessage(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final String uuid,
      final Map<String, dynamic> body,
      required final String type,
      required final SnChannel channel,
      required final SnChannelMember sender,
      required final int channelId,
      required final int senderId,
      required final int? quoteEventId,
      required final int? relatedEventId,
      final SnChatMessagePreload? preload}) = _$SnChatMessageImpl;
  const _SnChatMessage._() : super._();

  factory _SnChatMessage.fromJson(Map<String, dynamic> json) =
      _$SnChatMessageImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  String get uuid;
  @override
  Map<String, dynamic> get body;
  @override
  String get type;
  @override
  SnChannel get channel;
  @override
  SnChannelMember get sender;
  @override
  int get channelId;
  @override
  int get senderId;
  @override
  int? get quoteEventId;
  @override
  int? get relatedEventId;
  @override
  SnChatMessagePreload? get preload;

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnChatMessageImplCopyWith<_$SnChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnChatMessagePreload _$SnChatMessagePreloadFromJson(Map<String, dynamic> json) {
  return _SnChatMessagePreload.fromJson(json);
}

/// @nodoc
mixin _$SnChatMessagePreload {
  List<SnAttachment?>? get attachments => throw _privateConstructorUsedError;
  SnChatMessage? get quoteEvent => throw _privateConstructorUsedError;

  /// Serializes this SnChatMessagePreload to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnChatMessagePreload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnChatMessagePreloadCopyWith<SnChatMessagePreload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnChatMessagePreloadCopyWith<$Res> {
  factory $SnChatMessagePreloadCopyWith(SnChatMessagePreload value,
          $Res Function(SnChatMessagePreload) then) =
      _$SnChatMessagePreloadCopyWithImpl<$Res, SnChatMessagePreload>;
  @useResult
  $Res call({List<SnAttachment?>? attachments, SnChatMessage? quoteEvent});

  $SnChatMessageCopyWith<$Res>? get quoteEvent;
}

/// @nodoc
class _$SnChatMessagePreloadCopyWithImpl<$Res,
        $Val extends SnChatMessagePreload>
    implements $SnChatMessagePreloadCopyWith<$Res> {
  _$SnChatMessagePreloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnChatMessagePreload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachments = freezed,
    Object? quoteEvent = freezed,
  }) {
    return _then(_value.copyWith(
      attachments: freezed == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<SnAttachment?>?,
      quoteEvent: freezed == quoteEvent
          ? _value.quoteEvent
          : quoteEvent // ignore: cast_nullable_to_non_nullable
              as SnChatMessage?,
    ) as $Val);
  }

  /// Create a copy of SnChatMessagePreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChatMessageCopyWith<$Res>? get quoteEvent {
    if (_value.quoteEvent == null) {
      return null;
    }

    return $SnChatMessageCopyWith<$Res>(_value.quoteEvent!, (value) {
      return _then(_value.copyWith(quoteEvent: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnChatMessagePreloadImplCopyWith<$Res>
    implements $SnChatMessagePreloadCopyWith<$Res> {
  factory _$$SnChatMessagePreloadImplCopyWith(_$SnChatMessagePreloadImpl value,
          $Res Function(_$SnChatMessagePreloadImpl) then) =
      __$$SnChatMessagePreloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<SnAttachment?>? attachments, SnChatMessage? quoteEvent});

  @override
  $SnChatMessageCopyWith<$Res>? get quoteEvent;
}

/// @nodoc
class __$$SnChatMessagePreloadImplCopyWithImpl<$Res>
    extends _$SnChatMessagePreloadCopyWithImpl<$Res, _$SnChatMessagePreloadImpl>
    implements _$$SnChatMessagePreloadImplCopyWith<$Res> {
  __$$SnChatMessagePreloadImplCopyWithImpl(_$SnChatMessagePreloadImpl _value,
      $Res Function(_$SnChatMessagePreloadImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnChatMessagePreload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachments = freezed,
    Object? quoteEvent = freezed,
  }) {
    return _then(_$SnChatMessagePreloadImpl(
      attachments: freezed == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<SnAttachment?>?,
      quoteEvent: freezed == quoteEvent
          ? _value.quoteEvent
          : quoteEvent // ignore: cast_nullable_to_non_nullable
              as SnChatMessage?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnChatMessagePreloadImpl extends _SnChatMessagePreload {
  const _$SnChatMessagePreloadImpl(
      {final List<SnAttachment?>? attachments, this.quoteEvent})
      : _attachments = attachments,
        super._();

  factory _$SnChatMessagePreloadImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnChatMessagePreloadImplFromJson(json);

  final List<SnAttachment?>? _attachments;
  @override
  List<SnAttachment?>? get attachments {
    final value = _attachments;
    if (value == null) return null;
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final SnChatMessage? quoteEvent;

  @override
  String toString() {
    return 'SnChatMessagePreload(attachments: $attachments, quoteEvent: $quoteEvent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnChatMessagePreloadImpl &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.quoteEvent, quoteEvent) ||
                other.quoteEvent == quoteEvent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_attachments), quoteEvent);

  /// Create a copy of SnChatMessagePreload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnChatMessagePreloadImplCopyWith<_$SnChatMessagePreloadImpl>
      get copyWith =>
          __$$SnChatMessagePreloadImplCopyWithImpl<_$SnChatMessagePreloadImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnChatMessagePreloadImplToJson(
      this,
    );
  }
}

abstract class _SnChatMessagePreload extends SnChatMessagePreload {
  const factory _SnChatMessagePreload(
      {final List<SnAttachment?>? attachments,
      final SnChatMessage? quoteEvent}) = _$SnChatMessagePreloadImpl;
  const _SnChatMessagePreload._() : super._();

  factory _SnChatMessagePreload.fromJson(Map<String, dynamic> json) =
      _$SnChatMessagePreloadImpl.fromJson;

  @override
  List<SnAttachment?>? get attachments;
  @override
  SnChatMessage? get quoteEvent;

  /// Create a copy of SnChatMessagePreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnChatMessagePreloadImplCopyWith<_$SnChatMessagePreloadImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SnChatCall _$SnChatCallFromJson(Map<String, dynamic> json) {
  return _SnChatCall.fromJson(json);
}

/// @nodoc
mixin _$SnChatCall {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  String get externalId => throw _privateConstructorUsedError;
  int get founderId => throw _privateConstructorUsedError;
  int get channelId => throw _privateConstructorUsedError;
  SnChannelMember get founder => throw _privateConstructorUsedError;
  List<dynamic> get participants => throw _privateConstructorUsedError;

  /// Serializes this SnChatCall to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnChatCall
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnChatCallCopyWith<SnChatCall> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnChatCallCopyWith<$Res> {
  factory $SnChatCallCopyWith(
          SnChatCall value, $Res Function(SnChatCall) then) =
      _$SnChatCallCopyWithImpl<$Res, SnChatCall>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      DateTime? endedAt,
      String externalId,
      int founderId,
      int channelId,
      SnChannelMember founder,
      List<dynamic> participants});

  $SnChannelMemberCopyWith<$Res> get founder;
}

/// @nodoc
class _$SnChatCallCopyWithImpl<$Res, $Val extends SnChatCall>
    implements $SnChatCallCopyWith<$Res> {
  _$SnChatCallCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnChatCall
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? endedAt = freezed,
    Object? externalId = null,
    Object? founderId = null,
    Object? channelId = null,
    Object? founder = null,
    Object? participants = null,
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
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      externalId: null == externalId
          ? _value.externalId
          : externalId // ignore: cast_nullable_to_non_nullable
              as String,
      founderId: null == founderId
          ? _value.founderId
          : founderId // ignore: cast_nullable_to_non_nullable
              as int,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int,
      founder: null == founder
          ? _value.founder
          : founder // ignore: cast_nullable_to_non_nullable
              as SnChannelMember,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ) as $Val);
  }

  /// Create a copy of SnChatCall
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChannelMemberCopyWith<$Res> get founder {
    return $SnChannelMemberCopyWith<$Res>(_value.founder, (value) {
      return _then(_value.copyWith(founder: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnChatCallImplCopyWith<$Res>
    implements $SnChatCallCopyWith<$Res> {
  factory _$$SnChatCallImplCopyWith(
          _$SnChatCallImpl value, $Res Function(_$SnChatCallImpl) then) =
      __$$SnChatCallImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      DateTime? endedAt,
      String externalId,
      int founderId,
      int channelId,
      SnChannelMember founder,
      List<dynamic> participants});

  @override
  $SnChannelMemberCopyWith<$Res> get founder;
}

/// @nodoc
class __$$SnChatCallImplCopyWithImpl<$Res>
    extends _$SnChatCallCopyWithImpl<$Res, _$SnChatCallImpl>
    implements _$$SnChatCallImplCopyWith<$Res> {
  __$$SnChatCallImplCopyWithImpl(
      _$SnChatCallImpl _value, $Res Function(_$SnChatCallImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnChatCall
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? endedAt = freezed,
    Object? externalId = null,
    Object? founderId = null,
    Object? channelId = null,
    Object? founder = null,
    Object? participants = null,
  }) {
    return _then(_$SnChatCallImpl(
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
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      externalId: null == externalId
          ? _value.externalId
          : externalId // ignore: cast_nullable_to_non_nullable
              as String,
      founderId: null == founderId
          ? _value.founderId
          : founderId // ignore: cast_nullable_to_non_nullable
              as int,
      channelId: null == channelId
          ? _value.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int,
      founder: null == founder
          ? _value.founder
          : founder // ignore: cast_nullable_to_non_nullable
              as SnChannelMember,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnChatCallImpl implements _SnChatCall {
  const _$SnChatCallImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.endedAt,
      required this.externalId,
      required this.founderId,
      required this.channelId,
      required this.founder,
      final List<dynamic> participants = const []})
      : _participants = participants;

  factory _$SnChatCallImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnChatCallImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final DateTime? endedAt;
  @override
  final String externalId;
  @override
  final int founderId;
  @override
  final int channelId;
  @override
  final SnChannelMember founder;
  final List<dynamic> _participants;
  @override
  @JsonKey()
  List<dynamic> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  String toString() {
    return 'SnChatCall(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, endedAt: $endedAt, externalId: $externalId, founderId: $founderId, channelId: $channelId, founder: $founder, participants: $participants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnChatCallImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.externalId, externalId) ||
                other.externalId == externalId) &&
            (identical(other.founderId, founderId) ||
                other.founderId == founderId) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.founder, founder) || other.founder == founder) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      endedAt,
      externalId,
      founderId,
      channelId,
      founder,
      const DeepCollectionEquality().hash(_participants));

  /// Create a copy of SnChatCall
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnChatCallImplCopyWith<_$SnChatCallImpl> get copyWith =>
      __$$SnChatCallImplCopyWithImpl<_$SnChatCallImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnChatCallImplToJson(
      this,
    );
  }
}

abstract class _SnChatCall implements SnChatCall {
  const factory _SnChatCall(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final DateTime? endedAt,
      required final String externalId,
      required final int founderId,
      required final int channelId,
      required final SnChannelMember founder,
      final List<dynamic> participants}) = _$SnChatCallImpl;

  factory _SnChatCall.fromJson(Map<String, dynamic> json) =
      _$SnChatCallImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  DateTime? get endedAt;
  @override
  String get externalId;
  @override
  int get founderId;
  @override
  int get channelId;
  @override
  SnChannelMember get founder;
  @override
  List<dynamic> get participants;

  /// Create a copy of SnChatCall
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnChatCallImplCopyWith<_$SnChatCallImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
