// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationUnreadCountNotifierHash() =>
    r'd199abf0d16944587e747798399a267a790341f3';

/// See also [NotificationUnreadCountNotifier].
@ProviderFor(NotificationUnreadCountNotifier)
final notificationUnreadCountNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      NotificationUnreadCountNotifier,
      int
    >.internal(
      NotificationUnreadCountNotifier.new,
      name: r'notificationUnreadCountNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$notificationUnreadCountNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationUnreadCountNotifier = AutoDisposeAsyncNotifier<int>;
String _$notificationListNotifierHash() =>
    r'934a47bc2ce9e75699a4f53e2169470fd0c04a53';

/// See also [NotificationListNotifier].
@ProviderFor(NotificationListNotifier)
final notificationListNotifierProvider = AutoDisposeAsyncNotifierProvider<
  NotificationListNotifier,
  CursorPagingData<SnNotification>
>.internal(
  NotificationListNotifier.new,
  name: r'notificationListNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationListNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationListNotifier =
    AutoDisposeAsyncNotifier<CursorPagingData<SnNotification>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
