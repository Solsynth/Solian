// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnChannel {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  dynamic get deletedAt;
  String get alias;
  String get name;
  String get description;
  List<SnChannelMember>? get members;
  List<SnChatMessage>? get messages;
  int get type;
  int get accountId;
  SnRealm? get realm;
  int? get realmId;
  bool get isPublic;
  bool get isCommunity;

  /// Create a copy of SnChannel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnChannelCopyWith<SnChannel> get copyWith =>
      _$SnChannelCopyWithImpl<SnChannel>(this as SnChannel, _$identity);

  /// Serializes this SnChannel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnChannel &&
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
            const DeepCollectionEquality().equals(other.members, members) &&
            const DeepCollectionEquality().equals(other.messages, messages) &&
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
      const DeepCollectionEquality().hash(members),
      const DeepCollectionEquality().hash(messages),
      type,
      accountId,
      realm,
      realmId,
      isPublic,
      isCommunity);

  @override
  String toString() {
    return 'SnChannel(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, members: $members, messages: $messages, type: $type, accountId: $accountId, realm: $realm, realmId: $realmId, isPublic: $isPublic, isCommunity: $isCommunity)';
  }
}

/// @nodoc
abstract mixin class $SnChannelCopyWith<$Res> {
  factory $SnChannelCopyWith(SnChannel value, $Res Function(SnChannel) _then) =
      _$SnChannelCopyWithImpl;
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
class _$SnChannelCopyWithImpl<$Res> implements $SnChannelCopyWith<$Res> {
  _$SnChannelCopyWithImpl(this._self, this._then);

  final SnChannel _self;
  final $Res Function(SnChannel) _then;

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
              as dynamic,
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
              as List<SnChannelMember>?,
      messages: freezed == messages
          ? _self.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<SnChatMessage>?,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      realm: freezed == realm
          ? _self.realm
          : realm // ignore: cast_nullable_to_non_nullable
              as SnRealm?,
      realmId: freezed == realmId
          ? _self.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int?,
      isPublic: null == isPublic
          ? _self.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommunity: null == isCommunity
          ? _self.isCommunity
          : isCommunity // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of SnChannel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnRealmCopyWith<$Res>? get realm {
    if (_self.realm == null) {
      return null;
    }

    return $SnRealmCopyWith<$Res>(_self.realm!, (value) {
      return _then(_self.copyWith(realm: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SnChannel extends SnChannel {
  const _SnChannel(
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
  factory _SnChannel.fromJson(Map<String, dynamic> json) =>
      _$SnChannelFromJson(json);

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

  /// Create a copy of SnChannel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnChannelCopyWith<_SnChannel> get copyWith =>
      __$SnChannelCopyWithImpl<_SnChannel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnChannelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnChannel &&
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

  @override
  String toString() {
    return 'SnChannel(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, members: $members, messages: $messages, type: $type, accountId: $accountId, realm: $realm, realmId: $realmId, isPublic: $isPublic, isCommunity: $isCommunity)';
  }
}

/// @nodoc
abstract mixin class _$SnChannelCopyWith<$Res>
    implements $SnChannelCopyWith<$Res> {
  factory _$SnChannelCopyWith(
          _SnChannel value, $Res Function(_SnChannel) _then) =
      __$SnChannelCopyWithImpl;
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
class __$SnChannelCopyWithImpl<$Res> implements _$SnChannelCopyWith<$Res> {
  __$SnChannelCopyWithImpl(this._self, this._then);

  final _SnChannel _self;
  final $Res Function(_SnChannel) _then;

  /// Create a copy of SnChannel
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
    Object? messages = freezed,
    Object? type = null,
    Object? accountId = null,
    Object? realm = freezed,
    Object? realmId = freezed,
    Object? isPublic = null,
    Object? isCommunity = null,
  }) {
    return _then(_SnChannel(
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
              as dynamic,
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
              as List<SnChannelMember>?,
      messages: freezed == messages
          ? _self._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<SnChatMessage>?,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      realm: freezed == realm
          ? _self.realm
          : realm // ignore: cast_nullable_to_non_nullable
              as SnRealm?,
      realmId: freezed == realmId
          ? _self.realmId
          : realmId // ignore: cast_nullable_to_non_nullable
              as int?,
      isPublic: null == isPublic
          ? _self.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isCommunity: null == isCommunity
          ? _self.isCommunity
          : isCommunity // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of SnChannel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnRealmCopyWith<$Res>? get realm {
    if (_self.realm == null) {
      return null;
    }

    return $SnRealmCopyWith<$Res>(_self.realm!, (value) {
      return _then(_self.copyWith(realm: value));
    });
  }
}

/// @nodoc
mixin _$SnChannelMember {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  int get channelId;
  int get accountId;
  String? get nick;
  SnChannel? get channel;
  SnAccount? get account;
  int get notify;
  int get powerLevel;
  dynamic get calls;
  dynamic get events;

  /// Create a copy of SnChannelMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnChannelMemberCopyWith<SnChannelMember> get copyWith =>
      _$SnChannelMemberCopyWithImpl<SnChannelMember>(
          this as SnChannelMember, _$identity);

  /// Serializes this SnChannelMember to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnChannelMember &&
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

  @override
  String toString() {
    return 'SnChannelMember(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, channelId: $channelId, accountId: $accountId, nick: $nick, channel: $channel, account: $account, notify: $notify, powerLevel: $powerLevel, calls: $calls, events: $events)';
  }
}

/// @nodoc
abstract mixin class $SnChannelMemberCopyWith<$Res> {
  factory $SnChannelMemberCopyWith(
          SnChannelMember value, $Res Function(SnChannelMember) _then) =
      _$SnChannelMemberCopyWithImpl;
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
class _$SnChannelMemberCopyWithImpl<$Res>
    implements $SnChannelMemberCopyWith<$Res> {
  _$SnChannelMemberCopyWithImpl(this._self, this._then);

  final SnChannelMember _self;
  final $Res Function(SnChannelMember) _then;

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
      channelId: null == channelId
          ? _self.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      nick: freezed == nick
          ? _self.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String?,
      channel: freezed == channel
          ? _self.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as SnChannel?,
      account: freezed == account
          ? _self.account
          : account // ignore: cast_nullable_to_non_nullable
              as SnAccount?,
      notify: null == notify
          ? _self.notify
          : notify // ignore: cast_nullable_to_non_nullable
              as int,
      powerLevel: null == powerLevel
          ? _self.powerLevel
          : powerLevel // ignore: cast_nullable_to_non_nullable
              as int,
      calls: freezed == calls
          ? _self.calls
          : calls // ignore: cast_nullable_to_non_nullable
              as dynamic,
      events: freezed == events
          ? _self.events
          : events // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }

  /// Create a copy of SnChannelMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChannelCopyWith<$Res>? get channel {
    if (_self.channel == null) {
      return null;
    }

    return $SnChannelCopyWith<$Res>(_self.channel!, (value) {
      return _then(_self.copyWith(channel: value));
    });
  }

  /// Create a copy of SnChannelMember
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
class _SnChannelMember extends SnChannelMember {
  const _SnChannelMember(
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
  factory _SnChannelMember.fromJson(Map<String, dynamic> json) =>
      _$SnChannelMemberFromJson(json);

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

  /// Create a copy of SnChannelMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnChannelMemberCopyWith<_SnChannelMember> get copyWith =>
      __$SnChannelMemberCopyWithImpl<_SnChannelMember>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnChannelMemberToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnChannelMember &&
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

  @override
  String toString() {
    return 'SnChannelMember(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, channelId: $channelId, accountId: $accountId, nick: $nick, channel: $channel, account: $account, notify: $notify, powerLevel: $powerLevel, calls: $calls, events: $events)';
  }
}

/// @nodoc
abstract mixin class _$SnChannelMemberCopyWith<$Res>
    implements $SnChannelMemberCopyWith<$Res> {
  factory _$SnChannelMemberCopyWith(
          _SnChannelMember value, $Res Function(_SnChannelMember) _then) =
      __$SnChannelMemberCopyWithImpl;
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
class __$SnChannelMemberCopyWithImpl<$Res>
    implements _$SnChannelMemberCopyWith<$Res> {
  __$SnChannelMemberCopyWithImpl(this._self, this._then);

  final _SnChannelMember _self;
  final $Res Function(_SnChannelMember) _then;

  /// Create a copy of SnChannelMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_SnChannelMember(
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
      channelId: null == channelId
          ? _self.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      nick: freezed == nick
          ? _self.nick
          : nick // ignore: cast_nullable_to_non_nullable
              as String?,
      channel: freezed == channel
          ? _self.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as SnChannel?,
      account: freezed == account
          ? _self.account
          : account // ignore: cast_nullable_to_non_nullable
              as SnAccount?,
      notify: null == notify
          ? _self.notify
          : notify // ignore: cast_nullable_to_non_nullable
              as int,
      powerLevel: null == powerLevel
          ? _self.powerLevel
          : powerLevel // ignore: cast_nullable_to_non_nullable
              as int,
      calls: freezed == calls
          ? _self.calls
          : calls // ignore: cast_nullable_to_non_nullable
              as dynamic,
      events: freezed == events
          ? _self.events
          : events // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }

  /// Create a copy of SnChannelMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChannelCopyWith<$Res>? get channel {
    if (_self.channel == null) {
      return null;
    }

    return $SnChannelCopyWith<$Res>(_self.channel!, (value) {
      return _then(_self.copyWith(channel: value));
    });
  }

  /// Create a copy of SnChannelMember
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
mixin _$SnChatMessage {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get uuid;
  Map<String, dynamic> get body;
  String get type;
  SnChannel get channel;
  SnChannelMember get sender;
  int get channelId;
  int get senderId;
  int? get quoteEventId;
  int? get relatedEventId;
  SnChatMessagePreload? get preload;

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnChatMessageCopyWith<SnChatMessage> get copyWith =>
      _$SnChatMessageCopyWithImpl<SnChatMessage>(
          this as SnChatMessage, _$identity);

  /// Serializes this SnChatMessage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnChatMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            const DeepCollectionEquality().equals(other.body, body) &&
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
      const DeepCollectionEquality().hash(body),
      type,
      channel,
      sender,
      channelId,
      senderId,
      quoteEventId,
      relatedEventId,
      preload);

  @override
  String toString() {
    return 'SnChatMessage(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, uuid: $uuid, body: $body, type: $type, channel: $channel, sender: $sender, channelId: $channelId, senderId: $senderId, quoteEventId: $quoteEventId, relatedEventId: $relatedEventId, preload: $preload)';
  }
}

/// @nodoc
abstract mixin class $SnChatMessageCopyWith<$Res> {
  factory $SnChatMessageCopyWith(
          SnChatMessage value, $Res Function(SnChatMessage) _then) =
      _$SnChatMessageCopyWithImpl;
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
class _$SnChatMessageCopyWithImpl<$Res>
    implements $SnChatMessageCopyWith<$Res> {
  _$SnChatMessageCopyWithImpl(this._self, this._then);

  final SnChatMessage _self;
  final $Res Function(SnChatMessage) _then;

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
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _self.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as SnChannel,
      sender: null == sender
          ? _self.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as SnChannelMember,
      channelId: null == channelId
          ? _self.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int,
      senderId: null == senderId
          ? _self.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as int,
      quoteEventId: freezed == quoteEventId
          ? _self.quoteEventId
          : quoteEventId // ignore: cast_nullable_to_non_nullable
              as int?,
      relatedEventId: freezed == relatedEventId
          ? _self.relatedEventId
          : relatedEventId // ignore: cast_nullable_to_non_nullable
              as int?,
      preload: freezed == preload
          ? _self.preload
          : preload // ignore: cast_nullable_to_non_nullable
              as SnChatMessagePreload?,
    ));
  }

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChannelCopyWith<$Res> get channel {
    return $SnChannelCopyWith<$Res>(_self.channel, (value) {
      return _then(_self.copyWith(channel: value));
    });
  }

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChannelMemberCopyWith<$Res> get sender {
    return $SnChannelMemberCopyWith<$Res>(_self.sender, (value) {
      return _then(_self.copyWith(sender: value));
    });
  }

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChatMessagePreloadCopyWith<$Res>? get preload {
    if (_self.preload == null) {
      return null;
    }

    return $SnChatMessagePreloadCopyWith<$Res>(_self.preload!, (value) {
      return _then(_self.copyWith(preload: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SnChatMessage extends SnChatMessage {
  const _SnChatMessage(
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
  factory _SnChatMessage.fromJson(Map<String, dynamic> json) =>
      _$SnChatMessageFromJson(json);

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

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnChatMessageCopyWith<_SnChatMessage> get copyWith =>
      __$SnChatMessageCopyWithImpl<_SnChatMessage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnChatMessageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnChatMessage &&
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

  @override
  String toString() {
    return 'SnChatMessage(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, uuid: $uuid, body: $body, type: $type, channel: $channel, sender: $sender, channelId: $channelId, senderId: $senderId, quoteEventId: $quoteEventId, relatedEventId: $relatedEventId, preload: $preload)';
  }
}

/// @nodoc
abstract mixin class _$SnChatMessageCopyWith<$Res>
    implements $SnChatMessageCopyWith<$Res> {
  factory _$SnChatMessageCopyWith(
          _SnChatMessage value, $Res Function(_SnChatMessage) _then) =
      __$SnChatMessageCopyWithImpl;
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
class __$SnChatMessageCopyWithImpl<$Res>
    implements _$SnChatMessageCopyWith<$Res> {
  __$SnChatMessageCopyWithImpl(this._self, this._then);

  final _SnChatMessage _self;
  final $Res Function(_SnChatMessage) _then;

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_SnChatMessage(
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
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _self._body
          : body // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _self.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as SnChannel,
      sender: null == sender
          ? _self.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as SnChannelMember,
      channelId: null == channelId
          ? _self.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int,
      senderId: null == senderId
          ? _self.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as int,
      quoteEventId: freezed == quoteEventId
          ? _self.quoteEventId
          : quoteEventId // ignore: cast_nullable_to_non_nullable
              as int?,
      relatedEventId: freezed == relatedEventId
          ? _self.relatedEventId
          : relatedEventId // ignore: cast_nullable_to_non_nullable
              as int?,
      preload: freezed == preload
          ? _self.preload
          : preload // ignore: cast_nullable_to_non_nullable
              as SnChatMessagePreload?,
    ));
  }

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChannelCopyWith<$Res> get channel {
    return $SnChannelCopyWith<$Res>(_self.channel, (value) {
      return _then(_self.copyWith(channel: value));
    });
  }

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChannelMemberCopyWith<$Res> get sender {
    return $SnChannelMemberCopyWith<$Res>(_self.sender, (value) {
      return _then(_self.copyWith(sender: value));
    });
  }

  /// Create a copy of SnChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChatMessagePreloadCopyWith<$Res>? get preload {
    if (_self.preload == null) {
      return null;
    }

    return $SnChatMessagePreloadCopyWith<$Res>(_self.preload!, (value) {
      return _then(_self.copyWith(preload: value));
    });
  }
}

/// @nodoc
mixin _$SnChatMessagePreload {
  List<SnAttachment?>? get attachments;
  SnChatMessage? get quoteEvent;

  /// Create a copy of SnChatMessagePreload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnChatMessagePreloadCopyWith<SnChatMessagePreload> get copyWith =>
      _$SnChatMessagePreloadCopyWithImpl<SnChatMessagePreload>(
          this as SnChatMessagePreload, _$identity);

  /// Serializes this SnChatMessagePreload to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnChatMessagePreload &&
            const DeepCollectionEquality()
                .equals(other.attachments, attachments) &&
            (identical(other.quoteEvent, quoteEvent) ||
                other.quoteEvent == quoteEvent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(attachments), quoteEvent);

  @override
  String toString() {
    return 'SnChatMessagePreload(attachments: $attachments, quoteEvent: $quoteEvent)';
  }
}

/// @nodoc
abstract mixin class $SnChatMessagePreloadCopyWith<$Res> {
  factory $SnChatMessagePreloadCopyWith(SnChatMessagePreload value,
          $Res Function(SnChatMessagePreload) _then) =
      _$SnChatMessagePreloadCopyWithImpl;
  @useResult
  $Res call({List<SnAttachment?>? attachments, SnChatMessage? quoteEvent});

  $SnChatMessageCopyWith<$Res>? get quoteEvent;
}

/// @nodoc
class _$SnChatMessagePreloadCopyWithImpl<$Res>
    implements $SnChatMessagePreloadCopyWith<$Res> {
  _$SnChatMessagePreloadCopyWithImpl(this._self, this._then);

  final SnChatMessagePreload _self;
  final $Res Function(SnChatMessagePreload) _then;

  /// Create a copy of SnChatMessagePreload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? attachments = freezed,
    Object? quoteEvent = freezed,
  }) {
    return _then(_self.copyWith(
      attachments: freezed == attachments
          ? _self.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<SnAttachment?>?,
      quoteEvent: freezed == quoteEvent
          ? _self.quoteEvent
          : quoteEvent // ignore: cast_nullable_to_non_nullable
              as SnChatMessage?,
    ));
  }

  /// Create a copy of SnChatMessagePreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChatMessageCopyWith<$Res>? get quoteEvent {
    if (_self.quoteEvent == null) {
      return null;
    }

    return $SnChatMessageCopyWith<$Res>(_self.quoteEvent!, (value) {
      return _then(_self.copyWith(quoteEvent: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SnChatMessagePreload extends SnChatMessagePreload {
  const _SnChatMessagePreload(
      {final List<SnAttachment?>? attachments, this.quoteEvent})
      : _attachments = attachments,
        super._();
  factory _SnChatMessagePreload.fromJson(Map<String, dynamic> json) =>
      _$SnChatMessagePreloadFromJson(json);

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

  /// Create a copy of SnChatMessagePreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnChatMessagePreloadCopyWith<_SnChatMessagePreload> get copyWith =>
      __$SnChatMessagePreloadCopyWithImpl<_SnChatMessagePreload>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnChatMessagePreloadToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnChatMessagePreload &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.quoteEvent, quoteEvent) ||
                other.quoteEvent == quoteEvent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_attachments), quoteEvent);

  @override
  String toString() {
    return 'SnChatMessagePreload(attachments: $attachments, quoteEvent: $quoteEvent)';
  }
}

/// @nodoc
abstract mixin class _$SnChatMessagePreloadCopyWith<$Res>
    implements $SnChatMessagePreloadCopyWith<$Res> {
  factory _$SnChatMessagePreloadCopyWith(_SnChatMessagePreload value,
          $Res Function(_SnChatMessagePreload) _then) =
      __$SnChatMessagePreloadCopyWithImpl;
  @override
  @useResult
  $Res call({List<SnAttachment?>? attachments, SnChatMessage? quoteEvent});

  @override
  $SnChatMessageCopyWith<$Res>? get quoteEvent;
}

/// @nodoc
class __$SnChatMessagePreloadCopyWithImpl<$Res>
    implements _$SnChatMessagePreloadCopyWith<$Res> {
  __$SnChatMessagePreloadCopyWithImpl(this._self, this._then);

  final _SnChatMessagePreload _self;
  final $Res Function(_SnChatMessagePreload) _then;

  /// Create a copy of SnChatMessagePreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? attachments = freezed,
    Object? quoteEvent = freezed,
  }) {
    return _then(_SnChatMessagePreload(
      attachments: freezed == attachments
          ? _self._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<SnAttachment?>?,
      quoteEvent: freezed == quoteEvent
          ? _self.quoteEvent
          : quoteEvent // ignore: cast_nullable_to_non_nullable
              as SnChatMessage?,
    ));
  }

  /// Create a copy of SnChatMessagePreload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChatMessageCopyWith<$Res>? get quoteEvent {
    if (_self.quoteEvent == null) {
      return null;
    }

    return $SnChatMessageCopyWith<$Res>(_self.quoteEvent!, (value) {
      return _then(_self.copyWith(quoteEvent: value));
    });
  }
}

/// @nodoc
mixin _$SnChatCall {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  DateTime? get endedAt;
  String get externalId;
  int get founderId;
  int get channelId;
  SnChannelMember get founder;
  List<dynamic> get participants;

  /// Create a copy of SnChatCall
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnChatCallCopyWith<SnChatCall> get copyWith =>
      _$SnChatCallCopyWithImpl<SnChatCall>(this as SnChatCall, _$identity);

  /// Serializes this SnChatCall to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnChatCall &&
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
                .equals(other.participants, participants));
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
      const DeepCollectionEquality().hash(participants));

  @override
  String toString() {
    return 'SnChatCall(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, endedAt: $endedAt, externalId: $externalId, founderId: $founderId, channelId: $channelId, founder: $founder, participants: $participants)';
  }
}

/// @nodoc
abstract mixin class $SnChatCallCopyWith<$Res> {
  factory $SnChatCallCopyWith(
          SnChatCall value, $Res Function(SnChatCall) _then) =
      _$SnChatCallCopyWithImpl;
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
class _$SnChatCallCopyWithImpl<$Res> implements $SnChatCallCopyWith<$Res> {
  _$SnChatCallCopyWithImpl(this._self, this._then);

  final SnChatCall _self;
  final $Res Function(SnChatCall) _then;

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
      endedAt: freezed == endedAt
          ? _self.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      externalId: null == externalId
          ? _self.externalId
          : externalId // ignore: cast_nullable_to_non_nullable
              as String,
      founderId: null == founderId
          ? _self.founderId
          : founderId // ignore: cast_nullable_to_non_nullable
              as int,
      channelId: null == channelId
          ? _self.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int,
      founder: null == founder
          ? _self.founder
          : founder // ignore: cast_nullable_to_non_nullable
              as SnChannelMember,
      participants: null == participants
          ? _self.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }

  /// Create a copy of SnChatCall
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChannelMemberCopyWith<$Res> get founder {
    return $SnChannelMemberCopyWith<$Res>(_self.founder, (value) {
      return _then(_self.copyWith(founder: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SnChatCall implements SnChatCall {
  const _SnChatCall(
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
  factory _SnChatCall.fromJson(Map<String, dynamic> json) =>
      _$SnChatCallFromJson(json);

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

  /// Create a copy of SnChatCall
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnChatCallCopyWith<_SnChatCall> get copyWith =>
      __$SnChatCallCopyWithImpl<_SnChatCall>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnChatCallToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnChatCall &&
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

  @override
  String toString() {
    return 'SnChatCall(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, endedAt: $endedAt, externalId: $externalId, founderId: $founderId, channelId: $channelId, founder: $founder, participants: $participants)';
  }
}

/// @nodoc
abstract mixin class _$SnChatCallCopyWith<$Res>
    implements $SnChatCallCopyWith<$Res> {
  factory _$SnChatCallCopyWith(
          _SnChatCall value, $Res Function(_SnChatCall) _then) =
      __$SnChatCallCopyWithImpl;
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
class __$SnChatCallCopyWithImpl<$Res> implements _$SnChatCallCopyWith<$Res> {
  __$SnChatCallCopyWithImpl(this._self, this._then);

  final _SnChatCall _self;
  final $Res Function(_SnChatCall) _then;

  /// Create a copy of SnChatCall
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_SnChatCall(
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
      endedAt: freezed == endedAt
          ? _self.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      externalId: null == externalId
          ? _self.externalId
          : externalId // ignore: cast_nullable_to_non_nullable
              as String,
      founderId: null == founderId
          ? _self.founderId
          : founderId // ignore: cast_nullable_to_non_nullable
              as int,
      channelId: null == channelId
          ? _self.channelId
          : channelId // ignore: cast_nullable_to_non_nullable
              as int,
      founder: null == founder
          ? _self.founder
          : founder // ignore: cast_nullable_to_non_nullable
              as SnChannelMember,
      participants: null == participants
          ? _self._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }

  /// Create a copy of SnChatCall
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnChannelMemberCopyWith<$Res> get founder {
    return $SnChannelMemberCopyWith<$Res>(_self.founder, (value) {
      return _then(_self.copyWith(founder: value));
    });
  }
}

// dart format on
