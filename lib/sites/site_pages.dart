import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/creators/publication_site.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'site_pages.g.dart';

@riverpod
Future<List<SnPublicationPage>> sitePages(
  Ref ref,
  String pubName,
  String siteSlug,
) async {
  final client = ref.watch(solarNetworkClientProvider);
  final resp = await client.dio.get('/zone/sites/$pubName/$siteSlug/pages');
  final data = resp.data as List<dynamic>;
  return data.map((json) => SnPublicationPage.fromJson(json)).toList();
}

@riverpod
Future<SnPublicationPage> sitePage(Ref ref, String pageId) async {
  final client = ref.watch(solarNetworkClientProvider);
  final resp = await client.dio.get('/zone/sites/pages/$pageId');
  return SnPublicationPage.fromJson(resp.data);
}

class SitePagesNotifier extends AsyncNotifier<List<SnPublicationPage>> {
  final ({String pubName, String siteSlug}) arg;
  SitePagesNotifier(this.arg);

  @override
  Future<List<SnPublicationPage>> build() async {
    return fetchPages();
  }

  Future<List<SnPublicationPage>> fetchPages() async {
    try {
      final client = ref.read(solarNetworkClientProvider);
      final resp = await client.dio.get(
        '/zone/sites/${arg.pubName}/${arg.siteSlug}/pages',
      );
      final data = resp.data as List<dynamic>;
      return data.map((json) => SnPublicationPage.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<SnPublicationPage?> createPage(Map<String, dynamic> pageData) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(solarNetworkClientProvider);
      final resp = await client.dio.post(
        '/zone/sites/${arg.pubName}/${arg.siteSlug}/pages',
        data: pageData,
      );
      final newPage = SnPublicationPage.fromJson(resp.data);

      return newPage;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<SnPublicationPage?> updatePage(
    String pageId,
    Map<String, dynamic> pageData,
  ) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(solarNetworkClientProvider);
      final resp = await client.dio.patch(
        '/zone/sites/pages/$pageId',
        data: pageData,
      );
      final updatedPage = SnPublicationPage.fromJson(resp.data);

      return updatedPage;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deletePage(String pageId) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.delete('/zone/sites/pages/$pageId');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final sitePagesNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<
      SitePagesNotifier,
      List<SnPublicationPage>,
      ({String pubName, String siteSlug})
    >(SitePagesNotifier.new);
