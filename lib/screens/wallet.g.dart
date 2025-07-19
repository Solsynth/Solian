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
