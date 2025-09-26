// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accountStatusHash() => r'abc2f11f0fbaf637efc182cf85ab838936c4d875';

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

/// See also [accountStatus].
@ProviderFor(accountStatus)
const accountStatusProvider = AccountStatusFamily();

/// See also [accountStatus].
class AccountStatusFamily extends Family<AsyncValue<SnAccountStatus?>> {
  /// See also [accountStatus].
  const AccountStatusFamily();

  /// See also [accountStatus].
  AccountStatusProvider call(String uname) {
    return AccountStatusProvider(uname);
  }

  @override
  AccountStatusProvider getProviderOverride(
    covariant AccountStatusProvider provider,
  ) {
    return call(provider.uname);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'accountStatusProvider';
}

/// See also [accountStatus].
class AccountStatusProvider
    extends AutoDisposeFutureProvider<SnAccountStatus?> {
  /// See also [accountStatus].
  AccountStatusProvider(String uname)
    : this._internal(
        (ref) => accountStatus(ref as AccountStatusRef, uname),
        from: accountStatusProvider,
        name: r'accountStatusProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$accountStatusHash,
        dependencies: AccountStatusFamily._dependencies,
        allTransitiveDependencies:
            AccountStatusFamily._allTransitiveDependencies,
        uname: uname,
      );

  AccountStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uname,
  }) : super.internal();

  final String uname;

  @override
  Override overrideWith(
    FutureOr<SnAccountStatus?> Function(AccountStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AccountStatusProvider._internal(
        (ref) => create(ref as AccountStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uname: uname,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnAccountStatus?> createElement() {
    return _AccountStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountStatusProvider && other.uname == uname;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uname.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AccountStatusRef on AutoDisposeFutureProviderRef<SnAccountStatus?> {
  /// The parameter `uname` of this provider.
  String get uname;
}

class _AccountStatusProviderElement
    extends AutoDisposeFutureProviderElement<SnAccountStatus?>
    with AccountStatusRef {
  _AccountStatusProviderElement(super.provider);

  @override
  String get uname => (origin as AccountStatusProvider).uname;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
