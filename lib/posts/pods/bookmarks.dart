import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final bookmarksProvider = AsyncNotifierProvider.autoDispose(
  BookmarksNotifier.new,
);

class BookmarksNotifier extends AsyncNotifier<PaginationState<SnPost>>
    with AsyncPaginationController<SnPost> {
  static const int pageSize = 20;

  @override
  Future<List<SnPost>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);
    final result = await client.sphere.getBookmarks(
      offset: fetchedCount,
      take: pageSize,
      order: 'created',
    );
    totalCount = result.totalCount;
    return result.items;
  }
}

final bookmarkStatusProvider = FutureProvider.family<SnPostBookmark?, String>(
  (ref, postId) {
    ref.keepAlive();
    final client = ref.read(solarNetworkClientProvider);
    return client.sphere.getPostBookmark(postId);
  },
);

Future<void> toggleBookmark(WidgetRef ref, {required String postId, required bool currentlyBookmarked}) async {
  final client = ref.read(solarNetworkClientProvider);
  if (currentlyBookmarked) {
    await client.sphere.unbookmarkPost(postId);
  } else {
    await client.sphere.bookmarkPost(postId);
  }
  ref.invalidate(bookmarkStatusProvider(postId));
}

final userReactionsProvider = AsyncNotifierProvider.autoDispose
    .family<UserReactionsNotifier, PaginationState<UserReactionListingItem>, String>(
      UserReactionsNotifier.new,
    );

class UserReactionsNotifier
    extends AsyncNotifier<PaginationState<UserReactionListingItem>>
    with AsyncPaginationController<UserReactionListingItem> {
  static const int pageSize = 20;

  final String arg;
  UserReactionsNotifier(this.arg);

  @override
  Future<List<UserReactionListingItem>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);
    final result = await client.sphere.getUserReactions(
      name: arg,
      offset: fetchedCount,
      take: pageSize,
      order: 'created',
    );
    totalCount = result.totalCount;
    return result.items;
  }
}
