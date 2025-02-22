// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SnLocalChatChannelTable extends SnLocalChatChannel
    with TableInfo<$SnLocalChatChannelTable, SnLocalChatChannelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnLocalChatChannelTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumnWithTypeConverter<SnChannel, Uint8List> content =
      GeneratedColumn<Uint8List>('content', aliasedName, false,
              type: DriftSqlType.blob, requiredDuringInsert: true)
          .withConverter<SnChannel>($SnLocalChatChannelTable.$convertercontent);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sn_local_chat_channel';
  @override
  VerificationContext validateIntegrity(
      Insertable<SnLocalChatChannelData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    context.handle(_contentMeta, const VerificationResult.success());
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SnLocalChatChannelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SnLocalChatChannelData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      content: $SnLocalChatChannelTable.$convertercontent.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.blob, data['${effectivePrefix}content'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SnLocalChatChannelTable createAlias(String alias) {
    return $SnLocalChatChannelTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SnChannel, Uint8List, Object?> $convertercontent =
      TypeConverter.jsonb(
          fromJson: (json) => SnChannel.fromJson(json as Map<String, Object?>),
          toJson: (pref) => pref.toJson());
}

class SnLocalChatChannelData extends DataClass
    implements Insertable<SnLocalChatChannelData> {
  final int id;
  final SnChannel content;
  final DateTime createdAt;
  const SnLocalChatChannelData(
      {required this.id, required this.content, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['content'] = Variable<Uint8List>(
          $SnLocalChatChannelTable.$convertercontent.toSql(content));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SnLocalChatChannelCompanion toCompanion(bool nullToAbsent) {
    return SnLocalChatChannelCompanion(
      id: Value(id),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory SnLocalChatChannelData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SnLocalChatChannelData(
      id: serializer.fromJson<int>(json['id']),
      content: $SnLocalChatChannelTable.$convertercontent
          .fromJson(serializer.fromJson<Object?>(json['content'])),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'content': serializer.toJson<Object?>(
          $SnLocalChatChannelTable.$convertercontent.toJson(content)),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SnLocalChatChannelData copyWith(
          {int? id, SnChannel? content, DateTime? createdAt}) =>
      SnLocalChatChannelData(
        id: id ?? this.id,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );
  SnLocalChatChannelData copyWithCompanion(SnLocalChatChannelCompanion data) {
    return SnLocalChatChannelData(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SnLocalChatChannelData(')
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
      (other is SnLocalChatChannelData &&
          other.id == this.id &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class SnLocalChatChannelCompanion
    extends UpdateCompanion<SnLocalChatChannelData> {
  final Value<int> id;
  final Value<SnChannel> content;
  final Value<DateTime> createdAt;
  const SnLocalChatChannelCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SnLocalChatChannelCompanion.insert({
    this.id = const Value.absent(),
    required SnChannel content,
    this.createdAt = const Value.absent(),
  }) : content = Value(content);
  static Insertable<SnLocalChatChannelData> custom({
    Expression<int>? id,
    Expression<Uint8List>? content,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SnLocalChatChannelCompanion copyWith(
      {Value<int>? id, Value<SnChannel>? content, Value<DateTime>? createdAt}) {
    return SnLocalChatChannelCompanion(
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
      map['content'] = Variable<Uint8List>(
          $SnLocalChatChannelTable.$convertercontent.toSql(content.value));
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
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SnLocalChatMessageTable extends SnLocalChatMessage
    with TableInfo<$SnLocalChatMessageTable, SnLocalChatMessageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnLocalChatMessageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _channelIdMeta =
      const VerificationMeta('channelId');
  @override
  late final GeneratedColumn<int> channelId = GeneratedColumn<int>(
      'channel_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumnWithTypeConverter<SnChatMessage, Uint8List>
      content = GeneratedColumn<Uint8List>('content', aliasedName, false,
              type: DriftSqlType.blob, requiredDuringInsert: true)
          .withConverter<SnChatMessage>(
              $SnLocalChatMessageTable.$convertercontent);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, channelId, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sn_local_chat_message';
  @override
  VerificationContext validateIntegrity(
      Insertable<SnLocalChatMessageData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('channel_id')) {
      context.handle(_channelIdMeta,
          channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta));
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    context.handle(_contentMeta, const VerificationResult.success());
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

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
      content: $SnLocalChatMessageTable.$convertercontent.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.blob, data['${effectivePrefix}content'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SnLocalChatMessageTable createAlias(String alias) {
    return $SnLocalChatMessageTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SnChatMessage, Uint8List, Object?>
      $convertercontent = TypeConverter.jsonb(
          fromJson: (json) =>
              SnChatMessage.fromJson(json as Map<String, Object?>),
          toJson: (pref) => pref.toJson());
}

class SnLocalChatMessageData extends DataClass
    implements Insertable<SnLocalChatMessageData> {
  final int id;
  final int channelId;
  final SnChatMessage content;
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
    {
      map['content'] = Variable<Uint8List>(
          $SnLocalChatMessageTable.$convertercontent.toSql(content));
    }
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
      content: $SnLocalChatMessageTable.$convertercontent
          .fromJson(serializer.fromJson<Object?>(json['content'])),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'channelId': serializer.toJson<int>(channelId),
      'content': serializer.toJson<Object?>(
          $SnLocalChatMessageTable.$convertercontent.toJson(content)),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SnLocalChatMessageData copyWith(
          {int? id,
          int? channelId,
          SnChatMessage? content,
          DateTime? createdAt}) =>
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
  final Value<SnChatMessage> content;
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
    required SnChatMessage content,
    this.createdAt = const Value.absent(),
  })  : channelId = Value(channelId),
        content = Value(content);
  static Insertable<SnLocalChatMessageData> custom({
    Expression<int>? id,
    Expression<int>? channelId,
    Expression<Uint8List>? content,
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
      Value<SnChatMessage>? content,
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
      map['content'] = Variable<Uint8List>(
          $SnLocalChatMessageTable.$convertercontent.toSql(content.value));
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SnLocalChatChannelTable snLocalChatChannel =
      $SnLocalChatChannelTable(this);
  late final $SnLocalChatMessageTable snLocalChatMessage =
      $SnLocalChatMessageTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [snLocalChatChannel, snLocalChatMessage];
}

typedef $$SnLocalChatChannelTableCreateCompanionBuilder
    = SnLocalChatChannelCompanion Function({
  Value<int> id,
  required SnChannel content,
  Value<DateTime> createdAt,
});
typedef $$SnLocalChatChannelTableUpdateCompanionBuilder
    = SnLocalChatChannelCompanion Function({
  Value<int> id,
  Value<SnChannel> content,
  Value<DateTime> createdAt,
});

class $$SnLocalChatChannelTableFilterComposer
    extends Composer<_$AppDatabase, $SnLocalChatChannelTable> {
  $$SnLocalChatChannelTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SnChannel, SnChannel, Uint8List> get content =>
      $composableBuilder(
          column: $table.content,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SnLocalChatChannelTableOrderingComposer
    extends Composer<_$AppDatabase, $SnLocalChatChannelTable> {
  $$SnLocalChatChannelTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SnLocalChatChannelTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnLocalChatChannelTable> {
  $$SnLocalChatChannelTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SnChannel, Uint8List> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SnLocalChatChannelTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SnLocalChatChannelTable,
    SnLocalChatChannelData,
    $$SnLocalChatChannelTableFilterComposer,
    $$SnLocalChatChannelTableOrderingComposer,
    $$SnLocalChatChannelTableAnnotationComposer,
    $$SnLocalChatChannelTableCreateCompanionBuilder,
    $$SnLocalChatChannelTableUpdateCompanionBuilder,
    (
      SnLocalChatChannelData,
      BaseReferences<_$AppDatabase, $SnLocalChatChannelTable,
          SnLocalChatChannelData>
    ),
    SnLocalChatChannelData,
    PrefetchHooks Function()> {
  $$SnLocalChatChannelTableTableManager(
      _$AppDatabase db, $SnLocalChatChannelTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnLocalChatChannelTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnLocalChatChannelTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnLocalChatChannelTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<SnChannel> content = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SnLocalChatChannelCompanion(
            id: id,
            content: content,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required SnChannel content,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SnLocalChatChannelCompanion.insert(
            id: id,
            content: content,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SnLocalChatChannelTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SnLocalChatChannelTable,
    SnLocalChatChannelData,
    $$SnLocalChatChannelTableFilterComposer,
    $$SnLocalChatChannelTableOrderingComposer,
    $$SnLocalChatChannelTableAnnotationComposer,
    $$SnLocalChatChannelTableCreateCompanionBuilder,
    $$SnLocalChatChannelTableUpdateCompanionBuilder,
    (
      SnLocalChatChannelData,
      BaseReferences<_$AppDatabase, $SnLocalChatChannelTable,
          SnLocalChatChannelData>
    ),
    SnLocalChatChannelData,
    PrefetchHooks Function()>;
typedef $$SnLocalChatMessageTableCreateCompanionBuilder
    = SnLocalChatMessageCompanion Function({
  Value<int> id,
  required int channelId,
  required SnChatMessage content,
  Value<DateTime> createdAt,
});
typedef $$SnLocalChatMessageTableUpdateCompanionBuilder
    = SnLocalChatMessageCompanion Function({
  Value<int> id,
  Value<int> channelId,
  Value<SnChatMessage> content,
  Value<DateTime> createdAt,
});

class $$SnLocalChatMessageTableFilterComposer
    extends Composer<_$AppDatabase, $SnLocalChatMessageTable> {
  $$SnLocalChatMessageTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get channelId => $composableBuilder(
      column: $table.channelId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SnChatMessage, SnChatMessage, Uint8List>
      get content => $composableBuilder(
          column: $table.content,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SnLocalChatMessageTableOrderingComposer
    extends Composer<_$AppDatabase, $SnLocalChatMessageTable> {
  $$SnLocalChatMessageTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get channelId => $composableBuilder(
      column: $table.channelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SnLocalChatMessageTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnLocalChatMessageTable> {
  $$SnLocalChatMessageTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SnChatMessage, Uint8List> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SnLocalChatMessageTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SnLocalChatMessageTable,
    SnLocalChatMessageData,
    $$SnLocalChatMessageTableFilterComposer,
    $$SnLocalChatMessageTableOrderingComposer,
    $$SnLocalChatMessageTableAnnotationComposer,
    $$SnLocalChatMessageTableCreateCompanionBuilder,
    $$SnLocalChatMessageTableUpdateCompanionBuilder,
    (
      SnLocalChatMessageData,
      BaseReferences<_$AppDatabase, $SnLocalChatMessageTable,
          SnLocalChatMessageData>
    ),
    SnLocalChatMessageData,
    PrefetchHooks Function()> {
  $$SnLocalChatMessageTableTableManager(
      _$AppDatabase db, $SnLocalChatMessageTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnLocalChatMessageTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnLocalChatMessageTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnLocalChatMessageTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> channelId = const Value.absent(),
            Value<SnChatMessage> content = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SnLocalChatMessageCompanion(
            id: id,
            channelId: channelId,
            content: content,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int channelId,
            required SnChatMessage content,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SnLocalChatMessageCompanion.insert(
            id: id,
            channelId: channelId,
            content: content,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SnLocalChatMessageTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SnLocalChatMessageTable,
    SnLocalChatMessageData,
    $$SnLocalChatMessageTableFilterComposer,
    $$SnLocalChatMessageTableOrderingComposer,
    $$SnLocalChatMessageTableAnnotationComposer,
    $$SnLocalChatMessageTableCreateCompanionBuilder,
    $$SnLocalChatMessageTableUpdateCompanionBuilder,
    (
      SnLocalChatMessageData,
      BaseReferences<_$AppDatabase, $SnLocalChatMessageTable,
          SnLocalChatMessageData>
    ),
    SnLocalChatMessageData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SnLocalChatChannelTableTableManager get snLocalChatChannel =>
      $$SnLocalChatChannelTableTableManager(_db, _db.snLocalChatChannel);
  $$SnLocalChatMessageTableTableManager get snLocalChatMessage =>
      $$SnLocalChatMessageTableTableManager(_db, _db.snLocalChatMessage);
}
