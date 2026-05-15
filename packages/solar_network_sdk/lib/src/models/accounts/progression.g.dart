// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnProgressBadgeRewardDefinition _$SnProgressBadgeRewardDefinitionFromJson(
  Map<String, dynamic> json,
) => _SnProgressBadgeRewardDefinition(
  type: json['type'] as String,
  label: json['label'] as String?,
  caption: json['caption'] as String?,
  meta: json['meta'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SnProgressBadgeRewardDefinitionToJson(
  _SnProgressBadgeRewardDefinition instance,
) => <String, dynamic>{
  'type': instance.type,
  'label': instance.label,
  'caption': instance.caption,
  'meta': instance.meta,
};

_SnProgressRewardDefinition _$SnProgressRewardDefinitionFromJson(
  Map<String, dynamic> json,
) => _SnProgressRewardDefinition(
  experience: (json['experience'] as num?)?.toInt() ?? 0,
  sourcePoints: json['source_points'] as num? ?? 0,
  sourcePointsCurrency: json['source_points_currency'] as String? ?? 'points',
  badge: json['badge'] == null
      ? null
      : SnProgressBadgeRewardDefinition.fromJson(
          json['badge'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SnProgressRewardDefinitionToJson(
  _SnProgressRewardDefinition instance,
) => <String, dynamic>{
  'experience': instance.experience,
  'source_points': instance.sourcePoints,
  'source_points_currency': instance.sourcePointsCurrency,
  'badge': instance.badge?.toJson(),
};

_SnQuestScheduleConfig _$SnQuestScheduleConfigFromJson(
  Map<String, dynamic> json,
) => _SnQuestScheduleConfig(
  repeatability: json['repeatability'] as String? ?? 'none',
  activeDaysOfWeek:
      (json['active_days_of_week'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
);

Map<String, dynamic> _$SnQuestScheduleConfigToJson(
  _SnQuestScheduleConfig instance,
) => <String, dynamic>{
  'repeatability': instance.repeatability,
  'active_days_of_week': instance.activeDaysOfWeek,
};

_SnSeriesStage _$SnSeriesStageFromJson(Map<String, dynamic> json) =>
    _SnSeriesStage(
      identifier: json['identifier'] as String,
      title: json['title'] as String,
      seriesOrder: (json['series_order'] as num?)?.toInt() ?? 0,
      targetCount: (json['target_count'] as num?)?.toInt() ?? 1,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$SnSeriesStageToJson(_SnSeriesStage instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'title': instance.title,
      'series_order': instance.seriesOrder,
      'target_count': instance.targetCount,
      'is_completed': instance.isCompleted,
      'completed_at': instance.completedAt?.toIso8601String(),
    };

_SnAchievementStats _$SnAchievementStatsFromJson(Map<String, dynamic> json) =>
    _SnAchievementStats(
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      completedCount: (json['completed_count'] as num?)?.toInt() ?? 0,
      hiddenTotalCount: (json['hidden_total_count'] as num?)?.toInt() ?? 0,
      hiddenCompletedCount:
          (json['hidden_completed_count'] as num?)?.toInt() ?? 0,
      completionPercentage: json['completion_percentage'] as num? ?? 0,
    );

Map<String, dynamic> _$SnAchievementStatsToJson(_SnAchievementStats instance) =>
    <String, dynamic>{
      'total_count': instance.totalCount,
      'completed_count': instance.completedCount,
      'hidden_total_count': instance.hiddenTotalCount,
      'hidden_completed_count': instance.hiddenCompletedCount,
      'completion_percentage': instance.completionPercentage,
    };

_SnAchievementState _$SnAchievementStateFromJson(Map<String, dynamic> json) =>
    _SnAchievementState(
      identifier: json['identifier'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      icon: json['icon'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      hidden: json['hidden'] as bool? ?? false,
      isEnabled: json['is_enabled'] as bool? ?? true,
      targetCount: (json['target_count'] as num?)?.toInt() ?? 1,
      progressCount: (json['progress_count'] as num?)?.toInt() ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      reward: json['reward'] == null
          ? null
          : SnProgressRewardDefinition.fromJson(
              json['reward'] as Map<String, dynamic>,
            ),
      seriesIdentifier: json['series_identifier'] as String?,
      seriesTitle: json['series_title'] as String?,
      seriesOrder: (json['series_order'] as num?)?.toInt() ?? 0,
      seriesTotalSteps: (json['series_total_steps'] as num?)?.toInt() ?? 0,
      seriesCompletedSteps:
          (json['series_completed_steps'] as num?)?.toInt() ?? 0,
      seriesStages:
          (json['series_stages'] as List<dynamic>?)
              ?.map((e) => SnSeriesStage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SnAchievementStateToJson(_SnAchievementState instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'title': instance.title,
      'summary': instance.summary,
      'icon': instance.icon,
      'sort_order': instance.sortOrder,
      'hidden': instance.hidden,
      'is_enabled': instance.isEnabled,
      'target_count': instance.targetCount,
      'progress_count': instance.progressCount,
      'is_completed': instance.isCompleted,
      'completed_at': instance.completedAt?.toIso8601String(),
      'reward': instance.reward?.toJson(),
      'series_identifier': instance.seriesIdentifier,
      'series_title': instance.seriesTitle,
      'series_order': instance.seriesOrder,
      'series_total_steps': instance.seriesTotalSteps,
      'series_completed_steps': instance.seriesCompletedSteps,
      'series_stages': instance.seriesStages.map((e) => e.toJson()).toList(),
    };

_SnQuestState _$SnQuestStateFromJson(Map<String, dynamic> json) =>
    _SnQuestState(
      identifier: json['identifier'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      icon: json['icon'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      hidden: json['hidden'] as bool? ?? false,
      isEnabled: json['is_enabled'] as bool? ?? true,
      targetCount: (json['target_count'] as num?)?.toInt() ?? 1,
      progressCount: (json['progress_count'] as num?)?.toInt() ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      periodKey: json['period_key'] as String? ?? '',
      nextResetAt: json['next_reset_at'] == null
          ? null
          : DateTime.parse(json['next_reset_at'] as String),
      schedule: json['schedule'] == null
          ? null
          : SnQuestScheduleConfig.fromJson(
              json['schedule'] as Map<String, dynamic>,
            ),
      reward: json['reward'] == null
          ? null
          : SnProgressRewardDefinition.fromJson(
              json['reward'] as Map<String, dynamic>,
            ),
      seriesIdentifier: json['series_identifier'] as String?,
      seriesTitle: json['series_title'] as String?,
      seriesOrder: (json['series_order'] as num?)?.toInt() ?? 0,
      seriesTotalSteps: (json['series_total_steps'] as num?)?.toInt() ?? 0,
      seriesCompletedSteps:
          (json['series_completed_steps'] as num?)?.toInt() ?? 0,
      seriesStages:
          (json['series_stages'] as List<dynamic>?)
              ?.map((e) => SnSeriesStage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SnQuestStateToJson(_SnQuestState instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'title': instance.title,
      'summary': instance.summary,
      'icon': instance.icon,
      'sort_order': instance.sortOrder,
      'hidden': instance.hidden,
      'is_enabled': instance.isEnabled,
      'target_count': instance.targetCount,
      'progress_count': instance.progressCount,
      'is_completed': instance.isCompleted,
      'completed_at': instance.completedAt?.toIso8601String(),
      'period_key': instance.periodKey,
      'next_reset_at': instance.nextResetAt?.toIso8601String(),
      'schedule': instance.schedule?.toJson(),
      'reward': instance.reward?.toJson(),
      'series_identifier': instance.seriesIdentifier,
      'series_title': instance.seriesTitle,
      'series_order': instance.seriesOrder,
      'series_total_steps': instance.seriesTotalSteps,
      'series_completed_steps': instance.seriesCompletedSteps,
      'series_stages': instance.seriesStages.map((e) => e.toJson()).toList(),
    };

_SnProgressRewardGrant _$SnProgressRewardGrantFromJson(
  Map<String, dynamic> json,
) => _SnProgressRewardGrant(
  id: json['id'] as String,
  accountId: json['account_id'] as String,
  definitionType: json['definition_type'] as String? ?? 'achievement',
  definitionIdentifier: json['definition_identifier'] as String,
  definitionTitle: json['definition_title'] as String,
  rewardToken: json['reward_token'] as String,
  sourceEventId: json['source_event_id'] as String,
  reward: json['reward'] == null
      ? null
      : SnProgressRewardDefinition.fromJson(
          json['reward'] as Map<String, dynamic>,
        ),
  periodKey: json['period_key'] as String?,
  badgeGrantedAt: json['badge_granted_at'] == null
      ? null
      : DateTime.parse(json['badge_granted_at'] as String),
  experienceGrantedAt: json['experience_granted_at'] == null
      ? null
      : DateTime.parse(json['experience_granted_at'] as String),
  sourcePointsGrantedAt: json['source_points_granted_at'] == null
      ? null
      : DateTime.parse(json['source_points_granted_at'] as String),
  notificationSentAt: json['notification_sent_at'] == null
      ? null
      : DateTime.parse(json['notification_sent_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SnProgressRewardGrantToJson(
  _SnProgressRewardGrant instance,
) => <String, dynamic>{
  'id': instance.id,
  'account_id': instance.accountId,
  'definition_type': instance.definitionType,
  'definition_identifier': instance.definitionIdentifier,
  'definition_title': instance.definitionTitle,
  'reward_token': instance.rewardToken,
  'source_event_id': instance.sourceEventId,
  'reward': instance.reward?.toJson(),
  'period_key': instance.periodKey,
  'badge_granted_at': instance.badgeGrantedAt?.toIso8601String(),
  'experience_granted_at': instance.experienceGrantedAt?.toIso8601String(),
  'source_points_granted_at': instance.sourcePointsGrantedAt?.toIso8601String(),
  'notification_sent_at': instance.notificationSentAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_SnProgressionCompletedPacket _$SnProgressionCompletedPacketFromJson(
  Map<String, dynamic> json,
) => _SnProgressionCompletedPacket(
  kind: json['kind'] as String,
  identifier: json['identifier'] as String,
  title: json['title'] as String,
  periodKey: json['period_key'] as String?,
  reward: json['reward'] == null
      ? null
      : SnProgressRewardDefinition.fromJson(
          json['reward'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SnProgressionCompletedPacketToJson(
  _SnProgressionCompletedPacket instance,
) => <String, dynamic>{
  'kind': instance.kind,
  'identifier': instance.identifier,
  'title': instance.title,
  'period_key': instance.periodKey,
  'reward': instance.reward?.toJson(),
};
