// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_task_ws_handler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DriveTaskWsHandler)
final driveTaskWsHandlerProvider = DriveTaskWsHandlerProvider._();

final class DriveTaskWsHandlerProvider
    extends $NotifierProvider<DriveTaskWsHandler, void> {
  DriveTaskWsHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveTaskWsHandlerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveTaskWsHandlerHash();

  @$internal
  @override
  DriveTaskWsHandler create() => DriveTaskWsHandler();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$driveTaskWsHandlerHash() =>
    r'2e74fff852ab6e98a6f40f63c63ca86316aff6bc';

abstract class _$DriveTaskWsHandler extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
