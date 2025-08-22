// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_bot.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$botHash() => r'267c75029a194fe180aeaebf12cbb0c1da9b8529';

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

/// See also [bot].
@ProviderFor(bot)
const botProvider = BotFamily();

/// See also [bot].
class BotFamily extends Family<AsyncValue<Bot?>> {
  /// See also [bot].
  const BotFamily();

  /// See also [bot].
  BotProvider call(String id) {
    return BotProvider(id);
  }

  @override
  BotProvider getProviderOverride(covariant BotProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'botProvider';
}

/// See also [bot].
class BotProvider extends AutoDisposeFutureProvider<Bot?> {
  /// See also [bot].
  BotProvider(String id)
    : this._internal(
        (ref) => bot(ref as BotRef, id),
        from: botProvider,
        name: r'botProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product') ? null : _$botHash,
        dependencies: BotFamily._dependencies,
        allTransitiveDependencies: BotFamily._allTransitiveDependencies,
        id: id,
      );

  BotProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(FutureOr<Bot?> Function(BotRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: BotProvider._internal(
        (ref) => create(ref as BotRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Bot?> createElement() {
    return _BotProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BotProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BotRef on AutoDisposeFutureProviderRef<Bot?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _BotProviderElement extends AutoDisposeFutureProviderElement<Bot?>
    with BotRef {
  _BotProviderElement(super.provider);

  @override
  String get id => (origin as BotProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
