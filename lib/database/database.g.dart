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
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
      'alias', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumnWithTypeConverter<SnChannel, String> content =
      GeneratedColumn<String>('content', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
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
  List<GeneratedColumn> get $columns => [id, alias, content, createdAt];
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
    if (data.containsKey('alias')) {
      context.handle(
          _aliasMeta, alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta));
    } else if (isInserting) {
      context.missing(_aliasMeta);
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
      alias: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alias'])!,
      content: $SnLocalChatChannelTable.$convertercontent.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}content'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SnLocalChatChannelTable createAlias(String alias) {
    return $SnLocalChatChannelTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SnChannel, String, Map<String, Object?>>
      $convertercontent = const SnChannelConverter();
}

class SnLocalChatChannelData extends DataClass
    implements Insertable<SnLocalChatChannelData> {
  final int id;
  final String alias;
  final SnChannel content;
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
    {
      map['content'] = Variable<String>(
          $SnLocalChatChannelTable.$convertercontent.toSql(content));
    }
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
      content: $SnLocalChatChannelTable.$convertercontent
          .fromJson(serializer.fromJson<Map<String, Object?>>(json['content'])),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'alias': serializer.toJson<String>(alias),
      'content': serializer.toJson<Map<String, Object?>>(
          $SnLocalChatChannelTable.$convertercontent.toJson(content)),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SnLocalChatChannelData copyWith(
          {int? id, String? alias, SnChannel? content, DateTime? createdAt}) =>
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
  final Value<SnChannel> content;
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
    required SnChannel content,
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
      Value<SnChannel>? content,
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
      map['content'] = Variable<String>(
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
          ..write('alias: $alias, ')
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
  late final GeneratedColumnWithTypeConverter<SnChatMessage, String> content =
      GeneratedColumn<String>('content', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
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
              .read(DriftSqlType.string, data['${effectivePrefix}content'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SnLocalChatMessageTable createAlias(String alias) {
    return $SnLocalChatMessageTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SnChatMessage, String, Map<String, Object?>>
      $convertercontent = const SnMessageConverter();
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
      map['content'] = Variable<String>(
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
          .fromJson(serializer.fromJson<Map<String, Object?>>(json['content'])),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'channelId': serializer.toJson<int>(channelId),
      'content': serializer.toJson<Map<String, Object?>>(
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
      map['content'] = Variable<String>(
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

class $SnLocalKeyPairTable extends SnLocalKeyPair
    with TableInfo<$SnLocalKeyPairTable, SnLocalKeyPairData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnLocalKeyPairTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _publicKeyMeta =
      const VerificationMeta('publicKey');
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
      'public_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _privateKeyMeta =
      const VerificationMeta('privateKey');
  @override
  late final GeneratedColumn<String> privateKey = GeneratedColumn<String>(
      'private_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, accountId, publicKey, privateKey, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sn_local_key_pair';
  @override
  VerificationContext validateIntegrity(Insertable<SnLocalKeyPairData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(_publicKeyMeta,
          publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta));
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('private_key')) {
      context.handle(
          _privateKeyMeta,
          privateKey.isAcceptableOrUnknown(
              data['private_key']!, _privateKeyMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

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
  $SnLocalKeyPairTable createAlias(String alias) {
    return $SnLocalKeyPairTable(attachedDatabase, alias);
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SnLocalChatChannelTable snLocalChatChannel =
      $SnLocalChatChannelTable(this);
  late final $SnLocalChatMessageTable snLocalChatMessage =
      $SnLocalChatMessageTable(this);
  late final $SnLocalKeyPairTable snLocalKeyPair = $SnLocalKeyPairTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [snLocalChatChannel, snLocalChatMessage, snLocalKeyPair];
}

typedef $$SnLocalChatChannelTableCreateCompanionBuilder
    = SnLocalChatChannelCompanion Function({
  Value<int> id,
  required String alias,
  required SnChannel content,
  Value<DateTime> createdAt,
});
typedef $$SnLocalChatChannelTableUpdateCompanionBuilder
    = SnLocalChatChannelCompanion Function({
  Value<int> id,
  Value<String> alias,
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

  ColumnFilters<String> get alias => $composableBuilder(
      column: $table.alias, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SnChannel, SnChannel, String> get content =>
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

  ColumnOrderings<String> get alias => $composableBuilder(
      column: $table.alias, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
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

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SnChannel, String> get content =>
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
            Value<String> alias = const Value.absent(),
            Value<SnChannel> content = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SnLocalChatChannelCompanion(
            id: id,
            alias: alias,
            content: content,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String alias,
            required SnChannel content,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SnLocalChatChannelCompanion.insert(
            id: id,
            alias: alias,
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

  ColumnWithTypeConverterFilters<SnChatMessage, SnChatMessage, String>
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

  ColumnOrderings<String> get content => $composableBuilder(
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

  GeneratedColumnWithTypeConverter<SnChatMessage, String> get content =>
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
typedef $$SnLocalKeyPairTableCreateCompanionBuilder = SnLocalKeyPairCompanion
    Function({
  required String id,
  required int accountId,
  required String publicKey,
  Value<String?> privateKey,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$SnLocalKeyPairTableUpdateCompanionBuilder = SnLocalKeyPairCompanion
    Function({
  Value<String> id,
  Value<int> accountId,
  Value<String> publicKey,
  Value<String?> privateKey,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$SnLocalKeyPairTableFilterComposer
    extends Composer<_$AppDatabase, $SnLocalKeyPairTable> {
  $$SnLocalKeyPairTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get publicKey => $composableBuilder(
      column: $table.publicKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get privateKey => $composableBuilder(
      column: $table.privateKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$SnLocalKeyPairTableOrderingComposer
    extends Composer<_$AppDatabase, $SnLocalKeyPairTable> {
  $$SnLocalKeyPairTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get publicKey => $composableBuilder(
      column: $table.publicKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get privateKey => $composableBuilder(
      column: $table.privateKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$SnLocalKeyPairTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnLocalKeyPairTable> {
  $$SnLocalKeyPairTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get privateKey => $composableBuilder(
      column: $table.privateKey, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$SnLocalKeyPairTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SnLocalKeyPairTable,
    SnLocalKeyPairData,
    $$SnLocalKeyPairTableFilterComposer,
    $$SnLocalKeyPairTableOrderingComposer,
    $$SnLocalKeyPairTableAnnotationComposer,
    $$SnLocalKeyPairTableCreateCompanionBuilder,
    $$SnLocalKeyPairTableUpdateCompanionBuilder,
    (
      SnLocalKeyPairData,
      BaseReferences<_$AppDatabase, $SnLocalKeyPairTable, SnLocalKeyPairData>
    ),
    SnLocalKeyPairData,
    PrefetchHooks Function()> {
  $$SnLocalKeyPairTableTableManager(
      _$AppDatabase db, $SnLocalKeyPairTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnLocalKeyPairTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnLocalKeyPairTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnLocalKeyPairTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> accountId = const Value.absent(),
            Value<String> publicKey = const Value.absent(),
            Value<String?> privateKey = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SnLocalKeyPairCompanion(
            id: id,
            accountId: accountId,
            publicKey: publicKey,
            privateKey: privateKey,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int accountId,
            required String publicKey,
            Value<String?> privateKey = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SnLocalKeyPairCompanion.insert(
            id: id,
            accountId: accountId,
            publicKey: publicKey,
            privateKey: privateKey,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SnLocalKeyPairTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SnLocalKeyPairTable,
    SnLocalKeyPairData,
    $$SnLocalKeyPairTableFilterComposer,
    $$SnLocalKeyPairTableOrderingComposer,
    $$SnLocalKeyPairTableAnnotationComposer,
    $$SnLocalKeyPairTableCreateCompanionBuilder,
    $$SnLocalKeyPairTableUpdateCompanionBuilder,
    (
      SnLocalKeyPairData,
      BaseReferences<_$AppDatabase, $SnLocalKeyPairTable, SnLocalKeyPairData>
    ),
    SnLocalKeyPairData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SnLocalChatChannelTableTableManager get snLocalChatChannel =>
      $$SnLocalChatChannelTableTableManager(_db, _db.snLocalChatChannel);
  $$SnLocalChatMessageTableTableManager get snLocalChatMessage =>
      $$SnLocalChatMessageTableTableManager(_db, _db.snLocalChatMessage);
  $$SnLocalKeyPairTableTableManager get snLocalKeyPair =>
      $$SnLocalKeyPairTableTableManager(_db, _db.snLocalKeyPair);
}
