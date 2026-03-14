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

String _$realmQuotaInfoHash() => r'2fdc4ea5cd68de667f82d97d67b483226a9b45f3';
