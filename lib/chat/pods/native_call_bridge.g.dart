// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native_call_bridge.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NativeCallBridge)
final nativeCallBridgeProvider = NativeCallBridgeProvider._();

final class NativeCallBridgeProvider
    extends $NotifierProvider<NativeCallBridge, NativeCallState> {
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

String _$nativeCallBridgeHash() => r'5fbac832915489bdc089eb950a33abeeade0a8c0';

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
