// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_authorized_apps.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authorizedApps)
final authorizedAppsProvider = AuthorizedAppsProvider._();

final class AuthorizedAppsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AuthorizedApp>>,
          List<AuthorizedApp>,
          FutureOr<List<AuthorizedApp>>
        >
    with
        $FutureModifier<List<AuthorizedApp>>,
        $FutureProvider<List<AuthorizedApp>> {
  AuthorizedAppsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authorizedAppsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authorizedAppsHash();

  @$internal
  @override
  $FutureProviderElement<List<AuthorizedApp>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AuthorizedApp>> create(Ref ref) {
    return authorizedApps(ref);
  }
}

String _$authorizedAppsHash() => r'1178875817ef5aa7bf24d7286a557b7546662881';
