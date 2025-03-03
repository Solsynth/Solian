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
  List<GeneratedColumn> get $columns => [id, channelId, content, createdAt];
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
  final String content;
  final DateTime createdAt;
  const SnLocalChatMessageData(
      {required this.id,
      required this.channelId,
      required this.content,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['channel_id'] = Variable<int>(channelId);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SnLocalChatMessageCompanion toCompanion(bool nullToAbsent) {
    return SnLocalChatMessageCompanion(
      id: Value(id),
      channelId: Value(channelId),
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
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SnLocalChatMessageData copyWith(
          {int? id, int? channelId, String? content, DateTime? createdAt}) =>
      SnLocalChatMessageData(
        id: id ?? this.id,
        channelId: channelId ?? this.channelId,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );
  SnLocalChatMessageData copyWithCompanion(SnLocalChatMessageCompanion data) {
    return SnLocalChatMessageData(
      id: data.id.present ? data.id.value : this.id,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalChatMessageData(')
          ..write('id: $id, ')
          ..write('channelId: $channelId, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, channelId, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnLocalChatMessageData &&
          other.id == this.id &&
          other.channelId == this.channelId &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class SnLocalChatMessageCompanion
    extends UpdateCompanion<SnLocalChatMessageData> {
  final Value<int> id;
  final Value<int> channelId;
  final Value<String> content;
  final Value<DateTime> createdAt;
  const SnLocalChatMessageCompanion({
    this.id = const Value.absent(),
    this.channelId = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SnLocalChatMessageCompanion.insert({
    this.id = const Value.absent(),
    required int channelId,
    required String content,
    this.createdAt = const Value.absent(),
  })  : channelId = Value(channelId),
        content = Value(content);
  static Insertable<SnLocalChatMessageData> custom({
    Expression<int>? id,
    Expression<int>? channelId,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (channelId != null) 'channel_id': channelId,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SnLocalChatMessageCompanion copyWith(
      {Value<int>? id,
      Value<int>? channelId,
      Value<String>? content,
      Value<DateTime>? createdAt}) {
    return SnLocalChatMessageCompanion(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
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
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
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
  @override
  List<GeneratedColumn> get $columns => [id, accountId, publicKey, privateKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sn_local_key_pair';
  @override
  Set<GeneratedColumn> get $primaryKey => const {};
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
  const SnLocalKeyPairData(
      {required this.id,
      required this.accountId,
      required this.publicKey,
      this.privateKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<int>(accountId);
    map['public_key'] = Variable<String>(publicKey);
    if (!nullToAbsent || privateKey != null) {
      map['private_key'] = Variable<String>(privateKey);
    }
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
    };
  }

  SnLocalKeyPairData copyWith(
          {String? id,
          int? accountId,
          String? publicKey,
          Value<String?> privateKey = const Value.absent()}) =>
      SnLocalKeyPairData(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        publicKey: publicKey ?? this.publicKey,
        privateKey: privateKey.present ? privateKey.value : this.privateKey,
      );
  SnLocalKeyPairData copyWithCompanion(SnLocalKeyPairCompanion data) {
    return SnLocalKeyPairData(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      privateKey:
          data.privateKey.present ? data.privateKey.value : this.privateKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalKeyPairData(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('publicKey: $publicKey, ')
          ..write('privateKey: $privateKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accountId, publicKey, privateKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SnLocalKeyPairData &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.publicKey == this.publicKey &&
          other.privateKey == this.privateKey);
}

class SnLocalKeyPairCompanion extends UpdateCompanion<SnLocalKeyPairData> {
  final Value<String> id;
  final Value<int> accountId;
  final Value<String> publicKey;
  final Value<String?> privateKey;
  final Value<int> rowid;
  const SnLocalKeyPairCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.privateKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SnLocalKeyPairCompanion.insert({
    required String id,
    required int accountId,
    required String publicKey,
    this.privateKey = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        accountId = Value(accountId),
        publicKey = Value(publicKey);
  static Insertable<SnLocalKeyPairData> custom({
    Expression<String>? id,
    Expression<int>? accountId,
    Expression<String>? publicKey,
    Expression<String>? privateKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (publicKey != null) 'public_key': publicKey,
      if (privateKey != null) 'private_key': privateKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SnLocalKeyPairCompanion copyWith(
      {Value<String>? id,
      Value<int>? accountId,
      Value<String>? publicKey,
      Value<String?>? privateKey,
      Value<int>? rowid}) {
    return SnLocalKeyPairCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
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
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV2 extends GeneratedDatabase {
  DatabaseAtV2(QueryExecutor e) : super(e);
  late final SnLocalChatChannel snLocalChatChannel = SnLocalChatChannel(this);
  late final SnLocalChatMessage snLocalChatMessage = SnLocalChatMessage(this);
  late final SnLocalKeyPair snLocalKeyPair = SnLocalKeyPair(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [snLocalChatChannel, snLocalChatMessage, snLocalKeyPair];
  @override
  int get schemaVersion => 2;
}
