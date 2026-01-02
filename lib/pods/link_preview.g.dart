// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_preview.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LinkPreview)
final linkPreviewProvider = LinkPreviewFamily._();

final class LinkPreviewProvider
    extends $AsyncNotifierProvider<LinkPreview, SnScrappedLink?> {
  LinkPreviewProvider._({
    required LinkPreviewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'linkPreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$linkPreviewHash();

  @override
  String toString() {
    return r'linkPreviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LinkPreview create() => LinkPreview();

  @override
  bool operator ==(Object other) {
    return other is LinkPreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$linkPreviewHash() => r'5130593d3066155cb958d20714ee577df1f940d7';

final class LinkPreviewFamily extends $Family
    with
        $ClassFamilyOverride<
          LinkPreview,
          AsyncValue<SnScrappedLink?>,
          SnScrappedLink?,
          FutureOr<SnScrappedLink?>,
          String
        > {
  LinkPreviewFamily._()
    : super(
        retry: null,
        name: r'linkPreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LinkPreviewProvider call(String url) =>
      LinkPreviewProvider._(argument: url, from: this);

  @override
  String toString() => r'linkPreviewProvider';
}

abstract class _$LinkPreview extends $AsyncNotifier<SnScrappedLink?> {
  late final _$args = ref.$arg as String;
  String get url => _$args;

  FutureOr<SnScrappedLink?> build(String url);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SnScrappedLink?>, SnScrappedLink?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SnScrappedLink?>, SnScrappedLink?>,
              AsyncValue<SnScrappedLink?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
