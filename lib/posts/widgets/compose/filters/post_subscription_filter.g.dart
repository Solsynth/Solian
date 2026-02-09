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
    r'208463c1f879a3ddab4092112e312a0cd27ebc2f';

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
