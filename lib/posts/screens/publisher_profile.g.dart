// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publisher_profile.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(publisher)
final publisherProvider = PublisherFamily._();

final class PublisherProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublisher>,
          SnPublisher,
          FutureOr<SnPublisher>
        >
    with $FutureModifier<SnPublisher>, $FutureProvider<SnPublisher> {
  PublisherProvider._({
    required PublisherFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherHash();

  @override
  String toString() {
    return r'publisherProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPublisher> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPublisher> create(Ref ref) {
    final argument = this.argument as String;
    return publisher(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherHash() => r'a1da21f0275421382e2882fd52c4e061c4675cf7';

final class PublisherFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPublisher>, String> {
  PublisherFamily._()
    : super(
        retry: null,
        name: r'publisherProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherProvider call(String uname) =>
      PublisherProvider._(argument: uname, from: this);

  @override
  String toString() => r'publisherProvider';
}

@ProviderFor(publisherBadges)
final publisherBadgesProvider = PublisherBadgesFamily._();

final class PublisherBadgesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnAccountBadge>>,
          List<SnAccountBadge>,
          FutureOr<List<SnAccountBadge>>
        >
    with
        $FutureModifier<List<SnAccountBadge>>,
        $FutureProvider<List<SnAccountBadge>> {
  PublisherBadgesProvider._({
    required PublisherBadgesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherBadgesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherBadgesHash();

  @override
  String toString() {
    return r'publisherBadgesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnAccountBadge>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnAccountBadge>> create(Ref ref) {
    final argument = this.argument as String;
    return publisherBadges(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherBadgesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherBadgesHash() => r'a355f0d1d150e820464cd23eaf8acfdc76992991';

final class PublisherBadgesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SnAccountBadge>>, String> {
  PublisherBadgesFamily._()
    : super(
        retry: null,
        name: r'publisherBadgesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherBadgesProvider call(String pubName) =>
      PublisherBadgesProvider._(argument: pubName, from: this);

  @override
  String toString() => r'publisherBadgesProvider';
}

@ProviderFor(publisherSubscriptionStatus)
final publisherSubscriptionStatusProvider =
    PublisherSubscriptionStatusFamily._();

final class PublisherSubscriptionStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublisherSubscription?>,
          SnPublisherSubscription?,
          FutureOr<SnPublisherSubscription?>
        >
    with
        $FutureModifier<SnPublisherSubscription?>,
        $FutureProvider<SnPublisherSubscription?> {
  PublisherSubscriptionStatusProvider._({
    required PublisherSubscriptionStatusFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherSubscriptionStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherSubscriptionStatusHash();

  @override
  String toString() {
    return r'publisherSubscriptionStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPublisherSubscription?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPublisherSubscription?> create(Ref ref) {
    final argument = this.argument as String;
    return publisherSubscriptionStatus(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherSubscriptionStatusProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherSubscriptionStatusHash() =>
    r'688bf38554afea9e68b2cb59c5f08c6e8dd31b62';

final class PublisherSubscriptionStatusFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPublisherSubscription?>, String> {
  PublisherSubscriptionStatusFamily._()
    : super(
        retry: null,
        name: r'publisherSubscriptionStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherSubscriptionStatusProvider call(String pubName) =>
      PublisherSubscriptionStatusProvider._(argument: pubName, from: this);

  @override
  String toString() => r'publisherSubscriptionStatusProvider';
}

@ProviderFor(publisherFollowRequest)
final publisherFollowRequestProvider = PublisherFollowRequestFamily._();

final class PublisherFollowRequestProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublisherSubscriptionStatus?>,
          SnPublisherSubscriptionStatus?,
          FutureOr<SnPublisherSubscriptionStatus?>
        >
    with
        $FutureModifier<SnPublisherSubscriptionStatus?>,
        $FutureProvider<SnPublisherSubscriptionStatus?> {
  PublisherFollowRequestProvider._({
    required PublisherFollowRequestFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherFollowRequestProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherFollowRequestHash();

  @override
  String toString() {
    return r'publisherFollowRequestProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPublisherSubscriptionStatus?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPublisherSubscriptionStatus?> create(Ref ref) {
    final argument = this.argument as String;
    return publisherFollowRequest(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherFollowRequestProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherFollowRequestHash() =>
    r'9b778b21df7d539c016282e7cf3b931b4334d7da';

final class PublisherFollowRequestFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SnPublisherSubscriptionStatus?>,
          String
        > {
  PublisherFollowRequestFamily._()
    : super(
        retry: null,
        name: r'publisherFollowRequestProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherFollowRequestProvider call(String pubName) =>
      PublisherFollowRequestProvider._(argument: pubName, from: this);

  @override
  String toString() => r'publisherFollowRequestProvider';
}

@ProviderFor(publisherFeatures)
final publisherFeaturesProvider = PublisherFeaturesFamily._();

final class PublisherFeaturesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, bool>>,
          Map<String, bool>,
          FutureOr<Map<String, bool>>
        >
    with
        $FutureModifier<Map<String, bool>>,
        $FutureProvider<Map<String, bool>> {
  PublisherFeaturesProvider._({
    required PublisherFeaturesFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'publisherFeaturesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherFeaturesHash();

  @override
  String toString() {
    return r'publisherFeaturesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, bool>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, bool>> create(Ref ref) {
    final argument = this.argument as String?;
    return publisherFeatures(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherFeaturesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherFeaturesHash() => r'08bace2d9a3da227ecec0cbf8709e55ee0646ca2';

final class PublisherFeaturesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, bool>>, String?> {
  PublisherFeaturesFamily._()
    : super(
        retry: null,
        name: r'publisherFeaturesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherFeaturesProvider call(String? uname) =>
      PublisherFeaturesProvider._(argument: uname, from: this);

  @override
  String toString() => r'publisherFeaturesProvider';
}

@ProviderFor(publisherHeatmap)
final publisherHeatmapProvider = PublisherHeatmapFamily._();

final class PublisherHeatmapProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnHeatmap?>,
          SnHeatmap?,
          FutureOr<SnHeatmap?>
        >
    with $FutureModifier<SnHeatmap?>, $FutureProvider<SnHeatmap?> {
  PublisherHeatmapProvider._({
    required PublisherHeatmapFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherHeatmapProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherHeatmapHash();

  @override
  String toString() {
    return r'publisherHeatmapProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnHeatmap?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SnHeatmap?> create(Ref ref) {
    final argument = this.argument as String;
    return publisherHeatmap(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherHeatmapProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherHeatmapHash() => r'86db275ce3861a2855b5ec35fbfef85fc47b23a6';

final class PublisherHeatmapFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnHeatmap?>, String> {
  PublisherHeatmapFamily._()
    : super(
        retry: null,
        name: r'publisherHeatmapProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherHeatmapProvider call(String uname) =>
      PublisherHeatmapProvider._(argument: uname, from: this);

  @override
  String toString() => r'publisherHeatmapProvider';
}
