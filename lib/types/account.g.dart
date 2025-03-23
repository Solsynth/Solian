// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnAccount _$SnAccountFromJson(Map<String, dynamic> json) => _SnAccount(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      confirmedAt: json['confirmed_at'] == null
          ? null
          : DateTime.parse(json['confirmed_at'] as String),
      contacts: (json['contacts'] as List<dynamic>?)
          ?.map((e) => SnAccountContact.fromJson(e as Map<String, dynamic>))
          .toList(),
      avatar: json['avatar'] as String? ?? "",
      banner: json['banner'] as String? ?? "",
      name: json['name'] as String,
      nick: json['nick'] as String,
      permNodes: json['perm_nodes'] as Map<String, dynamic>? ?? const {},
      language: json['language'] as String,
      profile: json['profile'] == null
          ? null
          : SnAccountProfile.fromJson(json['profile'] as Map<String, dynamic>),
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => SnAccountBadge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      suspendedAt: json['suspended_at'] == null
          ? null
          : DateTime.parse(json['suspended_at'] as String),
      affiliatedId: (json['affiliated_id'] as num?)?.toInt(),
      affiliatedTo: (json['affiliated_to'] as num?)?.toInt(),
      automatedBy: (json['automated_by'] as num?)?.toInt(),
      automatedId: (json['automated_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SnAccountToJson(_SnAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'confirmed_at': instance.confirmedAt?.toIso8601String(),
      'contacts': instance.contacts?.map((e) => e.toJson()).toList(),
      'avatar': instance.avatar,
      'banner': instance.banner,
      'name': instance.name,
      'nick': instance.nick,
      'perm_nodes': instance.permNodes,
      'language': instance.language,
      'profile': instance.profile?.toJson(),
      'badges': instance.badges.map((e) => e.toJson()).toList(),
      'suspended_at': instance.suspendedAt?.toIso8601String(),
      'affiliated_id': instance.affiliatedId,
      'affiliated_to': instance.affiliatedTo,
      'automated_by': instance.automatedBy,
      'automated_id': instance.automatedId,
    };

_SnAccountContact _$SnAccountContactFromJson(Map<String, dynamic> json) =>
    _SnAccountContact(
      accountId: (json['account_id'] as num).toInt(),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      id: (json['id'] as num).toInt(),
      isPrimary: json['is_primary'] as bool,
      isPublic: json['is_public'] as bool,
      type: (json['type'] as num).toInt(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      verifiedAt: json['verified_at'] == null
          ? null
          : DateTime.parse(json['verified_at'] as String),
    );

Map<String, dynamic> _$SnAccountContactToJson(_SnAccountContact instance) =>
    <String, dynamic>{
      'account_id': instance.accountId,
      'content': instance.content,
      'created_at': instance.createdAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'id': instance.id,
      'is_primary': instance.isPrimary,
      'is_public': instance.isPublic,
      'type': instance.type,
      'updated_at': instance.updatedAt.toIso8601String(),
      'verified_at': instance.verifiedAt?.toIso8601String(),
    };

_SnAccountProfile _$SnAccountProfileFromJson(Map<String, dynamic> json) =>
    _SnAccountProfile(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      description: json['description'] as String,
      timeZone: json['time_zone'] as String,
      location: json['location'] as String,
      pronouns: json['pronouns'] as String,
      gender: json['gender'] as String,
      links: (json['links'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      experience: (json['experience'] as num).toInt(),
      lastSeenAt: json['last_seen_at'] == null
          ? null
          : DateTime.parse(json['last_seen_at'] as String),
      birthday: json['birthday'] == null
          ? null
          : DateTime.parse(json['birthday'] as String),
      accountId: (json['account_id'] as num).toInt(),
    );

Map<String, dynamic> _$SnAccountProfileToJson(_SnAccountProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'description': instance.description,
      'time_zone': instance.timeZone,
      'location': instance.location,
      'pronouns': instance.pronouns,
      'gender': instance.gender,
      'links': instance.links,
      'experience': instance.experience,
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
      'birthday': instance.birthday?.toIso8601String(),
      'account_id': instance.accountId,
    };

_SnRelationship _$SnRelationshipFromJson(Map<String, dynamic> json) =>
    _SnRelationship(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      accountId: (json['account_id'] as num).toInt(),
      relatedId: (json['related_id'] as num).toInt(),
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      related: json['related'] == null
          ? null
          : SnAccount.fromJson(json['related'] as Map<String, dynamic>),
      status: (json['status'] as num).toInt(),
      permNodes: json['perm_nodes'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SnRelationshipToJson(_SnRelationship instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'account_id': instance.accountId,
      'related_id': instance.relatedId,
      'account': instance.account?.toJson(),
      'related': instance.related?.toJson(),
      'status': instance.status,
      'perm_nodes': instance.permNodes,
    };

_SnAccountBadge _$SnAccountBadgeFromJson(Map<String, dynamic> json) =>
    _SnAccountBadge(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'],
      type: json['type'] as String,
      accountId: (json['account_id'] as num).toInt(),
      isActive: json['is_active'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SnAccountBadgeToJson(_SnAccountBadge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt,
      'type': instance.type,
      'account_id': instance.accountId,
      'is_active': instance.isActive,
      'metadata': instance.metadata,
    };

_SnAccountStatusInfo _$SnAccountStatusInfoFromJson(Map<String, dynamic> json) =>
    _SnAccountStatusInfo(
      isDisturbable: json['is_disturbable'] as bool,
      isOnline: json['is_online'] as bool,
      lastSeenAt: json['last_seen_at'] == null
          ? null
          : DateTime.parse(json['last_seen_at'] as String),
      status: json['status'] == null
          ? null
          : SnAccountStatus.fromJson(json['status'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SnAccountStatusInfoToJson(
        _SnAccountStatusInfo instance) =>
    <String, dynamic>{
      'is_disturbable': instance.isDisturbable,
      'is_online': instance.isOnline,
      'last_seen_at': instance.lastSeenAt?.toIso8601String(),
      'status': instance.status?.toJson(),
    };

_SnAccountStatus _$SnAccountStatusFromJson(Map<String, dynamic> json) =>
    _SnAccountStatus(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      type: json['type'] as String,
      label: json['label'] as String,
      attitude: (json['attitude'] as num).toInt(),
      isNoDisturb: json['is_no_disturb'] as bool,
      isInvisible: json['is_invisible'] as bool,
      clearAt: json['clear_at'] == null
          ? null
          : DateTime.parse(json['clear_at'] as String),
      accountId: (json['account_id'] as num).toInt(),
    );

Map<String, dynamic> _$SnAccountStatusToJson(_SnAccountStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'type': instance.type,
      'label': instance.label,
      'attitude': instance.attitude,
      'is_no_disturb': instance.isNoDisturb,
      'is_invisible': instance.isInvisible,
      'clear_at': instance.clearAt?.toIso8601String(),
      'account_id': instance.accountId,
    };

_SnAbuseReport _$SnAbuseReportFromJson(Map<String, dynamic> json) =>
    _SnAbuseReport(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      resource: json['resource'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      accountId: (json['account_id'] as num).toInt(),
    );

Map<String, dynamic> _$SnAbuseReportToJson(_SnAbuseReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'resource': instance.resource,
      'reason': instance.reason,
      'status': instance.status,
      'account_id': instance.accountId,
    };

_SnActionEvent _$SnActionEventFromJson(Map<String, dynamic> json) =>
    _SnActionEvent(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      type: json['type'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      location: json['location'] as String?,
      coordinateX: (json['coordinate_x'] as num?)?.toDouble(),
      coordinateY: (json['coordinate_y'] as num?)?.toDouble(),
      ipAddress: json['ip_address'] as String,
      userAgent: json['user_agent'] as String,
      account: SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      accountId: (json['account_id'] as num).toInt(),
    );

Map<String, dynamic> _$SnActionEventToJson(_SnActionEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'type': instance.type,
      'metadata': instance.metadata,
      'location': instance.location,
      'coordinate_x': instance.coordinateX,
      'coordinate_y': instance.coordinateY,
      'ip_address': instance.ipAddress,
      'user_agent': instance.userAgent,
      'account': instance.account.toJson(),
      'account_id': instance.accountId,
    };

_SnProgram _$SnProgramFromJson(Map<String, dynamic> json) => _SnProgram(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      alias: json['alias'] as String,
      expRequirement: (json['exp_requirement'] as num).toInt(),
      price: json['price'] as Map<String, dynamic>,
      badge: json['badge'] as Map<String, dynamic>,
      group: json['group'] as Map<String, dynamic>,
      appearance: json['appearance'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SnProgramToJson(_SnProgram instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'name': instance.name,
      'description': instance.description,
      'alias': instance.alias,
      'exp_requirement': instance.expRequirement,
      'price': instance.price,
      'badge': instance.badge,
      'group': instance.group,
      'appearance': instance.appearance,
    };

_SnProgramMember _$SnProgramMemberFromJson(Map<String, dynamic> json) =>
    _SnProgramMember(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      lastPaid: DateTime.parse(json['last_paid'] as String),
      account: SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      accountId: (json['account_id'] as num).toInt(),
      program: SnProgram.fromJson(json['program'] as Map<String, dynamic>),
      programId: (json['program_id'] as num).toInt(),
    );

Map<String, dynamic> _$SnProgramMemberToJson(_SnProgramMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'last_paid': instance.lastPaid.toIso8601String(),
      'account': instance.account.toJson(),
      'account_id': instance.accountId,
      'program': instance.program.toJson(),
      'program_id': instance.programId,
    };
