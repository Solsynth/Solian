import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';

final subscriptionsProvider = FutureProvider<List<SnPublisherSubscription>>((
  ref,
) async {
  final client = ref.read(apiClientProvider);

  final response = await client.get('/sphere/subscriptions');

  return response.data
      .map((json) => SnPublisherSubscription.fromJson(json))
      .cast<SnPublisherSubscription>()
      .toList();
});
