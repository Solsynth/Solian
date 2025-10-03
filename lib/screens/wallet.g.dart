// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletCurrentHash() => r'088505ce1a78901016a3bda05217f813ed3b44c6';

/// See also [walletCurrent].
@ProviderFor(walletCurrent)
final walletCurrentProvider = AutoDisposeFutureProvider<SnWallet?>.internal(
  walletCurrent,
  name: r'walletCurrentProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$walletCurrentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalletCurrentRef = AutoDisposeFutureProviderRef<SnWallet?>;
String _$walletFundsHash() => r'7ceb415f64fcadab2b10461e27b95bf92352c707';

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

/// See also [walletFunds].
@ProviderFor(walletFunds)
const walletFundsProvider = WalletFundsFamily();

/// See also [walletFunds].
class WalletFundsFamily extends Family<AsyncValue<List<SnWalletFund>>> {
  /// See also [walletFunds].
  const WalletFundsFamily();

  /// See also [walletFunds].
  WalletFundsProvider call({int offset = 0, int take = 20}) {
    return WalletFundsProvider(offset: offset, take: take);
  }

  @override
  WalletFundsProvider getProviderOverride(
    covariant WalletFundsProvider provider,
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
  String? get name => r'walletFundsProvider';
}

/// See also [walletFunds].
class WalletFundsProvider
    extends AutoDisposeFutureProvider<List<SnWalletFund>> {
  /// See also [walletFunds].
  WalletFundsProvider({int offset = 0, int take = 20})
    : this._internal(
        (ref) => walletFunds(ref as WalletFundsRef, offset: offset, take: take),
        from: walletFundsProvider,
        name: r'walletFundsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$walletFundsHash,
        dependencies: WalletFundsFamily._dependencies,
        allTransitiveDependencies: WalletFundsFamily._allTransitiveDependencies,
        offset: offset,
        take: take,
      );

  WalletFundsProvider._internal(
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
    FutureOr<List<SnWalletFund>> Function(WalletFundsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WalletFundsProvider._internal(
        (ref) => create(ref as WalletFundsRef),
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
  AutoDisposeFutureProviderElement<List<SnWalletFund>> createElement() {
    return _WalletFundsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletFundsProvider &&
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
mixin WalletFundsRef on AutoDisposeFutureProviderRef<List<SnWalletFund>> {
  /// The parameter `offset` of this provider.
  int get offset;

  /// The parameter `take` of this provider.
  int get take;
}

class _WalletFundsProviderElement
    extends AutoDisposeFutureProviderElement<List<SnWalletFund>>
    with WalletFundsRef {
  _WalletFundsProviderElement(super.provider);

  @override
  int get offset => (origin as WalletFundsProvider).offset;
  @override
  int get take => (origin as WalletFundsProvider).take;
}

String _$walletFundRecipientsHash() =>
    r'18eb815eb709449dd5c545d81fc0ee43ca667578';

/// See also [walletFundRecipients].
@ProviderFor(walletFundRecipients)
const walletFundRecipientsProvider = WalletFundRecipientsFamily();

/// See also [walletFundRecipients].
class WalletFundRecipientsFamily
    extends Family<AsyncValue<List<SnWalletFundRecipient>>> {
  /// See also [walletFundRecipients].
  const WalletFundRecipientsFamily();

  /// See also [walletFundRecipients].
  WalletFundRecipientsProvider call({int offset = 0, int take = 20}) {
    return WalletFundRecipientsProvider(offset: offset, take: take);
  }

  @override
  WalletFundRecipientsProvider getProviderOverride(
    covariant WalletFundRecipientsProvider provider,
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
  String? get name => r'walletFundRecipientsProvider';
}

/// See also [walletFundRecipients].
class WalletFundRecipientsProvider
    extends AutoDisposeFutureProvider<List<SnWalletFundRecipient>> {
  /// See also [walletFundRecipients].
  WalletFundRecipientsProvider({int offset = 0, int take = 20})
    : this._internal(
        (ref) => walletFundRecipients(
          ref as WalletFundRecipientsRef,
          offset: offset,
          take: take,
        ),
        from: walletFundRecipientsProvider,
        name: r'walletFundRecipientsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$walletFundRecipientsHash,
        dependencies: WalletFundRecipientsFamily._dependencies,
        allTransitiveDependencies:
            WalletFundRecipientsFamily._allTransitiveDependencies,
        offset: offset,
        take: take,
      );

  WalletFundRecipientsProvider._internal(
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
    FutureOr<List<SnWalletFundRecipient>> Function(
      WalletFundRecipientsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WalletFundRecipientsProvider._internal(
        (ref) => create(ref as WalletFundRecipientsRef),
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
  AutoDisposeFutureProviderElement<List<SnWalletFundRecipient>>
  createElement() {
    return _WalletFundRecipientsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletFundRecipientsProvider &&
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
mixin WalletFundRecipientsRef
    on AutoDisposeFutureProviderRef<List<SnWalletFundRecipient>> {
  /// The parameter `offset` of this provider.
  int get offset;

  /// The parameter `take` of this provider.
  int get take;
}

class _WalletFundRecipientsProviderElement
    extends AutoDisposeFutureProviderElement<List<SnWalletFundRecipient>>
    with WalletFundRecipientsRef {
  _WalletFundRecipientsProviderElement(super.provider);

  @override
  int get offset => (origin as WalletFundRecipientsProvider).offset;
  @override
  int get take => (origin as WalletFundRecipientsProvider).take;
}

String _$walletFundHash() => r'a690b0def8f4293b4a8f244e44f8bb735687e5dd';

/// See also [walletFund].
@ProviderFor(walletFund)
const walletFundProvider = WalletFundFamily();

/// See also [walletFund].
class WalletFundFamily extends Family<AsyncValue<SnWalletFund>> {
  /// See also [walletFund].
  const WalletFundFamily();

  /// See also [walletFund].
  WalletFundProvider call(String fundId) {
    return WalletFundProvider(fundId);
  }

  @override
  WalletFundProvider getProviderOverride(
    covariant WalletFundProvider provider,
  ) {
    return call(provider.fundId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'walletFundProvider';
}

/// See also [walletFund].
class WalletFundProvider extends AutoDisposeFutureProvider<SnWalletFund> {
  /// See also [walletFund].
  WalletFundProvider(String fundId)
    : this._internal(
        (ref) => walletFund(ref as WalletFundRef, fundId),
        from: walletFundProvider,
        name: r'walletFundProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$walletFundHash,
        dependencies: WalletFundFamily._dependencies,
        allTransitiveDependencies: WalletFundFamily._allTransitiveDependencies,
        fundId: fundId,
      );

  WalletFundProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fundId,
  }) : super.internal();

  final String fundId;

  @override
  Override overrideWith(
    FutureOr<SnWalletFund> Function(WalletFundRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WalletFundProvider._internal(
        (ref) => create(ref as WalletFundRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fundId: fundId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SnWalletFund> createElement() {
    return _WalletFundProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletFundProvider && other.fundId == fundId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fundId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WalletFundRef on AutoDisposeFutureProviderRef<SnWalletFund> {
  /// The parameter `fundId` of this provider.
  String get fundId;
}

class _WalletFundProviderElement
    extends AutoDisposeFutureProviderElement<SnWalletFund>
    with WalletFundRef {
  _WalletFundProviderElement(super.provider);

  @override
  String get fundId => (origin as WalletFundProvider).fundId;
}

String _$walletFundStatsHash() => r'fac8761cf7828fa151e8cc9115416265148bd00e';

/// See also [walletFundStats].
@ProviderFor(walletFundStats)
final walletFundStatsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
      walletFundStats,
      name: r'walletFundStatsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$walletFundStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WalletFundStatsRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$transactionListNotifierHash() =>
    r'7b777cd44f3351f68f7bd1dd76bfe8b388381bdb';

/// See also [TransactionListNotifier].
@ProviderFor(TransactionListNotifier)
final transactionListNotifierProvider = AutoDisposeAsyncNotifierProvider<
  TransactionListNotifier,
  CursorPagingData<SnTransaction>
>.internal(
  TransactionListNotifier.new,
  name: r'transactionListNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$transactionListNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionListNotifier =
    AutoDisposeAsyncNotifier<CursorPagingData<SnTransaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
