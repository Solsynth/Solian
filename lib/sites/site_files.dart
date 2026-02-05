import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/discovery/discovery_models/site_file.dart';
import 'package:island/core/network.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'site_files.g.dart';

@riverpod
Future<List<SnSiteFileEntry>> siteFiles(
  Ref ref, {
  required String siteId,
  String? path,
}) async {
  final apiClient = ref.watch(apiClientProvider);
  final queryParams = path != null ? {'path': path} : null;
  final resp = await apiClient.get(
    '/zone/sites/$siteId/files',
    queryParameters: queryParams,
  );
  final data = resp.data as List<dynamic>;
  return data.map((json) => SnSiteFileEntry.fromJson(json)).toList();
}

@riverpod
Future<SnFileContent> siteFileContent(
  Ref ref, {
  required String siteId,
  required String relativePath,
}) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get(
    '/zone/sites/$siteId/files/content/$relativePath',
  );
  final content =
      resp.data is String
          ? resp.data
          : SnFileContent.fromJson(resp.data).content;
  return SnFileContent(content: content);
}

@riverpod
Future<String> siteFileContentRaw(
  Ref ref, {
  required String siteId,
  required String relativePath,
}) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get(
    '/zone/sites/$siteId/files/content/$relativePath',
  );
  return resp.data is String ? resp.data : resp.data['content'] as String;
}

class SiteFilesNotifier extends AsyncNotifier<List<SnSiteFileEntry>> {
  final ({String siteId, String? path}) arg;
  SiteFilesNotifier(this.arg);

  @override
  Future<List<SnSiteFileEntry>> build() async {
    return fetchFiles();
  }

  Future<List<SnSiteFileEntry>> fetchFiles() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final queryParams = arg.path != null ? {'path': arg.path} : null;
      final resp = await apiClient.get(
        '/zone/sites/${arg.siteId}/files',
        queryParameters: queryParams,
      );
      final data = resp.data as List<dynamic>;
      return data.map((json) => SnSiteFileEntry.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadFile(File file, String filePath) async {
    state = const AsyncValue.loading();
    try {
      final apiClient = ref.read(apiClientProvider);

      // Create multipart form data
      final formData = FormData.fromMap({
        'filePath': filePath,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType('application', 'octet-stream'),
        ),
      });

      await apiClient.post(
        '/zone/sites/${arg.siteId}/files/upload',
        data: formData,
      );

      // Refresh the files list
      ref.invalidate(siteFilesProvider(siteId: arg.siteId, path: arg.path));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateFileContent(String relativePath, String newContent) async {
    state = const AsyncValue.loading();
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.put(
        '/zone/sites/${arg.siteId}/files/edit/$relativePath',
        data: {'new_content': newContent},
      );

      // Refresh the files list
      ref.invalidate(siteFilesProvider(siteId: arg.siteId, path: arg.path));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteFile(String relativePath) async {
    state = const AsyncValue.loading();
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.delete(
        '/zone/sites/${arg.siteId}/files/delete/$relativePath',
      );

      // Refresh the files list
      ref.invalidate(siteFilesProvider(siteId: arg.siteId, path: arg.path));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> createDirectory(String directoryPath) async {
    // For directories, we upload a dummy file first then delete it or create through upload
    // Actually, according to API docs, directories are created when uploading files to them
    // So we'll just invalidate to refresh the list
    ref.invalidate(siteFilesProvider(siteId: arg.siteId, path: arg.path));
  }
}

final siteFilesNotifierProvider = AsyncNotifierProvider.autoDispose.family(
  SiteFilesNotifier.new,
);
