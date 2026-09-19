// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_console.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(personalityModels)
final personalityModelsProvider = PersonalityModelsProvider._();

final class PersonalityModelsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnPersonalityModel>>,
          List<SnPersonalityModel>,
          FutureOr<List<SnPersonalityModel>>
        >
    with
        $FutureModifier<List<SnPersonalityModel>>,
        $FutureProvider<List<SnPersonalityModel>> {
  PersonalityModelsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personalityModelsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personalityModelsHash();

  @$internal
  @override
  $FutureProviderElement<List<SnPersonalityModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnPersonalityModel>> create(Ref ref) {
    return personalityModels(ref);
  }
}

String _$personalityModelsHash() => r'cb4d19d77c53abf5505f6d1f1a4fceddc230b382';

@ProviderFor(personalityBilling)
final personalityBillingProvider = PersonalityBillingProvider._();

final class PersonalityBillingProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPersonalityBilling>,
          SnPersonalityBilling,
          FutureOr<SnPersonalityBilling>
        >
    with
        $FutureModifier<SnPersonalityBilling>,
        $FutureProvider<SnPersonalityBilling> {
  PersonalityBillingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personalityBillingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personalityBillingHash();

  @$internal
  @override
  $FutureProviderElement<SnPersonalityBilling> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPersonalityBilling> create(Ref ref) {
    return personalityBilling(ref);
  }
}

String _$personalityBillingHash() =>
    r'bc63ccde2fb00ee21ccb431a6b79e977cb82c434';

@ProviderFor(personalityCredentials)
final personalityCredentialsProvider = PersonalityCredentialsProvider._();

final class PersonalityCredentialsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnPersonalityCredential>>,
          List<SnPersonalityCredential>,
          FutureOr<List<SnPersonalityCredential>>
        >
    with
        $FutureModifier<List<SnPersonalityCredential>>,
        $FutureProvider<List<SnPersonalityCredential>> {
  PersonalityCredentialsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personalityCredentialsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personalityCredentialsHash();

  @$internal
  @override
  $FutureProviderElement<List<SnPersonalityCredential>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnPersonalityCredential>> create(Ref ref) {
    return personalityCredentials(ref);
  }
}

String _$personalityCredentialsHash() =>
    r'13eb302e47c87eeb56261dcf3e9dba0cf7dd01c1';

@ProviderFor(personalityOAuthStatus)
final personalityOAuthStatusProvider = PersonalityOAuthStatusProvider._();

final class PersonalityOAuthStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPersonalityOAuthStatus>,
          SnPersonalityOAuthStatus,
          FutureOr<SnPersonalityOAuthStatus>
        >
    with
        $FutureModifier<SnPersonalityOAuthStatus>,
        $FutureProvider<SnPersonalityOAuthStatus> {
  PersonalityOAuthStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personalityOAuthStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personalityOAuthStatusHash();

  @$internal
  @override
  $FutureProviderElement<SnPersonalityOAuthStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPersonalityOAuthStatus> create(Ref ref) {
    return personalityOAuthStatus(ref);
  }
}

String _$personalityOAuthStatusHash() =>
    r'612e9074f8d3662700f6725023a80f7a49f31f40';
