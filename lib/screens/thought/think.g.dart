// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'think.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(thoughtAvailableStaus)
final thoughtAvailableStausProvider = ThoughtAvailableStausProvider._();

final class ThoughtAvailableStausProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  ThoughtAvailableStausProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thoughtAvailableStausProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thoughtAvailableStausHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return thoughtAvailableStaus(ref);
  }
}

String _$thoughtAvailableStausHash() =>
    r'720e04e56bff8c4d4ca6854ce997da4e7926c84c';

@ProviderFor(thoughtSequence)
final thoughtSequenceProvider = ThoughtSequenceFamily._();

final class ThoughtSequenceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnThinkingThought>>,
          List<SnThinkingThought>,
          FutureOr<List<SnThinkingThought>>
        >
    with
        $FutureModifier<List<SnThinkingThought>>,
        $FutureProvider<List<SnThinkingThought>> {
  ThoughtSequenceProvider._({
    required ThoughtSequenceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'thoughtSequenceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$thoughtSequenceHash();

  @override
  String toString() {
    return r'thoughtSequenceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnThinkingThought>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnThinkingThought>> create(Ref ref) {
    final argument = this.argument as String;
    return thoughtSequence(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ThoughtSequenceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$thoughtSequenceHash() => r'2a93c0a04f9a720ba474c02a36502940fb7f3ed7';

final class ThoughtSequenceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SnThinkingThought>>, String> {
  ThoughtSequenceFamily._()
    : super(
        retry: null,
        name: r'thoughtSequenceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ThoughtSequenceProvider call(String sequenceId) =>
      ThoughtSequenceProvider._(argument: sequenceId, from: this);

  @override
  String toString() => r'thoughtSequenceProvider';
}

@ProviderFor(thoughtServices)
final thoughtServicesProvider = ThoughtServicesProvider._();

final class ThoughtServicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ThoughtServicesResponse>,
          ThoughtServicesResponse,
          FutureOr<ThoughtServicesResponse>
        >
    with
        $FutureModifier<ThoughtServicesResponse>,
        $FutureProvider<ThoughtServicesResponse> {
  ThoughtServicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thoughtServicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thoughtServicesHash();

  @$internal
  @override
  $FutureProviderElement<ThoughtServicesResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ThoughtServicesResponse> create(Ref ref) {
    return thoughtServices(ref);
  }
}

String _$thoughtServicesHash() => r'0ddeaec713ecfcdc9786c197f3d4cb41d36c26a5';
