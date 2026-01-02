// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(stickerPackContent)
final stickerPackContentProvider = StickerPackContentFamily._();

final class StickerPackContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnSticker>>,
          List<SnSticker>,
          FutureOr<List<SnSticker>>
        >
    with $FutureModifier<List<SnSticker>>, $FutureProvider<List<SnSticker>> {
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
    r'42d74f51022e67e35cb601c2f30f4f02e1f2be9d';

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

  StickerPackContentProvider call(String packId) =>
      StickerPackContentProvider._(argument: packId, from: this);

  @override
  String toString() => r'stickerPackContentProvider';
}

@ProviderFor(stickerPackSticker)
final stickerPackStickerProvider = StickerPackStickerFamily._();

final class StickerPackStickerProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnSticker?>,
          SnSticker?,
          FutureOr<SnSticker?>
        >
    with $FutureModifier<SnSticker?>, $FutureProvider<SnSticker?> {
  StickerPackStickerProvider._({
    required StickerPackStickerFamily super.from,
    required StickerWithPackQuery? super.argument,
  }) : super(
         retry: null,
         name: r'stickerPackStickerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stickerPackStickerHash();

  @override
  String toString() {
    return r'stickerPackStickerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnSticker?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SnSticker?> create(Ref ref) {
    final argument = this.argument as StickerWithPackQuery?;
    return stickerPackSticker(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StickerPackStickerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stickerPackStickerHash() =>
    r'5c553666b3a63530bdebae4b7cd52f303c5ab3a0';

final class StickerPackStickerFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<SnSticker?>, StickerWithPackQuery?> {
  StickerPackStickerFamily._()
    : super(
        retry: null,
        name: r'stickerPackStickerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StickerPackStickerProvider call(StickerWithPackQuery? query) =>
      StickerPackStickerProvider._(argument: query, from: this);

  @override
  String toString() => r'stickerPackStickerProvider';
}
