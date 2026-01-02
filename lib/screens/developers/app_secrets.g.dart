// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_secrets.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(customAppSecrets)
final customAppSecretsProvider = CustomAppSecretsFamily._();

final class CustomAppSecretsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CustomAppSecret>>,
          List<CustomAppSecret>,
          FutureOr<List<CustomAppSecret>>
        >
    with
        $FutureModifier<List<CustomAppSecret>>,
        $FutureProvider<List<CustomAppSecret>> {
  CustomAppSecretsProvider._({
    required CustomAppSecretsFamily super.from,
    required (String, String, String) super.argument,
  }) : super(
         retry: null,
         name: r'customAppSecretsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customAppSecretsHash();

  @override
  String toString() {
    return r'customAppSecretsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<CustomAppSecret>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CustomAppSecret>> create(Ref ref) {
    final argument = this.argument as (String, String, String);
    return customAppSecrets(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomAppSecretsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customAppSecretsHash() => r'1bc62ad812487883ce739793b22a76168d656752';

final class CustomAppSecretsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<CustomAppSecret>>,
          (String, String, String)
        > {
  CustomAppSecretsFamily._()
    : super(
        retry: null,
        name: r'customAppSecretsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomAppSecretsProvider call(
    String publisherName,
    String projectId,
    String appId,
  ) => CustomAppSecretsProvider._(
    argument: (publisherName, projectId, appId),
    from: this,
  );

  @override
  String toString() => r'customAppSecretsProvider';
}
