// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_pages.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sitePages)
final sitePagesProvider = SitePagesFamily._();

final class SitePagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnPublicationPage>>,
          List<SnPublicationPage>,
          FutureOr<List<SnPublicationPage>>
        >
    with
        $FutureModifier<List<SnPublicationPage>>,
        $FutureProvider<List<SnPublicationPage>> {
  SitePagesProvider._({
    required SitePagesFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'sitePagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sitePagesHash();

  @override
  String toString() {
    return r'sitePagesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnPublicationPage>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnPublicationPage>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return sitePages(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SitePagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sitePagesHash() => r'9f0c54a4e172ea7d9b71d42c83652bdb7b866485';

final class SitePagesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnPublicationPage>>,
          (String, String)
        > {
  SitePagesFamily._()
    : super(
        retry: null,
        name: r'sitePagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SitePagesProvider call(String pubName, String siteSlug) =>
      SitePagesProvider._(argument: (pubName, siteSlug), from: this);

  @override
  String toString() => r'sitePagesProvider';
}

@ProviderFor(sitePage)
final sitePageProvider = SitePageFamily._();

final class SitePageProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublicationPage>,
          SnPublicationPage,
          FutureOr<SnPublicationPage>
        >
    with
        $FutureModifier<SnPublicationPage>,
        $FutureProvider<SnPublicationPage> {
  SitePageProvider._({
    required SitePageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sitePageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sitePageHash();

  @override
  String toString() {
    return r'sitePageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPublicationPage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPublicationPage> create(Ref ref) {
    final argument = this.argument as String;
    return sitePage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SitePageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sitePageHash() => r'ec4aed328e7e110c632a0ec887aaa00142964c67';

final class SitePageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPublicationPage>, String> {
  SitePageFamily._()
    : super(
        retry: null,
        name: r'sitePageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SitePageProvider call(String pageId) =>
      SitePageProvider._(argument: pageId, from: this);

  @override
  String toString() => r'sitePageProvider';
}
