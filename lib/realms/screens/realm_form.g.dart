// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_form.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(realmQuotaInfo)
final realmQuotaInfoProvider = RealmQuotaInfoProvider._();

final class RealmQuotaInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<RealmQuotaInfo>,
          RealmQuotaInfo,
          FutureOr<RealmQuotaInfo>
        >
    with $FutureModifier<RealmQuotaInfo>, $FutureProvider<RealmQuotaInfo> {
  RealmQuotaInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realmQuotaInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realmQuotaInfoHash();

  @$internal
  @override
  $FutureProviderElement<RealmQuotaInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RealmQuotaInfo> create(Ref ref) {
    return realmQuotaInfo(ref);
  }
}

String _$realmQuotaInfoHash() => r'b3df729241c93bae08fd777318525cd6850784cd';
