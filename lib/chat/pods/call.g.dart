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

String _$callNotifierHash() => r'20b29538f9803396d74af7d71e1f0c9de62cbd8e';

/// Riverpod wrapper that delegates all call logic to [CallController].
/// The controller is created lazily on first [joinRoom] call.

abstract class _$CallNotifier extends $Notifier<CallState> {
  CallState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CallState, CallState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CallState, CallState>,
              CallState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
