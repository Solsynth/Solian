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

String _$sitePagesHash() => r'5e084e9694ad665e9b238c6a747c6c6e99c5eb03';

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

String _$sitePageHash() => r'542f70c5b103fe34d7cf7eb0821d52f017022efc';

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
