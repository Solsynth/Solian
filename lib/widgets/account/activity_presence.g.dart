// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_presence.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(discordAssets)
const discordAssetsProvider = DiscordAssetsFamily._();

final class DiscordAssetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>?>,
          Map<String, String>?,
          FutureOr<Map<String, String>?>
        >
    with
        $FutureModifier<Map<String, String>?>,
        $FutureProvider<Map<String, String>?> {
  const DiscordAssetsProvider._({
    required DiscordAssetsFamily super.from,
    required SnPresenceActivity super.argument,
  }) : super(
         retry: null,
         name: r'discordAssetsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$discordAssetsHash();

  @override
  String toString() {
    return r'discordAssetsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, String>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, String>?> create(Ref ref) {
    final argument = this.argument as SnPresenceActivity;
    return discordAssets(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DiscordAssetsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$discordAssetsHash() => r'3ef8465188059de96cf2ac9660ed3d88910443bf';

final class DiscordAssetsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, String>?>,
          SnPresenceActivity
        > {
  const DiscordAssetsFamily._()
    : super(
        retry: null,
        name: r'discordAssetsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DiscordAssetsProvider call(SnPresenceActivity activity) =>
      DiscordAssetsProvider._(argument: activity, from: this);

  @override
  String toString() => r'discordAssetsProvider';
}

@ProviderFor(discordAssetsUrl)
const discordAssetsUrlProvider = DiscordAssetsUrlFamily._();

final class DiscordAssetsUrlProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const DiscordAssetsUrlProvider._({
    required DiscordAssetsUrlFamily super.from,
    required (SnPresenceActivity, String) super.argument,
  }) : super(
         retry: null,
         name: r'discordAssetsUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$discordAssetsUrlHash();

  @override
  String toString() {
    return r'discordAssetsUrlProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as (SnPresenceActivity, String);
    return discordAssetsUrl(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DiscordAssetsUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$discordAssetsUrlHash() => r'a32f9333c3fb4d50ff88a54a6b8b72fbf5ba3ea1';

final class DiscordAssetsUrlFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<String?>,
          (SnPresenceActivity, String)
        > {
  const DiscordAssetsUrlFamily._()
    : super(
        retry: null,
        name: r'discordAssetsUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DiscordAssetsUrlProvider call(SnPresenceActivity activity, String key) =>
      DiscordAssetsUrlProvider._(argument: (activity, key), from: this);

  @override
  String toString() => r'discordAssetsUrlProvider';
}
