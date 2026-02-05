import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/discovery/discovery_models/webfeed.dart';
import 'package:island/core/network.dart';

final webFeedListProvider = FutureProvider.autoDispose
    .family<List<SnWebFeed>, String>((ref, pubName) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.get('/insight/publishers/$pubName/feeds');
      return (response.data as List)
          .map((json) => SnWebFeed.fromJson(json))
          .toList();
    });

class WebFeedNotifier extends AsyncNotifier<SnWebFeed> {
  final ({String pubName, String? feedId}) arg;
  WebFeedNotifier(this.arg);

  @override
  FutureOr<SnWebFeed> build() async {
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
        '/insight/publishers/${arg.pubName}/feeds/${arg.feedId}',
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
      final url = '/insight/publishers/${feed.publisherId}/feeds';

      final response = feed.id.isEmpty
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
      await client.delete('/insight/publishers/${arg.pubName}/feeds/$feedId');
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
        '/insight/publishers/${arg.pubName}/feeds/$feedId/scrap',
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
