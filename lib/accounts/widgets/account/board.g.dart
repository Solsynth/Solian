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

String _$boardWidgetAppsHash() => r'3653159be327eae3048d1f38f4a4a4cc00b00f3a';

@ProviderFor(boardWidgetByAppSlug)
final boardWidgetByAppSlugProvider = BoardWidgetByAppSlugFamily._();

final class BoardWidgetByAppSlugProvider
    extends
        $FunctionalProvider<
          AsyncValue<BoardWidgetApp?>,
          BoardWidgetApp?,
          FutureOr<BoardWidgetApp?>
        >
    with $FutureModifier<BoardWidgetApp?>, $FutureProvider<BoardWidgetApp?> {
  BoardWidgetByAppSlugProvider._({
    required BoardWidgetByAppSlugFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'boardWidgetByAppSlugProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$boardWidgetByAppSlugHash();

  @override
  String toString() {
    return r'boardWidgetByAppSlugProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BoardWidgetApp?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BoardWidgetApp?> create(Ref ref) {
    final argument = this.argument as String;
    return boardWidgetByAppSlug(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BoardWidgetByAppSlugProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$boardWidgetByAppSlugHash() =>
    r'd06704974c8cfe19a513f8146436512b9a764353';

final class BoardWidgetByAppSlugFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BoardWidgetApp?>, String> {
  BoardWidgetByAppSlugFamily._()
    : super(
        retry: null,
        name: r'boardWidgetByAppSlugProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BoardWidgetByAppSlugProvider call(String slug) =>
      BoardWidgetByAppSlugProvider._(argument: slug, from: this);

  @override
  String toString() => r'boardWidgetByAppSlugProvider';
}
