// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apps.dart';

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
          AsyncValue<CustomApp>,
          CustomApp,
          FutureOr<CustomApp>
        >
    with $FutureModifier<CustomApp>, $FutureProvider<CustomApp> {
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
  $FutureProviderElement<CustomApp> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CustomApp> create(Ref ref) {
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

String _$customAppHash() => r'be05431ba8bf06fd20ee988a61c3663a68e15fc9';

final class CustomAppFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<CustomApp>,
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

  CustomAppProvider call(
    String publisherName,
    String projectId,
    String appId,
  ) => CustomAppProvider._(
    argument: (publisherName, projectId, appId),
    from: this,
  );

  @override
  String toString() => r'customAppProvider';
}

@ProviderFor(customApps)
final customAppsProvider = CustomAppsFamily._();

final class CustomAppsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CustomApp>>,
          List<CustomApp>,
          FutureOr<List<CustomApp>>
        >
    with $FutureModifier<List<CustomApp>>, $FutureProvider<List<CustomApp>> {
  CustomAppsProvider._({
    required CustomAppsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'customAppsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customAppsHash();

  @override
  String toString() {
    return r'customAppsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<CustomApp>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CustomApp>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return customApps(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomAppsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customAppsHash() => r'450bedaf4220b8963cb44afeb14d4c0e80f01b11';

final class CustomAppsFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<CustomApp>>, (String, String)> {
  CustomAppsFamily._()
    : super(
        retry: null,
        name: r'customAppsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomAppsProvider call(String publisherName, String projectId) =>
      CustomAppsProvider._(argument: (publisherName, projectId), from: this);

  @override
  String toString() => r'customAppsProvider';
}
