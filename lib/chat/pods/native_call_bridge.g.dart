// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native_call_bridge.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Thin wrapper that listens to the native event channel and exposes
/// call state to Flutter widgets that need it (e.g., showing "in call" badges).

@ProviderFor(NativeCallBridge)
final nativeCallBridgeProvider = NativeCallBridgeProvider._();

/// Thin wrapper that listens to the native event channel and exposes
/// call state to Flutter widgets that need it (e.g., showing "in call" badges).
final class NativeCallBridgeProvider
    extends $NotifierProvider<NativeCallBridge, NativeCallState> {
  /// Thin wrapper that listens to the native event channel and exposes
  /// call state to Flutter widgets that need it (e.g., showing "in call" badges).
  NativeCallBridgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nativeCallBridgeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nativeCallBridgeHash();

  @$internal
  @override
  NativeCallBridge create() => NativeCallBridge();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NativeCallState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NativeCallState>(value),
    );
  }
}

String _$nativeCallBridgeHash() => r'fed609bfc11fb6e55d3a0902a7ae788d2d192c5c';

/// Thin wrapper that listens to the native event channel and exposes
/// call state to Flutter widgets that need it (e.g., showing "in call" badges).

abstract class _$NativeCallBridge extends $Notifier<NativeCallState> {
  NativeCallState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NativeCallState, NativeCallState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NativeCallState, NativeCallState>,
              NativeCallState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
