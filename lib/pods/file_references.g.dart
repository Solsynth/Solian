// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_references.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fileReferencesHash() => r'464562fbdc9452d8a5ffbd2d9d9343cdb43f1876';

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

/// See also [fileReferences].
@ProviderFor(fileReferences)
const fileReferencesProvider = FileReferencesFamily();

/// See also [fileReferences].
class FileReferencesFamily extends Family<AsyncValue<List<Reference>>> {
  /// See also [fileReferences].
  const FileReferencesFamily();

  /// See also [fileReferences].
  FileReferencesProvider call(String fileId) {
    return FileReferencesProvider(fileId);
  }

  @override
  FileReferencesProvider getProviderOverride(
    covariant FileReferencesProvider provider,
  ) {
    return call(provider.fileId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fileReferencesProvider';
}

/// See also [fileReferences].
class FileReferencesProvider
    extends AutoDisposeFutureProvider<List<Reference>> {
  /// See also [fileReferences].
  FileReferencesProvider(String fileId)
    : this._internal(
        (ref) => fileReferences(ref as FileReferencesRef, fileId),
        from: fileReferencesProvider,
        name: r'fileReferencesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$fileReferencesHash,
        dependencies: FileReferencesFamily._dependencies,
        allTransitiveDependencies:
            FileReferencesFamily._allTransitiveDependencies,
        fileId: fileId,
      );

  FileReferencesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fileId,
  }) : super.internal();

  final String fileId;

  @override
  Override overrideWith(
    FutureOr<List<Reference>> Function(FileReferencesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FileReferencesProvider._internal(
        (ref) => create(ref as FileReferencesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fileId: fileId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Reference>> createElement() {
    return _FileReferencesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FileReferencesProvider && other.fileId == fileId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fileId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FileReferencesRef on AutoDisposeFutureProviderRef<List<Reference>> {
  /// The parameter `fileId` of this provider.
  String get fileId;
}

class _FileReferencesProviderElement
    extends AutoDisposeFutureProviderElement<List<Reference>>
    with FileReferencesRef {
  _FileReferencesProviderElement(super.provider);

  @override
  String get fileId => (origin as FileReferencesProvider).fileId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
