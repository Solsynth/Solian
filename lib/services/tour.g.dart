// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TourStatusNotifier)
final tourStatusProvider = TourStatusNotifierProvider._();

final class TourStatusNotifierProvider
    extends $NotifierProvider<TourStatusNotifier, Map<String, bool>> {
  TourStatusNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tourStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tourStatusNotifierHash();

  @$internal
  @override
  TourStatusNotifier create() => TourStatusNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, bool>>(value),
    );
  }
}

String _$tourStatusNotifierHash() =>
    r'ee712e1f8010311df8f24838814ab5c451f9e593';

abstract class _$TourStatusNotifier extends $Notifier<Map<String, bool>> {
  Map<String, bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, bool>, Map<String, bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, bool>, Map<String, bool>>,
              Map<String, bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
