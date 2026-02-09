// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_button.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ongoingCall)
final ongoingCallProvider = OngoingCallFamily._();

final class OngoingCallProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnRealtimeCall?>,
          SnRealtimeCall?,
          FutureOr<SnRealtimeCall?>
        >
    with $FutureModifier<SnRealtimeCall?>, $FutureProvider<SnRealtimeCall?> {
  OngoingCallProvider._({
    required OngoingCallFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ongoingCallProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ongoingCallHash();

  @override
  String toString() {
    return r'ongoingCallProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnRealtimeCall?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnRealtimeCall?> create(Ref ref) {
    final argument = this.argument as String;
    return ongoingCall(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OngoingCallProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ongoingCallHash() => r'3d1efaaca2981ebf698e9241453dbf2b2f13bfe3';

final class OngoingCallFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnRealtimeCall?>, String> {
  OngoingCallFamily._()
    : super(
        retry: null,
        name: r'ongoingCallProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OngoingCallProvider call(String roomId) =>
      OngoingCallProvider._(argument: roomId, from: this);

  @override
  String toString() => r'ongoingCallProvider';
}
