// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnChannel _$SnChannelFromJson(Map<String, dynamic> json) => _SnChannel(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'],
      alias: json['alias'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => SnChannelMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => SnChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: (json['type'] as num).toInt(),
      accountId: (json['account_id'] as num).toInt(),
      realm: json['realm'] == null
          ? null
          : SnRealm.fromJson(json['realm'] as Map<String, dynamic>),
      realmId: (json['realm_id'] as num?)?.toInt(),
      isPublic: json['is_public'] as bool,
      isCommunity: json['is_community'] as bool,
    );

Map<String, dynamic> _$SnChannelToJson(_SnChannel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt,
      'alias': instance.alias,
      'name': instance.name,
      'description': instance.description,
      'members': instance.members?.map((e) => e.toJson()).toList(),
      'messages': instance.messages?.map((e) => e.toJson()).toList(),
      'type': instance.type,
      'account_id': instance.accountId,
      'realm': instance.realm?.toJson(),
      'realm_id': instance.realmId,
      'is_public': instance.isPublic,
      'is_community': instance.isCommunity,
    };

_SnChannelMember _$SnChannelMemberFromJson(Map<String, dynamic> json) =>
    _SnChannelMember(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      channelId: (json['channel_id'] as num).toInt(),
      accountId: (json['account_id'] as num).toInt(),
      nick: json['nick'] as String?,
      channel: json['channel'] == null
          ? null
          : SnChannel.fromJson(json['channel'] as Map<String, dynamic>),
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      notify: (json['notify'] as num?)?.toInt() ?? 0,
      powerLevel: (json['power_level'] as num).toInt(),
      calls: json['calls'],
      events: json['events'],
    );

Map<String, dynamic> _$SnChannelMemberToJson(_SnChannelMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'channel_id': instance.channelId,
      'account_id': instance.accountId,
      'nick': instance.nick,
      'channel': instance.channel?.toJson(),
      'account': instance.account?.toJson(),
      'notify': instance.notify,
      'power_level': instance.powerLevel,
      'calls': instance.calls,
      'events': instance.events,
    };

_SnChatMessage _$SnChatMessageFromJson(Map<String, dynamic> json) =>
    _SnChatMessage(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      uuid: json['uuid'] as String,
      body: json['body'] as Map<String, dynamic>? ?? const {},
      type: json['type'] as String,
      channel: SnChannel.fromJson(json['channel'] as Map<String, dynamic>),
      sender: SnChannelMember.fromJson(json['sender'] as Map<String, dynamic>),
      channelId: (json['channel_id'] as num).toInt(),
      senderId: (json['sender_id'] as num).toInt(),
      quoteEventId: (json['quote_event_id'] as num?)?.toInt(),
      relatedEventId: (json['related_event_id'] as num?)?.toInt(),
      preload: json['preload'] == null
          ? null
          : SnChatMessagePreload.fromJson(
              json['preload'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SnChatMessageToJson(_SnChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'uuid': instance.uuid,
      'body': instance.body,
      'type': instance.type,
      'channel': instance.channel.toJson(),
      'sender': instance.sender.toJson(),
      'channel_id': instance.channelId,
      'sender_id': instance.senderId,
      'quote_event_id': instance.quoteEventId,
      'related_event_id': instance.relatedEventId,
      'preload': instance.preload?.toJson(),
    };

_SnChatMessagePreload _$SnChatMessagePreloadFromJson(
        Map<String, dynamic> json) =>
    _SnChatMessagePreload(
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : SnAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      quoteEvent: json['quote_event'] == null
          ? null
          : SnChatMessage.fromJson(json['quote_event'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SnChatMessagePreloadToJson(
        _SnChatMessagePreload instance) =>
    <String, dynamic>{
      'attachments': instance.attachments?.map((e) => e?.toJson()).toList(),
      'quote_event': instance.quoteEvent?.toJson(),
    };

_SnChatCall _$SnChatCallFromJson(Map<String, dynamic> json) => _SnChatCall(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      externalId: json['external_id'] as String,
      founderId: (json['founder_id'] as num).toInt(),
      channelId: (json['channel_id'] as num).toInt(),
      founder:
          SnChannelMember.fromJson(json['founder'] as Map<String, dynamic>),
      participants: json['participants'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$SnChatCallToJson(_SnChatCall instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'ended_at': instance.endedAt?.toIso8601String(),
      'external_id': instance.externalId,
      'founder_id': instance.founderId,
      'channel_id': instance.channelId,
      'founder': instance.founder.toJson(),
      'participants': instance.participants,
    };
