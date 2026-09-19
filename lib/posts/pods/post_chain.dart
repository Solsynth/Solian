import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Members of the chain a post belongs to, head first, in publication order.
///
/// Chaining is flat: a chained post only stores the chain head id, so the rest
/// of its chain has to be read from the server. A chain head carries its members
/// on the post itself and never needs this.
final postChainProvider = FutureProvider.autoDispose
    .family<List<SnPost>, String>((ref, postId) async {
      final client = ref.watch(solarNetworkClientProvider);
      return await client.sphere.getPostChain(postId);
    });

/// The members of [chain] published before and after [currentId], the current
/// post excluded. [chain] is head first, so the split follows the same order the
/// server publishes the chain in. A chain that does not contain [currentId] — a
/// member the viewer cannot see — counts entirely as context that precedes it.
({List<SnPost> preceding, List<SnPost> following}) splitChainMembers(
  List<SnPost> chain,
  String currentId,
) {
  final index = chain.indexWhere((member) => member.id == currentId);
  if (index < 0) return (preceding: chain, following: const <SnPost>[]);
  return (
    preceding: chain.sublist(0, index),
    following: chain.sublist(index + 1),
  );
}

/// The chain members around [post], or null when it is not part of a chain.
///
/// A chain head already carries its members; a chained post reads the chain it
/// belongs to. Either way the caller gets the same head-first list, so both can
/// be rendered by the same widgets.
({List<SnPost> preceding, List<SnPost> following})? watchChainContext(
  WidgetRef ref,
  SnPost post,
) {
  final members = post.chainedPostId == null
      ? (post.chainedPosts.isEmpty ? null : [post, ...post.chainedPosts])
      : ref.watch(postChainProvider(post.id)).asData?.value;
  if (members == null) return null;
  return splitChainMembers(members, post.id);
}
