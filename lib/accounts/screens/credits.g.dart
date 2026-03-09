// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credits.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(socialCredits)
final socialCreditsProvider = SocialCreditsProvider._();

final class SocialCreditsProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  SocialCreditsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialCreditsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialCreditsHash();

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    return socialCredits(ref);
  }
}

String _$socialCreditsHash() => r'523ca19108237345335d3fc48c8107092128f2b4';
