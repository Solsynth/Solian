// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authFactors)
final authFactorsProvider = AuthFactorsProvider._();

final class AuthFactorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnAuthFactor>>,
          List<SnAuthFactor>,
          FutureOr<List<SnAuthFactor>>
        >
    with
        $FutureModifier<List<SnAuthFactor>>,
        $FutureProvider<List<SnAuthFactor>> {
  AuthFactorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authFactorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authFactorsHash();

  @$internal
  @override
  $FutureProviderElement<List<SnAuthFactor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnAuthFactor>> create(Ref ref) {
    return authFactors(ref);
  }
}

String _$authFactorsHash() => r'3882d31687c327743f2dc6b8b246355551cb2031';

@ProviderFor(contactMethods)
final contactMethodsProvider = ContactMethodsProvider._();

final class ContactMethodsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnContactMethod>>,
          List<SnContactMethod>,
          FutureOr<List<SnContactMethod>>
        >
    with
        $FutureModifier<List<SnContactMethod>>,
        $FutureProvider<List<SnContactMethod>> {
  ContactMethodsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactMethodsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactMethodsHash();

  @$internal
  @override
  $FutureProviderElement<List<SnContactMethod>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnContactMethod>> create(Ref ref) {
    return contactMethods(ref);
  }
}

String _$contactMethodsHash() => r'56804d9a20cfde005f9b1df665de2bc0d0cc9141';

@ProviderFor(accountConnections)
final accountConnectionsProvider = AccountConnectionsProvider._();

final class AccountConnectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnAccountConnection>>,
          List<SnAccountConnection>,
          FutureOr<List<SnAccountConnection>>
        >
    with
        $FutureModifier<List<SnAccountConnection>>,
        $FutureProvider<List<SnAccountConnection>> {
  AccountConnectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountConnectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountConnectionsHash();

  @$internal
  @override
  $FutureProviderElement<List<SnAccountConnection>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnAccountConnection>> create(Ref ref) {
    return accountConnections(ref);
  }
}

String _$accountConnectionsHash() =>
    r'f3393dc4cc77106ca1008cc974fc5f04d1b1802a';

@ProviderFor(publishingSettings)
final publishingSettingsProvider = PublishingSettingsProvider._();

final class PublishingSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublishingSettings>,
          SnPublishingSettings,
          FutureOr<SnPublishingSettings>
        >
    with
        $FutureModifier<SnPublishingSettings>,
        $FutureProvider<SnPublishingSettings> {
  PublishingSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publishingSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publishingSettingsHash();

  @$internal
  @override
  $FutureProviderElement<SnPublishingSettings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPublishingSettings> create(Ref ref) {
    return publishingSettings(ref);
  }
}

String _$publishingSettingsHash() =>
    r'5b878813d983391a12ef61a686318586e5bb5c07';

@ProviderFor(fediverseAvailability)
final fediverseAvailabilityProvider = FediverseAvailabilityProvider._();

final class FediverseAvailabilityProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnFediverseAvailabilityResponse>,
          SnFediverseAvailabilityResponse,
          FutureOr<SnFediverseAvailabilityResponse>
        >
    with
        $FutureModifier<SnFediverseAvailabilityResponse>,
        $FutureProvider<SnFediverseAvailabilityResponse> {
  FediverseAvailabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fediverseAvailabilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fediverseAvailabilityHash();

  @$internal
  @override
  $FutureProviderElement<SnFediverseAvailabilityResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnFediverseAvailabilityResponse> create(Ref ref) {
    return fediverseAvailability(ref);
  }
}

String _$fediverseAvailabilityHash() =>
    r'12ec3d0ffd3b23c48d1ac9a18761005e993518b9';

@ProviderFor(hasFediverseIdentity)
final hasFediverseIdentityProvider = HasFediverseIdentityProvider._();

final class HasFediverseIdentityProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  HasFediverseIdentityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasFediverseIdentityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasFediverseIdentityHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasFediverseIdentity(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasFediverseIdentityHash() =>
    r'f81f8f33594f0e894ccd5e863a6a45d76d629070';
