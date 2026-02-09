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

String _$publisherBadgesHash() => r'26776fd6cb611953f52bdb6a7dfa004c34d5cd8e';

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

@ProviderFor(publisherAppbarForcegroundColor)
final publisherAppbarForcegroundColorProvider =
    PublisherAppbarForcegroundColorFamily._();

final class PublisherAppbarForcegroundColorProvider
    extends $FunctionalProvider<AsyncValue<Color?>, Color?, FutureOr<Color?>>
    with $FutureModifier<Color?>, $FutureProvider<Color?> {
  PublisherAppbarForcegroundColorProvider._({
    required PublisherAppbarForcegroundColorFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherAppbarForcegroundColorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherAppbarForcegroundColorHash();

  @override
  String toString() {
    return r'publisherAppbarForcegroundColorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Color?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Color?> create(Ref ref) {
    final argument = this.argument as String;
    return publisherAppbarForcegroundColor(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherAppbarForcegroundColorProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherAppbarForcegroundColorHash() =>
    r'a7c9795c68a29beb611d2c258022c9a5640f2061';

final class PublisherAppbarForcegroundColorFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Color?>, String> {
  PublisherAppbarForcegroundColorFamily._()
    : super(
        retry: null,
        name: r'publisherAppbarForcegroundColorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherAppbarForcegroundColorProvider call(String pubName) =>
      PublisherAppbarForcegroundColorProvider._(argument: pubName, from: this);

  @override
  String toString() => r'publisherAppbarForcegroundColorProvider';
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
