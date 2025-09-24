// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$billingUsageHash() => r'270ec8499378ee0c038aa44ad1c2e3ad9025740a';

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
String _$billingQuotaHash() => r'0696b500fa8bb1270641bcacf262be58caff9b38';

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
    r'e2c8a076a9e635c7b43a87d00f78775427ba6334';

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
