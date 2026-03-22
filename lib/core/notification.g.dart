// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationState)
final notificationStateProvider = NotificationStateProvider._();

final class NotificationStateProvider
    extends $NotifierProvider<NotificationState, List<NotificationItem>> {
  NotificationStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationStateHash();

  @$internal
  @override
  NotificationState create() => NotificationState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<NotificationItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<NotificationItem>>(value),
    );
  }
}

String _$notificationStateHash() => r'4597cfc7c75dd0fd05dab65f78265a3ae10d23e7';

abstract class _$NotificationState extends $Notifier<List<NotificationItem>> {
  List<NotificationItem> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<List<NotificationItem>, List<NotificationItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<NotificationItem>, List<NotificationItem>>,
              List<NotificationItem>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
