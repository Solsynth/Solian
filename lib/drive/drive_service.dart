import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/screens/upload_tasks.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:mime/mime.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path/path.dart' show extension;
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'drive_service.g.dart';

class DriveE2eeFileEnvelope {
  static const String scheme = 'file.aesgcm.v1';
  static const int epoch = 1;
  static const String _magic = 'DYE2EE1\x00';
  static const int _version = 1;
  static const int _nonceLength = 12;
  static const int _tagLength = 16;

  static bool isEncryptedFile(SnCloudFile file) {
    final meta = _extractE2eeMeta(file);
    if (meta == null) return false;
    final value = meta['scheme']?.toString();
    return value != null && value.isNotEmpty;
  }

  static Map<String, dynamic>? _extractE2eeMeta(SnCloudFile file) {
    final fileMeta = file.fileMeta;
    if (fileMeta is! Map) return null;
    final root = Map<String, dynamic>.from(fileMeta as Map);
    final e2ee = root['e2ee'];
    if (e2ee is! Map) return null;
    return Map<String, dynamic>.from(e2ee);
  }

  static String? extractEncryptionKey(SnCloudFile file) {
    final fileMeta = file.fileMeta;
    if (fileMeta is! Map) return null;
    final root = Map<String, dynamic>.from(fileMeta as Map);
    final e2ee = root['e2ee'];
    if (e2ee is Map) {
      final mapped = Map<String, dynamic>.from(e2ee);
      final key =
          mapped['key']?.toString() ?? mapped['encrypt_key']?.toString();
      if (key != null && key.isNotEmpty) return key;
    }
    final topLevel =
        root['e2ee_key']?.toString() ?? root['encrypt_key']?.toString();
    if (topLevel != null && topLevel.isNotEmpty) return topLevel;
    return null;
  }

  static String generateEncryptKey() {
    final random = Random.secure();
    final keyBytes = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    return base64Encode(keyBytes);
  }

  static Uint8List encryptBytes({
    required Uint8List plaintext,
    required String encryptKey,
    String? encryptionHeader,
    String? encryptionSignature,
    int encryptionEpoch = epoch,
    String encryptionScheme = scheme,
  }) {
    final keyBytes = _decodeEncryptKey(encryptKey);
    final random = Random.secure();
    final nonce = Uint8List.fromList(
      List<int>.generate(_nonceLength, (_) => random.nextInt(256)),
    );
    final cipher = pc.GCMBlockCipher(pc.AESEngine())
      ..init(
        true,
        pc.AEADParameters(
          pc.KeyParameter(keyBytes),
          _tagLength * 8,
          nonce,
          Uint8List(0),
        ),
      );
    final encrypted = cipher.process(plaintext);
    if (encrypted.length < _tagLength) {
      throw StateError('Encryption output is shorter than expected tag length.');
    }
    final ciphertext = encrypted.sublist(0, encrypted.length - _tagLength);
    final tag = encrypted.sublist(encrypted.length - _tagLength);

    final header = <String, dynamic>{
      'encryptionScheme': encryptionScheme,
      'encryptionEpoch': encryptionEpoch,
      'encryptionHeader': encryptionHeader,
      'encryptionSignature': encryptionSignature,
      'kdf': 'none',
    };
    final headerBytes = Uint8List.fromList(utf8.encode(jsonEncode(header)));
    final headerLengthBytes = ByteData(4)
      ..setUint32(0, headerBytes.length, Endian.big);

    final out = BytesBuilder(copy: false);
    out.add(utf8.encode(_magic));
    out.addByte(_version);
    out.addByte(0); // salt length (raw-key mode)
    out.add(nonce);
    out.add(tag);
    out.add(headerLengthBytes.buffer.asUint8List());
    out.add(headerBytes);
    out.add(ciphertext);
    return out.toBytes();
  }

  static Uint8List decryptBytes({
    required Uint8List encryptedPayload,
    required String encryptKey,
  }) {
    final keyBytes = _decodeEncryptKey(encryptKey);
    var offset = 0;

    if (encryptedPayload.length < _magic.length + 1 + 1) {
      throw const FormatException('Invalid encrypted payload length.');
    }

    final magic = utf8.decode(
      encryptedPayload.sublist(0, _magic.length),
      allowMalformed: false,
    );
    if (magic != _magic) {
      throw const FormatException('Invalid encrypted payload magic.');
    }
    offset += _magic.length;

    final version = encryptedPayload[offset];
    offset += 1;
    if (version != _version) {
      throw FormatException('Unsupported encrypted payload version: $version');
    }

    final saltLength = encryptedPayload[offset];
    offset += 1;
    offset += saltLength;

    if (encryptedPayload.length < offset + _nonceLength + _tagLength + 4) {
      throw const FormatException('Invalid encrypted payload structure.');
    }

    final nonce = encryptedPayload.sublist(offset, offset + _nonceLength);
    offset += _nonceLength;
    final tag = encryptedPayload.sublist(offset, offset + _tagLength);
    offset += _tagLength;

    final headerLength = ByteData.sublistView(
      encryptedPayload,
      offset,
      offset + 4,
    ).getUint32(0, Endian.big);
    offset += 4;

    if (encryptedPayload.length < offset + headerLength) {
      throw const FormatException('Invalid encrypted payload header length.');
    }

    // Header currently carries metadata only; decoded for validation/sanity.
    final headerBytes = encryptedPayload.sublist(offset, offset + headerLength);
    offset += headerLength;
    if (headerBytes.isNotEmpty) {
      final decoded = jsonDecode(utf8.decode(headerBytes));
      if (decoded is! Map) {
        throw const FormatException('Invalid encrypted payload header.');
      }
    }

    final ciphertext = encryptedPayload.sublist(offset);
    final cipherInput = Uint8List(ciphertext.length + tag.length)
      ..setAll(0, ciphertext)
      ..setAll(ciphertext.length, tag);

    final cipher = pc.GCMBlockCipher(pc.AESEngine())
      ..init(
        false,
        pc.AEADParameters(
          pc.KeyParameter(keyBytes),
          _tagLength * 8,
          nonce,
          Uint8List(0),
        ),
      );
    return cipher.process(cipherInput);
  }

  static Uint8List _decodeEncryptKey(String raw) {
    try {
      final bytes = base64Decode(raw);
      if (bytes.length != 32) {
        throw const FormatException('encryptKey must decode to 32 bytes.');
      }
      return Uint8List.fromList(bytes);
    } catch (err) {
      throw FormatException('Invalid encryptKey base64: $err');
    }
  }
}

@Riverpod(keepAlive: true)
FileUploader driveFileUploader(Ref ref) {
  return FileUploader(ref);
}

class FileUploader {
  final Ref ref;
  late final Dio _client = ref.watch(apiClientProvider);
  FileUploader(this.ref);

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

  /// Reads chunks from a stream and yields them as they fill to the specified size.
  /// This is memory-efficient as it only holds one chunk at a time.
  Stream<Uint8List> _readChunksFromStream(
    Stream<List<int>> stream,
    int chunkSize,
  ) async* {
    final buffer = <int>[];

    await for (final data in stream) {
      buffer.addAll(data);

      // Yield complete chunks
      while (buffer.length >= chunkSize) {
        yield Uint8List.fromList(buffer.sublist(0, chunkSize));
        buffer.removeRange(0, chunkSize);
      }
    }

    // Yield any remaining data as the final chunk
    if (buffer.isNotEmpty) {
      yield Uint8List.fromList(buffer);
    }
  }

  /// Creates an upload task for the given file.
  Future<Map<String, dynamic>> createUploadTask({
    required dynamic fileData,
    required String fileName,
    required String contentType,
    String? poolId,
    String? bundleId,
    String? encryptPassword,
    String? encryptKey,
    String? encryptionScheme,
    String? encryptionHeader,
    String? encryptionSignature,
    int? encryptionEpoch,
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

    final payload = <String, dynamic>{
      'hash': hash,
      'file_name': fileName,
      'file_size': fileSize,
      'content_type': contentType,
      'pool_id': poolId,
      'bundle_id': bundleId,
      'expired_at': expiredAt,
      'chunk_size': chunkSize,
      'path': path,
    };

    if (encryptKey != null && encryptKey.isNotEmpty) {
      payload['encrypt_key'] = encryptKey;
      payload['encryption_scheme'] = encryptionScheme;
      payload['encryption_header'] = encryptionHeader;
      payload['encryption_signature'] = encryptionSignature;
      payload['encryption_epoch'] = encryptionEpoch;
    } else if (encryptPassword != null && encryptPassword.isNotEmpty) {
      // Backward-compatible pass-through for non-E2EE code paths.
      payload['encrypt_password'] = encryptPassword;
    }

    final response = await _client.post(
      '/drive/files/upload/create',
      data: payload,
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
    dynamic uploadData = fileData;
    String? encryptKey;
    String? encryptionScheme;
    int? encryptionEpoch;

    if (encryptPassword != null && encryptPassword.trim().isNotEmpty) {
      final plaintext = switch (fileData) {
        XFile value => Uint8List.fromList(await value.readAsBytes()),
        Uint8List value => value,
        _ => throw ArgumentError(
            'Encrypted upload only supports XFile/Uint8List input.',
          ),
      };
      encryptKey = encryptPassword.trim();
      encryptionScheme = DriveE2eeFileEnvelope.scheme;
      encryptionEpoch = DriveE2eeFileEnvelope.epoch;
      uploadData = DriveE2eeFileEnvelope.encryptBytes(
        plaintext: plaintext,
        encryptKey: encryptKey,
        encryptionScheme: encryptionScheme,
        encryptionEpoch: encryptionEpoch,
      );
    }

    // Step 1: Create upload task
    onProgress?.call(null, Duration.zero);
    final createResponse = await createUploadTask(
      fileData: uploadData,
      fileName: fileName,
      contentType: contentType,
      poolId: poolId,
      bundleId: bundleId,
      encryptPassword: encryptPassword,
      encryptKey: encryptKey,
      encryptionScheme: encryptionScheme,
      encryptionEpoch: encryptionEpoch,
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
    int totalSize;
    if (uploadData is XFile) {
      totalSize = await uploadData.length();
    } else if (uploadData is Uint8List) {
      totalSize = uploadData.length;
    } else {
      throw ArgumentError('Invalid fileData type');
    }

    // Step 2: Upload chunks
    int bytesUploaded = 0;
    int chunkIndex = 0;
    if (uploadData is XFile) {
      // Stream chunks from XFile - memory efficient for large files
      await for (final chunk in _readChunksFromStream(
        uploadData.openRead(),
        chunkSize,
      )) {
        await uploadChunk(
          taskId: taskId,
          chunkIndex: chunkIndex,
          chunkData: chunk,
          onSendProgress: (sent, total) {
            final overallProgress = (bytesUploaded + sent) / totalSize;
            onProgress?.call(overallProgress, Duration.zero);
          },
        );
        bytesUploaded += chunk.length;
        chunkIndex++;
      }
    } else if (uploadData is Uint8List) {
      // For Uint8List, we can use the simple chunked approach
      // since the data is already in memory
      for (int i = 0; i < uploadData.length; i += chunkSize) {
        final end = i + chunkSize > uploadData.length
            ? uploadData.length
            : i + chunkSize;
        final chunk = Uint8List.fromList(uploadData.sublist(i, end));
        await uploadChunk(
          taskId: taskId,
          chunkIndex: chunkIndex,
          chunkData: chunk,
          onSendProgress: (sent, total) {
            final overallProgress = (bytesUploaded + sent) / totalSize;
            onProgress?.call(overallProgress, Duration.zero);
          },
        );
        bytesUploaded += chunk.length;
        chunkIndex++;
      }
    } else {
      throw ArgumentError('Invalid fileData type');
    }

    // Step 3: Complete upload
    onProgress?.call(null, Duration.zero);
    return await completeUpload(taskId);
  }

  Completer<SnCloudFile?> createCloudFile({
    required UniversalFile fileData,
    String? poolId,
    String? path,
    String? encryptPassword,
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
              (_) =>
                  _processUpload(
                    fileData,
                    poolId,
                    path,
                    encryptPassword,
                    onProgress,
                    completer,
                  ),
            )
            .catchError((e) {
              debugPrint('Error removing GPS EXIF data: $e');
              return _processUpload(
                fileData,
                poolId,
                path,
                encryptPassword,
                onProgress,
                completer,
              );
            });

        return completer;
      }
    }

    _processUpload(
      fileData,
      poolId,
      path,
      encryptPassword,
      onProgress,
      completer,
    );
    return completer;
  }

  // Helper method to process the upload with enhanced uploader
  Completer<SnCloudFile?> _processUpload(
    UniversalFile fileData,
    String? poolId,
    String? path,
    String? encryptPassword,
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
        encryptPassword: encryptPassword,
        contentType: actualMimetype,
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
        encryptPassword: encryptPassword,
        poolId: poolId,
        onProgress: onProgress,
        completer: completer,
      );
    }

    return completer;
  }

  // Helper method to perform the actual upload with enhanced uploader
  void _performUpload({
    required dynamic fileData,
    required String fileName,
    required String contentType,
    String? poolId,
    String? path,
    String? encryptPassword,
    Function(double? progress, Duration estimate)? onProgress,
    required Completer<SnCloudFile?> completer,
  }) {
    // Use the enhanced uploader with task tracking
    final uploader = EnhancedFileUploader(ref);

    // Call progress start
    onProgress?.call(null, Duration.zero);
    uploader
        .uploadFile(
          fileData: fileData,
          fileName: fileName,
          contentType: contentType,
          poolId: poolId,
          path: path,
          encryptPassword: encryptPassword,
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

class FileDownloadService {
  final Ref ref;

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

  Future<void> _tryDecryptDownloadedFile(String filePath, SnCloudFile item) async {
    if (!DriveE2eeFileEnvelope.isEncryptedFile(item)) return;
    final key = DriveE2eeFileEnvelope.extractEncryptionKey(item);
    if (key == null || key.isEmpty) {
      showSnackBar('Downloaded encrypted file (missing decrypt key).');
      return;
    }
    final encryptedBytes = await File(filePath).readAsBytes();
    final plaintext = DriveE2eeFileEnvelope.decryptBytes(
      encryptedPayload: encryptedBytes,
      encryptKey: key,
    );
    await File(filePath).writeAsBytes(plaintext, flush: true);
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
    await _tryDecryptDownloadedFile(filePath, item);

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
      await _tryDecryptDownloadedFile(filePath, item);

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

@Riverpod(keepAlive: true)
FileDownloadService driveFileDownloader(Ref ref) {
  return FileDownloadService(ref);
}
