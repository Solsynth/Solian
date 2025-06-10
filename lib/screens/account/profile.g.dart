// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accountHash() => r'd2b0579617e6264452d98f47f695a9cdf45b24ec';

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

/// See also [account].
@ProviderFor(account)
const accountProvider = AccountFamily();

/// See also [account].
class AccountFamily extends Family<AsyncValue<SnAccount>> {
  /// See also [account].
  const AccountFamily();

  /// See also [account].
  AccountProvider call(String uname) {
    return AccountProvider(uname);
  }

  @override
  AccountProvider getProviderOverride(covariant AccountProvider provider) {
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
  String? get name => r'accountProvider';
}

/// See also [account].
class AccountProvider extends AutoDisposeFutureProvider<SnAccount> {
  /// See also [account].
  AccountProvider(String uname)
    : this._internal(
        (ref) => account(ref as AccountRef, uname),
        from: accountProvider,
        name: r'accountProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$accountHash,
        dependencies: AccountFamily._dependencies,
        allTransitiveDependencies: AccountFamily._allTransitiveDependencies,
        uname: uname,
      );

  AccountProvider._internal(
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
    FutureOr<SnAccount> Function(AccountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AccountProvider._internal(
        (ref) => create(ref as AccountRef),
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
  AutoDisposeFutureProviderElement<SnAccount> createElement() {
    return _AccountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountProvider && other.uname == uname;
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
mixin AccountRef on AutoDisposeFutureProviderRef<SnAccount> {
  /// The parameter `uname` of this provider.
  String get uname;
}

class _AccountProviderElement
    extends AutoDisposeFutureProviderElement<SnAccount>
    with AccountRef {
  _AccountProviderElement(super.provider);

  @override
  String get uname => (origin as AccountProvider).uname;
}

String _$accountBadgesHash() => r'4bfe5fb0d6ac0d4cde4563460bde289289188f6d';

/// See also [accountBadges].
@ProviderFor(accountBadges)
const accountBadgesProvider = AccountBadgesFamily();

/// See also [accountBadges].
class AccountBadgesFamily extends Family<AsyncValue<List<SnAccountBadge>>> {
  /// See also [accountBadges].
  const AccountBadgesFamily();

  /// See also [accountBadges].
  AccountBadgesProvider call(String uname) {
    return AccountBadgesProvider(uname);
  }

  @override
  AccountBadgesProvider getProviderOverride(
    covariant AccountBadgesProvider provider,
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
  String? get name => r'accountBadgesProvider';
}

/// See also [accountBadges].
class AccountBadgesProvider
    extends AutoDisposeFutureProvider<List<SnAccountBadge>> {
  /// See also [accountBadges].
  AccountBadgesProvider(String uname)
    : this._internal(
        (ref) => accountBadges(ref as AccountBadgesRef, uname),
        from: accountBadgesProvider,
        name: r'accountBadgesProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$accountBadgesHash,
        dependencies: AccountBadgesFamily._dependencies,
        allTransitiveDependencies:
            AccountBadgesFamily._allTransitiveDependencies,
        uname: uname,
      );

  AccountBadgesProvider._internal(
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
    FutureOr<List<SnAccountBadge>> Function(AccountBadgesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AccountBadgesProvider._internal(
        (ref) => create(ref as AccountBadgesRef),
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
  AutoDisposeFutureProviderElement<List<SnAccountBadge>> createElement() {
    return _AccountBadgesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountBadgesProvider && other.uname == uname;
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
mixin AccountBadgesRef on AutoDisposeFutureProviderRef<List<SnAccountBadge>> {
  /// The parameter `uname` of this provider.
  String get uname;
}

class _AccountBadgesProviderElement
    extends AutoDisposeFutureProviderElement<List<SnAccountBadge>>
    with AccountBadgesRef {
  _AccountBadgesProviderElement(super.provider);

  @override
  String get uname => (origin as AccountBadgesProvider).uname;
}

String _$accountAppbarForcegroundColorHash() =>
    r'f654a7a5594eda1500906e9ad023c22772257a9b';

/// See also [accountAppbarForcegroundColor].
@ProviderFor(accountAppbarForcegroundColor)
const accountAppbarForcegroundColorProvider =
    AccountAppbarForcegroundColorFamily();

/// See also [accountAppbarForcegroundColor].
class AccountAppbarForcegroundColorFamily extends Family<AsyncValue<Color?>> {
  /// See also [accountAppbarForcegroundColor].
  const AccountAppbarForcegroundColorFamily();

  /// See also [accountAppbarForcegroundColor].
  AccountAppbarForcegroundColorProvider call(String uname) {
    return AccountAppbarForcegroundColorProvider(uname);
  }

  @override
  AccountAppbarForcegroundColorProvider getProviderOverride(
    covariant AccountAppbarForcegroundColorProvider provider,
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
  String? get name => r'accountAppbarForcegroundColorProvider';
}

/// See also [accountAppbarForcegroundColor].
class AccountAppbarForcegroundColorProvider
    extends AutoDisposeFutureProvider<Color?> {
  /// See also [accountAppbarForcegroundColor].
  AccountAppbarForcegroundColorProvider(String uname)
    : this._internal(
        (ref) => accountAppbarForcegroundColor(
          ref as AccountAppbarForcegroundColorRef,
          uname,
        ),
        from: accountAppbarForcegroundColorProvider,
        name: r'accountAppbarForcegroundColorProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$accountAppbarForcegroundColorHash,
        dependencies: AccountAppbarForcegroundColorFamily._dependencies,
        allTransitiveDependencies:
            AccountAppbarForcegroundColorFamily._allTransitiveDependencies,
        uname: uname,
      );

  AccountAppbarForcegroundColorProvider._internal(
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
    FutureOr<Color?> Function(AccountAppbarForcegroundColorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AccountAppbarForcegroundColorProvider._internal(
        (ref) => create(ref as AccountAppbarForcegroundColorRef),
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
  AutoDisposeFutureProviderElement<Color?> createElement() {
    return _AccountAppbarForcegroundColorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountAppbarForcegroundColorProvider &&
        other.uname == uname;
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
mixin AccountAppbarForcegroundColorRef on AutoDisposeFutureProviderRef<Color?> {
  /// The parameter `uname` of this provider.
  String get uname;
}

class _AccountAppbarForcegroundColorProviderElement
    extends AutoDisposeFutureProviderElement<Color?>
    with AccountAppbarForcegroundColorRef {
  _AccountAppbarForcegroundColorProviderElement(super.provider);

  @override
  String get uname => (origin as AccountAppbarForcegroundColorProvider).uname;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
