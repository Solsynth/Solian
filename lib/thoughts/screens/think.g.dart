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
    r'7ac13bc62bbaaf02d1f4eba6817aac97e92f2d65';

@ProviderFor(thoughtQuota)
final thoughtQuotaProvider = ThoughtQuotaProvider._();

final class ThoughtQuotaProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  ThoughtQuotaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thoughtQuotaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thoughtQuotaHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return thoughtQuota(ref);
  }
}

String _$thoughtQuotaHash() => r'94d87043dd3c900bdc9cdc508b828f51e5fd5c96';

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

String _$thoughtSequenceHash() => r'5a88c23e23066163ab8bcfd5bc204706b77d165e';

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

String _$thoughtServicesHash() => r'f46a3365a7de31f2257c67aa1512c4ec6bf83259';
