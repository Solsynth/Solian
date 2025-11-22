// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_files.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$siteFilesHash() => r'd4029e6c160edcd454eb39ef1c19427b7f95a8d8';

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

/// See also [siteFiles].
@ProviderFor(siteFiles)
const siteFilesProvider = SiteFilesFamily();

/// See also [siteFiles].
class SiteFilesFamily extends Family<AsyncValue<List<SnSiteFileEntry>>> {
  /// See also [siteFiles].
  const SiteFilesFamily();

  /// See also [siteFiles].
  SiteFilesProvider call({required String siteId, String? path}) {
    return SiteFilesProvider(siteId: siteId, path: path);
  }

  @override
  SiteFilesProvider getProviderOverride(covariant SiteFilesProvider provider) {
    return call(siteId: provider.siteId, path: provider.path);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'siteFilesProvider';
}

/// See also [siteFiles].
class SiteFilesProvider
    extends AutoDisposeFutureProvider<List<SnSiteFileEntry>> {
  /// See also [siteFiles].
  SiteFilesProvider({required String siteId, String? path})
    : this._internal(
        (ref) => siteFiles(ref as SiteFilesRef, siteId: siteId, path: path),
        from: siteFilesProvider,
        name: r'siteFilesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$siteFilesHash,
        dependencies: SiteFilesFamily._dependencies,
        allTransitiveDependencies: SiteFilesFamily._allTransitiveDependencies,
        siteId: siteId,
        path: path,
      );

  SiteFilesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.siteId,
    required this.path,
  }) : super.internal();

  final String siteId;
  final String? path;

  @override
  Override overrideWith(
    FutureOr<List<SnSiteFileEntry>> Function(SiteFilesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SiteFilesProvider._internal(
        (ref) => create(ref as SiteFilesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        siteId: siteId,
        path: path,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SnSiteFileEntry>> createElement() {
    return _SiteFilesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SiteFilesProvider &&
        other.siteId == siteId &&
        other.path == path;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, siteId.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SiteFilesRef on AutoDisposeFutureProviderRef<List<SnSiteFileEntry>> {
  /// The parameter `siteId` of this provider.
  String get siteId;

  /// The parameter `path` of this provider.
  String? get path;
}

class _SiteFilesProviderElement
    extends AutoDisposeFutureProviderElement<List<SnSiteFileEntry>>
    with SiteFilesRef {
  _SiteFilesProviderElement(super.provider);

  @override
  String get siteId => (origin as SiteFilesProvider).siteId;
  @override
  String? get path => (origin as SiteFilesProvider).path;
}

String _$siteFileContentHash() => r'b594ad4f8c54555e742ece94ee001092cb2f83d1';

/// See also [siteFileContent].
@ProviderFor(siteFileContent)
const siteFileContentProvider = SiteFileContentFamily();

/// See also [siteFileContent].
class SiteFileContentFamily extends Family<AsyncValue<SnFileContent>> {
  /// See also [siteFileContent].
  const SiteFileContentFamily();

  /// See also [siteFileContent].
  SiteFileContentProvider call({
    required String siteId,
    required String relativePath,
  }) {
    return SiteFileContentProvider(siteId: siteId, relativePath: relativePath);
  }

  @override
  SiteFileContentProvider getProviderOverride(
    covariant SiteFileContentProvider provider,
  ) {
    return call(siteId: provider.siteId, relativePath: provider.relativePath);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'siteFileContentProvider';
}

/// See also [siteFileContent].
class SiteFileContentProvider extends AutoDisposeFutureProvider<SnFileContent> {
  /// See also [siteFileContent].
  SiteFileContentProvider({
    required String siteId,
    required String relativePath,
  }) : this._internal(
         (ref) => siteFileContent(
           ref as SiteFileContentRef,
           siteId: siteId,
           relativePath: relativePath,
         ),
         from: siteFileContentProvider,
         name: r'siteFileContentProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$siteFileContentHash,
         dependencies: SiteFileContentFamily._dependencies,
         allTransitiveDependencies:
             SiteFileContentFamily._allTransitiveDependencies,
         siteId: siteId,
         relativePath: relativePath,
       );

  SiteFileContentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.siteId,
    required this.relativePath,
  }) : super.internal();

  final String siteId;
  final String relativePath;

  @override
  Override overrideWith(
    FutureOr<SnFileContent> Function(SiteFileContentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SiteFileContentProvider._internal(
        (ref) => create(ref as SiteFileContentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        siteId: siteId,
        relativePath: relativePath,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnFileContent> createElement() {
    return _SiteFileContentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SiteFileContentProvider &&
        other.siteId == siteId &&
        other.relativePath == relativePath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, siteId.hashCode);
    hash = _SystemHash.combine(hash, relativePath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SiteFileContentRef on AutoDisposeFutureProviderRef<SnFileContent> {
  /// The parameter `siteId` of this provider.
  String get siteId;

  /// The parameter `relativePath` of this provider.
  String get relativePath;
}

class _SiteFileContentProviderElement
    extends AutoDisposeFutureProviderElement<SnFileContent>
    with SiteFileContentRef {
  _SiteFileContentProviderElement(super.provider);

  @override
  String get siteId => (origin as SiteFileContentProvider).siteId;
  @override
  String get relativePath => (origin as SiteFileContentProvider).relativePath;
}

String _$siteFileContentRawHash() =>
    r'd0331c30698a9f4b90fe9b79273ff5914fa46616';

/// See also [siteFileContentRaw].
@ProviderFor(siteFileContentRaw)
const siteFileContentRawProvider = SiteFileContentRawFamily();

/// See also [siteFileContentRaw].
class SiteFileContentRawFamily extends Family<AsyncValue<String>> {
  /// See also [siteFileContentRaw].
  const SiteFileContentRawFamily();

  /// See also [siteFileContentRaw].
  SiteFileContentRawProvider call({
    required String siteId,
    required String relativePath,
  }) {
    return SiteFileContentRawProvider(
      siteId: siteId,
      relativePath: relativePath,
    );
  }

  @override
  SiteFileContentRawProvider getProviderOverride(
    covariant SiteFileContentRawProvider provider,
  ) {
    return call(siteId: provider.siteId, relativePath: provider.relativePath);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'siteFileContentRawProvider';
}

/// See also [siteFileContentRaw].
class SiteFileContentRawProvider extends AutoDisposeFutureProvider<String> {
  /// See also [siteFileContentRaw].
  SiteFileContentRawProvider({
    required String siteId,
    required String relativePath,
  }) : this._internal(
         (ref) => siteFileContentRaw(
           ref as SiteFileContentRawRef,
           siteId: siteId,
           relativePath: relativePath,
         ),
         from: siteFileContentRawProvider,
         name: r'siteFileContentRawProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$siteFileContentRawHash,
         dependencies: SiteFileContentRawFamily._dependencies,
         allTransitiveDependencies:
             SiteFileContentRawFamily._allTransitiveDependencies,
         siteId: siteId,
         relativePath: relativePath,
       );

  SiteFileContentRawProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.siteId,
    required this.relativePath,
  }) : super.internal();

  final String siteId;
  final String relativePath;

  @override
  Override overrideWith(
    FutureOr<String> Function(SiteFileContentRawRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SiteFileContentRawProvider._internal(
        (ref) => create(ref as SiteFileContentRawRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        siteId: siteId,
        relativePath: relativePath,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _SiteFileContentRawProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SiteFileContentRawProvider &&
        other.siteId == siteId &&
        other.relativePath == relativePath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, siteId.hashCode);
    hash = _SystemHash.combine(hash, relativePath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SiteFileContentRawRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `siteId` of this provider.
  String get siteId;

  /// The parameter `relativePath` of this provider.
  String get relativePath;
}

class _SiteFileContentRawProviderElement
    extends AutoDisposeFutureProviderElement<String>
    with SiteFileContentRawRef {
  _SiteFileContentRawProviderElement(super.provider);

  @override
  String get siteId => (origin as SiteFileContentRawProvider).siteId;
  @override
  String get relativePath =>
      (origin as SiteFileContentRawProvider).relativePath;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
