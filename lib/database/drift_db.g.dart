// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_db.dart';

// ignore_for_file: type=lint
class $ChatRoomsTable extends ChatRooms
    with TableInfo<$ChatRoomsTable, ChatRoom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatRoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPublicMeta = const VerificationMeta(
    'isPublic',
  );
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
    'is_public',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_public" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCommunityMeta = const VerificationMeta(
    'isCommunity',
  );
  @override
  late final GeneratedColumn<bool> isCommunity = GeneratedColumn<bool>(
    'is_community',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_community" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
  picture = GeneratedColumn<String>(
    'picture',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Map<String, dynamic>?>($ChatRoomsTable.$converterpicturen);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
  background = GeneratedColumn<String>(
    'background',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Map<String, dynamic>?>($ChatRoomsTable.$converterbackgroundn);
  static const VerificationMeta _realmIdMeta = const VerificationMeta(
    'realmId',
  );
  @override
  late final GeneratedColumn<String> realmId = GeneratedColumn<String>(
    'realm_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    type,
    isPublic,
    isCommunity,
    picture,
    background,
    realmId,
    accountId,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatRoom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_public')) {
      context.handle(
        _isPublicMeta,
        isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta),
      );
    }
    if (data.containsKey('is_community')) {
      context.handle(
        _isCommunityMeta,
        isCommunity.isAcceptableOrUnknown(
          data['is_community']!,
          _isCommunityMeta,
        ),
      );
    }
    if (data.containsKey('realm_id')) {
      context.handle(
        _realmIdMeta,
        realmId.isAcceptableOrUnknown(data['realm_id']!, _realmIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatRoom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatRoom(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      isPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_public'],
      ),
      isCommunity: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_community'],
      ),
      picture: $ChatRoomsTable.$converterpicturen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}picture'],
        ),
      ),
      background: $ChatRoomsTable.$converterbackgroundn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}background'],
        ),
      ),
      realmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}realm_id'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ChatRoomsTable createAlias(String alias) {
    return $ChatRoomsTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterpicture =
      const MapConverter();
  static TypeConverter<Map<String, dynamic>?, String?> $converterpicturen =
      NullAwareTypeConverter.wrap($converterpicture);
  static TypeConverter<Map<String, dynamic>, String> $converterbackground =
      const MapConverter();
  static TypeConverter<Map<String, dynamic>?, String?> $converterbackgroundn =
      NullAwareTypeConverter.wrap($converterbackground);
}

class ChatRoom extends DataClass implements Insertable<ChatRoom> {
  final String id;
  final String? name;
  final String? description;
  final int type;
  final bool? isPublic;
  final bool? isCommunity;
  final Map<String, dynamic>? picture;
  final Map<String, dynamic>? background;
  final String? realmId;
  final String? accountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ChatRoom({
    required this.id,
    this.name,
    this.description,
    required this.type,
    this.isPublic,
    this.isCommunity,
    this.picture,
    this.background,
    this.realmId,
    this.accountId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || isPublic != null) {
      map['is_public'] = Variable<bool>(isPublic);
    }
    if (!nullToAbsent || isCommunity != null) {
      map['is_community'] = Variable<bool>(isCommunity);
    }
    if (!nullToAbsent || picture != null) {
      map['picture'] = Variable<String>(
        $ChatRoomsTable.$converterpicturen.toSql(picture),
      );
    }
    if (!nullToAbsent || background != null) {
      map['background'] = Variable<String>(
        $ChatRoomsTable.$converterbackgroundn.toSql(background),
      );
    }
    if (!nullToAbsent || realmId != null) {
      map['realm_id'] = Variable<String>(realmId);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ChatRoomsCompanion toCompanion(bool nullToAbsent) {
    return ChatRoomsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      type: Value(type),
      isPublic: isPublic == null && nullToAbsent
          ? const Value.absent()
          : Value(isPublic),
      isCommunity: isCommunity == null && nullToAbsent
          ? const Value.absent()
          : Value(isCommunity),
      picture: picture == null && nullToAbsent
          ? const Value.absent()
          : Value(picture),
      background: background == null && nullToAbsent
          ? const Value.absent()
          : Value(background),
      realmId: realmId == null && nullToAbsent
          ? const Value.absent()
          : Value(realmId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ChatRoom.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatRoom(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      type: serializer.fromJson<int>(json['type']),
      isPublic: serializer.fromJson<bool?>(json['isPublic']),
      isCommunity: serializer.fromJson<bool?>(json['isCommunity']),
      picture: serializer.fromJson<Map<String, dynamic>?>(json['picture']),
      background: serializer.fromJson<Map<String, dynamic>?>(
        json['background'],
      ),
      realmId: serializer.fromJson<String?>(json['realmId']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'description': serializer.toJson<String?>(description),
      'type': serializer.toJson<int>(type),
      'isPublic': serializer.toJson<bool?>(isPublic),
      'isCommunity': serializer.toJson<bool?>(isCommunity),
      'picture': serializer.toJson<Map<String, dynamic>?>(picture),
      'background': serializer.toJson<Map<String, dynamic>?>(background),
      'realmId': serializer.toJson<String?>(realmId),
      'accountId': serializer.toJson<String?>(accountId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ChatRoom copyWith({
    String? id,
    Value<String?> name = const Value.absent(),
    Value<String?> description = const Value.absent(),
    int? type,
    Value<bool?> isPublic = const Value.absent(),
    Value<bool?> isCommunity = const Value.absent(),
    Value<Map<String, dynamic>?> picture = const Value.absent(),
    Value<Map<String, dynamic>?> background = const Value.absent(),
    Value<String?> realmId = const Value.absent(),
    Value<String?> accountId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ChatRoom(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    description: description.present ? description.value : this.description,
    type: type ?? this.type,
    isPublic: isPublic.present ? isPublic.value : this.isPublic,
    isCommunity: isCommunity.present ? isCommunity.value : this.isCommunity,
    picture: picture.present ? picture.value : this.picture,
    background: background.present ? background.value : this.background,
    realmId: realmId.present ? realmId.value : this.realmId,
    accountId: accountId.present ? accountId.value : this.accountId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ChatRoom copyWithCompanion(ChatRoomsCompanion data) {
    return ChatRoom(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      isCommunity: data.isCommunity.present
          ? data.isCommunity.value
          : this.isCommunity,
      picture: data.picture.present ? data.picture.value : this.picture,
      background: data.background.present
          ? data.background.value
          : this.background,
      realmId: data.realmId.present ? data.realmId.value : this.realmId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatRoom(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('isPublic: $isPublic, ')
          ..write('isCommunity: $isCommunity, ')
          ..write('picture: $picture, ')
          ..write('background: $background, ')
          ..write('realmId: $realmId, ')
          ..write('accountId: $accountId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    type,
    isPublic,
    isCommunity,
    picture,
    background,
    realmId,
    accountId,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatRoom &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.type == this.type &&
          other.isPublic == this.isPublic &&
          other.isCommunity == this.isCommunity &&
          other.picture == this.picture &&
          other.background == this.background &&
          other.realmId == this.realmId &&
          other.accountId == this.accountId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ChatRoomsCompanion extends UpdateCompanion<ChatRoom> {
  final Value<String> id;
  final Value<String?> name;
  final Value<String?> description;
  final Value<int> type;
  final Value<bool?> isPublic;
  final Value<bool?> isCommunity;
  final Value<Map<String, dynamic>?> picture;
  final Value<Map<String, dynamic>?> background;
  final Value<String?> realmId;
  final Value<String?> accountId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ChatRoomsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.isCommunity = const Value.absent(),
    this.picture = const Value.absent(),
    this.background = const Value.absent(),
    this.realmId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatRoomsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    required int type,
    this.isPublic = const Value.absent(),
    this.isCommunity = const Value.absent(),
    this.picture = const Value.absent(),
    this.background = const Value.absent(),
    this.realmId = const Value.absent(),
    this.accountId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChatRoom> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? type,
    Expression<bool>? isPublic,
    Expression<bool>? isCommunity,
    Expression<String>? picture,
    Expression<String>? background,
    Expression<String>? realmId,
    Expression<String>? accountId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (isPublic != null) 'is_public': isPublic,
      if (isCommunity != null) 'is_community': isCommunity,
      if (picture != null) 'picture': picture,
      if (background != null) 'background': background,
      if (realmId != null) 'realm_id': realmId,
      if (accountId != null) 'account_id': accountId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatRoomsCompanion copyWith({
    Value<String>? id,
    Value<String?>? name,
    Value<String?>? description,
    Value<int>? type,
    Value<bool?>? isPublic,
    Value<bool?>? isCommunity,
    Value<Map<String, dynamic>?>? picture,
    Value<Map<String, dynamic>?>? background,
    Value<String?>? realmId,
    Value<String?>? accountId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ChatRoomsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      isPublic: isPublic ?? this.isPublic,
      isCommunity: isCommunity ?? this.isCommunity,
      picture: picture ?? this.picture,
      background: background ?? this.background,
      realmId: realmId ?? this.realmId,
      accountId: accountId ?? this.accountId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    if (isCommunity.present) {
      map['is_community'] = Variable<bool>(isCommunity.value);
    }
    if (picture.present) {
      map['picture'] = Variable<String>(
        $ChatRoomsTable.$converterpicturen.toSql(picture.value),
      );
    }
    if (background.present) {
      map['background'] = Variable<String>(
        $ChatRoomsTable.$converterbackgroundn.toSql(background.value),
      );
    }
    if (realmId.present) {
      map['realm_id'] = Variable<String>(realmId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatRoomsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('isPublic: $isPublic, ')
          ..write('isCommunity: $isCommunity, ')
          ..write('picture: $picture, ')
          ..write('background: $background, ')
          ..write('realmId: $realmId, ')
          ..write('accountId: $accountId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMembersTable extends ChatMembers
    with TableInfo<$ChatMembersTable, ChatMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chatRoomIdMeta = const VerificationMeta(
    'chatRoomId',
  );
  @override
  late final GeneratedColumn<String> chatRoomId = GeneratedColumn<String>(
    'chat_room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_rooms (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  account = GeneratedColumn<String>(
    'account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, dynamic>>($ChatMembersTable.$converteraccount);
  static const VerificationMeta _nickMeta = const VerificationMeta('nick');
  @override
  late final GeneratedColumn<String> nick = GeneratedColumn<String>(
    'nick',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notifyMeta = const VerificationMeta('notify');
  @override
  late final GeneratedColumn<int> notify = GeneratedColumn<int>(
    'notify',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breakUntilMeta = const VerificationMeta(
    'breakUntil',
  );
  @override
  late final GeneratedColumn<DateTime> breakUntil = GeneratedColumn<DateTime>(
    'break_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeoutUntilMeta = const VerificationMeta(
    'timeoutUntil',
  );
  @override
  late final GeneratedColumn<DateTime> timeoutUntil = GeneratedColumn<DateTime>(
    'timeout_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    chatRoomId,
    accountId,
    account,
    nick,
    notify,
    joinedAt,
    breakUntil,
    timeoutUntil,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chat_room_id')) {
      context.handle(
        _chatRoomIdMeta,
        chatRoomId.isAcceptableOrUnknown(
          data['chat_room_id']!,
          _chatRoomIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chatRoomIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('nick')) {
      context.handle(
        _nickMeta,
        nick.isAcceptableOrUnknown(data['nick']!, _nickMeta),
      );
    }
    if (data.containsKey('notify')) {
      context.handle(
        _notifyMeta,
        notify.isAcceptableOrUnknown(data['notify']!, _notifyMeta),
      );
    } else if (isInserting) {
      context.missing(_notifyMeta);
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    if (data.containsKey('break_until')) {
      context.handle(
        _breakUntilMeta,
        breakUntil.isAcceptableOrUnknown(data['break_until']!, _breakUntilMeta),
      );
    }
    if (data.containsKey('timeout_until')) {
      context.handle(
        _timeoutUntilMeta,
        timeoutUntil.isAcceptableOrUnknown(
          data['timeout_until']!,
          _timeoutUntilMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      chatRoomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chat_room_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      account: $ChatMembersTable.$converteraccount.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}account'],
        )!,
      ),
      nick: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nick'],
      ),
      notify: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notify'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      ),
      breakUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}break_until'],
      ),
      timeoutUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timeout_until'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ChatMembersTable createAlias(String alias) {
    return $ChatMembersTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converteraccount =
      const MapConverter();
}

class ChatMember extends DataClass implements Insertable<ChatMember> {
  final String id;
  final String chatRoomId;
  final String accountId;
  final Map<String, dynamic> account;
  final String? nick;
  final int notify;
  final DateTime? joinedAt;
  final DateTime? breakUntil;
  final DateTime? timeoutUntil;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ChatMember({
    required this.id,
    required this.chatRoomId,
    required this.accountId,
    required this.account,
    this.nick,
    required this.notify,
    this.joinedAt,
    this.breakUntil,
    this.timeoutUntil,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chat_room_id'] = Variable<String>(chatRoomId);
    map['account_id'] = Variable<String>(accountId);
    {
      map['account'] = Variable<String>(
        $ChatMembersTable.$converteraccount.toSql(account),
      );
    }
    if (!nullToAbsent || nick != null) {
      map['nick'] = Variable<String>(nick);
    }
    map['notify'] = Variable<int>(notify);
    if (!nullToAbsent || joinedAt != null) {
      map['joined_at'] = Variable<DateTime>(joinedAt);
    }
    if (!nullToAbsent || breakUntil != null) {
      map['break_until'] = Variable<DateTime>(breakUntil);
    }
    if (!nullToAbsent || timeoutUntil != null) {
      map['timeout_until'] = Variable<DateTime>(timeoutUntil);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ChatMembersCompanion toCompanion(bool nullToAbsent) {
    return ChatMembersCompanion(
      id: Value(id),
      chatRoomId: Value(chatRoomId),
      accountId: Value(accountId),
      account: Value(account),
      nick: nick == null && nullToAbsent ? const Value.absent() : Value(nick),
      notify: Value(notify),
      joinedAt: joinedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(joinedAt),
      breakUntil: breakUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(breakUntil),
      timeoutUntil: timeoutUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(timeoutUntil),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ChatMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMember(
      id: serializer.fromJson<String>(json['id']),
      chatRoomId: serializer.fromJson<String>(json['chatRoomId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      account: serializer.fromJson<Map<String, dynamic>>(json['account']),
      nick: serializer.fromJson<String?>(json['nick']),
      notify: serializer.fromJson<int>(json['notify']),
      joinedAt: serializer.fromJson<DateTime?>(json['joinedAt']),
      breakUntil: serializer.fromJson<DateTime?>(json['breakUntil']),
      timeoutUntil: serializer.fromJson<DateTime?>(json['timeoutUntil']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chatRoomId': serializer.toJson<String>(chatRoomId),
      'accountId': serializer.toJson<String>(accountId),
      'account': serializer.toJson<Map<String, dynamic>>(account),
      'nick': serializer.toJson<String?>(nick),
      'notify': serializer.toJson<int>(notify),
      'joinedAt': serializer.toJson<DateTime?>(joinedAt),
      'breakUntil': serializer.toJson<DateTime?>(breakUntil),
      'timeoutUntil': serializer.toJson<DateTime?>(timeoutUntil),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ChatMember copyWith({
    String? id,
    String? chatRoomId,
    String? accountId,
    Map<String, dynamic>? account,
    Value<String?> nick = const Value.absent(),
    int? notify,
    Value<DateTime?> joinedAt = const Value.absent(),
    Value<DateTime?> breakUntil = const Value.absent(),
    Value<DateTime?> timeoutUntil = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ChatMember(
    id: id ?? this.id,
    chatRoomId: chatRoomId ?? this.chatRoomId,
    accountId: accountId ?? this.accountId,
    account: account ?? this.account,
    nick: nick.present ? nick.value : this.nick,
    notify: notify ?? this.notify,
    joinedAt: joinedAt.present ? joinedAt.value : this.joinedAt,
    breakUntil: breakUntil.present ? breakUntil.value : this.breakUntil,
    timeoutUntil: timeoutUntil.present ? timeoutUntil.value : this.timeoutUntil,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ChatMember copyWithCompanion(ChatMembersCompanion data) {
    return ChatMember(
      id: data.id.present ? data.id.value : this.id,
      chatRoomId: data.chatRoomId.present
          ? data.chatRoomId.value
          : this.chatRoomId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      account: data.account.present ? data.account.value : this.account,
      nick: data.nick.present ? data.nick.value : this.nick,
      notify: data.notify.present ? data.notify.value : this.notify,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      breakUntil: data.breakUntil.present
          ? data.breakUntil.value
          : this.breakUntil,
      timeoutUntil: data.timeoutUntil.present
          ? data.timeoutUntil.value
          : this.timeoutUntil,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMember(')
          ..write('id: $id, ')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('accountId: $accountId, ')
          ..write('account: $account, ')
          ..write('nick: $nick, ')
          ..write('notify: $notify, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('breakUntil: $breakUntil, ')
          ..write('timeoutUntil: $timeoutUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    chatRoomId,
    accountId,
    account,
    nick,
    notify,
    joinedAt,
    breakUntil,
    timeoutUntil,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMember &&
          other.id == this.id &&
          other.chatRoomId == this.chatRoomId &&
          other.accountId == this.accountId &&
          other.account == this.account &&
          other.nick == this.nick &&
          other.notify == this.notify &&
          other.joinedAt == this.joinedAt &&
          other.breakUntil == this.breakUntil &&
          other.timeoutUntil == this.timeoutUntil &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ChatMembersCompanion extends UpdateCompanion<ChatMember> {
  final Value<String> id;
  final Value<String> chatRoomId;
  final Value<String> accountId;
  final Value<Map<String, dynamic>> account;
  final Value<String?> nick;
  final Value<int> notify;
  final Value<DateTime?> joinedAt;
  final Value<DateTime?> breakUntil;
  final Value<DateTime?> timeoutUntil;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ChatMembersCompanion({
    this.id = const Value.absent(),
    this.chatRoomId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.account = const Value.absent(),
    this.nick = const Value.absent(),
    this.notify = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.breakUntil = const Value.absent(),
    this.timeoutUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMembersCompanion.insert({
    required String id,
    required String chatRoomId,
    required String accountId,
    required Map<String, dynamic> account,
    this.nick = const Value.absent(),
    required int notify,
    this.joinedAt = const Value.absent(),
    this.breakUntil = const Value.absent(),
    this.timeoutUntil = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       chatRoomId = Value(chatRoomId),
       accountId = Value(accountId),
       account = Value(account),
       notify = Value(notify),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChatMember> custom({
    Expression<String>? id,
    Expression<String>? chatRoomId,
    Expression<String>? accountId,
    Expression<String>? account,
    Expression<String>? nick,
    Expression<int>? notify,
    Expression<DateTime>? joinedAt,
    Expression<DateTime>? breakUntil,
    Expression<DateTime>? timeoutUntil,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatRoomId != null) 'chat_room_id': chatRoomId,
      if (accountId != null) 'account_id': accountId,
      if (account != null) 'account': account,
      if (nick != null) 'nick': nick,
      if (notify != null) 'notify': notify,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (breakUntil != null) 'break_until': breakUntil,
      if (timeoutUntil != null) 'timeout_until': timeoutUntil,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? chatRoomId,
    Value<String>? accountId,
    Value<Map<String, dynamic>>? account,
    Value<String?>? nick,
    Value<int>? notify,
    Value<DateTime?>? joinedAt,
    Value<DateTime?>? breakUntil,
    Value<DateTime?>? timeoutUntil,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ChatMembersCompanion(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      accountId: accountId ?? this.accountId,
      account: account ?? this.account,
      nick: nick ?? this.nick,
      notify: notify ?? this.notify,
      joinedAt: joinedAt ?? this.joinedAt,
      breakUntil: breakUntil ?? this.breakUntil,
      timeoutUntil: timeoutUntil ?? this.timeoutUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chatRoomId.present) {
      map['chat_room_id'] = Variable<String>(chatRoomId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (account.present) {
      map['account'] = Variable<String>(
        $ChatMembersTable.$converteraccount.toSql(account.value),
      );
    }
    if (nick.present) {
      map['nick'] = Variable<String>(nick.value);
    }
    if (notify.present) {
      map['notify'] = Variable<int>(notify.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (breakUntil.present) {
      map['break_until'] = Variable<DateTime>(breakUntil.value);
    }
    if (timeoutUntil.present) {
      map['timeout_until'] = Variable<DateTime>(timeoutUntil.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMembersCompanion(')
          ..write('id: $id, ')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('accountId: $accountId, ')
          ..write('account: $account, ')
          ..write('nick: $nick, ')
          ..write('notify: $notify, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('breakUntil: $breakUntil, ')
          ..write('timeoutUntil: $timeoutUntil, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_rooms (id)',
    ),
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES chat_members (id)',
    ),
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
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  meta = GeneratedColumn<String>(
    'meta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  ).withConverter<Map<String, dynamic>>($ChatMessagesTable.$convertermeta);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  membersMentioned = GeneratedColumn<String>(
    'members_mentioned',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($ChatMessagesTable.$convertermembersMentioned);
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<
    List<Map<String, dynamic>>,
    String
  >
  attachments =
      GeneratedColumn<String>(
        'attachments',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<Map<String, dynamic>>>(
        $ChatMessagesTable.$converterattachments,
      );
  @override
  late final GeneratedColumnWithTypeConverter<
    List<Map<String, dynamic>>,
    String
  >
  reactions =
      GeneratedColumn<String>(
        'reactions',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<Map<String, dynamic>>>(
        $ChatMessagesTable.$converterreactions,
      );
  static const VerificationMeta _repliedMessageIdMeta = const VerificationMeta(
    'repliedMessageId',
  );
  @override
  late final GeneratedColumn<String> repliedMessageId = GeneratedColumn<String>(
    'replied_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _forwardedMessageIdMeta =
      const VerificationMeta('forwardedMessageId');
  @override
  late final GeneratedColumn<String> forwardedMessageId =
      GeneratedColumn<String>(
        'forwarded_message_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
    isDeleted,
    updatedAt,
    deletedAt,
    type,
    meta,
    membersMentioned,
    editedAt,
    attachments,
    reactions,
    repliedMessageId,
    forwardedMessageId,
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
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    }
    if (data.containsKey('replied_message_id')) {
      context.handle(
        _repliedMessageIdMeta,
        repliedMessageId.isAcceptableOrUnknown(
          data['replied_message_id']!,
          _repliedMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('forwarded_message_id')) {
      context.handle(
        _forwardedMessageIdMeta,
        forwardedMessageId.isAcceptableOrUnknown(
          data['forwarded_message_id']!,
          _forwardedMessageIdMeta,
        ),
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
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
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      status: $ChatMessagesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      meta: $ChatMessagesTable.$convertermeta.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}meta'],
        )!,
      ),
      membersMentioned: $ChatMessagesTable.$convertermembersMentioned.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}members_mentioned'],
        )!,
      ),
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}edited_at'],
      ),
      attachments: $ChatMessagesTable.$converterattachments.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}attachments'],
        )!,
      ),
      reactions: $ChatMessagesTable.$converterreactions.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reactions'],
        )!,
      ),
      repliedMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}replied_message_id'],
      ),
      forwardedMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}forwarded_message_id'],
      ),
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MessageStatus, int, int> $converterstatus =
      const EnumIndexConverter<MessageStatus>(MessageStatus.values);
  static TypeConverter<Map<String, dynamic>, String> $convertermeta =
      const MapConverter();
  static TypeConverter<List<String>, String> $convertermembersMentioned =
      const ListStringConverter();
  static TypeConverter<List<Map<String, dynamic>>, String>
  $converterattachments = const ListMapConverter();
  static TypeConverter<List<Map<String, dynamic>>, String> $converterreactions =
      const ListMapConverter();
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
  final bool? isDeleted;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String type;
  final Map<String, dynamic> meta;
  final List<String> membersMentioned;
  final DateTime? editedAt;
  final List<Map<String, dynamic>> attachments;
  final List<Map<String, dynamic>> reactions;
  final String? repliedMessageId;
  final String? forwardedMessageId;
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.content,
    this.nonce,
    required this.data,
    required this.createdAt,
    required this.status,
    this.isDeleted,
    this.updatedAt,
    this.deletedAt,
    required this.type,
    required this.meta,
    required this.membersMentioned,
    this.editedAt,
    required this.attachments,
    required this.reactions,
    this.repliedMessageId,
    this.forwardedMessageId,
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
    if (!nullToAbsent || isDeleted != null) {
      map['is_deleted'] = Variable<bool>(isDeleted);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['type'] = Variable<String>(type);
    {
      map['meta'] = Variable<String>(
        $ChatMessagesTable.$convertermeta.toSql(meta),
      );
    }
    {
      map['members_mentioned'] = Variable<String>(
        $ChatMessagesTable.$convertermembersMentioned.toSql(membersMentioned),
      );
    }
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<DateTime>(editedAt);
    }
    {
      map['attachments'] = Variable<String>(
        $ChatMessagesTable.$converterattachments.toSql(attachments),
      );
    }
    {
      map['reactions'] = Variable<String>(
        $ChatMessagesTable.$converterreactions.toSql(reactions),
      );
    }
    if (!nullToAbsent || repliedMessageId != null) {
      map['replied_message_id'] = Variable<String>(repliedMessageId);
    }
    if (!nullToAbsent || forwardedMessageId != null) {
      map['forwarded_message_id'] = Variable<String>(forwardedMessageId);
    }
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      roomId: Value(roomId),
      senderId: Value(senderId),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      nonce: nonce == null && nullToAbsent
          ? const Value.absent()
          : Value(nonce),
      data: Value(data),
      createdAt: Value(createdAt),
      status: Value(status),
      isDeleted: isDeleted == null && nullToAbsent
          ? const Value.absent()
          : Value(isDeleted),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      type: Value(type),
      meta: Value(meta),
      membersMentioned: Value(membersMentioned),
      editedAt: editedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editedAt),
      attachments: Value(attachments),
      reactions: Value(reactions),
      repliedMessageId: repliedMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(repliedMessageId),
      forwardedMessageId: forwardedMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(forwardedMessageId),
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
      isDeleted: serializer.fromJson<bool?>(json['isDeleted']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      type: serializer.fromJson<String>(json['type']),
      meta: serializer.fromJson<Map<String, dynamic>>(json['meta']),
      membersMentioned: serializer.fromJson<List<String>>(
        json['membersMentioned'],
      ),
      editedAt: serializer.fromJson<DateTime?>(json['editedAt']),
      attachments: serializer.fromJson<List<Map<String, dynamic>>>(
        json['attachments'],
      ),
      reactions: serializer.fromJson<List<Map<String, dynamic>>>(
        json['reactions'],
      ),
      repliedMessageId: serializer.fromJson<String?>(json['repliedMessageId']),
      forwardedMessageId: serializer.fromJson<String?>(
        json['forwardedMessageId'],
      ),
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
      'isDeleted': serializer.toJson<bool?>(isDeleted),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'type': serializer.toJson<String>(type),
      'meta': serializer.toJson<Map<String, dynamic>>(meta),
      'membersMentioned': serializer.toJson<List<String>>(membersMentioned),
      'editedAt': serializer.toJson<DateTime?>(editedAt),
      'attachments': serializer.toJson<List<Map<String, dynamic>>>(attachments),
      'reactions': serializer.toJson<List<Map<String, dynamic>>>(reactions),
      'repliedMessageId': serializer.toJson<String?>(repliedMessageId),
      'forwardedMessageId': serializer.toJson<String?>(forwardedMessageId),
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
    Value<bool?> isDeleted = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    String? type,
    Map<String, dynamic>? meta,
    List<String>? membersMentioned,
    Value<DateTime?> editedAt = const Value.absent(),
    List<Map<String, dynamic>>? attachments,
    List<Map<String, dynamic>>? reactions,
    Value<String?> repliedMessageId = const Value.absent(),
    Value<String?> forwardedMessageId = const Value.absent(),
  }) => ChatMessage(
    id: id ?? this.id,
    roomId: roomId ?? this.roomId,
    senderId: senderId ?? this.senderId,
    content: content.present ? content.value : this.content,
    nonce: nonce.present ? nonce.value : this.nonce,
    data: data ?? this.data,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    isDeleted: isDeleted.present ? isDeleted.value : this.isDeleted,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    type: type ?? this.type,
    meta: meta ?? this.meta,
    membersMentioned: membersMentioned ?? this.membersMentioned,
    editedAt: editedAt.present ? editedAt.value : this.editedAt,
    attachments: attachments ?? this.attachments,
    reactions: reactions ?? this.reactions,
    repliedMessageId: repliedMessageId.present
        ? repliedMessageId.value
        : this.repliedMessageId,
    forwardedMessageId: forwardedMessageId.present
        ? forwardedMessageId.value
        : this.forwardedMessageId,
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
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      type: data.type.present ? data.type.value : this.type,
      meta: data.meta.present ? data.meta.value : this.meta,
      membersMentioned: data.membersMentioned.present
          ? data.membersMentioned.value
          : this.membersMentioned,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      attachments: data.attachments.present
          ? data.attachments.value
          : this.attachments,
      reactions: data.reactions.present ? data.reactions.value : this.reactions,
      repliedMessageId: data.repliedMessageId.present
          ? data.repliedMessageId.value
          : this.repliedMessageId,
      forwardedMessageId: data.forwardedMessageId.present
          ? data.forwardedMessageId.value
          : this.forwardedMessageId,
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
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('type: $type, ')
          ..write('meta: $meta, ')
          ..write('membersMentioned: $membersMentioned, ')
          ..write('editedAt: $editedAt, ')
          ..write('attachments: $attachments, ')
          ..write('reactions: $reactions, ')
          ..write('repliedMessageId: $repliedMessageId, ')
          ..write('forwardedMessageId: $forwardedMessageId')
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
    isDeleted,
    updatedAt,
    deletedAt,
    type,
    meta,
    membersMentioned,
    editedAt,
    attachments,
    reactions,
    repliedMessageId,
    forwardedMessageId,
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
          other.isDeleted == this.isDeleted &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.type == this.type &&
          other.meta == this.meta &&
          other.membersMentioned == this.membersMentioned &&
          other.editedAt == this.editedAt &&
          other.attachments == this.attachments &&
          other.reactions == this.reactions &&
          other.repliedMessageId == this.repliedMessageId &&
          other.forwardedMessageId == this.forwardedMessageId);
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
  final Value<bool?> isDeleted;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> type;
  final Value<Map<String, dynamic>> meta;
  final Value<List<String>> membersMentioned;
  final Value<DateTime?> editedAt;
  final Value<List<Map<String, dynamic>>> attachments;
  final Value<List<Map<String, dynamic>>> reactions;
  final Value<String?> repliedMessageId;
  final Value<String?> forwardedMessageId;
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
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.meta = const Value.absent(),
    this.membersMentioned = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.attachments = const Value.absent(),
    this.reactions = const Value.absent(),
    this.repliedMessageId = const Value.absent(),
    this.forwardedMessageId = const Value.absent(),
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
    this.isDeleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.type = const Value.absent(),
    this.meta = const Value.absent(),
    this.membersMentioned = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.attachments = const Value.absent(),
    this.reactions = const Value.absent(),
    this.repliedMessageId = const Value.absent(),
    this.forwardedMessageId = const Value.absent(),
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
    Expression<bool>? isDeleted,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? type,
    Expression<String>? meta,
    Expression<String>? membersMentioned,
    Expression<DateTime>? editedAt,
    Expression<String>? attachments,
    Expression<String>? reactions,
    Expression<String>? repliedMessageId,
    Expression<String>? forwardedMessageId,
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
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (type != null) 'type': type,
      if (meta != null) 'meta': meta,
      if (membersMentioned != null) 'members_mentioned': membersMentioned,
      if (editedAt != null) 'edited_at': editedAt,
      if (attachments != null) 'attachments': attachments,
      if (reactions != null) 'reactions': reactions,
      if (repliedMessageId != null) 'replied_message_id': repliedMessageId,
      if (forwardedMessageId != null)
        'forwarded_message_id': forwardedMessageId,
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
    Value<bool?>? isDeleted,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? type,
    Value<Map<String, dynamic>>? meta,
    Value<List<String>>? membersMentioned,
    Value<DateTime?>? editedAt,
    Value<List<Map<String, dynamic>>>? attachments,
    Value<List<Map<String, dynamic>>>? reactions,
    Value<String?>? repliedMessageId,
    Value<String?>? forwardedMessageId,
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
      isDeleted: isDeleted ?? this.isDeleted,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      type: type ?? this.type,
      meta: meta ?? this.meta,
      membersMentioned: membersMentioned ?? this.membersMentioned,
      editedAt: editedAt ?? this.editedAt,
      attachments: attachments ?? this.attachments,
      reactions: reactions ?? this.reactions,
      repliedMessageId: repliedMessageId ?? this.repliedMessageId,
      forwardedMessageId: forwardedMessageId ?? this.forwardedMessageId,
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
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (meta.present) {
      map['meta'] = Variable<String>(
        $ChatMessagesTable.$convertermeta.toSql(meta.value),
      );
    }
    if (membersMentioned.present) {
      map['members_mentioned'] = Variable<String>(
        $ChatMessagesTable.$convertermembersMentioned.toSql(
          membersMentioned.value,
        ),
      );
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    if (attachments.present) {
      map['attachments'] = Variable<String>(
        $ChatMessagesTable.$converterattachments.toSql(attachments.value),
      );
    }
    if (reactions.present) {
      map['reactions'] = Variable<String>(
        $ChatMessagesTable.$converterreactions.toSql(reactions.value),
      );
    }
    if (repliedMessageId.present) {
      map['replied_message_id'] = Variable<String>(repliedMessageId.value);
    }
    if (forwardedMessageId.present) {
      map['forwarded_message_id'] = Variable<String>(forwardedMessageId.value);
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
          ..write('isDeleted: $isDeleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('type: $type, ')
          ..write('meta: $meta, ')
          ..write('membersMentioned: $membersMentioned, ')
          ..write('editedAt: $editedAt, ')
          ..write('attachments: $attachments, ')
          ..write('reactions: $reactions, ')
          ..write('repliedMessageId: $repliedMessageId, ')
          ..write('forwardedMessageId: $forwardedMessageId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostDraftsTable extends PostDrafts
    with TableInfo<$PostDraftsTable, PostDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<int> visibility = GeneratedColumn<int>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postDataMeta = const VerificationMeta(
    'postData',
  );
  @override
  late final GeneratedColumn<String> postData = GeneratedColumn<String>(
    'post_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    content,
    visibility,
    type,
    lastModified,
    postData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'post_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<PostDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('post_data')) {
      context.handle(
        _postDataMeta,
        postData.isAcceptableOrUnknown(data['post_data']!, _postDataMeta),
      );
    } else if (isInserting) {
      context.missing(_postDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostDraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visibility'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      postData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}post_data'],
      )!,
    );
  }

  @override
  $PostDraftsTable createAlias(String alias) {
    return $PostDraftsTable(attachedDatabase, alias);
  }
}

class PostDraft extends DataClass implements Insertable<PostDraft> {
  final String id;
  final String? title;
  final String? description;
  final String? content;
  final int visibility;
  final int type;
  final DateTime lastModified;
  final String postData;
  const PostDraft({
    required this.id,
    this.title,
    this.description,
    this.content,
    required this.visibility,
    required this.type,
    required this.lastModified,
    required this.postData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['visibility'] = Variable<int>(visibility);
    map['type'] = Variable<int>(type);
    map['last_modified'] = Variable<DateTime>(lastModified);
    map['post_data'] = Variable<String>(postData);
    return map;
  }

  PostDraftsCompanion toCompanion(bool nullToAbsent) {
    return PostDraftsCompanion(
      id: Value(id),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      visibility: Value(visibility),
      type: Value(type),
      lastModified: Value(lastModified),
      postData: Value(postData),
    );
  }

  factory PostDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostDraft(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      content: serializer.fromJson<String?>(json['content']),
      visibility: serializer.fromJson<int>(json['visibility']),
      type: serializer.fromJson<int>(json['type']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      postData: serializer.fromJson<String>(json['postData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'content': serializer.toJson<String?>(content),
      'visibility': serializer.toJson<int>(visibility),
      'type': serializer.toJson<int>(type),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'postData': serializer.toJson<String>(postData),
    };
  }

  PostDraft copyWith({
    String? id,
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> content = const Value.absent(),
    int? visibility,
    int? type,
    DateTime? lastModified,
    String? postData,
  }) => PostDraft(
    id: id ?? this.id,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    content: content.present ? content.value : this.content,
    visibility: visibility ?? this.visibility,
    type: type ?? this.type,
    lastModified: lastModified ?? this.lastModified,
    postData: postData ?? this.postData,
  );
  PostDraft copyWithCompanion(PostDraftsCompanion data) {
    return PostDraft(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      content: data.content.present ? data.content.value : this.content,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      type: data.type.present ? data.type.value : this.type,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      postData: data.postData.present ? data.postData.value : this.postData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostDraft(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('content: $content, ')
          ..write('visibility: $visibility, ')
          ..write('type: $type, ')
          ..write('lastModified: $lastModified, ')
          ..write('postData: $postData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    content,
    visibility,
    type,
    lastModified,
    postData,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostDraft &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.content == this.content &&
          other.visibility == this.visibility &&
          other.type == this.type &&
          other.lastModified == this.lastModified &&
          other.postData == this.postData);
}

class PostDraftsCompanion extends UpdateCompanion<PostDraft> {
  final Value<String> id;
  final Value<String?> title;
  final Value<String?> description;
  final Value<String?> content;
  final Value<int> visibility;
  final Value<int> type;
  final Value<DateTime> lastModified;
  final Value<String> postData;
  final Value<int> rowid;
  const PostDraftsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.content = const Value.absent(),
    this.visibility = const Value.absent(),
    this.type = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.postData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PostDraftsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.content = const Value.absent(),
    this.visibility = const Value.absent(),
    this.type = const Value.absent(),
    required DateTime lastModified,
    required String postData,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lastModified = Value(lastModified),
       postData = Value(postData);
  static Insertable<PostDraft> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? content,
    Expression<int>? visibility,
    Expression<int>? type,
    Expression<DateTime>? lastModified,
    Expression<String>? postData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (content != null) 'content': content,
      if (visibility != null) 'visibility': visibility,
      if (type != null) 'type': type,
      if (lastModified != null) 'last_modified': lastModified,
      if (postData != null) 'post_data': postData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PostDraftsCompanion copyWith({
    Value<String>? id,
    Value<String?>? title,
    Value<String?>? description,
    Value<String?>? content,
    Value<int>? visibility,
    Value<int>? type,
    Value<DateTime>? lastModified,
    Value<String>? postData,
    Value<int>? rowid,
  }) {
    return PostDraftsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      visibility: visibility ?? this.visibility,
      type: type ?? this.type,
      lastModified: lastModified ?? this.lastModified,
      postData: postData ?? this.postData,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<int>(visibility.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (postData.present) {
      map['post_data'] = Variable<String>(postData.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostDraftsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('content: $content, ')
          ..write('visibility: $visibility, ')
          ..write('type: $type, ')
          ..write('lastModified: $lastModified, ')
          ..write('postData: $postData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatRoomsTable chatRooms = $ChatRoomsTable(this);
  late final $ChatMembersTable chatMembers = $ChatMembersTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $PostDraftsTable postDrafts = $PostDraftsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    chatRooms,
    chatMembers,
    chatMessages,
    postDrafts,
  ];
}

typedef $$ChatRoomsTableCreateCompanionBuilder =
    ChatRoomsCompanion Function({
      required String id,
      Value<String?> name,
      Value<String?> description,
      required int type,
      Value<bool?> isPublic,
      Value<bool?> isCommunity,
      Value<Map<String, dynamic>?> picture,
      Value<Map<String, dynamic>?> background,
      Value<String?> realmId,
      Value<String?> accountId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ChatRoomsTableUpdateCompanionBuilder =
    ChatRoomsCompanion Function({
      Value<String> id,
      Value<String?> name,
      Value<String?> description,
      Value<int> type,
      Value<bool?> isPublic,
      Value<bool?> isCommunity,
      Value<Map<String, dynamic>?> picture,
      Value<Map<String, dynamic>?> background,
      Value<String?> realmId,
      Value<String?> accountId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$ChatRoomsTableReferences
    extends BaseReferences<_$AppDatabase, $ChatRoomsTable, ChatRoom> {
  $$ChatRoomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChatMembersTable, List<ChatMember>>
  _chatMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMembers,
    aliasName: $_aliasNameGenerator(db.chatRooms.id, db.chatMembers.chatRoomId),
  );

  $$ChatMembersTableProcessedTableManager get chatMembersRefs {
    final manager = $$ChatMembersTableTableManager(
      $_db,
      $_db.chatMembers,
    ).filter((f) => f.chatRoomId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessage>>
  _chatMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMessages,
    aliasName: $_aliasNameGenerator(db.chatRooms.id, db.chatMessages.roomId),
  );

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager(
      $_db,
      $_db.chatMessages,
    ).filter((f) => f.roomId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChatRoomsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatRoomsTable> {
  $$ChatRoomsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCommunity => $composableBuilder(
    column: $table.isCommunity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>?,
    Map<String, dynamic>,
    String
  >
  get picture => $composableBuilder(
    column: $table.picture,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>?,
    Map<String, dynamic>,
    String
  >
  get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get realmId => $composableBuilder(
    column: $table.realmId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> chatMembersRefs(
    Expression<bool> Function($$ChatMembersTableFilterComposer f) f,
  ) {
    final $$ChatMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMembers,
      getReferencedColumn: (t) => t.chatRoomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMembersTableFilterComposer(
            $db: $db,
            $table: $db.chatMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chatMessagesRefs(
    Expression<bool> Function($$ChatMessagesTableFilterComposer f) f,
  ) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableFilterComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatRoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatRoomsTable> {
  $$ChatRoomsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCommunity => $composableBuilder(
    column: $table.isCommunity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get picture => $composableBuilder(
    column: $table.picture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get background => $composableBuilder(
    column: $table.background,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get realmId => $composableBuilder(
    column: $table.realmId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatRoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatRoomsTable> {
  $$ChatRoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  GeneratedColumn<bool> get isCommunity => $composableBuilder(
    column: $table.isCommunity,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String> get picture =>
      $composableBuilder(column: $table.picture, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
  get background => $composableBuilder(
    column: $table.background,
    builder: (column) => column,
  );

  GeneratedColumn<String> get realmId =>
      $composableBuilder(column: $table.realmId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> chatMembersRefs<T extends Object>(
    Expression<T> Function($$ChatMembersTableAnnotationComposer a) f,
  ) {
    final $$ChatMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMembers,
      getReferencedColumn: (t) => t.chatRoomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chatMessagesRefs<T extends Object>(
    Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f,
  ) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatRoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatRoomsTable,
          ChatRoom,
          $$ChatRoomsTableFilterComposer,
          $$ChatRoomsTableOrderingComposer,
          $$ChatRoomsTableAnnotationComposer,
          $$ChatRoomsTableCreateCompanionBuilder,
          $$ChatRoomsTableUpdateCompanionBuilder,
          (ChatRoom, $$ChatRoomsTableReferences),
          ChatRoom,
          PrefetchHooks Function({bool chatMembersRefs, bool chatMessagesRefs})
        > {
  $$ChatRoomsTableTableManager(_$AppDatabase db, $ChatRoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatRoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatRoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatRoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<bool?> isPublic = const Value.absent(),
                Value<bool?> isCommunity = const Value.absent(),
                Value<Map<String, dynamic>?> picture = const Value.absent(),
                Value<Map<String, dynamic>?> background = const Value.absent(),
                Value<String?> realmId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatRoomsCompanion(
                id: id,
                name: name,
                description: description,
                type: type,
                isPublic: isPublic,
                isCommunity: isCommunity,
                picture: picture,
                background: background,
                realmId: realmId,
                accountId: accountId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required int type,
                Value<bool?> isPublic = const Value.absent(),
                Value<bool?> isCommunity = const Value.absent(),
                Value<Map<String, dynamic>?> picture = const Value.absent(),
                Value<Map<String, dynamic>?> background = const Value.absent(),
                Value<String?> realmId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatRoomsCompanion.insert(
                id: id,
                name: name,
                description: description,
                type: type,
                isPublic: isPublic,
                isCommunity: isCommunity,
                picture: picture,
                background: background,
                realmId: realmId,
                accountId: accountId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatRoomsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({chatMembersRefs = false, chatMessagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chatMembersRefs) db.chatMembers,
                    if (chatMessagesRefs) db.chatMessages,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chatMembersRefs)
                        await $_getPrefetchedData<
                          ChatRoom,
                          $ChatRoomsTable,
                          ChatMember
                        >(
                          currentTable: table,
                          referencedTable: $$ChatRoomsTableReferences
                              ._chatMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChatRoomsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chatRoomId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chatMessagesRefs)
                        await $_getPrefetchedData<
                          ChatRoom,
                          $ChatRoomsTable,
                          ChatMessage
                        >(
                          currentTable: table,
                          referencedTable: $$ChatRoomsTableReferences
                              ._chatMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChatRoomsTableReferences(
                                db,
                                table,
                                p0,
                              ).chatMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.roomId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChatRoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatRoomsTable,
      ChatRoom,
      $$ChatRoomsTableFilterComposer,
      $$ChatRoomsTableOrderingComposer,
      $$ChatRoomsTableAnnotationComposer,
      $$ChatRoomsTableCreateCompanionBuilder,
      $$ChatRoomsTableUpdateCompanionBuilder,
      (ChatRoom, $$ChatRoomsTableReferences),
      ChatRoom,
      PrefetchHooks Function({bool chatMembersRefs, bool chatMessagesRefs})
    >;
typedef $$ChatMembersTableCreateCompanionBuilder =
    ChatMembersCompanion Function({
      required String id,
      required String chatRoomId,
      required String accountId,
      required Map<String, dynamic> account,
      Value<String?> nick,
      required int notify,
      Value<DateTime?> joinedAt,
      Value<DateTime?> breakUntil,
      Value<DateTime?> timeoutUntil,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ChatMembersTableUpdateCompanionBuilder =
    ChatMembersCompanion Function({
      Value<String> id,
      Value<String> chatRoomId,
      Value<String> accountId,
      Value<Map<String, dynamic>> account,
      Value<String?> nick,
      Value<int> notify,
      Value<DateTime?> joinedAt,
      Value<DateTime?> breakUntil,
      Value<DateTime?> timeoutUntil,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$ChatMembersTableReferences
    extends BaseReferences<_$AppDatabase, $ChatMembersTable, ChatMember> {
  $$ChatMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChatRoomsTable _chatRoomIdTable(_$AppDatabase db) =>
      db.chatRooms.createAlias(
        $_aliasNameGenerator(db.chatMembers.chatRoomId, db.chatRooms.id),
      );

  $$ChatRoomsTableProcessedTableManager get chatRoomId {
    final $_column = $_itemColumn<String>('chat_room_id')!;

    final manager = $$ChatRoomsTableTableManager(
      $_db,
      $_db.chatRooms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chatRoomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessage>>
  _chatMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chatMessages,
    aliasName: $_aliasNameGenerator(
      db.chatMembers.id,
      db.chatMessages.senderId,
    ),
  );

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager(
      $_db,
      $_db.chatMessages,
    ).filter((f) => f.senderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChatMembersTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMembersTable> {
  $$ChatMembersTableFilterComposer({
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

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get nick => $composableBuilder(
    column: $table.nick,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notify => $composableBuilder(
    column: $table.notify,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get breakUntil => $composableBuilder(
    column: $table.breakUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timeoutUntil => $composableBuilder(
    column: $table.timeoutUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChatRoomsTableFilterComposer get chatRoomId {
    final $$ChatRoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatRoomId,
      referencedTable: $db.chatRooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatRoomsTableFilterComposer(
            $db: $db,
            $table: $db.chatRooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chatMessagesRefs(
    Expression<bool> Function($$ChatMessagesTableFilterComposer f) f,
  ) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.senderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableFilterComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMembersTable> {
  $$ChatMembersTableOrderingComposer({
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

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get account => $composableBuilder(
    column: $table.account,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nick => $composableBuilder(
    column: $table.nick,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notify => $composableBuilder(
    column: $table.notify,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get breakUntil => $composableBuilder(
    column: $table.breakUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timeoutUntil => $composableBuilder(
    column: $table.timeoutUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChatRoomsTableOrderingComposer get chatRoomId {
    final $$ChatRoomsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatRoomId,
      referencedTable: $db.chatRooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatRoomsTableOrderingComposer(
            $db: $db,
            $table: $db.chatRooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChatMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMembersTable> {
  $$ChatMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<String> get nick =>
      $composableBuilder(column: $table.nick, builder: (column) => column);

  GeneratedColumn<int> get notify =>
      $composableBuilder(column: $table.notify, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get breakUntil => $composableBuilder(
    column: $table.breakUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timeoutUntil => $composableBuilder(
    column: $table.timeoutUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$ChatRoomsTableAnnotationComposer get chatRoomId {
    final $$ChatRoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chatRoomId,
      referencedTable: $db.chatRooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatRoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatRooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chatMessagesRefs<T extends Object>(
    Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f,
  ) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chatMessages,
      getReferencedColumn: (t) => t.senderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChatMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMembersTable,
          ChatMember,
          $$ChatMembersTableFilterComposer,
          $$ChatMembersTableOrderingComposer,
          $$ChatMembersTableAnnotationComposer,
          $$ChatMembersTableCreateCompanionBuilder,
          $$ChatMembersTableUpdateCompanionBuilder,
          (ChatMember, $$ChatMembersTableReferences),
          ChatMember,
          PrefetchHooks Function({bool chatRoomId, bool chatMessagesRefs})
        > {
  $$ChatMembersTableTableManager(_$AppDatabase db, $ChatMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> chatRoomId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<Map<String, dynamic>> account = const Value.absent(),
                Value<String?> nick = const Value.absent(),
                Value<int> notify = const Value.absent(),
                Value<DateTime?> joinedAt = const Value.absent(),
                Value<DateTime?> breakUntil = const Value.absent(),
                Value<DateTime?> timeoutUntil = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMembersCompanion(
                id: id,
                chatRoomId: chatRoomId,
                accountId: accountId,
                account: account,
                nick: nick,
                notify: notify,
                joinedAt: joinedAt,
                breakUntil: breakUntil,
                timeoutUntil: timeoutUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String chatRoomId,
                required String accountId,
                required Map<String, dynamic> account,
                Value<String?> nick = const Value.absent(),
                required int notify,
                Value<DateTime?> joinedAt = const Value.absent(),
                Value<DateTime?> breakUntil = const Value.absent(),
                Value<DateTime?> timeoutUntil = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMembersCompanion.insert(
                id: id,
                chatRoomId: chatRoomId,
                accountId: accountId,
                account: account,
                nick: nick,
                notify: notify,
                joinedAt: joinedAt,
                breakUntil: breakUntil,
                timeoutUntil: timeoutUntil,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({chatRoomId = false, chatMessagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chatMessagesRefs) db.chatMessages,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (chatRoomId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.chatRoomId,
                                    referencedTable:
                                        $$ChatMembersTableReferences
                                            ._chatRoomIdTable(db),
                                    referencedColumn:
                                        $$ChatMembersTableReferences
                                            ._chatRoomIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chatMessagesRefs)
                        await $_getPrefetchedData<
                          ChatMember,
                          $ChatMembersTable,
                          ChatMessage
                        >(
                          currentTable: table,
                          referencedTable: $$ChatMembersTableReferences
                              ._chatMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChatMembersTableReferences(
                                db,
                                table,
                                p0,
                              ).chatMessagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.senderId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChatMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMembersTable,
      ChatMember,
      $$ChatMembersTableFilterComposer,
      $$ChatMembersTableOrderingComposer,
      $$ChatMembersTableAnnotationComposer,
      $$ChatMembersTableCreateCompanionBuilder,
      $$ChatMembersTableUpdateCompanionBuilder,
      (ChatMember, $$ChatMembersTableReferences),
      ChatMember,
      PrefetchHooks Function({bool chatRoomId, bool chatMessagesRefs})
    >;
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
      Value<bool?> isDeleted,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> type,
      Value<Map<String, dynamic>> meta,
      Value<List<String>> membersMentioned,
      Value<DateTime?> editedAt,
      Value<List<Map<String, dynamic>>> attachments,
      Value<List<Map<String, dynamic>>> reactions,
      Value<String?> repliedMessageId,
      Value<String?> forwardedMessageId,
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
      Value<bool?> isDeleted,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> type,
      Value<Map<String, dynamic>> meta,
      Value<List<String>> membersMentioned,
      Value<DateTime?> editedAt,
      Value<List<Map<String, dynamic>>> attachments,
      Value<List<Map<String, dynamic>>> reactions,
      Value<String?> repliedMessageId,
      Value<String?> forwardedMessageId,
      Value<int> rowid,
    });

final class $$ChatMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessage> {
  $$ChatMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChatRoomsTable _roomIdTable(_$AppDatabase db) =>
      db.chatRooms.createAlias(
        $_aliasNameGenerator(db.chatMessages.roomId, db.chatRooms.id),
      );

  $$ChatRoomsTableProcessedTableManager get roomId {
    final $_column = $_itemColumn<String>('room_id')!;

    final manager = $$ChatRoomsTableTableManager(
      $_db,
      $_db.chatRooms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ChatMembersTable _senderIdTable(_$AppDatabase db) =>
      db.chatMembers.createAlias(
        $_aliasNameGenerator(db.chatMessages.senderId, db.chatMembers.id),
      );

  $$ChatMembersTableProcessedTableManager get senderId {
    final $_column = $_itemColumn<String>('sender_id')!;

    final manager = $$ChatMembersTableTableManager(
      $_db,
      $_db.chatMembers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_senderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get meta => $composableBuilder(
    column: $table.meta,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get membersMentioned => $composableBuilder(
    column: $table.membersMentioned,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<Map<String, dynamic>>,
    List<Map<String, dynamic>>,
    String
  >
  get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<Map<String, dynamic>>,
    List<Map<String, dynamic>>,
    String
  >
  get reactions => $composableBuilder(
    column: $table.reactions,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get repliedMessageId => $composableBuilder(
    column: $table.repliedMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get forwardedMessageId => $composableBuilder(
    column: $table.forwardedMessageId,
    builder: (column) => ColumnFilters(column),
  );

  $$ChatRoomsTableFilterComposer get roomId {
    final $$ChatRoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.chatRooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatRoomsTableFilterComposer(
            $db: $db,
            $table: $db.chatRooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChatMembersTableFilterComposer get senderId {
    final $$ChatMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderId,
      referencedTable: $db.chatMembers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMembersTableFilterComposer(
            $db: $db,
            $table: $db.chatMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meta => $composableBuilder(
    column: $table.meta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get membersMentioned => $composableBuilder(
    column: $table.membersMentioned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reactions => $composableBuilder(
    column: $table.reactions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repliedMessageId => $composableBuilder(
    column: $table.repliedMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forwardedMessageId => $composableBuilder(
    column: $table.forwardedMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChatRoomsTableOrderingComposer get roomId {
    final $$ChatRoomsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.chatRooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatRoomsTableOrderingComposer(
            $db: $db,
            $table: $db.chatRooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChatMembersTableOrderingComposer get senderId {
    final $$ChatMembersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderId,
      referencedTable: $db.chatMembers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMembersTableOrderingComposer(
            $db: $db,
            $table: $db.chatMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String> get meta =>
      $composableBuilder(column: $table.meta, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get membersMentioned =>
      $composableBuilder(
        column: $table.membersMentioned,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<Map<String, dynamic>>, String>
  get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<Map<String, dynamic>>, String>
  get reactions =>
      $composableBuilder(column: $table.reactions, builder: (column) => column);

  GeneratedColumn<String> get repliedMessageId => $composableBuilder(
    column: $table.repliedMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get forwardedMessageId => $composableBuilder(
    column: $table.forwardedMessageId,
    builder: (column) => column,
  );

  $$ChatRoomsTableAnnotationComposer get roomId {
    final $$ChatRoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.chatRooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatRoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.chatRooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ChatMembersTableAnnotationComposer get senderId {
    final $$ChatMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.senderId,
      referencedTable: $db.chatMembers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChatMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.chatMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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
          (ChatMessage, $$ChatMessagesTableReferences),
          ChatMessage,
          PrefetchHooks Function({bool roomId, bool senderId})
        > {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
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
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<Map<String, dynamic>> meta = const Value.absent(),
                Value<List<String>> membersMentioned = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<List<Map<String, dynamic>>> attachments =
                    const Value.absent(),
                Value<List<Map<String, dynamic>>> reactions =
                    const Value.absent(),
                Value<String?> repliedMessageId = const Value.absent(),
                Value<String?> forwardedMessageId = const Value.absent(),
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
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                type: type,
                meta: meta,
                membersMentioned: membersMentioned,
                editedAt: editedAt,
                attachments: attachments,
                reactions: reactions,
                repliedMessageId: repliedMessageId,
                forwardedMessageId: forwardedMessageId,
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
                Value<bool?> isDeleted = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<Map<String, dynamic>> meta = const Value.absent(),
                Value<List<String>> membersMentioned = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<List<Map<String, dynamic>>> attachments =
                    const Value.absent(),
                Value<List<Map<String, dynamic>>> reactions =
                    const Value.absent(),
                Value<String?> repliedMessageId = const Value.absent(),
                Value<String?> forwardedMessageId = const Value.absent(),
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
                isDeleted: isDeleted,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                type: type,
                meta: meta,
                membersMentioned: membersMentioned,
                editedAt: editedAt,
                attachments: attachments,
                reactions: reactions,
                repliedMessageId: repliedMessageId,
                forwardedMessageId: forwardedMessageId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChatMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({roomId = false, senderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (roomId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.roomId,
                                referencedTable: $$ChatMessagesTableReferences
                                    ._roomIdTable(db),
                                referencedColumn: $$ChatMessagesTableReferences
                                    ._roomIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (senderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.senderId,
                                referencedTable: $$ChatMessagesTableReferences
                                    ._senderIdTable(db),
                                referencedColumn: $$ChatMessagesTableReferences
                                    ._senderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
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
      (ChatMessage, $$ChatMessagesTableReferences),
      ChatMessage,
      PrefetchHooks Function({bool roomId, bool senderId})
    >;
typedef $$PostDraftsTableCreateCompanionBuilder =
    PostDraftsCompanion Function({
      required String id,
      Value<String?> title,
      Value<String?> description,
      Value<String?> content,
      Value<int> visibility,
      Value<int> type,
      required DateTime lastModified,
      required String postData,
      Value<int> rowid,
    });
typedef $$PostDraftsTableUpdateCompanionBuilder =
    PostDraftsCompanion Function({
      Value<String> id,
      Value<String?> title,
      Value<String?> description,
      Value<String?> content,
      Value<int> visibility,
      Value<int> type,
      Value<DateTime> lastModified,
      Value<String> postData,
      Value<int> rowid,
    });

class $$PostDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $PostDraftsTable> {
  $$PostDraftsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postData => $composableBuilder(
    column: $table.postData,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PostDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $PostDraftsTable> {
  $$PostDraftsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postData => $composableBuilder(
    column: $table.postData,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PostDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostDraftsTable> {
  $$PostDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postData =>
      $composableBuilder(column: $table.postData, builder: (column) => column);
}

class $$PostDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PostDraftsTable,
          PostDraft,
          $$PostDraftsTableFilterComposer,
          $$PostDraftsTableOrderingComposer,
          $$PostDraftsTableAnnotationComposer,
          $$PostDraftsTableCreateCompanionBuilder,
          $$PostDraftsTableUpdateCompanionBuilder,
          (
            PostDraft,
            BaseReferences<_$AppDatabase, $PostDraftsTable, PostDraft>,
          ),
          PostDraft,
          PrefetchHooks Function()
        > {
  $$PostDraftsTableTableManager(_$AppDatabase db, $PostDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<int> visibility = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<String> postData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PostDraftsCompanion(
                id: id,
                title: title,
                description: description,
                content: content,
                visibility: visibility,
                type: type,
                lastModified: lastModified,
                postData: postData,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<int> visibility = const Value.absent(),
                Value<int> type = const Value.absent(),
                required DateTime lastModified,
                required String postData,
                Value<int> rowid = const Value.absent(),
              }) => PostDraftsCompanion.insert(
                id: id,
                title: title,
                description: description,
                content: content,
                visibility: visibility,
                type: type,
                lastModified: lastModified,
                postData: postData,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PostDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PostDraftsTable,
      PostDraft,
      $$PostDraftsTableFilterComposer,
      $$PostDraftsTableOrderingComposer,
      $$PostDraftsTableAnnotationComposer,
      $$PostDraftsTableCreateCompanionBuilder,
      $$PostDraftsTableUpdateCompanionBuilder,
      (PostDraft, BaseReferences<_$AppDatabase, $PostDraftsTable, PostDraft>),
      PostDraft,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatRoomsTableTableManager get chatRooms =>
      $$ChatRoomsTableTableManager(_db, _db.chatRooms);
  $$ChatMembersTableTableManager get chatMembers =>
      $$ChatMembersTableTableManager(_db, _db.chatMembers);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$PostDraftsTableTableManager get postDrafts =>
      $$PostDraftsTableTableManager(_db, _db.postDrafts);
}
