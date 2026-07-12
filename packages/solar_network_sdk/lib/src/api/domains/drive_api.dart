import 'package:dio/dio.dart';

import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/drive/file.dart';
import 'package:solar_network_sdk/src/models/drive/file_permission.dart';
import 'package:solar_network_sdk/src/models/drive/file_pool.dart';

/// API for cloud drive/storage endpoints (/drive).
///
/// Covers files, folders, upload tasks, bundles, pools, and billing
/// as documented in DRIVE_API.md.
class DriveApi extends BaseApi {
  DriveApi(super.dio);

  static const String _basePath = '/drive';

  // ===========================================================================
  // Files — open / info / metadata
  // ===========================================================================

  /// Opens (serves) a file. May redirect for remote files.
  ///
  /// [fileId] — file ID, optionally with extension.
  /// [download] — set `Content-Disposition: attachment`.
  /// [original] — skip compression, serve original.
  /// [thumbnail] — serve thumbnail variant.
  /// [overrideMimeType] — override Content-Type.
  /// [passcode] — bundle passcode for protected files.
  Future<Response> openFile(
    String fileId, {
    bool download = false,
    bool original = false,
    bool thumbnail = false,
    String? overrideMimeType,
    String? passcode,
  }) {
    return get(
      '$_basePath/files/$fileId',
      queryParameters: {
        if (download) 'download': true,
        if (original) 'original': true,
        if (thumbnail) 'thumbnail': true,
        'overrideMimeType': ?overrideMimeType,
        'passcode': ?passcode,
      },
    );
  }

  /// Downloads a file to [savePath].
  Future<Response> downloadFile({
    required String fileId,
    required String savePath,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.download(
      '$_basePath/files/$fileId',
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Returns end-to-end encryption metadata for a file.
  Future<Map<String, dynamic>?> getE2eeMeta(
    String fileId, {
    String? passcode,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/files/$fileId/e2ee',
      queryParameters: {'passcode': ?passcode},
    );
    return response.data;
  }

  /// Returns the full [SnCloudFile] object.
  Future<SnCloudFile> getFileInfo(String fileId) {
    return get(
      '$_basePath/files/$fileId/info',
    ).then((r) => SnCloudFile.fromJson(r.data));
  }

  /// Returns readable cloud files for [fileIds], preserving the requested order.
  Future<List<SnCloudFile>> getFiles(List<String> fileIds) async {
    if (fileIds.isEmpty) return [];

    final response = await get<List<dynamic>>(
      '$_basePath/files/meta',
      queryParameters: {'ids': fileIds.join(',')},
    );
    return parseList(response, SnCloudFile.fromJson);
  }

  /// Returns all cloud files sharing the same underlying storage object.
  Future<List<SnCloudFile>> getFileReferences(String fileId) async {
    final response = await get<List<dynamic>>(
      '$_basePath/files/$fileId/references',
    );
    return parseList(response, SnCloudFile.fromJson);
  }

  /// Returns the direct permission rows for a file.
  Future<List<SnFilePermission>> getFilePermissions(String fileId) async {
    final response = await get<List<dynamic>>(
      '$_basePath/files/$fileId/permissions',
    );
    return parseList(response, SnFilePermission.fromJson);
  }

  // ===========================================================================
  // Files — update / delete
  // ===========================================================================

  /// Updates the file's display name. Owner only.
  Future<SnCloudFile> updateFileName(String fileId, String newName) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/files/$fileId',
      data: {'name': newName},
    );
    return SnCloudFile.fromJson(response.data!);
  }

  /// Sets content sensitivity labels. Owner only.
  Future<SnCloudFile> updateSensitiveMarks(
    String fileId,
    List<String> marks,
  ) async {
    final response = await put<Map<String, dynamic>>(
      '$_basePath/files/$fileId/marks',
      data: {'sensitive_marks': marks},
    );
    return SnCloudFile.fromJson(response.data!);
  }

  /// Sets arbitrary user-defined metadata. Owner only.
  Future<SnCloudFile> updateUserMeta(
    String fileId,
    Map<String, dynamic> meta,
  ) async {
    final response = await put<Map<String, dynamic>>(
      '$_basePath/files/$fileId/meta',
      data: meta,
    );
    return SnCloudFile.fromJson(response.data!);
  }

  /// Replaces the full direct permission set for a file.
  Future<void> updateFilePermissions(
    String fileId,
    List<SnFilePermission> items,
  ) async {
    await put(
      '$_basePath/files/$fileId/permissions',
      data: {'items': items.map((item) => item.toJson()).toList()},
    );
  }

  /// Permanently deletes a file. Owner only.
  Future<void> deleteFile(String fileId) async {
    await delete<Map<String, dynamic>>('$_basePath/files/$fileId');
  }

  /// Deletes multiple files at once. Owner only.
  Future<int> batchDeleteFiles(List<String> fileIds) async {
    final response = await delete<Map<String, dynamic>>(
      '$_basePath/files/batches/delete',
      data: {'file_ids': fileIds},
    );
    return (response.data!['count'] as num).toInt();
  }

  // ===========================================================================
  // Folders & hierarchy
  // ===========================================================================

  /// Lists indexed files at the root level (no parent).
  Future<PaginatedResult<SnCloudFile>> listRootChildren({
    int offset = 0,
    int take = 50,
    String? query,
    String? name,
    String? extension,
    String? order,
    bool orderDesc = true,
    String? poolId,
    String? usage,
    String? applicationType,
    String? contentType,
    String? mimeType,
    String? parentId,
    bool? indexed,
    bool? isFolder,
    bool? hasThumbnail,
    bool? hasCompression,
    int? minSize,
    int? maxSize,
    String? createdAfter,
    String? createdBefore,
    String? updatedAfter,
    String? updatedBefore,
  }) async {
    final resolvedContentType = contentType ?? mimeType;
    final response = await get<List<dynamic>>(
      '$_basePath/files/root/children',
      queryParameters: {
        'offset': offset,
        'take': take,
        'query': ?query,
        'name': ?name,
        'extension': ?extension,
        'order': ?order,
        'orderDesc': orderDesc,
        'pool': ?poolId,
        'usage': ?usage,
        'application_type': ?applicationType,
        'content_type': ?resolvedContentType,
        'parent_id': ?parentId,
        'indexed': ?indexed,
        'is_folder': ?isFolder,
        'has_thumbnail': ?hasThumbnail,
        'has_compression': ?hasCompression,
        'min_size': ?minSize,
        'max_size': ?maxSize,
        'created_after': ?createdAfter,
        'created_before': ?createdBefore,
        'updated_after': ?updatedAfter,
        'updated_before': ?updatedBefore,
      },
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnCloudFile.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Lists files inside a folder.
  Future<PaginatedResult<SnCloudFile>> listFolderChildren(
    String parentId, {
    int offset = 0,
    int take = 50,
    String? query,
    String? name,
    String? extension,
    String? order,
    bool orderDesc = true,
    String? poolId,
    String? usage,
    String? applicationType,
    String? contentType,
    String? mimeType,
    bool? indexed,
    bool? isFolder,
    bool? hasThumbnail,
    bool? hasCompression,
    int? minSize,
    int? maxSize,
    String? createdAfter,
    String? createdBefore,
    String? updatedAfter,
    String? updatedBefore,
  }) async {
    final resolvedContentType = contentType ?? mimeType;
    final response = await get<List<dynamic>>(
      '$_basePath/files/$parentId/children',
      queryParameters: {
        'offset': offset,
        'take': take,
        'query': ?query,
        'name': ?name,
        'extension': ?extension,
        'order': ?order,
        'orderDesc': orderDesc,
        'pool': ?poolId,
        'usage': ?usage,
        'application_type': ?applicationType,
        'content_type': ?resolvedContentType,
        'indexed': ?indexed,
        'is_folder': ?isFolder,
        'has_thumbnail': ?hasThumbnail,
        'has_compression': ?hasCompression,
        'min_size': ?minSize,
        'max_size': ?maxSize,
        'created_after': ?createdAfter,
        'created_before': ?createdBefore,
        'updated_after': ?updatedAfter,
        'updated_before': ?updatedBefore,
      },
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnCloudFile.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Creates a new virtual folder.
  Future<SnCloudFile> createFolder({
    required String name,
    String? parentId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/files/folders',
      data: {'name': name, 'parent_id': ?parentId},
    );
    return SnCloudFile.fromJson(response.data!);
  }

  /// Moves a file to a different folder or to root. Owner only.
  ///
  /// [parentId] — target folder ID, `null` for root.
  /// [indexed] — whether file appears in hierarchy.
  Future<SnCloudFile> moveFile(
    String fileId, {
    String? parentId,
    bool? indexed,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/files/$fileId/hierarchy',
      data: {'parent_id': ?parentId, 'indexed': ?indexed},
    );
    return SnCloudFile.fromJson(response.data!);
  }

  // ===========================================================================
  // Unindexed / my files / recycle
  // ===========================================================================

  /// Lists files not part of the folder hierarchy.
  Future<PaginatedResult<SnCloudFile>> listUnindexedFiles({
    String? poolId,
    bool recycled = false,
    int offset = 0,
    int take = 20,
    String? query,
    String? name,
    String? extension,
    String? order,
    bool orderDesc = true,
    String? usage,
    String? applicationType,
    String? contentType,
    String? mimeType,
    bool? isFolder,
    bool? hasThumbnail,
    bool? hasCompression,
    int? minSize,
    int? maxSize,
    String? createdAfter,
    String? createdBefore,
    String? updatedAfter,
    String? updatedBefore,
  }) async {
    final resolvedContentType = contentType ?? mimeType;
    final response = await get<List<dynamic>>(
      '$_basePath/files/unindexed',
      queryParameters: {
        'pool': ?poolId,
        'recycled': recycled,
        'offset': offset,
        'take': take,
        'query': ?query,
        'name': ?name,
        'extension': ?extension,
        'order': ?order,
        'orderDesc': orderDesc,
        'usage': ?usage,
        'application_type': ?applicationType,
        'content_type': ?resolvedContentType,
        'is_folder': ?isFolder,
        'has_thumbnail': ?hasThumbnail,
        'has_compression': ?hasCompression,
        'min_size': ?minSize,
        'max_size': ?maxSize,
        'created_after': ?createdAfter,
        'created_before': ?createdBefore,
        'updated_after': ?updatedAfter,
        'updated_before': ?updatedBefore,
      },
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnCloudFile.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Lists all files owned by the user, regardless of hierarchy.
  Future<PaginatedResult<SnCloudFile>> listMyFiles({
    String? poolId,
    bool recycled = false,
    int offset = 0,
    int take = 20,
    String? query,
    String? name,
    String? extension,
    String? order,
    bool orderDesc = true,
    String? usage,
    String? applicationType,
    String? contentType,
    String? mimeType,
    bool? isFolder,
    bool? hasThumbnail,
    bool? hasCompression,
    int? minSize,
    int? maxSize,
    String? createdAfter,
    String? createdBefore,
    String? updatedAfter,
    String? updatedBefore,
  }) async {
    final resolvedContentType = contentType ?? mimeType;
    final response = await get<List<dynamic>>(
      '$_basePath/files/me',
      queryParameters: {
        'pool': ?poolId,
        'recycled': recycled,
        'offset': offset,
        'take': take,
        'query': ?query,
        'name': ?name,
        'extension': ?extension,
        'order': ?order,
        'orderDesc': orderDesc,
        'usage': ?usage,
        'application_type': ?applicationType,
        'content_type': ?resolvedContentType,
        'is_folder': ?isFolder,
        'has_thumbnail': ?hasThumbnail,
        'has_compression': ?hasCompression,
        'min_size': ?minSize,
        'max_size': ?maxSize,
        'created_after': ?createdAfter,
        'created_before': ?createdBefore,
        'updated_after': ?updatedAfter,
        'updated_before': ?updatedBefore,
      },
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnCloudFile.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Permanently deletes all recycled files for the current user.
  Future<int> deleteRecycledFiles() async {
    final response = await delete<Map<String, dynamic>>(
      '$_basePath/files/me/recycle',
    );
    return (response.data!['count'] as num).toInt();
  }

  /// Permanently deletes all recycled files across all users. Admin only.
  Future<int> deleteAllRecycledFiles() async {
    final response = await delete<Map<String, dynamic>>(
      '$_basePath/files/recycle',
    );
    return (response.data!['count'] as num).toInt();
  }

  // ===========================================================================
  // Upload — chunked
  // ===========================================================================

  /// Initiates a chunked upload. Supports deduplication by hash.
  ///
  /// Returns a map with `task_id`, `chunk_size`, `chunks_count`, or
  /// `file_exists: true` with `file` if deduplicated.
  Future<Map<String, dynamic>> createUploadTask({
    required String hash,
    required String fileName,
    required int fileSize,
    required String contentType,
    String? poolId,
    String? bundleId,
    String? encryptionScheme,
    String? encryptionHeader,
    String? encryptionSignature,
    String? expiredAt,
    int? chunkSize,
    String? parentId,
    String? usage,
    String? applicationType,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/files/upload/create',
      data: {
        'hash': hash,
        'file_name': fileName,
        'file_size': fileSize,
        'content_type': contentType,
        'pool_id': ?poolId,
        'bundle_id': ?bundleId,
        'encryption_scheme': ?encryptionScheme,
        'encryption_header': ?encryptionHeader,
        'encryption_signature': ?encryptionSignature,
        'expired_at': ?expiredAt,
        'chunk_size': ?chunkSize,
        'parent_id': ?parentId,
        'usage': ?usage,
        'application_type': ?applicationType,
      },
    );
    return response.data!;
  }

  /// Uploads a single chunk of the file.
  Future<void> uploadChunk({
    required String taskId,
    required int chunkIndex,
    required List<int> chunkData,
    String? fileName,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'chunk': MultipartFile.fromBytes(
        chunkData,
        filename: fileName ?? 'chunk_$chunkIndex',
      ),
    });
    await post(
      '$_basePath/files/upload/chunk/$taskId/$chunkIndex',
      data: formData,
      onSendProgress: onSendProgress,
    );
  }

  /// Completes a chunked upload. Returns 200 with SnCloudFile or 202 if still processing.
  Future<Response> completeUpload(String taskId) async {
    return post('$_basePath/files/upload/complete/$taskId');
  }

  // ===========================================================================
  // Upload — direct
  // ===========================================================================

  /// Single-request upload for files ≤ 20MB.
  Future<SnCloudFile> directUpload({
    required List<int> fileBytes,
    required String fileName,
    String? contentType,
    String? poolId,
    String? bundleId,
    String? encryptionScheme,
    String? encryptionHeader,
    String? encryptionSignature,
    String? expiredAt,
    String? parentId,
    String? usage,
    String? applicationType,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      'content_type': ?contentType,
      'pool_id': ?poolId,
      'bundle_id': ?bundleId,
      'encryption_scheme': ?encryptionScheme,
      'encryption_header': ?encryptionHeader,
      'encryption_signature': ?encryptionSignature,
      'expired_at': ?expiredAt,
      'parent_id': ?parentId,
      'usage': ?usage,
      'application_type': ?applicationType,
    });
    final response = await post<Map<String, dynamic>>(
      '$_basePath/files/upload/direct',
      data: formData,
      onSendProgress: onSendProgress,
    );
    return SnCloudFile.fromJson(response.data!);
  }

  // ===========================================================================
  // Upload — task management
  // ===========================================================================

  /// Lists the authenticated user's upload tasks.
  Future<List<Map<String, dynamic>>> listUploadTasks({
    String? status,
    String sortBy = 'lastActivity',
    bool sortDescending = true,
    int offset = 0,
    int limit = 50,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/files/upload/tasks',
      queryParameters: {
        'status': ?status,
        'sortBy': sortBy,
        'sortDescending': sortDescending,
        'offset': offset,
        'limit': limit,
      },
    );
    return (response.data as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Returns real-time progress for an upload task.
  Future<Map<String, dynamic>> getUploadProgress(String taskId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/files/upload/progress/$taskId',
    );
    return response.data!;
  }

  /// Returns information needed to resume an interrupted upload.
  Future<Map<String, dynamic>> resumeUpload(String taskId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/files/upload/resume/$taskId',
    );
    return response.data!;
  }

  /// Cancels an in-progress upload and cleans up temp files.
  Future<void> cancelUpload(String taskId) async {
    await delete('$_basePath/files/upload/task/$taskId');
  }

  /// Returns upload statistics for the authenticated user.
  Future<Map<String, dynamic>> getUploadStats() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/files/upload/stats',
    );
    return response.data!;
  }

  /// Returns the user's most recent upload tasks.
  Future<List<Map<String, dynamic>>> getRecentTasks({int limit = 10}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/files/upload/tasks/recent',
      queryParameters: {'limit': limit},
    );
    return (response.data as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Returns detailed task info including pool/bundle metadata.
  Future<Map<String, dynamic>> getTaskDetails(String taskId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/files/upload/tasks/$taskId/details',
    );
    return response.data!;
  }

  /// Cleans up all failed upload tasks for the authenticated user.
  Future<String> cleanupFailedTasks() async {
    final response = await delete<Map<String, dynamic>>(
      '$_basePath/files/upload/tasks/cleanup',
    );
    return response.data!['message'] as String;
  }

  // ===========================================================================
  // Bundles
  // ===========================================================================

  /// Gets a bundle by ID.
  Future<Map<String, dynamic>> getBundle(
    String bundleId, {
    String? passcode,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/bundles/$bundleId',
      queryParameters: {'passcode': ?passcode},
    );
    return response.data!;
  }

  /// Lists bundles owned by the authenticated user.
  Future<PaginatedResult<Map<String, dynamic>>> listMyBundles({
    String? term,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/bundles/me',
      queryParameters: {'term': ?term, 'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = (response.data as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Creates a new file bundle.
  Future<Map<String, dynamic>> createBundle({
    String? slug,
    String? name,
    String? description,
    String? passcode,
    String? expiredAt,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/bundles',
      data: {
        'slug': ?slug,
        'name': ?name,
        'description': ?description,
        'passcode': ?passcode,
        'expired_at': ?expiredAt,
      },
    );
    return response.data!;
  }

  /// Updates a bundle. Owner only.
  Future<Map<String, dynamic>> updateBundle(
    String bundleId, {
    String? slug,
    String? name,
    String? description,
    String? passcode,
    String? expiredAt,
  }) async {
    final response = await put<Map<String, dynamic>>(
      '$_basePath/bundles/$bundleId',
      data: {
        'slug': ?slug,
        'name': ?name,
        'description': ?description,
        'passcode': ?passcode,
        'expired_at': ?expiredAt,
      },
    );
    return response.data!;
  }

  /// Deletes a bundle. Files are marked for recycle. Owner only.
  Future<void> deleteBundle(String bundleId) async {
    await delete('$_basePath/bundles/$bundleId');
  }

  // ===========================================================================
  // Pools
  // ===========================================================================

  /// Lists storage pools available to the authenticated user.
  Future<List<SnFilePool>> listPools() async {
    final response = await get<List<dynamic>>('$_basePath/pools');
    return parseList(response, SnFilePool.fromJson);
  }

  /// Permanently deletes all recycled files in a pool.
  Future<int> deletePoolRecycledFiles(String poolId) async {
    final response = await delete<Map<String, dynamic>>(
      '$_basePath/pools/$poolId/recycle',
    );
    return (response.data!['count'] as num).toInt();
  }

  // ===========================================================================
  // Billing
  // ===========================================================================

  /// Returns total storage usage across all pools.
  Future<Map<String, dynamic>> getTotalUsage() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/billing/usage',
    );
    return response.data!;
  }

  /// Returns usage details for a specific pool.
  Future<Map<String, dynamic>> getPoolUsage(String poolId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/billing/usage/$poolId',
    );
    return response.data!;
  }

  /// Returns the user's storage quota breakdown.
  Future<Map<String, dynamic>> getQuota() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/billing/quota',
    );
    return response.data!;
  }

  /// Returns the user's quota purchase/addition records.
  Future<PaginatedResult<Map<String, dynamic>>> getQuotaRecords({
    bool expired = false,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/billing/quota/records',
      queryParameters: {'expired': expired, 'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = (response.data as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    return PaginatedResult(items: items, totalCount: totalCount);
  }
}
