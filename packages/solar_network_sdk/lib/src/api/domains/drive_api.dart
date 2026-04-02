import 'dart:io';

import 'package:dio/dio.dart';

import '../base_api.dart';
import '../../models/drive/file.dart';
import '../../models/drive/file_pool.dart';
import '../../models/drive/folder.dart';
import '../../models/drive/drive_task.dart';

/// API for cloud drive/storage endpoints (/drive).
///
/// Handles files, folders, file pools, and storage management.
class DriveApi extends BaseApi {
  DriveApi(super.dio);

  /// Base path for all drive endpoints.
  static const String _basePath = '/drive';

  // ==========================================
  // File endpoints
  // ==========================================

  /// Gets all files.
  ///
  /// [folderId] - Optional folder ID to filter by.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnCloudFile>> getFiles({
    String? folderId,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/files',
      queryParameters: {
        if (folderId != null) 'folder_id': folderId,
        'offset': offset,
        'take': take,
      },
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnCloudFile.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets a specific file by ID.
  ///
  /// [fileId] - The file ID.
  Future<SnCloudFile> getFile(String fileId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/files/$fileId',
    );
    return SnCloudFile.fromJson(response.data!);
  }

  /// Uploads a file.
  ///
  /// [file] - The file to upload.
  /// [folderId] - Optional folder ID to upload to.
  /// [onProgress] - Optional progress callback.
  Future<SnCloudFile> uploadFile({
    required File file,
    String? folderId,
    ProgressCallback? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      if (folderId != null) 'folder_id': folderId,
    });
    final response = await post<Map<String, dynamic>>(
      '$_basePath/files',
      data: formData,
      onSendProgress: onProgress,
    );
    return SnCloudFile.fromJson(response.data!);
  }

  /// Updates file metadata.
  ///
  /// [fileId] - The file ID.
  /// [data] - The metadata to update.
  Future<SnCloudFile> updateFile({
    required String fileId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/files/$fileId',
      data: data,
    );
    return SnCloudFile.fromJson(response.data!);
  }

  /// Deletes a file.
  ///
  /// [fileId] - The file ID.
  Future<void> deleteFile(String fileId) async {
    await delete('$_basePath/files/$fileId');
  }

  /// Downloads a file.
  ///
  /// [fileId] - The file ID.
  /// [savePath] - The path to save the file.
  /// [onProgress] - Optional progress callback.
  Future<Response> downloadFile({
    required String fileId,
    required String savePath,
    ProgressCallback? onProgress,
  }) async {
    return await dio.download(
      '$_basePath/files/$fileId/download',
      savePath,
      onReceiveProgress: onProgress,
    );
  }

  /// Gets a temporary download URL for a file.
  ///
  /// [fileId] - The file ID.
  /// [expiresIn] - URL expiration time in seconds.
  Future<String> getDownloadUrl({
    required String fileId,
    int expiresIn = 3600,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/files/$fileId/download-url',
      queryParameters: {'expires_in': expiresIn},
    );
    return response.data!['url'] as String;
  }

  /// Copies a file.
  ///
  /// [fileId] - The file ID to copy.
  /// [destinationFolderId] - The destination folder ID.
  Future<SnCloudFile> copyFile({
    required String fileId,
    required String destinationFolderId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/files/$fileId/copy',
      data: {'destination_folder_id': destinationFolderId},
    );
    return SnCloudFile.fromJson(response.data!);
  }

  /// Moves a file.
  ///
  /// [fileId] - The file ID to move.
  /// [destinationFolderId] - The destination folder ID.
  Future<SnCloudFile> moveFile({
    required String fileId,
    required String destinationFolderId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/files/$fileId/move',
      data: {'destination_folder_id': destinationFolderId},
    );
    return SnCloudFile.fromJson(response.data!);
  }

  /// Renames a file.
  ///
  /// [fileId] - The file ID.
  /// [newName] - The new file name.
  Future<SnCloudFile> renameFile({
    required String fileId,
    required String newName,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/files/$fileId/rename',
      data: {'name': newName},
    );
    return SnCloudFile.fromJson(response.data!);
  }

  // ==========================================
  // Folder endpoints
  // ==========================================

  /// Gets all folders.
  ///
  /// [parentId] - Optional parent folder ID.
  Future<List<SnCloudFolder>> getFolders({String? parentId}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/folders',
      queryParameters: parentId != null ? {'parent_id': parentId} : null,
    );
    return parseList(response, SnCloudFolder.fromJson);
  }

  /// Gets a specific folder by ID.
  ///
  /// [folderId] - The folder ID.
  Future<SnCloudFolder> getFolder(String folderId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/folders/$folderId',
    );
    return SnCloudFolder.fromJson(response.data!);
  }

  /// Creates a new folder.
  ///
  /// [name] - The folder name.
  /// [parentId] - Optional parent folder ID.
  Future<SnCloudFolder> createFolder({
    required String name,
    String? parentId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/folders',
      data: {'name': name, if (parentId != null) 'parent_id': parentId},
    );
    return SnCloudFolder.fromJson(response.data!);
  }

  /// Updates a folder.
  ///
  /// [folderId] - The folder ID.
  /// [data] - The data to update.
  Future<SnCloudFolder> updateFolder({
    required String folderId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/folders/$folderId',
      data: data,
    );
    return SnCloudFolder.fromJson(response.data!);
  }

  /// Deletes a folder.
  ///
  /// [folderId] - The folder ID.
  Future<void> deleteFolder(String folderId) async {
    await delete('$_basePath/folders/$folderId');
  }

  /// Renames a folder.
  ///
  /// [folderId] - The folder ID.
  /// [newName] - The new folder name.
  Future<SnCloudFolder> renameFolder({
    required String folderId,
    required String newName,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/folders/$folderId/rename',
      data: {'name': newName},
    );
    return SnCloudFolder.fromJson(response.data!);
  }

  /// Moves a folder.
  ///
  /// [folderId] - The folder ID to move.
  /// [destinationParentId] - The destination parent folder ID.
  Future<SnCloudFolder> moveFolder({
    required String folderId,
    required String destinationParentId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/folders/$folderId/move',
      data: {'destination_parent_id': destinationParentId},
    );
    return SnCloudFolder.fromJson(response.data!);
  }

  // ==========================================
  // File pool endpoints
  // ==========================================

  /// Gets all file pools.
  Future<List<SnFilePool>> getFilePools() async {
    final response = await get<List<dynamic>>('$_basePath/pools');
    return parseList(response, SnFilePool.fromJson);
  }

  /// Gets a specific file pool by ID.
  ///
  /// [poolId] - The pool ID.
  Future<SnFilePool> getFilePool(String poolId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/pools/$poolId',
    );
    return SnFilePool.fromJson(response.data!);
  }

  /// Creates a new file pool.
  ///
  /// [name] - The pool name.
  /// [description] - Optional description.
  Future<SnFilePool> createFilePool({
    required String name,
    String? description,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/pools',
      data: {'name': name, if (description != null) 'description': description},
    );
    return SnFilePool.fromJson(response.data!);
  }

  /// Updates a file pool.
  ///
  /// [poolId] - The pool ID.
  /// [data] - The data to update.
  Future<SnFilePool> updateFilePool({
    required String poolId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/pools/$poolId',
      data: data,
    );
    return SnFilePool.fromJson(response.data!);
  }

  /// Deletes a file pool.
  ///
  /// [poolId] - The pool ID.
  Future<void> deleteFilePool(String poolId) async {
    await delete('$_basePath/pools/$poolId');
  }

  /// Gets files in a pool.
  ///
  /// [poolId] - The pool ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnCloudFile>> getPoolFiles({
    required String poolId,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/pools/$poolId/files',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnCloudFile.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Adds a file to a pool.
  ///
  /// [poolId] - The pool ID.
  /// [fileId] - The file ID.
  Future<void> addFileToPool({
    required String poolId,
    required String fileId,
  }) async {
    await post('$_basePath/pools/$poolId/files/$fileId');
  }

  /// Removes a file from a pool.
  ///
  /// [poolId] - The pool ID.
  /// [fileId] - The file ID.
  Future<void> removeFileFromPool({
    required String poolId,
    required String fileId,
  }) async {
    await delete('$_basePath/pools/$poolId/files/$fileId');
  }

  // ==========================================
  // Task endpoints
  // ==========================================

  /// Gets all drive tasks.
  ///
  /// [status] - Optional status filter.
  Future<List<DriveTask>> getTasks({String? status}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/tasks',
      queryParameters: status != null ? {'status': status} : null,
    );
    return parseList(response, DriveTask.fromJson);
  }

  /// Gets a specific task by ID.
  ///
  /// [taskId] - The task ID.
  Future<DriveTask> getTask(String taskId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/tasks/$taskId',
    );
    return DriveTask.fromJson(response.data!);
  }

  /// Cancels a task.
  ///
  /// [taskId] - The task ID.
  Future<void> cancelTask(String taskId) async {
    await delete('$_basePath/tasks/$taskId');
  }

  // ==========================================
  // Storage info endpoints
  // ==========================================

  /// Gets storage usage information.
  Future<Map<String, dynamic>> getStorageInfo() async {
    final response = await get<Map<String, dynamic>>('$_basePath/storage');
    return response.data!;
  }

  /// Gets storage quota.
  Future<Map<String, dynamic>> getStorageQuota() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/storage/quota',
    );
    return response.data!;
  }

  // ==========================================
  // Search endpoints
  // ==========================================

  /// Searches files.
  ///
  /// [query] - The search query.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnCloudFile>> searchFiles({
    required String query,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/search',
      queryParameters: {'q': query, 'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnCloudFile.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  // ==========================================
  // Trash endpoints
  // ==========================================

  /// Gets trashed files.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnCloudFile>> getTrashedFiles({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/trash',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnCloudFile.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Restores a file from trash.
  ///
  /// [fileId] - The file ID.
  Future<SnCloudFile> restoreFromTrash(String fileId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/trash/$fileId/restore',
    );
    return SnCloudFile.fromJson(response.data!);
  }

  /// Permanently deletes a file from trash.
  ///
  /// [fileId] - The file ID.
  Future<void> permanentDelete(String fileId) async {
    await delete('$_basePath/trash/$fileId/permanent');
  }

  /// Empties the trash.
  Future<void> emptyTrash() async {
    await delete('$_basePath/trash');
  }
}
