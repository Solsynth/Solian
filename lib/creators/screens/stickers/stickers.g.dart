// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stickers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(stickerPack)
final stickerPackProvider = StickerPackFamily._();

final class StickerPackProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnStickerPack?>,
          SnStickerPack?,
          FutureOr<SnStickerPack?>
        >
    with $FutureModifier<SnStickerPack?>, $FutureProvider<SnStickerPack?> {
  StickerPackProvider._({
    required StickerPackFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'stickerPackProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stickerPackHash();

  @override
  String toString() {
    return r'stickerPackProvider'
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
    final argument = this.argument as String?;
    return stickerPack(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StickerPackProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stickerPackHash() => r'71ef84471237c8191918095094bdfc87d3920e77';

final class StickerPackFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnStickerPack?>, String?> {
  StickerPackFamily._()
    : super(
        retry: null,
        name: r'stickerPackProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StickerPackProvider call(String? packId) =>
      StickerPackProvider._(argument: packId, from: this);

  @override
  String toString() => r'stickerPackProvider';
}
