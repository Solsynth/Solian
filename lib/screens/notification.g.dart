// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationUnreadCountNotifierHash() =>
    r'08c773809958d96a7ce82acf04af1f9e0b23e119';

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
    r'260046e11f45b0d67ab25bcbdc8604890d71ccc7';

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
