// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fund_envelope.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletFundHash() => r'521fa280708e71266f8164268ba11f135f4ba810';

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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
