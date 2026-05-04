// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_overview.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(friendsOverview)
final friendsOverviewProvider = FriendsOverviewProvider._();

final class FriendsOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnFriendOverviewItem>>,
          List<SnFriendOverviewItem>,
          FutureOr<List<SnFriendOverviewItem>>
        >
    with
        $FutureModifier<List<SnFriendOverviewItem>>,
        $FutureProvider<List<SnFriendOverviewItem>> {
  FriendsOverviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'friendsOverviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendsOverviewHash();

  @$internal
  @override
  $FutureProviderElement<List<SnFriendOverviewItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnFriendOverviewItem>> create(Ref ref) {
    return friendsOverview(ref);
  }
}

String _$friendsOverviewHash() => r'29bf7b3795732de581656d57a900df4ac2a1e22f';
