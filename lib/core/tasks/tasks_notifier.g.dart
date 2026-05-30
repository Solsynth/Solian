// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Tasks)
final tasksProvider = TasksProvider._();

final class TasksProvider extends $NotifierProvider<Tasks, List<AppTask>> {
  TasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksHash();

  @$internal
  @override
  Tasks create() => Tasks();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AppTask> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AppTask>>(value),
    );
  }
}

String _$tasksHash() => r'935a891acd1f7294c772300919dcfa50ad63a778';

abstract class _$Tasks extends $Notifier<List<AppTask>> {
  List<AppTask> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<AppTask>, List<AppTask>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<AppTask>, List<AppTask>>,
              List<AppTask>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(taskEvents)
final taskEventsProvider = TaskEventsProvider._();

final class TaskEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppTaskEvent>,
          AppTaskEvent,
          Stream<AppTaskEvent>
        >
    with $FutureModifier<AppTaskEvent>, $StreamProvider<AppTaskEvent> {
  TaskEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskEventsHash();

  @$internal
  @override
  $StreamProviderElement<AppTaskEvent> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppTaskEvent> create(Ref ref) {
    return taskEvents(ref);
  }
}

String _$taskEventsHash() => r'333c53ea2332ebd946601378fe96344dcb13e885';
