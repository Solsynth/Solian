// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livestream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnLiveStream _$SnLiveStreamFromJson(Map<String, dynamic> json) =>
    _SnLiveStream(
      id: json['id'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      slug: json['slug'] as String?,
      type:
          $enumDecodeNullable(_$SnLiveStreamTypeEnumMap, json['type']) ??
          SnLiveStreamType.regular,
      visibility:
          $enumDecodeNullable(
            _$SnLiveStreamVisibilityEnumMap,
            json['visibility'],
          ) ??
          SnLiveStreamVisibility.public,
      status:
          $enumDecodeNullable(_$SnLiveStreamStatusEnumMap, json['status']) ??
          SnLiveStreamStatus.pending,
      roomName: json['room_name'] as String,
      ingressId: json['ingress_id'] as String?,
      ingressStreamKey: json['ingress_stream_key'] as String?,
      egressId: json['egress_id'] as String?,
      hlsEgressId: json['hls_egress_id'] as String?,
      hlsPlaylistPath: json['hls_playlist_path'] as String?,
      hlsStartedAt: json['hls_started_at'] == null
          ? null
          : DateTime.parse(json['hls_started_at'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      viewerCount: (json['viewer_count'] as num?)?.toInt() ?? 0,
      peakViewerCount: (json['peak_viewer_count'] as num?)?.toInt() ?? 0,
      thumbnail: json['thumbnail'] == null
          ? null
          : SnCloudFileReference.fromJson(
              json['thumbnail'] as Map<String, dynamic>,
            ),
      metadata: json['metadata'] as Map<String, dynamic>?,
      publisherId: json['publisher_id'] as String?,
      publisher: json['publisher'] == null
          ? null
          : SnPublisher.fromJson(json['publisher'] as Map<String, dynamic>),
      resourceIdentifier: json['resource_identifier'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnLiveStreamToJson(_SnLiveStream instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'slug': instance.slug,
      'type': _$SnLiveStreamTypeEnumMap[instance.type]!,
      'visibility': _$SnLiveStreamVisibilityEnumMap[instance.visibility]!,
      'status': _$SnLiveStreamStatusEnumMap[instance.status]!,
      'room_name': instance.roomName,
      'ingress_id': instance.ingressId,
      'ingress_stream_key': instance.ingressStreamKey,
      'egress_id': instance.egressId,
      'hls_egress_id': instance.hlsEgressId,
      'hls_playlist_path': instance.hlsPlaylistPath,
      'hls_started_at': instance.hlsStartedAt?.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'ended_at': instance.endedAt?.toIso8601String(),
      'viewer_count': instance.viewerCount,
      'peak_viewer_count': instance.peakViewerCount,
      'thumbnail': instance.thumbnail?.toJson(),
      'metadata': instance.metadata,
      'publisher_id': instance.publisherId,
      'publisher': instance.publisher?.toJson(),
      'resource_identifier': instance.resourceIdentifier,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

const _$SnLiveStreamTypeEnumMap = {
  SnLiveStreamType.regular: 0,
  SnLiveStreamType.interactive: 1,
};

const _$SnLiveStreamVisibilityEnumMap = {
  SnLiveStreamVisibility.public: 0,
  SnLiveStreamVisibility.unlisted: 1,
  SnLiveStreamVisibility.private: 2,
};

const _$SnLiveStreamStatusEnumMap = {
  SnLiveStreamStatus.pending: 0,
  SnLiveStreamStatus.active: 1,
  SnLiveStreamStatus.ended: 2,
  SnLiveStreamStatus.error: 3,
};
