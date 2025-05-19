// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$walletCurrentHash() => r'94e6f3776ce15679d17238e372660c365c9b1028';

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
String _$transactionListNotifierHash() =>
    r'148ffb0ee9e3be3b92de432f314d8ee2f09e9a24';

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
