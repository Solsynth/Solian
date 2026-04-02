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
          AsyncValue<List<SnAuthDeviceWithSession>>,
          List<SnAuthDeviceWithSession>,
          FutureOr<List<SnAuthDeviceWithSession>>
        >
    with
        $FutureModifier<List<SnAuthDeviceWithSession>>,
        $FutureProvider<List<SnAuthDeviceWithSession>> {
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
  $FutureProviderElement<List<SnAuthDeviceWithSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnAuthDeviceWithSession>> create(Ref ref) {
    return authDevices(ref);
  }
}

String _$authDevicesHash() => r'bd259f30579b30dc40b41fade45343667be28c6f';

@ProviderFor(authSessions)
final authSessionsProvider = AuthSessionsProvider._();

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
  AuthSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSessionsHash();

  @$internal
  @override
  $FutureProviderElement<PaginatedResult<SnAuthSession>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedResult<SnAuthSession>> create(Ref ref) {
    return authSessions(ref);
  }
}

String _$authSessionsHash() => r'5dc9131c00c0951191f305ff0c175c33b6a19f2d';
