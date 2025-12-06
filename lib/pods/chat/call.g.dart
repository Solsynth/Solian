// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CallNotifier)
const callProvider = CallNotifierProvider._();

final class CallNotifierProvider
    extends $NotifierProvider<CallNotifier, CallState> {
  const CallNotifierProvider._()
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

String _$callNotifierHash() => r'ef4e3e9c9d411cf9dce1ceb456a3b866b2c87db3';

abstract class _$CallNotifier extends $Notifier<CallState> {
  CallState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CallState, CallState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CallState, CallState>,
              CallState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
