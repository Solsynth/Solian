// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bots.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bots)
final botsProvider = BotsFamily._();

final class BotsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Bot>>,
          List<Bot>,
          FutureOr<List<Bot>>
        >
    with $FutureModifier<List<Bot>>, $FutureProvider<List<Bot>> {
  BotsProvider._({
    required BotsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'botsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$botsHash();

  @override
  String toString() {
    return r'botsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Bot>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Bot>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return bots(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is BotsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$botsHash() => r'15cefd5781350eb68208a342e85fcb0b9e0e3269';

final class BotsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Bot>>, (String, String)> {
  BotsFamily._()
    : super(
        retry: null,
        name: r'botsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BotsProvider call(String publisherName, String projectId) =>
      BotsProvider._(argument: (publisherName, projectId), from: this);

  @override
  String toString() => r'botsProvider';
}
