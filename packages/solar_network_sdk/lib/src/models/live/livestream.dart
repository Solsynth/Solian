import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'livestream.freezed.dart';
part 'livestream.g.dart';

enum SnLiveStreamStatus {
  @JsonValue(0)
  pending,
  @JsonValue(1)
  active,
  @JsonValue(2)
  ended,
  @JsonValue(3)
  error,
}

enum SnLiveStreamType {
  @JsonValue(0)
  regular,
  @JsonValue(1)
  interactive,
}

enum SnLiveStreamVisibility {
  @JsonValue(0)
  public,
  @JsonValue(1)
  unlisted,
  @JsonValue(2)
  private,
}

@freezed
sealed class SnLiveStream with _$SnLiveStream {
  const factory SnLiveStream({
    required String id,
    String? title,
    String? description,
    String? slug,
    @Default(SnLiveStreamType.regular) SnLiveStreamType type,
    @Default(SnLiveStreamVisibility.public) SnLiveStreamVisibility visibility,
    @Default(SnLiveStreamStatus.pending) SnLiveStreamStatus status,
    required String roomName,
    String? ingressId,
    String? ingressStreamKey,
    String? egressId,
    String? hlsEgressId,
    String? hlsPlaylistPath,
    DateTime? hlsStartedAt,
    DateTime? startedAt,
    DateTime? endedAt,
    @Default(0) int viewerCount,
    @Default(0) int peakViewerCount,
    SnCloudFileReference? thumbnail,
    Map<String, dynamic>? metadata,
    String? publisherId,
    SnPublisher? publisher,
    String? resourceIdentifier,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _SnLiveStream;

  factory SnLiveStream.fromJson(Map<String, dynamic> json) =>
      _$SnLiveStreamFromJson(json);
}
