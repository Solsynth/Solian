import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'progression.freezed.dart';
part 'progression.g.dart';

@freezed
sealed class SnProgressBadgeRewardDefinition
    with _$SnProgressBadgeRewardDefinition {
  const factory SnProgressBadgeRewardDefinition({
    required String type,
    String? label,
    String? caption,
    Map<String, dynamic>? meta,
  }) = _SnProgressBadgeRewardDefinition;

  factory SnProgressBadgeRewardDefinition.fromJson(Map<String, dynamic> json) =>
      _$SnProgressBadgeRewardDefinitionFromJson(json);
}

@freezed
sealed class SnProgressRewardDefinition with _$SnProgressRewardDefinition {
  const factory SnProgressRewardDefinition({
    @Default(0) int experience,
    @Default(0) num sourcePoints,
    @Default('points') String sourcePointsCurrency,
    SnProgressBadgeRewardDefinition? badge,
  }) = _SnProgressRewardDefinition;

  factory SnProgressRewardDefinition.fromJson(Map<String, dynamic> json) =>
      _$SnProgressRewardDefinitionFromJson(json);
}

@freezed
sealed class SnQuestScheduleConfig with _$SnQuestScheduleConfig {
  const factory SnQuestScheduleConfig({
    @Default('none') String repeatability,
    @Default([]) List<int> activeDaysOfWeek,
  }) = _SnQuestScheduleConfig;

  factory SnQuestScheduleConfig.fromJson(Map<String, dynamic> json) =>
      _$SnQuestScheduleConfigFromJson(json);
}

@freezed
sealed class SnAchievementState with _$SnAchievementState {
  const factory SnAchievementState({
    required String identifier,
    required String title,
    required String summary,
    String? icon,
    @Default(0) int sortOrder,
    @Default(false) bool hidden,
    @Default(true) bool isEnabled,
    @Default(1) int targetCount,
    @Default(0) int progressCount,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    SnProgressRewardDefinition? reward,
  }) = _SnAchievementState;

  factory SnAchievementState.fromJson(Map<String, dynamic> json) =>
      _$SnAchievementStateFromJson(json);
}

@freezed
sealed class SnQuestState with _$SnQuestState {
  const factory SnQuestState({
    required String identifier,
    required String title,
    required String summary,
    String? icon,
    @Default(0) int sortOrder,
    @Default(false) bool hidden,
    @Default(true) bool isEnabled,
    @Default(1) int targetCount,
    @Default(0) int progressCount,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    @Default('') String periodKey,
    DateTime? nextResetAt,
    SnQuestScheduleConfig? schedule,
    SnProgressRewardDefinition? reward,
  }) = _SnQuestState;

  factory SnQuestState.fromJson(Map<String, dynamic> json) =>
      _$SnQuestStateFromJson(json);
}

@freezed
sealed class SnProgressRewardGrant with _$SnProgressRewardGrant {
  const factory SnProgressRewardGrant({
    required String id,
    required String accountId,
    @Default('achievement') String definitionType,
    required String definitionIdentifier,
    required String definitionTitle,
    required String rewardToken,
    required String sourceEventId,
    SnProgressRewardDefinition? reward,
    String? periodKey,
    DateTime? badgeGrantedAt,
    DateTime? experienceGrantedAt,
    DateTime? sourcePointsGrantedAt,
    DateTime? notificationSentAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SnProgressRewardGrant;

  factory SnProgressRewardGrant.fromJson(Map<String, dynamic> json) =>
      _$SnProgressRewardGrantFromJson(json);
}

@freezed
sealed class SnProgressionCompletedPacket with _$SnProgressionCompletedPacket {
  const factory SnProgressionCompletedPacket({
    required String kind,
    required String identifier,
    required String title,
    String? periodKey,
    SnProgressRewardDefinition? reward,
  }) = _SnProgressionCompletedPacket;

  factory SnProgressionCompletedPacket.fromJson(Map<String, dynamic> json) =>
      _$SnProgressionCompletedPacketFromJson(json);
}
