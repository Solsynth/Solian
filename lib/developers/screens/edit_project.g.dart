// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_project.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(devProject)
final devProjectProvider = DevProjectFamily._();

final class DevProjectProvider
    extends
        $FunctionalProvider<
          AsyncValue<DevProject?>,
          DevProject?,
          FutureOr<DevProject?>
        >
    with $FutureModifier<DevProject?>, $FutureProvider<DevProject?> {
  DevProjectProvider._({
    required DevProjectFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'devProjectProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$devProjectHash();

  @override
  String toString() {
    return r'devProjectProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<DevProject?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DevProject?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return devProject(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DevProjectProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$devProjectHash() => r'd92be3f5cdc510c2a377615ed5c70622a6842bf2';

final class DevProjectFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DevProject?>, (String, String)> {
  DevProjectFamily._()
    : super(
        retry: null,
        name: r'devProjectProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DevProjectProvider call(String pubName, String id) =>
      DevProjectProvider._(argument: (pubName, id), from: this);

  @override
  String toString() => r'devProjectProvider';
}
