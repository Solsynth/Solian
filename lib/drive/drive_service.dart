import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/tasks/app_task.dart';
import 'package:island/tasks/tasks_notifier.dart';
import 'package:island/drive/screens/upload_tasks.dart';
import 'package:island/drive/widgets/quota_sidebar.dart';
import 'package:island/payments/quota_purchase_sheet.dart';
import 'package:island/route.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:mime/mime.dart';
import 'package:native_exif/native_exif.dart';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:http_parser/http_parser.dart';
import 'package:island/core/media_kit_init.dart';
import 'package:media_kit/media_kit.dart';
import 'package:image/image.dart' as img;
import 'package:island/drive/client_webp_encoder.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' show basenameWithoutExtension, extension, join;
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'drive_service.g.dart';

const String driveFileKeySecretPrefix = 'drive_e2ee_file_key_';
const int driveUploadChunkSizeBytes = 5 * 1024 * 1024;
const int driveDirectUploadMaxChunks = 2;
const int driveDirectUploadMaxFileSizeBytes =
    driveUploadChunkSizeBytes * driveDirectUploadMaxChunks;
const int driveChunkUploadConcurrency = 3;

/// S3 direct uploads for in-memory byte payloads use one presigned `PUT` per
/// upload with a known `Content-Length`. S3 rejects single-PUT objects larger
/// than 5 GB, so larger in-memory payloads must use the proxied chunk flow.
const int driveS3DirectUploadMaxFileSizeBytes = 5 * 1024 * 1024 * 1024;

/// [XFile]s at or above this size are uploaded as an S3 multipart direct
/// upload (presigned per-part `PUT`s with server-side completion) instead of
/// a single presigned `PUT`: parts upload in parallel and a failed part only
/// needs that part re-sent. Smaller files keep the simpler single-PUT path.
const int driveS3DirectMultipartMinFileSizeBytes = 100 * 1024 * 1024;

Future<void> _localProbeQueue = Future<void>.value();
Player? _localProbePlayer;

Future<T> _withSerializedLocalMediaProbe<T>(
  Future<T> Function(Player player) operation,
) {
  final previous = _localProbeQueue;
  final release = Completer<void>();
  _localProbeQueue = release.future;
  return previous.then((_) async {
    try {
      if (!ensureMediaKitInitialized()) {
        throw StateError('bundled media player is unavailable');
      }
      final player = _localProbePlayer ??= Player();
      return await operation(player);
    } finally {
      if (!release.isCompleted) release.complete();
    }
  });
}

class _ClientMediaUpload {
  final Map<String, dynamic> analysis;
  final Uint8List? thumbnail;
  final Uint8List? compression;

  const _ClientMediaUpload({
    required this.analysis,
    this.thumbnail,
    this.compression,
  });
}

Map<String, dynamic>? _prepareClientImageUploadInBackground(
  Uint8List bytes,
) {
  try {
    final image = img.decodeImage(bytes);
    if (image == null || image.width <= 0 || image.height <= 0) return null;

    final maxEdge = max(image.width, image.height);
    final prepared = maxEdge > 1920
        ? img.copyResize(
            image,
            width: image.width >= image.height
                ? 1920
                : (image.width * 1920 / image.height).round(),
            height: image.height >= image.width
                ? 1920
                : (image.height * 1920 / image.width).round(),
          )
        : image;
    final rgba = prepared.getBytes(order: img.ChannelOrder.rgba);
    // One lossy encode is enough here. Retrying at lower qualities would
    // spend more CPU to optimize a derivative that may be skipped anyway.
    final compression = encodeLossyWebP(
      rgba: rgba,
      width: prepared.width,
      height: prepared.height,
      quality: 80.0,
    );
    if (compression == null ||
        compression.isEmpty ||
        compression.length >= bytes.length ||
        compression.length > 16 * 1024 * 1024) {
      return null;
    }
    return {
      'width': image.width,
      'height': image.height,
      'compression': compression,
    };
  } catch (_) {
    return null;
  }
}

class DriveQuotaExceededException implements Exception {
  final String message;

  const DriveQuotaExceededException([
    this.message =
        'Storage quota exceeded. Free up space or upgrade your quota and try again.',
  ]);

  @override
  String toString() => message;
}

class _ConcurrencyLimiter {
  final int maxConcurrent;
  final List<Future<void>> _running = [];

  _ConcurrencyLimiter(this.maxConcurrent);

  Future<T> run<T>(Future<T> Function() task) async {
    while (_running.length >= maxConcurrent) {
      await Future.any(_running);
    }

    final future = task();
    _running.add(future);
    unawaited(
      future.then<void>(
        (_) => _running.remove(future),
        onError: (Object _, StackTrace _) => _running.remove(future),
      ),
    );
    return future;
  }
}

class _DriveQuotaExceededSheet extends StatelessWidget {
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? quota;
  final List<SnFilePool>? pools;
  final String message;

  const _DriveQuotaExceededSheet({
    required this.usage,
    required this.quota,
    required this.pools,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SheetScaffold(
      titleText: 'storageQuota'.tr(),
      heightFactor: 0.74,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'uploadBlocked'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: QuotaSidebarWidget(
              usage: usage,
              quota: quota,
              pools: pools,
              showPoolFilter: false,
              onBuyExtraQuota: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (sheetContext) => const QuotaPurchaseSheet(),
                );
              },
            ),
          ),
        ],
      ),
    );
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
    final root = Map<String, dynamic>.from(fileMeta as Map);
    final e2ee = root['e2ee'];
    if (e2ee is! Map) return null;
    return Map<String, dynamic>.from(e2ee);
  }

  static String? extractEncryptionKey(SnCloudFile file) {
    final fileMeta = file.fileMeta;
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
  static Future<void>? _activeQuotaSheetFuture;
  final Ref ref;
  late final _client = ref.read(solarNetworkClientProvider).dio;
  late final _driveApi = ref.read(solarNetworkClientProvider).drive;
  late final _navigatorKey = ref.read(routerProvider).navigatorKey;
  FileUploader(this.ref);

  String _parseUploadError(DioException err) {
    String? message;
    if (err.response?.data is String) {
      message = err.response?.data as String?;
    } else if (err.response?.data?['message'] != null) {
      message = <String?>[
        err.response?.data?['message']?.toString(),
        err.response?.data?['detail']?.toString(),
      ].where((e) => e != null).cast<String>().map((e) => e.trim()).join('\n');
    } else if (err.response?.data?['errors'] != null) {
      final errors = err.response?.data['errors'] as Map<String, dynamic>;
      message = errors.values
          .map(
            (ele) =>
                (ele as List<dynamic>).map((ele) => ele.toString()).join('\n'),
          )
          .join('\n');
    }
    if (message == null || message.isEmpty) {
      message = err.response?.statusMessage;
    }
    message ??= err.message;
    return message ?? err.toString();
  }

  bool _isQuotaExceededError(DioException err) {
    if (err.response?.statusCode != 403) return false;
    final remoteMessage = _parseUploadError(err).toLowerCase();
    return remoteMessage.contains('quota') ||
        remoteMessage.contains('storage') ||
        remoteMessage.contains('space') ||
        err.requestOptions.path.startsWith('/drive/files/upload');
  }

  String _buildQuotaExceededMessage(DioException err) {
    final remoteMessage = _parseUploadError(err).trim();
    if (remoteMessage.isEmpty) {
      return const DriveQuotaExceededException().toString();
    }
    final normalized = remoteMessage.toLowerCase();
    if (normalized.contains('quota') || normalized.contains('storage')) {
      return remoteMessage;
    }
    return 'Storage quota exceeded. $remoteMessage';
  }

  Future<void> _showQuotaExceededSheet({required String message}) {
    final activeSheet = _activeQuotaSheetFuture;
    if (activeSheet != null) return activeSheet;

    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      return Future.value();
    }

    final future = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return FutureBuilder<
          ({
            Map<String, dynamic>? usage,
            Map<String, dynamic>? quota,
            List<SnFilePool> pools,
          })
        >(
          future: () async {
            final usageFuture = _driveApi.getTotalUsage();
            final quotaFuture = _driveApi.getQuota();
            final poolsFuture = _driveApi.listPools();
            final results = await Future.wait<dynamic>([
              usageFuture,
              quotaFuture,
              poolsFuture,
            ]);
            return (
              usage: results[0] as Map<String, dynamic>?,
              quota: results[1] as Map<String, dynamic>?,
              pools: results[2] as List<SnFilePool>,
            );
          }(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return SheetScaffold(
                titleText: 'storageQuota'.tr(),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SheetScaffold(
                titleText: 'storageQuota'.tr(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SelectableText(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            final data = snapshot.data;
            return _DriveQuotaExceededSheet(
              usage: data?.usage,
              quota: data?.quota,
              pools: data?.pools,
              message: message,
            );
          },
        );
      },
    ).whenComplete(() => _activeQuotaSheetFuture = null);

    _activeQuotaSheetFuture = future;
    return future;
  }

  Future<void> showQuotaExceededSheetPreview({
    String message =
        'Storage quota exceeded. Free up space or upgrade your quota and try again.',
  }) {
    return _showQuotaExceededSheet(message: message);
  }

  Future<T> _guardUploadQuotaExceeded<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (err) {
      if (_isQuotaExceededError(err)) {
        final message = _buildQuotaExceededMessage(err);
        unawaited(_showQuotaExceededSheet(message: message));
        throw DriveQuotaExceededException(message);
      }
      rethrow;
    }
  }

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

  Future<String?> resolveParentIdFromPath({
    String? path,
    String? poolId,
    String? workspaceId,
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
        queryParameters: {'pool': ?poolId, 'workspace_id': ?workspaceId},
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

  Future<_ClientMediaUpload?> _prepareClientMediaUpload(
    dynamic fileData,
    String contentType,
  ) async {
    if (kIsWeb) return null;
    final normalizedType = contentType.toLowerCase();
    if (normalizedType.startsWith('image/')) {
      return _prepareClientImageUpload(fileData);
    }
    if (fileData is! XFile || fileData.path.isEmpty) {
      return null;
    }
    if (normalizedType.startsWith('video/')) {
      Uint8List? thumbnail;
      try {
        thumbnail = await VideoThumbnail.thumbnailData(
          video: fileData.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 320,
          quality: 50,
        );
      } catch (_) {}
      final analysis = await _inspectLocalVideo(fileData.path);
      if (analysis.isEmpty) return null;
      return _ClientMediaUpload(analysis: analysis, thumbnail: thumbnail);
    }
    if (normalizedType.startsWith('audio/')) {
      final analysis = await _inspectLocalAudio(fileData.path);
      if (analysis.isEmpty) return null;
      return _ClientMediaUpload(analysis: analysis);
    }
    return null;
  }

  Future<_ClientMediaUpload?> _prepareClientImageUpload(
    dynamic fileData,
  ) async {
    final bytes = fileData is XFile
        ? await fileData.readAsBytes()
        : fileData is Uint8List
        ? fileData
        : null;
    if (bytes == null || bytes.isEmpty || bytes.length > 64 * 1024 * 1024) {
      return null;
    }

    // Decode, resize, pixel conversion, and native WebP encoding are CPU
    // bound. Keep them off Flutter's UI isolate so large images do not freeze
    // scrolling or upload progress updates.
    final prepared = await compute(
      _prepareClientImageUploadInBackground,
      bytes,
    );
    if (prepared == null) return null;

    final compression = prepared['compression'];
    if (compression is! Uint8List || compression.isEmpty) return null;
    return _ClientMediaUpload(
      analysis: {
        'width': prepared['width'],
        'height': prepared['height'],
      },
      compression: compression,
    );
  }

  Future<Map<String, dynamic>> _inspectLocalAudio(String path) async {
    try {
      return await _withSerializedLocalMediaProbe((player) async {
        try {
          final durationFuture = player.stream.duration
              .firstWhere((duration) => duration > Duration.zero)
              .timeout(const Duration(seconds: 8));
          final paramsFuture = player.stream.audioParams
              .firstWhere(
                (params) =>
                    (params.sampleRate ?? 0) > 0 ||
                    (params.channelCount ?? 0) > 0,
              )
              .timeout(const Duration(seconds: 8));
          await player.open(Media(path), play: false);
          final duration = await durationFuture;
          final params = await paramsFuture;
          final metadata = <String, dynamic>{
            'duration_ms': duration.inMilliseconds,
          };
          if ((params.sampleRate ?? 0) > 0) {
            metadata['sample_rate'] = params.sampleRate;
          }
          if ((params.channelCount ?? 0) > 0) {
            metadata['channels'] = params.channelCount;
          }
          return metadata;
        } finally {
          await player.stop();
        }
      });
    } catch (_) {
      return const {};
    }
  }

  Future<Map<String, dynamic>> _inspectLocalVideo(String path) async {
    try {
      return await _withSerializedLocalMediaProbe((player) async {
        try {
          final paramsFuture = player.stream.videoParams
              .firstWhere(
                (params) => (params.w ?? 0) > 0 && (params.h ?? 0) > 0,
              )
              .timeout(const Duration(seconds: 8));
          final durationFuture = player.stream.duration
              .firstWhere((duration) => duration > Duration.zero)
              .timeout(const Duration(seconds: 8));
          await player.open(Media(path), play: false);
          final params = await paramsFuture;
          final duration = await durationFuture;
          final metadata = <String, dynamic>{};
          if (params.w != null && params.w! > 0) metadata['width'] = params.w;
          if (params.h != null && params.h! > 0) metadata['height'] = params.h;
          if (duration > Duration.zero) {
            metadata['duration_ms'] = duration.inMilliseconds;
          }
          if (params.rotate != null) metadata['rotation'] = params.rotate;
          final width = params.w ?? 0;
          final height = params.h ?? 0;
          if (width > 0 && height > 0) {
            final divisor = _greatestCommonDivisor(width, height);
            metadata['aspect_ratio'] =
                '${width ~/ divisor}:${height ~/ divisor}';
          }
          return metadata;
        } finally {
          await player.stop();
        }
      });
    } catch (_) {
      return const {};
    }
  }

  int _greatestCommonDivisor(int left, int right) {
    while (right != 0) {
      final next = left % right;
      left = right;
      right = next;
    }
    return left == 0 ? 1 : left;
  }

  Future<void> _putClientDerivative(
    String url,
    Uint8List body,
    String contentType,
  ) async {
    final client = Dio();
    try {
      await client.put<dynamic>(
        url,
        data: body,
        options: Options(
          headers: {'Content-Type': contentType},
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
    } finally {
      client.close();
    }
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
    String? expiredAt,
    String? parentId,
    String? path,
    String? workspaceId,
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
      'pool_id': poolId,
      'parent_id':
          parentId ??
          await resolveParentIdFromPath(
            path: path,
            poolId: poolId,
            workspaceId: workspaceId,
          ),
      'workspace_id': workspaceId,
      'expired_at': expiredAt,
      'usage': usage,
      'application_type': applicationType,
    };

    payload.removeWhere((_, value) => value == null);

    return _guardUploadQuotaExceeded(() async {
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
        throw const FormatException(
          'Unexpected direct upload response payload.',
        );
      }

      return _parseUploadedFileResponse(
        Map<String, dynamic>.from(response.data as Map),
      );
    });
  }

  /// Attempts the S3-backed direct upload flow (see DysonFS memo/UPLOAD_FLOW.md):
  ///
  /// 1. `POST /drive/files/upload/prepare` — DysonFS authorizes the upload and
  ///    returns a short-lived presigned `PUT` URL plus a task id.
  /// 2. `PUT <upload_url>` — the file bytes go straight to the S3 pool. The
  ///    presigned URL is self-authenticating, so the app's auth interceptor
  ///    must not touch this request. `XFile` bodies are streamed from disk
  ///    with a known `Content-Length` (no chunked encoding, which presigned
  ///    URLs reject); in-memory and web payloads go through a bare Dio.
  /// 3. `POST /drive/files/upload/<task-id>/complete` — DysonFS verifies
  ///    the object and creates the visible file with status `Processing`;
  ///    clients must not wait for `Completed` before displaying it.
  ///
  /// Returns `null` when the pool cannot issue presigned URLs
  /// (`use_proxied_upload`), so the caller can fall back to the proxied flow.
  Future<SnCloudFile?> tryUploadViaS3Direct({
    required dynamic fileData,
    required String fileName,
    required String contentType,
    String? poolId,
    String? expiredAt,
    String? parentId,
    String? path,
    String? workspaceId,
    String? usage,
    String? applicationType,
    Function(double? progress, Duration estimate)? onProgress,
    void Function(String stage, double progress)? onStage,
  }) async {
    final xfile = fileData is XFile ? fileData : null;
    final byteData = fileData is Uint8List ? fileData : null;
    if (xfile == null && byteData == null) {
      throw ArgumentError('Invalid fileData type');
    }
    final int fileSize;
    final String hash;
    onStage?.call('hashing', 0);
    if (xfile != null) {
      fileSize = await xfile.length();
      hash = await _calculateFileHashFromStream(xfile.openRead());
    } else {
      fileSize = byteData!.length;
      hash = _calculateFileHash(byteData);
    }
    onStage?.call('hashing', 1);
    onStage?.call('preparing_media', 0);
    final clientMedia = await _prepareClientMediaUpload(fileData, contentType);
    onStage?.call('preparing_media', 1);

    // Large XFiles go through the multipart direct flow (parallel presigned
    // part PUTs, server-side completion). Byte payloads are already
    // materialized in memory and web cannot stream ranges, so they stay on
    // the single-PUT path below.
    if (xfile != null &&
        !kIsWeb &&
        fileSize >= driveS3DirectMultipartMinFileSizeBytes) {
      return _uploadViaS3Multipart(
        xfile: xfile,
        fileSize: fileSize,
        hash: hash,
        fileName: fileName,
        contentType: contentType,
        poolId: poolId,
        expiredAt: expiredAt,
        parentId: parentId,
        path: path,
        workspaceId: workspaceId,
        usage: usage,
        applicationType: applicationType,
        onProgress: onProgress,
        onStage: onStage,
        clientMedia: clientMedia,
      );
    }

    onStage?.call('creating_upload', 0);
    onProgress?.call(null, Duration.zero);
    final prepareTimer = Stopwatch()..start();
    Map<String, dynamic> prepared;
    try {
      final resolvedParentId =
          parentId ??
          await resolveParentIdFromPath(
            path: path,
            poolId: poolId,
            workspaceId: workspaceId,
          );
      final response = await _guardUploadQuotaExceeded(
        () => _client.post(
          '/drive/files/upload/prepare',
          data: {
            'file_name': fileName,
            'file_size': fileSize,
            'content_type': contentType,
            'hash': hash,
            'pool_id': poolId,
            'workspace_id': workspaceId,
            'expired_at': expiredAt,
            'parent_id': resolvedParentId,
            'usage': usage,
            'application_type': applicationType,
            'client_analysis': clientMedia?.analysis,
            'want_thumbnail': clientMedia?.thumbnail != null,
            'want_compression':
                clientMedia?.compression != null &&
                !contentType.toLowerCase().startsWith('video/'),
          },
          options: Options(
            sendTimeout: const Duration(minutes: 2),
            receiveTimeout: const Duration(minutes: 2),
          ),
        ),
      );
      prepared = Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (err) {
      final body = err.response?.data;
      if (body is Map && body['use_proxied_upload'] == true) {
        return null;
      }
      rethrow;
    }
    prepareTimer.stop();
    debugPrint(
      '[DriveUpload] S3 prepare took: ${prepareTimer.elapsedMilliseconds}ms',
    );

    if (prepared['use_proxied_upload'] == true) {
      return null;
    }

    final taskId = prepared['task_id']?.toString();
    final uploadUrl = prepared['upload_url']?.toString();
    if (taskId == null ||
        taskId.isEmpty ||
        uploadUrl == null ||
        uploadUrl.isEmpty) {
      throw const FormatException(
        'Direct upload prepare response is missing task_id or upload_url.',
      );
    }
    onStage?.call('creating_upload', 1);
    final preparedContentType = prepared['content_type']?.toString();
    final resolvedContentType =
        (preparedContentType == null || preparedContentType.isEmpty)
        ? contentType
        : preparedContentType;

    onStage?.call('uploading_source', 0);
    final putTimer = Stopwatch()..start();
    if (xfile != null && !kIsWeb) {
      await _putXFileToPresignedUrl(
        uploadUrl: uploadUrl,
        file: xfile,
        contentType: resolvedContentType,
        onProgress: (progress, estimate) {
          onStage?.call('uploading_source', progress ?? 0);
          onProgress?.call(progress, estimate);
        },
      );
    } else {
      final body = xfile != null
          ? Uint8List.fromList(await xfile.readAsBytes())
          : byteData!;
      final putClient = Dio();
      try {
        await putClient.put<dynamic>(
          uploadUrl,
          data: body,
          options: Options(
            headers: {'Content-Type': resolvedContentType},
            sendTimeout: const Duration(minutes: 10),
            receiveTimeout: const Duration(minutes: 5),
          ),
          onSendProgress: (sent, total) {
            if (total > 0) {
              final progress = sent / total;
              onStage?.call('uploading_source', progress);
              onProgress?.call(progress, Duration.zero);
            }
          },
        );
      } finally {
        putClient.close();
      }
    }
    onStage?.call('uploading_source', 1);
    final thumbnailUploadUrl = prepared['thumbnail_upload_url']?.toString();
    if (clientMedia?.thumbnail != null &&
        thumbnailUploadUrl != null &&
        thumbnailUploadUrl.isNotEmpty) {
      onStage?.call('uploading_thumbnail', 0);
      await _putClientDerivative(
        thumbnailUploadUrl,
        clientMedia!.thumbnail!,
        'image/jpeg',
      );
      onStage?.call('uploading_thumbnail', 1);
    }
    final compressionUploadUrl = prepared['compression_upload_url']?.toString();
    if (clientMedia?.compression != null &&
        compressionUploadUrl != null &&
        compressionUploadUrl.isNotEmpty) {
      onStage?.call('uploading_compression', 0);
      await _putClientDerivative(
        compressionUploadUrl,
        clientMedia!.compression!,
        'image/webp',
      );
      onStage?.call('uploading_compression', 1);
    }
    putTimer.stop();
    debugPrint('[DriveUpload] S3 PUT took: ${putTimer.elapsedMilliseconds}ms');
    onStage?.call('finalizing', 0);
    final result = await _completeS3DirectUpload(taskId, onProgress);
    onStage?.call('finalizing', 1);
    return result;
  }

  /// Commits a prepared S3 direct upload (single PUT or multipart) and parses
  /// the resulting file. The server verifies the uploaded object/parts before
  /// creating the visible file.
  Future<SnCloudFile> _completeS3DirectUpload(
    String taskId,
    Function(double? progress, Duration estimate)? onProgress,
  ) async {
    onProgress?.call(null, Duration.zero);
    final completeTimer = Stopwatch()..start();
    final response = await _guardUploadQuotaExceeded(
      () => _client.post(
        '/drive/files/upload/$taskId/complete',
        options: Options(
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      ),
    );
    completeTimer.stop();
    debugPrint(
      '[DriveUpload] S3 complete-direct took: ${completeTimer.elapsedMilliseconds}ms',
    );

    if (response.data is! Map) {
      throw const FormatException(
        'Unexpected direct upload complete response payload.',
      );
    }
    return _parseUploadedFileResponse(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  /// Uploads an [XFile] as an S3 multipart direct upload.
  ///
  /// `prepare` with `multipart: true` creates the S3 session server-side and
  /// returns `upload_id`, `part_size` and `part_count`. Each part is presigned
  /// on demand (`POST /drive/files/upload/<task-id>/part`), PUT straight to S3
  /// with a bare client (presigned URLs are self-authenticating), and
  /// `complete-direct` verifies part completeness and commits the session
  /// server-side. Parts are uploaded in windows of
  /// [driveChunkUploadConcurrency] so memory stays bounded to a few parts.
  Future<SnCloudFile?> _uploadViaS3Multipart({
    required XFile xfile,
    required int fileSize,
    required String hash,
    required String fileName,
    _ClientMediaUpload? clientMedia,
    required String contentType,
    String? poolId,
    String? expiredAt,
    String? parentId,
    String? path,
    String? workspaceId,
    String? usage,
    String? applicationType,
    Function(double? progress, Duration estimate)? onProgress,
    void Function(String stage, double progress)? onStage,
  }) async {
    onStage?.call('creating_upload', 0);
    onProgress?.call(null, Duration.zero);
    final prepareTimer = Stopwatch()..start();
    Map<String, dynamic> prepared;
    try {
      final resolvedParentId =
          parentId ??
          await resolveParentIdFromPath(
            path: path,
            poolId: poolId,
            workspaceId: workspaceId,
          );
      final response = await _guardUploadQuotaExceeded(
        () => _client.post(
          '/drive/files/upload/prepare',
          data: {
            'file_name': fileName,
            'file_size': fileSize,
            'content_type': contentType,
            'hash': hash,
            'pool_id': poolId,
            'workspace_id': workspaceId,
            'expired_at': expiredAt,
            'parent_id': resolvedParentId,
            'usage': usage,
            'application_type': applicationType,
            'multipart': true,
            'client_analysis': clientMedia?.analysis,
            'want_thumbnail': clientMedia?.thumbnail != null,
            'want_compression':
                clientMedia?.compression != null &&
                !contentType.toLowerCase().startsWith('video/'),
          },
          options: Options(
            sendTimeout: const Duration(minutes: 2),
            receiveTimeout: const Duration(minutes: 2),
          ),
        ),
      );
      prepared = Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (err) {
      final body = err.response?.data;
      if (body is Map && body['use_proxied_upload'] == true) {
        return null;
      }
      rethrow;
    }
    prepareTimer.stop();
    debugPrint(
      '[DriveUpload] S3 multipart prepare took: '
      '${prepareTimer.elapsedMilliseconds}ms',
    );

    if (prepared['use_proxied_upload'] == true) {
      return null;
    }

    final taskId = prepared['task_id']?.toString();
    final partSize = prepared['part_size'] is int
        ? prepared['part_size'] as int
        : int.tryParse(prepared['part_size']?.toString() ?? '');
    final partCount = prepared['part_count'] is int
        ? prepared['part_count'] as int
        : int.tryParse(prepared['part_count']?.toString() ?? '');
    if (taskId == null ||
        taskId.isEmpty ||
        partSize == null ||
        partSize <= 0 ||
        partCount == null ||
        partCount <= 0) {
      throw const FormatException(
        'Direct upload prepare response is missing task_id, part_size or '
        'part_count.',
      );
    }
    onStage?.call('creating_upload', 1);
    final preparedContentType = prepared['content_type']?.toString();
    final resolvedContentType =
        (preparedContentType == null || preparedContentType.isEmpty)
        ? contentType
        : preparedContentType;

    // Parts the server already holds for this hash (a resumed session) are
    // skipped: their byte counts are still folded into progress.
    final uploadedParts = <int>{};
    if (prepared['uploaded_parts'] is List) {
      for (final raw in prepared['uploaded_parts'] as List) {
        final n = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
        if (n != null && n >= 1 && n <= partCount) {
          uploadedParts.add(n);
        }
      }
    }

    onStage?.call('uploading_source', 0);
    final putTimer = Stopwatch()..start();
    final limiter = _ConcurrencyLimiter(driveChunkUploadConcurrency);
    final partProgress = <int, int>{};
    var sent = 0;

    int bytesForPart(int partNumber) {
      return (partNumber == partCount)
          ? fileSize - (partCount - 1) * partSize
          : partSize;
    }

    void reportPartProgress(int partNumber, int bytes) {
      final maximum = bytesForPart(partNumber);
      final current = bytes.clamp(0, maximum).toInt();
      final previous = partProgress[partNumber] ?? 0;
      if (current == previous) return;
      partProgress[partNumber] = current;
      sent += current - previous;
      final progress = sent / fileSize;
      onStage?.call('uploading_source', progress);
      onProgress?.call(progress, Duration.zero);
    }

    for (
      var batchStart = 1;
      batchStart <= partCount;
      batchStart += driveChunkUploadConcurrency
    ) {
      final batchEnd = (batchStart + driveChunkUploadConcurrency > partCount)
          ? partCount + 1
          : batchStart + driveChunkUploadConcurrency;
      await Future.wait([
        for (var partNumber = batchStart; partNumber < batchEnd; partNumber++)
          if (uploadedParts.contains(partNumber))
            () async {
              reportPartProgress(partNumber, bytesForPart(partNumber));
            }()
          else
            limiter.run(
              () =>
                  _uploadS3Part(
                    xfile: xfile,
                    taskId: taskId,
                    partNumber: partNumber,
                    partSize: partSize,
                    fileSize: fileSize,
                    contentType: resolvedContentType,
                    onProgress: (bytes) =>
                        reportPartProgress(partNumber, bytes),
                  ).then((bytes) {
                    reportPartProgress(partNumber, bytes);
                  }),
            ),
      ]);
    }
    putTimer.stop();
    debugPrint(
      '[DriveUpload] S3 multipart PUT took: '
      '${putTimer.elapsedMilliseconds}ms',
    );

    final thumbnailUploadUrl = prepared['thumbnail_upload_url']?.toString();
    if (clientMedia?.thumbnail != null &&
        thumbnailUploadUrl != null &&
        thumbnailUploadUrl.isNotEmpty) {
      onStage?.call('uploading_thumbnail', 0);
      await _putClientDerivative(
        thumbnailUploadUrl,
        clientMedia!.thumbnail!,
        'image/jpeg',
      );
      onStage?.call('uploading_thumbnail', 1);
    }
    final compressionUploadUrl = prepared['compression_upload_url']?.toString();
    if (clientMedia?.compression != null &&
        compressionUploadUrl != null &&
        compressionUploadUrl.isNotEmpty) {
      onStage?.call('uploading_compression', 0);
      await _putClientDerivative(
        compressionUploadUrl,
        clientMedia!.compression!,
        'image/webp',
      );
      onStage?.call('uploading_compression', 1);
    }
    onStage?.call('finalizing', 0);
    final result = await _completeS3DirectUpload(taskId, onProgress);
    onStage?.call('finalizing', 1);
    return result;
  }

  /// Presigns and uploads one part of a multipart direct upload, returning
  /// the number of bytes sent.
  Future<int> _uploadS3Part({
    required XFile xfile,
    required String taskId,
    required int partNumber,
    required int partSize,
    required int fileSize,
    required String contentType,
    void Function(int bytesSent)? onProgress,
  }) async {
    final presignResponse = await _guardUploadQuotaExceeded(
      () => _client.post(
        '/drive/files/upload/$taskId/part',
        data: {'part_number': partNumber},
        options: Options(
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      ),
    );
    final partBody = Map<String, dynamic>.from(presignResponse.data as Map);
    final partUrl = partBody['upload_url']?.toString();
    if (partUrl == null || partUrl.isEmpty) {
      throw const FormatException(
        'Direct upload part presign response is missing upload_url.',
      );
    }

    final start = (partNumber - 1) * partSize;
    final end = partNumber * partSize < fileSize
        ? partNumber * partSize
        : fileSize;
    final body = await _readFileRange(xfile, start, end);

    final putClient = Dio();
    try {
      await putClient.put<dynamic>(
        partUrl,
        data: body,
        options: Options(
          headers: {'Content-Type': contentType},
          sendTimeout: const Duration(minutes: 10),
          receiveTimeout: const Duration(minutes: 5),
        ),
        onSendProgress: (sent, total) {
          if (onProgress == null) return;
          final progressBytes = total > 0 ? sent.clamp(0, body.length) : sent;
          onProgress(progressBytes.toInt());
        },
      );
    } finally {
      putClient.close();
    }
    return body.length;
  }

  /// Reads `[start, end)` bytes of [xfile] into memory (bounded to one part).
  Future<Uint8List> _readFileRange(XFile xfile, int start, int end) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in xfile.openRead(start, end)) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  /// Streams an [XFile] to a presigned `PUT` URL with a known `Content-Length`.
  ///
  /// The presigned URL is self-authenticating; the app's auth interceptor must
  /// not touch this request, so a raw [HttpClient] is used instead of the
  /// shared Dio. `dart:io` streams cannot set `Content-Length` (they fall back
  /// to chunked transfer encoding, which S3 presigned URLs reject), so the
  /// body is streamed here with the size set explicitly.
  Future<void> _putXFileToPresignedUrl({
    required String uploadUrl,
    required XFile file,
    required String contentType,
    Function(double? progress, Duration estimate)? onProgress,
  }) async {
    final uri = Uri.parse(uploadUrl);
    final total = await file.length();
    final client = HttpClient();
    try {
      final request = await client
          .putUrl(uri)
          .timeout(const Duration(seconds: 30));
      request.contentLength = total;
      request.headers.contentType = ContentType.parse(contentType);

      var sent = 0;
      final progressStream = file.openRead().map((chunk) {
        sent += chunk.length;
        if (total > 0) {
          onProgress?.call(sent / total, Duration.zero);
        }
        return chunk;
      });
      await request
          .addStream(progressStream)
          .timeout(const Duration(minutes: 30));
      final response = await request.close().timeout(
        const Duration(minutes: 5),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorBody = await response
            .transform(utf8.decoder)
            .join()
            .timeout(const Duration(seconds: 10));
        throw DioException.badResponse(
          statusCode: response.statusCode,
          requestOptions: RequestOptions(path: uploadUrl),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: uploadUrl),
            statusCode: response.statusCode,
            data: errorBody,
          ),
        );
      }
    } finally {
      client.close(force: true);
    }
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
    String? expiredAt,
    int? chunkSize,
    String? parentId,
    String? path,
    String? workspaceId,
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
    final payload = <String, dynamic>{
      'hash': hash,
      'file_name': fileName,
      'file_size': fileSize,
      'content_type': contentType,
      'pool_id': poolId,
      'workspace_id': workspaceId,
      'expired_at': expiredAt,
      'chunk_size': chunkSize,
      'parent_id':
          parentId ??
          await resolveParentIdFromPath(
            path: path,
            poolId: poolId,
            workspaceId: workspaceId,
          ),
      'usage': usage,
      'application_type': applicationType,
    };

    stepTimer
      ..reset()
      ..start();
    final response = await _guardUploadQuotaExceeded(
      () => _client.post(
        '/drive/files/upload/create',
        data: payload,
        options: Options(
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
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

    await _guardUploadQuotaExceeded(
      () => _client.post(
        '/drive/files/upload/chunk/$taskId/$chunkIndex',
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      ),
    );
    stepTimer.stop();
    debugPrint(
      '[DriveUpload] Chunk $chunkIndex upload took: ${stepTimer.elapsedMilliseconds}ms',
    );
  }

  Future<Map<String, dynamic>> getUploadProgress(String taskId) async {
    final response = await _guardUploadQuotaExceeded(
      () => _client.get(
        '/drive/files/upload/progress/$taskId',
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
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
    final response = await _guardUploadQuotaExceeded(
      () => _client.post(
        '/drive/files/upload/complete/$taskId',
        options: Options(
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
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
    int completedBytes = 0,
    Function(double? progress, Duration estimate)? onProgress,
  }) async {
    var bytesUploaded = 0;
    final bytesBeingUploaded = List<int>.filled(chunks.length, 0);
    final futures = <Future<void>>[];
    final semaphore = _ConcurrencyLimiter(driveChunkUploadConcurrency);

    void reportProgress() {
      final uploaded =
          completedBytes +
          bytesUploaded +
          bytesBeingUploaded.fold(0, (sum, bytes) => sum + bytes);
      onProgress?.call((uploaded / totalSize).clamp(0.0, 1.0), Duration.zero);
    }

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
              // Dio reports multipart bytes, including form-data overhead. Use
              // the chunk length so the task represents file bytes only.
              bytesBeingUploaded[i] = sent.clamp(0, chunk.length);
              reportProgress();
            },
          );
          bytesBeingUploaded[i] = 0;
          bytesUploaded += chunk.length;
          reportProgress();
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
    String? workspaceId,
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

    // Prefer the S3-backed direct upload (presigned PUT, multipart for large
    // XFiles) when the pool supports it; fall back to the proxied flow when it
    // cannot issue signed URLs. XFiles of any size are eligible (multipart
    // above the threshold, single PUT below); in-memory payloads are capped by
    // the single-PUT object limit. E2EE payloads and explicit chunk sizes stay
    // on the proxied path.
    if (localEncryptKey == null &&
        customChunkSize == null &&
        (uploadData is XFile ||
            totalSize <= driveS3DirectUploadMaxFileSizeBytes)) {
      final s3Uploaded = await tryUploadViaS3Direct(
        fileData: uploadData,
        fileName: fileName,
        contentType: contentType,
        poolId: poolId,
        expiredAt: expiredAt,
        parentId: parentId,
        path: path,
        workspaceId: workspaceId,
        usage: usage,
        applicationType: applicationType,
        onProgress: onProgress,
      );
      if (s3Uploaded != null) {
        overallTimer.stop();
        debugPrint(
          '[DriveUpload] Total upload time: ${overallTimer.elapsedMilliseconds}ms',
        );
        return s3Uploaded;
      }
    }

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
        expiredAt: expiredAt,
        parentId: parentId,
        path: path,
        workspaceId: workspaceId,
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
      expiredAt: expiredAt,
      chunkSize: customChunkSize,
      parentId: parentId,
      path: path,
      workspaceId: workspaceId,
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
          completedBytes: bytesUploaded,
          onProgress: onProgress,
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
          completedBytes: bytesUploaded,
          onProgress: onProgress,
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
    String? workspaceId,
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
                workspaceId,
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
                workspaceId,
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
      workspaceId,
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
    String? workspaceId,
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
        workspaceId: workspaceId,
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
        workspaceId: workspaceId,
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
    String? workspaceId,
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
          workspaceId: workspaceId,
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
    if (data is IDisplayableCloudFile) {
      return data.mimeType;
    }
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
      return data.mimeType;
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
  Future<void> moveFile(String fileId, {String? parentId, bool? indexed}) {
    return moveFiles([fileId], parentId: parentId, indexed: indexed);
  }

  /// Moves multiple files to a different folder or to root. Owner only.
  Future<void> moveFiles(
    List<String> fileIds, {
    String? parentId,
    bool? indexed,
  }) async {
    if (fileIds.isEmpty) return;
    await _client.post(
      '/drive/files/move/batch',
      data: {'file_ids': fileIds, 'parent_id': ?parentId, 'indexed': ?indexed},
    );
  }

  /// Permanently deletes a file. Owner only.
  Future<void> deleteFile(String fileId) {
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
  ///
  /// [marks] — integer category indices.
  /// API returns 200 with no body; update local state after success.
  Future<void> updateSensitiveMarks(String fileId, List<int> marks) {
    return _driveApi.updateSensitiveMarks(fileId, marks);
  }

  /// Sets arbitrary user-defined metadata. Owner only.
  Future<SnCloudFile> updateUserMeta(String fileId, Map<String, dynamic> meta) {
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
      extName = item.mimeType.split('/').lastOrNull ?? 'jpeg';
    }
    return extName.replaceFirst('.', '');
  }

  String _getFileName(SnCloudFile item, String extName) {
    return item.name.isEmpty ? '${item.id}.$extName' : item.name;
  }

  Future<String> _resolveUniqueDestinationPath(
    String directoryPath,
    String fileName,
  ) async {
    final fileExt = extension(fileName);
    final originalBaseName = fileExt.isEmpty
        ? fileName
        : basenameWithoutExtension(fileName);
    final suffixMatch = RegExp(
      r'^(.*) \((\d+)\)$',
    ).firstMatch(originalBaseName);
    final fileBaseName = suffixMatch?.group(1) ?? originalBaseName;
    var suffix = int.tryParse(suffixMatch?.group(2) ?? '') ?? 0;

    var candidatePath = join(directoryPath, fileName);
    while (await File(candidatePath).exists()) {
      suffix++;
      final candidateName = fileExt.isEmpty
          ? '$fileBaseName ($suffix)'
          : '$fileBaseName ($suffix)$fileExt';
      candidatePath = join(directoryPath, candidateName);
    }
    return candidatePath;
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
    if (serverUrl != null && item.storageUrl == null) {
      return '$serverUrl/drive/files/${item.id}?original=true';
    }
    final baseUri = item.storageUrl ?? '/drive/files/${item.id}';
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

  Future<({String filePath, int bytes})> _downloadToTemp(
    SnCloudFile item,
    String extName, {
    void Function(int received, int total)? onProgress,
  }) async {
    final cachedPath = await _getCachedOriginalFile(item);
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${item.id}.$extName';

    if (cachedPath != null) {
      await File(cachedPath).copy(filePath);
      final cachedBytes = await File(filePath).length();
      onProgress?.call(cachedBytes, cachedBytes);
      await _tryDecryptDownloadedFile(filePath, item);
      final bytes = await File(filePath).length();
      return (filePath: filePath, bytes: bytes);
    }

    await _driveApi.downloadFile(
      fileId: item.id,
      savePath: filePath,
      onReceiveProgress: onProgress,
    );
    await _tryDecryptDownloadedFile(filePath, item);
    final bytes = await File(filePath).length();

    return (filePath: filePath, bytes: bytes);
  }

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  Future<String?> _resolveDownloadDirectory({
    required bool useDownloadsFolder,
  }) async {
    if (_isDesktop && useDownloadsFolder) {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        return downloadsDir.path;
      }
    }

    if (_isDesktop) {
      return FilePicker.getDirectoryPath(
        dialogTitle: 'selectDownloadFolder'.tr(),
      );
    }

    return null;
  }

  Future<String> _saveTempFileToDirectory(
    String tempFilePath,
    SnCloudFile item,
    String extName, {
    required String directoryPath,
  }) async {
    final filePath = await _resolveUniqueDestinationPath(
      directoryPath,
      _getFileName(item, extName),
    );
    await File(tempFilePath).copy(filePath);
    return filePath;
  }

  Future<String?> _persistDownloadedFile(
    SnCloudFile item,
    String tempFilePath,
    String extName, {
    required bool useDownloadsFolder,
  }) async {
    if (_isDesktop) {
      final directory = await _resolveDownloadDirectory(
        useDownloadsFolder: useDownloadsFolder,
      );
      if (directory == null) return null;
      return _saveTempFileToDirectory(
        tempFilePath,
        item,
        extName,
        directoryPath: directory,
      );
    }

    await FileSaver.instance.saveFile(
      name: _getFileName(item, extName),
      file: File(tempFilePath),
      mimeType:
          MimeType.values.firstWhereOrNull((e) => e.type == item.mimeType) ??
          MimeType.custom,
    );
    return null;
  }

  Future<void> saveToGallery(
    SnCloudFile item, {
    bool useDownloadsFolder = false,
  }) async {
    try {
      showSnackBar('savingImage'.tr());

      final extName = _getFileExtension(item);
      final downloaded = await _downloadToTemp(item, extName);

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await Gal.putImage(downloaded.filePath, album: 'Solar Network');
        showSnackBar('imageSavedToGallery'.tr());
      } else {
        final savedPath = await _persistDownloadedFile(
          item,
          downloaded.filePath,
          extName,
          useDownloadsFolder: useDownloadsFolder,
        );
        if (savedPath != null) {
          showSnackBar('imageSaved'.tr());
        }
      }
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> downloadFile(
    SnCloudFile item, {
    bool useDownloadsFolder = false,
  }) async {
    await downloadWithProgress(item, useDownloadsFolder: useDownloadsFolder);
  }

  Future<void> downloadFiles(
    List<SnCloudFile> items, {
    bool useDownloadsFolder = false,
  }) async {
    if (items.isEmpty) return;

    try {
      final directoryPath = await _resolveDownloadDirectory(
        useDownloadsFolder: useDownloadsFolder,
      );
      if (_isDesktop && directoryPath == null) {
        return;
      }

      showSnackBar('downloadingFiles'.plural(items.length));

      final tasks = ref.read(tasksProvider.notifier);
      var completed = 0;
      var failed = 0;

      for (final item in items) {
        final taskId = tasks.addTask(
          title: item.name,
          type: AppTaskType.driveDownload,
          status: AppTaskStatus.inProgress,
          metadata: DriveDownloadTaskMeta(fileId: item.id).toMap(),
        );
        try {
          final extName = _getFileExtension(item);
          final downloaded = await _downloadToTemp(
            item,
            extName,
            onProgress: (received, total) {
              if (total > 0) {
                tasks.updateTask(
                  taskId,
                  progress: received / total,
                  metadata: DriveDownloadTaskMeta(
                    fileId: item.id,
                    totalBytes: total,
                    downloadedBytes: received,
                  ).toMap(),
                );
              }
            },
          );

          if (_isDesktop) {
            await _saveTempFileToDirectory(
              downloaded.filePath,
              item,
              extName,
              directoryPath: directoryPath!,
            );
          } else {
            await FileSaver.instance.saveFile(
              name: _getFileName(item, extName),
              file: File(downloaded.filePath),
              mimeType:
                  MimeType.values.firstWhereOrNull(
                    (e) => e.type == item.mimeType,
                  ) ??
                  MimeType.custom,
            );
          }
          tasks.updateTask(
            taskId,
            status: AppTaskStatus.completed,
            progress: 1.0,
          );
          completed++;
        } catch (e) {
          failed++;
          tasks.updateTask(
            taskId,
            status: AppTaskStatus.failed,
            errorMessage: e.toString(),
          );
        }
      }

      if (failed > 0) {
        showSnackBar(
          'downloadedFilesFailed'.plural(
            completed,
            args: [completed.toString(), failed.toString()],
          ),
        );
      } else {
        showSnackBar(
          'downloadedFiles'.plural(completed, args: [completed.toString()]),
        );
      }
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> downloadWithProgress(
    SnCloudFile item, {
    bool useDownloadsFolder = false,
    void Function(int received, int total)? onProgress,
  }) async {
    final tasks = ref.read(tasksProvider.notifier);
    String? taskId;

    try {
      final extName = _getFileExtension(item);
      final directoryPath = await _resolveDownloadDirectory(
        useDownloadsFolder: useDownloadsFolder,
      );
      if (_isDesktop && directoryPath == null) {
        return;
      }

      taskId = tasks.addTask(
        title: item.name,
        type: AppTaskType.driveDownload,
        status: AppTaskStatus.inProgress,
        metadata: DriveDownloadTaskMeta(fileId: item.id).toMap(),
      );
      showSnackBar('downloadingFile'.tr());
      final downloaded = await _downloadToTemp(
        item,
        extName,
        onProgress: (count, total) {
          onProgress?.call(count, total);
          if (total > 0 && taskId != null) {
            tasks.updateTask(
              taskId,
              progress: count / total,
              metadata: DriveDownloadTaskMeta(
                fileId: item.id,
                totalBytes: total,
                downloadedBytes: count,
              ).toMap(),
            );
          }
        },
      );

      if (_isDesktop) {
        await _saveTempFileToDirectory(
          downloaded.filePath,
          item,
          extName,
          directoryPath: directoryPath!,
        );
      } else {
        await FileSaver.instance.saveFile(
          name: _getFileName(item, extName),
          file: File(downloaded.filePath),
          mimeType:
              MimeType.values.firstWhereOrNull(
                (e) => e.type == item.mimeType,
              ) ??
              MimeType.custom,
        );
      }
      tasks.updateTask(taskId, status: AppTaskStatus.completed, progress: 1.0);
      showSnackBar(_isDesktop ? 'fileSaved'.tr() : 'fileSavedToDownloads'.tr());
    } catch (e) {
      if (taskId != null) {
        tasks.updateTask(
          taskId,
          status: AppTaskStatus.failed,
          errorMessage: e.toString(),
        );
      }
      showErrorAlert(e);
    }
  }
}

@Riverpod(keepAlive: true)
FileDownloadService driveFileDownloader(Ref ref) {
  return FileDownloadService(ref);
}
