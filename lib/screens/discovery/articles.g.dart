// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'articles.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(subscribedFeeds)
final subscribedFeedsProvider = SubscribedFeedsProvider._();

final class SubscribedFeedsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnWebFeed>>,
          List<SnWebFeed>,
          FutureOr<List<SnWebFeed>>
        >
    with $FutureModifier<List<SnWebFeed>>, $FutureProvider<List<SnWebFeed>> {
  SubscribedFeedsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscribedFeedsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscribedFeedsHash();

  @$internal
  @override
  $FutureProviderElement<List<SnWebFeed>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnWebFeed>> create(Ref ref) {
    return subscribedFeeds(ref);
  }
}

String _$subscribedFeedsHash() => r'91d6f909a3d2c9f68028550223f7c7b2128727d2';
