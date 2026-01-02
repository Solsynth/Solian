// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_app.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(customApp)
final customAppProvider = CustomAppFamily._();

final class CustomAppProvider
    extends
        $FunctionalProvider<
          AsyncValue<CustomApp?>,
          CustomApp?,
          FutureOr<CustomApp?>
        >
    with $FutureModifier<CustomApp?>, $FutureProvider<CustomApp?> {
  CustomAppProvider._({
    required CustomAppFamily super.from,
    required (String, String, String) super.argument,
  }) : super(
         retry: null,
         name: r'customAppProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customAppHash();

  @override
  String toString() {
    return r'customAppProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<CustomApp?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CustomApp?> create(Ref ref) {
    final argument = this.argument as (String, String, String);
    return customApp(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomAppProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customAppHash() => r'8e1b38f3dc9b04fad362ee1141fcbfc53f008c09';

final class CustomAppFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<CustomApp?>,
          (String, String, String)
        > {
  CustomAppFamily._()
    : super(
        retry: null,
        name: r'customAppProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomAppProvider call(String publisherName, String projectId, String id) =>
      CustomAppProvider._(argument: (publisherName, projectId, id), from: this);

  @override
  String toString() => r'customAppProvider';
}
