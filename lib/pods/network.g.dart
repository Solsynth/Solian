// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NetworkStatusNotifier)
const networkStatusProvider = NetworkStatusNotifierProvider._();

final class NetworkStatusNotifierProvider
    extends $NotifierProvider<NetworkStatusNotifier, NetworkStatus> {
  const NetworkStatusNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkStatusNotifierHash();

  @$internal
  @override
  NetworkStatusNotifier create() => NetworkStatusNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkStatus>(value),
    );
  }
}

String _$networkStatusNotifierHash() =>
    r'ca968c342be79cb97349fb95eee5c575d7076a99';

abstract class _$NetworkStatusNotifier extends $Notifier<NetworkStatus> {
  NetworkStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<NetworkStatus, NetworkStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NetworkStatus, NetworkStatus>,
              NetworkStatus,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
