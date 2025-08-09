// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stickerPackContentHash() =>
    r'42d74f51022e67e35cb601c2f30f4f02e1f2be9d';

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

/// See also [stickerPackContent].
@ProviderFor(stickerPackContent)
const stickerPackContentProvider = StickerPackContentFamily();

/// See also [stickerPackContent].
class StickerPackContentFamily extends Family<AsyncValue<List<SnSticker>>> {
  /// See also [stickerPackContent].
  const StickerPackContentFamily();

  /// See also [stickerPackContent].
  StickerPackContentProvider call(String packId) {
    return StickerPackContentProvider(packId);
  }

  @override
  StickerPackContentProvider getProviderOverride(
    covariant StickerPackContentProvider provider,
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
  String? get name => r'stickerPackContentProvider';
}

/// See also [stickerPackContent].
class StickerPackContentProvider
    extends AutoDisposeFutureProvider<List<SnSticker>> {
  /// See also [stickerPackContent].
  StickerPackContentProvider(String packId)
    : this._internal(
        (ref) => stickerPackContent(ref as StickerPackContentRef, packId),
        from: stickerPackContentProvider,
        name: r'stickerPackContentProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$stickerPackContentHash,
        dependencies: StickerPackContentFamily._dependencies,
        allTransitiveDependencies:
            StickerPackContentFamily._allTransitiveDependencies,
        packId: packId,
      );

  StickerPackContentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.packId,
  }) : super.internal();

  final String packId;

  @override
  Override overrideWith(
    FutureOr<List<SnSticker>> Function(StickerPackContentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StickerPackContentProvider._internal(
        (ref) => create(ref as StickerPackContentRef),
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
  AutoDisposeFutureProviderElement<List<SnSticker>> createElement() {
    return _StickerPackContentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StickerPackContentProvider && other.packId == packId;
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
mixin StickerPackContentRef on AutoDisposeFutureProviderRef<List<SnSticker>> {
  /// The parameter `packId` of this provider.
  String get packId;
}

class _StickerPackContentProviderElement
    extends AutoDisposeFutureProviderElement<List<SnSticker>>
    with StickerPackContentRef {
  _StickerPackContentProviderElement(super.provider);

  @override
  String get packId => (origin as StickerPackContentProvider).packId;
}

String _$stickerPackStickerHash() =>
    r'5c553666b3a63530bdebae4b7cd52f303c5ab3a0';

/// See also [stickerPackSticker].
@ProviderFor(stickerPackSticker)
const stickerPackStickerProvider = StickerPackStickerFamily();

/// See also [stickerPackSticker].
class StickerPackStickerFamily extends Family<AsyncValue<SnSticker?>> {
  /// See also [stickerPackSticker].
  const StickerPackStickerFamily();

  /// See also [stickerPackSticker].
  StickerPackStickerProvider call(StickerWithPackQuery? query) {
    return StickerPackStickerProvider(query);
  }

  @override
  StickerPackStickerProvider getProviderOverride(
    covariant StickerPackStickerProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'stickerPackStickerProvider';
}

/// See also [stickerPackSticker].
class StickerPackStickerProvider extends AutoDisposeFutureProvider<SnSticker?> {
  /// See also [stickerPackSticker].
  StickerPackStickerProvider(StickerWithPackQuery? query)
    : this._internal(
        (ref) => stickerPackSticker(ref as StickerPackStickerRef, query),
        from: stickerPackStickerProvider,
        name: r'stickerPackStickerProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$stickerPackStickerHash,
        dependencies: StickerPackStickerFamily._dependencies,
        allTransitiveDependencies:
            StickerPackStickerFamily._allTransitiveDependencies,
        query: query,
      );

  StickerPackStickerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final StickerWithPackQuery? query;

  @override
  Override overrideWith(
    FutureOr<SnSticker?> Function(StickerPackStickerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StickerPackStickerProvider._internal(
        (ref) => create(ref as StickerPackStickerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnSticker?> createElement() {
    return _StickerPackStickerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StickerPackStickerProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StickerPackStickerRef on AutoDisposeFutureProviderRef<SnSticker?> {
  /// The parameter `query` of this provider.
  StickerWithPackQuery? get query;
}

class _StickerPackStickerProviderElement
    extends AutoDisposeFutureProviderElement<SnSticker?>
    with StickerPackStickerRef {
  _StickerPackStickerProviderElement(super.provider);

  @override
  StickerWithPackQuery? get query =>
      (origin as StickerPackStickerProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
