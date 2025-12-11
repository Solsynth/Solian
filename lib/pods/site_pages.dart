import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'site_pages.g.dart';

@riverpod
Future<List<SnPublicationPage>> sitePages(
  Ref ref,
  String pubName,
  String siteSlug,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/zone/sites/$pubName/$siteSlug/pages');
  final data = resp.data as List<dynamic>;
  return data.map((json) => SnPublicationPage.fromJson(json)).toList();
}

@riverpod
Future<SnPublicationPage> sitePage(Ref ref, String pageId) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/zone/sites/pages/$pageId');
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
      final apiClient = ref.read(apiClientProvider);
      final resp = await apiClient.get(
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
      final apiClient = ref.read(apiClientProvider);
      final resp = await apiClient.post(
        '/zone/sites/${arg.pubName}/${arg.siteSlug}/pages',
        data: pageData,
      );
      final newPage = SnPublicationPage.fromJson(resp.data);

      // Refresh the pages list
      ref.invalidate(sitePagesProvider(arg.pubName, arg.siteSlug));

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
      final apiClient = ref.read(apiClientProvider);
      final resp = await apiClient.patch(
        '/zone/sites/pages/$pageId',
        data: pageData,
      );
      final updatedPage = SnPublicationPage.fromJson(resp.data);

      // Refresh the pages list
      ref.invalidate(sitePagesProvider(arg.pubName, arg.siteSlug));

      return updatedPage;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deletePage(String pageId) async {
    state = const AsyncValue.loading();
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.delete('/zone/sites/pages/$pageId');
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
