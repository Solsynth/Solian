// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sentFriendRequestHash() => r'0c52813eb6f86c05f6e0b1e4e840d0d9c350aa9e';

/// See also [sentFriendRequest].
@ProviderFor(sentFriendRequest)
final sentFriendRequestProvider =
    AutoDisposeFutureProvider<List<SnRelationship>>.internal(
      sentFriendRequest,
      name: r'sentFriendRequestProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$sentFriendRequestHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SentFriendRequestRef =
    AutoDisposeFutureProviderRef<List<SnRelationship>>;
String _$relationshipListNotifierHash() =>
    r'fc46920256f7c48445c00652165e879890f2c9a3';

/// See also [RelationshipListNotifier].
@ProviderFor(RelationshipListNotifier)
final relationshipListNotifierProvider = AutoDisposeAsyncNotifierProvider<
  RelationshipListNotifier,
  CursorPagingData<SnRelationship>
>.internal(
  RelationshipListNotifier.new,
  name: r'relationshipListNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$relationshipListNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RelationshipListNotifier =
    AutoDisposeAsyncNotifier<CursorPagingData<SnRelationship>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
