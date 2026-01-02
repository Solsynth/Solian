// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(walletCurrent)
final walletCurrentProvider = WalletCurrentProvider._();

final class WalletCurrentProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnWallet?>,
          SnWallet?,
          FutureOr<SnWallet?>
        >
    with $FutureModifier<SnWallet?>, $FutureProvider<SnWallet?> {
  WalletCurrentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletCurrentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletCurrentHash();

  @$internal
  @override
  $FutureProviderElement<SnWallet?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SnWallet?> create(Ref ref) {
    return walletCurrent(ref);
  }
}

String _$walletCurrentHash() => r'bdc7cb27ce2286b561a03522085cc4efc884faad';

@ProviderFor(walletStats)
final walletStatsProvider = WalletStatsProvider._();

final class WalletStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnWalletStats>,
          SnWalletStats,
          FutureOr<SnWalletStats>
        >
    with $FutureModifier<SnWalletStats>, $FutureProvider<SnWalletStats> {
  WalletStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletStatsHash();

  @$internal
  @override
  $FutureProviderElement<SnWalletStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnWalletStats> create(Ref ref) {
    return walletStats(ref);
  }
}

String _$walletStatsHash() => r'2243011937b377a66cdf44cae144021cee69e82f';

@ProviderFor(walletFund)
final walletFundProvider = WalletFundFamily._();

final class WalletFundProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnWalletFund>,
          SnWalletFund,
          FutureOr<SnWalletFund>
        >
    with $FutureModifier<SnWalletFund>, $FutureProvider<SnWalletFund> {
  WalletFundProvider._({
    required WalletFundFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'walletFundProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletFundHash();

  @override
  String toString() {
    return r'walletFundProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnWalletFund> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnWalletFund> create(Ref ref) {
    final argument = this.argument as String;
    return walletFund(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletFundProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletFundHash() => r'459efdee5e2775eedaa4312e0d317c218fa7e1fa';

final class WalletFundFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnWalletFund>, String> {
  WalletFundFamily._()
    : super(
        retry: null,
        name: r'walletFundProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WalletFundProvider call(String fundId) =>
      WalletFundProvider._(argument: fundId, from: this);

  @override
  String toString() => r'walletFundProvider';
}
