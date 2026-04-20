// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_sheet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to fetch sticker pack by prefix

@ProviderFor(stickerPackByPrefix)
final stickerPackByPrefixProvider = StickerPackByPrefixFamily._();

/// Provider to fetch sticker pack by prefix

final class StickerPackByPrefixProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnStickerPack?>,
          SnStickerPack?,
          FutureOr<SnStickerPack?>
        >
    with $FutureModifier<SnStickerPack?>, $FutureProvider<SnStickerPack?> {
  /// Provider to fetch sticker pack by prefix
  StickerPackByPrefixProvider._({
    required StickerPackByPrefixFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'stickerPackByPrefixProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stickerPackByPrefixHash();

  @override
  String toString() {
    return r'stickerPackByPrefixProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnStickerPack?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnStickerPack?> create(Ref ref) {
    final argument = this.argument as String;
    return stickerPackByPrefix(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StickerPackByPrefixProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stickerPackByPrefixHash() =>
    r'5f73a6d7fa437478cb403ad2453769fd4c59f349';

/// Provider to fetch sticker pack by prefix

final class StickerPackByPrefixFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnStickerPack?>, String> {
  StickerPackByPrefixFamily._()
    : super(
        retry: null,
        name: r'stickerPackByPrefixProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to fetch sticker pack by prefix

  StickerPackByPrefixProvider call(String prefix) =>
      StickerPackByPrefixProvider._(argument: prefix, from: this);

  @override
  String toString() => r'stickerPackByPrefixProvider';
}
