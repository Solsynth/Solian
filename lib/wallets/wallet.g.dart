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

String _$walletCurrentHash() => r'6a341edcd278520b3dca52de000c948762088779';

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

String _$walletStatsHash() => r'7490ae7eef524ca09903ace510b0424d3bc51806';

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

String _$walletFundHash() => r'e81c5dad1d2906c8285f3e08c2501f758d51ea1c';

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
