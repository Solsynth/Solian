// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stickers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stickerPackHash() => r'71ef84471237c8191918095094bdfc87d3920e77';

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

/// See also [stickerPack].
@ProviderFor(stickerPack)
const stickerPackProvider = StickerPackFamily();

/// See also [stickerPack].
class StickerPackFamily extends Family<AsyncValue<SnStickerPack?>> {
  /// See also [stickerPack].
  const StickerPackFamily();

  /// See also [stickerPack].
  StickerPackProvider call(String? packId) {
    return StickerPackProvider(packId);
  }

  @override
  StickerPackProvider getProviderOverride(
    covariant StickerPackProvider provider,
  ) {
    return call(provider.packId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'stickerPackProvider';
}

/// See also [stickerPack].
class StickerPackProvider extends AutoDisposeFutureProvider<SnStickerPack?> {
  /// See also [stickerPack].
  StickerPackProvider(String? packId)
    : this._internal(
        (ref) => stickerPack(ref as StickerPackRef, packId),
        from: stickerPackProvider,
        name: r'stickerPackProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$stickerPackHash,
        dependencies: StickerPackFamily._dependencies,
        allTransitiveDependencies: StickerPackFamily._allTransitiveDependencies,
        packId: packId,
      );

  StickerPackProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.packId,
  }) : super.internal();

  final String? packId;

  @override
  Override overrideWith(
    FutureOr<SnStickerPack?> Function(StickerPackRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StickerPackProvider._internal(
        (ref) => create(ref as StickerPackRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        packId: packId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnStickerPack?> createElement() {
    return _StickerPackProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StickerPackProvider && other.packId == packId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, packId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StickerPackRef on AutoDisposeFutureProviderRef<SnStickerPack?> {
  /// The parameter `packId` of this provider.
  String? get packId;
}

class _StickerPackProviderElement
    extends AutoDisposeFutureProviderElement<SnStickerPack?>
    with StickerPackRef {
  _StickerPackProviderElement(super.provider);

  @override
  String? get packId => (origin as StickerPackProvider).packId;
}

String _$stickerPacksNotifierHash() =>
    r'0a8edcf9c35396c411f1214f5e77b1e8fac6a3e6';

abstract class _$StickerPacksNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnStickerPack>> {
  late final String pubName;

  FutureOr<CursorPagingData<SnStickerPack>> build(String pubName);
}

/// See also [StickerPacksNotifier].
@ProviderFor(StickerPacksNotifier)
const stickerPacksNotifierProvider = StickerPacksNotifierFamily();

/// See also [StickerPacksNotifier].
class StickerPacksNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnStickerPack>>> {
  /// See also [StickerPacksNotifier].
  const StickerPacksNotifierFamily();

  /// See also [StickerPacksNotifier].
  StickerPacksNotifierProvider call(String pubName) {
    return StickerPacksNotifierProvider(pubName);
  }

  @override
  StickerPacksNotifierProvider getProviderOverride(
    covariant StickerPacksNotifierProvider provider,
  ) {
    return call(provider.pubName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'stickerPacksNotifierProvider';
}

/// See also [StickerPacksNotifier].
class StickerPacksNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          StickerPacksNotifier,
          CursorPagingData<SnStickerPack>
        > {
  /// See also [StickerPacksNotifier].
  StickerPacksNotifierProvider(String pubName)
    : this._internal(
        () => StickerPacksNotifier()..pubName = pubName,
        from: stickerPacksNotifierProvider,
        name: r'stickerPacksNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$stickerPacksNotifierHash,
        dependencies: StickerPacksNotifierFamily._dependencies,
        allTransitiveDependencies:
            StickerPacksNotifierFamily._allTransitiveDependencies,
        pubName: pubName,
      );

  StickerPacksNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pubName,
  }) : super.internal();

  final String pubName;

  @override
  FutureOr<CursorPagingData<SnStickerPack>> runNotifierBuild(
    covariant StickerPacksNotifier notifier,
  ) {
    return notifier.build(pubName);
  }

  @override
  Override overrideWith(StickerPacksNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: StickerPacksNotifierProvider._internal(
        () => create()..pubName = pubName,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pubName: pubName,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    StickerPacksNotifier,
    CursorPagingData<SnStickerPack>
  >
  createElement() {
    return _StickerPacksNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StickerPacksNotifierProvider && other.pubName == pubName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pubName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StickerPacksNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnStickerPack>> {
  /// The parameter `pubName` of this provider.
  String get pubName;
}

class _StickerPacksNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          StickerPacksNotifier,
          CursorPagingData<SnStickerPack>
        >
    with StickerPacksNotifierRef {
  _StickerPacksNotifierProviderElement(super.provider);

  @override
  String get pubName => (origin as StickerPacksNotifierProvider).pubName;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
