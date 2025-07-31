// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translate.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$translateStringHash() => r'51d638cf07cbf3ffa9469298f5bd9c667bc0ccb7';

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

/// See also [translateString].
@ProviderFor(translateString)
const translateStringProvider = TranslateStringFamily();

/// See also [translateString].
class TranslateStringFamily extends Family<AsyncValue<String>> {
  /// See also [translateString].
  const TranslateStringFamily();

  /// See also [translateString].
  TranslateStringProvider call(TranslateQuery query) {
    return TranslateStringProvider(query);
  }

  @override
  TranslateStringProvider getProviderOverride(
    covariant TranslateStringProvider provider,
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
  String? get name => r'translateStringProvider';
}

/// See also [translateString].
class TranslateStringProvider extends AutoDisposeFutureProvider<String> {
  /// See also [translateString].
  TranslateStringProvider(TranslateQuery query)
    : this._internal(
        (ref) => translateString(ref as TranslateStringRef, query),
        from: translateStringProvider,
        name: r'translateStringProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$translateStringHash,
        dependencies: TranslateStringFamily._dependencies,
        allTransitiveDependencies:
            TranslateStringFamily._allTransitiveDependencies,
        query: query,
      );

  TranslateStringProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final TranslateQuery query;

  @override
  Override overrideWith(
    FutureOr<String> Function(TranslateStringRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TranslateStringProvider._internal(
        (ref) => create(ref as TranslateStringRef),
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
  AutoDisposeFutureProviderElement<String> createElement() {
    return _TranslateStringProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TranslateStringProvider && other.query == query;
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
mixin TranslateStringRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `query` of this provider.
  TranslateQuery get query;
}

class _TranslateStringProviderElement
    extends AutoDisposeFutureProviderElement<String>
    with TranslateStringRef {
  _TranslateStringProviderElement(super.provider);

  @override
  TranslateQuery get query => (origin as TranslateStringProvider).query;
}

String _$detectStringLanguageHash() =>
    r'697b68464b3d00927cc43ccc1ba8ba93f2a470ed';

/// See also [detectStringLanguage].
@ProviderFor(detectStringLanguage)
const detectStringLanguageProvider = DetectStringLanguageFamily();

/// See also [detectStringLanguage].
class DetectStringLanguageFamily extends Family<String?> {
  /// See also [detectStringLanguage].
  const DetectStringLanguageFamily();

  /// See also [detectStringLanguage].
  DetectStringLanguageProvider call(String text) {
    return DetectStringLanguageProvider(text);
  }

  @override
  DetectStringLanguageProvider getProviderOverride(
    covariant DetectStringLanguageProvider provider,
  ) {
    return call(provider.text);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'detectStringLanguageProvider';
}

/// See also [detectStringLanguage].
class DetectStringLanguageProvider extends AutoDisposeProvider<String?> {
  /// See also [detectStringLanguage].
  DetectStringLanguageProvider(String text)
    : this._internal(
        (ref) => detectStringLanguage(ref as DetectStringLanguageRef, text),
        from: detectStringLanguageProvider,
        name: r'detectStringLanguageProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$detectStringLanguageHash,
        dependencies: DetectStringLanguageFamily._dependencies,
        allTransitiveDependencies:
            DetectStringLanguageFamily._allTransitiveDependencies,
        text: text,
      );

  DetectStringLanguageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.text,
  }) : super.internal();

  final String text;

  @override
  Override overrideWith(
    String? Function(DetectStringLanguageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DetectStringLanguageProvider._internal(
        (ref) => create(ref as DetectStringLanguageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        text: text,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String?> createElement() {
    return _DetectStringLanguageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DetectStringLanguageProvider && other.text == text;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, text.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DetectStringLanguageRef on AutoDisposeProviderRef<String?> {
  /// The parameter `text` of this provider.
  String get text;
}

class _DetectStringLanguageProviderElement
    extends AutoDisposeProviderElement<String?>
    with DetectStringLanguageRef {
  _DetectStringLanguageProviderElement(super.provider);

  @override
  String get text => (origin as DetectStringLanguageProvider).text;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
