// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SnRealmImplAdapter extends TypeAdapter<_$SnRealmImpl> {
  @override
  final int typeId = 1;

  @override
  _$SnRealmImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$SnRealmImpl(
      id: fields[0] as int,
      createdAt: fields[1] as DateTime,
      updatedAt: fields[2] as DateTime,
      deletedAt: fields[3] as DateTime?,
      alias: fields[4] as String,
      name: fields[5] as String,
      description: fields[6] as String,
      avatar: fields[7] as String?,
      banner: fields[8] as String?,
      accessPolicy: (fields[9] as Map?)?.cast<String, dynamic>(),
      accountId: fields[10] as int,
      isPublic: fields[11] as bool,
      isCommunity: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, _$SnRealmImpl obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.updatedAt)
      ..writeByte(3)
      ..write(obj.deletedAt)
      ..writeByte(4)
      ..write(obj.alias)
      ..writeByte(5)
      ..write(obj.name)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.avatar)
      ..writeByte(8)
      ..write(obj.banner)
      ..writeByte(10)
      ..write(obj.accountId)
      ..writeByte(11)
      ..write(obj.isPublic)
      ..writeByte(12)
      ..write(obj.isCommunity)
      ..writeByte(9)
      ..write(obj.accessPolicy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SnRealmImplAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SnRealmMemberImpl _$$SnRealmMemberImplFromJson(Map<String, dynamic> json) =>
    _$SnRealmMemberImpl(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      realmId: (json['realm_id'] as num).toInt(),
      accountId: (json['account_id'] as num).toInt(),
      realm: SnRealm.fromJson(json['realm'] as Map<String, dynamic>),
      account: SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      powerLevel: (json['power_level'] as num).toInt(),
    );

Map<String, dynamic> _$$SnRealmMemberImplToJson(_$SnRealmMemberImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'realm_id': instance.realmId,
      'account_id': instance.accountId,
      'realm': instance.realm.toJson(),
      'account': instance.account.toJson(),
      'power_level': instance.powerLevel,
    };

_$SnRealmImpl _$$SnRealmImplFromJson(Map<String, dynamic> json) =>
    _$SnRealmImpl(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      alias: json['alias'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => SnRealmMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      avatar: json['avatar'] as String?,
      banner: json['banner'] as String?,
      accessPolicy: json['access_policy'] as Map<String, dynamic>?,
      accountId: (json['account_id'] as num).toInt(),
      isPublic: json['is_public'] as bool,
      isCommunity: json['is_community'] as bool,
      popularity: (json['popularity'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SnRealmImplToJson(_$SnRealmImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'alias': instance.alias,
      'name': instance.name,
      'description': instance.description,
      'members': instance.members?.map((e) => e.toJson()).toList(),
      'avatar': instance.avatar,
      'banner': instance.banner,
      'access_policy': instance.accessPolicy,
      'account_id': instance.accountId,
      'is_public': instance.isPublic,
      'is_community': instance.isCommunity,
      'popularity': instance.popularity,
    };
