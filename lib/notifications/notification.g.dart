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

/// Riverpod provider that creates a Dio instance for custom-app notification requests.

@ProviderFor(customAppNotificationDio)
final customAppNotificationDioProvider = CustomAppNotificationDioFamily._();

/// Riverpod provider that creates a Dio instance for custom-app notification requests.

final class CustomAppNotificationDioProvider
    extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Riverpod provider that creates a Dio instance for custom-app notification requests.
  CustomAppNotificationDioProvider._({
    required CustomAppNotificationDioFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'customAppNotificationDioProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customAppNotificationDioHash();

  @override
  String toString() {
    return r'customAppNotificationDioProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    final argument = this.argument as String;
    return customAppNotificationDio(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomAppNotificationDioProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customAppNotificationDioHash() =>
    r'cc46972f29b0bd11305da5c206692f0c28e99505';

/// Riverpod provider that creates a Dio instance for custom-app notification requests.

final class CustomAppNotificationDioFamily extends $Family
    with $FunctionalFamilyOverride<Dio, String> {
  CustomAppNotificationDioFamily._()
    : super(
        retry: null,
        name: r'customAppNotificationDioProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Riverpod provider that creates a Dio instance for custom-app notification requests.

  CustomAppNotificationDioProvider call(String apiKey) =>
      CustomAppNotificationDioProvider._(argument: apiKey, from: this);

  @override
  String toString() => r'customAppNotificationDioProvider';
}
