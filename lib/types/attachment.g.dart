// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnAttachment _$SnAttachmentFromJson(Map<String, dynamic> json) =>
    _SnAttachment(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      rid: json['rid'] as String,
      uuid: json['uuid'] as String,
      size: (json['size'] as num).toInt(),
      name: json['name'] as String,
      alt: json['alt'] as String,
      mimetype: json['mimetype'] as String,
      hash: json['hash'] as String,
      destination: (json['destination'] as num).toInt(),
      refCount: (json['ref_count'] as num).toInt(),
      contentRating: (json['content_rating'] as num?)?.toInt() ?? 0,
      qualityRating: (json['quality_rating'] as num?)?.toInt() ?? 0,
      cleanedAt: json['cleaned_at'] == null
          ? null
          : DateTime.parse(json['cleaned_at'] as String),
      isAnalyzed: json['is_analyzed'] as bool,
      isSelfRef: json['is_self_ref'] as bool,
      isIndexable: json['is_indexable'] as bool,
      ref: json['ref'] == null
          ? null
          : SnAttachment.fromJson(json['ref'] as Map<String, dynamic>),
      refId: (json['ref_id'] as num?)?.toInt(),
      pool: json['pool'] == null
          ? null
          : SnAttachmentPool.fromJson(json['pool'] as Map<String, dynamic>),
      poolId: (json['pool_id'] as num?)?.toInt(),
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      accountId: (json['account_id'] as num).toInt(),
      thumbnailId: (json['thumbnail_id'] as num?)?.toInt(),
      thumbnail: json['thumbnail'] == null
          ? null
          : SnAttachment.fromJson(json['thumbnail'] as Map<String, dynamic>),
      compressedId: (json['compressed_id'] as num?)?.toInt(),
      compressed: json['compressed'] == null
          ? null
          : SnAttachment.fromJson(json['compressed'] as Map<String, dynamic>),
      boosts: (json['boosts'] as List<dynamic>?)
              ?.map(
                  (e) => SnAttachmentBoost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      usermeta: json['usermeta'] as Map<String, dynamic>? ?? const {},
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SnAttachmentToJson(_SnAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'rid': instance.rid,
      'uuid': instance.uuid,
      'size': instance.size,
      'name': instance.name,
      'alt': instance.alt,
      'mimetype': instance.mimetype,
      'hash': instance.hash,
      'destination': instance.destination,
      'ref_count': instance.refCount,
      'content_rating': instance.contentRating,
      'quality_rating': instance.qualityRating,
      'cleaned_at': instance.cleanedAt?.toIso8601String(),
      'is_analyzed': instance.isAnalyzed,
      'is_self_ref': instance.isSelfRef,
      'is_indexable': instance.isIndexable,
      'ref': instance.ref?.toJson(),
      'ref_id': instance.refId,
      'pool': instance.pool?.toJson(),
      'pool_id': instance.poolId,
      'account': instance.account?.toJson(),
      'account_id': instance.accountId,
      'thumbnail_id': instance.thumbnailId,
      'thumbnail': instance.thumbnail?.toJson(),
      'compressed_id': instance.compressedId,
      'compressed': instance.compressed?.toJson(),
      'boosts': instance.boosts.map((e) => e.toJson()).toList(),
      'usermeta': instance.usermeta,
      'metadata': instance.metadata,
    };

_SnAttachmentFragment _$SnAttachmentFragmentFromJson(
        Map<String, dynamic> json) =>
    _SnAttachmentFragment(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      rid: json['rid'] as String,
      uuid: json['uuid'] as String,
      size: (json['size'] as num).toInt(),
      name: json['name'] as String,
      alt: json['alt'] as String,
      mimetype: json['mimetype'] as String,
      hash: json['hash'] as String,
      fingerprint: json['fingerprint'] as String?,
      fileChunks: (json['file_chunks'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      fileChunksMissing: (json['file_chunks_missing'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SnAttachmentFragmentToJson(
        _SnAttachmentFragment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'rid': instance.rid,
      'uuid': instance.uuid,
      'size': instance.size,
      'name': instance.name,
      'alt': instance.alt,
      'mimetype': instance.mimetype,
      'hash': instance.hash,
      'fingerprint': instance.fingerprint,
      'file_chunks': instance.fileChunks,
      'file_chunks_missing': instance.fileChunksMissing,
    };

_SnAttachmentPool _$SnAttachmentPoolFromJson(Map<String, dynamic> json) =>
    _SnAttachmentPool(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      alias: json['alias'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      config: json['config'] as Map<String, dynamic>,
      accountId: (json['account_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SnAttachmentPoolToJson(_SnAttachmentPool instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'alias': instance.alias,
      'name': instance.name,
      'description': instance.description,
      'config': instance.config,
      'account_id': instance.accountId,
    };

_SnAttachmentDestination _$SnAttachmentDestinationFromJson(
        Map<String, dynamic> json) =>
    _SnAttachmentDestination(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String,
      label: json['label'] as String,
      region: json['region'] as String,
      isBoost: json['is_boost'] as bool,
    );

Map<String, dynamic> _$SnAttachmentDestinationToJson(
        _SnAttachmentDestination instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'label': instance.label,
      'region': instance.region,
      'is_boost': instance.isBoost,
    };

_SnAttachmentBoost _$SnAttachmentBoostFromJson(Map<String, dynamic> json) =>
    _SnAttachmentBoost(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      status: (json['status'] as num).toInt(),
      destination: (json['destination'] as num).toInt(),
      attachmentId: (json['attachment_id'] as num).toInt(),
      attachment:
          SnAttachment.fromJson(json['attachment'] as Map<String, dynamic>),
      account: (json['account'] as num).toInt(),
    );

Map<String, dynamic> _$SnAttachmentBoostToJson(_SnAttachmentBoost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'status': instance.status,
      'destination': instance.destination,
      'attachment_id': instance.attachmentId,
      'attachment': instance.attachment.toJson(),
      'account': instance.account,
    };

_SnSticker _$SnStickerFromJson(Map<String, dynamic> json) => _SnSticker(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      alias: json['alias'] as String,
      name: json['name'] as String,
      attachmentId: (json['attachment_id'] as num).toInt(),
      attachment:
          SnAttachment.fromJson(json['attachment'] as Map<String, dynamic>),
      packId: (json['pack_id'] as num).toInt(),
      pack: SnStickerPack.fromJson(json['pack'] as Map<String, dynamic>),
      accountId: (json['account_id'] as num).toInt(),
    );

Map<String, dynamic> _$SnStickerToJson(_SnSticker instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'alias': instance.alias,
      'name': instance.name,
      'attachment_id': instance.attachmentId,
      'attachment': instance.attachment.toJson(),
      'pack_id': instance.packId,
      'pack': instance.pack.toJson(),
      'account_id': instance.accountId,
    };

_SnStickerPack _$SnStickerPackFromJson(Map<String, dynamic> json) =>
    _SnStickerPack(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      prefix: json['prefix'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      stickers: (json['stickers'] as List<dynamic>?)
          ?.map((e) => SnSticker.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountId: (json['account_id'] as num).toInt(),
    );

Map<String, dynamic> _$SnStickerPackToJson(_SnStickerPack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
      'prefix': instance.prefix,
      'name': instance.name,
      'description': instance.description,
      'stickers': instance.stickers?.map((e) => e.toJson()).toList(),
      'account_id': instance.accountId,
    };

_SnAttachmentBilling _$SnAttachmentBillingFromJson(Map<String, dynamic> json) =>
    _SnAttachmentBilling(
      currentBytes: (json['current_bytes'] as num).toInt(),
      discountFileSize: (json['discount_file_size'] as num).toInt(),
      includedRatio: (json['included_ratio'] as num).toDouble(),
    );

Map<String, dynamic> _$SnAttachmentBillingToJson(
        _SnAttachmentBilling instance) =>
    <String, dynamic>{
      'current_bytes': instance.currentBytes,
      'discount_file_size': instance.discountFileSize,
      'included_ratio': instance.includedRatio,
    };
