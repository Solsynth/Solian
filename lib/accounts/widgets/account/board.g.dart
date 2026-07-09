// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(boardWidgetApps)
final boardWidgetAppsProvider = BoardWidgetAppsProvider._();

final class BoardWidgetAppsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BoardWidgetApp>>,
          List<BoardWidgetApp>,
          FutureOr<List<BoardWidgetApp>>
        >
    with
        $FutureModifier<List<BoardWidgetApp>>,
        $FutureProvider<List<BoardWidgetApp>> {
  BoardWidgetAppsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boardWidgetAppsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boardWidgetAppsHash();

  @$internal
  @override
  $FutureProviderElement<List<BoardWidgetApp>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BoardWidgetApp>> create(Ref ref) {
    return boardWidgetApps(ref);
  }
}

String _$boardWidgetAppsHash() => r'101fd09ef1776aac1ab8ddd528a75013d222d398';
