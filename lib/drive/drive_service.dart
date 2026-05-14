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
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/screens/upload_tasks.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:mime/mime.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path/path.dart' show extension;
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:http_parser/http_parser.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'drive_service.g.dart';

const String driveFileKeySecretPrefix = 'drive_e2ee_file_key_';
const int driveUploadChunkSizeBytes = 5 * 1024 * 1024;
const int driveDirectUploadMaxChunks = 2;
const int driveDirectUploadMaxFileSizeBytes =
    driveUploadChunkSizeBytes * driveDirectUploadMaxChunks;
const int driveChunkUploadConcurrency = 3;

class _ConcurrencyLimiter {
  final int maxConcurrent;
  final List<Future<void>> _running = [];

  _ConcurrencyLimiter(this.maxConcurrent);

  Future<T> run<T>(Future<T> Function() task) async {
    while (_running.length >= maxConcurrent) {
      await Future.any(_running);
    }

    final future = task();
    _running.add(future.then((_) => _running.remove(future)));
    return future;
  }
}

class DriveE2eeFileEnvelope {
  static const String scheme = 'file.aesgcm.v1';
  static const String _magic = 'DYE2EE1\x00';
  static const int _version = 1;
  static const int _saltLength = 16;
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
    String encryptionScheme = scheme,
  }) {
    final ikm = _decodeEncryptKey(encryptKey);
    final random = Random.secure();
    final salt = Uint8List.fromList(
      List<int>.generate(_saltLength, (_) => random.nextInt(256)),
    );
    final nonce = Uint8List.fromList(
      List<int>.generate(_nonceLength, (_) => random.nextInt(256)),
    );
    final keyBytes = _hkdfSha256(ikm: ikm, salt: salt, outputLength: 32);

    if (encryptionHeader != null && !_isValidBase64(encryptionHeader)) {
      throw const FormatException('encryptionHeader must be valid base64.');
    }
    if (encryptionSignature != null && !_isValidBase64(encryptionSignature)) {
      throw const FormatException('encryptionSignature must be valid base64.');
    }

    final aadHeader = <String, dynamic>{
      'encryptionScheme': encryptionScheme,
      'encryptionHeader': encryptionHeader,
      'encryptionSignature': encryptionSignature,
      'kdf': 'hkdf-sha256',
    };
    final aadBytes = Uint8List.fromList(utf8.encode(jsonEncode(aadHeader)));

    final cipher = pc.GCMBlockCipher(pc.AESEngine())
      ..init(
        true,
        pc.AEADParameters(
          pc.KeyParameter(keyBytes),
          _tagLength * 8,
          nonce,
          aadBytes,
        ),
      );
    final encrypted = cipher.process(plaintext);
    if (encrypted.length < _tagLength) {
      throw StateError(
        'Encryption output is shorter than expected tag length.',
      );
    }
    final ciphertext = encrypted.sublist(0, encrypted.length - _tagLength);
    final tag = encrypted.sublist(encrypted.length - _tagLength);

    final headerLengthBytes = ByteData(4)
      ..setUint32(0, aadBytes.length, Endian.big);

    final out = BytesBuilder(copy: false);
    out.add(utf8.encode(_magic));
    out.addByte(_version);
    out.addByte(salt.length);
    out.add(salt);
    out.add(nonce);
    out.add(headerLengthBytes.buffer.asUint8List());
    out.add(aadBytes);
    out.add(ciphertext);
    out.add(tag);
    return out.toBytes();
  }

  static Uint8List decryptBytes({
    required Uint8List encryptedPayload,
    required String encryptKey,
  }) {
    try {
      return _decryptBytesV2(
        encryptedPayload: encryptedPayload,
        encryptKey: encryptKey,
      );
    } catch (_) {
      // Backward compatibility for early client envelope layout.
      return _decryptBytesLegacyV1(
        encryptedPayload: encryptedPayload,
        encryptKey: encryptKey,
      );
    }
  }

  static Uint8List _decryptBytesV2({
    required Uint8List encryptedPayload,
    required String encryptKey,
  }) {
    final ikm = _decodeEncryptKey(encryptKey);
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
    if (encryptedPayload.length <
        offset + saltLength + _nonceLength + 4 + _tagLength) {
      throw const FormatException('Invalid encrypted payload structure.');
    }
    final salt = encryptedPayload.sublist(offset, offset + saltLength);
    offset += saltLength;

    final nonce = encryptedPayload.sublist(offset, offset + _nonceLength);
    offset += _nonceLength;

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

    if (encryptedPayload.length < offset + _tagLength) {
      throw const FormatException('Invalid encrypted payload ciphertext.');
    }
    final ciphertext = encryptedPayload.sublist(
      offset,
      encryptedPayload.length - _tagLength,
    );
    final tag = encryptedPayload.sublist(encryptedPayload.length - _tagLength);
    final cipherInput = Uint8List(ciphertext.length + tag.length)
      ..setAll(0, ciphertext)
      ..setAll(ciphertext.length, tag);
    final keyBytes = _hkdfSha256(ikm: ikm, salt: salt, outputLength: 32);

    final cipher = pc.GCMBlockCipher(pc.AESEngine())
      ..init(
        false,
        pc.AEADParameters(
          pc.KeyParameter(keyBytes),
          _tagLength * 8,
          nonce,
          headerBytes,
        ),
      );
    return cipher.process(cipherInput);
  }

  static Uint8List _decryptBytesLegacyV1({
    required Uint8List encryptedPayload,
    required String encryptKey,
  }) {
    final keyBytes = _decodeEncryptKey(encryptKey);
    var offset = 0;

    if (encryptedPayload.length < _magic.length + 1 + 1) {
      throw const FormatException('Invalid encrypted payload length.');
    }
    final magic = utf8.decode(encryptedPayload.sublist(0, _magic.length));
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
      throw const FormatException(
        'Invalid legacy encrypted payload structure.',
      );
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
    offset += 4 + headerLength;
    if (encryptedPayload.length < offset) {
      throw const FormatException('Invalid legacy encrypted payload header.');
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

  static Uint8List _hkdfSha256({
    required Uint8List ikm,
    required Uint8List salt,
    required int outputLength,
  }) {
    final hmac = Hmac(sha256, salt);
    final prk = hmac.convert(ikm).bytes;
    final blocks = <int>[];
    var previous = <int>[];
    var counter = 1;
    while (blocks.length < outputLength) {
      final input = <int>[...previous, counter];
      previous = Hmac(sha256, prk).convert(input).bytes;
      blocks.addAll(previous);
      counter += 1;
    }
    return Uint8List.fromList(blocks.sublist(0, outputLength));
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

  static bool _isValidBase64(String value) {
    try {
      base64Decode(value);
      return true;
    } catch (_) {
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
FileUploader driveFileUploader(Ref ref) {
  return FileUploader(ref);
}

class FileUploader {
  final Ref ref;
  late final _client = ref.watch(solarNetworkClientProvider).dio;
  late final _driveApi = ref.watch(solarNetworkClientProvider).drive;
  FileUploader(this.ref);

  List<Map<String, dynamic>> _extractChildrenPayload(dynamic responseData) {
    if (responseData is List) {
      return responseData
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }

    return const [];
  }

  Future<String?> _resolveParentIdFromPath({
    String? path,
    String? poolId,
  }) async {
    final normalizedPath = (path ?? '').trim();
    if (normalizedPath.isEmpty || normalizedPath == '/') return null;

    final parts = normalizedPath
        .split('/')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return null;

    String? parentId;
    for (final part in parts) {
      final endpoint = parentId == null
          ? '/drive/files/root/children'
          : '/drive/files/$parentId/children';
      final response = await _client.get(
        endpoint,
        queryParameters: {
          'pool': ?poolId,
        },
      );

      final children = _extractChildrenPayload(response.data);
      final matchedFolder = children
          .where(
            (item) =>
                item['is_folder'] == true && item['name']?.toString() == part,
          )
          .firstOrNull;

      if (matchedFolder == null) {
        throw StateError('Cannot resolve upload directory from path: $path');
      }

      parentId = matchedFolder['id']?.toString();
      if (parentId == null || parentId.isEmpty) {
        throw StateError('Folder ID missing while resolving path: $path');
      }
    }

    return parentId;
  }

  bool shouldUseDirectUpload({required int totalSize, int? customChunkSize}) {
    if (customChunkSize != null) return false;
    return totalSize <= driveDirectUploadMaxFileSizeBytes;
  }

  Future<int> resolveUploadDataSize(dynamic fileData) async {
    if (fileData is XFile) return fileData.length();
    if (fileData is Uint8List) return fileData.length;
    throw ArgumentError('Invalid fileData type');
  }

  SnCloudFile _parseUploadedFileResponse(Map<String, dynamic> payload) {
    final directFile = payload['file'];
    if (directFile is Map) {
      return SnCloudFile.fromJson(Map<String, dynamic>.from(directFile));
    }

    final fileInfo = payload['file_info'];
    if (fileInfo is Map) {
      return SnCloudFile.fromJson(Map<String, dynamic>.from(fileInfo));
    }

    final nestedData = payload['data'];
    if (nestedData is Map) {
      final nestedFile = nestedData['file'];
      if (nestedFile is Map) {
        return SnCloudFile.fromJson(Map<String, dynamic>.from(nestedFile));
      }
      if (nestedData['id'] != null) {
        return SnCloudFile.fromJson(Map<String, dynamic>.from(nestedData));
      }
    }

    if (payload['id'] != null) {
      return SnCloudFile.fromJson(payload);
    }

    throw const FormatException(
      'Unable to parse uploaded file response from direct upload.',
    );
  }

  Future<SnCloudFile> uploadFileDirect({
    required dynamic fileData,
    required String fileName,
    required String contentType,
    String? poolId,
    String? bundleId,
    String? expiredAt,
    String? parentId,
    String? path,
    String? encryptionScheme,
    String? encryptionHeader,
    String? encryptionSignature,
    String? usage,
    String? applicationType,
    ProgressCallback? onSendProgress,
  }) async {
    late final Uint8List bytes;
    if (fileData is XFile) {
      bytes = Uint8List.fromList(await fileData.readAsBytes());
    } else if (fileData is Uint8List) {
      bytes = fileData;
    } else {
      throw ArgumentError('Invalid fileData type');
    }

    final normalizedName = fileName.trim();
    final multipartFileName = normalizedName.isEmpty
        ? 'upload.bin'
        : normalizedName;

    MediaType? multipartContentType;
    final normalizedContentType = contentType.trim();
    if (normalizedContentType.isNotEmpty) {
      try {
        multipartContentType = MediaType.parse(normalizedContentType);
      } catch (_) {}
    }

    final payload = <String, dynamic>{
      'file': MultipartFile.fromBytes(
        bytes,
        filename: multipartFileName,
        contentType: multipartContentType,
      ),
      'poolId': poolId,
      'parent_id':
          parentId ?? await _resolveParentIdFromPath(path: path, poolId: poolId),
      'bundleId': bundleId,
      'expiredAt': expiredAt,
      'usage': usage,
      'applicationType': applicationType,
    };

    if (encryptionScheme != null && encryptionScheme.isNotEmpty) {
      payload['encryptionScheme'] = encryptionScheme;
      payload['encryptionHeader'] = encryptionHeader;
      payload['encryptionSignature'] = encryptionSignature;
    }
    payload.removeWhere((_, value) => value == null);

    final response = await _client.post(
      '/drive/files/upload/direct',
      data: FormData.fromMap(payload),
      onSendProgress: onSendProgress,
      options: Options(
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );

    if (response.data is! Map) {
      throw const FormatException('Unexpected direct upload response payload.');
    }

    return _parseUploadedFileResponse(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

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
    String? encryptionScheme,
    String? encryptionHeader,
    String? encryptionSignature,
    String? expiredAt,
    int? chunkSize,
    String? parentId,
    String? path,
    String? usage,
    String? applicationType,
  }) async {
    final stepTimer = Stopwatch()..start();

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
    stepTimer.stop();
    debugPrint(
      '[DriveUpload] Hash calculation took: ${stepTimer.elapsedMilliseconds}ms',
    );

    if (encryptionScheme != null &&
        encryptionScheme.isNotEmpty &&
        (encryptionHeader == null || encryptionHeader.isEmpty)) {
      throw const FormatException(
        'encryption_header is required when encryption_scheme is set.',
      );
    }
    if (encryptionHeader != null &&
        !DriveE2eeFileEnvelope._isValidBase64(encryptionHeader)) {
      throw const FormatException('encryption_header must be valid base64.');
    }
    if (encryptionSignature != null &&
        !DriveE2eeFileEnvelope._isValidBase64(encryptionSignature)) {
      throw const FormatException('encryption_signature must be valid base64.');
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
      'parent_id':
          parentId ?? await _resolveParentIdFromPath(path: path, poolId: poolId),
      'usage': usage,
      'application_type': applicationType,
    };

    if (encryptionScheme != null && encryptionScheme.isNotEmpty) {
      payload['encryption_scheme'] = encryptionScheme;
      payload['encryption_header'] = encryptionHeader;
      payload['encryption_signature'] = encryptionSignature;
    }

    stepTimer
      ..reset()
      ..start();
    final response = await _client.post(
      '/drive/files/upload/create',
      data: payload,
      options: Options(
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );
    stepTimer.stop();
    debugPrint(
      '[DriveUpload] Create upload task request took: ${stepTimer.elapsedMilliseconds}ms',
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
    final stepTimer = Stopwatch()..start();
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
      options: Options(
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );
    stepTimer.stop();
    debugPrint(
      '[DriveUpload] Chunk $chunkIndex upload took: ${stepTimer.elapsedMilliseconds}ms',
    );
  }

  Future<Map<String, dynamic>> getUploadProgress(String taskId) async {
    final response = await _client.get(
      '/drive/files/upload/progress/$taskId',
      options: Options(
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<SnCloudFile> _waitForUploadComplete(String taskId) async {
    while (true) {
      final progress = await getUploadProgress(taskId);
      final status = progress['status']?.toString();

      if (status == 'Completed') {
        final file = progress['file'];
        if (file is Map) {
          return SnCloudFile.fromJson(Map<String, dynamic>.from(file));
        }
        throw const FormatException('Upload completed but no file data found.');
      }

      if (status == 'Failed') {
        final error = progress['error']?.toString() ?? 'Upload failed';
        throw Exception(error);
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// Completes the upload and returns the CloudFile object.
  Future<SnCloudFile> completeUpload(String taskId) async {
    final stepTimer = Stopwatch()..start();
    final response = await _client.post(
      '/drive/files/upload/complete/$taskId',
      options: Options(
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );
    stepTimer.stop();
    debugPrint(
      '[DriveUpload] Complete upload request took: ${stepTimer.elapsedMilliseconds}ms',
    );

    if (response.statusCode == 202) {
      return _waitForUploadComplete(taskId);
    }

    return SnCloudFile.fromJson(response.data);
  }

  /// Uploads multiple chunks concurrently with a concurrency limit.
  Future<void> uploadChunksBatch({
    required String taskId,
    required List<Uint8List> chunks,
    required int startIndex,
    required int totalSize,
    Function(double? progress, Duration estimate)? onProgress,
  }) async {
    int bytesUploaded = 0;
    final futures = <Future<void>>[];
    final semaphore = _ConcurrencyLimiter(driveChunkUploadConcurrency);

    for (int i = 0; i < chunks.length; i++) {
      final chunkIndex = startIndex + i;
      final chunk = chunks[i];

      futures.add(
        semaphore.run(() async {
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
        }),
      );
    }

    await Future.wait(futures);
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
    String? parentId,
    String? path,
    String? usage,
    String? applicationType,
    Function(double? progress, Duration estimate)? onProgress,
  }) async {
    final overallTimer = Stopwatch()..start();
    dynamic uploadData = fileData;
    String? encryptionScheme;
    String? encryptionHeader;
    String? encryptionSignature;
    String? localEncryptKey;

    if (encryptPassword != null && encryptPassword.trim().isNotEmpty) {
      final encryptTimer = Stopwatch()..start();
      final plaintext = switch (fileData) {
        XFile value => Uint8List.fromList(await value.readAsBytes()),
        Uint8List value => value,
        _ => throw ArgumentError(
          'Encrypted upload only supports XFile/Uint8List input.',
        ),
      };
      localEncryptKey = encryptPassword.trim();
      encryptionScheme = DriveE2eeFileEnvelope.scheme;
      final headerJson = jsonEncode({'v': 1, 'kdf': 'hkdf-sha256'});
      encryptionHeader = base64Encode(utf8.encode(headerJson));
      uploadData = DriveE2eeFileEnvelope.encryptBytes(
        plaintext: plaintext,
        encryptKey: localEncryptKey,
        encryptionHeader: encryptionHeader,
        encryptionSignature: encryptionSignature,
        encryptionScheme: encryptionScheme,
      );
      encryptTimer.stop();
      debugPrint(
        '[DriveUpload] Encryption took: ${encryptTimer.elapsedMilliseconds}ms',
      );
    }

    final totalSize = await resolveUploadDataSize(uploadData);

    if (shouldUseDirectUpload(
      totalSize: totalSize,
      customChunkSize: customChunkSize,
    )) {
      onProgress?.call(null, Duration.zero);
      final directTimer = Stopwatch()..start();
      final uploaded = await uploadFileDirect(
        fileData: uploadData,
        fileName: fileName,
        contentType: contentType,
        poolId: poolId,
        bundleId: bundleId,
        expiredAt: expiredAt,
        parentId: parentId,
        path: path,
        encryptionScheme: encryptionScheme,
        encryptionHeader: encryptionHeader,
        encryptionSignature: encryptionSignature,
        usage: usage,
        applicationType: applicationType,
        onSendProgress: (sent, total) {
          if (total > 0) {
            onProgress?.call(sent / total, Duration.zero);
          }
        },
      );
      directTimer.stop();
      debugPrint(
        '[DriveUpload] Direct upload took: ${directTimer.elapsedMilliseconds}ms',
      );

      if (localEncryptKey != null && localEncryptKey.isNotEmpty) {
        await _storeFileEncryptKey(uploaded.id, localEncryptKey);
      }

      onProgress?.call(null, Duration.zero);
      overallTimer.stop();
      debugPrint(
        '[DriveUpload] Total upload time: ${overallTimer.elapsedMilliseconds}ms',
      );
      return uploaded;
    }

    // Step 1: Create upload task
    onProgress?.call(null, Duration.zero);
    final createTimer = Stopwatch()..start();
    final createResponse = await createUploadTask(
      fileData: uploadData,
      fileName: fileName,
      contentType: contentType,
      poolId: poolId,
      bundleId: bundleId,
      encryptPassword: encryptPassword,
      encryptionScheme: encryptionScheme,
      encryptionHeader: encryptionHeader,
      encryptionSignature: encryptionSignature,
      expiredAt: expiredAt,
      chunkSize: customChunkSize,
      parentId: parentId,
      path: path,
      usage: usage,
      applicationType: applicationType,
    );
    createTimer.stop();
    debugPrint(
      '[DriveUpload] Step 1 (Create upload task) total took: ${createTimer.elapsedMilliseconds}ms',
    );

    if (createResponse['file_exists'] == true) {
      // File already exists, return the existing file
      overallTimer.stop();
      debugPrint(
        '[DriveUpload] File exists, total upload time: ${overallTimer.elapsedMilliseconds}ms',
      );
      return SnCloudFile.fromJson(createResponse['file']);
    }

    final taskId = createResponse['task_id'] as String;
    final chunkSize = createResponse['chunk_size'] as int;
    // Step 2: Upload chunks in batches
    final chunkTimer = Stopwatch()..start();
    int totalChunks = 0;
    int bytesUploaded = 0;

    if (uploadData is XFile) {
      final chunks = <Uint8List>[];
      await for (final chunk in _readChunksFromStream(
        uploadData.openRead(),
        chunkSize,
      )) {
        chunks.add(chunk);
      }
      totalChunks = chunks.length;

      for (
        int batchStart = 0;
        batchStart < chunks.length;
        batchStart += driveChunkUploadConcurrency
      ) {
        final batchEnd =
            (batchStart + driveChunkUploadConcurrency > chunks.length)
            ? chunks.length
            : batchStart + driveChunkUploadConcurrency;
        final batch = chunks.sublist(batchStart, batchEnd);

        await uploadChunksBatch(
          taskId: taskId,
          chunks: batch,
          startIndex: batchStart,
          totalSize: totalSize,
          onProgress: (progress, estimate) {
            final overallProgress =
                (bytesUploaded + (progress ?? 0) * totalSize) / totalSize;
            onProgress?.call(overallProgress, estimate);
          },
        );
        bytesUploaded += batch.fold(0, (sum, chunk) => sum + chunk.length);
      }
    } else if (uploadData is Uint8List) {
      final chunks = <Uint8List>[];
      for (int i = 0; i < uploadData.length; i += chunkSize) {
        final end = i + chunkSize > uploadData.length
            ? uploadData.length
            : i + chunkSize;
        chunks.add(Uint8List.fromList(uploadData.sublist(i, end)));
      }
      totalChunks = chunks.length;

      for (
        int batchStart = 0;
        batchStart < chunks.length;
        batchStart += driveChunkUploadConcurrency
      ) {
        final batchEnd =
            (batchStart + driveChunkUploadConcurrency > chunks.length)
            ? chunks.length
            : batchStart + driveChunkUploadConcurrency;
        final batch = chunks.sublist(batchStart, batchEnd);

        await uploadChunksBatch(
          taskId: taskId,
          chunks: batch,
          startIndex: batchStart,
          totalSize: totalSize,
          onProgress: (progress, estimate) {
            final overallProgress =
                (bytesUploaded + (progress ?? 0) * totalSize) / totalSize;
            onProgress?.call(overallProgress, estimate);
          },
        );
        bytesUploaded += batch.fold(0, (sum, chunk) => sum + chunk.length);
      }
    } else {
      throw ArgumentError('Invalid fileData type');
    }
    chunkTimer.stop();
    debugPrint(
      '[DriveUpload] Step 2 (Upload $totalChunks chunks) total took: ${chunkTimer.elapsedMilliseconds}ms',
    );

    // Step 3: Complete upload
    onProgress?.call(null, Duration.zero);
    final completeTimer = Stopwatch()..start();
    final uploaded = await completeUpload(taskId);
    completeTimer.stop();
    debugPrint(
      '[DriveUpload] Step 3 (Complete upload) took: ${completeTimer.elapsedMilliseconds}ms',
    );

    if (localEncryptKey != null && localEncryptKey.isNotEmpty) {
      await _storeFileEncryptKey(uploaded.id, localEncryptKey);
    }

    overallTimer.stop();
    debugPrint(
      '[DriveUpload] Total upload time: ${overallTimer.elapsedMilliseconds}ms',
    );
    return uploaded;
  }

  Future<void> _storeFileEncryptKey(String fileId, String key) async {
    try {
      final db = ref.read(databaseProvider);
      await db.setSecret('$driveFileKeySecretPrefix$fileId', key);
    } catch (_) {}
  }

  Completer<SnCloudFile?> createCloudFile({
    required UniversalFile fileData,
    String? poolId,
    String? parentId,
    String? path,
    String? encryptPassword,
    FileUploadMode? mode,
    String? usage,
    String? applicationType,
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
                poolId,
                parentId,
                path,
                encryptPassword,
                onProgress,
                completer,
                usage: usage,
                applicationType: applicationType,
              ),
            )
            .catchError((e) {
              debugPrint('Error removing GPS EXIF data: $e');
              return _processUpload(
                fileData,
                poolId,
                parentId,
                path,
                encryptPassword,
                onProgress,
                completer,
                usage: usage,
                applicationType: applicationType,
              );
            });

        return completer;
      }
    }

    _processUpload(
      fileData,
      poolId,
      parentId,
      path,
      encryptPassword,
      onProgress,
      completer,
      usage: usage,
      applicationType: applicationType,
    );
    return completer;
  }

  // Helper method to process the upload with enhanced uploader
  Completer<SnCloudFile?> _processUpload(
    UniversalFile fileData,
    String? poolId,
    String? parentId,
    String? path,
    String? encryptPassword,
    Function(double? progress, Duration estimate)? onProgress,
    Completer<SnCloudFile?> completer, {
    String? usage,
    String? applicationType,
  }) {
    String actualMimetype = getMimeType(fileData);
    String actualFilename = fileData.displayName ?? 'randomly_file';
    Uint8List? bytes;

    // Handle the data based on what's in the UniversalFile
    final data = fileData.data;

    if (data is XFile) {
      _performUpload(
        fileData: data,
        fileName: fileData.displayName ?? data.name,
        parentId: parentId,
        path: path,
        encryptPassword: encryptPassword,
        contentType: actualMimetype,
        poolId: poolId,
        onProgress: onProgress,
        completer: completer,
        usage: usage,
        applicationType: applicationType,
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
        parentId: parentId,
        path: path,
        encryptPassword: encryptPassword,
        poolId: poolId,
        onProgress: onProgress,
        completer: completer,
        usage: usage,
        applicationType: applicationType,
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
    String? parentId,
    String? path,
    String? encryptPassword,
    String? usage,
    String? applicationType,
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
          parentId: parentId,
          path: path,
          encryptPassword: encryptPassword,
          usage: usage,
          applicationType: applicationType,
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

  // =========================================================================
  // File management operations
  // =========================================================================

  /// Updates the file's display name. Owner only.
  Future<SnCloudFile> renameFile(String fileId, String newName) {
    return _driveApi.updateFileName(fileId, newName);
  }

  /// Moves a file to a different folder or to root. Owner only.
  Future<SnCloudFile> moveFile(
    String fileId, {
    String? parentId,
    bool? indexed,
  }) {
    return _driveApi.moveFile(fileId, parentId: parentId, indexed: indexed);
  }

  /// Permanently deletes a file. Owner only.
  Future<SnCloudFile> deleteFile(String fileId) {
    return _driveApi.deleteFile(fileId);
  }

  /// Deletes multiple files at once. Owner only.
  Future<int> batchDeleteFiles(List<String> fileIds) {
    return _driveApi.batchDeleteFiles(fileIds);
  }

  /// Creates a new virtual folder.
  Future<SnCloudFile> createFolder({required String name, String? parentId}) {
    return _driveApi.createFolder(name: name, parentId: parentId);
  }

  /// Sets content sensitivity labels. Owner only.
  Future<SnCloudFile> updateSensitiveMarks(
    String fileId,
    List<String> marks,
  ) {
    return _driveApi.updateSensitiveMarks(fileId, marks);
  }

  /// Sets arbitrary user-defined metadata. Owner only.
  Future<SnCloudFile> updateUserMeta(
    String fileId,
    Map<String, dynamic> meta,
  ) {
    return _driveApi.updateUserMeta(fileId, meta);
  }

  /// Permanently deletes all recycled files for the current user.
  Future<int> deleteRecycledFiles() {
    return _driveApi.deleteRecycledFiles();
  }
}

enum FileUploadMode { generic, mediaSafe }

class FileDownloadService {
  final Ref ref;
  late final _driveApi = ref.read(solarNetworkClientProvider).drive;

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

  Future<void> _tryDecryptDownloadedFile(
    String filePath,
    SnCloudFile item,
  ) async {
    if (!DriveE2eeFileEnvelope.isEncryptedFile(item)) return;
    final key =
        await _getStoredFileEncryptKey(item.id) ??
        DriveE2eeFileEnvelope.extractEncryptionKey(item);
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

  Future<String?> _getStoredFileEncryptKey(String fileId) async {
    try {
      final db = ref.read(databaseProvider);
      return await db.getSecret('$driveFileKeySecretPrefix$fileId');
    } catch (_) {
      return null;
    }
  }

  String _getOriginalUrl(SnCloudFile item, {String? serverUrl}) {
    if (serverUrl != null && item.url == null) {
      return '$serverUrl/drive/files/${item.id}?original=true';
    }
    final baseUri = item.url ?? '/drive/files/${item.id}';
    return baseUri.contains('?')
        ? '$baseUri&original=true'
        : '$baseUri?original=true';
  }

  Future<String?> _getCachedOriginalFile(SnCloudFile item) async {
    try {
      final serverUrl = ref.read(serverUrlProvider);
      final url = _getOriginalUrl(item, serverUrl: serverUrl);
      final fileInfo = await DefaultCacheManager().getFileFromCache(url);
      if (fileInfo != null && await File(fileInfo.file.path).exists()) {
        return fileInfo.file.path;
      }
    } catch (_) {}
    return null;
  }

  Future<String> _downloadToTemp(SnCloudFile item, String extName) async {
    final cachedPath = await _getCachedOriginalFile(item);
    if (cachedPath != null) {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${item.id}.$extName';
      await File(cachedPath).copy(filePath);
      await _tryDecryptDownloadedFile(filePath, item);
      return filePath;
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${item.id}.$extName';

    await _driveApi.downloadFile(
      fileId: item.id,
      savePath: filePath,
      original: true,
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

      final extName = _getFileExtension(item);
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${item.id}.$extName';

      await _driveApi.downloadFile(
        fileId: item.id,
        savePath: filePath,
        original: true,
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
