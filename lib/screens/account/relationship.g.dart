// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sentFriendRequest)
final sentFriendRequestProvider = SentFriendRequestProvider._();

final class SentFriendRequestProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnRelationship>>,
          List<SnRelationship>,
          FutureOr<List<SnRelationship>>
        >
    with
        $FutureModifier<List<SnRelationship>>,
        $FutureProvider<List<SnRelationship>> {
  SentFriendRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sentFriendRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sentFriendRequestHash();

  @$internal
  @override
  $FutureProviderElement<List<SnRelationship>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnRelationship>> create(Ref ref) {
    return sentFriendRequest(ref);
  }
}

String _$sentFriendRequestHash() => r'0c52813eb6f86c05f6e0b1e4e840d0d9c350aa9e';
