import 'dart:async';
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/network.dart';
import 'package:mime/mime.dart';
import 'package:native_exif/native_exif.dart';

class FileUploader {
  final Dio _client;

  FileUploader(this._client);

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

    final response = await _client.post(
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

    await _client.post(
      '/drive/files/upload/chunk/$taskId/$chunkIndex',
      data: formData,
    );
  }

  /// Completes the upload and returns the CloudFile object.
  Future<SnCloudFile> completeUpload(String taskId) async {
    final response = await _client.post('/drive/files/upload/complete/$taskId');

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

  static Completer<SnCloudFile?> createCloudFile({
    required UniversalFile fileData,
    required Dio client,
    String? poolId,
    FileUploadMode? mode,
    Function(double progress, Duration estimate)? onProgress,
  }) {
    final completer = Completer<SnCloudFile?>();

    final effectiveMode =
        mode ??
        (fileData.type == UniversalFileType.file
            ? FileUploadMode.generic
            : FileUploadMode.mediaSafe);

    if (effectiveMode == FileUploadMode.mediaSafe &&
        fileData.isOnDevice &&
        fileData.type == UniversalFileType.image) {
      final data = fileData.data;
      if (data is XFile &&
          !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android)) {
        Exif.fromPath(data.path)
            .then((exif) async {
              final gpsAttributes = {
                'GPSLatitude': '',
                'GPSLatitudeRef': '',
                'GPSLongitude': '',
                'GPSLongitudeRef': '',
                'GPSAltitude': '',
                'GPSAltitudeRef': '',
                'GPSTimeStamp': '',
                'GPSProcessingMethod': '',
                'GPSDateStamp': '',
              };
              await exif.writeAttributes(gpsAttributes);
            })
            .then(
              (_) => _processUpload(
                fileData,
                client,
                poolId,
                onProgress,
                completer,
              ),
            )
            .catchError((e) {
              debugPrint('Error removing GPS EXIF data: $e');
              return _processUpload(
                fileData,
                client,
                poolId,
                onProgress,
                completer,
              );
            });

        return completer;
      }
    }

    _processUpload(fileData, client, poolId, onProgress, completer);
    return completer;
  }

  // Helper method to process the upload
  static Completer<SnCloudFile?> _processUpload(
    UniversalFile fileData,
    Dio client,
    String? poolId,
    Function(double progress, Duration estimate)? onProgress,
    Completer<SnCloudFile?> completer,
  ) {
    String actualMimetype = getMimeType(fileData);
    late XFile file;
    String actualFilename = fileData.displayName ?? 'randomly_file';
    Uint8List? byteData;

    // Handle the data based on what's in the UniversalFile
    final data = fileData.data;

    if (data is XFile) {
      file = data;
      actualFilename = fileData.displayName ?? data.name;
    } else if (data is List<int> || data is Uint8List) {
      byteData = data is List<int> ? Uint8List.fromList(data) : data;
      actualFilename = fileData.displayName ?? 'uploaded_file';
      file = XFile.fromData(byteData!, mimeType: actualMimetype);
    } else if (data is SnCloudFile) {
      // If the file is already on the cloud, just return it
      completer.complete(data);
      return completer;
    } else {
      completer.completeError(
        ArgumentError(
          'Invalid fileData type. Expected data to be XFile, List<int>, Uint8List, or SnCloudFile.',
        ),
      );
      return completer;
    }

    final uploader = FileUploader(client);

    // Call progress start
    onProgress?.call(0.0, Duration.zero);
    uploader
        .uploadFile(
          file: file,
          fileName: actualFilename,
          contentType: actualMimetype,
          poolId: poolId,
        )
        .then((result) {
          // Call progress end
          onProgress?.call(1.0, Duration.zero);
          completer.complete(result);
        })
        .catchError((e) {
          completer.completeError(e);
          throw e;
        });

    return completer;
  }

  /// Gets the MIME type of a UniversalFile.
  static String getMimeType(UniversalFile file) {
    final data = file.data;
    if (data is XFile) {
      final mime = data.mimeType;
      if (mime != null && mime.isNotEmpty) return mime;
      final filename = file.displayName ?? data.name;
      final detected = lookupMimeType(filename);
      if (detected != null) return detected;
      throw Exception('Cannot detect mime type for file: $filename');
    } else if (data is List<int> || data is Uint8List) {
      return 'application/octet-stream';
    } else if (data is SnCloudFile) {
      return data.mimeType ?? 'application/octet-stream';
    } else {
      throw ArgumentError('Invalid file data type');
    }
  }
}

enum FileUploadMode { generic, mediaSafe }

// Riverpod provider for the FileUploader service
final fileUploaderProvider = Provider<FileUploader>((ref) {
  final dio = ref.watch(apiClientProvider);
  return FileUploader(dio);
});
