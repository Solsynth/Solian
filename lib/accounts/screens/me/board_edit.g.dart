// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_edit.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BoardEditorState)
final boardEditorStateProvider = BoardEditorStateProvider._();

final class BoardEditorStateProvider
    extends
        $NotifierProvider<
          BoardEditorState,
          (Map<String, bool>, List<AccountBoardItem>, List<String>)
        > {
  BoardEditorStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boardEditorStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boardEditorStateHash();

  @$internal
  @override
  BoardEditorState create() => BoardEditorState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    (Map<String, bool>, List<AccountBoardItem>, List<String>) value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<
            (Map<String, bool>, List<AccountBoardItem>, List<String>)
          >(value),
    );
  }
}

String _$boardEditorStateHash() => r'8ad9cde82271a2132427ef4f6f8ea0c3eeb22fa3';

abstract class _$BoardEditorState
    extends
        $Notifier<(Map<String, bool>, List<AccountBoardItem>, List<String>)> {
  (Map<String, bool>, List<AccountBoardItem>, List<String>) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              (Map<String, bool>, List<AccountBoardItem>, List<String>),
              (Map<String, bool>, List<AccountBoardItem>, List<String>)
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                (Map<String, bool>, List<AccountBoardItem>, List<String>),
                (Map<String, bool>, List<AccountBoardItem>, List<String>)
              >,
              (Map<String, bool>, List<AccountBoardItem>, List<String>),
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
