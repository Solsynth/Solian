import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/discovery/models/site_file.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'site_files.g.dart';

@riverpod
Future<List<SnSiteFileEntry>> siteFiles(
  Ref ref, {
  required String siteId,
  String? path,
}) async {
  final client = ref.watch(solarNetworkClientProvider);
  final queryParams = path != null ? {'path': path} : null;
  final resp = await client.dio.get(
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
  final client = ref.watch(solarNetworkClientProvider);
  final resp = await client.dio.get(
    '/zone/sites/$siteId/files/content/$relativePath',
  );
  final content = resp.data is String
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
  final client = ref.watch(solarNetworkClientProvider);
  final resp = await client.dio.get(
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
      final client = ref.read(solarNetworkClientProvider);
      final queryParams = arg.path != null ? {'path': arg.path} : null;
      final resp = await client.dio.get(
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
      debugPrint('[SiteFiles] Uploading file: $filePath from: ${file.path}');
      debugPrint('[SiteFiles] Site ID: ${arg.siteId}');

      final client = ref.read(solarNetworkClientProvider);

      // Create multipart form data
      final formData = FormData.fromMap({
        'filePath': filePath,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType('application', 'octet-stream'),
        ),
      });

      debugPrint(
        '[SiteFiles] Sending upload request to: /zone/sites/${arg.siteId}/files/upload',
      );
      debugPrint(
        '[SiteFiles] FormData: filePath=$filePath, filename=${file.path.split('/').last}',
      );

      final response = await client.dio.post(
        '/zone/sites/${arg.siteId}/files/upload',
        data: formData,
      );

      debugPrint('[SiteFiles] Upload response status: ${response.statusCode}');
      debugPrint('[SiteFiles] Upload response data: ${response.data}');

      // Refresh the files list - check if ref is still mounted
      if (ref.mounted) {
        ref.invalidate(siteFilesProvider(siteId: arg.siteId, path: arg.path));
      }
    } catch (error, stackTrace) {
      debugPrint('[SiteFiles] Upload error: $error');
      debugPrint('[SiteFiles] Upload error stack: $stackTrace');
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateFileContent(String relativePath, String newContent) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.put(
        '/zone/sites/${arg.siteId}/files/edit/$relativePath',
        data: {'new_content': newContent},
      );

      // Refresh the files list - check if ref is still mounted
      if (ref.mounted) {
        ref.invalidate(siteFilesProvider(siteId: arg.siteId, path: arg.path));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteFile(String relativePath) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.delete(
        '/zone/sites/${arg.siteId}/files/delete/$relativePath',
      );

      // Refresh the files list - check if ref is still mounted
      if (ref.mounted) {
        ref.invalidate(siteFilesProvider(siteId: arg.siteId, path: arg.path));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> createDirectory(String directoryPath) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.post(
        '/zone/sites/${arg.siteId}/files/folder',
        data: {'path': directoryPath},
      );

      // Refresh the files list - check if ref is still mounted
      if (ref.mounted) {
        ref.invalidate(siteFilesProvider(siteId: arg.siteId, path: arg.path));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final siteFilesNotifierProvider = AsyncNotifierProvider.autoDispose.family(
  SiteFilesNotifier.new,
);
