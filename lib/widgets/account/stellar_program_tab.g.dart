// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stellar_program_tab.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accountStellarSubscriptionHash() =>
    r'80abcdefb3868775fd8fe3c980215713efff5948';

/// See also [accountStellarSubscription].
@ProviderFor(accountStellarSubscription)
final accountStellarSubscriptionProvider =
    AutoDisposeFutureProvider<SnWalletSubscription?>.internal(
      accountStellarSubscription,
      name: r'accountStellarSubscriptionProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$accountStellarSubscriptionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AccountStellarSubscriptionRef =
    AutoDisposeFutureProviderRef<SnWalletSubscription?>;
String _$accountSentGiftsHash() => r'32a282ec863023c749d81423704787943110a188';

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

/// See also [accountSentGifts].
@ProviderFor(accountSentGifts)
const accountSentGiftsProvider = AccountSentGiftsFamily();

/// See also [accountSentGifts].
class AccountSentGiftsFamily extends Family<AsyncValue<List<SnWalletGift>>> {
  /// See also [accountSentGifts].
  const AccountSentGiftsFamily();

  /// See also [accountSentGifts].
  AccountSentGiftsProvider call({int offset = 0, int take = 20}) {
    return AccountSentGiftsProvider(offset: offset, take: take);
  }

  @override
  AccountSentGiftsProvider getProviderOverride(
    covariant AccountSentGiftsProvider provider,
  ) {
    return call(offset: provider.offset, take: provider.take);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'accountSentGiftsProvider';
}

/// See also [accountSentGifts].
class AccountSentGiftsProvider
    extends AutoDisposeFutureProvider<List<SnWalletGift>> {
  /// See also [accountSentGifts].
  AccountSentGiftsProvider({int offset = 0, int take = 20})
    : this._internal(
        (ref) => accountSentGifts(
          ref as AccountSentGiftsRef,
          offset: offset,
          take: take,
        ),
        from: accountSentGiftsProvider,
        name: r'accountSentGiftsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$accountSentGiftsHash,
        dependencies: AccountSentGiftsFamily._dependencies,
        allTransitiveDependencies:
            AccountSentGiftsFamily._allTransitiveDependencies,
        offset: offset,
        take: take,
      );

  AccountSentGiftsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.offset,
    required this.take,
  }) : super.internal();

  final int offset;
  final int take;

  @override
  Override overrideWith(
    FutureOr<List<SnWalletGift>> Function(AccountSentGiftsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AccountSentGiftsProvider._internal(
        (ref) => create(ref as AccountSentGiftsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        offset: offset,
        take: take,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SnWalletGift>> createElement() {
    return _AccountSentGiftsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountSentGiftsProvider &&
        other.offset == offset &&
        other.take == take;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, offset.hashCode);
    hash = _SystemHash.combine(hash, take.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AccountSentGiftsRef on AutoDisposeFutureProviderRef<List<SnWalletGift>> {
  /// The parameter `offset` of this provider.
  int get offset;

  /// The parameter `take` of this provider.
  int get take;
}

class _AccountSentGiftsProviderElement
    extends AutoDisposeFutureProviderElement<List<SnWalletGift>>
    with AccountSentGiftsRef {
  _AccountSentGiftsProviderElement(super.provider);

  @override
  int get offset => (origin as AccountSentGiftsProvider).offset;
  @override
  int get take => (origin as AccountSentGiftsProvider).take;
}

String _$accountReceivedGiftsHash() =>
    r'7c0dfcc109f6f50ec326dd64c2d944aaccd9f775';

/// See also [accountReceivedGifts].
@ProviderFor(accountReceivedGifts)
const accountReceivedGiftsProvider = AccountReceivedGiftsFamily();

/// See also [accountReceivedGifts].
class AccountReceivedGiftsFamily
    extends Family<AsyncValue<List<SnWalletGift>>> {
  /// See also [accountReceivedGifts].
  const AccountReceivedGiftsFamily();

  /// See also [accountReceivedGifts].
  AccountReceivedGiftsProvider call({int offset = 0, int take = 20}) {
    return AccountReceivedGiftsProvider(offset: offset, take: take);
  }

  @override
  AccountReceivedGiftsProvider getProviderOverride(
    covariant AccountReceivedGiftsProvider provider,
  ) {
    return call(offset: provider.offset, take: provider.take);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'accountReceivedGiftsProvider';
}

/// See also [accountReceivedGifts].
class AccountReceivedGiftsProvider
    extends AutoDisposeFutureProvider<List<SnWalletGift>> {
  /// See also [accountReceivedGifts].
  AccountReceivedGiftsProvider({int offset = 0, int take = 20})
    : this._internal(
        (ref) => accountReceivedGifts(
          ref as AccountReceivedGiftsRef,
          offset: offset,
          take: take,
        ),
        from: accountReceivedGiftsProvider,
        name: r'accountReceivedGiftsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$accountReceivedGiftsHash,
        dependencies: AccountReceivedGiftsFamily._dependencies,
        allTransitiveDependencies:
            AccountReceivedGiftsFamily._allTransitiveDependencies,
        offset: offset,
        take: take,
      );

  AccountReceivedGiftsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.offset,
    required this.take,
  }) : super.internal();

  final int offset;
  final int take;

  @override
  Override overrideWith(
    FutureOr<List<SnWalletGift>> Function(AccountReceivedGiftsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AccountReceivedGiftsProvider._internal(
        (ref) => create(ref as AccountReceivedGiftsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        offset: offset,
        take: take,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SnWalletGift>> createElement() {
    return _AccountReceivedGiftsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountReceivedGiftsProvider &&
        other.offset == offset &&
        other.take == take;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, offset.hashCode);
    hash = _SystemHash.combine(hash, take.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AccountReceivedGiftsRef
    on AutoDisposeFutureProviderRef<List<SnWalletGift>> {
  /// The parameter `offset` of this provider.
  int get offset;

  /// The parameter `take` of this provider.
  int get take;
}

class _AccountReceivedGiftsProviderElement
    extends AutoDisposeFutureProviderElement<List<SnWalletGift>>
    with AccountReceivedGiftsRef {
  _AccountReceivedGiftsProviderElement(super.provider);

  @override
  int get offset => (origin as AccountReceivedGiftsProvider).offset;
  @override
  int get take => (origin as AccountReceivedGiftsProvider).take;
}

String _$accountGiftHash() => r'7169d355f78e4fe3bf6b3ff444350faa46a0d216';

/// See also [accountGift].
@ProviderFor(accountGift)
const accountGiftProvider = AccountGiftFamily();

/// See also [accountGift].
class AccountGiftFamily extends Family<AsyncValue<SnWalletGift>> {
  /// See also [accountGift].
  const AccountGiftFamily();

  /// See also [accountGift].
  AccountGiftProvider call(String giftId) {
    return AccountGiftProvider(giftId);
  }

  @override
  AccountGiftProvider getProviderOverride(
    covariant AccountGiftProvider provider,
  ) {
    return call(provider.giftId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'accountGiftProvider';
}

/// See also [accountGift].
class AccountGiftProvider extends AutoDisposeFutureProvider<SnWalletGift> {
  /// See also [accountGift].
  AccountGiftProvider(String giftId)
    : this._internal(
        (ref) => accountGift(ref as AccountGiftRef, giftId),
        from: accountGiftProvider,
        name: r'accountGiftProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$accountGiftHash,
        dependencies: AccountGiftFamily._dependencies,
        allTransitiveDependencies: AccountGiftFamily._allTransitiveDependencies,
        giftId: giftId,
      );

  AccountGiftProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.giftId,
  }) : super.internal();

  final String giftId;

  @override
  Override overrideWith(
    FutureOr<SnWalletGift> Function(AccountGiftRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AccountGiftProvider._internal(
        (ref) => create(ref as AccountGiftRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        giftId: giftId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnWalletGift> createElement() {
    return _AccountGiftProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountGiftProvider && other.giftId == giftId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, giftId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AccountGiftRef on AutoDisposeFutureProviderRef<SnWalletGift> {
  /// The parameter `giftId` of this provider.
  String get giftId;
}

class _AccountGiftProviderElement
    extends AutoDisposeFutureProviderElement<SnWalletGift>
    with AccountGiftRef {
  _AccountGiftProviderElement(super.provider);

  @override
  String get giftId => (origin as AccountGiftProvider).giftId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
