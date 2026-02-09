// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(publicationSiteDetail)
final publicationSiteDetailProvider = PublicationSiteDetailFamily._();

final class PublicationSiteDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublicationSite>,
          SnPublicationSite,
          FutureOr<SnPublicationSite>
        >
    with
        $FutureModifier<SnPublicationSite>,
        $FutureProvider<SnPublicationSite> {
  PublicationSiteDetailProvider._({
    required PublicationSiteDetailFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'publicationSiteDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publicationSiteDetailHash();

  @override
  String toString() {
    return r'publicationSiteDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SnPublicationSite> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPublicationSite> create(Ref ref) {
    final argument = this.argument as (String, String);
    return publicationSiteDetail(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicationSiteDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publicationSiteDetailHash() =>
    r'e5d259ea39c4ba47e92d37e644fc3d84984927a9';

final class PublicationSiteDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SnPublicationSite>,
          (String, String)
        > {
  PublicationSiteDetailFamily._()
    : super(
        retry: null,
        name: r'publicationSiteDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublicationSiteDetailProvider call(String pubName, String siteSlug) =>
      PublicationSiteDetailProvider._(
        argument: (pubName, siteSlug),
        from: this,
      );

  @override
  String toString() => r'publicationSiteDetailProvider';
}
