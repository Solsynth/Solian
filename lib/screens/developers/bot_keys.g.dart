// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_keys.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$botKeysHash() => r'f7d1121833dc3da0cbd84b6171c2b2539edeb785';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [botKeys].
@ProviderFor(botKeys)
const botKeysProvider = BotKeysFamily();

/// See also [botKeys].
class BotKeysFamily extends Family<AsyncValue<List<SnAccountApiKey>>> {
  /// See also [botKeys].
  const BotKeysFamily();

  /// See also [botKeys].
  BotKeysProvider call(String publisherName, String projectId, String botId) {
    return BotKeysProvider(publisherName, projectId, botId);
  }

  @override
  BotKeysProvider getProviderOverride(covariant BotKeysProvider provider) {
    return call(provider.publisherName, provider.projectId, provider.botId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'botKeysProvider';
}

/// See also [botKeys].
class BotKeysProvider extends AutoDisposeFutureProvider<List<SnAccountApiKey>> {
  /// See also [botKeys].
  BotKeysProvider(String publisherName, String projectId, String botId)
    : this._internal(
        (ref) => botKeys(ref as BotKeysRef, publisherName, projectId, botId),
        from: botKeysProvider,
        name: r'botKeysProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$botKeysHash,
        dependencies: BotKeysFamily._dependencies,
        allTransitiveDependencies: BotKeysFamily._allTransitiveDependencies,
        publisherName: publisherName,
        projectId: projectId,
        botId: botId,
      );

  BotKeysProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.publisherName,
    required this.projectId,
    required this.botId,
  }) : super.internal();

  final String publisherName;
  final String projectId;
  final String botId;

  @override
  Override overrideWith(
    FutureOr<List<SnAccountApiKey>> Function(BotKeysRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BotKeysProvider._internal(
        (ref) => create(ref as BotKeysRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        publisherName: publisherName,
        projectId: projectId,
        botId: botId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SnAccountApiKey>> createElement() {
    return _BotKeysProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BotKeysProvider &&
        other.publisherName == publisherName &&
        other.projectId == projectId &&
        other.botId == botId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, publisherName.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);
    hash = _SystemHash.combine(hash, botId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BotKeysRef on AutoDisposeFutureProviderRef<List<SnAccountApiKey>> {
  /// The parameter `publisherName` of this provider.
  String get publisherName;

  /// The parameter `projectId` of this provider.
  String get projectId;

  /// The parameter `botId` of this provider.
  String get botId;
}

class _BotKeysProviderElement
    extends AutoDisposeFutureProviderElement<List<SnAccountApiKey>>
    with BotKeysRef {
  _BotKeysProviderElement(super.provider);

  @override
  String get publisherName => (origin as BotKeysProvider).publisherName;
  @override
  String get projectId => (origin as BotKeysProvider).projectId;
  @override
  String get botId => (origin as BotKeysProvider).botId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
