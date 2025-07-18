// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_picker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchAccountsHash() => r'fa3b8b7d51e14cf40d4116ba0ff0b6955fa0ff54';

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

/// See also [searchAccounts].
@ProviderFor(searchAccounts)
const searchAccountsProvider = SearchAccountsFamily();

/// See also [searchAccounts].
class SearchAccountsFamily extends Family<AsyncValue<List<SnAccount>>> {
  /// See also [searchAccounts].
  const SearchAccountsFamily();

  /// See also [searchAccounts].
  SearchAccountsProvider call({required String query}) {
    return SearchAccountsProvider(query: query);
  }

  @override
  SearchAccountsProvider getProviderOverride(
    covariant SearchAccountsProvider provider,
  ) {
    return call(query: provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchAccountsProvider';
}

/// See also [searchAccounts].
class SearchAccountsProvider
    extends AutoDisposeFutureProvider<List<SnAccount>> {
  /// See also [searchAccounts].
  SearchAccountsProvider({required String query})
    : this._internal(
        (ref) => searchAccounts(ref as SearchAccountsRef, query: query),
        from: searchAccountsProvider,
        name: r'searchAccountsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$searchAccountsHash,
        dependencies: SearchAccountsFamily._dependencies,
        allTransitiveDependencies:
            SearchAccountsFamily._allTransitiveDependencies,
        query: query,
      );

  SearchAccountsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<SnAccount>> Function(SearchAccountsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchAccountsProvider._internal(
        (ref) => create(ref as SearchAccountsRef),
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
  AutoDisposeFutureProviderElement<List<SnAccount>> createElement() {
    return _SearchAccountsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchAccountsProvider && other.query == query;
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
mixin SearchAccountsRef on AutoDisposeFutureProviderRef<List<SnAccount>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchAccountsProviderElement
    extends AutoDisposeFutureProviderElement<List<SnAccount>>
    with SearchAccountsRef {
  _SearchAccountsProviderElement(super.provider);

  @override
  String get query => (origin as SearchAccountsProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
