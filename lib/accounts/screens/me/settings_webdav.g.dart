// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_webdav.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(webdavTokens)
final webdavTokensProvider = WebdavTokensProvider._();

final class WebdavTokensProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WebdavToken>>,
          List<WebdavToken>,
          FutureOr<List<WebdavToken>>
        >
    with
        $FutureModifier<List<WebdavToken>>,
        $FutureProvider<List<WebdavToken>> {
  WebdavTokensProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webdavTokensProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webdavTokensHash();

  @$internal
  @override
  $FutureProviderElement<List<WebdavToken>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WebdavToken>> create(Ref ref) {
    return webdavTokens(ref);
  }
}

String _$webdavTokensHash() => r'543552b3307487d71e77a940c122406d42471640';

@ProviderFor(s3Tokens)
final s3TokensProvider = S3TokensProvider._();

final class S3TokensProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<S3Token>>,
          List<S3Token>,
          FutureOr<List<S3Token>>
        >
    with $FutureModifier<List<S3Token>>, $FutureProvider<List<S3Token>> {
  S3TokensProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r's3TokensProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$s3TokensHash();

  @$internal
  @override
  $FutureProviderElement<List<S3Token>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<S3Token>> create(Ref ref) {
    return s3Tokens(ref);
  }
}

String _$s3TokensHash() => r'a43c74ba3e666bf75bea82b36ae327f31a4f33a8';

@ProviderFor(myStoragePools)
final myStoragePoolsProvider = MyStoragePoolsProvider._();

final class MyStoragePoolsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StoragePool>>,
          List<StoragePool>,
          FutureOr<List<StoragePool>>
        >
    with
        $FutureModifier<List<StoragePool>>,
        $FutureProvider<List<StoragePool>> {
  MyStoragePoolsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myStoragePoolsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myStoragePoolsHash();

  @$internal
  @override
  $FutureProviderElement<List<StoragePool>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StoragePool>> create(Ref ref) {
    return myStoragePools(ref);
  }
}

String _$myStoragePoolsHash() => r'17e715689c4de5d3c2d51bffa4e09c62f7dee193';
