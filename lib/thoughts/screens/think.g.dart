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

@ProviderFor(deleteThoughtSequence)
final deleteThoughtSequenceProvider = DeleteThoughtSequenceFamily._();

final class DeleteThoughtSequenceProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  DeleteThoughtSequenceProvider._({
    required DeleteThoughtSequenceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deleteThoughtSequenceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteThoughtSequenceHash();

  @override
  String toString() {
    return r'deleteThoughtSequenceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return deleteThoughtSequence(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteThoughtSequenceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteThoughtSequenceHash() =>
    r'ddd1c74e9b97af23f372b4a8f3d6d8bc24e3cbd6';

final class DeleteThoughtSequenceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  DeleteThoughtSequenceFamily._()
    : super(
        retry: null,
        name: r'deleteThoughtSequenceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteThoughtSequenceProvider call(String sequenceId) =>
      DeleteThoughtSequenceProvider._(argument: sequenceId, from: this);

  @override
  String toString() => r'deleteThoughtSequenceProvider';
}

@ProviderFor(updateThoughtSequenceSharing)
final updateThoughtSequenceSharingProvider =
    UpdateThoughtSequenceSharingFamily._();

final class UpdateThoughtSequenceSharingProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  UpdateThoughtSequenceSharingProvider._({
    required UpdateThoughtSequenceSharingFamily super.from,
    required (String, {bool isPublic}) super.argument,
  }) : super(
         retry: null,
         name: r'updateThoughtSequenceSharingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$updateThoughtSequenceSharingHash();

  @override
  String toString() {
    return r'updateThoughtSequenceSharingProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (String, {bool isPublic});
    return updateThoughtSequenceSharing(
      ref,
      argument.$1,
      isPublic: argument.isPublic,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateThoughtSequenceSharingProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateThoughtSequenceSharingHash() =>
    r'a3545aefefe4a78c02d7e36bbc09ea1e095a1c11';

final class UpdateThoughtSequenceSharingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, (String, {bool isPublic})> {
  UpdateThoughtSequenceSharingFamily._()
    : super(
        retry: null,
        name: r'updateThoughtSequenceSharingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UpdateThoughtSequenceSharingProvider call(
    String sequenceId, {
    required bool isPublic,
  }) => UpdateThoughtSequenceSharingProvider._(
    argument: (sequenceId, isPublic: isPublic),
    from: this,
  );

  @override
  String toString() => r'updateThoughtSequenceSharingProvider';
}

@ProviderFor(markThoughtSequenceAsRead)
final markThoughtSequenceAsReadProvider = MarkThoughtSequenceAsReadFamily._();

final class MarkThoughtSequenceAsReadProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  MarkThoughtSequenceAsReadProvider._({
    required MarkThoughtSequenceAsReadFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'markThoughtSequenceAsReadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$markThoughtSequenceAsReadHash();

  @override
  String toString() {
    return r'markThoughtSequenceAsReadProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return markThoughtSequenceAsRead(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MarkThoughtSequenceAsReadProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$markThoughtSequenceAsReadHash() =>
    r'ed81846b259769c2922688b79372add11780a729';

final class MarkThoughtSequenceAsReadFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  MarkThoughtSequenceAsReadFamily._()
    : super(
        retry: null,
        name: r'markThoughtSequenceAsReadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MarkThoughtSequenceAsReadProvider call(String sequenceId) =>
      MarkThoughtSequenceAsReadProvider._(argument: sequenceId, from: this);

  @override
  String toString() => r'markThoughtSequenceAsReadProvider';
}
