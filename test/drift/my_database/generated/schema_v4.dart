// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class SnLocalChatChannel extends Table
    with TableInfo<SnLocalChatChannel, SnLocalChatChannelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SnLocalChatChannel(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
      'alias', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  @override
  List<GeneratedColumn> get $columns => [id, alias, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sn_local_chat_channel';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnLocalChatChannelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnLocalChatChannelData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      alias: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alias'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  SnLocalChatChannel createAlias(String alias) {
    return SnLocalChatChannel(attachedDatabase, alias);
  }
}

class SnLocalChatChannelData extends DataClass
    implements Insertable<SnLocalChatChannelData> {
  final int id;
  final String alias;
  final String content;
  final DateTime createdAt;
  const SnLocalChatChannelData(
      {required this.id,
      required this.alias,
      required this.content,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['alias'] = Variable<String>(alias);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SnLocalChatChannelCompanion toCompanion(bool nullToAbsent) {
    return SnLocalChatChannelCompanion(
      id: Value(id),
      alias: Value(alias),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory SnLocalChatChannelData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnLocalChatChannelData(
      id: serializer.fromJson<int>(json['id']),
      alias: serializer.fromJson<String>(json['alias']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'alias': serializer.toJson<String>(alias),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SnLocalChatChannelData copyWith(
          {int? id, String? alias, String? content, DateTime? createdAt}) =>
      SnLocalChatChannelData(
        id: id ?? this.id,
        alias: alias ?? this.alias,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );
  SnLocalChatChannelData copyWithCompanion(SnLocalChatChannelCompanion data) {
    return SnLocalChatChannelData(
      id: data.id.present ? data.id.value : this.id,
      alias: data.alias.present ? data.alias.value : this.alias,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalChatChannelData(')
          ..write('id: $id, ')
          ..write('alias: $alias, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, alias, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnLocalChatChannelData &&
          other.id == this.id &&
          other.alias == this.alias &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class SnLocalChatChannelCompanion
    extends UpdateCompanion<SnLocalChatChannelData> {
  final Value<int> id;
  final Value<String> alias;
  final Value<String> content;
  final Value<DateTime> createdAt;
  const SnLocalChatChannelCompanion({
    this.id = const Value.absent(),
    this.alias = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SnLocalChatChannelCompanion.insert({
    this.id = const Value.absent(),
    required String alias,
    required String content,
    this.createdAt = const Value.absent(),
  })  : alias = Value(alias),
        content = Value(content);
  static Insertable<SnLocalChatChannelData> custom({
    Expression<int>? id,
    Expression<String>? alias,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alias != null) 'alias': alias,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SnLocalChatChannelCompanion copyWith(
      {Value<int>? id,
      Value<String>? alias,
      Value<String>? content,
      Value<DateTime>? createdAt}) {
    return SnLocalChatChannelCompanion(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalChatChannelCompanion(')
          ..write('id: $id, ')
          ..write('alias: $alias, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class SnLocalChatMessage extends Table
    with TableInfo<SnLocalChatMessage, SnLocalChatMessageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SnLocalChatMessage(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> channelId = GeneratedColumn<int>(
      'channel_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<int> senderId = GeneratedColumn<int>(
      'sender_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, channelId, senderId, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sn_local_chat_message';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnLocalChatMessageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnLocalChatMessageData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      channelId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}channel_id'])!,
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sender_id']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  SnLocalChatMessage createAlias(String alias) {
    return SnLocalChatMessage(attachedDatabase, alias);
  }
}

class SnLocalChatMessageData extends DataClass
    implements Insertable<SnLocalChatMessageData> {
  final int id;
  final int channelId;
  final int? senderId;
  final String content;
  final DateTime createdAt;
  const SnLocalChatMessageData(
      {required this.id,
      required this.channelId,
      this.senderId,
      required this.content,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['channel_id'] = Variable<int>(channelId);
    if (!nullToAbsent || senderId != null) {
      map['sender_id'] = Variable<int>(senderId);
    }
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SnLocalChatMessageCompanion toCompanion(bool nullToAbsent) {
    return SnLocalChatMessageCompanion(
      id: Value(id),
      channelId: Value(channelId),
      senderId: senderId == null && nullToAbsent
          ? const Value.absent()
          : Value(senderId),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory SnLocalChatMessageData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnLocalChatMessageData(
      id: serializer.fromJson<int>(json['id']),
      channelId: serializer.fromJson<int>(json['channelId']),
      senderId: serializer.fromJson<int?>(json['senderId']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'channelId': serializer.toJson<int>(channelId),
      'senderId': serializer.toJson<int?>(senderId),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SnLocalChatMessageData copyWith(
          {int? id,
          int? channelId,
          Value<int?> senderId = const Value.absent(),
          String? content,
          DateTime? createdAt}) =>
      SnLocalChatMessageData(
        id: id ?? this.id,
        channelId: channelId ?? this.channelId,
        senderId: senderId.present ? senderId.value : this.senderId,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );
  SnLocalChatMessageData copyWithCompanion(SnLocalChatMessageCompanion data) {
    return SnLocalChatMessageData(
      id: data.id.present ? data.id.value : this.id,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalChatMessageData(')
          ..write('id: $id, ')
          ..write('channelId: $channelId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, channelId, senderId, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnLocalChatMessageData &&
          other.id == this.id &&
          other.channelId == this.channelId &&
          other.senderId == this.senderId &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class SnLocalChatMessageCompanion
    extends UpdateCompanion<SnLocalChatMessageData> {
  final Value<int> id;
  final Value<int> channelId;
  final Value<int?> senderId;
  final Value<String> content;
  final Value<DateTime> createdAt;
  const SnLocalChatMessageCompanion({
    this.id = const Value.absent(),
    this.channelId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SnLocalChatMessageCompanion.insert({
    this.id = const Value.absent(),
    required int channelId,
    this.senderId = const Value.absent(),
    required String content,
    this.createdAt = const Value.absent(),
  })  : channelId = Value(channelId),
        content = Value(content);
  static Insertable<SnLocalChatMessageData> custom({
    Expression<int>? id,
    Expression<int>? channelId,
    Expression<int>? senderId,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (channelId != null) 'channel_id': channelId,
      if (senderId != null) 'sender_id': senderId,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SnLocalChatMessageCompanion copyWith(
      {Value<int>? id,
      Value<int>? channelId,
      Value<int?>? senderId,
      Value<String>? content,
      Value<DateTime>? createdAt}) {
    return SnLocalChatMessageCompanion(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<int>(channelId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<int>(senderId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalChatMessageCompanion(')
          ..write('id: $id, ')
          ..write('channelId: $channelId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class SnLocalChannelMember extends Table
    with TableInfo<SnLocalChannelMember, SnLocalChannelMemberData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SnLocalChannelMember(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<int> channelId = GeneratedColumn<int>(
      'channel_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<DateTime> cacheExpiredAt =
      GeneratedColumn<DateTime>('cache_expired_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, channelId, accountId, content, createdAt, cacheExpiredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sn_local_channel_member';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnLocalChannelMemberData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnLocalChannelMemberData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      channelId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}channel_id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      cacheExpiredAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}cache_expired_at'])!,
    );
  }

  @override
  SnLocalChannelMember createAlias(String alias) {
    return SnLocalChannelMember(attachedDatabase, alias);
  }
}

class SnLocalChannelMemberData extends DataClass
    implements Insertable<SnLocalChannelMemberData> {
  final int id;
  final int channelId;
  final int accountId;
  final String content;
  final DateTime createdAt;
  final DateTime cacheExpiredAt;
  const SnLocalChannelMemberData(
      {required this.id,
      required this.channelId,
      required this.accountId,
      required this.content,
      required this.createdAt,
      required this.cacheExpiredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['channel_id'] = Variable<int>(channelId);
    map['account_id'] = Variable<int>(accountId);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['cache_expired_at'] = Variable<DateTime>(cacheExpiredAt);
    return map;
  }

  SnLocalChannelMemberCompanion toCompanion(bool nullToAbsent) {
    return SnLocalChannelMemberCompanion(
      id: Value(id),
      channelId: Value(channelId),
      accountId: Value(accountId),
      content: Value(content),
      createdAt: Value(createdAt),
      cacheExpiredAt: Value(cacheExpiredAt),
    );
  }

  factory SnLocalChannelMemberData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnLocalChannelMemberData(
      id: serializer.fromJson<int>(json['id']),
      channelId: serializer.fromJson<int>(json['channelId']),
      accountId: serializer.fromJson<int>(json['accountId']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      cacheExpiredAt: serializer.fromJson<DateTime>(json['cacheExpiredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'channelId': serializer.toJson<int>(channelId),
      'accountId': serializer.toJson<int>(accountId),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'cacheExpiredAt': serializer.toJson<DateTime>(cacheExpiredAt),
    };
  }

  SnLocalChannelMemberData copyWith(
          {int? id,
          int? channelId,
          int? accountId,
          String? content,
          DateTime? createdAt,
          DateTime? cacheExpiredAt}) =>
      SnLocalChannelMemberData(
        id: id ?? this.id,
        channelId: channelId ?? this.channelId,
        accountId: accountId ?? this.accountId,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        cacheExpiredAt: cacheExpiredAt ?? this.cacheExpiredAt,
      );
  SnLocalChannelMemberData copyWithCompanion(
      SnLocalChannelMemberCompanion data) {
    return SnLocalChannelMemberData(
      id: data.id.present ? data.id.value : this.id,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cacheExpiredAt: data.cacheExpiredAt.present
          ? data.cacheExpiredAt.value
          : this.cacheExpiredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalChannelMemberData(')
          ..write('id: $id, ')
          ..write('channelId: $channelId, ')
          ..write('accountId: $accountId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('cacheExpiredAt: $cacheExpiredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, channelId, accountId, content, createdAt, cacheExpiredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnLocalChannelMemberData &&
          other.id == this.id &&
          other.channelId == this.channelId &&
          other.accountId == this.accountId &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.cacheExpiredAt == this.cacheExpiredAt);
}

class SnLocalChannelMemberCompanion
    extends UpdateCompanion<SnLocalChannelMemberData> {
  final Value<int> id;
  final Value<int> channelId;
  final Value<int> accountId;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<DateTime> cacheExpiredAt;
  const SnLocalChannelMemberCompanion({
    this.id = const Value.absent(),
    this.channelId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cacheExpiredAt = const Value.absent(),
  });
  SnLocalChannelMemberCompanion.insert({
    this.id = const Value.absent(),
    required int channelId,
    required int accountId,
    required String content,
    this.createdAt = const Value.absent(),
    required DateTime cacheExpiredAt,
  })  : channelId = Value(channelId),
        accountId = Value(accountId),
        content = Value(content),
        cacheExpiredAt = Value(cacheExpiredAt);
  static Insertable<SnLocalChannelMemberData> custom({
    Expression<int>? id,
    Expression<int>? channelId,
    Expression<int>? accountId,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? cacheExpiredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (channelId != null) 'channel_id': channelId,
      if (accountId != null) 'account_id': accountId,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (cacheExpiredAt != null) 'cache_expired_at': cacheExpiredAt,
    });
  }

  SnLocalChannelMemberCompanion copyWith(
      {Value<int>? id,
      Value<int>? channelId,
      Value<int>? accountId,
      Value<String>? content,
      Value<DateTime>? createdAt,
      Value<DateTime>? cacheExpiredAt}) {
    return SnLocalChannelMemberCompanion(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      accountId: accountId ?? this.accountId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      cacheExpiredAt: cacheExpiredAt ?? this.cacheExpiredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<int>(channelId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cacheExpiredAt.present) {
      map['cache_expired_at'] = Variable<DateTime>(cacheExpiredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalChannelMemberCompanion(')
          ..write('id: $id, ')
          ..write('channelId: $channelId, ')
          ..write('accountId: $accountId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('cacheExpiredAt: $cacheExpiredAt')
          ..write(')'))
        .toString();
  }
}

class SnLocalKeyPair extends Table
    with TableInfo<SnLocalKeyPair, SnLocalKeyPairData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SnLocalKeyPair(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
      'public_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> privateKey = GeneratedColumn<String>(
      'private_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const CustomExpression('0'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, accountId, publicKey, privateKey, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sn_local_key_pair';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnLocalKeyPairData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnLocalKeyPairData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      publicKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}public_key'])!,
      privateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}private_key']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  SnLocalKeyPair createAlias(String alias) {
    return SnLocalKeyPair(attachedDatabase, alias);
  }
}

class SnLocalKeyPairData extends DataClass
    implements Insertable<SnLocalKeyPairData> {
  final String id;
  final int accountId;
  final String publicKey;
  final String? privateKey;
  final bool isActive;
  const SnLocalKeyPairData(
      {required this.id,
      required this.accountId,
      required this.publicKey,
      this.privateKey,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<int>(accountId);
    map['public_key'] = Variable<String>(publicKey);
    if (!nullToAbsent || privateKey != null) {
      map['private_key'] = Variable<String>(privateKey);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  SnLocalKeyPairCompanion toCompanion(bool nullToAbsent) {
    return SnLocalKeyPairCompanion(
      id: Value(id),
      accountId: Value(accountId),
      publicKey: Value(publicKey),
      privateKey: privateKey == null && nullToAbsent
          ? const Value.absent()
          : Value(privateKey),
      isActive: Value(isActive),
    );
  }

  factory SnLocalKeyPairData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnLocalKeyPairData(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      publicKey: serializer.fromJson<String>(json['publicKey']),
      privateKey: serializer.fromJson<String?>(json['privateKey']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<int>(accountId),
      'publicKey': serializer.toJson<String>(publicKey),
      'privateKey': serializer.toJson<String?>(privateKey),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  SnLocalKeyPairData copyWith(
          {String? id,
          int? accountId,
          String? publicKey,
          Value<String?> privateKey = const Value.absent(),
          bool? isActive}) =>
      SnLocalKeyPairData(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        publicKey: publicKey ?? this.publicKey,
        privateKey: privateKey.present ? privateKey.value : this.privateKey,
        isActive: isActive ?? this.isActive,
      );
  SnLocalKeyPairData copyWithCompanion(SnLocalKeyPairCompanion data) {
    return SnLocalKeyPairData(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      privateKey:
          data.privateKey.present ? data.privateKey.value : this.privateKey,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalKeyPairData(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('publicKey: $publicKey, ')
          ..write('privateKey: $privateKey, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, accountId, publicKey, privateKey, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnLocalKeyPairData &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.publicKey == this.publicKey &&
          other.privateKey == this.privateKey &&
          other.isActive == this.isActive);
}

class SnLocalKeyPairCompanion extends UpdateCompanion<SnLocalKeyPairData> {
  final Value<String> id;
  final Value<int> accountId;
  final Value<String> publicKey;
  final Value<String?> privateKey;
  final Value<bool> isActive;
  final Value<int> rowid;
  const SnLocalKeyPairCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.privateKey = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SnLocalKeyPairCompanion.insert({
    required String id,
    required int accountId,
    required String publicKey,
    this.privateKey = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        accountId = Value(accountId),
        publicKey = Value(publicKey);
  static Insertable<SnLocalKeyPairData> custom({
    Expression<String>? id,
    Expression<int>? accountId,
    Expression<String>? publicKey,
    Expression<String>? privateKey,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (publicKey != null) 'public_key': publicKey,
      if (privateKey != null) 'private_key': privateKey,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SnLocalKeyPairCompanion copyWith(
      {Value<String>? id,
      Value<int>? accountId,
      Value<String>? publicKey,
      Value<String?>? privateKey,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return SnLocalKeyPairCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (privateKey.present) {
      map['private_key'] = Variable<String>(privateKey.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalKeyPairCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('publicKey: $publicKey, ')
          ..write('privateKey: $privateKey, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SnLocalAccount extends Table
    with TableInfo<SnLocalAccount, SnLocalAccountData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SnLocalAccount(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<DateTime> cacheExpiredAt =
      GeneratedColumn<DateTime>('cache_expired_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, content, createdAt, cacheExpiredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sn_local_account';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnLocalAccountData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnLocalAccountData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      cacheExpiredAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}cache_expired_at'])!,
    );
  }

  @override
  SnLocalAccount createAlias(String alias) {
    return SnLocalAccount(attachedDatabase, alias);
  }
}

class SnLocalAccountData extends DataClass
    implements Insertable<SnLocalAccountData> {
  final int id;
  final String name;
  final String content;
  final DateTime createdAt;
  final DateTime cacheExpiredAt;
  const SnLocalAccountData(
      {required this.id,
      required this.name,
      required this.content,
      required this.createdAt,
      required this.cacheExpiredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['cache_expired_at'] = Variable<DateTime>(cacheExpiredAt);
    return map;
  }

  SnLocalAccountCompanion toCompanion(bool nullToAbsent) {
    return SnLocalAccountCompanion(
      id: Value(id),
      name: Value(name),
      content: Value(content),
      createdAt: Value(createdAt),
      cacheExpiredAt: Value(cacheExpiredAt),
    );
  }

  factory SnLocalAccountData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnLocalAccountData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      cacheExpiredAt: serializer.fromJson<DateTime>(json['cacheExpiredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'cacheExpiredAt': serializer.toJson<DateTime>(cacheExpiredAt),
    };
  }

  SnLocalAccountData copyWith(
          {int? id,
          String? name,
          String? content,
          DateTime? createdAt,
          DateTime? cacheExpiredAt}) =>
      SnLocalAccountData(
        id: id ?? this.id,
        name: name ?? this.name,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        cacheExpiredAt: cacheExpiredAt ?? this.cacheExpiredAt,
      );
  SnLocalAccountData copyWithCompanion(SnLocalAccountCompanion data) {
    return SnLocalAccountData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cacheExpiredAt: data.cacheExpiredAt.present
          ? data.cacheExpiredAt.value
          : this.cacheExpiredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalAccountData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('cacheExpiredAt: $cacheExpiredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, content, createdAt, cacheExpiredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnLocalAccountData &&
          other.id == this.id &&
          other.name == this.name &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.cacheExpiredAt == this.cacheExpiredAt);
}

class SnLocalAccountCompanion extends UpdateCompanion<SnLocalAccountData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<DateTime> cacheExpiredAt;
  const SnLocalAccountCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cacheExpiredAt = const Value.absent(),
  });
  SnLocalAccountCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String content,
    this.createdAt = const Value.absent(),
    required DateTime cacheExpiredAt,
  })  : name = Value(name),
        content = Value(content),
        cacheExpiredAt = Value(cacheExpiredAt);
  static Insertable<SnLocalAccountData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? cacheExpiredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (cacheExpiredAt != null) 'cache_expired_at': cacheExpiredAt,
    });
  }

  SnLocalAccountCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? content,
      Value<DateTime>? createdAt,
      Value<DateTime>? cacheExpiredAt}) {
    return SnLocalAccountCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      cacheExpiredAt: cacheExpiredAt ?? this.cacheExpiredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cacheExpiredAt.present) {
      map['cache_expired_at'] = Variable<DateTime>(cacheExpiredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalAccountCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('cacheExpiredAt: $cacheExpiredAt')
          ..write(')'))
        .toString();
  }
}

class SnLocalAttachment extends Table
    with TableInfo<SnLocalAttachment, SnLocalAttachmentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SnLocalAttachment(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> rid = GeneratedColumn<String>(
      'rid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<DateTime> cacheExpiredAt =
      GeneratedColumn<DateTime>('cache_expired_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, rid, uuid, content, accountId, createdAt, cacheExpiredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sn_local_attachment';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnLocalAttachmentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnLocalAttachmentData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      rid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rid'])!,
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      cacheExpiredAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}cache_expired_at'])!,
    );
  }

  @override
  SnLocalAttachment createAlias(String alias) {
    return SnLocalAttachment(attachedDatabase, alias);
  }
}

class SnLocalAttachmentData extends DataClass
    implements Insertable<SnLocalAttachmentData> {
  final int id;
  final String rid;
  final String uuid;
  final String content;
  final int accountId;
  final DateTime createdAt;
  final DateTime cacheExpiredAt;
  const SnLocalAttachmentData(
      {required this.id,
      required this.rid,
      required this.uuid,
      required this.content,
      required this.accountId,
      required this.createdAt,
      required this.cacheExpiredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rid'] = Variable<String>(rid);
    map['uuid'] = Variable<String>(uuid);
    map['content'] = Variable<String>(content);
    map['account_id'] = Variable<int>(accountId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['cache_expired_at'] = Variable<DateTime>(cacheExpiredAt);
    return map;
  }

  SnLocalAttachmentCompanion toCompanion(bool nullToAbsent) {
    return SnLocalAttachmentCompanion(
      id: Value(id),
      rid: Value(rid),
      uuid: Value(uuid),
      content: Value(content),
      accountId: Value(accountId),
      createdAt: Value(createdAt),
      cacheExpiredAt: Value(cacheExpiredAt),
    );
  }

  factory SnLocalAttachmentData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnLocalAttachmentData(
      id: serializer.fromJson<int>(json['id']),
      rid: serializer.fromJson<String>(json['rid']),
      uuid: serializer.fromJson<String>(json['uuid']),
      content: serializer.fromJson<String>(json['content']),
      accountId: serializer.fromJson<int>(json['accountId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      cacheExpiredAt: serializer.fromJson<DateTime>(json['cacheExpiredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rid': serializer.toJson<String>(rid),
      'uuid': serializer.toJson<String>(uuid),
      'content': serializer.toJson<String>(content),
      'accountId': serializer.toJson<int>(accountId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'cacheExpiredAt': serializer.toJson<DateTime>(cacheExpiredAt),
    };
  }

  SnLocalAttachmentData copyWith(
          {int? id,
          String? rid,
          String? uuid,
          String? content,
          int? accountId,
          DateTime? createdAt,
          DateTime? cacheExpiredAt}) =>
      SnLocalAttachmentData(
        id: id ?? this.id,
        rid: rid ?? this.rid,
        uuid: uuid ?? this.uuid,
        content: content ?? this.content,
        accountId: accountId ?? this.accountId,
        createdAt: createdAt ?? this.createdAt,
        cacheExpiredAt: cacheExpiredAt ?? this.cacheExpiredAt,
      );
  SnLocalAttachmentData copyWithCompanion(SnLocalAttachmentCompanion data) {
    return SnLocalAttachmentData(
      id: data.id.present ? data.id.value : this.id,
      rid: data.rid.present ? data.rid.value : this.rid,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      content: data.content.present ? data.content.value : this.content,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cacheExpiredAt: data.cacheExpiredAt.present
          ? data.cacheExpiredAt.value
          : this.cacheExpiredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalAttachmentData(')
          ..write('id: $id, ')
          ..write('rid: $rid, ')
          ..write('uuid: $uuid, ')
          ..write('content: $content, ')
          ..write('accountId: $accountId, ')
          ..write('createdAt: $createdAt, ')
          ..write('cacheExpiredAt: $cacheExpiredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, rid, uuid, content, accountId, createdAt, cacheExpiredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnLocalAttachmentData &&
          other.id == this.id &&
          other.rid == this.rid &&
          other.uuid == this.uuid &&
          other.content == this.content &&
          other.accountId == this.accountId &&
          other.createdAt == this.createdAt &&
          other.cacheExpiredAt == this.cacheExpiredAt);
}

class SnLocalAttachmentCompanion
    extends UpdateCompanion<SnLocalAttachmentData> {
  final Value<int> id;
  final Value<String> rid;
  final Value<String> uuid;
  final Value<String> content;
  final Value<int> accountId;
  final Value<DateTime> createdAt;
  final Value<DateTime> cacheExpiredAt;
  const SnLocalAttachmentCompanion({
    this.id = const Value.absent(),
    this.rid = const Value.absent(),
    this.uuid = const Value.absent(),
    this.content = const Value.absent(),
    this.accountId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cacheExpiredAt = const Value.absent(),
  });
  SnLocalAttachmentCompanion.insert({
    this.id = const Value.absent(),
    required String rid,
    required String uuid,
    required String content,
    required int accountId,
    this.createdAt = const Value.absent(),
    required DateTime cacheExpiredAt,
  })  : rid = Value(rid),
        uuid = Value(uuid),
        content = Value(content),
        accountId = Value(accountId),
        cacheExpiredAt = Value(cacheExpiredAt);
  static Insertable<SnLocalAttachmentData> custom({
    Expression<int>? id,
    Expression<String>? rid,
    Expression<String>? uuid,
    Expression<String>? content,
    Expression<int>? accountId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? cacheExpiredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rid != null) 'rid': rid,
      if (uuid != null) 'uuid': uuid,
      if (content != null) 'content': content,
      if (accountId != null) 'account_id': accountId,
      if (createdAt != null) 'created_at': createdAt,
      if (cacheExpiredAt != null) 'cache_expired_at': cacheExpiredAt,
    });
  }

  SnLocalAttachmentCompanion copyWith(
      {Value<int>? id,
      Value<String>? rid,
      Value<String>? uuid,
      Value<String>? content,
      Value<int>? accountId,
      Value<DateTime>? createdAt,
      Value<DateTime>? cacheExpiredAt}) {
    return SnLocalAttachmentCompanion(
      id: id ?? this.id,
      rid: rid ?? this.rid,
      uuid: uuid ?? this.uuid,
      content: content ?? this.content,
      accountId: accountId ?? this.accountId,
      createdAt: createdAt ?? this.createdAt,
      cacheExpiredAt: cacheExpiredAt ?? this.cacheExpiredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rid.present) {
      map['rid'] = Variable<String>(rid.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cacheExpiredAt.present) {
      map['cache_expired_at'] = Variable<DateTime>(cacheExpiredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalAttachmentCompanion(')
          ..write('id: $id, ')
          ..write('rid: $rid, ')
          ..write('uuid: $uuid, ')
          ..write('content: $content, ')
          ..write('accountId: $accountId, ')
          ..write('createdAt: $createdAt, ')
          ..write('cacheExpiredAt: $cacheExpiredAt')
          ..write(')'))
        .toString();
  }
}

class SnLocalSticker extends Table
    with TableInfo<SnLocalSticker, SnLocalStickerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SnLocalSticker(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
      'alias', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> fullAlias = GeneratedColumn<String>(
      'full_alias', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, alias, fullAlias, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sn_local_sticker';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnLocalStickerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnLocalStickerData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      alias: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alias'])!,
      fullAlias: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_alias'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  SnLocalSticker createAlias(String alias) {
    return SnLocalSticker(attachedDatabase, alias);
  }
}

class SnLocalStickerData extends DataClass
    implements Insertable<SnLocalStickerData> {
  final int id;
  final String alias;
  final String fullAlias;
  final String content;
  final DateTime createdAt;
  const SnLocalStickerData(
      {required this.id,
      required this.alias,
      required this.fullAlias,
      required this.content,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['alias'] = Variable<String>(alias);
    map['full_alias'] = Variable<String>(fullAlias);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SnLocalStickerCompanion toCompanion(bool nullToAbsent) {
    return SnLocalStickerCompanion(
      id: Value(id),
      alias: Value(alias),
      fullAlias: Value(fullAlias),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory SnLocalStickerData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnLocalStickerData(
      id: serializer.fromJson<int>(json['id']),
      alias: serializer.fromJson<String>(json['alias']),
      fullAlias: serializer.fromJson<String>(json['fullAlias']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'alias': serializer.toJson<String>(alias),
      'fullAlias': serializer.toJson<String>(fullAlias),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SnLocalStickerData copyWith(
          {int? id,
          String? alias,
          String? fullAlias,
          String? content,
          DateTime? createdAt}) =>
      SnLocalStickerData(
        id: id ?? this.id,
        alias: alias ?? this.alias,
        fullAlias: fullAlias ?? this.fullAlias,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );
  SnLocalStickerData copyWithCompanion(SnLocalStickerCompanion data) {
    return SnLocalStickerData(
      id: data.id.present ? data.id.value : this.id,
      alias: data.alias.present ? data.alias.value : this.alias,
      fullAlias: data.fullAlias.present ? data.fullAlias.value : this.fullAlias,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalStickerData(')
          ..write('id: $id, ')
          ..write('alias: $alias, ')
          ..write('fullAlias: $fullAlias, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, alias, fullAlias, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnLocalStickerData &&
          other.id == this.id &&
          other.alias == this.alias &&
          other.fullAlias == this.fullAlias &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class SnLocalStickerCompanion extends UpdateCompanion<SnLocalStickerData> {
  final Value<int> id;
  final Value<String> alias;
  final Value<String> fullAlias;
  final Value<String> content;
  final Value<DateTime> createdAt;
  const SnLocalStickerCompanion({
    this.id = const Value.absent(),
    this.alias = const Value.absent(),
    this.fullAlias = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SnLocalStickerCompanion.insert({
    this.id = const Value.absent(),
    required String alias,
    required String fullAlias,
    required String content,
    this.createdAt = const Value.absent(),
  })  : alias = Value(alias),
        fullAlias = Value(fullAlias),
        content = Value(content);
  static Insertable<SnLocalStickerData> custom({
    Expression<int>? id,
    Expression<String>? alias,
    Expression<String>? fullAlias,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alias != null) 'alias': alias,
      if (fullAlias != null) 'full_alias': fullAlias,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SnLocalStickerCompanion copyWith(
      {Value<int>? id,
      Value<String>? alias,
      Value<String>? fullAlias,
      Value<String>? content,
      Value<DateTime>? createdAt}) {
    return SnLocalStickerCompanion(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      fullAlias: fullAlias ?? this.fullAlias,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (fullAlias.present) {
      map['full_alias'] = Variable<String>(fullAlias.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalStickerCompanion(')
          ..write('id: $id, ')
          ..write('alias: $alias, ')
          ..write('fullAlias: $fullAlias, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class SnLocalStickerPack extends Table
    with TableInfo<SnLocalStickerPack, SnLocalStickerPackData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SnLocalStickerPack(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  @override
  List<GeneratedColumn> get $columns => [id, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sn_local_sticker_pack';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnLocalStickerPackData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnLocalStickerPackData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  SnLocalStickerPack createAlias(String alias) {
    return SnLocalStickerPack(attachedDatabase, alias);
  }
}

class SnLocalStickerPackData extends DataClass
    implements Insertable<SnLocalStickerPackData> {
  final int id;
  final String content;
  final DateTime createdAt;
  const SnLocalStickerPackData(
      {required this.id, required this.content, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SnLocalStickerPackCompanion toCompanion(bool nullToAbsent) {
    return SnLocalStickerPackCompanion(
      id: Value(id),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory SnLocalStickerPackData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnLocalStickerPackData(
      id: serializer.fromJson<int>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SnLocalStickerPackData copyWith(
          {int? id, String? content, DateTime? createdAt}) =>
      SnLocalStickerPackData(
        id: id ?? this.id,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );
  SnLocalStickerPackData copyWithCompanion(SnLocalStickerPackCompanion data) {
    return SnLocalStickerPackData(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalStickerPackData(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnLocalStickerPackData &&
          other.id == this.id &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class SnLocalStickerPackCompanion
    extends UpdateCompanion<SnLocalStickerPackData> {
  final Value<int> id;
  final Value<String> content;
  final Value<DateTime> createdAt;
  const SnLocalStickerPackCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SnLocalStickerPackCompanion.insert({
    this.id = const Value.absent(),
    required String content,
    this.createdAt = const Value.absent(),
  }) : content = Value(content);
  static Insertable<SnLocalStickerPackData> custom({
    Expression<int>? id,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SnLocalStickerPackCompanion copyWith(
      {Value<int>? id, Value<String>? content, Value<DateTime>? createdAt}) {
    return SnLocalStickerPackCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalStickerPackCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class SnLocalRealm extends Table
    with TableInfo<SnLocalRealm, SnLocalRealmData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SnLocalRealm(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
      'alias', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: const CustomExpression(
          'CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)'));
  late final GeneratedColumn<DateTime> cacheExpiredAt =
      GeneratedColumn<DateTime>('cache_expired_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, alias, content, accountId, createdAt, cacheExpiredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sn_local_realm';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnLocalRealmData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnLocalRealmData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      alias: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alias'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      cacheExpiredAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}cache_expired_at'])!,
    );
  }

  @override
  SnLocalRealm createAlias(String alias) {
    return SnLocalRealm(attachedDatabase, alias);
  }
}

class SnLocalRealmData extends DataClass
    implements Insertable<SnLocalRealmData> {
  final int id;
  final String alias;
  final String content;
  final int accountId;
  final DateTime createdAt;
  final DateTime cacheExpiredAt;
  const SnLocalRealmData(
      {required this.id,
      required this.alias,
      required this.content,
      required this.accountId,
      required this.createdAt,
      required this.cacheExpiredAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['alias'] = Variable<String>(alias);
    map['content'] = Variable<String>(content);
    map['account_id'] = Variable<int>(accountId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['cache_expired_at'] = Variable<DateTime>(cacheExpiredAt);
    return map;
  }

  SnLocalRealmCompanion toCompanion(bool nullToAbsent) {
    return SnLocalRealmCompanion(
      id: Value(id),
      alias: Value(alias),
      content: Value(content),
      accountId: Value(accountId),
      createdAt: Value(createdAt),
      cacheExpiredAt: Value(cacheExpiredAt),
    );
  }

  factory SnLocalRealmData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnLocalRealmData(
      id: serializer.fromJson<int>(json['id']),
      alias: serializer.fromJson<String>(json['alias']),
      content: serializer.fromJson<String>(json['content']),
      accountId: serializer.fromJson<int>(json['accountId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      cacheExpiredAt: serializer.fromJson<DateTime>(json['cacheExpiredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'alias': serializer.toJson<String>(alias),
      'content': serializer.toJson<String>(content),
      'accountId': serializer.toJson<int>(accountId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'cacheExpiredAt': serializer.toJson<DateTime>(cacheExpiredAt),
    };
  }

  SnLocalRealmData copyWith(
          {int? id,
          String? alias,
          String? content,
          int? accountId,
          DateTime? createdAt,
          DateTime? cacheExpiredAt}) =>
      SnLocalRealmData(
        id: id ?? this.id,
        alias: alias ?? this.alias,
        content: content ?? this.content,
        accountId: accountId ?? this.accountId,
        createdAt: createdAt ?? this.createdAt,
        cacheExpiredAt: cacheExpiredAt ?? this.cacheExpiredAt,
      );
  SnLocalRealmData copyWithCompanion(SnLocalRealmCompanion data) {
    return SnLocalRealmData(
      id: data.id.present ? data.id.value : this.id,
      alias: data.alias.present ? data.alias.value : this.alias,
      content: data.content.present ? data.content.value : this.content,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cacheExpiredAt: data.cacheExpiredAt.present
          ? data.cacheExpiredAt.value
          : this.cacheExpiredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalRealmData(')
          ..write('id: $id, ')
          ..write('alias: $alias, ')
          ..write('content: $content, ')
          ..write('accountId: $accountId, ')
          ..write('createdAt: $createdAt, ')
          ..write('cacheExpiredAt: $cacheExpiredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, alias, content, accountId, createdAt, cacheExpiredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnLocalRealmData &&
          other.id == this.id &&
          other.alias == this.alias &&
          other.content == this.content &&
          other.accountId == this.accountId &&
          other.createdAt == this.createdAt &&
          other.cacheExpiredAt == this.cacheExpiredAt);
}

class SnLocalRealmCompanion extends UpdateCompanion<SnLocalRealmData> {
  final Value<int> id;
  final Value<String> alias;
  final Value<String> content;
  final Value<int> accountId;
  final Value<DateTime> createdAt;
  final Value<DateTime> cacheExpiredAt;
  const SnLocalRealmCompanion({
    this.id = const Value.absent(),
    this.alias = const Value.absent(),
    this.content = const Value.absent(),
    this.accountId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cacheExpiredAt = const Value.absent(),
  });
  SnLocalRealmCompanion.insert({
    this.id = const Value.absent(),
    required String alias,
    required String content,
    required int accountId,
    this.createdAt = const Value.absent(),
    required DateTime cacheExpiredAt,
  })  : alias = Value(alias),
        content = Value(content),
        accountId = Value(accountId),
        cacheExpiredAt = Value(cacheExpiredAt);
  static Insertable<SnLocalRealmData> custom({
    Expression<int>? id,
    Expression<String>? alias,
    Expression<String>? content,
    Expression<int>? accountId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? cacheExpiredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alias != null) 'alias': alias,
      if (content != null) 'content': content,
      if (accountId != null) 'account_id': accountId,
      if (createdAt != null) 'created_at': createdAt,
      if (cacheExpiredAt != null) 'cache_expired_at': cacheExpiredAt,
    });
  }

  SnLocalRealmCompanion copyWith(
      {Value<int>? id,
      Value<String>? alias,
      Value<String>? content,
      Value<int>? accountId,
      Value<DateTime>? createdAt,
      Value<DateTime>? cacheExpiredAt}) {
    return SnLocalRealmCompanion(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      content: content ?? this.content,
      accountId: accountId ?? this.accountId,
      createdAt: createdAt ?? this.createdAt,
      cacheExpiredAt: cacheExpiredAt ?? this.cacheExpiredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cacheExpiredAt.present) {
      map['cache_expired_at'] = Variable<DateTime>(cacheExpiredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalRealmCompanion(')
          ..write('id: $id, ')
          ..write('alias: $alias, ')
          ..write('content: $content, ')
          ..write('accountId: $accountId, ')
          ..write('createdAt: $createdAt, ')
          ..write('cacheExpiredAt: $cacheExpiredAt')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV4 extends GeneratedDatabase {
  DatabaseAtV4(QueryExecutor e) : super(e);
  late final SnLocalChatChannel snLocalChatChannel = SnLocalChatChannel(this);
  late final SnLocalChatMessage snLocalChatMessage = SnLocalChatMessage(this);
  late final SnLocalChannelMember snLocalChannelMember =
      SnLocalChannelMember(this);
  late final SnLocalKeyPair snLocalKeyPair = SnLocalKeyPair(this);
  late final SnLocalAccount snLocalAccount = SnLocalAccount(this);
  late final SnLocalAttachment snLocalAttachment = SnLocalAttachment(this);
  late final SnLocalSticker snLocalSticker = SnLocalSticker(this);
  late final SnLocalStickerPack snLocalStickerPack = SnLocalStickerPack(this);
  late final SnLocalRealm snLocalRealm = SnLocalRealm(this);
  late final Index idxChannelAlias = Index('idx_channel_alias',
      'CREATE INDEX idx_channel_alias ON sn_local_chat_channel (alias)');
  late final Index idxChatChannel = Index('idx_chat_channel',
      'CREATE INDEX idx_chat_channel ON sn_local_chat_message (channel_id)');
  late final Index idxAccountName = Index('idx_account_name',
      'CREATE INDEX idx_account_name ON sn_local_account (name)');
  late final Index idxAttachmentRid = Index('idx_attachment_rid',
      'CREATE INDEX idx_attachment_rid ON sn_local_attachment (rid)');
  late final Index idxAttachmentAccount = Index('idx_attachment_account',
      'CREATE INDEX idx_attachment_account ON sn_local_attachment (account_id)');
  late final Index idxRealmAlias = Index('idx_realm_alias',
      'CREATE INDEX idx_realm_alias ON sn_local_realm (alias)');
  late final Index idxRealmAccount = Index('idx_realm_account',
      'CREATE INDEX idx_realm_account ON sn_local_realm (account_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        snLocalChatChannel,
        snLocalChatMessage,
        snLocalChannelMember,
        snLocalKeyPair,
        snLocalAccount,
        snLocalAttachment,
        snLocalSticker,
        snLocalStickerPack,
        snLocalRealm,
        idxChannelAlias,
        idxChatChannel,
        idxAccountName,
        idxAttachmentRid,
        idxAttachmentAccount,
        idxRealmAlias,
        idxRealmAccount
      ];
  @override
  int get schemaVersion => 4;
}
