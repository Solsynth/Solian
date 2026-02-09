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

String _$authDevicesHash() => r'1af378149286020ec263be178c573ccc247a0cd1';
