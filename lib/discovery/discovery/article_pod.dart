import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/discovery/discovery_models/webfeed.dart';

/// Provider that fetches a single article by its ID
final articleDetailProvider = FutureProvider.autoDispose
    .family<SnWebArticle, String>((ref, articleId) async {
      final dio = ref.watch(apiClientProvider);

      try {
        final response = await dio.get<Map<String, dynamic>>(
          '/insight/feeds/articles/$articleId',
        );

        if (response.statusCode == 200 && response.data != null) {
          return SnWebArticle.fromJson(response.data!);
        } else {
          throw Exception('Failed to load article');
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          throw Exception('Article not found');
        } else {
          throw Exception('Failed to load article: ${e.message}');
        }
      } catch (e) {
        throw Exception('Failed to load article: $e');
      }
    });
