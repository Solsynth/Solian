// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hub.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(developerStats)
final developerStatsProvider = DeveloperStatsFamily._();

final class DeveloperStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeveloperStats?>,
          DeveloperStats?,
          FutureOr<DeveloperStats?>
        >
    with $FutureModifier<DeveloperStats?>, $FutureProvider<DeveloperStats?> {
  DeveloperStatsProvider._({
    required DeveloperStatsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'developerStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$developerStatsHash();

  @override
  String toString() {
    return r'developerStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DeveloperStats?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeveloperStats?> create(Ref ref) {
    final argument = this.argument as String?;
    return developerStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeveloperStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$developerStatsHash() => r'45546f29ec7cd1a9c3a4e0f4e39275e78bf34755';

final class DeveloperStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DeveloperStats?>, String?> {
  DeveloperStatsFamily._()
    : super(
        retry: null,
        name: r'developerStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeveloperStatsProvider call(String? uname) =>
      DeveloperStatsProvider._(argument: uname, from: this);

  @override
  String toString() => r'developerStatsProvider';
}

@ProviderFor(developers)
final developersProvider = DevelopersProvider._();

final class DevelopersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnDeveloper>>,
          List<SnDeveloper>,
          FutureOr<List<SnDeveloper>>
        >
    with
        $FutureModifier<List<SnDeveloper>>,
        $FutureProvider<List<SnDeveloper>> {
  DevelopersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'developersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$developersHash();

  @$internal
  @override
  $FutureProviderElement<List<SnDeveloper>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnDeveloper>> create(Ref ref) {
    return developers(ref);
  }
}

String _$developersHash() => r'252341098617ac398ce133994453f318dd3edbd2';

@ProviderFor(devProjects)
final devProjectsProvider = DevProjectsFamily._();

final class DevProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnDevProject>>,
          List<SnDevProject>,
          FutureOr<List<SnDevProject>>
        >
    with
        $FutureModifier<List<SnDevProject>>,
        $FutureProvider<List<SnDevProject>> {
  DevProjectsProvider._({
    required DevProjectsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'devProjectsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$devProjectsHash();

  @override
  String toString() {
    return r'devProjectsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnDevProject>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnDevProject>> create(Ref ref) {
    final argument = this.argument as String;
    return devProjects(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DevProjectsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$devProjectsHash() => r'746bb10ccd198eaec456af840ffef38b4f688310';

final class DevProjectsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SnDevProject>>, String> {
  DevProjectsFamily._()
    : super(
        retry: null,
        name: r'devProjectsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DevProjectsProvider call(String pubName) =>
      DevProjectsProvider._(argument: pubName, from: this);

  @override
  String toString() => r'devProjectsProvider';
}
