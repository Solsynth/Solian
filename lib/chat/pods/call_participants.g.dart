// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_participants.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A cache for participant account data during active calls.
/// This provider keeps data alive for the duration of the call to avoid
/// repeated network requests when widgets rebuild.

@ProviderFor(CallParticipantAccountCache)
final callParticipantAccountCacheProvider =
    CallParticipantAccountCacheProvider._();

/// A cache for participant account data during active calls.
/// This provider keeps data alive for the duration of the call to avoid
/// repeated network requests when widgets rebuild.
final class CallParticipantAccountCacheProvider
    extends
        $NotifierProvider<
          CallParticipantAccountCache,
          Map<String, AsyncValue<SnAccount>>
        > {
  /// A cache for participant account data during active calls.
  /// This provider keeps data alive for the duration of the call to avoid
  /// repeated network requests when widgets rebuild.
  CallParticipantAccountCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'callParticipantAccountCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$callParticipantAccountCacheHash();

  @$internal
  @override
  CallParticipantAccountCache create() => CallParticipantAccountCache();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, AsyncValue<SnAccount>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, AsyncValue<SnAccount>>>(
        value,
      ),
    );
  }
}

String _$callParticipantAccountCacheHash() =>
    r'878a5af68cef1b9556d0a79a3bd8a620cc04946e';

/// A cache for participant account data during active calls.
/// This provider keeps data alive for the duration of the call to avoid
/// repeated network requests when widgets rebuild.

abstract class _$CallParticipantAccountCache
    extends $Notifier<Map<String, AsyncValue<SnAccount>>> {
  Map<String, AsyncValue<SnAccount>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, AsyncValue<SnAccount>>,
              Map<String, AsyncValue<SnAccount>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, AsyncValue<SnAccount>>,
                Map<String, AsyncValue<SnAccount>>
              >,
              Map<String, AsyncValue<SnAccount>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// A family provider that uses the cache for call participant accounts.
/// This is more efficient than accountProvider for call UI where widgets
/// rebuild frequently.

@ProviderFor(callParticipantAccount)
final callParticipantAccountProvider = CallParticipantAccountFamily._();

/// A family provider that uses the cache for call participant accounts.
/// This is more efficient than accountProvider for call UI where widgets
/// rebuild frequently.

final class CallParticipantAccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnAccount>,
          AsyncValue<SnAccount>,
          AsyncValue<SnAccount>
        >
    with $Provider<AsyncValue<SnAccount>> {
  /// A family provider that uses the cache for call participant accounts.
  /// This is more efficient than accountProvider for call UI where widgets
  /// rebuild frequently.
  CallParticipantAccountProvider._({
    required CallParticipantAccountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'callParticipantAccountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callParticipantAccountHash();

  @override
  String toString() {
    return r'callParticipantAccountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<SnAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<SnAccount> create(Ref ref) {
    final argument = this.argument as String;
    return callParticipantAccount(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<SnAccount> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<SnAccount>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CallParticipantAccountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callParticipantAccountHash() =>
    r'cda1394f0b996e64bf2bc4d19fdac35d3789ba14';

/// A family provider that uses the cache for call participant accounts.
/// This is more efficient than accountProvider for call UI where widgets
/// rebuild frequently.

final class CallParticipantAccountFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<SnAccount>, String> {
  CallParticipantAccountFamily._()
    : super(
        retry: null,
        name: r'callParticipantAccountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A family provider that uses the cache for call participant accounts.
  /// This is more efficient than accountProvider for call UI where widgets
  /// rebuild frequently.

  CallParticipantAccountProvider call(String identity) =>
      CallParticipantAccountProvider._(argument: identity, from: this);

  @override
  String toString() => r'callParticipantAccountProvider';
}
