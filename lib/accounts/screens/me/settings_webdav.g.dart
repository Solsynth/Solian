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

String _$webdavTokensHash() => r'af8e2c772a8759c496af030f84131535d6f65cf5';
