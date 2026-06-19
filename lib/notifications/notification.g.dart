// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationUnreadCountNotifier)
final notificationUnreadCountProvider =
    NotificationUnreadCountNotifierProvider._();

final class NotificationUnreadCountNotifierProvider
    extends $AsyncNotifierProvider<NotificationUnreadCountNotifier, int> {
  NotificationUnreadCountNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationUnreadCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationUnreadCountNotifierHash();

  @$internal
  @override
  NotificationUnreadCountNotifier create() => NotificationUnreadCountNotifier();
}

String _$notificationUnreadCountNotifierHash() =>
    r'e99d1050bb33d3f679090249caebc6b602f5c02a';

abstract class _$NotificationUnreadCountNotifier extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
