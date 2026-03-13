// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_subscription_filter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(publishersSubscriptions)
final publishersSubscriptionsProvider = PublishersSubscriptionsProvider._();

final class PublishersSubscriptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnPublisherSubscription>>,
          List<SnPublisherSubscription>,
          FutureOr<List<SnPublisherSubscription>>
        >
    with
        $FutureModifier<List<SnPublisherSubscription>>,
        $FutureProvider<List<SnPublisherSubscription>> {
  PublishersSubscriptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publishersSubscriptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publishersSubscriptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<SnPublisherSubscription>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnPublisherSubscription>> create(Ref ref) {
    return publishersSubscriptions(ref);
  }
}

String _$publishersSubscriptionsHash() =>
    r'756a24e3be7f7d1471ce783df06cea6fd8b75ade';

@ProviderFor(categoriesSubscriptions)
final categoriesSubscriptionsProvider = CategoriesSubscriptionsProvider._();

final class CategoriesSubscriptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnCategorySubscription>>,
          List<SnCategorySubscription>,
          FutureOr<List<SnCategorySubscription>>
        >
    with
        $FutureModifier<List<SnCategorySubscription>>,
        $FutureProvider<List<SnCategorySubscription>> {
  CategoriesSubscriptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesSubscriptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesSubscriptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<SnCategorySubscription>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnCategorySubscription>> create(Ref ref) {
    return categoriesSubscriptions(ref);
  }
}

String _$categoriesSubscriptionsHash() =>
    r'14a8f04d258d1a10aae20ca959495926840c9386';

@ProviderFor(publisherSubscriptionReadStatus)
final publisherSubscriptionReadStatusProvider =
    PublisherSubscriptionReadStatusFamily._();

final class PublisherSubscriptionReadStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<DateTime?>,
          DateTime?,
          FutureOr<DateTime?>
        >
    with $FutureModifier<DateTime?>, $FutureProvider<DateTime?> {
  PublisherSubscriptionReadStatusProvider._({
    required PublisherSubscriptionReadStatusFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherSubscriptionReadStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherSubscriptionReadStatusHash();

  @override
  String toString() {
    return r'publisherSubscriptionReadStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DateTime?> create(Ref ref) {
    final argument = this.argument as String;
    return publisherSubscriptionReadStatus(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherSubscriptionReadStatusProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherSubscriptionReadStatusHash() =>
    r'b5c03eded3c24d5f4aaac56bd87e9ba762379b2f';

final class PublisherSubscriptionReadStatusFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DateTime?>, String> {
  PublisherSubscriptionReadStatusFamily._()
    : super(
        retry: null,
        name: r'publisherSubscriptionReadStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherSubscriptionReadStatusProvider call(String publisherName) =>
      PublisherSubscriptionReadStatusProvider._(
        argument: publisherName,
        from: this,
      );

  @override
  String toString() => r'publisherSubscriptionReadStatusProvider';
}
