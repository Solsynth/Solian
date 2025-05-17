// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_db.dart';

// ignore_for_file: type=lint
class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nonceMeta = const VerificationMeta('nonce');
  @override
  late final GeneratedColumn<String> nonce = GeneratedColumn<String>(
    'nonce',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MessageStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<MessageStatus>($ChatMessagesTable.$converterstatus);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roomId,
    senderId,
    content,
    nonce,
    data,
    createdAt,
    status,
    isRead,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('nonce')) {
      context.handle(
        _nonceMeta,
        nonce.isAcceptableOrUnknown(data['nonce']!, _nonceMeta),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      roomId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}room_id'],
          )!,
      senderId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sender_id'],
          )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      nonce: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nonce'],
      ),
      data:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}data'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      status: $ChatMessagesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      isRead:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_read'],
          )!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MessageStatus, int, int> $converterstatus =
      const EnumIndexConverter<MessageStatus>(MessageStatus.values);
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final String id;
  final String roomId;
  final String senderId;
  final String? content;
  final String? nonce;
  final String data;
  final DateTime createdAt;
  final MessageStatus status;
  final bool isRead;
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.content,
    this.nonce,
    required this.data,
    required this.createdAt,
    required this.status,
    required this.isRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['room_id'] = Variable<String>(roomId);
    map['sender_id'] = Variable<String>(senderId);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || nonce != null) {
      map['nonce'] = Variable<String>(nonce);
    }
    map['data'] = Variable<String>(data);
    map['created_at'] = Variable<DateTime>(createdAt);
    {
      map['status'] = Variable<int>(
        $ChatMessagesTable.$converterstatus.toSql(status),
      );
    }
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      roomId: Value(roomId),
      senderId: Value(senderId),
      content:
          content == null && nullToAbsent
              ? const Value.absent()
              : Value(content),
      nonce:
          nonce == null && nullToAbsent ? const Value.absent() : Value(nonce),
      data: Value(data),
      createdAt: Value(createdAt),
      status: Value(status),
      isRead: Value(isRead),
    );
  }

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<String>(json['id']),
      roomId: serializer.fromJson<String>(json['roomId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      content: serializer.fromJson<String?>(json['content']),
      nonce: serializer.fromJson<String?>(json['nonce']),
      data: serializer.fromJson<String>(json['data']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: $ChatMessagesTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roomId': serializer.toJson<String>(roomId),
      'senderId': serializer.toJson<String>(senderId),
      'content': serializer.toJson<String?>(content),
      'nonce': serializer.toJson<String?>(nonce),
      'data': serializer.toJson<String>(data),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<int>(
        $ChatMessagesTable.$converterstatus.toJson(status),
      ),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? roomId,
    String? senderId,
    Value<String?> content = const Value.absent(),
    Value<String?> nonce = const Value.absent(),
    String? data,
    DateTime? createdAt,
    MessageStatus? status,
    bool? isRead,
  }) => ChatMessage(
    id: id ?? this.id,
    roomId: roomId ?? this.roomId,
    senderId: senderId ?? this.senderId,
    content: content.present ? content.value : this.content,
    nonce: nonce.present ? nonce.value : this.nonce,
    data: data ?? this.data,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    isRead: isRead ?? this.isRead,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      content: data.content.present ? data.content.value : this.content,
      nonce: data.nonce.present ? data.nonce.value : this.nonce,
      data: data.data.present ? data.data.value : this.data,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('nonce: $nonce, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    roomId,
    senderId,
    content,
    nonce,
    data,
    createdAt,
    status,
    isRead,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.senderId == this.senderId &&
          other.content == this.content &&
          other.nonce == this.nonce &&
          other.data == this.data &&
          other.createdAt == this.createdAt &&
          other.status == this.status &&
          other.isRead == this.isRead);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<String> id;
  final Value<String> roomId;
  final Value<String> senderId;
  final Value<String?> content;
  final Value<String?> nonce;
  final Value<String> data;
  final Value<DateTime> createdAt;
  final Value<MessageStatus> status;
  final Value<bool> isRead;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.content = const Value.absent(),
    this.nonce = const Value.absent(),
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String roomId,
    required String senderId,
    this.content = const Value.absent(),
    this.nonce = const Value.absent(),
    required String data,
    required DateTime createdAt,
    required MessageStatus status,
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       roomId = Value(roomId),
       senderId = Value(senderId),
       data = Value(data),
       createdAt = Value(createdAt),
       status = Value(status);
  static Insertable<ChatMessage> custom({
    Expression<String>? id,
    Expression<String>? roomId,
    Expression<String>? senderId,
    Expression<String>? content,
    Expression<String>? nonce,
    Expression<String>? data,
    Expression<DateTime>? createdAt,
    Expression<int>? status,
    Expression<bool>? isRead,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (senderId != null) 'sender_id': senderId,
      if (content != null) 'content': content,
      if (nonce != null) 'nonce': nonce,
      if (data != null) 'data': data,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
      if (isRead != null) 'is_read': isRead,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? roomId,
    Value<String>? senderId,
    Value<String?>? content,
    Value<String?>? nonce,
    Value<String>? data,
    Value<DateTime>? createdAt,
    Value<MessageStatus>? status,
    Value<bool>? isRead,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      nonce: nonce ?? this.nonce,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (nonce.present) {
      map['nonce'] = Variable<String>(nonce.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $ChatMessagesTable.$converterstatus.toSql(status.value),
      );
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('nonce: $nonce, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('isRead: $isRead, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [chatMessages];
}

typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      required String id,
      required String roomId,
      required String senderId,
      Value<String?> content,
      Value<String?> nonce,
      required String data,
      required DateTime createdAt,
      required MessageStatus status,
      Value<bool> isRead,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<String> id,
      Value<String> roomId,
      Value<String> senderId,
      Value<String?> content,
      Value<String?> nonce,
      Value<String> data,
      Value<DateTime> createdAt,
      Value<MessageStatus> status,
      Value<bool> isRead,
      Value<int> rowid,
    });

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nonce => $composableBuilder(
    column: $table.nonce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MessageStatus, MessageStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nonce => $composableBuilder(
    column: $table.nonce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get nonce =>
      $composableBuilder(column: $table.nonce, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (
            ChatMessage,
            BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
          ),
          ChatMessage,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> nonce = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<MessageStatus> status = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                roomId: roomId,
                senderId: senderId,
                content: content,
                nonce: nonce,
                data: data,
                createdAt: createdAt,
                status: status,
                isRead: isRead,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String roomId,
                required String senderId,
                Value<String?> content = const Value.absent(),
                Value<String?> nonce = const Value.absent(),
                required String data,
                required DateTime createdAt,
                required MessageStatus status,
                Value<bool> isRead = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                roomId: roomId,
                senderId: senderId,
                content: content,
                nonce: nonce,
                data: data,
                createdAt: createdAt,
                status: status,
                isRead: isRead,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (
        ChatMessage,
        BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage>,
      ),
      ChatMessage,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
}
