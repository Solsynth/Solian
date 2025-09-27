import 'dart:async';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/network.dart';

class FileUploader {
  final Dio _dio;

  FileUploader(this._dio);

  /// Calculates the MD5 hash of a file.
  Future<String> _calculateFileHash(XFile file) async {
    final bytes = await file.readAsBytes();
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Creates an upload task for the given file.
  Future<Map<String, dynamic>> createUploadTask({
    required XFile file,
    required String fileName,
    required String contentType,
    String? poolId,
    String? bundleId,
    String? encryptPassword,
    String? expiredAt,
    int? chunkSize,
  }) async {
    final hash = await _calculateFileHash(file);
    final fileSize = await file.length();

    final response = await _dio.post(
      '/drive/files/upload/create',
      data: {
        'hash': hash,
        'file_name': fileName,
        'file_size': fileSize,
        'content_type': contentType,
        'pool_id': poolId,
        'bundle_id': bundleId,
        'encrypt_password': encryptPassword,
        'expired_at': expiredAt,
        'chunk_size': chunkSize,
      },
    );

    return response.data;
  }

  /// Uploads a single chunk of the file.
  Future<void> uploadChunk({
    required String taskId,
    required int chunkIndex,
    required Uint8List chunkData,
  }) async {
    final formData = FormData.fromMap({
      'chunk': MultipartFile.fromBytes(
        chunkData,
        filename: 'chunk_$chunkIndex',
      ),
    });

    await _dio.post(
      '/drive/files/upload/chunk/$taskId/$chunkIndex',
      data: formData,
    );
  }

  /// Completes the upload and returns the CloudFile object.
  Future<SnCloudFile> completeUpload(String taskId) async {
    final response = await _dio.post('/drive/files/upload/complete/$taskId');

    return SnCloudFile.fromJson(response.data);
  }

  /// Uploads a file in chunks using the multi-part API.
  Future<SnCloudFile> uploadFile({
    required XFile file,
    required String fileName,
    required String contentType,
    String? poolId,
    String? bundleId,
    String? encryptPassword,
    String? expiredAt,
    int? customChunkSize,
  }) async {
    // Step 1: Create upload task
    final createResponse = await createUploadTask(
      file: file,
      fileName: fileName,
      contentType: contentType,
      poolId: poolId,
      bundleId: bundleId,
      encryptPassword: encryptPassword,
      expiredAt: expiredAt,
      chunkSize: customChunkSize,
    );

    if (createResponse['file_exists'] == true) {
      // File already exists, return the existing file
      return SnCloudFile.fromJson(createResponse['file']);
    }

    final taskId = createResponse['task_id'] as String;
    final chunkSize = createResponse['chunk_size'] as int;
    final chunksCount = createResponse['chunks_count'] as int;

    // Step 2: Upload chunks
    final stream = file.openRead();
    final chunks = <Uint8List>[];
    int bytesRead = 0;
    final buffer = BytesBuilder();

    await for (final chunk in stream) {
      buffer.add(chunk);
      bytesRead += chunk.length;

      if (bytesRead >= chunkSize) {
        chunks.add(buffer.takeBytes());
        bytesRead = 0;
      }
    }

    // Add remaining bytes as last chunk
    if (buffer.length > 0) {
      chunks.add(buffer.takeBytes());
    }

    // Ensure we have the correct number of chunks
    if (chunks.length != chunksCount) {
      throw Exception(
        'Chunk count mismatch: expected $chunksCount, got ${chunks.length}',
      );
    }

    // Upload each chunk
    for (int i = 0; i < chunks.length; i++) {
      await uploadChunk(taskId: taskId, chunkIndex: i, chunkData: chunks[i]);
    }

    // Step 3: Complete upload
    return await completeUpload(taskId);
  }
}

// Riverpod provider for the FileUploader service
final fileUploaderProvider = Provider<FileUploader>((ref) {
  final dio = ref.watch(apiClientProvider);
  return FileUploader(dio);
});
