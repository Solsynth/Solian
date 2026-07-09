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
          (Map<String, bool>, List<AccountBoardItem>)
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
    (Map<String, bool>, List<AccountBoardItem>) value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<(Map<String, bool>, List<AccountBoardItem>)>(
            value,
          ),
    );
  }
}

String _$boardEditorStateHash() => r'b5f01b824590a086ecbd32d299f1583a694a7e1b';

abstract class _$BoardEditorState
    extends $Notifier<(Map<String, bool>, List<AccountBoardItem>)> {
  (Map<String, bool>, List<AccountBoardItem>) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              (Map<String, bool>, List<AccountBoardItem>),
              (Map<String, bool>, List<AccountBoardItem>)
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                (Map<String, bool>, List<AccountBoardItem>),
                (Map<String, bool>, List<AccountBoardItem>)
              >,
              (Map<String, bool>, List<AccountBoardItem>),
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
