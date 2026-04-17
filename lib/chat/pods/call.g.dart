// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CallNotifier)
final callProvider = CallNotifierProvider._();

final class CallNotifierProvider
    extends $NotifierProvider<CallNotifier, CallState> {
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

String _$callNotifierHash() => r'3b1265d92e88c9e61cdc0abe99d93c771f2b007e';

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
