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

/// Provider to fetch stickers in a pack

@ProviderFor(stickerPackContent)
final stickerPackContentProvider = StickerPackContentFamily._();

/// Provider to fetch stickers in a pack

final class StickerPackContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnSticker>>,
          List<SnSticker>,
          FutureOr<List<SnSticker>>
        >
    with $FutureModifier<List<SnSticker>>, $FutureProvider<List<SnSticker>> {
  /// Provider to fetch stickers in a pack
  StickerPackContentProvider._({
    required StickerPackContentFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'stickerPackContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stickerPackContentHash();

  @override
  String toString() {
    return r'stickerPackContentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnSticker>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnSticker>> create(Ref ref) {
    final argument = this.argument as String;
    return stickerPackContent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StickerPackContentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stickerPackContentHash() =>
    r'1f78e8ba3ca1ede79527ff9ac6dbb6ec7fe13d22';

/// Provider to fetch stickers in a pack

final class StickerPackContentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SnSticker>>, String> {
  StickerPackContentFamily._()
    : super(
        retry: null,
        name: r'stickerPackContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to fetch stickers in a pack

  StickerPackContentProvider call(String packId) =>
      StickerPackContentProvider._(argument: packId, from: this);

  @override
  String toString() => r'stickerPackContentProvider';
}

/// Provider to check if user owns the sticker pack

@ProviderFor(stickerPackOwnership)
final stickerPackOwnershipProvider = StickerPackOwnershipFamily._();

/// Provider to check if user owns the sticker pack

final class StickerPackOwnershipProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider to check if user owns the sticker pack
  StickerPackOwnershipProvider._({
    required StickerPackOwnershipFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'stickerPackOwnershipProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stickerPackOwnershipHash();

  @override
  String toString() {
    return r'stickerPackOwnershipProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return stickerPackOwnership(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StickerPackOwnershipProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stickerPackOwnershipHash() =>
    r'c6f5a4f8ed503b94603061424cac53e6cff54103';

/// Provider to check if user owns the sticker pack

final class StickerPackOwnershipFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  StickerPackOwnershipFamily._()
    : super(
        retry: null,
        name: r'stickerPackOwnershipProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to check if user owns the sticker pack

  StickerPackOwnershipProvider call(String packId) =>
      StickerPackOwnershipProvider._(argument: packId, from: this);

  @override
  String toString() => r'stickerPackOwnershipProvider';
}
