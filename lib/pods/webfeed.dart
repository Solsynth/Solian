import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/models/webfeed.dart';
import 'package:island/pods/network.dart';

final webFeedListProvider = FutureProvider.family<List<SnWebFeed>, String>((
  ref,
  pubName,
) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/sphere/publishers/$pubName/feeds');
  return (response.data as List)
      .map((json) => SnWebFeed.fromJson(json))
      .toList();
});

class WebFeedNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<
          SnWebFeed,
          ({String pubName, String? feedId})
        > {
  @override
  FutureOr<SnWebFeed> build(({String pubName, String? feedId}) arg) async {
    if (arg.feedId == null || arg.feedId!.isEmpty) {
      return SnWebFeed(
        id: '',
        url: '',
        title: '',
        publisherId: arg.pubName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: null,
      );
    }

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get(
        '/sphere/publishers/${arg.pubName}/feeds/${arg.feedId}',
      );
      return SnWebFeed.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveFeed(SnWebFeed feed) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      final url = '/sphere/publishers/${feed.publisherId}/feeds';

      final response =
          feed.id.isEmpty
              ? await client.post(url, data: feed.toJson())
              : await client.patch('$url/${feed.id}', data: feed.toJson());

      state = AsyncValue.data(SnWebFeed.fromJson(response.data));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteFeed() async {
    final feedId = arg.feedId;
    if (feedId == null || feedId.isEmpty) return;

    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      await client.delete('/sphere/publishers/${arg.pubName}/feeds/$feedId');
      state = AsyncValue.data(
        SnWebFeed(
          id: '',
          url: '',
          title: '',
          publisherId: arg.pubName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          deletedAt: null,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> scrapFeed() async {
    final feedId = arg.feedId;
    if (feedId == null || feedId.isEmpty) return;

    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      await client.post(
        '/sphere/publishers/${arg.pubName}/feeds/$feedId/scrap',
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 180),
        ),
      );

      // Reload the feed
      final response = await client.get(
        '/sphere/publishers/${arg.pubName}/feeds/$feedId',
      );
      state = AsyncValue.data(SnWebFeed.fromJson(response.data));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final webFeedNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<WebFeedNotifier, SnWebFeed, ({String pubName, String? feedId})>(
      WebFeedNotifier.new,
    );
