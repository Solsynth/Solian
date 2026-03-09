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

String _$authFactorsHash() => r'9806897f2b1331c8b3430599659fef3088725a4f';

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

String _$contactMethodsHash() => r'42399a97aa5e1e4e1ddff3171b0ebab69b923113';

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
    r'9e63e495c8e9be25b307b8a00980d613c3c2f605';
