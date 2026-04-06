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
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
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
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return authorizedApps(ref);
  }
}

String _$authorizedAppsHash() => r'a5a89dcaf1c0df95e29b92c20088d3d0f75e9f08';
