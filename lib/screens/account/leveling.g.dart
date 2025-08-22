// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leveling.dart';

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
String _$levelingHistoryNotifierHash() =>
    r'e795f9b7911c9e50f15c095ea237cb0e87bf1e89';

/// See also [LevelingHistoryNotifier].
@ProviderFor(LevelingHistoryNotifier)
final levelingHistoryNotifierProvider = AutoDisposeAsyncNotifierProvider<
  LevelingHistoryNotifier,
  CursorPagingData<SnExperienceRecord>
>.internal(
  LevelingHistoryNotifier.new,
  name: r'levelingHistoryNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$levelingHistoryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LevelingHistoryNotifier =
    AutoDisposeAsyncNotifier<CursorPagingData<SnExperienceRecord>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
