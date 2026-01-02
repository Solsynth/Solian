// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_files.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(siteFiles)
final siteFilesProvider = SiteFilesFamily._();

final class SiteFilesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnSiteFileEntry>>,
          List<SnSiteFileEntry>,
          FutureOr<List<SnSiteFileEntry>>
        >
    with
        $FutureModifier<List<SnSiteFileEntry>>,
        $FutureProvider<List<SnSiteFileEntry>> {
  SiteFilesProvider._({
    required SiteFilesFamily super.from,
    required ({String siteId, String? path}) super.argument,
  }) : super(
         retry: null,
         name: r'siteFilesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siteFilesHash();

  @override
  String toString() {
    return r'siteFilesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnSiteFileEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnSiteFileEntry>> create(Ref ref) {
    final argument = this.argument as ({String siteId, String? path});
    return siteFiles(ref, siteId: argument.siteId, path: argument.path);
  }

  @override
  bool operator ==(Object other) {
    return other is SiteFilesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siteFilesHash() => r'd4029e6c160edcd454eb39ef1c19427b7f95a8d8';

final class SiteFilesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnSiteFileEntry>>,
          ({String siteId, String? path})
        > {
  SiteFilesFamily._()
    : super(
        retry: null,
        name: r'siteFilesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SiteFilesProvider call({required String siteId, String? path}) =>
      SiteFilesProvider._(argument: (siteId: siteId, path: path), from: this);

  @override
  String toString() => r'siteFilesProvider';
}

@ProviderFor(siteFileContent)
final siteFileContentProvider = SiteFileContentFamily._();

final class SiteFileContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnFileContent>,
          SnFileContent,
          FutureOr<SnFileContent>
        >
    with $FutureModifier<SnFileContent>, $FutureProvider<SnFileContent> {
  SiteFileContentProvider._({
    required SiteFileContentFamily super.from,
    required ({String siteId, String relativePath}) super.argument,
  }) : super(
         retry: null,
         name: r'siteFileContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siteFileContentHash();

  @override
  String toString() {
    return r'siteFileContentProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SnFileContent> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnFileContent> create(Ref ref) {
    final argument = this.argument as ({String siteId, String relativePath});
    return siteFileContent(
      ref,
      siteId: argument.siteId,
      relativePath: argument.relativePath,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SiteFileContentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siteFileContentHash() => r'b594ad4f8c54555e742ece94ee001092cb2f83d1';

final class SiteFileContentFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SnFileContent>,
          ({String siteId, String relativePath})
        > {
  SiteFileContentFamily._()
    : super(
        retry: null,
        name: r'siteFileContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SiteFileContentProvider call({
    required String siteId,
    required String relativePath,
  }) => SiteFileContentProvider._(
    argument: (siteId: siteId, relativePath: relativePath),
    from: this,
  );

  @override
  String toString() => r'siteFileContentProvider';
}

@ProviderFor(siteFileContentRaw)
final siteFileContentRawProvider = SiteFileContentRawFamily._();

final class SiteFileContentRawProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  SiteFileContentRawProvider._({
    required SiteFileContentRawFamily super.from,
    required ({String siteId, String relativePath}) super.argument,
  }) : super(
         retry: null,
         name: r'siteFileContentRawProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$siteFileContentRawHash();

  @override
  String toString() {
    return r'siteFileContentRawProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as ({String siteId, String relativePath});
    return siteFileContentRaw(
      ref,
      siteId: argument.siteId,
      relativePath: argument.relativePath,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SiteFileContentRawProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$siteFileContentRawHash() =>
    r'd0331c30698a9f4b90fe9b79273ff5914fa46616';

final class SiteFileContentRawFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<String>,
          ({String siteId, String relativePath})
        > {
  SiteFileContentRawFamily._()
    : super(
        retry: null,
        name: r'siteFileContentRawProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SiteFileContentRawProvider call({
    required String siteId,
    required String relativePath,
  }) => SiteFileContentRawProvider._(
    argument: (siteId: siteId, relativePath: relativePath),
    from: this,
  );

  @override
  String toString() => r'siteFileContentRawProvider';
}
