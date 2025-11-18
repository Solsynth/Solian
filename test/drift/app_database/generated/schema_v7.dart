// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class ChatRooms extends Table with TableInfo<ChatRooms, ChatRoomsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ChatRooms(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
    'is_public',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_public" IN (0, 1))',
    ),
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<bool> isCommunity = GeneratedColumn<bool>(
    'is_community',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_community" IN (0, 1))',
    ),
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<String> picture = GeneratedColumn<String>(
    'picture',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> background = GeneratedColumn<String>(
    'background',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> realmId = GeneratedColumn<String>(
    'realm_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatRoomsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatRoomsData(
      id:
          attachedDatabase.typeMapping.read(
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
      type:
          attachedDatabase.typeMapping.read(
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
      picture: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}picture'],
      ),
      background: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}background'],
      ),
      realmId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}realm_id'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
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
  ChatRooms createAlias(String alias) {
    return ChatRooms(attachedDatabase, alias);
  }
}

class ChatRoomsData extends DataClass implements Insertable<ChatRoomsData> {
  final String id;
  final String? name;
  final String? description;
  final int type;
  final bool? isPublic;
  final bool? isCommunity;
  final String? picture;
  final String? background;
  final String? realmId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ChatRoomsData({
    required this.id,
    this.name,
    this.description,
    required this.type,
    this.isPublic,
    this.isCommunity,
    this.picture,
    this.background,
    this.realmId,
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
      map['picture'] = Variable<String>(picture);
    }
    if (!nullToAbsent || background != null) {
      map['background'] = Variable<String>(background);
    }
    if (!nullToAbsent || realmId != null) {
      map['realm_id'] = Variable<String>(realmId);
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
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      type: Value(type),
      isPublic:
          isPublic == null && nullToAbsent
              ? const Value.absent()
              : Value(isPublic),
      isCommunity:
          isCommunity == null && nullToAbsent
              ? const Value.absent()
              : Value(isCommunity),
      picture:
          picture == null && nullToAbsent
              ? const Value.absent()
              : Value(picture),
      background:
          background == null && nullToAbsent
              ? const Value.absent()
              : Value(background),
      realmId:
          realmId == null && nullToAbsent
              ? const Value.absent()
              : Value(realmId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
    );
  }

  factory ChatRoomsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatRoomsData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      type: serializer.fromJson<int>(json['type']),
      isPublic: serializer.fromJson<bool?>(json['isPublic']),
      isCommunity: serializer.fromJson<bool?>(json['isCommunity']),
      picture: serializer.fromJson<String?>(json['picture']),
      background: serializer.fromJson<String?>(json['background']),
      realmId: serializer.fromJson<String?>(json['realmId']),
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
      'picture': serializer.toJson<String?>(picture),
      'background': serializer.toJson<String?>(background),
      'realmId': serializer.toJson<String?>(realmId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ChatRoomsData copyWith({
    String? id,
    Value<String?> name = const Value.absent(),
    Value<String?> description = const Value.absent(),
    int? type,
    Value<bool?> isPublic = const Value.absent(),
    Value<bool?> isCommunity = const Value.absent(),
    Value<String?> picture = const Value.absent(),
    Value<String?> background = const Value.absent(),
    Value<String?> realmId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ChatRoomsData(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    description: description.present ? description.value : this.description,
    type: type ?? this.type,
    isPublic: isPublic.present ? isPublic.value : this.isPublic,
    isCommunity: isCommunity.present ? isCommunity.value : this.isCommunity,
    picture: picture.present ? picture.value : this.picture,
    background: background.present ? background.value : this.background,
    realmId: realmId.present ? realmId.value : this.realmId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ChatRoomsData copyWithCompanion(ChatRoomsCompanion data) {
    return ChatRoomsData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      type: data.type.present ? data.type.value : this.type,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      isCommunity:
          data.isCommunity.present ? data.isCommunity.value : this.isCommunity,
      picture: data.picture.present ? data.picture.value : this.picture,
      background:
          data.background.present ? data.background.value : this.background,
      realmId: data.realmId.present ? data.realmId.value : this.realmId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatRoomsData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('isPublic: $isPublic, ')
          ..write('isCommunity: $isCommunity, ')
          ..write('picture: $picture, ')
          ..write('background: $background, ')
          ..write('realmId: $realmId, ')
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
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatRoomsData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.type == this.type &&
          other.isPublic == this.isPublic &&
          other.isCommunity == this.isCommunity &&
          other.picture == this.picture &&
          other.background == this.background &&
          other.realmId == this.realmId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ChatRoomsCompanion extends UpdateCompanion<ChatRoomsData> {
  final Value<String> id;
  final Value<String?> name;
  final Value<String?> description;
  final Value<int> type;
  final Value<bool?> isPublic;
  final Value<bool?> isCommunity;
  final Value<String?> picture;
  final Value<String?> background;
  final Value<String?> realmId;
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
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChatRoomsData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? type,
    Expression<bool>? isPublic,
    Expression<bool>? isCommunity,
    Expression<String>? picture,
    Expression<String>? background,
    Expression<String>? realmId,
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
    Value<String?>? picture,
    Value<String?>? background,
    Value<String?>? realmId,
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
      map['picture'] = Variable<String>(picture.value);
    }
    if (background.present) {
      map['background'] = Variable<String>(background.value);
    }
    if (realmId.present) {
      map['realm_id'] = Variable<String>(realmId.value);
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ChatMembers extends Table with TableInfo<ChatMembers, ChatMembersData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ChatMembers(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
    'account',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> nick = GeneratedColumn<String>(
    'nick',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> role = GeneratedColumn<int>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> notify = GeneratedColumn<int>(
    'notify',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<DateTime> breakUntil = GeneratedColumn<DateTime>(
    'break_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<DateTime> timeoutUntil = GeneratedColumn<DateTime>(
    'timeout_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<bool> isBot = GeneratedColumn<bool>(
    'is_bot',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bot" IN (0, 1))',
    ),
  );
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<DateTime> lastTyped = GeneratedColumn<DateTime>(
    'last_typed',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
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
    role,
    notify,
    joinedAt,
    breakUntil,
    timeoutUntil,
    isBot,
    status,
    lastTyped,
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMembersData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMembersData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      chatRoomId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}chat_room_id'],
          )!,
      accountId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}account_id'],
          )!,
      account:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}account'],
          )!,
      nick: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nick'],
      ),
      role:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}role'],
          )!,
      notify:
          attachedDatabase.typeMapping.read(
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
      isBot:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_bot'],
          )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      lastTyped: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_typed'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
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
  ChatMembers createAlias(String alias) {
    return ChatMembers(attachedDatabase, alias);
  }
}

class ChatMembersData extends DataClass implements Insertable<ChatMembersData> {
  final String id;
  final String chatRoomId;
  final String accountId;
  final String account;
  final String? nick;
  final int role;
  final int notify;
  final DateTime? joinedAt;
  final DateTime? breakUntil;
  final DateTime? timeoutUntil;
  final bool isBot;
  final String? status;
  final DateTime? lastTyped;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ChatMembersData({
    required this.id,
    required this.chatRoomId,
    required this.accountId,
    required this.account,
    this.nick,
    required this.role,
    required this.notify,
    this.joinedAt,
    this.breakUntil,
    this.timeoutUntil,
    required this.isBot,
    this.status,
    this.lastTyped,
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
    map['account'] = Variable<String>(account);
    if (!nullToAbsent || nick != null) {
      map['nick'] = Variable<String>(nick);
    }
    map['role'] = Variable<int>(role);
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
    map['is_bot'] = Variable<bool>(isBot);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || lastTyped != null) {
      map['last_typed'] = Variable<DateTime>(lastTyped);
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
      role: Value(role),
      notify: Value(notify),
      joinedAt:
          joinedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(joinedAt),
      breakUntil:
          breakUntil == null && nullToAbsent
              ? const Value.absent()
              : Value(breakUntil),
      timeoutUntil:
          timeoutUntil == null && nullToAbsent
              ? const Value.absent()
              : Value(timeoutUntil),
      isBot: Value(isBot),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      lastTyped:
          lastTyped == null && nullToAbsent
              ? const Value.absent()
              : Value(lastTyped),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
    );
  }

  factory ChatMembersData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMembersData(
      id: serializer.fromJson<String>(json['id']),
      chatRoomId: serializer.fromJson<String>(json['chatRoomId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      account: serializer.fromJson<String>(json['account']),
      nick: serializer.fromJson<String?>(json['nick']),
      role: serializer.fromJson<int>(json['role']),
      notify: serializer.fromJson<int>(json['notify']),
      joinedAt: serializer.fromJson<DateTime?>(json['joinedAt']),
      breakUntil: serializer.fromJson<DateTime?>(json['breakUntil']),
      timeoutUntil: serializer.fromJson<DateTime?>(json['timeoutUntil']),
      isBot: serializer.fromJson<bool>(json['isBot']),
      status: serializer.fromJson<String?>(json['status']),
      lastTyped: serializer.fromJson<DateTime?>(json['lastTyped']),
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
      'account': serializer.toJson<String>(account),
      'nick': serializer.toJson<String?>(nick),
      'role': serializer.toJson<int>(role),
      'notify': serializer.toJson<int>(notify),
      'joinedAt': serializer.toJson<DateTime?>(joinedAt),
      'breakUntil': serializer.toJson<DateTime?>(breakUntil),
      'timeoutUntil': serializer.toJson<DateTime?>(timeoutUntil),
      'isBot': serializer.toJson<bool>(isBot),
      'status': serializer.toJson<String?>(status),
      'lastTyped': serializer.toJson<DateTime?>(lastTyped),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ChatMembersData copyWith({
    String? id,
    String? chatRoomId,
    String? accountId,
    String? account,
    Value<String?> nick = const Value.absent(),
    int? role,
    int? notify,
    Value<DateTime?> joinedAt = const Value.absent(),
    Value<DateTime?> breakUntil = const Value.absent(),
    Value<DateTime?> timeoutUntil = const Value.absent(),
    bool? isBot,
    Value<String?> status = const Value.absent(),
    Value<DateTime?> lastTyped = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ChatMembersData(
    id: id ?? this.id,
    chatRoomId: chatRoomId ?? this.chatRoomId,
    accountId: accountId ?? this.accountId,
    account: account ?? this.account,
    nick: nick.present ? nick.value : this.nick,
    role: role ?? this.role,
    notify: notify ?? this.notify,
    joinedAt: joinedAt.present ? joinedAt.value : this.joinedAt,
    breakUntil: breakUntil.present ? breakUntil.value : this.breakUntil,
    timeoutUntil: timeoutUntil.present ? timeoutUntil.value : this.timeoutUntil,
    isBot: isBot ?? this.isBot,
    status: status.present ? status.value : this.status,
    lastTyped: lastTyped.present ? lastTyped.value : this.lastTyped,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ChatMembersData copyWithCompanion(ChatMembersCompanion data) {
    return ChatMembersData(
      id: data.id.present ? data.id.value : this.id,
      chatRoomId:
          data.chatRoomId.present ? data.chatRoomId.value : this.chatRoomId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      account: data.account.present ? data.account.value : this.account,
      nick: data.nick.present ? data.nick.value : this.nick,
      role: data.role.present ? data.role.value : this.role,
      notify: data.notify.present ? data.notify.value : this.notify,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      breakUntil:
          data.breakUntil.present ? data.breakUntil.value : this.breakUntil,
      timeoutUntil:
          data.timeoutUntil.present
              ? data.timeoutUntil.value
              : this.timeoutUntil,
      isBot: data.isBot.present ? data.isBot.value : this.isBot,
      status: data.status.present ? data.status.value : this.status,
      lastTyped: data.lastTyped.present ? data.lastTyped.value : this.lastTyped,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMembersData(')
          ..write('id: $id, ')
          ..write('chatRoomId: $chatRoomId, ')
          ..write('accountId: $accountId, ')
          ..write('account: $account, ')
          ..write('nick: $nick, ')
          ..write('role: $role, ')
          ..write('notify: $notify, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('breakUntil: $breakUntil, ')
          ..write('timeoutUntil: $timeoutUntil, ')
          ..write('isBot: $isBot, ')
          ..write('status: $status, ')
          ..write('lastTyped: $lastTyped, ')
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
    role,
    notify,
    joinedAt,
    breakUntil,
    timeoutUntil,
    isBot,
    status,
    lastTyped,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMembersData &&
          other.id == this.id &&
          other.chatRoomId == this.chatRoomId &&
          other.accountId == this.accountId &&
          other.account == this.account &&
          other.nick == this.nick &&
          other.role == this.role &&
          other.notify == this.notify &&
          other.joinedAt == this.joinedAt &&
          other.breakUntil == this.breakUntil &&
          other.timeoutUntil == this.timeoutUntil &&
          other.isBot == this.isBot &&
          other.status == this.status &&
          other.lastTyped == this.lastTyped &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ChatMembersCompanion extends UpdateCompanion<ChatMembersData> {
  final Value<String> id;
  final Value<String> chatRoomId;
  final Value<String> accountId;
  final Value<String> account;
  final Value<String?> nick;
  final Value<int> role;
  final Value<int> notify;
  final Value<DateTime?> joinedAt;
  final Value<DateTime?> breakUntil;
  final Value<DateTime?> timeoutUntil;
  final Value<bool> isBot;
  final Value<String?> status;
  final Value<DateTime?> lastTyped;
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
    this.role = const Value.absent(),
    this.notify = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.breakUntil = const Value.absent(),
    this.timeoutUntil = const Value.absent(),
    this.isBot = const Value.absent(),
    this.status = const Value.absent(),
    this.lastTyped = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMembersCompanion.insert({
    required String id,
    required String chatRoomId,
    required String accountId,
    required String account,
    this.nick = const Value.absent(),
    required int role,
    required int notify,
    this.joinedAt = const Value.absent(),
    this.breakUntil = const Value.absent(),
    this.timeoutUntil = const Value.absent(),
    required bool isBot,
    this.status = const Value.absent(),
    this.lastTyped = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       chatRoomId = Value(chatRoomId),
       accountId = Value(accountId),
       account = Value(account),
       role = Value(role),
       notify = Value(notify),
       isBot = Value(isBot),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChatMembersData> custom({
    Expression<String>? id,
    Expression<String>? chatRoomId,
    Expression<String>? accountId,
    Expression<String>? account,
    Expression<String>? nick,
    Expression<int>? role,
    Expression<int>? notify,
    Expression<DateTime>? joinedAt,
    Expression<DateTime>? breakUntil,
    Expression<DateTime>? timeoutUntil,
    Expression<bool>? isBot,
    Expression<String>? status,
    Expression<DateTime>? lastTyped,
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
      if (role != null) 'role': role,
      if (notify != null) 'notify': notify,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (breakUntil != null) 'break_until': breakUntil,
      if (timeoutUntil != null) 'timeout_until': timeoutUntil,
      if (isBot != null) 'is_bot': isBot,
      if (status != null) 'status': status,
      if (lastTyped != null) 'last_typed': lastTyped,
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
    Value<String>? account,
    Value<String?>? nick,
    Value<int>? role,
    Value<int>? notify,
    Value<DateTime?>? joinedAt,
    Value<DateTime?>? breakUntil,
    Value<DateTime?>? timeoutUntil,
    Value<bool>? isBot,
    Value<String?>? status,
    Value<DateTime?>? lastTyped,
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
      role: role ?? this.role,
      notify: notify ?? this.notify,
      joinedAt: joinedAt ?? this.joinedAt,
      breakUntil: breakUntil ?? this.breakUntil,
      timeoutUntil: timeoutUntil ?? this.timeoutUntil,
      isBot: isBot ?? this.isBot,
      status: status ?? this.status,
      lastTyped: lastTyped ?? this.lastTyped,
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
      map['account'] = Variable<String>(account.value);
    }
    if (nick.present) {
      map['nick'] = Variable<String>(nick.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(role.value);
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
    if (isBot.present) {
      map['is_bot'] = Variable<bool>(isBot.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastTyped.present) {
      map['last_typed'] = Variable<DateTime>(lastTyped.value);
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
          ..write('role: $role, ')
          ..write('notify: $notify, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('breakUntil: $breakUntil, ')
          ..write('timeoutUntil: $timeoutUntil, ')
          ..write('isBot: $isBot, ')
          ..write('status: $status, ')
          ..write('lastTyped: $lastTyped, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ChatMessages extends Table
    with TableInfo<ChatMessages, ChatMessagesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ChatMessages(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> nonce = GeneratedColumn<String>(
    'nonce',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('\'text\''),
  );
  late final GeneratedColumn<String> meta = GeneratedColumn<String>(
    'meta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('\'{}\''),
  );
  late final GeneratedColumn<String> membersMentioned = GeneratedColumn<String>(
    'members_mentioned',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('\'[]\''),
  );
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> attachments = GeneratedColumn<String>(
    'attachments',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('\'[]\''),
  );
  late final GeneratedColumn<String> reactions = GeneratedColumn<String>(
    'reactions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('\'[]\''),
  );
  late final GeneratedColumn<String> repliedMessageId = GeneratedColumn<String>(
    'replied_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessagesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessagesData(
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
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}status'],
          )!,
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
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      meta:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}meta'],
          )!,
      membersMentioned:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}members_mentioned'],
          )!,
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}edited_at'],
      ),
      attachments:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}attachments'],
          )!,
      reactions:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}reactions'],
          )!,
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
  ChatMessages createAlias(String alias) {
    return ChatMessages(attachedDatabase, alias);
  }
}

class ChatMessagesData extends DataClass
    implements Insertable<ChatMessagesData> {
  final String id;
  final String roomId;
  final String senderId;
  final String? content;
  final String? nonce;
  final String data;
  final DateTime createdAt;
  final int status;
  final bool? isDeleted;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String type;
  final String meta;
  final String membersMentioned;
  final DateTime? editedAt;
  final String attachments;
  final String reactions;
  final String? repliedMessageId;
  final String? forwardedMessageId;
  const ChatMessagesData({
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
    map['status'] = Variable<int>(status);
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
    map['meta'] = Variable<String>(meta);
    map['members_mentioned'] = Variable<String>(membersMentioned);
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<DateTime>(editedAt);
    }
    map['attachments'] = Variable<String>(attachments);
    map['reactions'] = Variable<String>(reactions);
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
      content:
          content == null && nullToAbsent
              ? const Value.absent()
              : Value(content),
      nonce:
          nonce == null && nullToAbsent ? const Value.absent() : Value(nonce),
      data: Value(data),
      createdAt: Value(createdAt),
      status: Value(status),
      isDeleted:
          isDeleted == null && nullToAbsent
              ? const Value.absent()
              : Value(isDeleted),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      type: Value(type),
      meta: Value(meta),
      membersMentioned: Value(membersMentioned),
      editedAt:
          editedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(editedAt),
      attachments: Value(attachments),
      reactions: Value(reactions),
      repliedMessageId:
          repliedMessageId == null && nullToAbsent
              ? const Value.absent()
              : Value(repliedMessageId),
      forwardedMessageId:
          forwardedMessageId == null && nullToAbsent
              ? const Value.absent()
              : Value(forwardedMessageId),
    );
  }

  factory ChatMessagesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessagesData(
      id: serializer.fromJson<String>(json['id']),
      roomId: serializer.fromJson<String>(json['roomId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      content: serializer.fromJson<String?>(json['content']),
      nonce: serializer.fromJson<String?>(json['nonce']),
      data: serializer.fromJson<String>(json['data']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: serializer.fromJson<int>(json['status']),
      isDeleted: serializer.fromJson<bool?>(json['isDeleted']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      type: serializer.fromJson<String>(json['type']),
      meta: serializer.fromJson<String>(json['meta']),
      membersMentioned: serializer.fromJson<String>(json['membersMentioned']),
      editedAt: serializer.fromJson<DateTime?>(json['editedAt']),
      attachments: serializer.fromJson<String>(json['attachments']),
      reactions: serializer.fromJson<String>(json['reactions']),
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
      'status': serializer.toJson<int>(status),
      'isDeleted': serializer.toJson<bool?>(isDeleted),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'type': serializer.toJson<String>(type),
      'meta': serializer.toJson<String>(meta),
      'membersMentioned': serializer.toJson<String>(membersMentioned),
      'editedAt': serializer.toJson<DateTime?>(editedAt),
      'attachments': serializer.toJson<String>(attachments),
      'reactions': serializer.toJson<String>(reactions),
      'repliedMessageId': serializer.toJson<String?>(repliedMessageId),
      'forwardedMessageId': serializer.toJson<String?>(forwardedMessageId),
    };
  }

  ChatMessagesData copyWith({
    String? id,
    String? roomId,
    String? senderId,
    Value<String?> content = const Value.absent(),
    Value<String?> nonce = const Value.absent(),
    String? data,
    DateTime? createdAt,
    int? status,
    Value<bool?> isDeleted = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    String? type,
    String? meta,
    String? membersMentioned,
    Value<DateTime?> editedAt = const Value.absent(),
    String? attachments,
    String? reactions,
    Value<String?> repliedMessageId = const Value.absent(),
    Value<String?> forwardedMessageId = const Value.absent(),
  }) => ChatMessagesData(
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
    repliedMessageId:
        repliedMessageId.present
            ? repliedMessageId.value
            : this.repliedMessageId,
    forwardedMessageId:
        forwardedMessageId.present
            ? forwardedMessageId.value
            : this.forwardedMessageId,
  );
  ChatMessagesData copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessagesData(
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
      membersMentioned:
          data.membersMentioned.present
              ? data.membersMentioned.value
              : this.membersMentioned,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      attachments:
          data.attachments.present ? data.attachments.value : this.attachments,
      reactions: data.reactions.present ? data.reactions.value : this.reactions,
      repliedMessageId:
          data.repliedMessageId.present
              ? data.repliedMessageId.value
              : this.repliedMessageId,
      forwardedMessageId:
          data.forwardedMessageId.present
              ? data.forwardedMessageId.value
              : this.forwardedMessageId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesData(')
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
      (other is ChatMessagesData &&
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

class ChatMessagesCompanion extends UpdateCompanion<ChatMessagesData> {
  final Value<String> id;
  final Value<String> roomId;
  final Value<String> senderId;
  final Value<String?> content;
  final Value<String?> nonce;
  final Value<String> data;
  final Value<DateTime> createdAt;
  final Value<int> status;
  final Value<bool?> isDeleted;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> type;
  final Value<String> meta;
  final Value<String> membersMentioned;
  final Value<DateTime?> editedAt;
  final Value<String> attachments;
  final Value<String> reactions;
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
    required int status,
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
  static Insertable<ChatMessagesData> custom({
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
    Value<int>? status,
    Value<bool?>? isDeleted,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? type,
    Value<String>? meta,
    Value<String>? membersMentioned,
    Value<DateTime?>? editedAt,
    Value<String>? attachments,
    Value<String>? reactions,
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
      map['status'] = Variable<int>(status.value);
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
      map['meta'] = Variable<String>(meta.value);
    }
    if (membersMentioned.present) {
      map['members_mentioned'] = Variable<String>(membersMentioned.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    if (attachments.present) {
      map['attachments'] = Variable<String>(attachments.value);
    }
    if (reactions.present) {
      map['reactions'] = Variable<String>(reactions.value);
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

class PostDrafts extends Table with TableInfo<PostDrafts, PostDraftsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PostDrafts(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<int> visibility = GeneratedColumn<int>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('0'),
  );
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostDraftsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostDraftsData(
      id:
          attachedDatabase.typeMapping.read(
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
      visibility:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}visibility'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}type'],
          )!,
      lastModified:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}last_modified'],
          )!,
      postData:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}post_data'],
          )!,
    );
  }

  @override
  PostDrafts createAlias(String alias) {
    return PostDrafts(attachedDatabase, alias);
  }
}

class PostDraftsData extends DataClass implements Insertable<PostDraftsData> {
  final String id;
  final String? title;
  final String? description;
  final String? content;
  final int visibility;
  final int type;
  final DateTime lastModified;
  final String postData;
  const PostDraftsData({
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
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      content:
          content == null && nullToAbsent
              ? const Value.absent()
              : Value(content),
      visibility: Value(visibility),
      type: Value(type),
      lastModified: Value(lastModified),
      postData: Value(postData),
    );
  }

  factory PostDraftsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostDraftsData(
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

  PostDraftsData copyWith({
    String? id,
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> content = const Value.absent(),
    int? visibility,
    int? type,
    DateTime? lastModified,
    String? postData,
  }) => PostDraftsData(
    id: id ?? this.id,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    content: content.present ? content.value : this.content,
    visibility: visibility ?? this.visibility,
    type: type ?? this.type,
    lastModified: lastModified ?? this.lastModified,
    postData: postData ?? this.postData,
  );
  PostDraftsData copyWithCompanion(PostDraftsCompanion data) {
    return PostDraftsData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      content: data.content.present ? data.content.value : this.content,
      visibility:
          data.visibility.present ? data.visibility.value : this.visibility,
      type: data.type.present ? data.type.value : this.type,
      lastModified:
          data.lastModified.present
              ? data.lastModified.value
              : this.lastModified,
      postData: data.postData.present ? data.postData.value : this.postData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostDraftsData(')
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
      (other is PostDraftsData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.content == this.content &&
          other.visibility == this.visibility &&
          other.type == this.type &&
          other.lastModified == this.lastModified &&
          other.postData == this.postData);
}

class PostDraftsCompanion extends UpdateCompanion<PostDraftsData> {
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
  static Insertable<PostDraftsData> custom({
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

class DatabaseAtV7 extends GeneratedDatabase {
  DatabaseAtV7(QueryExecutor e) : super(e);
  late final ChatRooms chatRooms = ChatRooms(this);
  late final ChatMembers chatMembers = ChatMembers(this);
  late final ChatMessages chatMessages = ChatMessages(this);
  late final PostDrafts postDrafts = PostDrafts(this);
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
  @override
  int get schemaVersion => 7;
}
