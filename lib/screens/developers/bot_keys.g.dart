// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_keys.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(botKeys)
final botKeysProvider = BotKeysFamily._();

final class BotKeysProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnAccountApiKey>>,
          List<SnAccountApiKey>,
          FutureOr<List<SnAccountApiKey>>
        >
    with
        $FutureModifier<List<SnAccountApiKey>>,
        $FutureProvider<List<SnAccountApiKey>> {
  BotKeysProvider._({
    required BotKeysFamily super.from,
    required (String, String, String) super.argument,
  }) : super(
         retry: null,
         name: r'botKeysProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$botKeysHash();

  @override
  String toString() {
    return r'botKeysProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnAccountApiKey>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnAccountApiKey>> create(Ref ref) {
    final argument = this.argument as (String, String, String);
    return botKeys(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is BotKeysProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$botKeysHash() => r'f7d1121833dc3da0cbd84b6171c2b2539edeb785';

final class BotKeysFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnAccountApiKey>>,
          (String, String, String)
        > {
  BotKeysFamily._()
    : super(
        retry: null,
        name: r'botKeysProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BotKeysProvider call(String publisherName, String projectId, String botId) =>
      BotKeysProvider._(
        argument: (publisherName, projectId, botId),
        from: this,
      );

  @override
  String toString() => r'botKeysProvider';
}
