// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_storage_db.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ComposeStorageNotifier)
final composeStorageProvider = ComposeStorageNotifierProvider._();

final class ComposeStorageNotifierProvider
    extends $NotifierProvider<ComposeStorageNotifier, Map<String, SnPost>> {
  ComposeStorageNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'composeStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$composeStorageNotifierHash();

  @$internal
  @override
  ComposeStorageNotifier create() => ComposeStorageNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, SnPost> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, SnPost>>(value),
    );
  }
}

String _$composeStorageNotifierHash() =>
    r'7c01d4c8f11dbfde728e703a2c319b3c2150002e';

abstract class _$ComposeStorageNotifier extends $Notifier<Map<String, SnPost>> {
  Map<String, SnPost> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, SnPost>, Map<String, SnPost>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, SnPost>, Map<String, SnPost>>,
              Map<String, SnPost>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
