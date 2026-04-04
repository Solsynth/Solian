// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_devices.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authDevices)
final authDevicesProvider = AuthDevicesProvider._();

final class AuthDevicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedResult<SnAuthDeviceWithSession>>,
          PaginatedResult<SnAuthDeviceWithSession>,
          FutureOr<PaginatedResult<SnAuthDeviceWithSession>>
        >
    with
        $FutureModifier<PaginatedResult<SnAuthDeviceWithSession>>,
        $FutureProvider<PaginatedResult<SnAuthDeviceWithSession>> {
  AuthDevicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authDevicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authDevicesHash();

  @$internal
  @override
  $FutureProviderElement<PaginatedResult<SnAuthDeviceWithSession>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedResult<SnAuthDeviceWithSession>> create(Ref ref) {
    return authDevices(ref);
  }
}

String _$authDevicesHash() => r'bda95cc18e9ac420379b3679a4d20c9bbbe7076e';

@ProviderFor(authSessions)
final authSessionsProvider = AuthSessionsFamily._();

final class AuthSessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedResult<SnAuthSession>>,
          PaginatedResult<SnAuthSession>,
          FutureOr<PaginatedResult<SnAuthSession>>
        >
    with
        $FutureModifier<PaginatedResult<SnAuthSession>>,
        $FutureProvider<PaginatedResult<SnAuthSession>> {
  AuthSessionsProvider._({
    required AuthSessionsFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'authSessionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$authSessionsHash();

  @override
  String toString() {
    return r'authSessionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PaginatedResult<SnAuthSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedResult<SnAuthSession>> create(Ref ref) {
    final argument = this.argument as int?;
    return authSessions(ref, type: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AuthSessionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$authSessionsHash() => r'8fd0b7791c7917c6e2209b1bee040f0ccd3654a7';

final class AuthSessionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedResult<SnAuthSession>>,
          int?
        > {
  AuthSessionsFamily._()
    : super(
        retry: null,
        name: r'authSessionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AuthSessionsProvider call({int? type}) =>
      AuthSessionsProvider._(argument: type, from: this);

  @override
  String toString() => r'authSessionsProvider';
}

@ProviderFor(SessionTypeFilter)
final sessionTypeFilterProvider = SessionTypeFilterProvider._();

final class SessionTypeFilterProvider
    extends $NotifierProvider<SessionTypeFilter, int?> {
  SessionTypeFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionTypeFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionTypeFilterHash();

  @$internal
  @override
  SessionTypeFilter create() => SessionTypeFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$sessionTypeFilterHash() => r'548b22f614e3e475871c87509fbeae2c647fc1cc';

abstract class _$SessionTypeFilter extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
