// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iap_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(iapService)
final iapServiceProvider = IapServiceProvider._();

final class IapServiceProvider
    extends $FunctionalProvider<IapService, IapService, IapService>
    with $Provider<IapService> {
  IapServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iapServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iapServiceHash();

  @$internal
  @override
  $ProviderElement<IapService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IapService create(Ref ref) {
    return iapService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IapService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IapService>(value),
    );
  }
}

String _$iapServiceHash() => r'63f489aacd87d015cbad694f21bc90238da1f972';

@ProviderFor(iapInitialize)
final iapInitializeProvider = IapInitializeProvider._();

final class IapInitializeProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  IapInitializeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iapInitializeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iapInitializeHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return iapInitialize(ref);
  }
}

String _$iapInitializeHash() => r'13dda8de3def9f8dcdf37f7edeb99fb4806b1013';

@ProviderFor(iapLoadProducts)
final iapLoadProductsProvider = IapLoadProductsFamily._();

final class IapLoadProductsProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  IapLoadProductsProvider._({
    required IapLoadProductsFamily super.from,
    required List<String> super.argument,
  }) : super(
         retry: null,
         name: r'iapLoadProductsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$iapLoadProductsHash();

  @override
  String toString() {
    return r'iapLoadProductsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as List<String>;
    return iapLoadProducts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IapLoadProductsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$iapLoadProductsHash() => r'72568f01acb8bfa0ffb58fc3d595e7f99fdf08ab';

final class IapLoadProductsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, List<String>> {
  IapLoadProductsFamily._()
    : super(
        retry: null,
        name: r'iapLoadProductsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IapLoadProductsProvider call(List<String> productIds) =>
      IapLoadProductsProvider._(argument: productIds, from: this);

  @override
  String toString() => r'iapLoadProductsProvider';
}

@ProviderFor(iapPurchaseStream)
final iapPurchaseStreamProvider = IapPurchaseStreamProvider._();

final class IapPurchaseStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PurchaseDetails>>,
          List<PurchaseDetails>,
          Stream<List<PurchaseDetails>>
        >
    with
        $FutureModifier<List<PurchaseDetails>>,
        $StreamProvider<List<PurchaseDetails>> {
  IapPurchaseStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iapPurchaseStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iapPurchaseStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<PurchaseDetails>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PurchaseDetails>> create(Ref ref) {
    return iapPurchaseStream(ref);
  }
}

String _$iapPurchaseStreamHash() => r'a713c78ca79efaa24dd8601abfc8a1c80eaf77d7';

@ProviderFor(iapPurchaseResultStream)
final iapPurchaseResultStreamProvider = IapPurchaseResultStreamProvider._();

final class IapPurchaseResultStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<IapPurchaseResult>,
          IapPurchaseResult,
          Stream<IapPurchaseResult>
        >
    with
        $FutureModifier<IapPurchaseResult>,
        $StreamProvider<IapPurchaseResult> {
  IapPurchaseResultStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iapPurchaseResultStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iapPurchaseResultStreamHash();

  @$internal
  @override
  $StreamProviderElement<IapPurchaseResult> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<IapPurchaseResult> create(Ref ref) {
    return iapPurchaseResultStream(ref);
  }
}

String _$iapPurchaseResultStreamHash() =>
    r'6a951f3f035d2726d3781ed2a878a13664e787d9';

@ProviderFor(iapPurchase)
final iapPurchaseProvider = IapPurchaseFamily._();

final class IapPurchaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<IapPurchaseResult?>,
          IapPurchaseResult?,
          FutureOr<IapPurchaseResult?>
        >
    with
        $FutureModifier<IapPurchaseResult?>,
        $FutureProvider<IapPurchaseResult?> {
  IapPurchaseProvider._({
    required IapPurchaseFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'iapPurchaseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$iapPurchaseHash();

  @override
  String toString() {
    return r'iapPurchaseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<IapPurchaseResult?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<IapPurchaseResult?> create(Ref ref) {
    final argument = this.argument as String;
    return iapPurchase(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IapPurchaseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$iapPurchaseHash() => r'e736dfef6f8b5b7dfc89cde0180e03bc03631a3f';

final class IapPurchaseFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<IapPurchaseResult?>, String> {
  IapPurchaseFamily._()
    : super(
        retry: null,
        name: r'iapPurchaseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IapPurchaseProvider call(String productId) =>
      IapPurchaseProvider._(argument: productId, from: this);

  @override
  String toString() => r'iapPurchaseProvider';
}

@ProviderFor(iapPastPurchases)
final iapPastPurchasesProvider = IapPastPurchasesProvider._();

final class IapPastPurchasesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PurchaseDetails>>,
          List<PurchaseDetails>,
          FutureOr<List<PurchaseDetails>>
        >
    with
        $FutureModifier<List<PurchaseDetails>>,
        $FutureProvider<List<PurchaseDetails>> {
  IapPastPurchasesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iapPastPurchasesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iapPastPurchasesHash();

  @$internal
  @override
  $FutureProviderElement<List<PurchaseDetails>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PurchaseDetails>> create(Ref ref) {
    return iapPastPurchases(ref);
  }
}

String _$iapPastPurchasesHash() => r'409799103668a1c10dd8c9e2621b158d2c7a451a';
