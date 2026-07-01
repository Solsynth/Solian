// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod wrapper that delegates all call logic to [CallController].
/// The controller is created lazily on first [joinRoom] call.

@ProviderFor(CallNotifier)
final callProvider = CallNotifierProvider._();

/// Riverpod wrapper that delegates all call logic to [CallController].
/// The controller is created lazily on first [joinRoom] call.
final class CallNotifierProvider
    extends $NotifierProvider<CallNotifier, CallState> {
  /// Riverpod wrapper that delegates all call logic to [CallController].
  /// The controller is created lazily on first [joinRoom] call.
  CallNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'callProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$callNotifierHash();

  @$internal
  @override
  CallNotifier create() => CallNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CallState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CallState>(value),
    );
  }
}

String _$callNotifierHash() => r'75e9581d88a65a525e65b01fa775d14ad6ab738f';

/// Riverpod wrapper that delegates all call logic to [CallController].
/// The controller is created lazily on first [joinRoom] call.

abstract class _$CallNotifier extends $Notifier<CallState> {
  CallState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CallState, CallState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CallState, CallState>,
              CallState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
