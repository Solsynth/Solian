import 'package:freezed_annotation/freezed_annotation.dart';

part 'publishing_settings.freezed.dart';
part 'publishing_settings.g.dart';

@freezed
sealed class SnPublishingSettings with _$SnPublishingSettings {
  const factory SnPublishingSettings({
    required String id,
    required String accountId,
    String? defaultPostingPublisherId,
    String? defaultReplyPublisherId,
    String? defaultFediversePublisherId,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _SnPublishingSettings;

  factory SnPublishingSettings.fromJson(Map<String, dynamic> json) =>
      _$SnPublishingSettingsFromJson(json);
}

@freezed
sealed class SnFediversePublisherAvailability
    with _$SnFediversePublisherAvailability {
  const factory SnFediversePublisherAvailability({
    required String publisherId,
    required String publisherName,
    required String fediverseHandle,
    required String fediverseUri,
    String? avatarUrl,
    required bool isEnabled,
    required int followersCount,
    required int followingCount,
    required int postsCount,
  }) = _SnFediversePublisherAvailability;

  factory SnFediversePublisherAvailability.fromJson(
    Map<String, dynamic> json,
  ) => _$SnFediversePublisherAvailabilityFromJson(json);
}

@freezed
sealed class SnFediverseAvailabilityResponse
    with _$SnFediverseAvailabilityResponse {
  const factory SnFediverseAvailabilityResponse({
    required bool isEnabled,
    required List<SnFediversePublisherAvailability> publishers,
  }) = _SnFediverseAvailabilityResponse;

  factory SnFediverseAvailabilityResponse.fromJson(Map<String, dynamic> json) =>
      _$SnFediverseAvailabilityResponseFromJson(json);
}
