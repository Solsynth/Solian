// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_manage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Protected-tag quota and owned tags for a publisher.

@ProviderFor(publisherTagQuota)
final publisherTagQuotaProvider = PublisherTagQuotaFamily._();

/// Protected-tag quota and owned tags for a publisher.

final class PublisherTagQuotaProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnTagQuota>,
          SnTagQuota,
          FutureOr<SnTagQuota>
        >
    with $FutureModifier<SnTagQuota>, $FutureProvider<SnTagQuota> {
  /// Protected-tag quota and owned tags for a publisher.
  PublisherTagQuotaProvider._({
    required PublisherTagQuotaFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherTagQuotaProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherTagQuotaHash();

  @override
  String toString() {
    return r'publisherTagQuotaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnTagQuota> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SnTagQuota> create(Ref ref) {
    final argument = this.argument as String;
    return publisherTagQuota(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherTagQuotaProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherTagQuotaHash() => r'd54cac8f76e035c2897fbf23ed95e125960a783a';

/// Protected-tag quota and owned tags for a publisher.

final class PublisherTagQuotaFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnTagQuota>, String> {
  PublisherTagQuotaFamily._()
    : super(
        retry: null,
        name: r'publisherTagQuotaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Protected-tag quota and owned tags for a publisher.

  PublisherTagQuotaProvider call(String pubName) =>
      PublisherTagQuotaProvider._(argument: pubName, from: this);

  @override
  String toString() => r'publisherTagQuotaProvider';
}

@ProviderFor(creatorPublisher)
final creatorPublisherProvider = CreatorPublisherFamily._();

final class CreatorPublisherProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublisher>,
          SnPublisher,
          FutureOr<SnPublisher>
        >
    with $FutureModifier<SnPublisher>, $FutureProvider<SnPublisher> {
  CreatorPublisherProvider._({
    required CreatorPublisherFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'creatorPublisherProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creatorPublisherHash();

  @override
  String toString() {
    return r'creatorPublisherProvider'
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
    return creatorPublisher(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CreatorPublisherProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creatorPublisherHash() => r'1121366a23e3585ba2a110e051c7000b4a756314';

final class CreatorPublisherFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPublisher>, String> {
  CreatorPublisherFamily._()
    : super(
        retry: null,
        name: r'creatorPublisherProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreatorPublisherProvider call(String pubName) =>
      CreatorPublisherProvider._(argument: pubName, from: this);

  @override
  String toString() => r'creatorPublisherProvider';
}
