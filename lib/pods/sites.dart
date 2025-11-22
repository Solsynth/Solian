import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/network.dart';

class SiteNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<
          SnPublicationSite,
          ({String pubName, String? siteId})
        > {
  @override
  FutureOr<SnPublicationSite> build(
    ({String pubName, String? siteId}) arg,
  ) async {
    if (arg.siteId == null || arg.siteId!.isEmpty) {
      return SnPublicationSite(
        id: '',
        slug: '',
        name: '',
        publisherId: arg.pubName,
        accountId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        pages: [],
      );
    }

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('/sphere/sites/${arg.siteId}');
      return SnPublicationSite.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveSite(SnPublicationSite site) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      final url = '/sphere/sites';

      final response =
          site.id.isEmpty
              ? await client.post(url, data: site.toJson())
              : await client.patch('$url/${site.id}', data: site.toJson());

      state = AsyncValue.data(SnPublicationSite.fromJson(response.data));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteSite() async {
    final siteId = arg.siteId;
    if (siteId == null || siteId.isEmpty) return;

    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      await client.delete('/sphere/sites/$siteId');
      state = AsyncValue.data(
        SnPublicationSite(
          id: '',
          slug: '',
          name: '',
          publisherId: arg.pubName,
          accountId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          pages: [],
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final siteNotifierProvider = AsyncNotifierProvider.autoDispose.family<
  SiteNotifier,
  SnPublicationSite,
  ({String pubName, String? siteId})
>(SiteNotifier.new);
