// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_bot.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bot)
final botProvider = BotFamily._();

final class BotProvider
    extends $FunctionalProvider<AsyncValue<Bot?>, Bot?, FutureOr<Bot?>>
    with $FutureModifier<Bot?>, $FutureProvider<Bot?> {
  BotProvider._({
    required BotFamily super.from,
    required (String, String, String) super.argument,
  }) : super(
         retry: null,
         name: r'botProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$botHash();

  @override
  String toString() {
    return r'botProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Bot?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Bot?> create(Ref ref) {
    final argument = this.argument as (String, String, String);
    return bot(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is BotProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$botHash() => r'7bec47bb2a4061a5babc6d6d19c3d4c320c91188';

final class BotFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Bot?>, (String, String, String)> {
  BotFamily._()
    : super(
        retry: null,
        name: r'botProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BotProvider call(String publisherName, String projectId, String id) =>
      BotProvider._(argument: (publisherName, projectId, id), from: this);

  @override
  String toString() => r'botProvider';
}
