import 'dart:async';
import 'dart:io';
import 'package:convert/convert.dart';
import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/drive/drive_models/drive_task.dart';
import 'package:island/drive/drive_models/file.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/drive/upload_tasks.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:mime/mime.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path/path.dart' show extension;
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class FileUploader {
  final Dio _client;

  FileUploader(this._client);

  /// Calculates the MD5 hash of file bytes.
  String _calculateFileHash(Uint8List bytes) {
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Calculates the MD5 hash from a stream.
  Future<String> _calculateFileHashFromStream(Stream<List<int>> stream) async {
    final accumulator = AccumulatorSink<Digest>();
    final converter = md5.startChunkedConversion(accumulator);
    await for (final chunk in stream) {
      converter.add(chunk);
    }
    converter.close();
    final digest = accumulator.events.single;
    return digest.toString();
  }

  /// Reads the next chunk from a stream subscription.
  Future<Uint8List> _readNextChunk(
    StreamSubscription<List<int>> subscription,
    int size,
  ) async {
    final completer = Completer<Uint8List>();
    final buffer = <int>[];
    int remaining = size;

    void onData(List<int> data) {
      buffer.addAll(data);
      remaining -= data.length;
      if (remaining <= 0) {
        subscription.pause();
        completer.complete(Uint8List.fromList(buffer.sublist(0, size)));
      }
    }

    void onDone() {
      if (!completer.isCompleted) {
        completer.complete(Uint8List.fromList(buffer));
      }
    }

    subscription.onData(onData);
    subscription.onDone(onDone);

    return completer.future;
  }

  /// Creates an upload task for the given file.
  Future<Map<String, dynamic>> createUploadTask({
    required dynamic fileData,
    required String fileName,
    required String contentType,
    String? poolId,
    String? bundleId,
    String? encryptPassword,
    String? expiredAt,
    int? chunkSize,
    String? path,
  }) async {
    String hash;
    int fileSize;
    if (fileData is XFile) {
      fileSize = await fileData.length();
      hash = await _calculateFileHashFromStream(fileData.openRead());
    } else if (fileData is Uint8List) {
      hash = _calculateFileHash(fileData);
      fileSize = fileData.length;
    } else {
      throw ArgumentError('Invalid fileData type');
    }

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
        'path': path,
      },
    );

    return response.data;
  }

  /// Uploads a single chunk of the file.
  Future<void> uploadChunk({
    required String taskId,
    required int chunkIndex,
    required Uint8List chunkData,
    ProgressCallback? onSendProgress,
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
      onSendProgress: onSendProgress,
    );
  }

  /// Completes the upload and returns the CloudFile object.
  Future<SnCloudFile> completeUpload(String taskId) async {
    final response = await _client.post(
      '/drive/files/upload/complete/$taskId',
      options: Options(
        sendTimeout: Duration(minutes: 1),
        receiveTimeout: Duration(minutes: 1),
      ),
    );

    return SnCloudFile.fromJson(response.data);
  }

  /// Uploads a file in chunks using the multi-part API.
  Future<SnCloudFile> uploadFile({
    required dynamic fileData,
    required String fileName,
    required String contentType,
    String? poolId,
    String? bundleId,
    String? encryptPassword,
    String? expiredAt,
    int? customChunkSize,
    String? path,
    Function(double? progress, Duration estimate)? onProgress,
  }) async {
    // Step 1: Create upload task
    onProgress?.call(null, Duration.zero);
    final createResponse = await createUploadTask(
      fileData: fileData,
      fileName: fileName,
      contentType: contentType,
      poolId: poolId,
      bundleId: bundleId,
      encryptPassword: encryptPassword,
      expiredAt: expiredAt,
      chunkSize: customChunkSize,
      path: path,
    );

    if (createResponse['file_exists'] == true) {
      // File already exists, return the existing file
      return SnCloudFile.fromJson(createResponse['file']);
    }

    final taskId = createResponse['task_id'] as String;
    final chunkSize = createResponse['chunk_size'] as int;
    final chunksCount = createResponse['chunks_count'] as int;
    int totalSize;
    if (fileData is XFile) {
      totalSize = await fileData.length();
    } else if (fileData is Uint8List) {
      totalSize = fileData.length;
    } else {
      throw ArgumentError('Invalid fileData type');
    }

    // Step 2: Upload chunks
    int bytesUploaded = 0;
    if (fileData is XFile) {
      // Use stream for XFile
      final subscription = fileData.openRead().listen(null);
      subscription.pause();
      for (int i = 0; i < chunksCount; i++) {
        subscription.resume();
        final chunkData = await _readNextChunk(subscription, chunkSize);
        await uploadChunk(
          taskId: taskId,
          chunkIndex: i,
          chunkData: chunkData,
          onSendProgress: (sent, total) {
            final overallProgress = (bytesUploaded + sent) / totalSize;
            onProgress?.call(overallProgress, Duration.zero);
          },
        );
        bytesUploaded += chunkData.length;
      }
      subscription.cancel();
    } else if (fileData is Uint8List) {
      // Use old way for Uint8List
      final chunks = <Uint8List>[];
      for (int i = 0; i < fileData.length; i += chunkSize) {
        final end = i + chunkSize > fileData.length
            ? fileData.length
            : i + chunkSize;
        chunks.add(Uint8List.fromList(fileData.sublist(i, end)));
      }

      // Upload each chunk
      for (int i = 0; i < chunks.length; i++) {
        await uploadChunk(
          taskId: taskId,
          chunkIndex: i,
          chunkData: chunks[i],
          onSendProgress: (sent, total) {
            final overallProgress = (bytesUploaded + sent) / totalSize;
            onProgress?.call(overallProgress, Duration.zero);
          },
        );
        bytesUploaded += chunks[i].length;
      }
    } else {
      throw ArgumentError('Invalid fileData type');
    }

    // Step 3: Complete upload
    onProgress?.call(null, Duration.zero);
    return await completeUpload(taskId);
  }

  static Completer<SnCloudFile?> createCloudFile({
    required UniversalFile fileData,
    required WidgetRef ref,
    String? poolId,
    String? path,
    FileUploadMode? mode,
    Function(double? progress, Duration estimate)? onProgress,
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
                ref,
                poolId,
                path,
                onProgress,
                completer,
              ),
            )
            .catchError((e) {
              debugPrint('Error removing GPS EXIF data: $e');
              return _processUpload(
                fileData,
                ref,
                poolId,
                path,
                onProgress,
                completer,
              );
            });

        return completer;
      }
    }

    _processUpload(fileData, ref, poolId, path, onProgress, completer);
    return completer;
  }

  // Helper method to process the upload with enhanced uploader
  static Completer<SnCloudFile?> _processUpload(
    UniversalFile fileData,
    WidgetRef ref,
    String? poolId,
    String? path,
    Function(double? progress, Duration estimate)? onProgress,
    Completer<SnCloudFile?> completer,
  ) {
    String actualMimetype = getMimeType(fileData);
    String actualFilename = fileData.displayName ?? 'randomly_file';
    Uint8List? bytes;

    // Handle the data based on what's in the UniversalFile
    final data = fileData.data;

    if (data is XFile) {
      _performUpload(
        fileData: data,
        fileName: fileData.displayName ?? data.name,
        path: path,
        contentType: actualMimetype,
        ref: ref,
        poolId: poolId,
        onProgress: onProgress,
        completer: completer,
      );
      return completer;
    } else if (data is List<int> || data is Uint8List) {
      bytes = data is List<int> ? Uint8List.fromList(data) : data;
      actualFilename = fileData.displayName ?? 'uploaded_file';
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

    if (bytes != null) {
      _performUpload(
        fileData: bytes,
        fileName: actualFilename,
        contentType: actualMimetype,
        path: path,
        ref: ref,
        poolId: poolId,
        onProgress: onProgress,
        completer: completer,
      );
    }

    return completer;
  }

  // Helper method to perform the actual upload with enhanced uploader
  static void _performUpload({
    required dynamic fileData,
    required String fileName,
    required String contentType,
    required WidgetRef ref,
    String? poolId,
    String? path,
    Function(double? progress, Duration estimate)? onProgress,
    required Completer<SnCloudFile?> completer,
  }) {
    // Use the enhanced uploader with task tracking
    final uploader = ref.read(enhancedFileUploaderProvider);

    // Call progress start
    onProgress?.call(null, Duration.zero);
    uploader
        .uploadFile(
          fileData: fileData,
          fileName: fileName,
          contentType: contentType,
          poolId: poolId,
          path: path,
          onProgress: onProgress,
        )
        .then((result) {
          // Call progress end
          onProgress?.call(null, Duration.zero);
          completer.complete(result);
        })
        .catchError((e) {
          completer.completeError(e);
          throw e;
        });
  }

  /// Gets the MIME type of a UniversalFile.
  static String getMimeType(UniversalFile file, {bool useFallback = true}) {
    final data = file.data;
    if (data is XFile) {
      final mime = data.mimeType;
      if (mime != null && mime.isNotEmpty) return mime;
      final filename = file.displayName ?? data.name;
      if (filename.isNotEmpty) {
        final detected = lookupMimeType(filename);
        if (detected != null) return detected;
      } else {
        return switch (file.type) {
          UniversalFileType.image => 'image/unknown',
          UniversalFileType.audio => 'audio/unknown',
          UniversalFileType.video => 'video/unknown',
          _ => 'application/unknown',
        };
      }
      if (useFallback) {
        final ext = extension(data.path).substring(1);
        if (ext.isNotEmpty) return 'application/$ext';
        return 'application/unknown';
      }
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

class FileDownloadService {
  final WidgetRef ref;

  FileDownloadService(this.ref);

  String _getFileExtension(SnCloudFile item) {
    var extName = extension(item.name).trim();
    if (extName.isEmpty) {
      extName = item.mimeType?.split('/').lastOrNull ?? 'jpeg';
    }
    return extName.replaceFirst('.', '');
  }

  String _getFileName(SnCloudFile item, String extName) {
    return item.name.isEmpty ? '${item.id}.$extName' : item.name;
  }

  Future<String> _downloadToTemp(SnCloudFile item, String extName) async {
    final client = ref.read(apiClientProvider);
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${item.id}.$extName';

    await client.download(
      '/drive/files/${item.id}',
      filePath,
      queryParameters: {'original': true},
    );

    return filePath;
  }

  Future<void> saveToGallery(SnCloudFile item) async {
    try {
      showSnackBar('Saving image...');

      final extName = _getFileExtension(item);
      final filePath = await _downloadToTemp(item, extName);

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await Gal.putImage(filePath, album: 'Solar Network');
        showSnackBar('Image saved to gallery');
      } else {
        await FileSaver.instance.saveFile(
          name: _getFileName(item, extName),
          file: File(filePath),
        );
        showSnackBar('Image saved to downloads');
      }
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> downloadFile(SnCloudFile item) async {
    try {
      showSnackBar('Downloading file...');

      final extName = _getFileExtension(item);
      final filePath = await _downloadToTemp(item, extName);

      await FileSaver.instance.saveFile(
        name: _getFileName(item, extName),
        file: File(filePath),
      );
      showSnackBar('File saved to downloads');
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> downloadWithProgress(
    SnCloudFile item, {
    void Function(int received, int total)? onProgress,
  }) async {
    final taskNotifier = ref.read(uploadTasksProvider.notifier);
    final taskId = taskNotifier.addLocalDownloadTask(item);

    try {
      showSnackBar('Downloading file...');

      final client = ref.read(apiClientProvider);
      final extName = _getFileExtension(item);
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${item.id}.$extName';

      await client.download(
        '/drive/files/${item.id}',
        filePath,
        queryParameters: {'original': true},
        onReceiveProgress: (count, total) {
          onProgress?.call(count, total);
          if (total > 0) {
            taskNotifier.updateDownloadProgress(taskId, count, total);
            taskNotifier.updateTransmissionProgress(taskId, count / total);
          }
        },
      );

      await FileSaver.instance.saveFile(
        name: _getFileName(item, extName),
        file: File(filePath),
      );
      taskNotifier.updateTaskStatus(taskId, DriveTaskStatus.completed);
      showSnackBar('File saved to downloads');
    } catch (e) {
      taskNotifier.updateTaskStatus(
        taskId,
        DriveTaskStatus.failed,
        errorMessage: e.toString(),
      );
      showErrorAlert(e);
    }
  }
}
