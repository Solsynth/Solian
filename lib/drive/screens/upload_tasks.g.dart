// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_tasks.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UploadTasks)
final uploadTasksProvider = UploadTasksProvider._();

final class UploadTasksProvider
    extends $NotifierProvider<UploadTasks, List<DriveTask>> {
  UploadTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uploadTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uploadTasksHash();

  @$internal
  @override
  UploadTasks create() => UploadTasks();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DriveTask> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DriveTask>>(value),
    );
  }
}

String _$uploadTasksHash() => r'83f5ceeab49a9476891d739fe0f5c347c1d6306e';

abstract class _$UploadTasks extends $Notifier<List<DriveTask>> {
  List<DriveTask> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<DriveTask>, List<DriveTask>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<DriveTask>, List<DriveTask>>,
              List<DriveTask>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
