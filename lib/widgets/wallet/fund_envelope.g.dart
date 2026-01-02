// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fund_envelope.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$walletFundHash() => r'521fa280708e71266f8164268ba11f135f4ba810';

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
