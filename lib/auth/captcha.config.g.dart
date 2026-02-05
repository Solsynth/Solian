// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captcha.config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(captchaUrl)
final captchaUrlProvider = CaptchaUrlProvider._();

final class CaptchaUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  CaptchaUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captchaUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captchaUrlHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return captchaUrl(ref);
  }
}

String _$captchaUrlHash() => r'5d59de4f26a0544bf4fbd5209943f0b111959ce6';
