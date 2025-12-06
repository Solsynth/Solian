// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(billingUsage)
const billingUsageProvider = BillingUsageProvider._();

final class BillingUsageProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          FutureOr<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $FutureProvider<Map<String, dynamic>?> {
  const BillingUsageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billingUsageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billingUsageHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>?> create(Ref ref) {
    return billingUsage(ref);
  }
}

String _$billingUsageHash() => r'58d8bc774868d60781574c85d6b25869a79c57aa';

@ProviderFor(billingQuota)
const billingQuotaProvider = BillingQuotaProvider._();

final class BillingQuotaProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          FutureOr<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $FutureProvider<Map<String, dynamic>?> {
  const BillingQuotaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billingQuotaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billingQuotaHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>?> create(Ref ref) {
    return billingQuota(ref);
  }
}

String _$billingQuotaHash() => r'4ec5d728e439015800abb2d0d673b5a7329cc654';
