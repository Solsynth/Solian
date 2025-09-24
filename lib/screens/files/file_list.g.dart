// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$billingUsageHash() => r'58d8bc774868d60781574c85d6b25869a79c57aa';

/// See also [billingUsage].
@ProviderFor(billingUsage)
final billingUsageProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>?>.internal(
      billingUsage,
      name: r'billingUsageProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$billingUsageHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BillingUsageRef = AutoDisposeFutureProviderRef<Map<String, dynamic>?>;
String _$billingQuotaHash() => r'4ec5d728e439015800abb2d0d673b5a7329cc654';

/// See also [billingQuota].
@ProviderFor(billingQuota)
final billingQuotaProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>?>.internal(
      billingQuota,
      name: r'billingQuotaProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$billingQuotaHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BillingQuotaRef = AutoDisposeFutureProviderRef<Map<String, dynamic>?>;
String _$cloudFileListNotifierHash() =>
    r'22c45a8ea23147a3835ba870ad2f0bb833f853ea';

/// See also [CloudFileListNotifier].
@ProviderFor(CloudFileListNotifier)
final cloudFileListNotifierProvider = AutoDisposeAsyncNotifierProvider<
  CloudFileListNotifier,
  CursorPagingData<SnCloudFile>
>.internal(
  CloudFileListNotifier.new,
  name: r'cloudFileListNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cloudFileListNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CloudFileListNotifier =
    AutoDisposeAsyncNotifier<CursorPagingData<SnCloudFile>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
