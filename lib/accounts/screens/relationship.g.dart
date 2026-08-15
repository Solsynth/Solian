// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(friendRequest)
final friendRequestProvider = FriendRequestProvider._();

final class FriendRequestProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnRelationship>>,
          List<SnRelationship>,
          FutureOr<List<SnRelationship>>
        >
    with
        $FutureModifier<List<SnRelationship>>,
        $FutureProvider<List<SnRelationship>> {
  FriendRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'friendRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendRequestHash();

  @$internal
  @override
  $FutureProviderElement<List<SnRelationship>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnRelationship>> create(Ref ref) {
    return friendRequest(ref);
  }
}

String _$friendRequestHash() => r'68bc584e5c62c443ebad14adc71d02e3b32efa41';
