// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_scaffold.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      data: SnNotification.fromJson(json['data'] as Map<String, dynamic>),
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'created_at': instance.createdAt?.toIso8601String(),
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appNotificationsHash() => r'8ab8b2b23f7f7953b05f08b90a57f495fd6f88d0';

/// See also [AppNotifications].
@ProviderFor(AppNotifications)
final appNotificationsProvider = AutoDisposeNotifierProvider<
  AppNotifications,
  List<AppNotification>
>.internal(
  AppNotifications.new,
  name: r'appNotificationsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppNotifications = AutoDisposeNotifier<List<AppNotification>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
