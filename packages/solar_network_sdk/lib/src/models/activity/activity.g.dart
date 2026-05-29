// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SnNotableDay _$SnNotableDayFromJson(Map<String, dynamic> json) =>
    _SnNotableDay(
      date: DateTime.parse(json['date'] as String),
      localName: json['local_name'] as String,
      globalName: json['global_name'] as String,
      countryCode: json['country_code'] as String?,
      localizableKey: json['localizable_key'] as String?,
      holidays: (json['holidays'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$SnNotableDayToJson(_SnNotableDay instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'local_name': instance.localName,
      'global_name': instance.globalName,
      'country_code': instance.countryCode,
      'localizable_key': instance.localizableKey,
      'holidays': instance.holidays,
    };

_SnTimelineEvent _$SnTimelineEventFromJson(Map<String, dynamic> json) =>
    _SnTimelineEvent(
      id: json['id'] as String,
      type: json['type'] as String,
      resourceIdentifier: json['resource_identifier'] as String,
      data: json['data'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnTimelineEventToJson(_SnTimelineEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'resource_identifier': instance.resourceIdentifier,
      'data': instance.data,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnCheckInResult _$SnCheckInResultFromJson(Map<String, dynamic> json) =>
    _SnCheckInResult(
      id: json['id'] as String,
      level: (json['level'] as num).toInt(),
      tips: (json['tips'] as List<dynamic>)
          .map((e) => SnFortuneTip.fromJson(e as Map<String, dynamic>))
          .toList(),
      fortuneReport: json['fortune_report'] == null
          ? null
          : SnCheckInFortuneReport.fromJson(
              json['fortune_report'] as Map<String, dynamic>,
            ),
      accountId: json['account_id'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnCheckInResultToJson(_SnCheckInResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'level': instance.level,
      'tips': instance.tips.map((e) => e.toJson()).toList(),
      'fortune_report': instance.fortuneReport?.toJson(),
      'account_id': instance.accountId,
      'account': instance.account?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnCheckInFortuneReport _$SnCheckInFortuneReportFromJson(
  Map<String, dynamic> json,
) => _SnCheckInFortuneReport(
  version: (json['version'] as num).toInt(),
  poem: json['poem'] as String,
  summary: json['summary'] as String,
  summaryDetail: json['summary_detail'] as String?,
  wish: json['wish'] as String,
  love: json['love'] as String,
  study: json['study'] as String,
  career: json['career'] as String,
  health: json['health'] as String,
  lostItem: json['lost_item'] as String,
  luckyColor: json['lucky_color'] as String,
  luckyDirection: json['lucky_direction'] as String,
  luckyTime: json['lucky_time'] as String,
  luckyItem: json['lucky_item'] as String,
  luckyAction: json['lucky_action'] as String,
  avoidAction: json['avoid_action'] as String,
  ritual: json['ritual'] as String,
);

Map<String, dynamic> _$SnCheckInFortuneReportToJson(
  _SnCheckInFortuneReport instance,
) => <String, dynamic>{
  'version': instance.version,
  'poem': instance.poem,
  'summary': instance.summary,
  'summary_detail': instance.summaryDetail,
  'wish': instance.wish,
  'love': instance.love,
  'study': instance.study,
  'career': instance.career,
  'health': instance.health,
  'lost_item': instance.lostItem,
  'lucky_color': instance.luckyColor,
  'lucky_direction': instance.luckyDirection,
  'lucky_time': instance.luckyTime,
  'lucky_item': instance.luckyItem,
  'lucky_action': instance.luckyAction,
  'avoid_action': instance.avoidAction,
  'ritual': instance.ritual,
};

_SnFortuneTip _$SnFortuneTipFromJson(Map<String, dynamic> json) =>
    _SnFortuneTip(
      isPositive: json['is_positive'] as bool,
      title: json['title'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$SnFortuneTipToJson(_SnFortuneTip instance) =>
    <String, dynamic>{
      'is_positive': instance.isPositive,
      'title': instance.title,
      'content': instance.content,
    };

_SnRecurrencePattern _$SnRecurrencePatternFromJson(Map<String, dynamic> json) =>
    _SnRecurrencePattern(
      frequency: (json['frequency'] as num).toInt(),
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      occurrences: (json['occurrences'] as num?)?.toInt(),
      daysOfWeek: (json['days_of_week'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dayOfMonth: (json['day_of_month'] as num?)?.toInt(),
      monthOfYear: (json['month_of_year'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SnRecurrencePatternToJson(
  _SnRecurrencePattern instance,
) => <String, dynamic>{
  'frequency': instance.frequency,
  'interval': instance.interval,
  'end_date': instance.endDate?.toIso8601String(),
  'occurrences': instance.occurrences,
  'days_of_week': instance.daysOfWeek,
  'day_of_month': instance.dayOfMonth,
  'month_of_year': instance.monthOfYear,
};

_SnUserCalendarEvent _$SnUserCalendarEventFromJson(Map<String, dynamic> json) =>
    _SnUserCalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      isAllDay: json['is_all_day'] as bool? ?? false,
      visibility:
          (json['visibility'] as num?)?.toInt() ?? SnEventVisibility.private,
      recurrence: json['recurrence'] == null
          ? null
          : SnRecurrencePattern.fromJson(
              json['recurrence'] as Map<String, dynamic>,
            ),
      meta: json['meta'] as Map<String, dynamic>?,
      accountId: json['account_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnUserCalendarEventToJson(
  _SnUserCalendarEvent instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'location': instance.location,
  'start_time': instance.startTime.toIso8601String(),
  'end_time': instance.endTime.toIso8601String(),
  'is_all_day': instance.isAllDay,
  'visibility': instance.visibility,
  'recurrence': instance.recurrence?.toJson(),
  'meta': instance.meta,
  'account_id': instance.accountId,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

_SnMergedCalendarEvent _$SnMergedCalendarEventFromJson(
  Map<String, dynamic> json,
) => _SnMergedCalendarEvent(
  id: json['id'] as String?,
  type: json['type'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  location: json['location'] as String?,
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
  isAllDay: json['is_all_day'] as bool? ?? false,
  meta: json['meta'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SnMergedCalendarEventToJson(
  _SnMergedCalendarEvent instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'title': instance.title,
  'description': instance.description,
  'location': instance.location,
  'start_time': instance.startTime.toIso8601String(),
  'end_time': instance.endTime.toIso8601String(),
  'is_all_day': instance.isAllDay,
  'meta': instance.meta,
};

_SnEventCalendarEntry _$SnEventCalendarEntryFromJson(
  Map<String, dynamic> json,
) => _SnEventCalendarEntry(
  date: DateTime.parse(json['date'] as String),
  checkInResult: json['check_in_result'] == null
      ? null
      : SnCheckInResult.fromJson(
          json['check_in_result'] as Map<String, dynamic>,
        ),
  statuses:
      (json['statuses'] as List<dynamic>?)
          ?.map((e) => SnAccountStatus.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  userEvents:
      (json['user_events'] as List<dynamic>?)
          ?.map((e) => SnUserCalendarEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  notableDays:
      (json['notable_days'] as List<dynamic>?)
          ?.map((e) => SnNotableDay.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  mergedEvents: (json['merged_events'] as List<dynamic>?)
      ?.map((e) => SnMergedCalendarEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SnEventCalendarEntryToJson(
  _SnEventCalendarEntry instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'check_in_result': instance.checkInResult?.toJson(),
  'statuses': instance.statuses.map((e) => e.toJson()).toList(),
  'user_events': instance.userEvents.map((e) => e.toJson()).toList(),
  'notable_days': instance.notableDays.map((e) => e.toJson()).toList(),
  'merged_events': instance.mergedEvents?.map((e) => e.toJson()).toList(),
};

_SnPresenceActivity _$SnPresenceActivityFromJson(Map<String, dynamic> json) =>
    _SnPresenceActivity(
      id: json['id'] as String,
      type: (json['type'] as num).toInt(),
      manualId: json['manual_id'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      caption: json['caption'] as String?,
      titleUrl: json['title_url'] as String?,
      subtitleUrl: json['subtitle_url'] as String?,
      smallImage: json['small_image'] as String?,
      largeImage: json['large_image'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
      leaseMinutes: (json['lease_minutes'] as num).toInt(),
      leaseExpiresAt: DateTime.parse(json['lease_expires_at'] as String),
      accountId: json['account_id'] as String,
      account: json['account'] == null
          ? null
          : SnAccount.fromJson(json['account'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$SnPresenceActivityToJson(_SnPresenceActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'manual_id': instance.manualId,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'caption': instance.caption,
      'title_url': instance.titleUrl,
      'subtitle_url': instance.subtitleUrl,
      'small_image': instance.smallImage,
      'large_image': instance.largeImage,
      'meta': instance.meta,
      'lease_minutes': instance.leaseMinutes,
      'lease_expires_at': instance.leaseExpiresAt.toIso8601String(),
      'account_id': instance.accountId,
      'account': instance.account?.toJson(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

_SnAccountTimelineItem _$SnAccountTimelineItemFromJson(
  Map<String, dynamic> json,
) => _SnAccountTimelineItem(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  eventType: (json['event_type'] as num).toInt(),
  activity: json['activity'] == null
      ? null
      : SnPresenceActivity.fromJson(json['activity'] as Map<String, dynamic>),
  status: json['status'] == null
      ? null
      : SnAccountStatus.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SnAccountTimelineItemToJson(
  _SnAccountTimelineItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'created_at': instance.createdAt.toIso8601String(),
  'event_type': instance.eventType,
  'activity': instance.activity?.toJson(),
  'status': instance.status?.toJson(),
};

_SnEventCountdownItem _$SnEventCountdownItemFromJson(
  Map<String, dynamic> json,
) => _SnEventCountdownItem(
  eventId: json['event_id'] as String?,
  eventType: (json['event_type'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  location: json['location'] as String?,
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
  isAllDay: json['is_all_day'] as bool? ?? false,
  daysRemaining: (json['days_remaining'] as num).toInt(),
  hoursRemaining: (json['hours_remaining'] as num).toInt(),
  isOngoing: json['is_ongoing'] as bool,
  meta: json['meta'] as Map<String, dynamic>?,
  accountId: json['account_id'] as String?,
);

Map<String, dynamic> _$SnEventCountdownItemToJson(
  _SnEventCountdownItem instance,
) => <String, dynamic>{
  'event_id': instance.eventId,
  'event_type': instance.eventType,
  'title': instance.title,
  'description': instance.description,
  'location': instance.location,
  'start_time': instance.startTime.toIso8601String(),
  'end_time': instance.endTime.toIso8601String(),
  'is_all_day': instance.isAllDay,
  'days_remaining': instance.daysRemaining,
  'hours_remaining': instance.hoursRemaining,
  'is_ongoing': instance.isOngoing,
  'meta': instance.meta,
  'account_id': instance.accountId,
};
