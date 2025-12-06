// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hub.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(publisherStats)
const publisherStatsProvider = PublisherStatsFamily._();

final class PublisherStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublisherStats?>,
          SnPublisherStats?,
          FutureOr<SnPublisherStats?>
        >
    with
        $FutureModifier<SnPublisherStats?>,
        $FutureProvider<SnPublisherStats?> {
  const PublisherStatsProvider._({
    required PublisherStatsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'publisherStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherStatsHash();

  @override
  String toString() {
    return r'publisherStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPublisherStats?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPublisherStats?> create(Ref ref) {
    final argument = this.argument as String?;
    return publisherStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherStatsHash() => r'eea4ed98bf165cc785874f83b912bb7e23d1f7bc';

final class PublisherStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPublisherStats?>, String?> {
  const PublisherStatsFamily._()
    : super(
        retry: null,
        name: r'publisherStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherStatsProvider call(String? uname) =>
      PublisherStatsProvider._(argument: uname, from: this);

  @override
  String toString() => r'publisherStatsProvider';
}

@ProviderFor(publisherHeatmap)
const publisherHeatmapProvider = PublisherHeatmapFamily._();

final class PublisherHeatmapProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnHeatmap?>,
          SnHeatmap?,
          FutureOr<SnHeatmap?>
        >
    with $FutureModifier<SnHeatmap?>, $FutureProvider<SnHeatmap?> {
  const PublisherHeatmapProvider._({
    required PublisherHeatmapFamily super.from,
    required String? super.argument,
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
    final argument = this.argument as String?;
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

String _$publisherHeatmapHash() => r'5f70c55e14629ec8628445a317888e02fccd9af2';

final class PublisherHeatmapFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnHeatmap?>, String?> {
  const PublisherHeatmapFamily._()
    : super(
        retry: null,
        name: r'publisherHeatmapProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherHeatmapProvider call(String? uname) =>
      PublisherHeatmapProvider._(argument: uname, from: this);

  @override
  String toString() => r'publisherHeatmapProvider';
}

@ProviderFor(publisherIdentity)
const publisherIdentityProvider = PublisherIdentityFamily._();

final class PublisherIdentityProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublisherMember?>,
          SnPublisherMember?,
          FutureOr<SnPublisherMember?>
        >
    with
        $FutureModifier<SnPublisherMember?>,
        $FutureProvider<SnPublisherMember?> {
  const PublisherIdentityProvider._({
    required PublisherIdentityFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherIdentityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherIdentityHash();

  @override
  String toString() {
    return r'publisherIdentityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPublisherMember?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPublisherMember?> create(Ref ref) {
    final argument = this.argument as String;
    return publisherIdentity(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherIdentityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherIdentityHash() => r'299372f25fa4b2bf8e11a8ba2d645100fc38e76f';

final class PublisherIdentityFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPublisherMember?>, String> {
  const PublisherIdentityFamily._()
    : super(
        retry: null,
        name: r'publisherIdentityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherIdentityProvider call(String uname) =>
      PublisherIdentityProvider._(argument: uname, from: this);

  @override
  String toString() => r'publisherIdentityProvider';
}

@ProviderFor(publisherFeatures)
const publisherFeaturesProvider = PublisherFeaturesFamily._();

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
  const PublisherFeaturesProvider._({
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
  const PublisherFeaturesFamily._()
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

@ProviderFor(publisherInvites)
const publisherInvitesProvider = PublisherInvitesProvider._();

final class PublisherInvitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnPublisherMember>>,
          List<SnPublisherMember>,
          FutureOr<List<SnPublisherMember>>
        >
    with
        $FutureModifier<List<SnPublisherMember>>,
        $FutureProvider<List<SnPublisherMember>> {
  const PublisherInvitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publisherInvitesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publisherInvitesHash();

  @$internal
  @override
  $FutureProviderElement<List<SnPublisherMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnPublisherMember>> create(Ref ref) {
    return publisherInvites(ref);
  }
}

String _$publisherInvitesHash() => r'93aafc2f02af0a7a055ec1770b3999363dfaabdc';
