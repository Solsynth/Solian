// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(theme)
final themeProvider = ThemeProvider._();

final class ThemeProvider
    extends $FunctionalProvider<ThemeSet, ThemeSet, ThemeSet>
    with $Provider<ThemeSet> {
  ThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeHash();

  @$internal
  @override
  $ProviderElement<ThemeSet> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeSet create(Ref ref) {
    return theme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeSet value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeSet>(value),
    );
  }
}

String _$themeHash() => r'5b41b68e2fc59431bb195ff75f63383982f7730f';
