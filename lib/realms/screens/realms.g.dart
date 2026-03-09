// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realms.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(realmsJoined)
final realmsJoinedProvider = RealmsJoinedProvider._();

final class RealmsJoinedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnRealm>>,
          List<SnRealm>,
          FutureOr<List<SnRealm>>
        >
    with $FutureModifier<List<SnRealm>>, $FutureProvider<List<SnRealm>> {
  RealmsJoinedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realmsJoinedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realmsJoinedHash();

  @$internal
  @override
  $FutureProviderElement<List<SnRealm>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnRealm>> create(Ref ref) {
    return realmsJoined(ref);
  }
}

String _$realmsJoinedHash() => r'c3a7118c19045eac2aca89eed612f3f81467eba6';

@ProviderFor(realm)
final realmProvider = RealmFamily._();

final class RealmProvider
    extends
        $FunctionalProvider<AsyncValue<SnRealm?>, SnRealm?, FutureOr<SnRealm?>>
    with $FutureModifier<SnRealm?>, $FutureProvider<SnRealm?> {
  RealmProvider._({
    required RealmFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'realmProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$realmHash();

  @override
  String toString() {
    return r'realmProvider'
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
    return realm(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RealmProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$realmHash() => r'dccdefcdf75b4a2ff87430b143def82183819484';

final class RealmFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnRealm?>, String?> {
  RealmFamily._()
    : super(
        retry: null,
        name: r'realmProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RealmProvider call(String? identifier) =>
      RealmProvider._(argument: identifier, from: this);

  @override
  String toString() => r'realmProvider';
}

@ProviderFor(realmInvites)
final realmInvitesProvider = RealmInvitesProvider._();

final class RealmInvitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnRealmMember>>,
          List<SnRealmMember>,
          FutureOr<List<SnRealmMember>>
        >
    with
        $FutureModifier<List<SnRealmMember>>,
        $FutureProvider<List<SnRealmMember>> {
  RealmInvitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realmInvitesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realmInvitesHash();

  @$internal
  @override
  $FutureProviderElement<List<SnRealmMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnRealmMember>> create(Ref ref) {
    return realmInvites(ref);
  }
}

String _$realmInvitesHash() => r'8c85ab263d0e43fc2e57c813aa4aca04b0f8fccb';
