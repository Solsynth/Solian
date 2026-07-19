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
    r'ba2a2842ddbb2c9c580e34bf8d4b2af80ce01f1e';

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
    r'ffff8f4c51f286bcc34b41ad1f111da76b57d616';

@ProviderFor(publisherSubscriptionReadStatus)
final publisherSubscriptionReadStatusProvider =
    PublisherSubscriptionReadStatusFamily._();

final class PublisherSubscriptionReadStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<PublisherSubscriptionReadStatus?>,
          PublisherSubscriptionReadStatus?,
          FutureOr<PublisherSubscriptionReadStatus?>
        >
    with
        $FutureModifier<PublisherSubscriptionReadStatus?>,
        $FutureProvider<PublisherSubscriptionReadStatus?> {
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
  $FutureProviderElement<PublisherSubscriptionReadStatus?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PublisherSubscriptionReadStatus?> create(Ref ref) {
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
    r'69290abe2e25aa73458ccd19f94512fbd5da6443';

final class PublisherSubscriptionReadStatusFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PublisherSubscriptionReadStatus?>,
          String
        > {
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
