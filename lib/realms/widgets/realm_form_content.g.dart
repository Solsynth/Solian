// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_form_content.dart';

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

@ProviderFor(_realm)
final _realmProvider = _RealmFamily._();

final class _RealmProvider
    extends
        $FunctionalProvider<AsyncValue<SnRealm?>, SnRealm?, FutureOr<SnRealm?>>
    with $FutureModifier<SnRealm?>, $FutureProvider<SnRealm?> {
  _RealmProvider._({
    required _RealmFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'_realmProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_realmHash();

  @override
  String toString() {
    return r'_realmProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnRealm?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SnRealm?> create(Ref ref) {
    final argument = this.argument as String?;
    return _realm(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is _RealmProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_realmHash() => r'31640a9f7697127c485b76b2ce7cdac361f5dca4';

final class _RealmFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnRealm?>, String?> {
  _RealmFamily._()
    : super(
        retry: null,
        name: r'_realmProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  _RealmProvider call(String? identifier) =>
      _RealmProvider._(argument: identifier, from: this);

  @override
  String toString() => r'_realmProvider';
}
