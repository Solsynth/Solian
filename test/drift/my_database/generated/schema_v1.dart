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

class DatabaseAtV1 extends GeneratedDatabase {
  DatabaseAtV1(QueryExecutor e) : super(e);
  late final SnLocalChatChannel snLocalChatChannel = SnLocalChatChannel(this);
  late final SnLocalChatMessage snLocalChatMessage = SnLocalChatMessage(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [snLocalChatChannel, snLocalChatMessage];
  @override
  int get schemaVersion => 1;
}
