// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(marketplaceWebFeed)
final marketplaceWebFeedProvider = MarketplaceWebFeedFamily._();

final class MarketplaceWebFeedProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnWebFeed>,
          SnWebFeed,
          FutureOr<SnWebFeed>
        >
    with $FutureModifier<SnWebFeed>, $FutureProvider<SnWebFeed> {
  MarketplaceWebFeedProvider._({
    required MarketplaceWebFeedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'marketplaceWebFeedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$marketplaceWebFeedHash();

  @override
  String toString() {
    return r'marketplaceWebFeedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnWebFeed> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SnWebFeed> create(Ref ref) {
    final argument = this.argument as String;
    return marketplaceWebFeed(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketplaceWebFeedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$marketplaceWebFeedHash() =>
    r'8383f94f1bc272b903c341b8d95000313b69d14c';

final class MarketplaceWebFeedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnWebFeed>, String> {
  MarketplaceWebFeedFamily._()
    : super(
        retry: null,
        name: r'marketplaceWebFeedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MarketplaceWebFeedProvider call(String feedId) =>
      MarketplaceWebFeedProvider._(argument: feedId, from: this);

  @override
  String toString() => r'marketplaceWebFeedProvider';
}

/// Provider for web feed subscription status

@ProviderFor(marketplaceWebFeedSubscription)
final marketplaceWebFeedSubscriptionProvider =
    MarketplaceWebFeedSubscriptionFamily._();

/// Provider for web feed subscription status

final class MarketplaceWebFeedSubscriptionProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider for web feed subscription status
  MarketplaceWebFeedSubscriptionProvider._({
    required MarketplaceWebFeedSubscriptionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'marketplaceWebFeedSubscriptionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$marketplaceWebFeedSubscriptionHash();

  @override
  String toString() {
    return r'marketplaceWebFeedSubscriptionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return marketplaceWebFeedSubscription(ref, feedId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketplaceWebFeedSubscriptionProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$marketplaceWebFeedSubscriptionHash() =>
    r'2ff06a48ed7d4236b57412ecca55e94c0a0b6330';

/// Provider for web feed subscription status

final class MarketplaceWebFeedSubscriptionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  MarketplaceWebFeedSubscriptionFamily._()
    : super(
        retry: null,
        name: r'marketplaceWebFeedSubscriptionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for web feed subscription status

  MarketplaceWebFeedSubscriptionProvider call({required String feedId}) =>
      MarketplaceWebFeedSubscriptionProvider._(argument: feedId, from: this);

  @override
  String toString() => r'marketplaceWebFeedSubscriptionProvider';
}
